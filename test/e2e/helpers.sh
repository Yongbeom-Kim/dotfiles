#!/bin/bash

__TMUX_FILE_FRONTMATTER=$(cat <<EOF
#!/usr/bin/env _copy_dotfile
# target: \${HOME}/.tmux.conf
EOF
)

__TMUX_FILE_CONTENT=$(cat <<EOF
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

run '~/.tmux/plugins/tpm/tpm'
EOF
)

typeset -A TMUX=(
  [frontmatter]="${__TMUX_FILE_FRONTMATTER}"
  [content]="${__TMUX_FILE_CONTENT}"
  [path]="${HOME}/some/path/here/.tmux.conf"
  [expected_install_path]="${HOME}/.tmux.conf"
)


