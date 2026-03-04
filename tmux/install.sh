#!/bin/bash

echo "🚀 Starting Tmux environment auto-setup..."

# 0. Check dependencies (git and tmux)
if ! command -v git &> /dev/null; then
    echo "❌ Error: 'git' is not installed. Please install git first."
    exit 1
fi

if ! command -v tmux &> /dev/null; then
    echo "❌ Error: 'tmux' is not installed. Please install tmux first."
    exit 1
fi

# 1. Check for the template file (Fail-fast mechanism)
echo "🔍 1/5: Checking for template .tmux.conf..."
if [ ! -f ".tmux.conf" ]; then
    echo "❌ Error: .tmux.conf file not found in the current directory. Skipping setup."
    exit 1
fi

# Get the absolute path of the current directory
DOTFILES_DIR=$(pwd)
echo "✅ Template found at $DOTFILES_DIR/.tmux.conf"

# 2. Backup existing configuration safely (Symlink aware)
echo "💾 2/5: Checking for existing Tmux configuration..."
if [ -f ~/.tmux.conf ] || [ -h ~/.tmux.conf ]; then
    # If it is already correctly symlinked, skip the backup
    if [ "$(readlink ~/.tmux.conf)" = "$DOTFILES_DIR/.tmux.conf" ]; then
        echo "✅ ~/.tmux.conf is already correctly symlinked. Skipping backup."
    else
        BACKUP_TIME=$(date +"%Y%m%d_%H%M%S")
        mv ~/.tmux.conf ~/.tmux.conf.backup_$BACKUP_TIME
        echo "✅ Existing .tmux.conf safely backed up to ~/.tmux.conf.backup_$BACKUP_TIME"
    fi
else
    echo "✅ No existing .tmux.conf found. Proceeding cleanly."
fi

# 3. Install TPM (Tmux Plugin Manager)
echo "📦 3/5: Installing TPM (Tmux Plugin Manager)..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "✅ TPM installed!"
else
    echo "💡 TPM is already installed. Skipping clone."
fi

# 4. Create Symbolic Link
echo "🔗 4/5: Creating a symbolic link for .tmux.conf..."
ln -sf "$DOTFILES_DIR/.tmux.conf" ~/.tmux.conf
echo "✅ Symlink created! (~/.tmux.conf -> $DOTFILES_DIR/.tmux.conf)"

# 5. Auto-install Tmux plugins
echo "🔌 5/5: Auto-installing Tmux plugins..."
# Reload tmux settings if it's already running, then install plugins.
tmux source ~/.tmux.conf 2>/dev/null
~/.tmux/plugins/tpm/bin/install_plugins
echo "✅ Plugins installed!"

echo ""
echo "🎉 All set! Open your terminal and type 'tmux' to enjoy your new setup."
