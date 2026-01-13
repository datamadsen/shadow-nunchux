#!/usr/bin/env bash
#
# TPM post-install script - downloads the nunchux binary for the current platform
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
BIN_DIR="$PLUGIN_DIR/bin"

# GitHub repo
REPO="datamadsen/shadow-nunchux"

# Detect platform
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

case "$OS" in
    linux|darwin) ;;
    *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

BINARY_NAME="nunchux-${OS}-${ARCH}"

# Get latest release tag
echo "Fetching latest release from $REPO..."
LATEST_TAG=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

if [[ -z "$LATEST_TAG" ]]; then
    echo "Error: Could not fetch latest release tag"
    exit 1
fi

echo "Latest release: $LATEST_TAG"

# Download binary
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/$BINARY_NAME"
echo "Downloading $BINARY_NAME..."

mkdir -p "$BIN_DIR"
if curl -sL "$DOWNLOAD_URL" -o "$BIN_DIR/nunchux"; then
    chmod +x "$BIN_DIR/nunchux"
    echo "Installed nunchux to $BIN_DIR/nunchux"

    # Store platform for update checks
    echo "$OS-$ARCH" > "$BIN_DIR/.platform"
else
    echo "Error: Failed to download binary"
    exit 1
fi
