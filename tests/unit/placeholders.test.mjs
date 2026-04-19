// SVG placeholder helpers for exhibitor logos and speaker avatars.
// The generators must be deterministic — the same name always produces
// the same initials, colour, and data URI — so cards stay visually
// stable across reloads, language switches, and re-renders.

import test from "node:test";
import assert from "node:assert/strict";

import {
  initialsFromName,
  logoDataUri,
  avatarDataUri,
} from "../../web/assets/js/util/placeholders.js";

test("initialsFromName: empty, null, or undefined input returns '?'", () => {
  assert.equal(initialsFromName(""), "?");
  assert.equal(initialsFromName(null), "?");
  assert.equal(initialsFromName(undefined), "?");
});

test("initialsFromName: whitespace-only input returns '?'", () => {
  assert.equal(initialsFromName("   "), "?");
  assert.equal(initialsFromName("\t\n"), "?");
});

test("initialsFromName: single-word name returns first two letters uppercased", () => {
  assert.equal(initialsFromName("Acme"), "AC");
  assert.equal(initialsFromName("ibm"), "IB");
});

test("initialsFromName: single-letter name yields just that letter uppercased", () => {
  assert.equal(initialsFromName("a"), "A");
});

test("initialsFromName: multi-word name uses first letter of first and last word", () => {
  assert.equal(initialsFromName("Jane Doe"), "JD");
  assert.equal(initialsFromName("Anna Maria Svensson"), "AS");
});

test("initialsFromName: trims surrounding whitespace", () => {
  assert.equal(initialsFromName("  Jane Doe  "), "JD");
});

test("initialsFromName: collapses repeated whitespace between words", () => {
  assert.equal(initialsFromName("Jane    Doe"), "JD");
});

test("initialsFromName: NFKD-normalized input drops combining diacritics (Å → A, Ö → O)", () => {
  // Stripping diacritics keeps the 1–2 char placeholder visually simple
  // and matches the deterministic color hash, which operates on the raw
  // name rather than the initials.
  assert.equal(initialsFromName("Åsa Öberg"), "AO");
  assert.equal(initialsFromName("Östen"), "OS");
});

test("initialsFromName: strips punctuation other than & and - so names like 'A&B Ltd.' still produce initials", () => {
  assert.equal(initialsFromName("A&B Ltd."), "AL");
  assert.equal(initialsFromName("!!!"), "?");
});

test("logoDataUri: returns a data:image/svg+xml URI", () => {
  const uri = logoDataUri("Nordbygg");
  assert.match(uri, /^data:image\/svg\+xml;utf8,/);
});

test("logoDataUri: renders a rounded-rect logo (contains <rect>)", () => {
  const uri = logoDataUri("Nordbygg");
  const svg = decodeURIComponent(uri.replace(/^data:image\/svg\+xml;utf8,/, ""));
  assert.match(svg, /<rect/);
  assert.doesNotMatch(svg, /<circle/);
});

test("logoDataUri: embeds the initials as rendered text", () => {
  const uri = logoDataUri("Jane Doe");
  const svg = decodeURIComponent(uri.replace(/^data:image\/svg\+xml;utf8,/, ""));
  assert.match(svg, />JD</);
});

test("logoDataUri: is deterministic for the same name", () => {
  assert.equal(logoDataUri("Acme"), logoDataUri("Acme"));
});

test("logoDataUri: empty name still yields a valid URI with a '?' placeholder", () => {
  const uri = logoDataUri("");
  const svg = decodeURIComponent(uri.replace(/^data:image\/svg\+xml;utf8,/, ""));
  assert.match(svg, />\?</);
});

test("avatarDataUri: returns a data:image/svg+xml URI", () => {
  const uri = avatarDataUri("Jane Doe");
  assert.match(uri, /^data:image\/svg\+xml;utf8,/);
});

test("avatarDataUri: renders a circular avatar (contains <circle>)", () => {
  const uri = avatarDataUri("Jane Doe");
  const svg = decodeURIComponent(uri.replace(/^data:image\/svg\+xml;utf8,/, ""));
  assert.match(svg, /<circle/);
  assert.doesNotMatch(svg, /<rect/);
});

test("avatarDataUri: embeds the initials as rendered text", () => {
  const uri = avatarDataUri("Anna Svensson");
  const svg = decodeURIComponent(uri.replace(/^data:image\/svg\+xml;utf8,/, ""));
  assert.match(svg, />AS</);
});

test("avatarDataUri: is deterministic for the same name", () => {
  assert.equal(avatarDataUri("Anna Svensson"), avatarDataUri("Anna Svensson"));
});

test("logoDataUri vs avatarDataUri: same name, different shape", () => {
  assert.notEqual(logoDataUri("Acme"), avatarDataUri("Acme"));
});
