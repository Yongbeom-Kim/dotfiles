#!/usr/bin/env zsh

set -euo pipefail

echo "Installing dependencies"...

find install-scripts -type f -print0 | while IFS= read -r -d '' f; do
    chmod +x "$f"
    echo "Running $f"
    "./$f"
done