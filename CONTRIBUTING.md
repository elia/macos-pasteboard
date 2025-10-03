# Contributing

Thanks for your interest in improving macos-pasteboard! This guide covers how to build, install, and debug the native addon locally on macOS.

## Prerequisites
- macOS (10.13+ target; modern macOS recommended)
- Xcode Command Line Tools: `xcode-select --install`
- Node.js 16+ (18+ recommended)
- Python 3 (for `node-gyp`)

Check your setup:
```
xcodebuild -version
node -v
node -p "process.arch"   # arm64 or x64
uname -m                  # Apple Silicon: arm64; Intel: x86_64
```

## Install dependencies
```
npm install
```

## Build
- Release build (default):
```
npm run build
```
- Debug build (easier to step through with LLDB):
```
npm_config_debug=1 npm run build
# or
npx node-gyp configure build --debug
```

Build outputs:
- `build/Release/macos_pasteboard.node`
- `build/Debug/macos_pasteboard.node`

## Quick test
```
node examples/smoke.js
```

## Use in another local project
- Using `npm link`:
```
# In this repo
npm link
# In your other project
npm link macos-pasteboard
```
- Using a packed tarball:
```
npm pack
# Note the generated .tgz filename, then in your other project:
npm i ../macos-pasteboard-<version>.tgz
```

## Development workflow
- Edit native code in `src/addon.mm`, JS in `index.js`, types in `types/`.
- Rebuild after native changes: `npm run build` (or debug variant).
- Re-run your script/app to load the new binary.

Clean rebuild:
```
npx node-gyp clean
rm -rf build
npm run build
```

## Debugging
- Run under LLDB:
```
lldb -- node examples/smoke.js
(lldb) run
# Set breakpoints e.g.
(lldb) breakpoint set --file addon.mm --name ReadText
```
- Add temporary logging in native code with `NSLog(@"...")` or `fprintf(stderr, ...)`.
- For JavaScript side, use `console.log` and try/catch around API calls.

## Architecture (arm64 vs x64)
The addon must match the architecture of the Node process that loads it.
- Check Node arch: `node -p process.arch` (arm64 or x64)
- On Apple Silicon, avoid Rosetta mismatch. If your Node is x64 (Rosetta), either switch to an arm64 Node or build the addon under x64:
```
# Force an x64 build if you intentionally use x64 Node via Rosetta
arch -x86_64 npx node-gyp rebuild
```
If you switch Node versions/arch, run `npm rebuild` or `npm run build` again.

## Troubleshooting
- “Failed to load native addon. Did you run npm run build on macOS?”
  - Ensure you ran `npm run build` successfully and the `.node` binary exists in `build/Release/` or `build/Debug/`.
- “no suitable image found / wrong architecture”
  - Node and the built addon architectures must match (see Architecture section).
- Permission prompts when reading pasteboard
  - Newer macOS versions may prompt for clipboard access the first time.

## Project structure
- `src/addon.mm` — Objective‑C++ N-API bridge to `NSPasteboard`
- `binding.gyp` — node-gyp build config (links `AppKit`)
- `index.js` — JS loader + ergonomic API
- `types/` — TypeScript declarations
- `examples/` — Example scripts

## Code style
- Keep native surface area small and focused; prefer explicit argument validation and clear return values.
- Avoid exceptions in native code (we compile with `NAPI_DISABLE_CPP_EXCEPTIONS`).

## Releasing
- Pre-flight: ensure docs/types are current and a clean build passes
  - `npm ci`
  - `npm run build`
  - `node examples/smoke.js`
- Version: bump with npm to create a tag and changelog-friendly commit message
  - `npm version patch` (or `minor`/`major`)
  - This updates `package.json`, creates a git commit and tag.
- Publish (from macOS): `prepack` runs a native build that links AppKit, so publish on macOS
  - Optional preview: `npm publish --dry-run`
  - Publish: `npm publish --access public`
- Push: `git push && git push --tags`
- Verify from a clean project
  - `mkdir -p /tmp/pbtest && cd /tmp/pbtest && npm init -y`
  - `npm i macos-pasteboard`
  - `node -e "console.log(require('macos-pasteboard').knownPasteboards())"`
- Notes
  - Ensure you’re logged in: `npm whoami` (and 2FA if enabled).
  - Our package is `os: ["darwin"]`; installs on non-macOS will be blocked.
  - We do not ship prebuilt binaries; users build locally via node-gyp on install.

Thanks again for contributing!
