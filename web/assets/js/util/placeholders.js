// Deterministic SVG placeholders for prototype content that has no
// real image source. Used for exhibitor logos and speaker avatars,
// which are simulated in the seed data and have no real logo or photo
// to scrape. The same name always renders the same color and initials
// so cards stay visually stable across reloads and languages.
//
// Real `logo` or `avatar` values in the catalog take precedence; the
// view helpers only fall back to these generators when the catalog
// field is empty.

const PALETTE = [
  "#0b3d91", "#8a1f57", "#123f66", "#004e42", "#00549a",
  "#b35b1c", "#5c2a2a", "#1c4d8f", "#006eb6", "#c41e3a",
  "#4a5d7e", "#6bae3e", "#004a94", "#002147", "#8b1a1a",
];

function hashString(str) {
  let h = 0;
  for (let i = 0; i < str.length; i++) {
    h = (h * 31 + str.charCodeAt(i)) | 0;
  }
  return Math.abs(h);
}

export function initialsFromName(name) {
  if (!name) return "?";
  const parts = name
    .normalize("NFKD")
    .replace(/[^\p{L}\p{N} &-]/gu, "")
    .trim()
    .split(/\s+/)
    .filter(Boolean);
  if (parts.length === 0) return "?";
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

function colorForName(name) {
  return PALETTE[hashString(name || "") % PALETTE.length];
}

function svgDataUri(svg) {
  return "data:image/svg+xml;utf8," + encodeURIComponent(svg);
}

export function logoDataUri(name) {
  const initials = initialsFromName(name);
  const bg = colorForName(name);
  const svg =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">` +
    `<rect width="64" height="64" rx="8" fill="${bg}"/>` +
    `<text x="50%" y="50%" dy=".1em" fill="#ffffff" font-family="Inter, sans-serif" ` +
    `font-size="26" font-weight="600" text-anchor="middle" dominant-baseline="middle">${initials}</text>` +
    `</svg>`;
  return svgDataUri(svg);
}

export function avatarDataUri(name) {
  const initials = initialsFromName(name);
  const bg = colorForName(name);
  const svg =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">` +
    `<circle cx="32" cy="32" r="32" fill="${bg}"/>` +
    `<text x="50%" y="50%" dy=".1em" fill="#ffffff" font-family="Inter, sans-serif" ` +
    `font-size="24" font-weight="600" text-anchor="middle" dominant-baseline="middle">${initials}</text>` +
    `</svg>`;
  return svgDataUri(svg);
}
