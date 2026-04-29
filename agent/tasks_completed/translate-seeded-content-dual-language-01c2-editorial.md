# Translate seeded content — 01c2: migration + seed for editorial content

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: see
  `translate-seeded-content-dual-language-01c1-events-and-venues.md`
  for the rationale and the four-way split of 01c. This task covers
  editorial content: news items, articles, speakers, program items.

This task **depends on** `-01a-helper-and-views.md` having landed (the
`pickLang` helper must be wired across views). It is independent of
01b, 01c1, 01c3 — the per-table migrations don't conflict.

## Objective

Convert the editorial-content text columns / jsonb leaves to the
`{en, sv}` shape via a migration, and rewrite the corresponding
sections of `supabase/seed/seed.sql` and `web/data/catalog.json` to
emit the new shape. For this task, fill both `en` and `sv` slots with
the existing seeded English copy (duplicate-fill). Real Swedish
translations land in sub-task 03.

## Scope (do)

- Add migration `supabase/migrations/0008_dual_language_editorial.sql`
  that converts the following to `jsonb {en, sv}`:
  - `public.news_items`: `title`, `body`
  - `public.articles`: `title`, `body`
  - `public.speakers`: `bio`, `affiliation` (`name` stays a single
    string)
  - `public.program_items`: `title`, `description`, `location` (track
    stays as a canonical key)
- For the top-level `text` columns, use `alter column … type jsonb
  using jsonb_build_object('en', value, 'sv', value)`. Drop any
  check constraints first if relevant.
- Make the migration idempotent — guard each conversion with a
  `case when jsonb_typeof(value) = 'string' then …` style check, or
  document in the migration's header comment why a re-run is safe.
- Apply the migration to the shared Supabase project via
  `mcp__claude_ai_Supabase__apply_migration`.
- Rewrite the news_items, articles, speakers, and program_items
  `INSERT` blocks in `supabase/seed/seed.sql` so every multilingual
  field is written in the new shape (`jsonb_build_object('en', '...',
  'sv', '...')`). Both `en` and `sv` slots carry the existing seeded
  English copy.
- Rewrite the corresponding sections in `web/data/catalog.json` in
  the same shape with the same duplicate-fill.
- Apply the rewritten seed to the shared project via
  `mcp__claude_ai_Supabase__execute_sql` and verify with spot-check
  selects, e.g.:
  - `select title->'en', title->'sv' from news_items where id =
    'nordbygg-2026-news-exhibitors-crossed'`
  - `select bio from speakers where id =
    'estro-2026-speaker-lindqvist'`

## Validation

- `npm run test:unit` passes.
- The `availableKeys` parity test still passes.
- Manual smoke: toggle the language flag in the running app — the
  News, Articles, Program, and Speakers surfaces on Nordbygg, ESTRO,
  and EHA continue to render (English text in both languages is
  fine; sub-task 03 backfills Swedish).
- Spot-check Supabase queries return jsonb objects for the converted
  columns.

## Scope (do not)

- Do **not** translate any seeded copy in this task.
- Do **not** touch event-level fields, venue, exhibitors, add-ons, or
  merchandise — those are other 01cN sub-tasks.
- Do **not** translate person names (`speakers.name` stays a single
  string).
- Do **not** update docs or post the milestone comment — those land
  with 01c4.

## Notes

- If any test fixture under `tests/` hard-codes English seeded
  strings for editorial content, update it to call `pickLang` or
  read the `.en` slot.
- Move this file to `agent/tasks_completed/` via `git mv` when done.
