# #!/usr/bin/env bash

# GIT_ROOT_DIR="$(git rev-parse --show-toplevel)"
# __SOURCE_ONLY=1 . ${GIT_ROOT_DIR}/src/_copy_dotfile.sh

# BOLD="\033[1m"
# RESET="\033[0m"
# RED="\033[31m"
# GREEN="\033[32m"
# INVERT="\033[7m"

# # Generic test runner: prepares two temp files, runs _add_frontmatter (in-place),
# # then reads the first file back and compares to expected
# run_test() {
#     test_name=$1
#     content_input=$2
#     frontmatter_source=$3
#     expected_output=$4
#     echo -e "${BOLD}Running test: $test_name${RESET}"

#     CONTENT_FILE=$(mktemp /tmp/test_add_frontmatter.content.XXXXXXXXX)
#     FM_FILE=$(mktemp /tmp/test_add_frontmatter.fm.XXXXXXXXX)

#     echo "$content_input" > "$CONTENT_FILE"
#     echo "$frontmatter_source" > "$FM_FILE"

#     _add_frontmatter "$CONTENT_FILE" "$FM_FILE"
#     actual_output="$(cat "$CONTENT_FILE")"

#     if [[ "$actual_output" != "$expected_output" ]]; then
#         echo -e "${RED}Test failed: expected ->\n$expected_output\n<- but got ->\n$actual_output\n<-${RESET}"
#         exit 1
#     fi
#     echo -e "${GREEN}Test passed: $test_name${RESET}"

#     rm -f "$CONTENT_FILE" "$FM_FILE"
# }

# # Basic: extract only leading # lines from FM source and prepend to content, preserving later comments in content
# # Also ensure that lines in FM source after the first non-# line are NOT included
# test_add_frontmatter_basic() {
#     content_input=$(cat <<'EOF'
# Original line 1
# Original line 2
# # trailing comment should remain in content
# EOF
# )
#     fm_source=$(cat <<'EOF'
# #!/usr/bin/env -S _copy_dotfile arg1 arg2
# # target: /path/one
# # target[Darwin]: /path/darwin
# First non-frontmatter content in source file
# # This comment appears after non-frontmatter in source and should NOT be part of frontmatter
# EOF
# )
#     expected_output=$(cat <<'EOF'
# #!/usr/bin/env -S _copy_dotfile arg1 arg2
# # target: /path/one
# # target[Darwin]: /path/darwin

# Original line 1
# Original line 2
# # trailing comment should remain in content
# EOF
# )
#     run_test "test_add_frontmatter_basic" "$content_input" "$fm_source" "$expected_output"
# }

# # When FM source contains only frontmatter (all # lines), prepend them to content with a blank line separator
# test_add_frontmatter_only_frontmatter_source() {
#     content_input=$(cat <<'EOF'
# line A
# line B
# EOF
# )
#     fm_source=$(cat <<'EOF'
# # fm1
# # fm2
# # fm3
# EOF
# )
#     expected_output=$(cat <<'EOF'
# # fm1
# # fm2
# # fm3

# line A
# line B
# EOF
# )
#     run_test "test_add_frontmatter_only_frontmatter_source" "$content_input" "$fm_source" "$expected_output"
# }

# # When FM source has no leading # lines, content should remain unchanged
# test_add_frontmatter_no_frontmatter_in_source() {
#     content_input=$(cat <<'EOF'
# alpha
# beta
# EOF
# )
#     fm_source=$(cat <<'EOF'
# alpha (not frontmatter)
# # fm-like but after content, should not be included
# EOF
# )
#     expected_output=$(cat <<'EOF'
# alpha
# beta
# EOF
# )
#     run_test "test_add_frontmatter_no_frontmatter_in_source" "$content_input" "$fm_source" "$expected_output"
# }

# # Frontmatter in source followed immediately by a blank line should not include the blank; we still add our single separator blank line
# # (ensures consistent separation)
# test_add_frontmatter_blank_line_after_frontmatter_in_source() {
#     content_input=$(cat <<'EOF'
# AAA
# BBB
# EOF
# )
#     fm_source=$(cat <<'EOF'
# # fmm A
# # fmm B

# source content begins here
# EOF
# )
#     expected_output=$(cat <<'EOF'
# # fmm A
# # fmm B

# AAA
# BBB
# EOF
# )
#     run_test "test_add_frontmatter_blank_line_after_frontmatter_in_source" "$content_input" "$fm_source" "$expected_output"
# }

# # Run tests
# echo -e "${INVERT}Running add frontmatter tests...${RESET}"
# test_add_frontmatter_basic
# unset test_add_frontmatter_basic

# test_add_frontmatter_only_frontmatter_source
# unset test_add_frontmatter_only_frontmatter_source

# test_add_frontmatter_no_frontmatter_in_source
# unset test_add_frontmatter_no_frontmatter_in_source

# test_add_frontmatter_blank_line_after_frontmatter_in_source
# unset test_add_frontmatter_blank_line_after_frontmatter_in_source

# unset run_test