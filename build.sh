#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# build.sh — Clone & build Ghostty for macOS 12
# ──────────────────────────────────────────────

SRC_DIR="${1:-$HOME/src/ghostty-macos-12}"
ZIG_FLAGS="-Doptimize=ReleaseFast -Dapp-runtime=glfw -Drenderer=opengl"

echo "🔄 Building Ghostty for macOS 12 Monterey"
echo "   Source: $SRC_DIR"
echo "   Flags:  $ZIG_FLAGS"
echo ""

# Clone if needed
if [ ! -d "$SRC_DIR" ]; then
    echo "📦 Cloning fightingdreamer/ghostty (macos-12 branch)..."
    git clone --branch macos-12 https://github.com/fightingdreamer/ghostty.git "$SRC_DIR"
else
    echo "📂 Updating existing source at $SRC_DIR..."
    cd "$SRC_DIR"
    git checkout macos-12
    git pull origin macos-12
fi

# Check prerequisites
if ! command -v zig &>/dev/null; then
    echo "❌ Zig not found! Install it: brew install zig"
    echo "   Or download from: https://ziglang.org/download/0.13.0/"
    exit 1
fi

ZIG_VER=$(zig version | cut -d. -f1-2)
echo "   Zig version: $(zig version)"

# Build
cd "$SRC_DIR"
echo "🔨 Building... (this takes a few minutes)"
zig build $ZIG_FLAGS

echo ""
echo "✅ Build complete!"
echo "   Binary: $SRC_DIR/zig-out/bin/ghostty"
echo ""
echo "Next step: run create-app-bundle.sh to wrap it in an .app"
