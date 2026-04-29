// Render-time helpers for dual-language seeded catalog content.
//
// Catalog text fields (event names, news bodies, exhibitor descriptions,
// venue copy, …) are stored as `jsonb { en, sv }` after the schema
// rewrite in sub-task 01c. `pickLang` resolves a value of that shape
// against the active UI language and treats a plain string as a
// transitional fallback (returns it as-is) so this helper is safe to
// land before the schema/seed rewrite.
//
// Persisted display labels (`ticket_type_label`, `menu_label`,
// `delivery_label`) intentionally keep their canonical-English rule via
// `canonicalTranslate` in i18n.js — see the carve-out comment at the
// top of util/sections.js.
//
// Pure module: no Alpine import, no globals. Views import `pickLang`
// directly and pass `$store.lang.current` at the call site, or read
// through the `pick` getter on the lang store for ergonomic
// `x-text="$store.lang.pick(event.name)"` bindings.

import { SUPPORTED_LANGUAGES, DEFAULT_LANGUAGE } from "../i18n.js";

function isLangBag(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) return false;
  for (const key of SUPPORTED_LANGUAGES) {
    if (Object.prototype.hasOwnProperty.call(value, key)) return true;
  }
  return false;
}

// Resolve a multilingual seeded leaf to a string in `lang`.
// Object input: returns `value[lang]`, falling back to the English slot,
//   then to the empty string.
// String input: returned as-is so callsites work during the transitional
//   window before the seed has been rewritten into `{ en, sv }`.
// Null/undefined: empty string so x-text bindings render a blank cell
//   instead of "undefined".
export function pickLang(value, lang) {
  if (value == null) return "";
  if (typeof value === "string") return value;
  if (isLangBag(value)) {
    return value[lang] ?? value[DEFAULT_LANGUAGE] ?? "";
  }
  return "";
}

export function pickLangArray(value, lang) {
  if (!Array.isArray(value)) return [];
  return value.map((entry) => pickLang(entry, lang));
}
