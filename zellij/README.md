# My Zellij Configuration

A Zellij configuration (`config.kdl`) shaped to match the Tmux setup in this repository, so the same fingers work in both.

## 🚀 Installation (Automated)

You can easily set up this configuration on any new machine using the provided automated installation script.

1. Clone this repository to your local machine:
```shell
git clone git@github.com:choridev/environment-settings.git
cd environment-settings/zellij
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
> The script is **idempotent and safe**. It checks for `zellij`, safely backs up any existing `config.kdl`, creates a **symbolic link** (`~/.config/zellij/config.kdl -> repo/config.kdl`) for real-time synchronization, and finally asks Zellij itself to parse the result so a broken config fails the install instead of your next session.

> [!NOTE]
> Only the file is linked, not the directory. Zellij writes `layouts/`, `themes/` and its own `.bak` files into `~/.config/zellij`, and linking the whole directory would drag them into this repository.

## 🎭 The Prefix, and Why Zellij Needs One

Zellij has no prefix. It is modal: you enter a mode, and every key in that mode is a command until you leave.

This configuration turns that into a Tmux prefix. `default_mode` is `locked`, where Zellij passes every key through to the program in the pane, and **`Ctrl + t`** unlocks it for exactly one command — each binding returns to `locked` when it fires. The result behaves like `Ctrl + t` in Tmux, and `Ctrl + t` `Ctrl + t` sends a literal `Ctrl + t` through, the same as Tmux's `send-prefix`.

The sub-modes are still there underneath. `Ctrl + t` `p` enters pane mode, `t` tab mode, `r` resize, `s` scroll, `m` move, `o` session — and those stay open until `Esc`, `Enter` or `Ctrl + t`. The bindings below are shortcuts straight off the prefix for the things reached often enough to be worth one.

## ✨ Features & Settings

- **Large Scrollback Buffer**: Keeps 50,000 lines per pane (`scroll_buffer_size 50000`), matching the Tmux `history-limit`. Takes effect on restart.
- **Mouse Support**: Enabled (`mouse_mode true`). Zellij enables it by default; it is written out so the intent survives a change of default.
- **System Clipboard Integration**: `copy_on_select true` with `copy_command` left unset, which makes OSC 52 the copy path — the same job `set-clipboard on` does in Tmux, and the reason copying works over SSH.
- **Theme Follows the Terminal**: `theme_dark` and `theme_light` are set to `catppuccin-frappe` and `catppuccin-latte`, so the colours track the host terminal's reported palette instead of being pinned to one.
- **Locked by Default**: `default_mode "locked"`, which is what makes the prefix scheme above work.

## ⌨️ Key Mappings

Press **`Ctrl + t`** first, then:

### Panes

- `\`: Split into two panes side by side (a vertical divider). New panes inherit the current directory, so no `-c` equivalent is needed.
- `-`: Split into two panes stacked top and bottom (a horizontal divider).
- `[` / `]`: Move to the previous / next pane. The prefix is needed for each move.
- `{` / `}`: Swap the focused pane with the one before / after it, carrying the focus along. Tmux's `swap-pane -U` / `-D`.
- `z`: Zoom — the focused pane fills the tab, and the tab bar marks it `(FULLSCREEN)`. Press again to restore.
- `!`: Break the focused pane out into a tab of its own.

### Tabs

A Zellij **tab** is what Tmux calls a **window**.

- `c`: New tab.
- `n`: Next tab.
- `l`: The tab you were on before this one.
- `,`: Rename the current tab.
- `w`: Open the session manager — sessions, their tabs and panes, in one floating picker. The closest thing to `choose-tree`.
- `i`: Toggle synchronised input, so typing goes to every pane in the tab at once. The tab bar marks it, so no status-bar flag is needed.
- `space`: Cycle the layout.

### Scrollback & Search

- `v`: Enter scroll mode, the way `v` enters copy mode in the Tmux config. From there:
  - `f`: Search. Type the term, `Enter`, then `n` / `p` for next and previous, `c` / `o` / `w` to toggle case sensitivity, whole-word and wrap.
  - `e`: Open the scrollback in `$EDITOR`.
  - `Esc`: Leave.

> [!IMPORTANT]
> **There is no keyboard text selection in Zellij.** No `v` to begin a selection, no `Ctrl + v` block mode, no `y`. Those actions do not exist — `BeginSelection`, `RectangleToggle` and `Yank` are not part of Zellij's vocabulary, so the Tmux copy-mode bindings have nothing to map onto.
>
> What replaces them: drag with the mouse (`copy_on_select` copies on release), or press `e` in scroll mode. That dumps the scrollback to a temp file and opens it in `$EDITOR` — real Vim, so `v`, `Ctrl + v`, `y`, `/` and macros all work there. Over SSH, getting a yank from the editor to the local clipboard needs OSC 52 configured in the editor itself.

> [!NOTE]
> `Ctrl + t` `s` `c` copies the output of the last command in one keystroke, which covers the most common reason for reaching into the scrollback at all. It needs OSC 133 shell integration.

## 🔀 What Did Not Carry Over From Tmux

Four things in `../tmux/.tmux.conf` have no equivalent here. They are commented in `config.kdl` at the point where they would have gone.

- **Automatic pane evening.** The Tmux config runs `select-layout -E` after every split and after a pane closes. Zellij has no such action. Splitting four times leaves panes at 50/25/12/12, and closing one hands all of its space to a single neighbour — the same shape Tmux has without `-E`. `Ctrl + t` `space` is the manual repair: it snaps the tab to a preset layout. `auto_layout` does not fill the gap, since it only applies to panes opened without a direction and rearranges everything into a `main-vertical`-ish preset, discarding the structure `\` and `-` build up.
- **Dimmed unfocused panes.** Zellij themes have no per-pane foreground colour, so `window-style` / `window-active-style` have nowhere to go. The pane frame is the only marker of focus.
- **Keyboard selection and yank.** Covered above.
- **Mouse wheel scroll speed.** Tmux gets one line per wheel event through a `-N 1` copy-mode binding. Zellij exposes no equivalent option.

> [!NOTE]
> Zellij ships a built-in `tmux` mode on `Ctrl + b`. This configuration sets `clear-defaults=true`, which removes it, and nothing here re-enables it. It is a thinner emulation than the bindings above — no `!`, `w`, `l`, `{`/`}`, `i` or numbered tabs — and it uses Tmux's default `"` and `%` for splits rather than the `\` and `-` this repository uses.

> [!IMPORTANT]
> If your shell profile starts Tmux automatically on login, it will do so **inside every Zellij pane**, since Zellij does not set `$TMUX`. Guard that block with `[[ -z "$ZELLIJ" ]]` before using this configuration over SSH.
