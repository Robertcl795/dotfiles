#!/usr/bin/env python3
"""MCP server exposing the local vector context DB to AI tools.

Register with Claude Code (user scope):
    claude mcp add --scope user context-db -- \
        uv run --directory ~/.dotfiles/ai/context server.py

Or per-project via .mcp.json (see ai/scaffold.sh).
"""

from __future__ import annotations

from fastmcp import FastMCP

import indexer

mcp = FastMCP(
    "context-db",
    instructions=(
        "Local semantic search over indexed repositories (one collection per "
        "repo). Use context_search for prior art, conventions, ADRs and "
        "related code when literal grep would miss them. Chunks are excerpts: "
        "open the reported file before relying on one. Use context_index "
        "after large refactors to refresh a repo's collection."
    ),
)


@mcp.tool
def context_search(query: str, collection: str = "", k: int = 8) -> list[dict]:
    """Semantic search over indexed repos.

    Args:
        query: Natural-language or code-flavored search query.
        collection: Restrict to one repo's collection (default: all).
        k: Maximum number of chunks to return.

    Returns chunks with collection, path, start_line, score and snippet.
    """
    return indexer.search(query, collection, k)


@mcp.tool
def context_index(path: str, collection: str = "") -> str:
    """(Re)index a repository into the context DB.

    Args:
        path: Repository root to index.
        collection: Collection name (default: directory basename).
    """
    return indexer.index_repo(path, collection)


@mcp.tool
def context_collections() -> list[str]:
    """List the collections (repos) currently indexed."""
    return indexer.list_collections()


if __name__ == "__main__":
    mcp.run()
