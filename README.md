# Clean Neovim configuration

A complete Neovim 0.12 configuration built around a small, conventional plugin stack:

- transparent Vague theme, including terminal windows and floating windows;
- automatic parentheses, brackets, quotes, and completion-menu integration;
- native Neovim LSP using `vim.lsp.config()` and `vim.lsp.enable()`;
- Mason-managed language servers;
- completion with `nvim-cmp` and LuaSnip;
- Tree-sitter highlighting using `tree-sitter-manager.nvim`;
- Telescope search, Git signs, lualine, and which-key;
- Fugitive for Git commands, with Rhubarb for GitHub and GitHub Enterprise links;
- Octo for GitHub pull requests and review threads inside Neovim;
- one language registry at `lua/config/languages.lua`.

## Requirements

- Neovim **0.12 or newer**;
- Git;
- `curl` or `wget`, `unzip`, GNU `tar`, and `gzip` for Mason;
- a C compiler and the `tree-sitter` CLI for parser installation;
- Node.js and npm for language servers implemented in JavaScript;
- `ripgrep` for Telescope live grep;
- the GitHub CLI (`gh`), logged in to each GitHub host you use, for Octo;
- `fd` is recommended for faster file search;
- a clipboard provider such as `wl-clipboard` or `xclip` is optional.

A Nerd Font is optional. This config deliberately uses plain-text diagnostic and Git signs so it remains usable without one.

## Ubuntu 24.04 and 26.04

Ubuntu 24.04 ships Neovim 0.9.5, and Ubuntu 26.04 ships Neovim 0.11.6. Both are older than this config's required Neovim 0.12, so use the included pinned installer rather than `apt install neovim`.

Install prerequisites:

```bash
sudo apt update
sudo apt install -y \
  build-essential curl fd-find git gzip nodejs npm ripgrep tar unzip

# Optional clipboard integration. Pick the one matching your session.
sudo apt install -y wl-clipboard   # Wayland
# sudo apt install -y xclip        # X11

# Ubuntu calls the binary fdfind. This optional symlink exposes the usual name.
mkdir -p ~/.local/bin
ln -sfn "$(command -v fdfind)" ~/.local/bin/fd

# Required by tree-sitter-manager.nvim.
sudo npm install --global tree-sitter-cli

./scripts/install-neovim-ubuntu.sh
```

The installer downloads the official Neovim 0.12.4 tarball, verifies the published SHA-256 digest, installs it under `/opt/nvim-0.12.4`, and links `/usr/local/bin/nvim`.

## Arch Linux

Arch carries current Neovim and Tree-sitter packages directly:

```bash
sudo pacman -Syu --needed \
  base-devel curl fd git gzip neovim nodejs npm ripgrep tar tree-sitter-cli unzip

# Optional clipboard integration. Pick the one matching your session.
sudo pacman -S --needed wl-clipboard   # Wayland
# sudo pacman -S --needed xclip        # X11
```

Confirm the version:

```bash
nvim --version | head -n 1
```

It must report 0.12 or newer.

## macOS

The included bootstrap installs the Homebrew prerequisites, installs this config,
backs up any existing Lazy plugin checkout, and restores the plugin revisions from
`lazy-lock.json`:

```bash
./scripts/bootstrap-macos.sh
```

On a Mac without Homebrew:

```bash
./scripts/bootstrap-macos.sh --install-homebrew
```

## Install the configuration manually

Back up any existing config and Lazy plugin checkout, then copy this directory into
place. Keeping the plugin checkout separate from the new config prevents stale or
partially-updated plugin repositories from contaminating the install:

```bash
stamp="$(date +%Y%m%d-%H%M%S)"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
[ ! -e ~/.config/nvim ] || mv ~/.config/nvim ~/.config/nvim.backup-"$stamp"
[ ! -d "$data_home/nvim/lazy" ] || mv "$data_home/nvim/lazy" "$data_home/nvim/lazy.backup-$stamp"
mkdir -p ~/.config/nvim
cp -a . ~/.config/nvim/
```

Restore the plugin revisions committed in `lazy-lock.json`, then open Neovim:

```bash
nvim --headless "+Lazy! restore" +qa
nvim
```

On first launch:

1. `lazy.nvim` installs the plugins.
2. Mason starts installing the declared language servers.
3. Tree-sitter Manager starts installing the declared parsers.
4. Open `:Mason` and wait until the wanted servers show as installed.
5. Open `:TSManager` to inspect parser state.
6. Restart Neovim once the first installation pass completes.

This intentionally avoids a custom headless synchronization layer. Mason and Tree-sitter Manager use their own supported installation paths, which makes failures visible in their normal interfaces rather than hidden behind a bespoke command.

