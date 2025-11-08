SHELL := /usr/bin/env bash

.PHONY: help install install_dependencies bootstrap undo_bootstrap merge backup remove_backups pull push clean test

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

install: ##  Install _copy_dotfile script
	sudo ./scripts/install_copy_dotfile.sh

install_dependencies: ## Install dependencies I like
	./scripts/install_dependencies.sh

push: ## Push dotfiles into their target locations
	./script/run_dotfiles.sh push

pull: ## Pull dotfiles from target locations into this repo, try to merge them
	./scripts/run_dotfiles.sh pull

backup: ## Do a simple backup of existing target dotfiles
	./scripts/run_dotfiles.sh backup

restore_backup: ## Restore backups of all dotfiles
	./scripts/run_dotfiles.sh undo

remove_backups: ## Remove backups of dotfiles in this repo
	find dotfiles -name '*.bak' -exec rm {} \;