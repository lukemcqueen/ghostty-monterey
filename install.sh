#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# install.sh — One-shot Ghostty Monterey installer
# ──────────────────────────────────────────────
# MIT License
# Copyright (c) 2025 Luke McQueen
# SPDX-License-Identifier: MIT
# See LICENSE and NOTICE.md for third-party attributions.
#
# Clones, builds, bundles, and configures Ghostty
# for macOS 12 Monterey.
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/lukemcqueen/ghostty-monterey/main/install.sh | bash
# ──────────────────────────────────────────────

REPO="https://github.com/lukemcqueen/ghostty-monterey"
SRC_DIR="$HOME/src/ghostty-macos-12"

echo "========================================"
echo " Ghostty Monterey — macOS 12 Installer"
echo "========================================"
echo ""

# ── Step 1: Build ──
echo "🔨 Step 1/4: Building Ghostty from source..."
if ! command -v zig &>/dev/null; then
    echo "❌ Zig not found! Install it first:"
    echo "   brew install zig"
    echo "   Or: https://ziglang.org/download/0.13.0/"
    exit 1
fi

if [ ! -d "$SRC_DIR" ]; then
    echo "   Cloning fightingdreamer/ghostty (macos-12)..."
    git clone --branch macos-12 https://github.com/fightingdreamer/ghostty.git "$SRC_DIR"
else
    echo "   Updating existing source..."
    cd "$SRC_DIR" && git checkout macos-12 && git pull origin macos-12
fi

cd "$SRC_DIR"
echo "   Running zig build..."
zig build -Doptimize=ReleaseFast -Dapp-runtime=glfw -Drenderer=opengl
echo "   ✅ Build complete"

# ── Step 2: Sparkle ──
echo ""
echo "🔗 Step 2/4: Installing Sparkle framework..."
if ! brew list sparkle &>/dev/null; then
    brew install sparkle
fi
echo "   ✅ Sparkle installed"

# ── Step 3: App Bundle ──
echo ""
echo "📁 Step 3/4: Creating Ghostty.app bundle..."
# Download and run the create-app-bundle script
curl -sSL "$REPO/raw/main/create-app-bundle.sh" | bash
echo "   ✅ Bundle created"

# ── Step 4: Config ──
echo ""
echo "⚙️  Step 4/4: Installing config..."
mkdir -p "$HOME/.config/ghostty"
curl -sSL "$REPO/raw/main/ghostty-config" > "$HOME/.config/ghostty/config"
echo "   ✅ Config installed"

# ── Fix PATH ──
ln -sf /Applications/Ghostty.app/Contents/MacOS/ghostty "$HOME/.local/bin/ghostty" 2>/dev/null || true

echo ""
echo "========================================"
echo " ✅  Ghostty Monterey is ready!"
echo "========================================"
echo ""
echo "   📍  /Applications/Ghostty.app"
echo "   📍  ~/.config/ghostty/config"
echo ""
echo "   Open it from Spotlight (Cmd+Space)"
echo "   or Launchpad."
echo ""
echo "   Split panes:"
echo "     Cmd+D         — split right"
echo "     Cmd+Shift+D   — split down"
echo "     Cmd+\         — split right"
echo "     Cmd+-         — split down"
echo "========================================"
