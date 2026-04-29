# Translate seeded content — 01a: pickLang helper and view wiring

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: `translate-seeded-content-dual-language-01-shape-and-render-helpers.md`
  was further split into `-01a-helper-and-views.md` (this task),
  `-01b-i18n-type-category.md`, and `-01c-migration-and-seed.md`. The
  parent 01 task was too large for one session: a schema migration
  affecting nine tables, a new helper, wiring eight+ view files, plus
  rewriting `supabase/seed/seed.sql` (4425 lines) and
  `web/data/catalog.json` (8949 lines) into a new shape was infeasible
  to do safely in one pass. This sub-task lands the pickLang helper
  and view wiring first; because pickLang's transitional fallback
  returns plain strings as-is, this is safe to ship before the
  schema/seed change in 01c.

## Objective

Add a `pickLang(value, lang)` render-time helper that picks the
active-language variant from a `{en, sv}` jsonb leaf, and wire every
catalog render path in `web/assets/js/` to use it. Because pickLang
treats a plain string as a transitional fallback (returns it as-is),
this sub-task is safe to ship before the schema/seed change in 01c —
all catalog text continues to render unchanged after this lands.

## Decision: shape

Use **`jsonb { "en": "...", "sv": "..." }`** uniformly across catalog
text fields (the schema/seed change ships in 01c). Rationale captured
in the parent `-01-` task file.

For `events.type` / `events.category` / `program_items.track` — used
both as display labels and as canonical filter keys — the column stays
a stable English identifier and the translated label is looked up via
a small static map in `web/assets/js/i18n.js` (sub-task 01b).

## Scope (do)

- Add helper file `web/assets/js/util/i18n-content.js` exporting:
  - `pickLang(value, lang)` that:
    - returns `value[lang] ?? value.en ?? ""` if `value` is an object
      with at least one of the `SUPPORTED_LANGUAGES` keys,
    - returns `value` as-is if it is a string (transitional fallback
      for anything not yet converted),
    - returns `""` for null/undefined.
  - `pickLangArray(value, lang)` that maps `pickLang` over an array;
    returns `[]` for null/undefined/non-array.
  - `canonicalPickLang(value)` mirroring `canonicalTicketTypeLabel` in
    `web/assets/js/util/sections.js` — returns the English slot for
    persistence (used only if any place persists a denormalised label;
    verify and only export it if needed).
- Add unit test `tests/unit/i18n-content.test.mjs` asserting:
  - `pickLang({en: "A", sv: "B"}, "sv") === "B"`,
  - `pickLang({en: "A", sv: "B"}, "en") === "A"`,
  - `pickLang({en: "A"}, "sv") === "A"` (en fallback),
  - `pickLang("plain string", "sv") === "plain string"` (transitional
    fallback),
  - `pickLang(null, "sv") === ""`,
  - `pickLangArray([{en:"A",sv:"B"},{en:"C",sv:"D"}], "sv")` →
    `["B","D"]`.
- Wire every catalog render path to use `pickLang` against the active
  `lang` store. Audit and update at least:
  - `web/assets/js/stores/catalog.js` getters (`eventById`,
    `newsForEvent`, …) — return raw rows but expose helper accessors,
    OR provide a `t(field)` helper bound on the store for ergonomics.
  - `web/assets/js/views/event.js`, `food.js`, `purchase.js`,
    `points-shop.js`, `my-tickets.js`, `calendar.js`, `auth.js`,
    `me.js`, `newsletter-preferences.js`, `newsletter-signup.js` —
    every place that currently reads `event.name`, `event.summary`,
    `event.subtitle`, `news.title`, `news.body`, `article.title`,
    `article.body`, `program.title`, `program.description`,
    `program.location`, `exhibitor.description`, `addon.name`,
    `addon.description`, `merch.name`, `merch.description`,
    `venue.transport.summary`, etc.
  - `web/assets/js/util/calendar.js` (search filter), `food.js`,
    `points.js`, `sections.js` etc. — anywhere a multilingual seeded
    leaf is read.
- Each becomes `pickLang(field, $store.lang.current)` (or Alpine
  `x-text` against a getter that returns the picked value).
- Update `web/assets/js/util/sections.js`'s persisted-identity
  carve-out comment at the top to clarify that catalog content fields
  are dual-language and resolved at render time, while persisted
  display labels (`ticket_type_label`, `menu_label`,
  `delivery_label`) keep the canonical-English rule.
- Manual smoke: open the running app, the language flag toggle works
  and every catalog surface still renders English (because the seed
  is still single-string at this point — the helper's transitional
  fallback returns the string as-is).

## Validation

- `npm run test:unit` passes.
- New `i18n-content.test.mjs` covers the cases above.
- Existing tests under `tests/unit/` still pass without modification
  (they read seed strings as strings and pickLang's fallback preserves
  that). If any test reads through the new helper, prefer testing
  through the helper rather than around it.
- The `availableKeys` parity test in `tests/unit/i18n.test.mjs` still
  passes (no new top-level i18n keys yet — those land in 01b).

## Scope (do not)

- Do **not** add the schema migration or rewrite seed data in this
  task — those are 01c.
- Do **not** add `event.type.*` / `event.category.*` i18n keys — those
  are 01b.
- Do **not** translate any seeded copy — translations are 02–05.
- Do **not** touch the persisted-identity strings (`Guest` fallback,
  simulated-social-sign-in labels).

## Notes

- The helper must read the active language from the existing
  `web/assets/js/stores/lang.js` store (probably `$store.lang.current`
  or similar — verify the actual API before wiring).
- Keep the helper pure (no Alpine imports). Views import it directly
  and pass `$store.lang.current` at the call site.
- Move this file to `agent/tasks_completed/` via `git mv` when done.
