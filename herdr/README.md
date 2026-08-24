# My Herdr Configuration

A [Herdr](https://herdr.dev) configuration (`config.toml`) keyed to match the Tmux setup in this repository, so the same fingers work in both.

Herdr is a terminal workspace manager built around AI coding agents. Unlike Zellij it is already prefix-driven, so porting the Tmux keymap is a matter of renaming keys rather than rebuilding a mode machine.

## 🚀 Installation (Automated)

You can easily set up this configuration on any new machine using the provided automated installation script.

1. Clone this repository to your local machine:
```shell
git clone git@github.com:choridev/environment-settings.git
cd environment-settings/herdr
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
> The script is **idempotent and safe**. It checks for `herdr`, safely backs up any existing `config.toml`, creates a **symbolic link** (`~/.config/herdr/config.toml -> repo/config.toml`) for real-time synchronization, and asks Herdr itself to parse the result so a broken config fails the install instead of your next session.

> [!NOTE]
> Only the file is linked, not the directory. Herdr keeps its sockets, logs and `session.json` in `~/.config/herdr`, and linking the whole directory would drag them into this repository.

> [!IMPORTANT]
> If a Herdr server is already running, the installer reloads it, and **the prefix changes from `Ctrl + b` to `Ctrl + t` immediately** — including in the session you are sitting in.

## ✨ Features & Settings

- **Tmux Prefix**: `Ctrl + t`, replacing Herdr's own `Ctrl + b`, matching [`../tmux`](../tmux) and [`../zellij`](../zellij).
- **Theme Follows the Terminal**: `auto_switch` with `catppuccin-latte` for light and `catppuccin` for dark, so the colours track the host terminal instead of being pinned to one.
- **Onboarding Off**: `onboarding = false` skips the first-run walkthrough.

Everything else is left at Herdr's defaults. `herdr --default-config` prints the full reference, and `herdr config check` validates this file — it catches unknown keys, invalid key syntax, *and* two actions claiming the same chord.

## ⌨️ Key Mappings

Press **`Ctrl + t`** first, then:

### Panes

- `\`: Split into two panes side by side. Herdr names this `split_vertical` after the divider, the same convention the `.tmux.conf` comments use.
- `-`: Split into two panes stacked top and bottom (`split_horizontal`).
- `[` / `]`: Previous / next pane.
- `;`: Back to the pane you were on before this one.
- `h` `j` `k` `l` or `←` `↓` `↑` `→`: Move focus in that direction. Both sets work.
- `v`: Open the scrollback in `$EDITOR`.
- `{` / `}`: Swap the focused pane with its neighbour to the left / right.
- `x`: Close the pane. `z`: Zoom. `r`: Resize mode.

> [!NOTE]
> `focus_pane_*` takes one key each, so `hjkl` holds the native bindings — Herdr's own default, and the Vim answer — and the arrow keys, which is what Tmux binds `select-pane` to, run `herdr pane focus` as custom commands instead. Same result either way; the arrows cost one process spawn per press.

> [!NOTE]
> `{` and `}` are not native actions — Herdr has no swap binding, so they run `herdr pane swap` as detached shell commands. Not an exact port: Tmux's `swap-pane -U` / `-D` walk the pane order, while Herdr swaps with whatever sits in a given direction. In a plain row or column the two agree; in a nested layout they can differ.

### Tabs

A Herdr **tab** is what Tmux calls a **window**.

- `c`: New tab. `n` / `p`: Next / previous tab. `1`–`9`: Jump to that tab.
- `,`: Rename the current tab.
- `<` / `>`: Move the current tab left or right along the tab bar.

`c`, `n`, `p` and `1`–`9` are already Herdr's defaults and match Tmux as they stand. Herdr has no sub-modes competing for those letters, so `p` means *previous tab* here — something the Zellij port could not manage, since Zellij spends `p` on entering pane mode.

### Session

- `d`: Detach. `w`: Workspace picker. `?`: Help. `b`: Toggle the sidebar.

### Inside the Picker

`w` opens navigate mode, which has its own keys — local to the picker and independent of the pane focus keys above.

- `k` / `j`: Previous / next workspace.
- `h` / `l` or `←` / `→`: Previous / next pane.

Herdr's defaults are the other way round: workspaces on the arrow keys, panes on all four of `hjkl`. Panes are already reachable from the prefix with `[`, `]` and `h`/`l`, so the vertical pair is worth more on the workspace list, which is the thing actually stacked vertically in the picker.

> [!NOTE]
> `navigate_pane_down` and `navigate_pane_up` are set to the empty string rather than left out. Their defaults are `j` and `k`, and `herdr config check` accepts that overlap without complaining, which would leave it undecided at runtime which of the two moves. The left and right arrows are hardcoded by Herdr and keep working regardless.

## 🔀 What Did Not Carry Over From Tmux

- **Synchronised input.** No action for it. `herdr pane input` sets right-click routing, not input broadcast, so the `.tmux.conf`'s `i` has nothing to map onto.
- **Copy mode.** There is no keyboard selection or yank in Herdr itself. `Ctrl + t` `v` is pointed at the nearest thing — the scrollback opened in `$EDITOR` — so the `.tmux.conf`'s `bind v copy-mode` habit still lands somewhere useful, and a real Vim visual selection and yank happen there. Herdr's own default for that was `prefix+e`, now unbound; `v` was free because `split_vertical` moved onto the backslash.
- **Layout presets.** No `next-layout` action, so Tmux's `Space` has no home, and neither does `select-layout -E`.
- **Break pane out to a window.** No action for Tmux's `!`.
- **`x` and `&` confirmation.** Herdr closes panes and tabs without the `confirm-before` prompt Tmux wraps them in. `x` is left at Herdr's default; `&` is not bound at all.
