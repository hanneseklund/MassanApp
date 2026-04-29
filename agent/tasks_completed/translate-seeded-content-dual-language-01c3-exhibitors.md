# Translate seeded content — 01c3: migration + seed for exhibitors

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: see
  `translate-seeded-content-dual-language-01c1-events-and-venues.md`
  for the rationale and the four-way split of 01c. This task covers
  exhibitors only — by far the biggest table by row count
  (~870 rows) and by seed-file footprint (~3500 lines, dominated by
  the scraped Nordbygg directory).

This task **depends on** `-01a-helper-and-views.md` having landed (the
`pickLang` helper must be wired across views). It is independent of
the other 01cN sub-tasks.

## Objective

Convert `public.exhibitors.description` to `jsonb {en, sv}` via a
migration, and rewrite the exhibitors `INSERT` block in
`supabase/seed/seed.sql` and the corresponding rows in
`web/data/catalog.json` to emit the new shape. For this task, fill
both `en` and `sv` slots with the existing seeded `description` (i.e.
duplicate-fill). Real Swedish translations land in sub-task 04.

## Scope (do)

- Add migration `supabase/migrations/0009_dual_language_exhibitors.sql`
  that converts `public.exhibitors.description` from `text` to
  `jsonb {en, sv}`:
  - `alter column description type jsonb using
    case when description is null then null
    else jsonb_build_object('en', description, 'sv', description)
    end`
  - Make the migration idempotent — guard with a
    `case when jsonb_typeof(description) = 'string' then …` style
    check, or document in the migration's header comment why a re-run
    is safe.
- Apply the migration to the shared Supabase project via
  `mcp__claude_ai_Supabase__apply_migration`.
- Rewrite the `insert into public.exhibitors (...)` block in
  `supabase/seed/seed.sql` so every `description` value is written
  in the new shape:
  - `null` descriptions stay `null`.
  - Non-null descriptions become `jsonb_build_object('en', '...',
    'sv', '...')` with the same English text duplicated into both
    slots.
- Rewrite the exhibitor entries under `web/data/catalog.json`'s
  exhibitors collection in the same shape with the same
  duplicate-fill.
- Apply the rewritten seed to the shared project via
  `mcp__claude_ai_Supabase__execute_sql` and verify with spot-check
  selects, e.g.:
  - `select description->'en', description->'sv' from exhibitors
    where id = 'nordbygg-2026-exhibitor-136827'`
  - `select count(*) from exhibitors where description is not null
    and (description->'en' is null or description->'sv' is null)`
    (expect 0).

## Volume and tooling

- ~870 rows. The bulk are scraped Nordbygg descriptions, many of
  them already in Swedish (the source page is bilingual; some
  descriptions are Swedish-only). Duplicate-fill is still correct
  for this task — the language slot just carries whatever the source
  text was; sub-task 04 produces the natural counterpart.
- Strongly consider writing a one-off script under `scripts/` (e.g.
  `scripts/wrap_exhibitor_descriptions.mjs`) that:
  - Reads the existing `seed.sql` exhibitor INSERT block.
  - Replaces each `'description'` literal with the
    `jsonb_build_object('en', '...', 'sv', '...')` form.
  - Same for `catalog.json`.
  - Commit the script — sub-task 04 (real translation) and any future
    exhibitor rescrape will benefit from a reusable wrapper.
- Be careful with quote escaping: many exhibitor descriptions contain
  `'` apostrophes already escaped as `''`, plus newlines. The script
  must preserve the exact literal content; only wrap it.

## Validation

- `npm run test:unit` passes.
- Manual smoke: toggle the language flag in the running app — the
  Nordbygg 2026 Exhibitors tab continues to render (the displayed
  language is whatever the source description happened to be; that's
  fixed in sub-task 04).
- Spot-check Supabase queries return jsonb objects for the converted
  column.
- Confirm the search box on the Exhibitors tab still matches rows.
  If the search currently reads `description` as a string and
  pickLang's transitional fallback no longer applies (because the
  value is now a `{en, sv}` object), wire the filter through
  `pickLang($store.lang.current)` so it matches the active-language
  text.

## Scope (do not)

- Do **not** translate exhibitor descriptions in this task.
- Do **not** touch exhibitor `name`, `booth`, `website`, or `logo` —
  out of scope.
- Do **not** add or remove exhibitor rows.
- Do **not** rescrape exhibitor data.
- Do **not** update docs or post the milestone comment — those land
  with 01c4.

## Notes

- If any test fixture under `tests/` hard-codes English exhibitor
  strings, update it to call `pickLang` or read the `.en` slot.
- Move this file to `agent/tasks_completed/` via `git mv` when done.
