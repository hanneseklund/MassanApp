# Translate seeded content — 01: shape, schema, render helpers

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: `translate-seeded-content-dual-language.md` was split into
  this task plus `-02-translate-events-and-venue.md`,
  `-03-translate-news-articles-program-speakers.md`,
  `-04-translate-exhibitors.md`, and
  `-05-translate-addons-and-merchandise.md` because the schema/shape
  decision and render-helper wiring must land before any seed data is
  rewritten in the new shape.

## Objective

Pick the canonical shape for dual-language seed fields, ship a migration
that converts the affected columns / jsonb leaves to that shape, and add
the render-time helper that picks the active-language variant. After
this task lands, every catalog text field still renders English (because
the conversion duplicates the existing string into both `en` and `sv`),
but the rendering pipeline is ready to surface real Swedish translations
as soon as sub-tasks 02–05 backfill them.

## Decision: shape

Use **`jsonb { "en": "...", "sv": "..." }`** uniformly across catalog
text fields. Rationale:

- The schema already uses jsonb extensively (`branding`, `overrides`,
  `address`, `transport`, `parking`, `restaurants`, `security`, `maps`).
  Wrapping leaf strings in `{en, sv}` keeps a single composable shape
  and avoids doubling column counts.
- Aligns with the existing `availableKeys` parity test idea — every
  user-facing string carries the same set of language keys.
- Cleaner than `name_en` / `name_sv` parallel columns, especially for
  tables that will gain more languages later.

Arrays of plain strings (e.g. `events.questionnaire_subjects`,
`venues.security.general_rules`) become arrays of `{en, sv}` objects.

For `events.type` and `events.category` — used both as display labels
and as canonical filter keys — keep the column as a stable English
identifier and look up the translated label via a small static map in
`web/assets/js/i18n.js` (similar to existing `ticket_types.*` and
`food.themes.*` keys). This preserves filter comparison semantics.
The same applies to `program_items.track` if it surfaces in UI.

## Scope (do)

- Add migration `supabase/migrations/0007_dual_language_catalog.sql`
  that converts the following columns to jsonb `{en, sv}` (or, for
  already-jsonb columns, rewrites their string leaves):
  - `public.events`: `name`, `subtitle`, `summary`,
    `branding.hero_image_credit`,
    `overrides.{entrance,bag_rules,access_notes}`,
    `questionnaire_subjects` (array of strings → array of objects)
  - `public.news_items`: `title`, `body`
  - `public.articles`: `title`, `body`
  - `public.speakers`: `bio`, `affiliation` (`name` is a person and
    stays a single string)
  - `public.program_items`: `title`, `description`, `location`
    (track stays as a canonical key, like `type`/`category`)
  - `public.exhibitors`: `description` (company `name` stays single)
  - `public.point_addons`: `name`, `description`
  - `public.merchandise`: `name`, `description`
  - `public.venues`: rewrite jsonb leaves under `transport.summary`,
    `transport.modes[].mode`, `transport.modes[].detail`,
    `parking.summary`, `parking.notes`, `restaurants[].name`,
    `restaurants[].description`, `security.summary`,
    `security.general_rules[]`, `sustainability` (top-level text →
    jsonb), `maps[].name`, `maps[].description`
- Choose `text` columns that are simple and few (e.g.
  `news_items.title`, `articles.title`, `point_addons.name`) and
  convert with `alter table … alter column … type jsonb using
  jsonb_build_object('en', value, 'sv', value)`. For top-level `text`
  columns that need to become jsonb, drop any check constraints first
  if relevant.
- Apply the migration to the shared Supabase project via
  `mcp__claude_ai_Supabase__apply_migration`.
- Add a helper `pickLang(value, lang)` in
  `web/assets/js/util/i18n-content.js` (new file) that:
  - returns `value[lang] ?? value.en ?? ""` if `value` is an object
    with at least one of the `SUPPORTED_LANGUAGES` keys,
  - returns `value` as-is if it is a string (transitional fallback for
    anything not yet converted),
  - returns `""` for null/undefined.
  Add a sibling `pickLangArray(value, lang)` for arrays of `{en, sv}`
  objects.