## C++ verification

Open a `.cpp` file, then run:

```vim
:set filetype?
:lua print(vim.fn.exepath("clangd"))
:LspInfo
```

Expected results:

- `filetype=cpp`;
- an executable path ending in `mason/bin/clangd`, or a system `clangd` path;
- `clangd` listed as attached in `:LspInfo`.

If Mason could not install it, open `:Mason`, place the cursor on `clangd`, press `i`, and read `:MasonLog` if installation fails.

## Adding a language

Edit only `lua/config/languages.lua`. For example:

```lua
zig = {
  parsers = { "zig" },
  servers = {
    zls = {},
  },
},
```

Restart Neovim. Mason installs `zls`, Neovim configures and enables it, and Tree-sitter Manager installs the Zig parser. No Mason package list or separate LSP file is required.

Use canonical Neovim LSP configuration names from `:help lspconfig-all`, such as `clangd`, `lua_ls`, and `rust_analyzer`. Mason-lspconfig translates those names to Mason package names.

## Useful commands

| Command | Purpose |
|---|---|
| `:Lazy` | Plugin manager |
| `:Lazy update` | Update plugins and refresh `lazy-lock.json` |
| `:Mason` | Inspect and install language servers |
| `:MasonUpdate` | Refresh Mason registries |
| `:LspInfo` | Inspect enabled and attached LSP clients |
| `:checkhealth vim.lsp` | Diagnose LSP configuration |
| `:checkhealth mason` | Diagnose Mason prerequisites |
| `:TSManager` | Inspect parser installation |
| `:TSUpdate` | Update installed parsers |
| `:Git` | Fugitive status window (stage, commit, push) |
| `:GBrowse` | Open the current file on GitHub |
| `:Octo` | Pick from every Octo command |
| `:checkhealth octo` | Diagnose Octo and `gh` login |

## Main key mappings

| Mapping | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>tt` | Open a bottom terminal split |
| `<leader>cm` | Open Mason |
| `gd` | LSP definition |
| `gr` | LSP references |
| `K` | LSP hover |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>lf` | LSP formatting |
| `[d` / `]d` | Previous/next diagnostic |
| `<leader>gs` | Git status (Fugitive) |
| `<leader>gd` | Diff the current file against the index |
| `<leader>go` | Open the current line, or visual selection, on GitHub |
| `<leader>gy` | Copy a GitHub link to the current line, or visual selection |
| `<leader>gp` | Open the current branch's pull request (Octo) |
| `<leader>gP` | Pick a pull request (Octo) |
| `<leader>gr` | Browse the pull request's diff and review threads (Octo) |
| `<leader>gR` | Start or resume your own review (Octo) |
| `<Esc><Esc>` in a terminal | Leave terminal mode |

## GitHub Enterprise

Rhubarb builds GitHub links for `github.com` remotes with no setup. For a GitHub Enterprise
Server, export its base URL in your shell profile:

```bash
export GITHUB_ENTERPRISE_URL="https://github.example.com"
```

Separate several servers with commas. The URL is read from the environment rather than stored
in this config so that internal hostnames stay out of the repository. Without it, `:GBrowse`
reports `no GBrowse handler installed` for Enterprise remotes.

Line links are permalinks to the most recent commit that exists on the remote, so they open
even when you have unpushed commits.

Octo talks to GitHub through `gh`, so log in to the Enterprise server once:

```bash
gh auth login --hostname github.example.com
```

When Neovim starts inside a repository whose remote is one of the `GITHUB_ENTERPRISE_URL`
servers, Octo is pointed at that server and leaves out fields only `github.com` supports. In any
other repository Octo follows the remote, so `github.com` repositories keep working. The choice is
made when Octo first loads, so restart Neovim after switching between `github.com` and Enterprise
repositories in one session.

Octo's own buffer mappings use `<localleader>`, which is also Space in this config, so inside
Octo buffers they take priority. Press `<CR>` in an Octo buffer to list its actions.

## Transparency

The theme and common UI highlight groups do not set a background colour. Neovim can therefore show the terminal emulator's background, including its configured opacity or blur.

Your terminal emulator or compositor must also have transparency enabled. Neovim cannot make an otherwise opaque terminal window transparent by itself.

## Updating safely

`lazy-lock.json` is committed with this configuration and records the exact plugin revisions tested together. After deliberately updating plugins, commit the refreshed lockfile:

```bash
git add lazy-lock.json
git commit -m "Pin Neovim plugins"
```

Use `:Lazy update` when you deliberately want to refresh those revisions.
