#!/usr/bin/env bash

set -euo pipefail

mode="${1:-}"

find dotfiles -type f -not -name '*.new' -not -name '*.bak' -not -name '*.tmp' -not -name '.DS_Store' -print0 | while IFS= read -r -d '' f; do
  chmod +x "$f"
  echo "Running $f"
  "./$f" "$mode" || true # ignore errors and try to run every file
done