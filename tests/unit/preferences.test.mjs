// Newsletter preference normalization. Missing keys must default to
// true so existing database rows keep rendering when a new topic is
// added later. Extra unrecognized keys are dropped.

import test from "node:test";
import assert from "node:assert/strict";

import {
  NEWSLETTER_PREF_KEYS,
  defaultNewsletterPreferences,
  normalizeNewsletterPreferences,
} from "../../web/assets/js/newsletter/preferences.js";

test("defaultNewsletterPreferences: every key defaults to true", () => {
  const out = defaultNewsletterPreferences();
  for (const key of NEWSLETTER_PREF_KEYS) {
    assert.equal(out[key], true, `${key} defaults to true`);
  }
});

test("normalizeNewsletterPreferences: missing keys take the default (true)", () => {
  const out = normalizeNewsletterPreferences({ news: false });
  assert.equal(out.news, false);
  assert.equal(out.program_highlights, true);
  assert.equal(out.exhibitor_updates, true);
});

test("normalizeNewsletterPreferences: explicit false stays false", () => {
  const out = normalizeNewsletterPreferences({
    program_highlights: false,
    news: false,
    exhibitor_updates: false,
  });
  for (const key of NEWSLETTER_PREF_KEYS) {
    assert.equal(out[key], false);
  }
});

test("normalizeNewsletterPreferences: null input returns the default shape", () => {
  assert.deepEqual(
    normalizeNewsletterPreferences(null),
    defaultNewsletterPreferences(),
  );
  assert.deepEqual(
    normalizeNewsletterPreferences(undefined),
    defaultNewsletterPreferences(),
  );
});

test("normalizeNewsletterPreferences: unknown keys are dropped", () => {
  const out = normalizeNewsletterPreferences({
    news: false,
    not_a_real_topic: true,
  });
  assert.equal("not_a_real_topic" in out, false);
});

test("normalizeNewsletterPreferences: coerces truthy/falsy values to bool", () => {
  const out = normalizeNewsletterPreferences({
    program_highlights: 1,
    news: 0,
    exhibitor_updates: "yes",
  });
  assert.equal(out.program_highlights, true);
  assert.equal(out.news, false);
  assert.equal(out.exhibitor_updates, true);
});
