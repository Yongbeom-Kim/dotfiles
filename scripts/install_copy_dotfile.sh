#!/usr/bin/env bash

set -euo pipefail

for dir in /usr/local/bin /usr/bin "$HOME/.local/bin" "$HOME/bin" /opt/local/bin /opt/bin; do
  if [ -d "$dir" ] && [ -w "$dir" ]; then
    target="$dir/_copy_dotfile"
    break
  fi
done

cp src/_copy_dotfile.sh "$target"
chmod +x "$target"
echo "Installed _copy_dotfile to $target. Ensure $(dirname "$target") is in your \$PATH."
