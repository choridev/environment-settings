#!/bin/bash

echo "🚀 Starting Herdr environment auto-setup..."

# 0. Check dependencies (herdr)
if ! command -v herdr &> /dev/null; then
    echo "❌ Error: 'herdr' is not installed. Please install herdr first."
    exit 1
fi

# 1. Check Herdr Version. This is the version the configuration was written and
# verified against, not a known floor — older releases may well work, so a
# mismatch only warns. Step 5 is what actually decides: it asks Herdr itself
# whether it can parse the file.
TESTED_VERSION="0.8.2"
CURRENT_VERSION=$(herdr --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

echo "🔍 1/5: Checking Herdr version..."
if [ -n "$CURRENT_VERSION" ]; then
    LOWEST_VERSION=$(printf '%s\n' "$TESTED_VERSION" "$CURRENT_VERSION" | sort -V | head -n1)
    if [ "$LOWEST_VERSION" != "$TESTED_VERSION" ]; then
        echo "⚠️ Warning: Herdr $CURRENT_VERSION is older than the tested $TESTED_VERSION."
        echo "   Proceeding — the configuration check in step 5 will catch a real problem."
    else
        echo "✅ Herdr version ($CURRENT_VERSION) is $TESTED_VERSION or higher!"
    fi
else
    echo "⚠️ Warning: Could not parse Herdr version. Proceeding anyway..."
fi

# 2. Check for the template file (Fail-fast mechanism)
echo "📂 2/5: Checking for template config.toml..."
if [ ! -f "config.toml" ]; then
    echo "❌ Error: config.toml file not found in the current directory. Skipping setup."
    exit 1
fi

# Get the absolute path of the current directory
DOTFILES_DIR=$(pwd)
echo "✅ Template found at $DOTFILES_DIR/config.toml"

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/herdr"
CONFIG_FILE="$CONFIG_DIR/config.toml"
mkdir -p "$CONFIG_DIR"

# 3. Backup existing configuration safely (Symlink aware)
echo "💾 3/5: Checking for existing Herdr configuration..."
if [ -f "$CONFIG_FILE" ] || [ -h "$CONFIG_FILE" ]; then
    # If it is already correctly symlinked, skip the backup
    if [ "$(readlink "$CONFIG_FILE")" = "$DOTFILES_DIR/config.toml" ]; then
        echo "✅ $CONFIG_FILE is already correctly symlinked. Skipping backup."
    else
        BACKUP_TIME=$(date +"%Y%m%d_%H%M%S")
        mv "$CONFIG_FILE" "$CONFIG_FILE.backup_$BACKUP_TIME"
        echo "✅ Existing config.toml safely backed up to $CONFIG_FILE.backup_$BACKUP_TIME"
    fi
else
    echo "✅ No existing config.toml found. Proceeding cleanly."
fi

# 4. Create Symbolic Link (Only the config file — Herdr keeps its sockets,
# logs and session.json in this same directory)
echo "🔗 4/5: Creating a symbolic link for config.toml..."
ln -sf "$DOTFILES_DIR/config.toml" "$CONFIG_FILE"
echo "✅ Symlink created! ($CONFIG_FILE -> $DOTFILES_DIR/config.toml)"

# 5. Verify that Herdr accepts the configuration, then reload a running server
echo "🔌 5/5: Verifying the configuration..."
CHECK_OUTPUT=$(herdr config check 2>&1)
if echo "$CHECK_OUTPUT" | grep -q '^config: ok'; then
    echo "✅ Configuration parsed successfully."
else
    echo "❌ Error: Herdr rejected the configuration. Details:"
    echo "$CHECK_OUTPUT"
    exit 1
fi

if herdr server reload-config >/dev/null 2>&1; then
    echo "✅ Running Herdr server reloaded."
    echo "⚠️  The prefix is now Ctrl+t, not Ctrl+b — including in this session."
else
    echo "💡 No running Herdr server to reload. The config applies on next start."
fi

echo ""
echo "🎉 All set! Open your terminal and type 'herdr' to enjoy your new setup."
