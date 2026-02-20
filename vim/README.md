# My Vim Configuration

A lightweight and efficient Vim configuration (`.vimrc`) optimized for quick navigation, file management, and enhanced search capabilities.

## 🚀 Installation (Automated)

You can easily set up this configuration on any new machine using the provided automated installation script.

1. Clone this repository to your local machine:
``` shell
git clone git@github.com:choridev/environment-settings.git
cd environment-settings/vim
```

2. Make the script executable:
``` shell
chmod +x install.sh
```

3. Run the installation script:
``` shell
./install.sh
```

> [!NOTE]
> The script will automatically install `vim-plug`, copy the `.vimrc` file to your home directory, and install all the required plugins in the background.

## ✨ Features & Plugins

### Basic Settings
- **Indentation**: 4 spaces (`ts=4`, `sts=4`, `shiftwidth=4`).
- **Clipboard**: Synchronized with the system clipboard (optimized for macOS using `unnamed`).
- **UI**: Always shows line numbers (`nu`), the status line (`laststatus=2`), and the terminal window title (`title`).
- **Search**: Case-insensitive search (`ignorecase`) with highlighted results (`hlsearch`).

### Plugins
1. **[NERDTree](https://github.com/preservim/nerdtree)**: A file system explorer for the Vim editor.
2. **[vim-anzu](https://github.com/osyo-manga/vim-anzu)**: Adds a search status indicator (e.g., `(2/10)`) to the bottom of the screen when navigating search results.

## ⌨️ Key Mappings

### NERDTree
- `Ctrl + n` (`<C-n>`): Toggle the NERDTree file explorer panel.
- **Auto-open**: Automatically opens NERDTree if you launch Vim without specifying a file.
- **Auto-close**: Automatically closes Vim if NERDTree is the only window left open.

### Search (vim-anzu)
Overrides default search keys to show the search status position.
- `n`: Go to the next search result (with status echo).
- `N`: Go to the previous search result (with status echo).
- `*`: Search forward for the word under the cursor (with status echo).
- `#`: Search backward for the word under the cursor (with status echo).

> [!NOTE]
> The clipboard setting is currently optimized for macOS (`set clipboard=unnamed`). If you are using Linux, you may want to change it to `set clipboard=unnamedplus` for proper clipboard integration.

