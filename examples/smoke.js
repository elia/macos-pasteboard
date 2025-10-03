'use strict';

const pb = require('..');

const tag = `[${Date.now()}]`;

console.log('Known pasteboards:', pb.knownPasteboards());

console.log('Write general...');
pb.writeText(`hello general ${tag}`);
console.log('Read general:', pb.readText());

console.log('Write find...');
pb.writeText(`hello find ${tag}`,'find');
console.log('Read find:', pb.readText('find'));

console.log('Has text (general):', pb.hasText());
console.log('Types (general):', pb.types());

