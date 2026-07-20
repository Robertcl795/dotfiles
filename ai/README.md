# AI Development Standard

Senior-level standard for AI-assisted development. Everything here is the
**single source of truth**, versioned in dotfiles and *deployed* to tools —
never hand-duplicated.

## Principles

1. **Single source of truth** — instruction sets live once in
   `ai/instructions/` and are deployed to each consumer (GitHub Copilot,
   Claude Code agents/skills). Editing a deployed copy is a bug; edit here
   and redeploy.
2. **Tool-agnostic with adapters** — the same canonical content feeds
   Copilot (`.github/instructions/` with `applyTo` frontmatter), Claude Code
   subagents, slash commands and skills.
3. **Local-first** — the vector context DB runs locally (ChromaDB persistent
   store + fastembed ONNX embeddings). No API keys, works offline in WSL.
4. **Installable and testable** — deployed by the dotfiles bootstrap
   (`install/ai.sh`), verified by `tests/09_ai.sh`, carried into any repo
   with one scaffold command.

## Layout

```
ai/
├── instructions/   Canonical DO/DO-NOT rule sets (Copilot applyTo format)
├── agents/         Claude Code subagents        -> ~/.claude/agents/
├── prompts/        Slash commands               -> ~/.claude/commands/
├── skills/         Claude skills                -> ~/.claude/skills/
├── context/        Vector context DB (uv project: chromadb+fastembed+fastmcp)
├── scaffold.sh     Copy the standard into a target repo
└── justfile        just index / search / deploy / scaffold
```

## The four pillars

### 1. Vector Context DB (`context/`)

One Chroma collection per repo under `~/.local/share/ai-context/`
(`AI_CONTEXT_HOME` to override). Local embeddings via fastembed.

```bash
just --justfile ~/.dotfiles/ai/justfile index ~/code/my-repo
just --justfile ~/.dotfiles/ai/justfile search "how do we debounce service calls"
```

Exposed to Claude Code as the `context-db` MCP server
(`context_search` / `context_index` / `context_collections`), registered
user-scope by `install/ai.sh`, or per-project via the scaffolded `.mcp.json`.
Re-index after large refactors; the index does not auto-update.

### 2. Specialized agents (`agents/`)

| Agent | Role | Access |
|---|---|---|
| `angular-reviewer` | Reviews diffs/files against the canonical instruction sets, DO NOTs enforced | read-only |
| `security-auditor` | XSS, unsafe bindings, open redirects, upload handling | read-only |
| `test-writer` | Specs for utils/components: edge cases, property-based, runs until green | full |
| `planner` | Feature plans: component tree, state design, federation impact | read-only |

Reviewer agents are deliberately read-only: they report, the main session
applies fixes. That keeps review independent from implementation.

### 3. Reusable prompts (`prompts/`)

`/angular-review [scope]`, `/write-tests [files]`,
`/scaffold-feature <desc>`, `/index-repo`. Thin orchestration layers: they
set scope and delegate to the agents so behavior stays consistent.

### 4. Skills (`skills/`)

- `angular-standards` — progressive disclosure: triggers when editing
  `.component.ts`/`.html`/`.scss`/`.util.ts`, loads only the matching
  instruction file instead of stuffing every rule into context.
- `context-db` — teaches when/how to use semantic search vs plain grep.

## Deployment

**Globally (this machine):** ran automatically by the bootstrap, or:

```bash
bash install/ai.sh --run          # or: just --justfile ai/justfile deploy
```

**Into a repo (versioned, shared with the team):**

```bash
ai/scaffold.sh ~/code/my-repo     # or: just --justfile ai/justfile scaffold ~/code/my-repo
```

installs `.github/instructions/` (Copilot), `.claude/agents/`,
`.claude/commands/` and `.mcp.json` into the target. Commit those files in
the target repo.

## Maintenance rules

- New rule? Edit `ai/instructions/*.md` here, commit, redeploy/re-scaffold.
- New agent/prompt/skill? Add the file, re-run `install/ai.sh --run`
  (symlinks pick up edits automatically; new files need the re-run).
- Instruction files keep Copilot's `applyTo` frontmatter — do not strip it.
- `tests/09_ai.sh` must stay green: structure, py_compile, deployment links
  and an index/search round-trip.
