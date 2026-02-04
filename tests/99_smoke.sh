#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for t in \
  "$SCRIPT_DIR/00_preflight.sh" \
  "$SCRIPT_DIR/01_packages.sh" \
  "$SCRIPT_DIR/02_linking.sh" \
  "$SCRIPT_DIR/03_shell.sh" \
  "$SCRIPT_DIR/04_prompt.sh" \
  "$SCRIPT_DIR/05_nvim.sh" \
  "$SCRIPT_DIR/06_dev.sh"
do
  bash "$t"
done
