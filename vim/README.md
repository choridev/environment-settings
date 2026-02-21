# My Vim Configuration

A lightweight and efficient Vim configuration (`.vimrc`) optimized for quick navigation, file management, and enhanced search capabilities.

## 🚀 Installation (Automated)

You can easily set up this configuration on any new machine using the provided automated installation script.

1. Clone this repository to your local machine:
```shell
git clone git@github.com:choridev/environment-settings.git
cd environment-settings/vim
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
> The script is **idempotent and safe**. It checks for dependencies (`curl`, `vim`), backs up any existing `.vimrc`, installs the `vim-plug` manager, creates a **symbolic link** (`~/.vimrc -> repo/.vimrc`) for real-time synchronization, and auto-installs all required plugins.

## ✨ Features & Plugins

### Basic Settings
- **Indentation**: 4 spaces (`expandtab`, `ts=4`, `sts=4`, `shiftwidth=4`).
- **Clipboard**: Synchronized with the system clipboard (optimized for macOS using `unnamed`).
- **UI**: Always shows line numbers (`nu`), the status line (`laststatus=2`), terminal window title (`title`), and highlights the current line (`cursorline`).
- **Search**: Case-insensitive search (`ignorecase`) that becomes case-sensitive if you type an uppercase letter (`smartcase`), with highlighted results (`hlsearch`).
- **Smart Cursor**: Automatically remembers and returns to your last edit position when reopening a file.

### Plugins
1. **[NERDTree](https://github.com/preservim/nerdtree)**: A file system explorer for the Vim editor.
2. **[vim-anzu](https://github.com/osyo-manga/vim-anzu)**: Adds a search status indicator (e.g., `(2/10)`) and displays it in the status line.
3. **[indentLine](https://github.com/Yggdroot/indentLine)**: Displays thin vertical lines at each indentation level for better code readability.
4. **[auto-pairs](https://github.com/jiangmiao/auto-pairs)**: Automatically inserts and formats closing brackets, parentheses, and quotes.

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

