// Render-time helpers for dual-language seeded catalog content
// (web/assets/js/util/i18n-content.js). `pickLang` resolves a
// `{en, sv}` jsonb leaf against the active language; `pickLangArray`
// maps it across an array. Both treat a plain string as a transitional
// fallback so the helper is safe to land before the seed is rewritten
// (sub-task 01c).

import test from "node:test";
import assert from "node:assert/strict";

import {
  pickLang,
  pickLangArray,
} from "../../web/assets/js/util/i18n-content.js";

test("pickLang: returns the Swedish slot for sv", () => {
  assert.equal(pickLang({ en: "A", sv: "B" }, "sv"), "B");
});

test("pickLang: returns the English slot for en", () => {
  assert.equal(pickLang({ en: "A", sv: "B" }, "en"), "A");
});

test("pickLang: falls back to English when the requested locale slot is missing", () => {
  assert.equal(pickLang({ en: "A" }, "sv"), "A");
});

test("pickLang: plain string round-trips as-is (transitional fallback)", () => {
  // Before sub-task 01c rewrites the seed into {en, sv} every catalog
  // text leaf is still a single string. The helper must keep these
  // rendering verbatim so wiring views to pickLang is safe to ship
  // ahead of the schema/seed change.
  assert.equal(pickLang("plain string", "sv"), "plain string");
  assert.equal(pickLang("plain string", "en"), "plain string");
});

test("pickLang: null and undefined render as the empty string", () => {
  assert.equal(pickLang(null, "sv"), "");
  assert.equal(pickLang(undefined, "en"), "");
});

test("pickLang: a non-language object returns the empty string", () => {
  // Defensive: an unrelated object (e.g. a stray row passed by mistake)
  // must not blow up the binding — render an empty cell instead.
  assert.equal(pickLang({ foo: "bar" }, "sv"), "");
});

test("pickLangArray: maps pickLang across the array", () => {
  assert.deepEqual(
    pickLangArray(
      [
        { en: "A", sv: "B" },
        { en: "C", sv: "D" },
      ],
      "sv",
    ),
    ["B", "D"],
  );
});

test("pickLangArray: returns an empty array for null/undefined/non-array", () => {
  assert.deepEqual(pickLangArray(null, "sv"), []);
  assert.deepEqual(pickLangArray(undefined, "sv"), []);
  assert.deepEqual(pickLangArray("not-an-array", "sv"), []);
});

test("pickLangArray: preserves plain strings inside the array", () => {
  // Mixed-shape arrays appear during the 01a→01c transition window when
  // some leaves are already `{en, sv}` and others are still plain.
  assert.deepEqual(
    pickLangArray([{ en: "A", sv: "B" }, "plain", null], "sv"),
    ["B", "plain", ""],
  );
});
