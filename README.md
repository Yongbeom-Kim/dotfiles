# Dotfiles

Personal dotfiles with a simple, reproducible push/pull workflow.

## Prerequisites

- A Unix-like system
- `make`, `bash`, `zsh`, and `git` installed and available in your `$PATH`


## How to use

First, install `zsh`

| Task                        | Command                     | Description                                                                          |
|-----------------------------|-----------------------------|--------------------------------------------------------------------------------------|
| Install Everything          | `make install`              | Installs `/usr/local/bin/_copy_dotfile`, installs dependencies, then pushes dotfiles |
| Install Dependencies        | `make install_dependencies` | Installs some tools I use (Oh My Zsh + plugins)                                      |
| Install Dotfiles            | `make push`                 | Push dotfiles into their respective locations into the system                        |
| Get Current System Dotfiles | `make pull`                 | Creates `*.new` files next to the originals in `dotfiles/`                           |
| Clean temporary files       | `make clean`                | Removes all `*.new` files in `dotfiles/`                                            |


### Why `cp`, not `ln -s`?

I've found that while different machines of mine share a *base* dotfile configuration, I also have my machine-specific configurations. For instance, my work-issued laptop often has `.zshrc` configurations that I don't want to commit to this repo.

Copying files instead of symlinking them makes it easier to *import* existing dotfiles into the repo. For instance, if I have an existing, file to symlink, I'd have to move it into this repo and update the symlink to point to the new location.

Instead, I use `cp` to copy the dotfiles into their respective locations. When I want to update a dotfile, I simply `cp` it back into the repo under a gitignore-d `$DOTFILE.new` file, and then compare the diffs to see what changed.

## How it works: Shebang Abuse

This repo avoids having to keep track of dotfile locations by abusing shebangs (`#!`) to manage the location of each file.

For instance, here is the first few lines of my `.vimrc` file in this repo:

[`dotfiles/vim/.vimrc`](./dotfiles/vim/.vimrc)
```vim
#!/usr/bin/env -S _copy_dotfile ${HOME}/.vimrc

" Remap esc key
lnoremap kj <C-[>
inoremap jk <C-[>

" more config lines here
```

When I run this as a script:

```bash
./dotfiles/.vimrc
```

This is equivalent to running 

```bash
/usr/bin/env _copy_dotfile '$HOME/.vimrc' ./dotfiles/.vimrc
```

The first argument now serves as the target location, and the second argument as the source location, and the [script](./scripts/_copy_dotfile.sh) will back up the source file (`SOURCE_FILE.bak`) if it exists, then copy the source file to the target location.

To account for languages where `#` does not mark the start of a comment, the script strips the first line in any file copied.

### Pulling Dotfiles

To pull dotfiles from the system into this repo, we can create a new file like this:

`./dotfiles/.zshrc` (new)
```zsh
#!/usr/bin/env -S _copy_dotfile ${HOME}/.zshrc
```

Now, running `make pull` copies the current `$HOME/.zshrc` into `./dotfiles/.zshrc.new`. 

We can then compare the diffs to see what changed, and copy over specific changes from the new file over the old one.

With this, the dotfile locations and dotfile contents are now colocated in this repo, and we can easily keep track of changes to our dotfiles.

## Workflows

This allows us to have the following workflows:

### 1. Creating a new dotfile

This allows us to create a new dotfile by simply creating a new file in the `dotfiles/` directory, and adding the shebang line. It would work as follows:

1. Create a new file in the `dotfiles/` directory:

`dotfiles/.new_dotfile`
```zsh
#!/usr/bin/env -S _copy_dotfile ${HOME}/some/path/to.new_dotfile
```
2. Run `make pull` to copy the current configuration file `dotfiles/.new_dotfile.new`
3. Copy over specific changes from the new file over the old one
4. Commit and push the changes in this repo.

To *update* a dotfile, just do steps 2-4.

### 2. Setting up a new machine

To set up a new machine with these dotfiles, download the dependencies, clone this repo, and just run `make install`. This will:

1. Install `/usr/local/bin/_copy_dotfile`
2. Install additional dependencies (Oh My Zsh + plugins)
3. Push dotfiles into their respective locations (backups on `$HOME/<dotfile>.bak`).

### 3. Installing a specific dotfile only

Just run the dotfile as an executable.
```bash
./dotfiles/vim/.vimrc
```

## Notes about the dotfiles in this repo

### Zsh

- `zsh` must be installed before running anything.

### Vivaldi

- I [mod](https://forum.vivaldi.net/topic/10549/modding-vivaldi) my Vivaldiw with CSS files. Ensure the "Custom UI Modifications" is `<YOUR_HOME_DIRECTORY>/.vivaldi/css`
