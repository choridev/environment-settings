#!/bin/bash

echo "🚀 Starting Neovim environment auto-setup..."

# 0. Check dependencies (nvim and git)
for cmd in nvim git; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ Error: '$cmd' is not installed. Please install $cmd first."
        exit 1
    fi
done

# 1. Check Neovim Version (Must be >= 0.11.0 to avoid lspconfig deprecation warning)
MIN_VERSION="0.11.0"
CURRENT_VERSION=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

echo "🔍 1/6: Checking Neovim version..."
if [ -n "$CURRENT_VERSION" ]; then
    LOWEST_VERSION=$(printf '%s\n' "$MIN_VERSION" "$CURRENT_VERSION" | sort -V | head -n1)
    if [ "$LOWEST_VERSION" != "$MIN_VERSION" ]; then
        echo "❌ Error: Neovim version must be >= $MIN_VERSION to use latest plugins."
        echo "Your current version is $CURRENT_VERSION."
        echo "Please upgrade Neovim to 0.11+ first."
        exit 1
    fi
    echo "✅ Neovim version ($CURRENT_VERSION) is $MIN_VERSION or higher!"
else
    echo "⚠️ Warning: Could not parse Neovim version. Proceeding anyway..."
fi

# 2. Check directory structure
echo "📂 2/6: Checking directory structure..."
DOTFILES_DIR="$(pwd)/nvim"

if [ ! -f "$DOTFILES_DIR/init.lua" ]; then
    echo "❌ Error: 'nvim/init.lua' not found."
    echo "Please make sure you have an 'nvim' folder containing 'init.lua' right next to this script."
    exit 1
fi
echo "✅ Target config directory found at $DOTFILES_DIR"

CONFIG_DIR="$HOME/.config/nvim"
mkdir -p "$HOME/.config"

# 3. Backup existing configuration safely
echo "💾 3/6: Checking for existing Neovim configuration..."
if [ -d "$CONFIG_DIR" ] || [ -h "$CONFIG_DIR" ]; then
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

# 4. Clean cache & state (Crucial)
echo "🧹 4/6: Cleaning up old Neovim state/cache..."
rm -rf "$HOME/.local/share/nvim.bak" "$HOME/.local/state/nvim.bak" "$HOME/.cache/nvim.bak" 2>/dev/null
[ -d "$HOME/.local/share/nvim" ] && mv "$HOME/.local/share/nvim" "$HOME/.local/share/nvim.bak"
[ -d "$HOME/.local/state/nvim" ] && mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.bak"
[ -d "$HOME/.cache/nvim" ] && mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.bak"
echo "✅ Old state and cache backed up and cleared."

# 5. Create Symbolic Link (Only the 'nvim' folder!)
echo "🔗 5/6: Creating a symbolic link..."
ln -sfn "$DOTFILES_DIR" "$CONFIG_DIR"
echo "✅ Symlink created! ($CONFIG_DIR -> $DOTFILES_DIR)"

# 6. Auto-install Neovim plugins via lazy.nvim
echo "🔌 6/6: Auto-installing Neovim plugins..."
nvim --headless "+Lazy! sync" +qa

echo ""
echo "🎉 All set! Open your terminal and type 'nvim' to enjoy your new setup."
