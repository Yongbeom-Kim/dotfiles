#!/usr/bin/env bash
set -euo pipefail

USAGE="Usage: use as '#!/usr/bin/env -S _copy_dotfile DST_PATH' as the shebang in a script.
Running the script will copy the contents of the script to DST_PATH."

dst_path="$(eval echo \"${1:-}\")"
src_path="$(eval echo \"${2:-}\")"

BOLD="\033[1m"
RESET="\033[0m"
UNDERLINE="\033[4m"
GRAY="\033[90m"

if [[ -z "$dst_path" ]]; then
    echo "dst_path is empty."
    echo "$USAGE"
    exit 1
fi

if [[ -z "$src_path" ]]; then
    echo "src_path is empty."
    echo "$USAGE"
    exit 1
fi

if [[ ! -f "$src_path" ]]; then
    echo "src_path '$src_path' is not a file, skip."
    exit 0
fi

if [[ "$src_path" == "$dst_path" ]]; then
    echo "src_path and dst_path are the same, skip."
    exit 0
fi

push() {
    echo -e "${BOLD}Pushing ${UNDERLINE}$src_path${RESET}${BOLD} to ${UNDERLINE}$dst_path${RESET}"
    mkdir -p "$(dirname "$dst_path")"
    if [[ -f "$dst_path" ]]; then
        echo -e "${GRAY}Destination '$dst_path' exists.${RESET}"
        if cmp -s <(tail -n +2 "$src_path") "$dst_path"; then
            echo -e "${GRAY}Contents of src_path and dst_path are identical, skip backup.${RESET}"
        else
            echo -e "${GRAY}Contents of src_path and dst_path are different, backup dst_path to '$dst_path.bak'.${RESET}"
            cp "$dst_path" "$dst_path.bak"
        fi
    fi
    tail -n +2 "$src_path" >"$dst_path"
}

pull() {
    new_src_path="$src_path.new"
    echo -e "${BOLD}Pulling ${UNDERLINE}$dst_path${RESET}${BOLD} to ${UNDERLINE}$new_src_path${RESET}"
    if [[ ! -f "$dst_path" ]]; then
        echo -e "${GRAY}Destination '$dst_path' does not exist.${RESET}"
        return 0
    fi
    touch "$new_src_path"
    head -n 1 "$src_path" | cat - "$dst_path" >"$new_src_path"
    echo -e "${GRAY}Successfully pulled $dst_path to $new_src_path.${RESET}"
}

if [[ "$MODE" == "push" ]]; then
    push
elif [[ "$MODE" == "pull" ]]; then
    pull
else
    echo "MODE '$MODE' is not supported, only 'push' and 'pull' are supported."
    exit 1
fi