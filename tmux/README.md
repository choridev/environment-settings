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
- **Synchronised Input**: Type the same command into every pane of a window at once (`Ctrl + t` `i`), with a red **SYNC** flag in the status bar while it is active.
- **No Clipboard Plugin Required**: [tmux-yank](https://github.com/tmux-plugins/tmux-yank) is listed but commented out — it depends on a local clipboard tool (`pbcopy`, `xclip`, ...) and is useless on a headless server. OSC 52 covers the same job over SSH. Uncomment it if you run Tmux on a machine with a real clipboard.
- **True Color & SSH Fallbacks**: The configuration includes neatly organized, commented-out settings for 256/True Color overrides and manual OSC 52 escape sequences. Easily uncomment them if you experience color degradation or clipboard syncing issues over specific SSH environments.

## ⌨️ Key Mappings

### Prefix Bindings

The prefix is remapped from the Tmux default `Ctrl + b` to **`Ctrl + t`**. Press it first, then:

- `v`: Enter copy mode.
- `[` / `]`: Move to the previous / next pane (repeatable — keep pressing the key without re-entering the prefix).
- `\`: Split into two panes side by side (a vertical divider), keeping the current directory. Every pane in the row is re-spread to an equal width afterwards.
- `-`: Split into two panes stacked top and bottom (a horizontal divider), keeping the current directory. Every pane in the column is re-spread to an equal height afterwards.
- `i`: Toggle synchronised input — whatever you type goes to every pane in the window at once. Press it again to stop.

Both splits open the new pane in the same directory as the current one, so `\` and `-` are drop-in replacements for the defaults `%` and `"`.

Tmux splits the current pane in half and nothing else, so a third `\` would normally leave the row at 50/25/25. Both bindings run `select-layout -E` right after the split to even the panes back out — columns for `\`, rows for `-`. It only touches the panes sitting directly next to the new one, so the rest of the window keeps its shape: split a column off with `\`, then press `-` inside it, and the neighbouring columns stay exactly as wide as they were. That is why the bindings do not use the `even-horizontal` / `even-vertical` layouts, which flatten the whole window into one row or one column. Resize by hand afterwards if you want uneven panes; the next split in that direction will even them out again.

Tmux hands the leftover rows or columns that do not divide evenly to the last pane, so with four panes in a 62-row terminal you get 14/14/14/17 rather than a perfect quarter each. That is Tmux's own layout arithmetic — `even-vertical` produces exactly the same numbers — and it is most noticeable when stacking panes with `-` in a short terminal.

While synchronised input is on, a red **SYNC** flag sits at the right end of the status bar, and Tmux paints the active pane border red of its own accord. Look for either before typing anything you would not want to run in every pane at once.

> [!IMPORTANT]
> `[` and `]` override the Tmux defaults for that prefix. `Ctrl + t` `[` no longer enters copy mode — use `Ctrl + t` `v` instead — and `Ctrl + t` `]` no longer pastes the buffer. Use `Ctrl + t` `=` to pick a buffer to paste from.

> [!IMPORTANT]
> `i` also takes over a default: `Ctrl + t` `i` no longer shows the window information message. Run it through the command prompt (`Ctrl + t` `:` then `display-message`) on the rare occasion you want it.

> [!NOTE]
> Taking over `Ctrl + t` costs you the shell's `transpose-chars` binding, since Tmux swallows the key first. Press `Ctrl + t` twice to send a literal one through to the program running in the pane.

### Copy Mode

When you enter copy mode (by scrolling up with your mouse, or pressing `Ctrl + t` followed by `v`), you can use the following Vim-like bindings:

- `v`: Begin text selection (Visual mode).
- `Ctrl + v` (`<C-v>`): Toggle rectangle (block) selection.
- `y`: Yank (copy) the selected text to the system clipboard and exit copy mode.
