# Dotfiles

Personal dotfiles with a simple, reproducible push/pull workflow.

This is a git repo.

Think of your configuration files (e.g. `~/.vimrc`) as a remote origin.

When starting off, `make pull`, fix conflicts, and `make push` to synchronize existing dotfiles with those in this repo.

The `pull` operation is done with `git merge-file`, so it will work exactly as how your Git merges go.

## Prerequisites

- A Unix-like system
- `make`, `bash`, `zsh`, and `git` installed and available in your `$PATH`

## How to use

| Command                     | What it does                                                                                                                                            |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `make`                      | List all commands                                                                                                                                       |
| `make install`              | Install the `_copy_dotfile` script                                                                                                                      |
| `make install_dependencies` | Install some dependencies and programs I like                                                                                                           |
| `make pull`                 | Pull all dotfiles from their target locations, and merge it into the dotfiles in this repo                                                              |
| `make push`                 | Push all dotfiles from this repo into target locations. Backups in `<DOTFILE_PATH>.bak`. If a backup exists, this command will fail for the given file. |
| `make backup`               | Create backups in this repo. Backups in `<DOTFILE_PATH>.bak`. If a backup exists, this command will fail for the given file.                            |
| `make restore_backup`       | Restore dotfiles from their backups in this repo.                                                                                                       |
| `make remove_backups`       | Remove backups in this repo.                                                                                                                            |

If want to install a specific dotfile at `./dotfile/FILE`:

| Command                         | What it does                                                           |
| ------------------------------- | ---------------------------------------------------------------------- |
| `./dotfile/FILE pull`           | Pull this dotfile's target into `./dotfile/FILE`, and try to merge it. |
| `./dotfile/FILE push`           | Push `./dotfile/FILE` into its target location, make a backup          |
| `./dotfile/FILE backup`         | Create a backup for this dotfile. Backup is in `./dotfile/FILE.bak`    |
| `./dotfile/FILE restore_backup` | Restore this dotfile's target from its backup in `./dotfile/FILE.bak`  |

## How this repo works

### Some context about Shebangs

If you have a file like
`./some_file`

```bash
#!SOMETHING_HERE
```

And you do:
```bash
# If you run this
./some_file

# It is equivalent to doing
SOMETHING_HERE ./some_file
```

### Dotfiles

I make every dotfile executable by prepending a shebang to it, something like:

```vim
#!/usr/bin/env -S _copy_dotfile
# target: ${HOME}/.vimrc

" Remap esc key
lnoremap kj <C-[>
inoremap jk <C-[>

" More things below
```

The script `_copy_dotfile` parses the target from the starting "frontmatter" (leading line of `#`)

And we define the following

```bash
_copy_dotfile FILE pull # pulls file from the target into this file
_copy_dotfile FILE push # push this file to target and make a backup
_copy_dotfile FILE backup # make a backup from target file
_copy_dotfile FILE restore # restore target file from backup
```

### Shebang Syntax

The basic syntax for the executable dotfile looks like this.

The `# target: <PATH>` line specifies where the dotfile target is.
You are only allowed to specify one target, or the parser will throw an error.

[`./dotfile/vim/.vimrc`](./dotfiles/vim/.vimrc)
```bash
#!/usr/bin/env -S _copy_dotfile
# target: ${HOME}/.vimrc

CONTENTS HERE
```

For OS-specific targets, you can do something like this:

[`dotfiles/vscode-forks/cursor-settings.json`](./dotfiles/vscode-forks/cursor-settings.json)
```bash
#!/usr/bin/env -S _copy_dotfile
# target[Linux]: ${HOME}/.config/Cursor/User/settings.json
# target[Darwin]: ${HOME}/Library/Application\ Support/Cursor/User/settings.json

{
```

The OS is checked with the value of `uname -s`.

```bash
➜  dotfiles git:(main) uname -s                                                     
Linux

# So your target should be
# target[Linux]: PATH
```

## Why this design?

### Colocation and Shebangs

One of my biggest frustration with dotfile managers is that you typically have some arrangement like this:

- `./dotfiles/vim/.vimrc` - your vimrc file
- `./scripts/bootstrap.sh` - some kind of script to `cp` or `ln -s` the files in this repo to their target destination.

But where do you keep the information that maps `./dotfiles/vim/.vimrc` --> `$HOME/.vimrc`?

Typically, the common approach is to keep some kind of central store of this information, a mapping that maps every file in your repo to its destination.
You might also come up with some abstractions, such as every file in `./dotfiles/zshrc/*` is appended to the end of your `.zshrc`.

I _hate_ this. The result of this design is that to add _one_ configuration file, you go and edit _two_ things. Why can't it be one?

In my setup, every dotfile is an executable that installs itself into its intended target location.

### Why `cp`, not `ln -s`?

Well, first of all, my shebang approach is not compatible with symlinks, because I need to trim the starting shebang

When I first created my dotfile manager, I was sold the idea that having
this setup where `$HOME/.vimrc` symlinks to `$REPO/dotfiles/vim/vimrc`
is the holy grail of dotfile management.

When you go to edit the dotfiles, the changes get magically synced to your repo. `git commit -a`, `git push` and you can sync your changes everywhere!

I think this is not quite the best practice.

First of all, are you just going to run `git commit -am` on a cronjob? You still need to manually commit. This manual step never goes away.

I've also found that, for me, while different machines share a _base_ dotfile configuration,
I also have other machine-specific configurations.

For instance, my work-issued laptop often has `.zshrc` configurations that I don't want to commit to this repo.
`cp` is a good alternative that _decouples_ the source and destination dotfiles, that make managing them easier, and more intentional.

### Easy Imports

This kind of push-pull workflow also makes it easier to _import_ existing dotfiles into the repo.

Let's say I just installed `zsh`, set it up, and want to create a new dotfile entry.

Just create a new file `./dotfiles/zsh/.zshrc`:

```bash
#!/usr/bin/env -S _copy_dotfile
# target: ${HOME}/.vimrc

```

Run `make pull`, and pull your changes into this repo. Your dotfile is now version-tracked.

## Personal Notes

### Zsh

- `zsh` must be installed before running anything.

### Vivaldi

- I [mod](https://forum.vivaldi.net/topic/10549/modding-vivaldi) my Vivaldi with CSS files. Ensure the "Custom UI Modifications" is `<YOUR_HOME_DIRECTORY>/.vivaldi/css`
