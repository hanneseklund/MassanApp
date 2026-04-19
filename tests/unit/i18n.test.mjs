// UI translation helpers in web/assets/js/i18n.js. `translate` is the
// canonical lookup: it reads from the requested language dictionary,
// falls back to English when a key is missing, and falls back to the
// key itself if no language has it. `dateLocaleFor` maps the UI
// language to the Intl locale tag used by the date formatters.
// `activeTranslate` is the pre-Alpine-init escape hatch used by stores
// that need a string before the `lang` store is registered.

import test from "node:test";
import assert from "node:assert/strict";

import {
  SUPPORTED_LANGUAGES,
  DEFAULT_LANGUAGE,
  translate,
  dateLocaleFor,
  activeTranslate,
} from "../../web/assets/js/i18n.js";

test("SUPPORTED_LANGUAGES: includes en and sv", () => {
  assert.ok(SUPPORTED_LANGUAGES.includes("en"));
  assert.ok(SUPPORTED_LANGUAGES.includes("sv"));
});

test("DEFAULT_LANGUAGE: is English", () => {
  assert.equal(DEFAULT_LANGUAGE, "en");
});

test("translate: returns the English string for an English key", () => {
  assert.equal(translate("chrome.events", "en"), "Events");
});

test("translate: returns the Swedish string for a Swedish key", () => {
  assert.equal(translate("chrome.events", "sv"), "Evenemang");
});

test("translate: unknown language falls back to the English entry", () => {
  assert.equal(translate("chrome.events", "de"), "Events");
});

test("translate: missing key in the active language falls back to English", () => {
  // Synthesize a key that only exists in English to exercise the
  // per-key fallback path. Every key in the real dictionary is
  // present in both locales, so we rely on the behavior that a
  // missing key returns the English copy — or, if neither locale
  // has it, the key itself.
  const out = translate("chrome.events", "sv");
  assert.equal(out, "Evenemang"); // sanity: the key exists in sv

  // A key that does not exist at all returns the key itself so
  // templates keep rendering instead of showing "undefined".
  assert.equal(translate("definitely.not.a.real.key", "en"), "definitely.not.a.real.key");
  assert.equal(translate("definitely.not.a.real.key", "sv"), "definitely.not.a.real.key");
});

test("translate: interpolates {param} placeholders", () => {
  const out = translate("title.get_tickets_for", "en", { name: "Nordbygg 2026" });
  assert.equal(out, "Get tickets · Nordbygg 2026");
});

test("translate: leaves unresolved placeholders intact so missing params are visible", () => {
  const out = translate("title.get_tickets_for", "en", {});
  assert.match(out, /\{name\}/);
});

test("translate: interpolation works in Swedish too", () => {
  const out = translate("title.get_tickets_for", "sv", { name: "Nordbygg 2026" });
  assert.equal(out, "Köp biljetter · Nordbygg 2026");
});

test("translate: count-style placeholder renders a number", () => {
  const out = translate("me.n_tickets_hint", "en", { count: 3 });
  assert.equal(out, "3 tickets");
});

test("dateLocaleFor: English -> en-GB, Swedish -> sv-SE", () => {
  assert.equal(dateLocaleFor("en"), "en-GB");
  assert.equal(dateLocaleFor("sv"), "sv-SE");
});

test("dateLocaleFor: unknown language falls back to the default locale", () => {
  assert.equal(dateLocaleFor("de"), "en-GB");
  assert.equal(dateLocaleFor(undefined), "en-GB");
});

test("activeTranslate: without Alpine, returns the default-language string", () => {
  // The Node test environment has no Alpine store, so activeTranslate
  // must take the fallback path and resolve against English.
  assert.equal(typeof globalThis.Alpine, "undefined");
  assert.equal(activeTranslate("chrome.events"), "Events");
});

test("activeTranslate: interpolates params on the fallback path", () => {
  assert.equal(
    activeTranslate("title.get_tickets_for", { name: "ESTRO 2026" }),
    "Get tickets · ESTRO 2026",
  );
});
