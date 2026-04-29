# Translate seeded content — 01c1: migration + seed for events and venues

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: `translate-seeded-content-dual-language-01c-migration-and-seed.md`
  was further split into four sub-tasks (01c1–01c4) because the original
  scope — one migration affecting 9 tables, plus rewriting
  `supabase/seed/seed.sql` (4425 lines) and `web/data/catalog.json`
  (8949 lines) end-to-end — was infeasible in one session. Each
  sub-task lands its own migration and matching seed/catalog rewrite,
  so each is independently mergeable and the seed file is never in a
  broken state. Sub-task order:
  - 01c1 (this file): events + venues
  - 01c2: news_items, articles, speakers, program_items
  - 01c3: exhibitors (the bulk)
  - 01c4: point_addons, merchandise, docs updates, milestone comment

This task **depends on** `-01a-helper-and-views.md` having landed (the
`pickLang` helper must be wired across views). It is independent of
01b and the other 01cN sub-tasks, except that 01c4 should land last
because it carries the final docs update and the milestone comment.

## Objective

Convert the events and venues catalog text columns / jsonb leaves to
the `{en, sv}` shape via a migration, and rewrite the events + venues
sections of `supabase/seed/seed.sql` and `web/data/catalog.json` to
emit the new shape. For this task, fill both `en` and `sv` slots with
the existing seeded English copy (i.e. duplicate-fill). Real Swedish
translations land in sub-task 02.

## Scope (do)

- Add migration `supabase/migrations/0007_dual_language_events_venues.sql`
  that converts the following to `jsonb {en, sv}`:
  - `public.events`: `name`, `subtitle`, `summary`,
    `branding.hero_image_credit`,
    `overrides.{entrance,bag_rules,access_notes}`,
    `questionnaire_subjects` (array of strings → array of objects)
  - `public.venues`: jsonb leaves under `transport.summary`,
    `transport.modes[].mode`, `transport.modes[].detail`,
    `parking.summary`, `parking.notes`, `restaurants[].name`,
    `restaurants[].description`, `security.summary`,
    `security.general_rules[]`, `sustainability` (top-level text →
    jsonb), `maps[].name`, `maps[].description`
- For top-level `text` columns (`events.name`, `events.subtitle`,
  `events.summary`, `venues.sustainability`), use:
  `alter column … type jsonb using jsonb_build_object('en', value,
  'sv', value)`. Drop any check constraints first if relevant.
- For already-jsonb columns, rewrite their string leaves with a SQL
  `update` statement that wraps each leaf into `{en, sv}`.
- Make the migration idempotent — guard each conversion with a
  `case when jsonb_typeof(value) = 'string' then …` style check, or
  document in the migration's header comment why a re-run is safe.
- Apply the migration to the shared Supabase project via
  `mcp__claude_ai_Supabase__apply_migration`.
- Rewrite the events and venues `INSERT` blocks in
  `supabase/seed/seed.sql` so every multilingual field is written in
  the new shape. Use `jsonb_build_object('en', '...', 'sv', '...')`
  for object leaves and `jsonb_build_array(jsonb_build_object('en',
  '...', 'sv', '...'), …)` for arrays. Both `en` and `sv` slots carry
  the **existing seeded English copy** (duplicate-fill).
- Rewrite the events and venue rows in `web/data/catalog.json` in the
  same shape with the same duplicate-fill.
- Apply the rewritten seed to the shared project via
  `mcp__claude_ai_Supabase__execute_sql` and verify with spot-check
  selects, e.g.:
  - `select name->'en', name->'sv' from events where id = 'nordbygg-2026'`
  - `select sustainability from venues where id = 'stockholmsmassan'`

## Validation

- `npm run test:unit` passes (pickLang already accepts `{en, sv}`
  shape after 01a, so views render correctly).
- The `availableKeys` parity test still passes.
- Manual smoke: toggle the language flag in the running app — every
  event-card title/subtitle/summary and venue practical-info surface
  keeps rendering (English text in both languages is fine; sub-task
  02 backfills Swedish).
- Spot-check Supabase queries return jsonb objects for the converted
  columns.

## Scope (do not)

- Do **not** translate any seeded copy in this task. Both language
  slots carry the same English source string.
- Do **not** touch news, articles, speakers, program, exhibitors,
  add-ons, or merchandise — those are 01c2–01c4.
- Do **not** add new languages beyond `en` and `sv`.
- Do **not** touch persisted-identity strings.
- Do **not** update docs or post the milestone comment — those land
  with 01c4.

## Notes

- If any test fixture under `tests/` hard-codes English seeded
  strings for events or venues, update it to call `pickLang` or read
  the `.en` slot.
- Move this file to `agent/tasks_completed/` via `git mv` when done.
