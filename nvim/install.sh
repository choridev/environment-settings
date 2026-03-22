#!/bin/bash

echo "🚀 Starting Neovim environment auto-setup..."

# 0. Check dependencies (nvim and git)
for cmd in nvim git; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ Error: '$cmd' is not installed. Please install $cmd first."
        exit 1
    fi
done

# 1. Check for the config files (init.lua)
echo "🔍 1/5: Checking for Neovim config files..."
if [ ! -f "init.lua" ]; then
    echo "❌ Error: 'init.lua' not found in the current directory."
    echo "Please run this script from inside your cloned nvim directory."
    exit 1
fi

DOTFILES_DIR=$(pwd)
CONFIG_DIR="$HOME/.config/nvim"
echo "✅ Config found at $DOTFILES_DIR"

# Ensure ~/.config exists
mkdir -p "$HOME/.config"

# 2. Backup existing configuration safely (Symlink & Directory aware)
echo "💾 2/5: Checking for existing Neovim configuration..."
if [ -d "$CONFIG_DIR" ] || [ -h "$CONFIG_DIR" ]; then
    # If it is already correctly symlinked, skip the backup
    if [ "$(readlink "$CONFIG_DIR")" = "$DOTFILES_DIR" ]; then
        echo "✅ ~/.config/nvim is already correctly symlinked. Skipping backup."
    else
        BACKUP_TIME=$(date +"%Y%m%d_%H%M%S")
        mv "$CONFIG_DIR" "$CONFIG_DIR.backup_$BACKUP_TIME"
        echo "✅ Existing nvim config safely backed up to $CONFIG_DIR.backup_$BACKUP_TIME"
    fi
else
    echo "✅ No existing nvim config found. Proceeding cleanly."
fi

# 3. Clean cache & state (Crucial for Neovim to prevent conflicts)
echo "🧹 3/5: Cleaning up old Neovim state/cache..."
rm -rf "$HOME/.local/share/nvim.bak" "$HOME/.local/state/nvim.bak" "$HOME/.cache/nvim.bak" 2>/dev/null
[ -d "$HOME/.local/share/nvim" ] && mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.bak"
[ -d "$HOME/.local/state/nvim" ] && mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.bak"
[ -d "$HOME/.cache/nvim" ] && mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.bak"
echo "✅ Old state and cache backed up and cleared."

# 4. Create Symbolic Link
echo "🔗 4/5: Creating a symbolic link for nvim..."
ln -sfn "$DOTFILES_DIR" "$CONFIG_DIR"
echo "✅ Symlink created! ($CONFIG_DIR -> $DOTFILES_DIR)"

# 5. Auto-install Neovim plugins via lazy.nvim
echo "🔌 5/5: Auto-installing Neovim plugins..."
nvim --headless "+Lazy! sync" +qa

echo ""
echo "🎉 All set! Open your terminal and type 'nvim' to enjoy your new setup."
