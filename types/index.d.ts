export type PasteboardName = 'general' | 'find' | 'font' | 'ruler' | 'drag' | string;

export function readText(pboard?: PasteboardName): string | null;
export function writeText(text: string, pboard?: PasteboardName): boolean;
export function clear(pboard?: PasteboardName): boolean;
export function hasText(pboard?: PasteboardName): boolean;
export function types(pboard?: PasteboardName): string[];
export function knownPasteboards(): {
  general: string;
  find: string;
  font: string;
  ruler: string;
  drag: string;
};

// Aliases
export function readString(pboard?: PasteboardName): string | null;
export function writeString(text: string, pboard?: PasteboardName): boolean;

declare const _default: {
  readText: typeof readText;
  writeText: typeof writeText;
  clear: typeof clear;
  hasText: typeof hasText;
  types: typeof types;
  knownPasteboards: typeof knownPasteboards;
  readString: typeof readString;
  writeString: typeof writeString;
};

export default _default;
