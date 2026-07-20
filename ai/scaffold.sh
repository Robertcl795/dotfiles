#!/usr/bin/env bash
set -euo pipefail

# Scaffold the AI development standard into a target repository.
#
# Copies (versioned with the target project, visible to the whole team):
#   .github/instructions/   <- canonical instruction sets (Copilot picks
#                              these up via their applyTo frontmatter)
#   .claude/agents/         <- specialized subagents
#   .claude/commands/       <- reusable prompts (slash commands)
#   .mcp.json               <- context-db MCP server (project scope)
#
# Usage:
#   ai/scaffold.sh <target-repo> [--force]
#
# Existing files are skipped unless --force is given (then they are
# overwritten; a .bak copy is left next to each replaced file).

SOURCE_PATH="${BASH_SOURCE[0]:-${0:-}}"
AI_DIR="$(cd -- "$(dirname "$SOURCE_PATH")" && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}[scaffold]${NC} $*" >&2; }
warn() { echo -e "${YELLOW}[scaffold]${NC} $*" >&2; }
err()  { echo -e "${RED}[scaffold]${NC} $*" >&2; }

TARGET="${1:-}"
FORCE=0
[ "${2:-}" = "--force" ] && FORCE=1

if [ -z "$TARGET" ] || [ ! -d "$TARGET" ]; then
  err "Usage: ai/scaffold.sh <target-repo> [--force]"
  exit 1
fi
TARGET="$(cd -- "$TARGET" && pwd)"

copy_file() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ "$FORCE" != "1" ]; then
    warn "exists, skipping: ${dest#"$TARGET"/} (use --force to overwrite)"
    return 0
  fi
  if [ -e "$dest" ]; then
    cp "$dest" "$dest.bak"
  fi
  cp "$src" "$dest"
  info "installed: ${dest#"$TARGET"/}"
}

for f in "$AI_DIR"/instructions/*.instructions.md; do
  copy_file "$f" "$TARGET/.github/instructions/$(basename "$f")"
done

for f in "$AI_DIR"/agents/*.md; do
  copy_file "$f" "$TARGET/.claude/agents/$(basename "$f")"
done

for f in "$AI_DIR"/prompts/*.md; do
  copy_file "$f" "$TARGET/.claude/commands/$(basename "$f")"
done

# Project-scope MCP config pointing at the shared context server
MCP_JSON="$TARGET/.mcp.json"
if [ -e "$MCP_JSON" ] && [ "$FORCE" != "1" ]; then
  warn "exists, skipping: .mcp.json — add the context-db server manually if missing:"
  warn "  uv run --directory $AI_DIR/context server.py"
else
  [ -e "$MCP_JSON" ] && cp "$MCP_JSON" "$MCP_JSON.bak"
  cat > "$MCP_JSON" << EOF
{
  "mcpServers": {
    "context-db": {
      "command": "uv",
      "args": ["run", "--directory", "$AI_DIR/context", "server.py"]
    }
  }
}
EOF
  info "installed: .mcp.json"
fi

info "Done. Commit the new files in $TARGET to share them with the team."
info "Index the repo for semantic search: uv run --directory $AI_DIR/context indexer.py index --repo $TARGET"
