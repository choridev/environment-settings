# My Zsh Configuration

A fast, portable Zsh setup built around a Starship prompt, a persistent SSH agent, and `ssha` — an fzf-driven host picker that reads your own `~/.ssh/config`.

## ⚠️ Requirements
- **Zsh**
- **Git** and **curl** (Required to clone the plugins and install Starship)
- **fzf** (Required by the `ssha` host picker; without it `ssha` falls back to a numbered list)
- A **Nerd Font** (Optional, but recommended so the Starship prompt renders cleanly)

> [!NOTE]
> **[Starship](https://starship.rs)** is installed automatically by the script if it is missing. Everything else must already be on the machine.

## 🚀 Installation (Automated)

You can easily set up this configuration on any new machine using the provided automated installation script.

1. Clone this repository to your local machine:
```shell
git clone git@github.com:choridev/environment-settings.git
cd environment-settings/zsh
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
> The script is **idempotent and safe**. It checks for dependencies, safely backs up any existing `~/.zshrc`, clones the three Zsh plugins into `~/.zsh/`, installs Starship only when it is missing, creates **symbolic links** (`~/.zshrc`, `~/.zsh/ssh-helper.zsh`, `~/.config/starship.toml`) for real-time synchronization, writes a `~/.zshrc.local` stub if you do not have one, and finishes with a `zsh -n` syntax check.

### Machine-local settings

Keep API tokens, per-machine paths, and any work-specific aliases in `~/.zshrc.local`. It is created by the installer with mode `600`, is sourced last so it can override anything above it, and is never committed.

```shell
# ~/.zshrc.local
export SOME_API_TOKEN="..."
export SOME_REPO="$HOME/path/to/repo"
alias sr='cd "$SOME_REPO"'
```

If Zsh is not your login shell yet, switch to it once the script has finished:
```shell
chsh -s "$(command -v zsh)"
```

## ✨ Features

### Shell
- **Prompt**: **[Starship](https://starship.rs)**, configured in `starship.toml` — the hostname appears only over SSH, and the prompt shows the git branch, a compact git status, the UTC time, and how long the last command took.
- **Completion**: `compinit` with substring matching and an fzf picker on Tab, plus Herdr's own completions regenerated whenever its binary changes — see [Completion](#-completion) below.
- **History**: 100,000 entries, appended immediately so parallel shells do not clobber each other. Commands typed with a leading space are not recorded. **Up** and **Down** search for history entries that start with whatever is already on the line, so typing `ansi` and pressing Up walks through past `ansible-playbook …` commands instead of the last thing you ran. On an empty line they behave like plain history navigation, and inside a multi-line command they move between its lines first.
- **Plugins**: **[fzf-tab](https://github.com/Aloxaf/fzf-tab)**, **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** and **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)**. Every plugin is sourced through a guard, so a missing file degrades the shell gracefully instead of erroring on every startup.
- **Pager**: `LESS='-R'` — colour escapes pass through, and no `-F`. That flag only bites on piped input, where it quits when the output is shorter than one screen, so `cmd | less` would page sometimes and flash past other times; a file argument pages either way.
- **Node**: `nvm` is loaded when `~/.nvm` is present. Note that sourcing `nvm.sh` dominates shell startup time.
- **Portability**: The colour and `rm` aliases branch on whether GNU coreutils is present, so macOS gets `ls -G` with `CLICOLOR` and `rm -i` instead of the GNU-only `ls --color=auto` and `rm -I`. `diff --color` is enabled only if the installed `diff` accepts it.

## 🔎 Completion

Tab opens an **[fzf-tab](https://github.com/Aloxaf/fzf-tab)** picker over the candidates, and the candidates themselves are matched by **substring**, not by prefix. Typing part of a name from anywhere inside it is enough:

```shell
cd tron<Tab>                        # offers tron/, neutron/ and electron/
git switch osmosis<Tab>             # offers every branch containing "osmosis"
git switch argocd/k8s/osmo<Tab>     # fuzzy fallback still finds ...-osmosis-...
```

Matching is case-insensitive, so `OSMOSIS` finds the same branches as `osmosis`. Once the picker is open, keep typing to narrow it down with fzf's own fuzzy search.

Three settings have to agree for this to work, and dropping any one of them quietly breaks it:

- `matcher-list` puts substring matching **first**. A prefix matcher ahead of it would win outright — `tron` would resolve to `tron/` and `neutron/` would never be offered, because Zsh stops at the first matcher that produces a match.
- `menu yes` and `setopt menu_complete` keep Zsh from inserting the longest common prefix and calling it done. Without them `git switch osmosis` collapses to `argocd/`, throwing away the very text that was filtering the list.
- fzf-tab is sourced **before** zsh-autosuggestions and zsh-syntax-highlighting, since those wrap the same widget.

The trailing `r:|?=**` matcher is a fuzzy fallback that only runs when nothing else matched. It matches non-contiguously, so a query like `osmo` also pulls in `cosmos` — the picker is there to choose between them.

### Herdr's own completions

`herdr completion zsh` writes a 1,700-line `#compdef` function, not something to `eval`, so it goes in `fpath` as `~/.zsh/completions/_herdr`. That gets `herdr <Tab>` offering all 18 subcommands with their descriptions, `herdr pane <Tab>` offering 25, and the enum flags offering only their real values — `--direction` gives `right down`, `channel set` gives `stable preview`. The completion file is also a more complete command list than `herdr --help`, which omits `terminal` and `plugin`.

Both the directory and the file are created by the shell, not by `install.sh`, and the file is rewritten whenever the `herdr` binary is newer than it — Herdr self-updates, so a file generated once would go stale on new flags. Two `stat` calls per startup, measured at 0.014s. `compinit` picks up a newly written file even with a warm `.zcompdump`, so nothing has to invalidate the cache.

The same block also refreshes `~/.claude/skills/herdr/SKILL.md` from `herdr --skill`, on the same binary-is-newer test, so the two files Herdr generates about its own CLI can never drift apart. That half is skipped unless `~/.claude` already exists — the shell should not be the thing that creates Claude Code's config directory.

On a machine without Herdr the whole block is skipped: `command -v herdr` fails, so no directory is made and `fpath` is untouched.

### Automatic Multiplexer
When the session is interactive, arrives over SSH, and is not already inside a multiplexer, the shell attaches to one. [Herdr](../herdr) is used where it is installed, and [tmux](../tmux) otherwise. Local shells are left alone.

Plain `herdr` attaches to the persistent session it names `default`; passing `--session` with the hostname would fragment that into a second one. Tmux keeps the session named `main` with its window named after the hostname.

> [!NOTE]
> The guard checks that **both** `$HERDR_ENV` and `$TMUX` are empty. Each multiplexer sets only its own variable, so testing `$TMUX` alone would start Herdr inside every tmux pane.

`$HERDR_ENV` is Herdr's own marker for running inside Herdr, and its agent skill file tests it the same way. It is the test that matters most here: a Herdr pane inherits `SSH_TTY` from the login shell, so without it every new pane — and every split — would open another Herdr inside itself.

### Persistent SSH agent
The shell keeps one agent alive across every session by caching its environment in `~/.ssh-agent-info`, and only spawns a new agent when the cached one cannot be reached. It deliberately never runs `ssh-add`: key loading is left to `AddKeysToAgent yes` in `~/.ssh/config`, which adds a key to the agent the first time it is actually used. See the [`ssh`](../ssh) directory for that side of the setup.

## 🔍 `ssha` — SSH Host Picker

`ssha` reads every `Host` entry from `~/.ssh/config` (following `Include` directives), then opens an fzf picker with a live preview of the resolved user, hostname, port, identity file, and jump host.

```shell
ssha              # pick from all hosts
ssha web          # pick from hosts matching "web"
```

Reachability is probed with `ssh-keyscan` in the background and cached for a day, so hosts are marked `●` reachable or `○` unreachable in the list. Hosts behind a `ProxyJump` are skipped rather than probed.

> [!IMPORTANT]
> **Running `ssha` opens connections to your servers, without asking first.** The sweep starts on its own the first time you run `ssha`, and again whenever the cache is older than 24 hours — you never have to invoke `ssha-check` yourself. It covers every host in `~/.ssh/config` that is not behind a `ProxyJump`, **up to 50 at a time**, so on a large config this is a burst of parallel connections that your network monitoring may read as a port scan.
>
> Nothing is authenticated and nothing is sent: `ssh-keyscan -T 5` only asks each host for its public host key. Still, look over your SSH config before the first run, and use `ssha-status` when you just want to read the cached result without touching the network.

### Commands
- `ssha [query]`: Open the host picker and connect. Aliased to `sa`.
- `ssha-check`: Re-probe every host in the background and refresh the cache.
- `ssha-status [up|down]`: Show reachable/unreachable counts, or list either group.
- `ssha-cache-clear`: Drop the cached host list and helper scripts.

### Picker Keys
- `Enter`: Connect in the current shell.
- `Ctrl + s`: Open the connection in a new pane below. *(inside a multiplexer only)*
- `Ctrl + o`: Open the connection in a new pane to the right. *(inside a multiplexer only)*
- `Ctrl + n`: Open the connection in a new window (tmux) or tab (Herdr) named after the host. *(inside a multiplexer only)*

These three work in both tmux and Herdr. `$TMUX` is checked first, because locally Herdr is the outer multiplexer that spawns the shells — when both markers are set, the session in front of you is the tmux one nested inside a Herdr pane. Outside both, only `Enter` is offered.

All three take the same two steps: open a pane running a shell, then type `ssh …` into it. The pane therefore stays open when the connection ends rather than closing with it, and the command sits in that shell's history, ready to re-run with `↑`. The receiving shell re-splits whatever arrives, so `ssha` quotes each word itself and a host with a space in its name survives.

They differ in the details. tmux prints the new pane's id; Herdr answers with JSON, so its `pane_id` is read out of the reply. tmux needs an explicit `-c` to open the pane in the current directory, which Herdr inherits on its own, and Herdr needs an explicit `pane focus`, since it leaves the new pane unfocused where tmux hands it over.

Tab completion for `ssha` is wired to the same host list.

## ⌨️ Aliases

- `l` / `ll`: `ls -F` / `ls -alFh`
- `vi`: Open `nvim`
- `tm`: `tmux`
- `sa`: `ssha`
- `g`: `git`
- `cl`: `clear`
- `rm`: `rm -I` — prompts once before removing three or more files
- `ls`, `grep`, `diff`: Colour output enabled by default
