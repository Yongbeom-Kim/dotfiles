SHELL := /usr/bin/env bash

.PHONY: install pull push clean test

install:
	sudo ./scripts/install_copy_dotfile.sh

install_dependencies:
	./scripts/install_dependencies.sh

bootstrap:
	./scripts/run_dotfiles.sh bootstrap

undo_bootstrap:
	./scripts/run_dotfiles.sh undo

merge:
	./scripts/run_dotfiles.sh merge

remove_backups:
	find dotfiles -name '*.bak' -exec rm {} \;