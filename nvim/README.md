# My Neovim Configuration

A modern, blazing-fast, and modular Neovim configuration written entirely in Lua. Optimized for development speed, smart auto-completion, and powerful file navigation.

## ⚠️ Requirements
- **Neovim 0.11.0+** (Required for the latest LSP and plugin capabilities)
- **Git**, **curl**, and **npm** (Required by Mason for installing language servers)
- A **Nerd Font** (Optional but highly recommended for UI icons and `alpha-nvim` dashboard)

## 🚀 Installation (Automated)

You can easily set up this configuration on any new machine using the provided automated installation script.

1. Clone this repository to your local machine:
```shell
git clone git@github.com:choridev/environment-settings.git
cd environment-settings/nvim
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
> The script is **idempotent and safe**. It checks for dependencies and the required Neovim version (`>= 0.11.0`). It safely backs up your existing `~/.config/nvim`, clears old Neovim caches/states to prevent conflicts, creates a clean **symbolic link** (`~/.config/nvim -> repo/nvim`), and bootstraps plugins via `lazy.nvim` automatically in headless mode.

## ✨ Features & Plugins

### Core Architecture
- **Plugin Manager**: Powered by **[lazy.nvim](https://github.com/folke/lazy.nvim)** for lazy-loading and incredibly fast startup times.
- **Language**: 100% Lua configuration for better performance and maintainability.
- **Indentation**: Standardized to 2 spaces (the global standard for Lua and modern configurations).

### Key Plugins
1. **[Telescope](https://github.com/nvim-telescope/telescope.nvim)**: A highly extendable fuzzy finder over lists (files, words, recent files) with `fzf-native` and `ui-select` integration for a slick UI.
2. **[Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)**: Advanced parsing for beautiful, semantic syntax highlighting and code folding.
3. **[Mason & LSP Config](https://github.com/williamboman/mason.nvim)**: A portable package manager to seamlessly install and automatically connect Language Servers (LSP) like `lua_ls`.
4. **[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)**: The ultimate auto-completion engine with VSCode-like snippet support (`LuaSnip`), beautifully bordered windows, and multiple sources.
5. **[conform.nvim](https://github.com/stevearc/conform.nvim)**: A lightweight and powerful formatter to auto-format your code perfectly upon saving.
6. **[alpha-nvim](https://github.com/goolord/alpha-nvim)**: A beautiful, customizable startup dashboard with ASCII art and quick-access menus.

## ⌨️ Key Mappings

### General Navigation
- `Ctrl + 6` (`<C-^>`): Instantly jump back and forth between the two most recently used buffers (Alternate Buffer).

### Dashboard (alpha-nvim)
When launching Neovim without opening a file, the startup menu provides these quick keys:
- `n`: New file (`:ene`)
- `f`: Find file via Telescope
- `w`: Find Word (Live grep) via Telescope
- `r`: Recent files via Telescope
- `q`: Quit Neovim

### Auto-completion (nvim-cmp)
- `Ctrl + Space`: Manually trigger the completion menu.
- `Enter` (`<CR>`): Confirm the currently selected auto-completion item.
- `Ctrl + e`: Abort/close the completion menu.
- `Ctrl + f` / `Ctrl + b`: Scroll forward/backward through the documentation window.
