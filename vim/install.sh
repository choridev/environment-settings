#!/bin/bash

echo "🚀 Starting Vim environment auto-setup..."

# 1. Install vim-plug (Plugin Manager)
echo "📦 1/3: Installing vim-plug..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 2. Copy .vimrc file
echo "📄 2/3: Copying .vimrc to the home directory (~/)..."
if [ -f ".vimrc" ]; then
    cp .vimrc ~/.vimrc
    echo "✅ Copy complete!"
else
    echo "❌ Error: .vimrc file not found in the current directory. Skipping copy."
fi

# 3. Auto-install Vim plugins
echo "🔌 3/3: Auto-installing Vim plugins (NERDTree, vim-anzu)..."
vim +PlugInstall +qall

echo "🎉 All set! Open your terminal and type 'vim' to enjoy your new setup."

