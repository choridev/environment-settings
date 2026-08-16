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
- **Dimmed Unfocused Panes**: Every pane but the focused one is greyed out, so the cursor is easy to find in a busy window. The dimming lifts while synchronised input is on and comes back when it is switched off.
- **Synchronised Input**: Type the same command into every pane of a window at once (`Ctrl + t` `i`), with a red **SYNC** flag in the status bar while it is active.
- **No Clipboard Plugin Required**: [tmux-yank](https://github.com/tmux-plugins/tmux-yank) is listed but commented out — it depends on a local clipboard tool (`pbcopy`, `xclip`, ...) and is useless on a headless server. OSC 52 covers the same job over SSH. Uncomment it if you run Tmux on a machine with a real clipboard.
- **True Color & SSH Fallbacks**: The configuration includes neatly organized, commented-out settings for 256/True Color overrides and manual OSC 52 escape sequences. Easily uncomment them if you experience color degradation or clipboard syncing issues over specific SSH environments.

## ⌨️ Key Mappings

### Prefix Bindings

The prefix is remapped from the Tmux default `Ctrl + b` to **`Ctrl + t`**. Press it first, then:

- `v`: Enter copy mode.
- `[` / `]`: Move to the previous / next pane (repeatable — keep pressing the key without re-entering the prefix).
- `\`: Split into two panes side by side (a vertical divider), keeping the current directory. The row is re-evened afterwards.
- `-`: Split into two panes stacked top and bottom (a horizontal divider), keeping the current directory. The column is re-evened afterwards.
- `i`: Toggle synchronised input — whatever you type goes to every pane in the window at once, and the dimming lifts for as long as it is on. Press it again to stop.

Both splits open the new pane in the same directory as the current one, so `\` and `-` are drop-in replacements for the defaults `%` and `"`.

Tmux halves only the current pane, so a third `\` would leave the row at 50/25/25. Both bindings run `select-layout -E` afterwards, which re-evens just the panes next to the new one — the rest of the window keeps its shape. The `even-horizontal` / `even-vertical` layouts would instead flatten everything into one row or column. Resize by hand if you want uneven panes; the next split in that direction evens them again.

Closing a pane re-evens the survivors too, whether it ended on its own (`exit`, `Ctrl + D`) or you killed it with `Ctrl + t` `x` — Tmux reports those through different hooks, so both are hooked.

Leftover rows or columns that do not divide evenly all go to the last pane: four panes in a 62-row terminal give 14/14/14/17. That is Tmux's own arithmetic, and `even-vertical` produces the same numbers.

> [!NOTE]
> Closing the **last** pane of a window closes the window, and the window you land on gets evened as a side effect — Tmux does not tell the hook which window the pane came from. Only noticeable if you had hand-resized that window.

Unfocused panes are greyed out through `window-style` / `window-active-style`. Both are palette entries — `brightblack` and `terminal` — so they follow the terminal's own light/dark theme instead of pinning a colour. Synchronised input overrides the dimming for that window, since every pane is live while it is on.

> [!NOTE]
> Only text left at the default colour dims. Anything a program colours itself — a shell prompt, syntax highlighting, `ls` output — keeps its own colour in an unfocused pane. The pane border and the cursor still mark the focused pane.

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
