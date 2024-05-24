from pathlib import Path
import os
import sys
import shutil
from dataclasses import dataclass
from typing import List

# List of all terminal style characters.
TERM = {
    'reset': '\033[0m',
    'bold': '\033[1m',
    'italic': '\033[3m',
    'underline': '\033[4m',
    'reverse': '\033[7m',
    'strikethrough': '\033[9m',
    'invisible': '\033[8m',

    'black': '\033[30m',
    'red': '\033[31m',
    'green': '\033[32m',
    'yellow': '\033[33m',
    'blue': '\033[34m',
    'purple': '\033[35m',
    'cyan': '\033[36m',
    'white': '\033[37m',

    'black_bg': '\033[40m',
    'red_bg': '\033[41m',
    'green_bg': '\033[42m',
    'yellow_bg': '\033[43m',
    'blue_bg': '\033[44m',
    'purple_bg': '\033[45m',
    'cyan_bg': '\033[46m',
    'white_bg': '\033[47m',
}

# Directories
XDG_CONFIG_HOME = Path(os.environ.get('XDG_CONFIG_HOME', '~/.config')).expanduser().resolve()
USER_HOME = Path.home().resolve()

def assert_command_found(command: str) -> bool:
    """Return True if the given command is found in the PATH."""
    return shutil.which(command) is not None


def symlink_file_with_backup(src_path: Path, dst_path: Path, backup_path: Path):
    """Create a symlink, backing up and overwriting the target if it exists."""
    src_path = src_path.absolute()
    dst_path = dst_path.absolute()
    print(f"Creating symlink from {src_path} to {dst_path}")
    dst_path.parent.mkdir(parents=True, exist_ok=True)

    if dst_path.exists() and not dst_path.is_symlink():
        print(f"{TERM['yellow']}{dst_path} already exists.{TERM['reset']}")
        print(f"{TERM['yellow']}Backing up {dst_path} to {backup_path}{TERM['reset']}")
        backup_path.unlink(missing_ok=True)
        # print(f'Hardlinking {dst_path} --> {backup_path}')
        backup_path.hardlink_to(dst_path)
        
    print(f"{TERM['yellow']}Overwriting {dst_path} with symlink{TERM['reset']}")
    dst_path.unlink(missing_ok=True)
    # print(f'Softlinking {src_path} --> {dst_path}')
    dst_path.symlink_to(src_path)


@dataclass
class SetupConfig:
    application_name: str
    assert_commands: List[str]
    symlink_src: Path
    symlink_dst: List[Path]

    def setup(self):
        """Setup application configs."""
        print(f"Setting up configs for {self.application_name}...")
        for command in self.assert_commands:
            if not assert_command_found(command):
                print(f"{TERM['red']}Command {command} not found. Skipping setup.{TERM['reset']}")
                return
        for dst_path in self.symlink_dst:
            symlink_file_with_backup(self.symlink_src, dst_path, self.backup_path)
        print(f"{TERM['green']}Setup complete.{TERM['reset']}")
    
    def restore(self):
        """Restore application configs."""
        print(f"Restoring configs for {self.application_name}...")
        for dst_path in self.symlink_dst:
            if dst_path.exists():
                print(f"Removing symlink from {dst_path}")
                dst_path.unlink()
            if self.backup_path.exists():
                print(f"Restoring backup from {self.backup_path} to {dst_path}")
                dst_path.hardlink_to(self.backup_path)
                # self.backup_path.unlink()
        print(f"{TERM['green']}Restore complete.{TERM['reset']}")

    @property
    def backup_path(self) -> Path:
        """Return the backup path for the symlink destination."""
        return self.symlink_src.with_suffix(self.symlink_src.suffix + ".bak")
    

setup_configs = [
    SetupConfig("VS Code", ["code"], Path('./vscode/settings.json'), [XDG_CONFIG_HOME / "Code/User/settings.json"]),
    SetupConfig("Vim", ["vim"], Path("./vim/.vimrc"), [USER_HOME / ".vimrc"]),
    # Conda in zsh because I put conda in zshrc
    SetupConfig("Oh My Zsh", ["zsh"], Path("./oh-my-zsh/.zshrc"), [USER_HOME / ".zshrc"]),
    SetupConfig("Tmux", ["tmux"], Path("./tmux/.tmux.conf"), [XDG_CONFIG_HOME / ".tmux.conf"]),
    SetupConfig("Pipy", ["pip"], Path("./pipy/pip.conf"), [USER_HOME / ".pip/pip.conf"])
]

if __name__ == '__main__':
    if len(sys.argv) < 2 or len(sys.argv) > 2 or sys.argv[1] not in ['setup', 'restore']:
        print(f"{TERM['red']}{TERM['bold']}Usage: python3 setup.py [setup|restore]{TERM['reset']}")
        sys.exit(1)
    
    if sys.argv[1] == 'setup':
        print(f"{TERM['bold']}Setting up dotfiles...{TERM['reset']}")
        for setup_config in setup_configs:
            print()
            setup_config.setup()
        sys.exit(0)

    if sys.argv[1] == 'restore':
        print(f"{TERM['bold']}Restoring dotfiles...{TERM['reset']}")
        for setup_config in setup_configs:
            print()
            setup_config.restore()
        sys.exit(0)
    


