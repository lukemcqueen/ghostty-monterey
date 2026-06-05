#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────
# create-app-bundle.sh
# Wrap a compiled ghostty binary in a macOS .app
# bundle with icon, Sparkle framework, and codesign.
# ──────────────────────────────────────────────────
# MIT License
# Copyright (c) 2025 Luke McQueen
# SPDX-License-Identifier: MIT
# See LICENSE and NOTICE.md for third-party attributions.

BINARY="${1:-$HOME/src/ghostty-macos-12/zig-out/bin/ghostty}"
APP_DIR="/Applications/Ghostty.app"

if [ ! -f "$BINARY" ]; then
    echo "❌ Binary not found at: $BINARY"
    echo "   Run build.sh first, or pass the path:"
    echo "   $0 /path/to/ghostty"
    exit 1
fi

echo "📁 Creating app bundle at $APP_DIR"

# ── Create directory structure ──
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# ── Link binary ──
ln -sf "$BINARY" "$APP_DIR/Contents/MacOS/ghostty"

# ── Generate .icns icon ──
ICON_SRC="$HOME/src/ghostty-macos-12/macos/Assets.xcassets/AppIcon.appiconset"
ICONSET="/tmp/ghostty.iconset"

if [ -d "$ICON_SRC" ]; then
    echo "🎨 Generating app icon..."
    mkdir -p "$ICONSET"
    cp "$ICON_SRC/macOS-AppIcon-16px-16pt@1x.png"  "$ICONSET/icon_16x16.png" 2>/dev/null || true
    cp "$ICON_SRC/macOS-AppIcon-32px-16pt@2x.png"  "$ICONSET/icon_16x16@2x.png" 2>/dev/null || true
    cp "$ICON_SRC/macOS-AppIcon-32px-32pt@1x.png"  "$ICONSET/icon_32x32.png" 2>/dev/null || true
    cp "$ICON_SRC/macOS-AppIcon-64px-32pt@2x.png"  "$ICONSET/icon_32x32@2x.png" 2>/dev/null || true
    cp "$ICON_SRC/macOS-AppIcon-128px-128pt@1x.png" "$ICONSET/icon_128x128.png" 2>/dev/null || true
    cp "$ICON_SRC/macOS-AppIcon-256px-128pt@2x.png" "$ICONSET/icon_128x128@2x.png" 2>/dev/null || true
    cp "$ICON_SRC/macOS-AppIcon-512px.png"          "$ICONSET/icon_512x512.png" 2>/dev/null || true
    cp "$ICON_SRC/macOS-AppIcon-1024px.png"         "$ICONSET/icon_512x512@2x.png" 2>/dev/null || true
    iconutil -c icns "$ICONSET" -o "$APP_DIR/Contents/Resources/AppIcon.icns"
    rm -rf "$ICONSET"
    echo "   Icon: $APP_DIR/Contents/Resources/AppIcon.icns"
else
    echo "⚠️  Icon source not found, skipping icon generation"
fi

# ── Write Info.plist ──
cat > "$APP_DIR/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>ghostty</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.fightingdreamer.Ghostty</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Ghostty</string>
    <key>CFBundleDisplayName</key>
    <string>Ghostty</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.1.3</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSEnvironment</key>
    <dict>
        <key>GHOSTTY_MAC_APP</key>
        <string>1</string>
    </dict>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>MDItemKeywords</key>
    <string>Terminal</string>
    <key>NSServices</key>
    <array>
        <dict>
            <key>NSMenuItem</key>
            <dict>
                <key>default</key>
                <string>New Ghostty Tab Here</string>
            </dict>
            <key>NSMessage</key>
            <string>openTab</string>
            <key>NSRequiredContext</key>
            <dict>
                <key>NSTextContent</key>
                <string>FilePath</string>
            </dict>
            <key>NSSendTypes</key>
            <array>
                <string>NSFilenamesPboardType</string>
                <string>public.plain-text</string>
            </array>
        </dict>
        <dict>
            <key>NSMenuItem</key>
            <dict>
                <key>default</key>
                <string>New Ghostty Window Here</string>
            </dict>
            <key>NSMessage</key>
            <string>openWindow</string>
            <key>NSRequiredContext</key>
            <dict>
                <key>NSTextContent</key>
                <string>FilePath</string>
            </dict>
            <key>NSSendTypes</key>
            <array>
                <string>NSFilenamesPboardType</string>
                <string>public.plain-text</string>
            </array>
        </dict>
    </array>
    <key>SUEnableAutomaticChecks</key>
    <false/>
</dict>
</plist>
PLIST
echo "   Info.plist written"

# ── Bundle Sparkle.framework ──
if [ -d "/usr/local/Caskroom/sparkle" ]; then
    SPARKLE_VER=$(ls /usr/local/Caskroom/sparkle/ | sort -V | tail -1)
    SPARKLE_SRC="/usr/local/Caskroom/sparkle/$SPARKLE_VER/Sparkle.framework"
    if [ -d "$SPARKLE_SRC" ]; then
        echo "🔗 Bundling Sparkle.framework ($SPARKLE_VER)..."
        mkdir -p "$APP_DIR/Contents/Frameworks"
        cp -R "$SPARKLE_SRC" "$APP_DIR/Contents/Frameworks/Sparkle.framework"
    fi
else
    echo "⚠️  Sparkle not found. Install it: brew install sparkle"
    echo "   Then re-run this script."
fi

# ── Ad-hoc codesign ──
echo "✍️  Ad-hoc signing bundle..."
codesign --force --deep --sign - "$APP_DIR"
echo "   Signed."

# ── Register with Launch Services ──
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if [ -f "$LSREGISTER" ]; then
    "$LSREGISTER" -f "$APP_DIR" 2>/dev/null
    echo "   Registered with Launch Services."
fi

echo ""
echo "✅ Done! Ghostty is installed at:"
echo "   $APP_DIR"
echo ""
echo "Find it in Spotlight (Cmd+Space) or Launchpad."
echo ""
echo "To set up split pane keybindings, copy the config:"
echo "   curl -sSL https://raw.githubusercontent.com/lukemcqueen/ghostty-monterey/main/ghostty-config \\"
echo "     > ~/.config/ghostty/config"
