#!/usr/bin/env zsh

set -euo pipefail

mode="${1:-}"

find dotfiles -type f -not -name '*.new' -not -name '*.bak' -not -name '.DS_Store' -print0 | while IFS= read -r -d '' f; do
  chmod +x "$f"
  echo "Running $f"
  "./$f" "$mode"
done