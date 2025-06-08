#!/bin/bash
# Install script for dotfiles
# Usage: ./install.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Installing dotfiles from $DOTFILES_DIR"

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if [ -f /etc/fedora-release ]; then
        DISTRO="fedora"
    else
        DISTRO="unknown"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    DISTRO="macos"
else
    OS="unknown"
    DISTRO="unknown"
fi

echo "Detected OS: $OS ($DISTRO)"

# Function to create symbolic links
link_file() {
    local src=$1
    local dst=$2
    
    if [ -f "$src" ] || [ -d "$src" ]; then
        # Create backup if the destination exists and is not a symlink
        if [ -e "$dst" ] && [ ! -L "$dst" ]; then
            echo "Backing up $dst to ${dst}.backup"
            mv "$dst" "${dst}.backup"
        fi
        
        # Create parent directories if they don't exist
        mkdir -p "$(dirname "$dst")"
        
        # Create the symlink
        echo "Linking $src to $dst"
        ln -sf "$src" "$dst"
    else
        echo "Warning: Source file $src does not exist"
    fi
}

# Shell configs
link_file "$DOTFILES_DIR/shell/zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/shell/bashrc" "$HOME/.bashrc"
link_file "$DOTFILES_DIR/shell/bash_profile" "$HOME/.bash_profile"
link_file "$DOTFILES_DIR/shell/profile" "$HOME/.profile"
link_file "$DOTFILES_DIR/shell/aliases" "$HOME/.aliases"
link_file "$DOTFILES_DIR/shell/functions" "$HOME/.functions"

# Git configs
link_file "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/git/gitignore_global" "$HOME/.gitignore_global"

# Terminal configs
link_file "$DOTFILES_DIR/terminal/tmux.conf" "$HOME/.tmux.conf"
[ -f "$DOTFILES_DIR/terminal/alacritty" ] && link_file "$DOTFILES_DIR/terminal/alacritty" "$HOME/.config/alacritty"
[ -f "$DOTFILES_DIR/terminal/kitty" ] && link_file "$DOTFILES_DIR/terminal/kitty" "$HOME/.config/kitty"

# Editor configs
link_file "$DOTFILES_DIR/editor/vimrc" "$HOME/.vimrc"
[ -d "$DOTFILES_DIR/editor/vim" ] && link_file "$DOTFILES_DIR/editor/vim" "$HOME/.vim"
link_file "$DOTFILES_DIR/editor/emacs" "$HOME/.emacs"
[ -d "$DOTFILES_DIR/editor/emacs.d" ] && link_file "$DOTFILES_DIR/editor/emacs.d" "$HOME/.emacs.d"

# Doom Emacs configs
[ -d "$DOTFILES_DIR/editor/doom.d" ] && link_file "$DOTFILES_DIR/editor/doom.d" "$HOME/.doom.d"
[ -d "$DOTFILES_DIR/editor/doom-config" ] && link_file "$DOTFILES_DIR/editor/doom-config" "$HOME/.config/doom"

# VS Code (location depends on OS)
if [ "$OS" == "linux" ]; then
    [ -f "$DOTFILES_DIR/editor/vscode/settings.json" ] && \
        link_file "$DOTFILES_DIR/editor/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
    [ -f "$DOTFILES_DIR/editor/vscode/keybindings.json" ] && \
        link_file "$DOTFILES_DIR/editor/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
elif [ "$OS" == "macos" ]; then
    [ -f "$DOTFILES_DIR/editor/vscode/settings.json" ] && \
        link_file "$DOTFILES_DIR/editor/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
    [ -f "$DOTFILES_DIR/editor/vscode/keybindings.json" ] && \
        link_file "$DOTFILES_DIR/editor/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
fi

# SSH config (without keys)
[ -f "$DOTFILES_DIR/ssh/config" ] && link_file "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"

# Window Manager configs
[ -d "$DOTFILES_DIR/wm/i3" ] && link_file "$DOTFILES_DIR/wm/i3" "$HOME/.config/i3"
[ -d "$DOTFILES_DIR/wm/sway" ] && link_file "$DOTFILES_DIR/wm/sway" "$HOME/.config/sway"
# First, restore the hyprdots base
if [ -d "$DOTFILES_DIR/hyprdots" ]; then
    echo "Restoring hyprdots base setup..."
    cp -r "$DOTFILES_DIR/hyprdots" "$HOME/fedora-hyprland-hyprdots"
fi

# Then link your custom Hyprland config on top
[ -d "$DOTFILES_DIR/wm/hypr" ] && link_file "$DOTFILES_DIR/wm/hypr" "$HOME/.config/hypr"
link_file "$DOTFILES_DIR/wm/xinitrc" "$HOME/.xinitrc"
link_file "$DOTFILES_DIR/wm/Xresources" "$HOME/.Xresources"

# Link .config directories
for config_dir in "$DOTFILES_DIR/config"/*; do
    if [ -d "$config_dir" ]; then
        config_name=$(basename "$config_dir")
        link_file "$config_dir" "$HOME/.config/$config_name"
    fi
done

# OS-specific setup
if [ "$OS" == "linux" ] && [ "$DISTRO" == "fedora" ]; then
    echo "Setting up Fedora-specific configurations..."
    
    read -p "Do you want to install packages from dnf-user-installed.txt? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "$DOTFILES_DIR/package-lists/dnf-user-installed.txt" ]; then
            echo "Installing packages from dnf-user-installed.txt..."
            # Extract package names and install them
            grep -v '@' "$DOTFILES_DIR/package-lists/dnf-user-installed.txt" | xargs sudo dnf install -y
        fi
    fi
    
    read -p "Do you want to install Flatpak apps? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "$DOTFILES_DIR/package-lists/flatpak-packages.txt" ]; then
            echo "Installing Flatpak applications..."
            xargs -I{} flatpak install -y {} < "$DOTFILES_DIR/package-lists/flatpak-packages.txt"
        fi
    fi
    
    # GNOME settings if applicable
    if command -v dconf &> /dev/null; then
        read -p "Do you want to load GNOME settings? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [ -f "$DOTFILES_DIR/os-specific/linux/dconf-settings.ini" ]; then
                echo "Loading GNOME settings..."
                dconf load / < "$DOTFILES_DIR/os-specific/linux/dconf-settings.ini"
            fi
        fi
    fi
    
elif [ "$OS" == "macos" ]; then
    echo "Setting up macOS-specific configurations..."
    
    # Install Homebrew if not installed
    if ! command -v brew &> /dev/null; then
        read -p "Homebrew is not installed. Do you want to install it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    fi
    
    # Install from Brewfile
    if [ -f "$DOTFILES_DIR/os-specific/macos/Brewfile" ]; then
        read -p "Do you want to install applications from Brewfile? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing from Brewfile..."
            brew bundle --file="$DOTFILES_DIR/os-specific/macos/Brewfile"
        fi
    fi
fi

echo "Dotfiles installation complete!"
