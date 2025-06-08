# Dotfiles

This repository contains my personal dotfiles and system configurations.

## Structure

- `shell/` - Shell configurations (zsh, bash)
- `editor/` - Text editor configurations (vim, emacs, vscode, doom emacs)
- `git/` - Git configuration
- `terminal/` - Terminal emulator configurations (tmux, alacritty, kitty)
- `wm/` - Window manager / DE configurations
- `ssh/` - SSH configuration (without keys)
- `config/` - Configuration files from ~/.config/
- `package-lists/` - Lists of installed packages
- `os-specific/` - OS-specific configurations
  - `fedora/` - Fedora-specific configs
  - `macos/` - macOS-specific configs

## Installation

To install these dotfiles on a new system:

```bash
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
./install.sh
```

The install script will create symbolic links from this repository to your home directory. If you already have configuration files, they will be backed up with a `.backup` extension.

## OS-Specific Setup

The installer will detect your OS and offer to install packages and apply system-specific configurations.

### Fedora

- Installs packages from `package-lists/dnf-user-installed.txt`
- Installs Flatpak applications from `package-lists/flatpak-packages.txt`
- Applies GNOME settings from dconf

### macOS

- Installs Homebrew if not already installed
- Installs applications from `os-specific/macos/Brewfile`

## Customization

Feel free to modify any of these files to suit your preferences. After making changes, you may need to:

1. Source the updated configuration: `source ~/.zshrc` (for example)
2. Or log out and log back in for some changes to take effect

## Syncing Changes

When you make changes to your configurations, remember to update this repository:

1. Run the backup script again
2. Review the changes with `git diff`
3. Commit and push your changes
