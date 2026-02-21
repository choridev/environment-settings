# My Git Configuration

A secure and modular Git configuration (`.gitconfig`) optimized for SSH commit signing, better logging, and separating personal credentials from public dotfiles.

## 🚀 Installation (Automated)

You can easily set up this configuration on any new machine using the provided automated installation script.

1. Clone this repository to your local machine:
```shell
git clone git@github.com:choridev/environment-settings.git
cd environment-settings/git
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
> The script is **idempotent and safe**. It backs up any existing `.gitconfig`, creates a **symbolic link** (`~/.gitconfig -> repo/.gitconfig`), and interactively sets up your personal credentials in a separate, secure file.

## 🔒 Security & Credential Management (The `[include]` Magic)

To keep personal information (like email and SSH keys) out of this public repository, the main `.gitconfig` uses the `[include]` directive to load a local file: `~/.gitconfig.local`.

During the installation script, you will be prompted to enter:
1. **Git Name**
2. **Git Email**
3. **SSH Signing Key Path** *(Defaults to `~/.ssh/id_ed25519.pub` if you just press Enter)*

> [!IMPORTANT]  
> The `~/.gitconfig.local` file is strictly for your local machine. **Do not commit this file to any public repository**, as it contains your personal signature identities.

## ✨ Features & Settings

### Core Settings
- **Default Editor**: Set to `vim` for seamless commit message editing.
- **Auto Prune**: Automatically removes remote-tracking references that no longer exist on the remote when fetching (`fetch.prune = true`).
- **Default Branch**: Sets `main` as the default branch name when initializing new repositories.

### Commit Signing
- **SSH GPG Signing**: Configured to sign commits using SSH keys instead of traditional GPG keys (`gpgsign = true`, `gpg.format = ssh`).

### Aliases
- `git lg`: A highly customized, colorful, and graph-based Git log. It displays the commit hash, branch indicators, commit message, relative time, and author name in a beautiful one-line format.

