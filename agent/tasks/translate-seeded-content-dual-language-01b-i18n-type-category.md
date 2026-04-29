# Translate seeded content — 01b: i18n keys for event.type / event.category

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: see `translate-seeded-content-dual-language-01-shape-and-render-helpers.md`.
  This task can land independently of 01a and 01c — adding i18n keys
  is purely additive.

## Objective

Keep `events.type` / `events.category` (and `program_items.track` if
it surfaces in UI) as canonical English identifiers in the database
to preserve filter comparison semantics, and look up their translated
display labels via the existing static i18n map.

## Scope (do)

- Inventory every distinct value of `events.type` and
  `events.category` (and `program_items.track` if surfaced) used in
  `supabase/seed/seed.sql` and `web/data/catalog.json`. Examples
  include `trade_fair`, `congress`, `health_medicine`,
  `construction_real_estate`, etc. — confirm the actual set from the
  seed.
- For each distinct value, add an i18n key in
  `web/assets/js/i18n.js` under `event.type.*` and `event.category.*`
  (and `program.track.*` if applicable) with both `en` and `sv`
  entries. Suggested baseline translations:
  - `event.type.trade_fair`: en "Trade fair" / sv "Mässa"
  - `event.type.congress`: en "Congress" / sv "Kongress"
  - `event.category.construction_real_estate`: en "Construction and
    real estate" / sv "Bygg och fastighet"
  - `event.category.health_medicine`: en "Health & Medicine" / sv
    "Hälsa och medicin"
  - …add the rest based on the actual seed inventory.
- Update the calendar view (`web/assets/js/views/calendar.js`) and any
  other surface that displays these values to render the translated
  i18n key (e.g. via the existing `t(...)` helper) instead of the raw
  `event.type` / `event.category` string. The underlying column value
  stays the canonical English identifier — filter comparisons against
  it are unaffected.
- If any test fixture under `tests/unit/` asserts on the rendered
  English label, update it to assert through the i18n lookup.

## Validation

- `npm run test:unit` passes.
- The existing `availableKeys` parity test in
  `tests/unit/i18n.test.mjs` still passes (the new keys exist in both
  `en` and `sv` slots).
- Toggle the language flag in the running app and confirm the
  calendar event-card type/category labels render in Swedish.
- Filtering by type / category in the calendar still works (the
  filter operates on the canonical English column value, not the
  rendered label).

## Scope (do not)

- Do **not** change the database column values — they stay canonical
  English identifiers.
- Do **not** add the schema migration, the seed rewrite, or the
  pickLang helper here — those are 01a / 01c.
- Do **not** translate other seeded copy — that lands in 02–05.

## Notes

- Move this file to `agent/tasks_completed/` via `git mv` when done.
