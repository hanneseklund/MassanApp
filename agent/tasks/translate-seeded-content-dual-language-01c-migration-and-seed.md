# Translate seeded content — 01c: schema migration and seed rewrite

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: see `translate-seeded-content-dual-language-01-shape-and-render-helpers.md`.
  This task **depends on** `-01a-helper-and-views.md` having landed
  (the pickLang helper must be wired across views before the schema
  changes shape, otherwise views would render `[object Object]` after
  the migration). It is independent of `-01b-i18n-type-category.md`.

## Objective

Convert the relevant catalog text columns / jsonb leaves to the
`{en, sv}` shape via a migration, and rewrite
`supabase/seed/seed.sql` and `web/data/catalog.json` to emit the new
shape. For this task, fill both `en` and `sv` slots with the existing
seeded English copy (i.e. duplicate). Real translations land in
sub-tasks 02–05.

## Scope (do)

- Add migration `supabase/migrations/0007_dual_language_catalog.sql`
  that converts the following to `jsonb {en, sv}`:
  - `public.events`: `name`, `subtitle`, `summary`,
    `branding.hero_image_credit`,
    `overrides.{entrance,bag_rules,access_notes}`,
    `questionnaire_subjects` (array of strings → array of objects)
  - `public.news_items`: `title`, `body`
  - `public.articles`: `title`, `body`
  - `public.speakers`: `bio`, `affiliation` (`name` stays a single
    string)
  - `public.program_items`: `title`, `description`, `location` (track
    stays as a canonical key)
  - `public.exhibitors`: `description` (company `name` stays single)
  - `public.point_addons`: `name`, `description`
  - `public.merchandise`: `name`, `description`
  - `public.venues`: rewrite jsonb leaves under `transport.summary`,
    `transport.modes[].mode`, `transport.modes[].detail`,
    `parking.summary`, `parking.notes`, `restaurants[].name`,
    `restaurants[].description`, `security.summary`,
    `security.general_rules[]`, `sustainability` (top-level text →
    jsonb), `maps[].name`, `maps[].description`
- For top-level `text` columns (e.g. `news_items.title`,
  `articles.title`, `point_addons.name`), use:
  `alter table … alter column … type jsonb using
  jsonb_build_object('en', value, 'sv', value)`. Drop any check
  constraints first if relevant.
- For already-jsonb columns, rewrite their string leaves with a SQL
  `update` statement that wraps each leaf into `{en, sv}`.
- Make the migration idempotent — guard each conversion with a
  `case when jsonb_typeof(value) = 'string' then …` style check, or
  document in the migration's header comment why a re-run is safe.
- Apply the migration to the shared Supabase project via
  `mcp__claude_ai_Supabase__apply_migration`.
- Rewrite `supabase/seed/seed.sql` so every multilingual field is
  written in the new shape. Use `jsonb_build_object('en', '...',
  'sv', '...')` for object leaves and `jsonb_build_array(
  jsonb_build_object('en', '...', 'sv', '...'), …)` for arrays.
  Both `en` and `sv` slots carry the **existing seeded English copy**
  (duplicate-fill). Real translations land in sub-tasks 02–05.
- Rewrite `web/data/catalog.json` in the same shape with the same
  duplicate-fill.
- Apply the rewritten seed to the shared project via
  `mcp__claude_ai_Supabase__execute_sql` and verify with spot-check
  selects, e.g.:
  - `select name->'en', name->'sv' from events where id = 'nordbygg-2026'`
  - `select sustainability from venues where id = 'stockholmsmassan'`
- Update `docs/functional-specification.md` §"Accessibility and
  internationalization (baseline)" to remove the catalog-content
  carve-out (the paragraph saying event content "stays in the
  language it was seeded in"). Replace with a description of the new
  rule: every user-facing seeded field is dual-language and renders
  in the active UI language; only persisted display labels keep
  their canonical-English rule.
- Update `docs/implementation-specification.md` (the seed-shape
  section) to describe the `{en, sv}` shape and the `pickLang` helper
  added in 01a.
- Post a single milestone comment on issue #27 announcing that the
  dual-language seed shape is in place and translations follow in
  sub-tasks 02–05.

## Validation

- `npm run test:unit` passes (pickLang already accepts `{en, sv}`
  shape after 01a, so views render correctly).
- The `availableKeys` parity test still passes.
- Manual smoke: toggle the language flag in the running app — every
  catalog surface keeps rendering (English text in both languages is
  fine; sub-tasks 02–05 backfill Swedish).
- Spot-check Supabase queries return jsonb objects for the converted
  columns.

## Scope (do not)

- Do **not** translate any seeded copy in this task. Both language
  slots carry the same English source string.
- Do **not** add new languages beyond `en` and `sv`.
- Do **not** touch persisted-identity strings.

## Notes

- The seed-rewrite is the bulk of the work: roughly 200+ leaf
  conversions across `seed.sql` and `catalog.json` each. Plan for
  careful, mechanical edits and consider using a small script if it
  helps — but the result must be readable, hand-maintained SQL/JSON.
- If any test fixture under `tests/` hard-codes English seeded
  strings, update it to call `pickLang` or read the `.en` slot.
- Move this file to `agent/tasks_completed/` via `git mv` when done.
