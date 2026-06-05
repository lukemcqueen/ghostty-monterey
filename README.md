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

## Troubleshooting

### "font-family-fallback: unknown field" on first launch

The config option `font-family-fallback` does not exist in Ghostty. Fallback fonts are specified by repeating `font-family` multiple times:

```ini
# ❌ Wrong — will error
font-family-fallback = Fira Code, Menlo, monospace

# ✅ Correct
font-family = JetBrains Mono
font-family = Fira Code
font-family = Menlo
font-family = monospace
```

The config in this repo already uses the correct syntax, so the `install.sh` path is clean. If you wrote your own config, switch to repeated `font-family` lines.

### "Library not loaded: Sparkle.framework" on launch

The Ghostty binary links against Sparkle (auto-update framework) but it isn't bundled by default. The `create-app-bundle.sh` script installs Sparkle via Homebrew and copies it into the `.app`. If you see this error:

```bash
brew install sparkle
cp -R /usr/local/Caskroom/sparkle/2.9.2/Sparkle.framework /Applications/Ghostty.app/Contents/Frameworks/
codesign --force --deep --sign - /Applications/Ghostty.app
```

### Ghostty doesn't show in Spotlight / Launchpad

Run the Launch Services re-registration:

```bash
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/Ghostty.app
```

## Credits & Licensing

This project builds, packages, and configures third-party open source
software. Full license texts are in [`NOTICE.md`](NOTICE.md).

| Component | License | Author / Copyright |
|---|---|---|
| [Ghostty](https://github.com/ghostty-org/ghostty) | MIT | © 2024 Mitchell Hashimoto, Ghostty contributors |
| [fightingdreamer/ghostty](https://github.com/fightingdreamer/ghostty) (macOS 12 fork) | MIT | © 2024 Mitchell Hashimoto |
| [Sparkle](https://sparkle-project.org/) | MIT + BSD-2 | Andy Matuschak, Elgato Systems, Kornel Lesiński, Mayur Pawashe, et al. |
| [Catppuccin](https://github.com/catppuccin/ghostty) theme | MIT | © 2021 Catppuccin |
| [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono) | SIL OFL 1.1 | © 2020 JetBrains s.r.o. |

The scripts, config, and documentation in this repository are released
under the [MIT License](LICENSE).
