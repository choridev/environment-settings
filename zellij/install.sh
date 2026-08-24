#!/bin/bash

echo "🚀 Starting Zellij environment auto-setup..."

# 0. Check dependencies (zellij)
if ! command -v zellij &> /dev/null; then
    echo "❌ Error: 'zellij' is not installed. Please install zellij first."
    exit 1
fi

# 1. Check Zellij Version. This is the version the configuration was written
# and verified against, not a known floor — older releases may well work, so
# a mismatch only warns. Step 5 is what actually decides: it asks Zellij
# itself whether it can parse the file.
TESTED_VERSION="0.45.0"
CURRENT_VERSION=$(zellij --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

echo "🔍 1/5: Checking Zellij version..."
if [ -n "$CURRENT_VERSION" ]; then
    LOWEST_VERSION=$(printf '%s\n' "$TESTED_VERSION" "$CURRENT_VERSION" | sort -V | head -n1)
    if [ "$LOWEST_VERSION" != "$TESTED_VERSION" ]; then
        echo "⚠️ Warning: Zellij $CURRENT_VERSION is older than the tested $TESTED_VERSION."
        echo "   Proceeding — the configuration check in step 5 will catch a real problem."
    else
        echo "✅ Zellij version ($CURRENT_VERSION) is $TESTED_VERSION or higher!"
    fi
else
    echo "⚠️ Warning: Could not parse Zellij version. Proceeding anyway..."
fi

# 2. Check for the template file (Fail-fast mechanism)
echo "📂 2/5: Checking for template config.kdl..."
if [ ! -f "config.kdl" ]; then
    echo "❌ Error: config.kdl file not found in the current directory. Skipping setup."
    exit 1
fi

# Get the absolute path of the current directory
DOTFILES_DIR=$(pwd)
echo "✅ Template found at $DOTFILES_DIR/config.kdl"

CONFIG_DIR="$HOME/.config/zellij"
CONFIG_FILE="$CONFIG_DIR/config.kdl"
mkdir -p "$CONFIG_DIR"

# 3. Backup existing configuration safely (Symlink aware)
echo "💾 3/5: Checking for existing Zellij configuration..."
if [ -f "$CONFIG_FILE" ] || [ -h "$CONFIG_FILE" ]; then
    # If it is already correctly symlinked, skip the backup
    if [ "$(readlink "$CONFIG_FILE")" = "$DOTFILES_DIR/config.kdl" ]; then
        echo "✅ $CONFIG_FILE is already correctly symlinked. Skipping backup."
    else
        BACKUP_TIME=$(date +"%Y%m%d_%H%M%S")
        mv "$CONFIG_FILE" "$CONFIG_FILE.backup_$BACKUP_TIME"
        echo "✅ Existing config.kdl safely backed up to $CONFIG_FILE.backup_$BACKUP_TIME"
    fi
else
    echo "✅ No existing config.kdl found. Proceeding cleanly."
fi

# 4. Create Symbolic Link (Only the config file — Zellij writes its own
# layouts/, themes/ and .bak files into this directory)
echo "🔗 4/5: Creating a symbolic link for config.kdl..."
ln -sf "$DOTFILES_DIR/config.kdl" "$CONFIG_FILE"
echo "✅ Symlink created! ($CONFIG_FILE -> $DOTFILES_DIR/config.kdl)"

# 5. Verify that Zellij accepts the configuration
echo "🔌 5/5: Verifying the configuration..."
if zellij setup --check 2>&1 | grep -q "Well defined"; then
    echo "✅ Configuration parsed successfully."
else
    echo "❌ Error: Zellij rejected the configuration. Details:"
    zellij setup --check 2>&1 | grep -A 10 -iE "error|failed"
    exit 1
fi

echo ""
echo "🎉 All set! Open your terminal and type 'zellij' to enjoy your new setup."
