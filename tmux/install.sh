#!/bin/bash

echo "🚀 Starting Tmux environment auto-setup..."

# 1. Install TPM (Tmux Plugin Manager)
echo "📦 1/3: Installing TPM (Tmux Plugin Manager)..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "✅ TPM installed!"
else
    echo "💡 TPM is already installed. Skipping clone."
fi

# 2. Copy .tmux.conf file
echo "📄 2/3: Copying .tmux.conf to the home directory (~/)..."
if [ -f ".tmux.conf" ]; then
    cp .tmux.conf ~/.tmux.conf
    echo "✅ Copy complete!"
else
    echo "❌ Error: .tmux.conf file not found in the current directory. Skipping copy."
    exit 1
fi

# 3. Auto-install Tmux plugins
echo "🔌 3/3: Auto-installing Tmux plugins (tmux-yank)..."
# Reload tmux settings if it's already running, then install plugins.
tmux source ~/.tmux.conf 2>/dev/null
~/.tmux/plugins/tpm/bin/install_plugins

echo "🎉 All set! Open your terminal and type 'tmux' to enjoy your new setup."

