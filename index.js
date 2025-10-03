'use strict';

// Attempt to load the compiled native addon from the common build paths.
let binding;
try {
  binding = require('./build/Release/macos_pasteboard.node');
} catch (e1) {
  try {
    binding = require('./build/Debug/macos_pasteboard.node');
  } catch (e2) {
    const err = new Error(
      'Failed to load native addon. Did you run \"npm run build\" on macOS?\n' +
      'Original errors:\n' + e1.message + '\n' + e2.message
    );
    err.cause = { release: e1, debug: e2 };
    throw err;
  }
}

// Export a small ergonomic JS API on top of the native functions
const api = {
  readText: (pboard) => binding.readText(pboard),
  writeText: (text, pboard) => binding.writeText(String(text), pboard),
  clear: (pboard) => binding.clear(pboard),
  hasText: (pboard) => binding.hasText(pboard),
  types: (pboard) => binding.types(pboard),
  knownPasteboards: () => binding.knownPasteboards(),

  // Aliases for familiarity
  readString: (pboard) => binding.readText(pboard),
  writeString: (text, pboard) => binding.writeText(String(text), pboard)
};

module.exports = api;

