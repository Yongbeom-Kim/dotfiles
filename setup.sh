#!/bin/bash

# Abort if command not found
assert_command_found() {
  if ! command -v $1 &> /dev/null
  then
    echo "$1 command is not found, aborting"
    exit 1
  fi
}

# Force symlink (delete file if exists)
force_symlink() {
  if [ -L $2 ] || [ -f $2 ] ; then
    echo "Removing $2..."
    rm $2
  fi

  echo "Symlinking $1 to $2..."
  ln -s $1 $2
}


# Set up VS Code
echo "Setting up VS Code:"
assert_command_found "code"
force_symlink "$PWD/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

# Set up vim
echo "Setting up Vim:"
assert_command_found "vim"
force_symlink "$PWD/vim/.vimrc" "$HOME/.vimrc"

# Set up oh-my-zsh
echo "Setting up oh-my-zsh..."
assert_command_found "zsh"
assert_command_found "conda" # I put conda in my .zshrc
force_symlink "$PWD/oh-my-zsh/.zshrc" "$HOME/.zshrc"
