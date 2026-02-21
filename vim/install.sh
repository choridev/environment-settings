#!/bin/bash

echo "🚀 Starting Vim environment auto-setup..."

# 0. Check dependencies (curl and vim)
if ! command -v curl &> /dev/null; then
    echo "❌ Error: 'curl' is not installed. Please install curl first."
    exit 1
fi

if ! command -v vim &> /dev/null; then
    echo "❌ Error: 'vim' is not installed. Please install vim first."
    exit 1
fi

# 1. Check for the template file
echo "🔍 1/5: Checking for template .vimrc..."
if [ ! -f ".vimrc" ]; then
    echo "❌ Error: .vimrc file not found in the current directory. Skipping setup."
    exit 1
fi

# Get the absolute path of the current directory
DOTFILES_DIR=$(pwd)
echo "✅ Template found at $DOTFILES_DIR/.vimrc"

# 2. Backup existing configuration safely (Symlink aware)
echo "💾 2/5: Checking for existing Vim configuration..."
if [ -f ~/.vimrc ] || [ -h ~/.vimrc ]; then
    # If it is already correctly symlinked, skip the backup
    if [ "$(readlink ~/.vimrc)" = "$DOTFILES_DIR/.vimrc" ]; then
        echo "✅ ~/.vimrc is already correctly symlinked. Skipping backup."
    else
        BACKUP_TIME=$(date +"%Y%m%d_%H%M%S")
        mv ~/.vimrc ~/.vimrc.backup_$BACKUP_TIME
        echo "✅ Existing .vimrc safely backed up to ~/.vimrc.backup_$BACKUP_TIME"
    fi
else
    echo "✅ No existing .vimrc found. Proceeding cleanly."
fi

# 3. Install vim-plug
echo "📦 3/5: Installing vim-plug..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "✅ vim-plug installed!"

# 4. Create Symbolic Link
echo "🔗 4/5: Creating a symbolic link for .vimrc..."
ln -sf "$DOTFILES_DIR/.vimrc" ~/.vimrc
echo "✅ Symlink created! (~/.vimrc -> $DOTFILES_DIR/.vimrc)"

# 5. Auto-install Vim plugins
echo "🔌 5/5: Auto-installing Vim plugins..."
vim +PlugInstall +qall

echo ""
echo "🎉 All set! Open your terminal and type 'vim' to enjoy your new setup."

