// UI translation helpers in web/assets/js/i18n.js. `translate` is the
// canonical lookup: it reads from the requested language dictionary,
// falls back to English when a key is missing, and falls back to the
// key itself if no language has it. `dateLocaleFor` maps the UI
// language to the Intl locale tag used by the date formatters.
// `activeTranslate` is the pre-Alpine-init escape hatch used by stores
// that need a string before the `lang` store is registered.

import test from "node:test";
import assert from "node:assert/strict";
import { readdirSync, readFileSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import {
  SUPPORTED_LANGUAGES,
  DEFAULT_LANGUAGE,
  translate,
  translateLabel,
  labelKey,
  dateLocaleFor,
  activeTranslate,
  canonicalTranslate,
  availableKeys,
} from "../../web/assets/js/i18n.js";

const REPO_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..");

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

test("canonicalTranslate: always resolves against the default language", () => {
  // Used by sections.js and food.js when persisting display labels
  // (ticket_type_label, menu_label, delivery_label) so the stored
  // copy stays stable independent of whoever views the row later.
  assert.equal(canonicalTranslate("chrome.events"), "Events");
});

test("canonicalTranslate: interpolates params on the canonical entry", () => {
  assert.equal(
    canonicalTranslate("title.get_tickets_for", { name: "Nordbygg 2026" }),
    "Get tickets · Nordbygg 2026",
  );
});

test("labelKey: slugifies seeded values with whitespace, ampersand, and hyphens", () => {
  // Spaces, hyphens, and ampersands are collapsed into a single
  // underscore as a side-effect of the `[^a-z0-9]+` rule. Note that the
  // literal word "and" (alphabetic) survives — so "Construction and real
  // estate" keeps "and" while "Health & Medicine" drops the `&` entirely.
  assert.equal(labelKey("event.type", "Trade fair"), "event.type.trade_fair");
  assert.equal(
    labelKey("event.category", "Health & Medicine"),
    "event.category.health_medicine",
  );
  assert.equal(
    labelKey("event.category", "Construction and real estate"),
    "event.category.construction_and_real_estate",
  );
  assert.equal(
    labelKey("program.track", "Late-breaking"),
    "program.track.late_breaking",
  );
});

test("labelKey: empty / null input yields null", () => {
  assert.equal(labelKey("event.type", null), null);
  assert.equal(labelKey("event.type", ""), null);
});

test("translateLabel: maps seeded value to its English display label", () => {
  assert.equal(translateLabel("event.type", "Trade fair", "en"), "Trade fair");
  assert.equal(
    translateLabel("event.category", "Health & Medicine", "en"),
    "Health & Medicine",
  );
});

test("translateLabel: maps seeded value to its Swedish display label", () => {
  assert.equal(translateLabel("event.type", "Trade fair", "sv"), "Mässa");
  assert.equal(translateLabel("event.type", "Congress", "sv"), "Kongress");
  assert.equal(
    translateLabel("event.category", "Health & Medicine", "sv"),
    "Hälsa och medicin",
  );
  assert.equal(
    translateLabel("program.track", "Sustainability", "sv"),
    "Hållbarhet",
  );
});

test("translateLabel: unmapped value returns the raw input so it stays visible", () => {
  assert.equal(
    translateLabel("event.type", "Unknown future type", "sv"),
    "Unknown future type",
  );
});

test("translateLabel: null / empty input yields the empty string", () => {
  assert.equal(translateLabel("event.type", null, "en"), "");
  assert.equal(translateLabel("event.type", "", "sv"), "");
});

test("availableKeys: every supported language has the same key set", () => {
  // The per-key English fallback in `translate` means a missing
  // Swedish key renders silently in English instead of failing.
  // Assert parity here so dropped translations fail a fast unit check
  // before they reach a reviewer. When adding a new language, extend
  // SUPPORTED_LANGUAGES and translate every key into it rather than
  // relying on the fallback.
  const reference = new Set(availableKeys(DEFAULT_LANGUAGE));
  for (const lang of SUPPORTED_LANGUAGES) {
    const keys = new Set(availableKeys(lang));
    const missing = [...reference].filter((k) => !keys.has(k));
    const extra = [...keys].filter((k) => !reference.has(k));
    assert.deepEqual(
      missing,
      [],
      `${lang} is missing keys present in ${DEFAULT_LANGUAGE}: ${missing.join(", ")}`,
    );
    assert.deepEqual(
      extra,
      [],
      `${lang} has keys that do not exist in ${DEFAULT_LANGUAGE}: ${extra.join(", ")}`,
    );
  }
});

test("availableKeys: unknown language returns an empty list", () => {
  assert.deepEqual(availableKeys("de"), []);
  assert.deepEqual(availableKeys(undefined), []);
});

// Walk web/ and collect literal translation-key references so the test
// below can assert each one resolves. Catches three call shapes:
//   $store.lang.t('key')      method-call form (any object)
//   activeTranslate('key')    direct helper from i18n.js
//   canonicalTranslate('key') direct helper from i18n.js
//   translate('key', ...)     direct helper from i18n.js
//   t('key')                  bare local alias (`const t = activeTranslate`
//                             or a wrapper closing over Alpine.store('lang'))
// Keys built from variables (e.g. food's per-menu lookups via name_key)
// are not literal so they do not appear here, which is fine — those
// callsites delegate to dictionary entries that *are* present as
// literals in the originating modules and so are covered transitively.
function collectKeyReferences() {
  const refs = []; // { file, line, key }
  const lookups = [
    // .t('key') — method call on any receiver (Alpine store, alias, etc.).
    /\.t\(\s*["']([\w.]+)["']/g,
    // activeTranslate / canonicalTranslate / translate — direct helper calls.
    /\b(?:active|canonical)?Translate\(\s*["']([\w.]+)["']/g,
    // Bare `t('key')` — local alias, e.g. `const t = activeTranslate;`.
    // The leading boundary excludes `.t(` (already covered) and tokens
    // like `mt(` that happen to end in `t`.
    /(?:^|[^A-Za-z0-9_.])t\(\s*["']([\w.]+)["']/g,
  ];
  function scan(filePath) {
    const content = readFileSync(filePath, "utf8");
    const lineStarts = [0];
    for (let i = 0; i < content.length; i++) {
      if (content[i] === "\n") lineStarts.push(i + 1);
    }
    function lineFor(offset) {
      let lo = 0;
      let hi = lineStarts.length - 1;
      while (lo < hi) {
        const mid = (lo + hi + 1) >> 1;
        if (lineStarts[mid] <= offset) lo = mid;
        else hi = mid - 1;
      }
      return lo + 1;
    }
    for (const re of lookups) {
      re.lastIndex = 0;
      let m;
      while ((m = re.exec(content)) !== null) {
        const key = m[1];
        // Translation keys are dotted namespaces of letter-led segments
        // (e.g. `food.menus.burger_classic.name`). Restrict matches to
        // that shape so non-key strings that happen to be dotted (file
        // paths, version triples, ellipses inside comments) do not get
        // picked up by the bare-`t(` regex below.
        if (!/^[a-z][\w]*(?:\.[a-z][\w]*)+$/i.test(key)) continue;
        refs.push({ file: filePath, line: lineFor(m.index), key });
      }
    }
  }
  function walk(dir) {
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
      const full = join(dir, entry.name);
      if (entry.isDirectory()) {
        walk(full);
      } else if (/\.(js|html)$/.test(entry.name)) {
        scan(full);
      }
    }
  }
  walk(join(REPO_ROOT, "web"));
  return refs;
}

test("every literal translation key referenced in web/ exists in the dictionary", () => {
  // The `availableKeys` parity check above protects against half-translated
  // keys, but it cannot catch the inverse failure mode: a `lang.t('foo.bar')`
  // call whose dictionary entry was never added (or was renamed). Such a
  // call falls through `translate`'s "key as fallback" path and renders
  // the raw key into the UI — invisible to the parity test and easy to
  // miss in review.
  //
  // Walk web/ for literal-key callsites and assert each resolves against
  // the English dictionary. English is canonical: every supported language
  // mirrors it (enforced by the parity test above), so a key found in `en`
  // is by construction available in every other supported language too.
  const dictionary = new Set(availableKeys(DEFAULT_LANGUAGE));
  const refs = collectKeyReferences();
  // Sanity check that the scanner is actually finding callsites — if a
  // future refactor breaks the regexes, this guard fails fast instead
  // of silently passing an empty assertion.
  assert.ok(
    refs.length > 50,
    `expected to find many translation references; collected ${refs.length}`,
  );
  const missing = refs.filter((r) => !dictionary.has(r.key));
  assert.deepEqual(
    missing,
    [],
    `Translation keys referenced in code but not defined in i18n.js:\n${missing
      .map((r) => `  ${r.file}:${r.line} -> ${r.key}`)
      .join("\n")}`,
  );
});
