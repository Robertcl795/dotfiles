#!/usr/bin/env python3
"""Local vector context DB: index repos and search them semantically.

Storage: ~/.local/share/ai-context (override with AI_CONTEXT_HOME).
One Chroma collection per repo. Embeddings are computed locally with
fastembed (ONNX) — no API keys, works offline after the first model
download.

Usage:
    uv run indexer.py index --repo /path/to/repo [--collection name]
    uv run indexer.py search "query" [--collection name] [-k 8]
    uv run indexer.py collections
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

DB_PATH = Path(os.environ.get("AI_CONTEXT_HOME", "~/.local/share/ai-context")).expanduser()
EMBED_MODEL = os.environ.get("AI_CONTEXT_MODEL", "BAAI/bge-small-en-v1.5")

INCLUDE_EXT = {
    ".md", ".ts", ".tsx", ".js", ".jsx", ".html", ".scss", ".css",
    ".py", ".sh", ".zsh", ".fish", ".toml", ".yaml", ".yml", ".kdl",
}
EXCLUDE_DIRS = {
    ".git", "node_modules", "dist", "build", "out", ".venv", "venv",
    "target", ".next", ".angular", "coverage", "__pycache__", ".nx",
}
MAX_FILE_BYTES = 200_000
CHUNK_LINES = 60
CHUNK_OVERLAP = 10


def _embedding_function():
    """Chroma embedding function backed by fastembed (local ONNX).

    Subclasses chroma's EmbeddingFunction base so query-time helpers
    (embed_query, retries, config persistence) come from the base class.
    Defined inside a factory so importing this module never pulls chroma.
    """
    from chromadb.api.types import Documents, EmbeddingFunction

    class FastEmbedFunction(EmbeddingFunction[Documents]):
        def __init__(self) -> None:
            from fastembed import TextEmbedding

            self._model = TextEmbedding(EMBED_MODEL)

        def __call__(self, input):  # noqa: A002 - name mandated by chroma
            return [e.tolist() for e in self._model.embed(list(input))]

        @staticmethod
        def name() -> str:
            return "fastembed"

        def get_config(self) -> dict:
            return {"model": EMBED_MODEL}

        @staticmethod
        def build_from_config(config: dict):
            return _embedding_function()()

    return FastEmbedFunction


def _client():
    import chromadb

    DB_PATH.mkdir(parents=True, exist_ok=True)
    return chromadb.PersistentClient(path=str(DB_PATH))


def _collection(client, name: str, create: bool = True):
    fn = _embedding_function()()
    if create:
        return client.get_or_create_collection(name, embedding_function=fn)
    return client.get_collection(name, embedding_function=fn)


def iter_files(root: Path):
    for path in sorted(root.rglob("*")):
        if not path.is_file() or path.suffix.lower() not in INCLUDE_EXT:
            continue
        if any(part in EXCLUDE_DIRS for part in path.relative_to(root).parts):
            continue
        try:
            if path.stat().st_size > MAX_FILE_BYTES:
                continue
        except OSError:
            continue
        yield path


def chunk_file(path: Path) -> list[tuple[str, int]]:
    """Split a file into (text, start_line) chunks."""
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return []
    lines = text.splitlines()
    if not lines:
        return []

    chunks: list[tuple[str, int]] = []
    if path.suffix.lower() == ".md":
        # Split markdown on top-level/second-level headings, cap chunk size
        current: list[str] = []
        start = 1
        for i, line in enumerate(lines, start=1):
            if line.startswith(("# ", "## ")) and current:
                chunks.append(("\n".join(current), start))
                current, start = [], i
            current.append(line)
            if sum(len(l) for l in current) > 4000:
                chunks.append(("\n".join(current), start))
                current, start = [], i + 1
        if current:
            chunks.append(("\n".join(current), start))
    else:
        step = CHUNK_LINES - CHUNK_OVERLAP
        for start_idx in range(0, len(lines), step):
            block = lines[start_idx : start_idx + CHUNK_LINES]
            if block:
                chunks.append(("\n".join(block), start_idx + 1))
            if start_idx + CHUNK_LINES >= len(lines):
                break
    return [(t, s) for t, s in chunks if t.strip()]


def index_repo(repo: str, collection: str = "") -> str:
    root = Path(repo).expanduser().resolve()
    if not root.is_dir():
        raise SystemExit(f"Not a directory: {root}")
    name = collection or root.name

    client = _client()
    # Rebuild from scratch so deleted files don't linger
    try:
        client.delete_collection(name)
    except Exception:
        pass
    coll = _collection(client, name)

    ids: list[str] = []
    docs: list[str] = []
    metas: list[dict] = []
    files = 0
    for path in iter_files(root):
        rel = str(path.relative_to(root))
        file_chunks = chunk_file(path)
        if file_chunks:
            files += 1
        for i, (text, start_line) in enumerate(file_chunks):
            ids.append(f"{rel}:{i}")
            docs.append(text)
            metas.append({"path": rel, "start_line": start_line})

    for batch_start in range(0, len(ids), 256):
        end = batch_start + 256
        coll.add(ids=ids[batch_start:end], documents=docs[batch_start:end], metadatas=metas[batch_start:end])

    summary = f"Indexed {files} files ({len(ids)} chunks) into collection '{name}'."
    print(summary, file=sys.stderr)
    return summary


def search(query: str, collection: str = "", k: int = 8) -> list[dict]:
    client = _client()
    names = [collection] if collection else [c.name for c in client.list_collections()]
    hits: list[dict] = []
    for name in names:
        try:
            coll = _collection(client, name, create=False)
        except Exception:
            continue
        res = coll.query(query_texts=[query], n_results=min(k, max(coll.count(), 1)))
        for doc, meta, dist in zip(
            res["documents"][0], res["metadatas"][0], res["distances"][0]
        ):
            hits.append(
                {
                    "collection": name,
                    "path": meta.get("path", "?"),
                    "start_line": meta.get("start_line", 1),
                    "score": round(1 - dist, 4),
                    "snippet": doc[:1200],
                }
            )
    hits.sort(key=lambda h: h["score"], reverse=True)
    return hits[:k]


def list_collections() -> list[str]:
    return sorted(c.name for c in _client().list_collections())


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_index = sub.add_parser("index", help="(Re)index a repository")
    p_index.add_argument("--repo", required=True)
    p_index.add_argument("--collection", default="")

    p_search = sub.add_parser("search", help="Semantic search")
    p_search.add_argument("query")
    p_search.add_argument("--collection", default="")
    p_search.add_argument("-k", type=int, default=8)

    sub.add_parser("collections", help="List indexed collections")

    args = parser.parse_args()
    if args.cmd == "index":
        index_repo(args.repo, args.collection)
    elif args.cmd == "search":
        for hit in search(args.query, args.collection, args.k):
            print(f"[{hit['score']:.3f}] {hit['collection']}:{hit['path']}:{hit['start_line']}")
            first_lines = "\n".join(hit["snippet"].splitlines()[:6])
            print(f"{first_lines}\n---")
    elif args.cmd == "collections":
        for name in list_collections():
            print(name)


if __name__ == "__main__":
    main()
