# Translate seeded content — 01c4: migration + seed for points/merchandise + docs + milestone

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: see
  `translate-seeded-content-dual-language-01c1-events-and-venues.md`
  for the rationale and the four-way split of 01c. This task covers
  the point-system catalog (point_addons, merchandise) plus the docs
  update and the milestone comment that close out the 01c roll-up.

This task **depends on** `-01a-helper-and-views.md` having landed.
It should land **last** of the 01cN sub-tasks (after 01c1, 01c2,
01c3) because it carries the docs update and the milestone comment.

## Objective

Convert the point-system catalog text columns to the `{en, sv}`
shape via a migration, rewrite the corresponding sections of
`supabase/seed/seed.sql` and `web/data/catalog.json` to emit the new
shape, update the docs to remove the catalog-content carve-out, and
post the milestone comment on issue #27. For this task, fill both
`en` and `sv` slots with the existing seeded English copy
(duplicate-fill). Real Swedish translations land in sub-task 05.

## Scope (do)

- Add migration `supabase/migrations/0010_dual_language_points.sql`
  that converts the following to `jsonb {en, sv}`:
  - `public.point_addons`: `name`, `description`
  - `public.merchandise`: `name`, `description`
- Use `alter column … type jsonb using jsonb_build_object('en',
  value, 'sv', value)`. Drop any check constraints first if relevant.
- Make the migration idempotent — guard each conversion with a
  `case when jsonb_typeof(value) = 'string' then …` style check, or
  document in the migration's header comment why a re-run is safe.
- Apply the migration to the shared Supabase project via
  `mcp__claude_ai_Supabase__apply_migration`.
- Rewrite the point_addons and merchandise `INSERT` blocks in
  `supabase/seed/seed.sql` so every multilingual field is written
  in the new shape (`jsonb_build_object('en', '...', 'sv', '...')`).
  Both `en` and `sv` slots carry the existing seeded English copy.
- Rewrite the corresponding sections in `web/data/catalog.json` in
  the same shape with the same duplicate-fill.
- Apply the rewritten seed to the shared project via
  `mcp__claude_ai_Supabase__execute_sql` and verify with spot-check
  selects, e.g.:
  - `select name->'en', name->'sv' from point_addons where id =
    'nordbygg-2026-addon-gift-bag'`
  - `select description from merchandise where id = 'merch-tote-bag'`
- Update `docs/functional-specification.md` §"Accessibility and
  internationalization (baseline)" to remove the catalog-content
  carve-out (the paragraph saying event content "stays in the
  language it was seeded in"). Replace with a description of the new
  rule: every user-facing seeded field is dual-language and renders
  in the active UI language; only persisted display labels keep
  their canonical-English rule.
- Update `docs/implementation-specification.md` (the seed-shape
  section) to describe the `{en, sv}` shape and the `pickLang` helper
  added in 01a. Note that the schema migration was split across
  `0007_dual_language_events_venues.sql`,
  `0008_dual_language_editorial.sql`,
  `0009_dual_language_exhibitors.sql`, and
  `0010_dual_language_points.sql` (one per table group) so each
  could land independently with its matching seed rewrite.
- Post a single milestone comment on issue #27 announcing that the
  dual-language seed shape is in place across all catalog tables and
  that real Swedish translations follow in sub-tasks 02–05.

## Validation

- `npm run test:unit` passes.
- The `availableKeys` parity test still passes.
- Manual smoke: toggle the language flag in the running app — the
  points shop (`#/points`) and any event add-on grid render correctly
  (English text in both languages is fine; sub-task 05 backfills
  Swedish).
- Spot-check Supabase queries return jsonb objects for the converted
  columns.
- Confirm none of 01c1, 01c2, 01c3 were accidentally re-skipped — i.e.
  every catalog text field in the schema is now `jsonb` (not `text`),
  and `select count(*) from <table> where <column> is not null and
  jsonb_typeof(<column>) <> 'object'` returns 0 for each converted
  column. If any column is still `text`, do **not** silently fix it
  here; flag it on the relevant 01cN sub-task instead.

## Scope (do not)

- Do **not** translate any seeded copy in this task.
- Do **not** touch points-cost, image, or stock values — copy is the
  only thing in scope.
- Do **not** alter the redemption flow itself.

## Notes

- If any test fixture under `tests/` hard-codes English seeded
  strings for add-ons or merchandise, update it to call `pickLang`
  or read the `.en` slot.
- Move this file to `agent/tasks_completed/` via `git mv` when done.
