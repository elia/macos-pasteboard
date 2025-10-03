# macos-pasteboard

Native macOS pasteboard (clipboard) access for Node.js using N-API.

- Supports alternative pasteboards, e.g. the "find" pasteboard.
- Simple JS API; no app/window required.
- Works similarly to `pbcopy`/`pbpaste` for text.

Note: This package only targets macOS.

## Install

```
npm install
npm run build
```

Requirements: Xcode command line tools and Python for `node-gyp`.

## Usage

```js
const pb = require('macos-pasteboard');

// General pasteboard (default)
pb.writeText('Hello from Node!');
console.log(pb.readText()); // => 'Hello from Node!'

// Alternative pasteboard: "find"
pb.writeText('search-term', 'find');
console.log(pb.readText('find')); // => 'search-term'

// Inspect types and state
console.log(pb.hasText()); // => true/false
console.log(pb.types());   // => array of UTI/type identifiers

// Known pasteboards (friendly names -> underlying system names)
console.log(pb.knownPasteboards());
```

API
- `readText(pboard?) => string | null`
- `writeText(text, pboard?) => boolean`
- `clear(pboard?) => boolean`
- `hasText(pboard?) => boolean`
- `types(pboard?) => string[]`
- `knownPasteboards() => { general, find, font, ruler, drag }`

`pboard` can be one of: `general` (default), `find`, `font`, `ruler`, `drag`, or a custom named pasteboard.

## CLI parity with pbcopy/pbpaste
This library intentionally focuses on a JS API. If you need a CLI, you can create a tiny wrapper using these APIs, or continue using `pbcopy`/`pbpaste` with the `-pboard` flag.

## Notes
- On recent macOS versions, reading the pasteboard may be subject to privacy prompts or app permissions.
- The module uses Objective‑C++ and links against `AppKit`.

## License
MIT
