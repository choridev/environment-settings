#!/bin/bash

echo "🚀 Starting Zsh environment auto-setup..."

# 0. Check dependencies
# git: cloning plugins | curl: installing starship | fzf: the `ssha` host picker
for cmd in zsh git curl fzf; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ Error: '$cmd' is not installed. Please install $cmd first."
        exit 1
    fi
done

# 1. Check for the template files (Fail-fast mechanism)
echo "🔍 1/6: Checking for template files..."
DOTFILES_DIR=$(pwd)
for f in .zshrc ssh-helper.zsh starship.toml; do
    if [ ! -f "$DOTFILES_DIR/$f" ]; then
        echo "❌ Error: '$f' not found in the current directory. Skipping setup."
        exit 1
    fi
done
echo "✅ Templates found at $DOTFILES_DIR"

# 2. Backup existing configuration safely (Symlink aware)
echo "💾 2/6: Checking for an existing .zshrc..."
if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
    if [ "$(readlink ~/.zshrc)" = "$DOTFILES_DIR/.zshrc" ]; then
        echo "✅ ~/.zshrc is already correctly symlinked. Skipping backup."
    else
        BACKUP_TIME=$(date +"%Y%m%d_%H%M%S")
        mv ~/.zshrc ~/.zshrc.backup_$BACKUP_TIME
        echo "✅ Existing .zshrc safely backed up to ~/.zshrc.backup_$BACKUP_TIME"
    fi
else
    echo "✅ No existing .zshrc found. Proceeding cleanly."
fi

# 3. Install Zsh plugins
echo "📦 3/6: Installing Zsh plugins..."
mkdir -p ~/.zsh
install_plugin() {
    local name="$1" url="$2"
    if [ ! -d "$HOME/.zsh/$name" ]; then
        git clone --depth 1 "$url" "$HOME/.zsh/$name"
        echo "✅ $name installed!"
    else
        echo "💡 $name is already installed. Skipping clone."
    fi
}
install_plugin fzf-tab https://github.com/Aloxaf/fzf-tab
install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
install_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting

# 4. Install Starship prompt
echo "🌟 4/6: Installing Starship prompt..."
if command -v starship &> /dev/null; then
    echo "💡 Starship is already installed ($(starship --version | head -1)). Skipping."
else
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    echo "✅ Starship installed!"
fi

# 5. Create symbolic links
echo "🔗 5/6: Creating symbolic links..."
mkdir -p ~/.config
ln -sfn "$DOTFILES_DIR/.zshrc" ~/.zshrc
ln -sfn "$DOTFILES_DIR/ssh-helper.zsh" ~/.zsh/ssh-helper.zsh
ln -sfn "$DOTFILES_DIR/starship.toml" ~/.config/starship.toml
echo "✅ Symlinks created!"
echo "   ~/.zshrc               -> $DOTFILES_DIR/.zshrc"
echo "   ~/.zsh/ssh-helper.zsh  -> $DOTFILES_DIR/ssh-helper.zsh"
echo "   ~/.config/starship.toml -> $DOTFILES_DIR/starship.toml"

# 6. Verify the configuration parses
echo "🧪 6/6: Verifying the configuration..."
if zsh -n "$DOTFILES_DIR/.zshrc" && zsh -n "$DOTFILES_DIR/ssh-helper.zsh"; then
    echo "✅ Syntax check passed!"
else
    echo "⚠️ Warning: a syntax error was reported above. The shell may not start cleanly."
fi

echo ""
echo "🎉 All set! Run 'chsh -s $(command -v zsh)' if zsh is not your login shell yet,"
echo "   then open a new terminal to enjoy your new setup."
