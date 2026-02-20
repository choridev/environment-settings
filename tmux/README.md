# My Tmux Configuration

A highly productive Tmux configuration (`.tmux.conf`) optimized for seamless mouse support and Vim-style text copying across SSH sessions.

## 🚀 Installation (Automated)

You can easily set up this configuration on any new machine using the provided automated installation script.

1. Clone this repository to your local machine:
```bash
git clone git@github.com:choridev/environment-settings.git
cd environment-settings/tmux
```

2. Make the script executable:
```bash
chmod +x install.sh
```

3. Run the installation script:
```bash
./install.sh
```

> **Note**: The script will automatically install [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm), copy the `.tmux.conf` file to your home directory, and install the required plugins.

## ✨ Features & Plugins

- **Mouse Support**: Fully enabled (`mouse on`). You can resize panes, switch windows, and scroll through history using your mouse or trackpad.
- **System Clipboard Integration**: Uses OSC 52 to synchronize copied text inside Tmux directly to your local OS clipboard (`set-clipboard on`).
- **Vim-style Copy Mode**: Navigate and copy text in Tmux just like you do in Vim.
- **[tmux-yank](https://github.com/tmux-plugins/tmux-yank)**: A plugin that enables copying to the system clipboard in Tmux.

## ⌨️ Key Mappings (Copy Mode)

When you enter copy mode (by scrolling up with your mouse or pressing `Ctrl + b` followed by `[`), you can use the following Vim-like bindings:

- `v`: Begin text selection (Visual mode).
- `Ctrl + v` (`<C-v>`): Toggle rectangle (block) selection.
- `y`: Yank (copy) the selected text to the system clipboard and exit copy mode.

