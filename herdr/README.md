# My Herdr Configuration

A [Herdr](https://herdr.dev) configuration (`config.toml`) keyed to match the Tmux setup in this repository, so the same fingers work in both.

Herdr is a terminal workspace manager built around AI coding agents. It is prefix-driven like Tmux, so porting the Tmux keymap is a matter of renaming keys rather than rebuilding it around modes.

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

- **Tmux Prefix**: `Ctrl + t`, replacing Herdr's own `Ctrl + b`, matching [`../tmux`](../tmux).
- **Theme Follows the Terminal**: `auto_switch` with `catppuccin-latte` for light and `catppuccin` for dark, so the colours track the host terminal instead of being pinned to one.
- **Onboarding Off**: `onboarding = false` skips the first-run walkthrough.
- **In-App Toasts**: `ui.toast.delivery = "herdr"`, on from `off`. Fires when a background agent finishes or needs input, and only if it is still in that state a second later. `terminal` and `system` hand the popup to the host instead, which a session reached over SSH cannot rely on. The copied-to-clipboard popup is separate and on by default.
- **50 MB of Scrollback**: `scrollback_limit_bytes`, 5x the default. The limit is bytes, not lines, and a row costs its full pane width — about 9 bytes a cell — so lines ≈ limit / (columns × 9) however short the lines are. A full-width pane here is 268 columns: ~4,150 lines on the default, ~20,700 at 50 MB. Two things it does not do: a pane keeps the limit it was born with, so `herdr server reload-config` reaches only panes opened afterwards, and rows belonging to the alternate screen — pagers, editors, TUI agents — never enter the scrollback at any size.

Both of the files Herdr generates about its own CLI are wired up on the [`../zsh`](../zsh) side, from one block with one trigger: the `.zshrc` rewrites the `#compdef` completions and the agent skill file whenever the `herdr` binary is newer than them. Herdr self-updates, so anything generated once would go stale on the next release.

`herdr --skill` prints Herdr's agent skill file — the instructions an AI agent needs to drive `pane read`, `pane run` and `pane wait-output`. It lands in `~/.claude/skills/herdr/SKILL.md` so Claude Code loads it on its own instead of being asked to run the command.

Everything else is left at Herdr's defaults. `herdr --default-config` prints the full reference, and `herdr config check` validates this file — it catches unknown keys, invalid key syntax, *and* two actions claiming the same chord.

## ⌨️ Key Mappings

Press **`Ctrl + t`** first, then:

### Panes

- `\`: Split into two panes side by side. Herdr names this `split_vertical` after the divider, the same convention the `.tmux.conf` comments use.
- `-`: Split into two panes stacked top and bottom (`split_horizontal`).
- `[` / `]`: Previous / next pane.
- `;`: Rename the pane. Next to the `,` that renames a tab; Herdr's own `prefix+shift+p` went to the pull-request popup, and Tmux's last-pane on `;` is given up for this.
- `h` `j` `k` `l` or `←` `↓` `↑` `→`: Move focus in that direction. Both sets work.
- `v`: Copy mode. `h` `j` `k` `l`, `w`/`b`/`e`, `{`/`}` and `PageUp`/`PageDown` to move, `/` or `?` to search and `n`/`N` to repeat, `v` or Space to select, `y` to copy, `q` to leave. Herdr's default is `[`, taken here by pane cycling.
- `e`: Open the whole scrollback in `$EDITOR`.
- `{` / `}`: Swap the focused pane with its neighbour to the left / right.
- `z`: Zoom. `r`: Resize mode.

> [!NOTE]
> Herdr binds `close_pane` to `prefix+x` and `close_tab` to `prefix+shift+x`, and both take effect immediately. Both are emptied here. Tmux wraps its `x` and `&` in `confirm-before`; Herdr's only confirmation setting is `ui.confirm_close`, which by its own description covers closing a *workspace*, not a pane or a tab. Exit the shell to close a pane; closing the last pane in a tab closes the tab.

> [!NOTE]
> `{` and `}` are `swap_pane_left` / `swap_pane_right`, not an exact port: Tmux's `swap-pane -U` / `-D` walk the pane order, while Herdr swaps with whatever sits in a given direction. In a plain row or column the two agree; in a nested layout they can differ. Only the horizontal pair is moved; `swap_pane_up` and `swap_pane_down` stay on their `prefix+shift+k` / `prefix+shift+j` defaults, so vertical swapping is there without a `.tmux.conf` counterpart.

> [!IMPORTANT]
> **`herdr --default-config` is not the whole list of settable keys, and `--help` is not the whole list of CLI flags.** `copy_mode`, `swap_pane_*` and `advanced.scrollback_limit_bytes` are all missing from that output, and `pane split --focus` is missing from its `--help`. Earlier revisions of this file recorded the first three as things Herdr could not do at all.
>
> The authoritative list is the [Config reference](https://herdr.dev/docs/config-reference/), which has every one of those keys with its default; array values — `next_tab = ["prefix+n", "ctrl+alt+]"]` — are on the [Configuration](https://herdr.dev/docs/configuration/) page. Read those before concluding a setting does not exist.
>
> `herdr config check` settles a name locally: `unknown config key keys.<name>` for one the binary does not know, `invalid keybinding` for a value it cannot parse — naming the offending key even inside an array — and `config: ok` otherwise. `HOME=/tmp/probe herdr config check` tries a name without touching this file. It compares explicit bindings against each other only: a key that collides with some *other* action's default passes as `ok`.

### Tabs

A Herdr **tab** is what Tmux calls a **window**.

- `c`: New tab. `n` / `p`: Next / previous tab. `1`–`9`: Jump to that tab.
- `,`: Rename the current tab.
- `<` / `>`: Move the current tab left or right along the tab bar.

`c`, `n`, `p` and `1`–`9` are already Herdr's defaults and match Tmux as they stand. Herdr has no sub-modes competing for those letters, so `p` means *previous tab* here rather than being spent on entering a mode.

### Agents

- `a` / `Shift + a`: Next / previous agent.
- `Ctrl + 1`–`Ctrl + 9`: Jump straight to that agent.

Herdr leaves all three unbound by default. Unlike the workspace picker these are single-shot, so the prefix is needed for each step rather than once for a run of them — `prefix+w` can do better only because `workspace_picker` opens a mode, and the set of mode-opening actions is fixed at `help`, `settings`, `open_notification_target`, `workspace_picker`, `goto`, `resize_mode` and `toggle_sidebar`. None of them concerns agents, and a config cannot define a new mode.

> [!NOTE]
> `focus_agent` is an indexed binding: the literal `1..9` covers all nine in one line, and `herdr config check` rejects any other form with *"indexed keybinding must use 1..9"*. Herdr's own example uses `prefix+alt+1..9`; `ctrl` is used here so `Alt` chords stay with the terminal.

### Session

- `d`: Detach. `w`: Workspace picker. `?`: Help. `b`: Toggle the sidebar.

### GitHub

- `Shift + I`: The open issues involving me, grouped by repository, in a popup.
- `Shift + P`: The open pull requests involving me, grouped by repository, in a popup.

Both are `[[keys.command]]` entries running `gh search` through `sort` into `fzf`, with `gh issue view` / `gh pr view` as the preview — Herdr has no action of its own for this. `--involves` rather than `--assignee`, which covers author, reviewer and mentions too and returns nothing at all for pull requests here. `sort -s -k1,1` keys on the repository field alone, and `-s` is what keeps each repository's rows in the newest-first order `gh` returned. `--limit 100` is well past the current counts; `gh` truncates silently, so if fzf's counter ever reads `100/100`, raise it.

### Inside the Picker

`w` opens navigate mode, which has its own keys — local to the picker and independent of the pane focus keys above.

- `k` / `j`: Previous / next workspace.
- `h` / `l` or `←` / `→`: Previous / next pane.

Herdr's defaults are the other way round: workspaces on the arrow keys, panes on all four of `hjkl`. Panes are already reachable from the prefix with `[`, `]` and `h`/`l`, so the vertical pair is worth more on the workspace list, which is the thing actually stacked vertically in the picker.

> [!NOTE]
> `navigate_pane_down` and `navigate_pane_up` are set to the empty string rather than left out. Their defaults are `j` and `k`, and `herdr config check` accepts that overlap without complaining, which would leave it undecided at runtime which of the two moves. The left and right arrows are hardcoded by Herdr and keep working regardless.

## 🔀 What Did Not Carry Over From Tmux

- **Synchronised input.** No action for it. `herdr pane input` sets right-click routing, not input broadcast, so the `.tmux.conf`'s `i` has nothing to map onto.
- **Layout presets.** No `next-layout` action, so Tmux's `Space` has no home, and neither does `select-layout -E`.
- **Break pane out to a window.** No action for Tmux's `!`.
- **`x` and `&` confirmation.** Herdr closes panes and tabs without the `confirm-before` prompt Tmux wraps them in — `ui.confirm_close` covers only workspaces. So nothing here closes either one from the keyboard: `close_pane` and `close_tab` are both emptied, and `&` was never mapped. `prefix+shift+d` closes a workspace and does ask first.
