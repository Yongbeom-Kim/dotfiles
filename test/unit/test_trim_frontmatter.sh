# #!/usr/bin/env bash

# GIT_ROOT_DIR="$(git rev-parse --show-toplevel)"
# __SOURCE_ONLY=1 . ${GIT_ROOT_DIR}/src/_copy_dotfile.sh

# TEMP_FILE=$(mktemp /tmp/test_trim_frontmatter.XXXXXXXXX)

# BOLD="\033[1m"
# RESET="\033[0m"
# RED="\033[31m"
# GREEN="\033[32m"
# INVERT="\033[7m"

# # Generic test runner: writes input to a temp file, runs _trim_frontmatter (in-place),
# # then reads the file back and compares to expected
# test() {
#     test_name=$1
#     input=$2
#     expected_output=$3
#     echo -e "${BOLD}Running test: $test_name${RESET}"

#     echo "$input" > "$TEMP_FILE"
#     _trim_frontmatter "$TEMP_FILE"
#     actual_output="$(cat "$TEMP_FILE")"

#     if [[ "$actual_output" != "$expected_output" ]]; then
#         echo -e "${RED}Test failed: expected ->\n$expected_output\n<- but got ->\n$actual_output\n<-${RESET}"
#         exit 1
#     fi
#     echo -e "${GREEN}Test passed: $test_name${RESET}"
# }

# # Frontmatter (leading # lines) should be trimmed, later # lines preserved
# # Example: "#1" "<content>" "#2" => trim only "#1"
# test_trim_frontmatter_preserves_later_comments() {
#     input=$(cat <<'EOF'
# #!/usr/bin/env _copy_dotfile arg1 arg2
# # target: /path/one
# # target[Darwin]: /path/darwin
# First real content line
# Second content line
# # This is not frontmatter and should remain
# EOF
# )
#     expected_output=$(cat <<'EOF'
# First real content line
# Second content line
# # This is not frontmatter and should remain
# EOF
# )
#     test "test_trim_frontmatter_preserves_later_comments" "$input" "$expected_output"
# }

# # If the whole file is comments, trimming should yield empty content
# test_trim_frontmatter_only_comments() {
#     input=$(cat <<'EOF'
# # only comment line 1
# # only comment line 2
# # only comment line 3
# EOF
# )
#     expected_output=""
#     test "test_trim_frontmatter_only_comments" "$input" "$expected_output"
# }

# # If there is no leading comment, content should remain unchanged
# test_trim_frontmatter_no_frontmatter() {
#     input=$(cat <<'EOF'
# echo "Hello"
# # trailing comment should remain
# EOF
# )
#     expected_output=$(cat <<'EOF'
# echo "Hello"
# # trailing comment should remain
# EOF
# )
#     test "test_trim_frontmatter_no_frontmatter" "$input" "$expected_output"
# }

# # A blank line can separate frontmatter from content; the blank line should be preserved
# test_trim_frontmatter_blank_separator() {
#     input=$(cat <<'EOF'
# # frontmatter line A
# # frontmatter line B

# first content line after blank
# EOF
# )
#     expected_output=$(cat <<'EOF'

# first content line after blank
# EOF
# )
#     test "test_trim_frontmatter_blank_separator" "$input" "$expected_output"
# }

# # Run tests

# echo -e "${INVERT}Running trim frontmatter tests...${RESET}"

# test_trim_frontmatter_preserves_later_comments
# unset test_trim_frontmatter_preserves_later_comments

# test_trim_frontmatter_only_comments
# unset test_trim_frontmatter_only_comments

# test_trim_frontmatter_no_frontmatter
# unset test_trim_frontmatter_no_frontmatter

# test_trim_frontmatter_blank_separator
# unset test_trim_frontmatter_blank_separator

# unset test