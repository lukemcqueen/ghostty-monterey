# Ghostty Monterey 🐢

**Ghostty terminal emulator — built for macOS 12 Monterey.**

The latest Ghostty releases require macOS 13+, but [@fightingdreamer](https://github.com/fightingdreamer/ghostty) maintains a `macos-12` branch that runs on Monterey. This repo provides:

- **`build.sh`** — clones and compiles Ghostty for macOS 12 with GLFW+OpenGL
- **`create-app-bundle.sh`** — wraps the binary in a proper `.app` bundle with icon, Sparkle framework, and codesigning
- **`install.sh`** — does it all in one shot
- **`ghostty-config`** — a ready-to-use config with split panes, Catppuccin theme, and JetBrains Mono

## Quick Install

```bash
curl -sSL https://raw.githubusercontent.com/lukemcqueen/ghostty-monterey/main/install.sh | bash
```

Then find **Ghostty** in Spotlight (Cmd+Space) or Launchpad.

## What You Get

| | |
|---|---|
| **Ghostty** | v1.1.3-macos-12, built with GLFW + OpenGL |
| **Sparkle** | Auto-update framework bundled and ad-hoc signed |
| **App Icon** | Official Ghostty icon at full resolution |
| **Finder Services** | Right-click a folder → "New Ghostty Window Here" / "New Ghostty Tab Here" |
| **Split Panes** | Cmd+D (right), Cmd+Shift+D (down), Cmd+\ (right), Cmd+- (down) |
| **Split Navigation** | Cmd+Alt+arrows to move, Cmd+Ctrl+arrows to resize |

## Manual Build

```bash
# 1. Clone and build
git clone --branch macos-12 https://github.com/fightingdreamer/ghostty.git
cd ghostty
zig build -Doptimize=ReleaseFast -Dapp-runtime=glfw -Drenderer=opengl

# 2. Create the app bundle
./create-app-bundle.sh

# 3. Copy the config
cp ghostty-config ~/.config/ghostty/config
```

### Prerequisites

- **Zig 0.13.0** — `brew install zig` or download from [ziglang.org](https://ziglang.org/download/0.13.0/)
- **Xcode Command Line Tools** — `xcode-select --install`

### Build Flags

| Flag | Why |
|---|---|
| `-Dapp-runtime=glfw` | Uses GLFW instead of Metal/Cocoa (required for macOS 12) |
| `-Drenderer=opengl` | OpenGL renderer (Metal unavailable on older GPUs) |
| `-Doptimize=ReleaseFast` | Optimised binary |

## Split Pane Keybindings

| Shortcut | Action |
|---|---|
| `Cmd + D` | Split right |
| `Cmd + Shift + D` | Split down |
| `Cmd + \` | Split right (visual) |
| `Cmd + -` | Split down (visual) |
| `Cmd + Alt + ←↑→↓` | Navigate splits |
| `Cmd + Ctrl + ←↑→↓` | Resize splits (10px) |
| `Cmd + Shift + Enter` | Toggle split zoom |
| `Cmd + Ctrl + =` | Equalize all splits |

## Credits

- [Ghostty](https://github.com/ghostty-org/ghostty) by Mitchell Hashimoto
- [@fightingdreamer](https://github.com/fightingdreamer/ghostty) for the macOS 12 port
