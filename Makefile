SHELL := /usr/bin/env bash

.PHONY: install pull push

all: install_script install_dependencies push

install_script:
	sudo ./scripts/install_copy_dotfile.sh

install_dependencies:
	./scripts/install_dependencies.sh

pull:
	env MODE=pull ./scripts/run_dotfiles.sh

push:
	env MODE=push ./scripts/run_dotfiles.sh

clean:
	find dotfiles -name '*.new' -exec rm {} \;
