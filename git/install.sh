#!/bin/bash

echo "🚀 Starting Git environment auto-setup..."

# 0. Check dependencies (git)
if ! command -v git &> /dev/null; then
    echo "❌ Error: 'git' is not installed. Please install git first."
    exit 1
fi

# 1. Check for the template file (Fail-fast mechanism)
echo "🔍 1/4: Checking for template .gitconfig..."
if [ ! -f ".gitconfig" ]; then
    echo "❌ Error: .gitconfig file not found in the current directory. Skipping setup."
    exit 1
fi

# Get the absolute path of the current directory
DOTFILES_DIR=$(pwd)
echo "✅ Template found at $DOTFILES_DIR/.gitconfig"

# 2. Backup existing configuration safely (Symlink aware)
echo "💾 2/4: Checking for existing Git configuration..."
if [ -f ~/.gitconfig ] || [ -h ~/.gitconfig ]; then
    # If it is already correctly symlinked, skip the backup
    if [ "$(readlink ~/.gitconfig)" = "$DOTFILES_DIR/.gitconfig" ]; then
        echo "✅ ~/.gitconfig is already correctly symlinked. Skipping backup."
    else
        BACKUP_TIME=$(date +"%Y%m%d_%H%M%S")
        mv ~/.gitconfig ~/.gitconfig.backup_$BACKUP_TIME
        echo "✅ Existing .gitconfig safely backed up to ~/.gitconfig.backup_$BACKUP_TIME"
    fi
else
    echo "✅ No existing .gitconfig found. Proceeding cleanly."
fi

# 3. Create Symbolic Link
echo "🔗 3/4: Creating a symbolic link for .gitconfig..."
ln -sf "$DOTFILES_DIR/.gitconfig" ~/.gitconfig
echo "✅ Symlink created! (~/.gitconfig -> $DOTFILES_DIR/.gitconfig)"

# 4. Interactive Local Config Setup (.gitconfig.local)
echo "👤 4/4: Setting up personal Git information..."
if [ -f ~/.gitconfig.local ]; then
    echo "✅ ~/.gitconfig.local already exists. Skipping interactive setup to preserve your keys."
else
    echo "💡 No local configuration found. Let's set it up!"
    echo "---------------------------------------------------"
    
    read -p "👉 Enter your Git Name: " GIT_NAME
    read -p "👉 Enter your Git Email: " GIT_EMAIL
    read -p "👉 Enter your SSH Signing Key path [Default: ~/.ssh/id_ed25519.pub]: " GIT_SIGNINGKEY

    # Apply default value if user just pressed Enter
    GIT_SIGNINGKEY=${GIT_SIGNINGKEY:-~/.ssh/id_ed25519.pub}

    # Create the local file with the provided (or default) inputs
    cat <<EOF > ~/.gitconfig.local
[user]
    name = $GIT_NAME
    email = $GIT_EMAIL
    signingkey = $GIT_SIGNINGKEY
EOF
    echo "✅ ~/.gitconfig.local successfully created with signingkey: $GIT_SIGNINGKEY"
    echo "---------------------------------------------------"
fi

echo ""
echo "🎉 All set! Your Git environment is ready to use."
