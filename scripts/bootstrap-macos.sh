#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'USAGE'
Usage: ./scripts/bootstrap-macos.sh [options]

Bootstrap this Neovim configuration on macOS.

Options:
  --install-homebrew  Install Homebrew if it is not already available.
  --no-config         Install/update prerequisites without copying the config.
  -h, --help          Show this help text.
USAGE
}

install_homebrew=0
install_config=1

while (($#)); do
  case "$1" in
    --install-homebrew)
      install_homebrew=1
      ;;
    --no-config)
      install_config=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  printf 'This bootstrap is for macOS only. Detected: %s\n' "$(uname -s)" >&2
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

if ! xcode-select -p >/dev/null 2>&1; then
  printf 'Xcode Command Line Tools are required for Git and a C compiler.\n' >&2
  printf 'Starting the Apple installer. Re-run this script after it finishes.\n' >&2
  xcode-select --install >/dev/null 2>&1 || true
  exit 1
fi

find_brew() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return 0
  fi

  local candidate
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

brew_was_on_path=0
if command -v brew >/dev/null 2>&1; then
  brew_was_on_path=1
fi

brew_bin="$(find_brew || true)"

if [[ -z "$brew_bin" ]]; then
  if ((install_homebrew == 0)); then
    cat >&2 <<'EOF_BREW'
Homebrew is required but was not found.

Install it from https://brew.sh, then re-run this script, or let this bootstrap
run the official installer:

  ./scripts/bootstrap-macos.sh --install-homebrew
EOF_BREW
    exit 1
  fi

  if ! command -v curl >/dev/null 2>&1; then
    printf 'curl is required to install Homebrew.\n' >&2
    exit 1
  fi

  printf 'Homebrew not found; running the official Homebrew installer...\n'
  /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  brew_bin="$(find_brew || true)"
  if [[ -z "$brew_bin" ]]; then
    printf 'Homebrew installation completed, but brew could not be located.\n' >&2
    printf 'Follow the post-install PATH instructions printed by Homebrew, then re-run this script.\n' >&2
    exit 1
  fi
fi

# Make Homebrew-installed binaries available to this bootstrap even when brew was
# just installed and the parent shell has not yet loaded Homebrew's shellenv.
eval "$("$brew_bin" shellenv)"

printf 'Installing macOS prerequisites with Homebrew...\n'
brew install \
  fd \
  git \
  gnu-tar \
  neovim \
  node \
  ripgrep \
  tree-sitter-cli

nvim_version_output="$(nvim --version)"
nvim_version_line="${nvim_version_output%%$'\n'*}"
nvim_version="${nvim_version_line#NVIM v}"
nvim_major="${nvim_version%%.*}"
nvim_rest="${nvim_version#*.}"
nvim_minor="${nvim_rest%%.*}"

if [[ ! "$nvim_major" =~ ^[0-9]+$ || ! "$nvim_minor" =~ ^[0-9]+$ ]]; then
  printf 'Could not parse Neovim version from: %s\n' "$nvim_version_line" >&2
  exit 1
fi

if ((nvim_major == 0 && nvim_minor < 12)); then
  printf 'Neovim 0.12 or newer is required; found %s.\n' "$nvim_version_line" >&2
  exit 1
fi

if ((install_config == 1)); then
  config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  mkdir -p "$config_home" "$data_home"
  config_home="$(cd "$config_home" && pwd -P)"
  data_home="$(cd "$data_home" && pwd -P)"
  config_dir="$config_home/nvim"
  lazy_dir="$data_home/nvim/lazy"
  stamp="$(date +%Y%m%d-%H%M%S)"

  if [[ "$repo_root" == "$config_dir" ]]; then
    printf 'Configuration is already installed at %s; leaving it in place.\n' "$config_dir"
  else
    if [[ -e "$config_dir" || -L "$config_dir" ]]; then
      backup_dir="$config_dir.backup-$stamp"
      mv "$config_dir" "$backup_dir"
      printf 'Backed up existing Neovim config to %s\n' "$backup_dir"
    fi

    mkdir -p "$config_dir"
    cp -R "$repo_root/." "$config_dir/"
    rm -rf "$config_dir/.git"
    printf 'Installed Neovim config at %s\n' "$config_dir"
  fi

  # Plugin checkouts live outside ~/.config/nvim. An older Neovim setup can
  # therefore leave incompatible or damaged repositories behind even after the
  # config itself is replaced. Move them aside and restore the exact revisions
  # committed in lazy-lock.json.
  if [[ -d "$lazy_dir" ]]; then
    lazy_backup="$data_home/nvim/lazy.backup-$stamp"
    mv "$lazy_dir" "$lazy_backup"
    printf 'Backed up existing Lazy plugin state to %s\n' "$lazy_backup"
  fi

  printf 'Restoring pinned Neovim plugins from lazy-lock.json...\n'
  nvim --headless "+Lazy! restore" +qa
fi

printf '\nBootstrap complete: %s\n' "$nvim_version_line"
printf 'Homebrew: %s\n' "$brew_bin"
printf 'tree-sitter: %s\n' "$(command -v tree-sitter)"
printf 'GNU tar: %s\n' "$(command -v gtar)"
printf '\nOpen Neovim with: nvim\n'

if ((brew_was_on_path == 0)); then
  brew_prefix="$("$brew_bin" --prefix)"
  printf 'For future shells, add Homebrew to PATH with:\n'
  printf '  eval "$(%s/bin/brew shellenv)"\n' "$brew_prefix"
fi
