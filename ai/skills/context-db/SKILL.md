---
name: context-db
description: Query or (re)index the local vector context DB (ChromaDB + fastembed) for semantic search over repos, docs and team instructions. Use when you need prior art, ADRs, related code or conventions that plain grep won't find by keyword.
---

# Vector Context DB

Local semantic search over indexed repositories. Storage lives in
`~/.local/share/ai-context/` (override: `AI_CONTEXT_HOME`); one Chroma
collection per repo. Embeddings are local (fastembed/ONNX) — no API calls.

## When to reach for it

- "How did we solve X elsewhere?" — search before designing something new
- Finding conventions/ADRs/docs whose wording you don't know exactly
- Locating related code across a large workspace when grep keywords fail

Prefer plain Grep when you know the literal string — it's faster and exact.

## Via MCP (preferred when the `context-db` server is connected)

- `context_search(query, collection?, k?)` — semantic top-k chunks with
  file paths and scores
- `context_index(path, collection?)` — (re)index a repo; collection defaults
  to the directory name
- `context_collections()` — list what's indexed

## Via CLI (fallback)

```bash
# index the current repo
uv run --directory ~/.dotfiles/ai/context indexer.py index --repo .

# search (optionally scope to a collection)
uv run --directory ~/.dotfiles/ai/context indexer.py search "query" --collection myrepo

# or with just, from anywhere in dotfiles:
just --justfile ~/.dotfiles/ai/justfile index .
just --justfile ~/.dotfiles/ai/justfile search "query"
```

Results are chunks, not whole files: always open the reported file before
relying on a chunk. Re-index after large refactors — the index does not
auto-update.
