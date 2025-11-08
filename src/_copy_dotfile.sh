#!/usr/bin/env bash
set -euo pipefail

USAGE="Usage: use as '#!/usr/bin/env -S _copy_dotfile DST_PATH' as the shebang in a script.
Running the script will copy the contents of the script to DST_PATH."

BOLD="\033[1m"
RESET="\033[0m"
UNDERLINE="\033[4m"
GRAY="\033[90m"
RED="\033[91m"

echo_stderr() {
	echo "$@" >&2
}

_get_backup_path() {
	src_path="$1"
	echo "$src_path.bak"
}

_get_temp_path() {
	src_path="$1"
	echo "$src_path.tmp"
}

# String manipulation (file parsing)

_get_frontmatter() {
	content="$1"
	frontmatter=""
	while IFS= read -r line; do
		if [[ ! "$line" == "#"* ]]; then
			break
		fi
		frontmatter+="$line"$'\n'
	done <<< "$content"
	echo "$frontmatter"
}

_trim_frontmatter() {
	content="$1"
	frontmatter="$(_get_frontmatter "$content")"
	content="${content#"$frontmatter"}"
	echo "$content"
}

_add_frontmatter() {
	frontmatter="$1"
	content="$2"

	while [[ "$frontmatter" == *$'\n' ]]; do
		frontmatter=${frontmatter%$'\n'}
	done

	while [[ "$content" == $'\n'* ]]; do
		content=${content#$'\n'}
	done
	echo "${frontmatter%%}"$'\n\n'"$content"
}

_get_target() {
	content=$1
	frontmatter="$(_get_frontmatter "$content")"

	os_name="$(uname -s)"
	targets=()
	while IFS= read -r line; do
		if [[ "$line" == "# target:"* ]]; then
			target_raw="${line#*# target: }"
			targets+=("$(eval echo "$target_raw")")
		fi

		if [[ "$line" == "# target[$os_name]:"* ]]; then
			target_raw="${line#*# target*: }"
			targets+=("$(eval echo "$target_raw")")
		fi
	done <<< "$frontmatter"
	
	if [[ "${#targets[@]}" -eq 0 ]]; then
		echo_stderr -e "${RED}No target found in file.${RESET}"
		return 1
	fi
	if [[ "${#targets[@]}" -gt 1 ]]; then
		echo_stderr -e "${RED}Multiple targets found in file. Only one should be specified. Targets: ${targets[@]}.${RESET}"
		return 1
	fi
	echo "${targets[0]}"
}

# File Manipulation

GIT_CONFLICT_START_MARKER="<<<<<<< "
GIT_CONFLICT_END_MARKER=">>>>>>> "

_file_assert_no_merge_conflicts() {
	file_to_check="$1"
	if ! sed -n "/^${GIT_CONFLICT_START_MARKER}/q1" "$file_to_check"; then
		echo -e "${RED}Merge conflict marker detected in $file_to_check. Please resolve conflicts before proceeding.${RESET}"
		sed -n "/^${GIT_CONFLICT_START_MARKER}/,/^${GIT_CONFLICT_END_MARKER}/p" "$file_to_check"
		return 1
	fi
}

_try_backup_file_with_frontmatter_if_exists() {
	backup_path="$1"
	existing_path="$2"
	frontmatter="$3"

	if [[ ! -f "$existing_path" ]]; then
		echo -e "${GRAY}File '$existing_path' does not exist, unable to backup.${RESET}"
		return 0 # This is not an error
	fi
	if [[ -f "$backup_path" ]]; then
		echo -e "${GRAY}Backup location $backup_path exists. Merge it into $existing_path first, and try again.${RESET}"
		return 1
	fi

	backup_content="$(cat "$existing_path")"
	backup_content="$(_add_frontmatter "$frontmatter" "$backup_content")"
	echo "$backup_content" > "$backup_path"
}

_try_push_dotfile() {
	src_path="$1"
	dst_path="$2"
	src_content="$(cat "$src_path")"
	backup_path="$(_get_backup_path "$dst_path")"

	content="$(_trim_frontmatter "$src_content")"
	echo "$content" > "$dst_path"
}

_restore_backup_dotfile() {
	backup_path="$1"
	dst_path="$2"

	backup_content="$(cat "$backup_path")"
	backup_content="$(_trim_frontmatter "$backup_content")"
	echo "$backup_content" > "$dst_path"
}

_merge_files() {
	base_path="$1"
	other_file_path="$2"
	if [[ ! -f "$base_path" ]]; then
		echo -e "${RED}Source file $base_path does not exist.${RESET}"
		return 1
	fi

	if [[ ! -f "$other_file_path" ]]; then
		echo -e "${RED}Other file $other_file_path does not exist.${RESET}"
		return 1
	fi

	if ! command -v git >/dev/null 2>&1; then
		echo -e "${RED}Git is not installed. Please install git first.${RESET}"
		return 1
	fi

	git merge-file "$base_path" "$base_path" "$other_file_path"
}

# Command interface

push_file_to_target() {
	src_path=$1

	if ! _file_assert_no_merge_conflicts "$src_path"; then
		echo -e "${RED}Error: Merge conflict marker detected in $src_path. Aborting push.${RESET}"
		exit 1
	fi
		
	src_path_content="$(cat "$src_path")"
	backup_path="$(_get_backup_path "$src_path")"
	frontmatter="$(_get_frontmatter "$src_path_content")"
	dst_path="$(_get_target "$src_path_content")"
		
	if [[ "$src_path" == "$dst_path" ]]; then
		echo -e "${GRAY}Source and destination are the same, skip link.${RESET}"
		return 0
	fi

	if cmp -s "$src_path" "$dst_path"; then
		echo -e "${GRAY}Source and destination are the same, skip link.${RESET}"
		return 0
	fi

	if ! _try_backup_file_with_frontmatter_if_exists "$backup_path" "$dst_path" "$frontmatter"; then
		echo -e "${RED}Failed to backup $dst_path.${RESET}"
		exit 1
	fi

	if ! _try_push_dotfile "$src_path" "$dst_path"; then
		echo -e "${RED}Failed to push into $dst_path.${RESET}"
		exit 1
	fi
}

restore_backup_file() {
	src_path=$1
	src_path_content="$(cat "$src_path")"
	backup_path="$(_get_backup_path "$src_path")"
	frontmatter="$(_get_frontmatter "$src_path_content")"
	dst_path="$(_get_target "$src_path_content")"

	echo -e "${BOLD}Restoring $backup_path to $dst_path.${RESET}"

	if ! _file_assert_no_merge_conflicts "$backup_path"; then
		echo -e "${RED}Error: Merge conflict marker detected in $backup_path. Aborting restore.${RESET}"
		exit 1
	fi

	if [[ ! -f "$backup_path" ]]; then
		echo -e "${GRAY}Backup location $backup_path does not exist, skip restore.${RESET}"
		return 0
	fi

	_restore_backup_dotfile "$backup_path" "$dst_path"
		
	echo -e "${GRAY}Backup location $backup_path restored to $dst_path.${RESET}"
	echo -e "${GRAY}Backup file $backup_path removed.${RESET}"
	rm "$backup_path"
}

backup_file() {
	src_path=$1
	src_path_content="$(cat "$src_path")"
	backup_path="$(_get_backup_path "$src_path")"
	frontmatter="$(_get_frontmatter "$src_path_content")"
	dst_path="$(_get_target "$src_path_content")"
	if ! _try_backup_file_with_frontmatter_if_exists "$backup_path" "$dst_path" "$frontmatter"; then
		echo -e "${RED}Failed to backup $dst_path.${RESET}"
		exit 1
	fi

	echo -e "${GRAY}Backup of $dst_path created at $backup_path.${RESET}"
}

pull_file_from_target() {
	src_path=$1
	src_path_content="$(cat "$src_path")"
	dst_path="$(_get_target "$src_path_content")"
	temp_path="$(_get_temp_path "$src_path")"
	frontmatter="$(_get_frontmatter "$src_path_content")"

	if [[ -f "$temp_path" ]]; then
		echo -e "${GRAY}Temporary file $temp_path exists, removing $temp_path.${RESET}"
	fi

	if ! _try_backup_file_with_frontmatter_if_exists "$temp_path" "$dst_path" "$frontmatter"; then
		echo -e "${RED}Failed to backup $dst_path.${RESET}"
		exit 1
	fi

	if ! _merge_files "$src_path" "$temp_path"; then
		echo -e "${RED}Failed to merge $temp_path into $src_path.${RESET}"
		exit 1
	fi

	echo -e "${GRAY}file $temp_path merged into $src_path. Temporary file $temp_path removed.${RESET}"
	rm "$temp_path"

	_file_assert_no_merge_conflicts $temp_path || true
}


main() {
	src_path="$(eval echo \"${1:-}\")"
	MODE="${2:-}"

	case "${MODE:-}" in
		"pull")
			pull_file_from_target "$src_path"
			;;
		"restore")
			restore_backup_file "$src_path"
			;;
		"backup")
			backup_file "$src_path"
			;;
		"push")
			push_file_to_target "$src_path"
			;;
		*)
			echo -e "${RED}Error:${RESET} Invalid or missing mode argument.\nUsage: <source_file> {push|backup|restore|merge}${RESET}"
			exit 1
	esac
}

if [[ ! "${__SOURCE_ONLY:-}" == "1" ]]; then
    main "$@"
fi