- Wire every catalog render path to use `pickLang` against the active
  `lang` store, including:
  - `web/assets/js/stores/catalog.js` getters (`eventById`,
    `newsForEvent`, …) — return raw rows but expose helper accessors,
    OR provide a `t(field)` helper bound on the store for ergonomics.
  - `web/assets/js/views/event.js`, `food.js`, `purchase.js`,
    `points-shop.js`, `my-tickets.js`, `calendar.js`, `auth.js` —
    every place that currently reads `event.name`, `event.summary`,
    `news.title`, `news.body`, `article.title`, `article.body`,
    `program.title`, `program.description`, `program.location`,
    `exhibitor.description`, `addon.name`, `addon.description`,
    `merch.name`, `merch.description`, `venue.transport.summary`,
    etc. Each becomes `pickLang(field, $store.lang.current)` (or
    Alpine `x-text` against a getter that returns the picked value).
  - `web/assets/js/util/sections.js` — the existing
    `canonicalTicketTypeLabel` already persists English; mirror that
    pattern with a `canonicalPickLang(value)` exported alongside
    `pickLang` for places that persist a label (e.g. ticket
    `event_name` denormalised on `tickets.event_name` if any — verify;
    otherwise no change needed).
- Add i18n keys for every `events.type` and `events.category` value
  observed in the seed (e.g. `event.type.trade_fair`,
  `event.category.health_medicine`, …) in `web/assets/js/i18n.js`,
  with both `en` and `sv` entries. Update the calendar view to render
  these keys instead of the raw `event.type` / `event.category`
  strings, but keep the underlying column values as the English
  canonical strings for filter comparison.
- Update `supabase/seed/seed.sql` and `web/data/catalog.json` so that
  every multilingual field is written in the new shape. For this
  task, fill both `en` and `sv` slots with the **existing seeded
  copy** (i.e. duplicate). Real translations land in sub-tasks 02–05.
  The duplicate-fill is intentional: it lets us land the schema +
  render-helper change without a half-rendered app, and it makes the
  translation diffs in 02–05 small and reviewable.
- Apply the rewritten seed to the shared project via
  `mcp__claude_ai_Supabase__execute_sql` and verify with a couple of
  spot-check `select` queries (e.g. `select name->'en', name->'sv'
  from events where id = 'nordbygg-2026'`).
- Update the persisted-identity carve-out comment at the top of
  `web/assets/js/util/sections.js` to clarify that catalog content
  fields are now dual-language and resolved at render time, while
  persisted display labels (`ticket_type_label`, `menu_label`,
  `delivery_label`) keep the canonical-English rule.
- Update `docs/functional-specification.md` §"Accessibility and
  internationalization (baseline)" to remove the catalog-content
  carve-out (the paragraph that says event content "stays in the
  language it was seeded in"). Replace with a description of the new
  rule: every user-facing seeded field is dual-language and renders
  in the active UI language; only persisted display labels keep
  their canonical-English rule.
- Update `docs/implementation-specification.md` (or wherever the seed
  shape is documented) to describe the `{en, sv}` shape and the
  `pickLang` helper.

## Validation

- `npm run test:unit` passes.
- New unit test in `tests/unit/` asserts:
  - `pickLang({en: "A", sv: "B"}, "sv") === "B"`,
  - `pickLang({en: "A", sv: "B"}, "en") === "A"`,
  - `pickLang({en: "A"}, "sv") === "A"` (en fallback),
  - `pickLang("plain string", "sv") === "plain string"` (transitional
    fallback),
  - `pickLang(null, "sv") === ""`.
- Existing `availableKeys` parity test still passes.
- Manually toggle the language flag in the running app: every catalog
  surface keeps rendering (English text in both languages is fine for
  this sub-task — sub-tasks 02–05 backfill Swedish copy).

## Scope (do not)

- Do **not** translate any seeded copy in this task. Both language
  slots carry the same English source string.
- Do **not** touch the persisted-identity strings (`Guest` fallback,
  simulated-social-sign-in labels) — the user has explicitly scoped
  those out.
- Do **not** add new languages beyond `en` and `sv`.

## Notes

- Keep the migration idempotent (`alter column … type jsonb using …`
  is safe to re-run if you guard with a `case when` on the existing
  shape, or simply rely on Postgres behaviour). Document the chosen
  approach in the migration's header comment.
- If any test fixture under `tests/` hard-codes English seeded
  strings, update it to call `pickLang` or read the `.en` slot.
- When this sub-task lands, post a single milestone comment on issue
  #27 announcing that the dual-language seed shape is in place and
  that translations follow in sub-tasks 02–05.
- Move this file to `agent/tasks_completed/` via `git mv` when done.
