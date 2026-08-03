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
> The script is **idempotent and safe**. It checks for dependencies, safely backs up any existing `~/.zshrc`, clones the two Zsh plugins into `~/.zsh/`, installs Starship only when it is missing, creates **symbolic links** (`~/.zshrc`, `~/.zsh/ssh-helper.zsh`, `~/.config/starship.toml`) for real-time synchronization, and finishes with a `zsh -n` syntax check.

If Zsh is not your login shell yet, switch to it once the script has finished:
```shell
chsh -s "$(command -v zsh)"
```

## ✨ Features

### Shell
- **Prompt**: **[Starship](https://starship.rs)**, configured in `starship.toml` — the hostname appears only over SSH, and the prompt shows the git branch, a compact git status, the UTC time, and how long the last command took.
- **Completion**: `compinit` with substring matching and an fzf picker on Tab — see [Completion](#-completion) below.
- **History**: 100,000 entries, appended immediately so parallel shells do not clobber each other. Commands typed with a leading space are not recorded.
- **Plugins**: **[fzf-tab](https://github.com/Aloxaf/fzf-tab)**, **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** and **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)**. Every plugin is sourced through a guard, so a missing file degrades the shell gracefully instead of erroring on every startup.
- **Node**: `nvm` is loaded when `~/.nvm` is present. Note that sourcing `nvm.sh` dominates shell startup time.

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

### Automatic tmux
When the session is interactive, arrives over SSH, and is not already inside tmux, the shell attaches to a session named `main` (creating it if needed) with the window named after the short hostname. Local shells are left alone.

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
- `Ctrl + s`: Open the connection in a new pane below. *(inside tmux only)*
- `Ctrl + o`: Open the connection in a new pane to the right. *(inside tmux only)*
- `Ctrl + n`: Open the connection in a new tmux window named after the host. *(inside tmux only)*

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
