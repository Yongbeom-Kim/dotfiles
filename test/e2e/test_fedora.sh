#!/usr/bin/env -S docker run -it fedora:42
# HELPER_PATH="${GIT_ROOT_DIR}/test/e2e/helpers.sh"

# IMAGE="fedora:42"
# CONT=$(docker run -qdit ${IMAGE})

bash
# echo_test_start

# d_fs_install_dotfile_script

# tmux_file_frontmatter=$(cat <<EOF
# #!/usr/bin/env -S _copy_dotfile
# # target: \${HOME}/.tmux.conf
# EOF
# )
# tmux_file_content=$(cat <<EOF
# set -g @plugin 'tmux-plugins/tpm'
# set -g @plugin 'tmux-plugins/tmux-sensible'

# run '~/.tmux/plugins/tpm/tpm'
# EOF
# )
# tmux_file_path='${HOME}/some/path/here/.tmux.conf'

# d_fs_add_file "${tmux_file_path}" "${tmux_file_frontmatter}\n${tmux_file_content}"
# dexec "${tmux_file_path}"
# d_fs_assert_file "\${HOME}/.tmux.conf" "${tmux_file_content}"



# ddebug


# dkill