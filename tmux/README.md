# My Tmux Configuration

A highly productive Tmux configuration (`.tmux.conf`) optimized for seamless mouse support and Vim-style text copying across SSH sessions.

## 🚀 Installation (Automated)

You can easily set up this configuration on any new machine using the provided automated installation script.

1. Clone this repository to your local machine:
```shell
git clone git@github.com:choridev/environment-settings.git
cd environment-settings/tmux
```

2. Make the script executable:
```shell
chmod +x install.sh
```

3. Run the installation script:
```shell
./install.sh
```

> [!NOTE]
> The script is **idempotent and safe**. It checks for dependencies (`git`, `tmux`), safely backs up any existing `.tmux.conf`, installs [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm), creates a **symbolic link** (`~/.tmux.conf -> repo/.tmux.conf`) for real-time synchronization, and auto-installs all required plugins.

## ✨ Features & Plugins

- **Mouse Support**: Fully enabled (`mouse on`). You can resize panes, switch windows, and scroll through history using your mouse or trackpad.
- **System Clipboard Integration**: Uses OSC 52 to synchronize copied text inside Tmux directly to your local OS clipboard (`set-clipboard on`).
- **Vim-style Copy Mode**: Navigate and copy text in Tmux just like you do in Vim.
- **No Clipboard Plugin Required**: [tmux-yank](https://github.com/tmux-plugins/tmux-yank) is listed but commented out — it depends on a local clipboard tool (`pbcopy`, `xclip`, ...) and is useless on a headless server. OSC 52 covers the same job over SSH. Uncomment it if you run Tmux on a machine with a real clipboard.
- **True Color & SSH Fallbacks**: The configuration includes neatly organized, commented-out settings for 256/True Color overrides and manual OSC 52 escape sequences. Easily uncomment them if you experience color degradation or clipboard syncing issues over specific SSH environments.

## ⌨️ Key Mappings

### Prefix Bindings

Press the prefix (`Ctrl + b`) first, then:

- `v`: Enter copy mode.
- `[` / `]`: Move to the previous / next pane (repeatable — keep pressing the key without re-entering the prefix).
- `\`: Split into two panes side by side (a vertical divider), keeping the current directory.
- `-`: Split into two panes stacked top and bottom (a horizontal divider), keeping the current directory.

Both splits open the new pane in the same directory as the current one, so `\` and `-` are drop-in replacements for the defaults `%` and `"`.

> [!IMPORTANT]
> `[` and `]` override the Tmux defaults for that prefix. `Ctrl + b` `[` no longer enters copy mode — use `Ctrl + b` `v` instead — and `Ctrl + b` `]` no longer pastes the buffer. Use `Ctrl + b` `=` to pick a buffer to paste from.

### Copy Mode

When you enter copy mode (by scrolling up with your mouse, or pressing `Ctrl + b` followed by `v`), you can use the following Vim-like bindings:

- `v`: Begin text selection (Visual mode).
- `Ctrl + v` (`<C-v>`): Toggle rectangle (block) selection.
- `y`: Yank (copy) the selected text to the system clipboard and exit copy mode.
