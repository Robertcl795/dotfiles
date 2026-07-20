---
description: (Re)index the current repo into the vector context DB
---

Index this repository into the local vector context DB so semantic search is
available: $ARGUMENTS

If the `context-db` MCP server is connected, call its `context_index` tool
with the repo root (collection = repo directory name unless I specified one).
Otherwise run it directly:

```bash
uv run --directory ~/.dotfiles/ai/context indexer.py index --repo .
```

When indexing finishes, report the collection name and chunk count, then run
a sanity search for a term you saw in the repo README and show the top hit.
