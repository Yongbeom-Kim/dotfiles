#!/usr/bin/env zsh

set -euo pipefail

find dotfiles -type f -not -name '*.new' -not -name '.DS_Store' -print0 | while IFS= read -r -d '' f; do
  chmod +x "$f"
  # echo "Running $f"
  "./$f"
done