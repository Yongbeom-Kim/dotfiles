#!/usr/bin/env bash

GIT_ROOT_DIR="$(git rev-parse --show-toplevel)"
__SOURCE_ONLY=1 . ${GIT_ROOT_DIR}/src/_copy_dotfile.sh

TEMP_FILE=$(mktemp /tmp/test_get_target.XXXXXXXXX)

BOLD="\033[1m"
RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
INVERT="\033[7m"

echo -e "${INVERT}Running get target tests...${RESET}"

test() {
    test_name=$1
    input=$2
    expected_output=${3:-}
    echo -e "${BOLD}Running test: $test_name${RESET}"
    
    actual_output="$(_get_target "$input")" && return_code=$? || return_code=$?

    if [[ -z "$expected_output" ]]; then
        if [[ $return_code -eq 0 ]]; then
            echo -e "${RED}Test Failed: expected non-zero return code, but got 0${RESET}"
            return 1
        else 
            echo -e "${GREEN}Test passed: return code $return_code, nonzero as expected${RESET}"
        fi
    fi


    if [[ "$actual_output" != "$expected_output" ]]; then
        echo -e "${RED}Test failed: expected $expected_output, but got $actual_output${RESET}"
        return 1
    fi
    echo -e "${GREEN}Test passed: $test_name${RESET}"
}

test_one_target() {
    input=$(cat <<EOF
#!/some/thing/here arg1 arg2 arg3
# target: /intended/final/path
EOF
)
    expected_output="/intended/final/path"
    test "test_one_target" "$input" "$expected_output"
}
test_one_target
unset test_one_target


test_zero_targets() {
    input=$(cat <<EOF
#!/some/thing/here arg1 arg2 arg3
# some-other-comment
# not-target: /intended/final/path2
EOF
)
    test "test_zero_targets" "$input"
}
test_zero_targets
unset test_zero_targets



test_two_targets() {
    input=$(cat <<EOF
#!/some/thing/here arg1 arg2 arg3
# target: /intended/final/path1
# target: /intended/final/path2
EOF
)
    test "test_two_targets" "$input"
}
test_two_targets
unset test_two_targets


test_uname_targets() {
    input=$(cat <<EOF
#!/some/thing/here arg1 arg2 arg3
# target[Linux]: /intended/linux/path
# target[Darwin]: /intended/darwin/path
EOF
)
    uname() { echo Darwin; }
    expected_output="/intended/darwin/path"
    test "test_uname_targets[Darwin]" "$input" "$expected_output"
    unset -f uname

    uname() { echo Linux; }
    expected_output="/intended/linux/path"
    test "test_uname_targets[Linux]" "$input" "$expected_output"
    unset -f uname
}
test_uname_targets
unset test_uname_targets

test_ignore_target_after_non_comment_line() {
    input=$(cat <<EOF
#!/some/thing/here arg1 arg2 arg3
# target: /intended/final/path1
some other line
# target: /intended/final/path3
EOF
)
    expected_output="/intended/final/path1"
    test "test_ignore_target_after_non_comment_line" "$input" "$expected_output"
}
test_ignore_target_after_non_comment_line
unset test_ignore_target_after_non_comment_line


test_handle_spaces_in_target_path() {
    input=$(cat <<EOF
#!/some/thing/here arg1 arg2 arg3
# target: /intended/final/path with spaces
EOF
)
    expected_output="/intended/final/path with spaces"
    test "test_handle_spaces_in_target_path" "$input" "$expected_output"
}
test_handle_spaces_in_target_path
unset test_handle_spaces_in_target_path

test_tmux_conf_file() {
    input=$(cat <<'EOF'
#!/usr/bin/env _copy_dotfile ${HOME}/.tmux.conf
# target: ${HOME}/.tmux.conf
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-sensible'

run '~/.tmux/plugins/tpm/tpm'
EOF
)
    expected_output="${HOME}/.tmux.conf"
    test "test_tmux_conf_file" "$input" "$expected_output"
}
test_tmux_conf_file
unset test_tmux_conf_file