#!/usr/bin/env bash
set -Eeuo pipefail

for command in curl sha256sum tar sudo; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$command" >&2
    exit 1
  fi
done

version="0.12.4"
case "$(uname -m)" in
  x86_64)
    arch="x86_64"
    sha256="012bf3fcac5ade43914df3f174668bf64d05e049a4f032a388c027b1ebd78628"
    ;;
  aarch64|arm64)
    arch="arm64"
    sha256="ceb7e88c6b681f0515d135dcdfad54f5eb4373b25ce6172197cd9a69c758063f"
    ;;
  *)
    printf 'Unsupported architecture: %s\n' "$(uname -m)" >&2
    exit 1
    ;;
esac

archive="nvim-linux-${arch}.tar.gz"
url="https://github.com/neovim/neovim/releases/download/v${version}/${archive}"
install_dir="/opt/nvim-${version}"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

curl --fail --location --proto '=https' --tlsv1.2 \
  --output "$tmp_dir/$archive" "$url"

echo "$sha256  $tmp_dir/$archive" | sha256sum --check --status

tar --extract --gzip --file "$tmp_dir/$archive" --directory "$tmp_dir"

sudo rm -rf "$install_dir"
sudo mv "$tmp_dir/nvim-linux-${arch}" "$install_dir"
sudo ln -sfn "$install_dir/bin/nvim" /usr/local/bin/nvim

printf 'Installed %s\n' "$(nvim --version | head -n 1)"
