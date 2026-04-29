# Translate seeded content — 04d-cont-x-y-z: Nordbygg exhibitors X, Y, Z + milestone

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent: see
  `translate-seeded-content-dual-language-04d-nordbygg-s-z.md`
  (in `tasks_completed/`). The 04d parent was scoped to Nordbygg
  S–Z but was too large for one agent session (~148 rows with
  non-null descriptions where `description->'en' = description->'sv'`).
  X, Y, Z are tiny (3+1+4 rows), so they share this file.
- shared tooling: see
  `translate-seeded-content-dual-language-04a-simulated-and-nordbygg-a-d.md`
  (in `tasks_completed/`) for the language-detection heuristic,
  the terminology-mapping comment in `seed.sql`, and the applier
  script.

This task **depends on** `-04a-…` having landed (the tooling and
the shared terminology comment in `seed.sql` are already in place).
It should land **last** of the 04d-cont sub-tasks because it carries
the milestone comment that closes out the entire 04N exhibitor-
translation roll-up.

## Objective

Backfill natural translations for Nordbygg 2026 exhibitors whose
`name` starts with the letter **X**, **Y**, or **Z**
(case-insensitive). At time of split this is **8 rows with non-null
descriptions** (3 for X, 1 for Y, 4 for Z) where
`description->'en' = description->'sv'`.

The exhibitor `name` column stays a single string (company brand
names are not translated).

## Scope (do)

- Use the same applier-payload pattern as 04a:
  - The applier script `scripts/apply_exhibitor_translations.mjs`
    already exists and accepts a payload path on the CLI. Pass it
    a payload at `scripts/translations/exhibitors-04d-cont-x-y-z.json`
    of shape `[{ id, en, sv }, ...]`.
  - The applier idempotently rewrites both
    `supabase/seed/seed.sql` and `web/data/catalog.json` for the
    matching ids.
- Detect the source language for each row using the heuristic from
  04a: Swedish if the text contains `å`, `ä`, `ö` (any case) or one
  of the standalone tokens `och`, `är`, `vi`, `för`, `med`, `på`,
  `eller`. Otherwise English.
- Translate the non-source slot. Keep paragraph breaks, bullets and
  any embedded HTML/punctuation intact.
- Apply the payload locally:
  `node scripts/apply_exhibitor_translations.mjs scripts/translations/exhibitors-04d-cont-x-y-z.json`
- Apply the same delta to the shared Supabase project via
  `mcp__claude_ai_Supabase__execute_sql`. Build a single VALUES-list
  UPDATE for the 8 rows.
- Verify with a spot-check select (any updated X, Y, or Z row).

## Closing checks (across all 04N) — gate the milestone comment

- `select count(*) from exhibitors where event_id = 'nordbygg-2026'
  and description is not null and description->'en' =
  description->'sv'` must return **0**.
- `select count(*) from exhibitors where event_id = 'nordbygg-2026'
  and description is not null and (description->'en' is null or
  description->'sv' is null)` must return **0**.

If either count is non-zero, do **not** post the milestone comment.
File a follow-up sub-task (`-04e-cleanup-…`) listing the residual
rows by id and stop.

## Milestone comment

After the seed lands and both closing checks above return 0, post a
single milestone comment on issue #27 announcing that exhibitor
descriptions are now natural-language dual-language across all
~566 non-null Nordbygg rows plus the simulated ESTRO/EHA rows.
Cross-link the four 04N PRs (04a, 04b, 04c, 04d).

## Tooling

- `scripts/apply_exhibitor_translations.mjs` already exists and is
  idempotent; reuse it as-is. Do **not** modify the wrap script
  `scripts/wrap_exhibitor_descriptions.mjs`.
- The shared terminology mapping is documented in `seed.sql` at the
  exhibitors INSERT comment block. Extend that comment if you
  introduce a new mapping that future sub-tasks should follow.

## Validation

- `npm run test:unit` passes.
- Toggle the language flag in the running app, open Nordbygg 2026
  Exhibitors and scroll to the X, Y, and Z ranges. Spot-check the
  cards; both languages render fluently.
- Confirm the search-filter check from 04a still works in both
  languages.

## Scope (do not)

- Do **not** translate exhibitor `name`.
- Do **not** translate descriptions for letters other than X, Y, or
  Z in this task — S, T, U–V, W each land in their own
  `-04d-cont-…md` sub-tasks.
- Do **not** rescrape or change exhibitor logos, websites, or booth
  numbers.
- Do **not** add or remove exhibitor rows.
- Do **not** post the milestone comment unless the closing checks
  above all pass.

## Notes

- Move this file to `agent/tasks_completed/` via `git mv` when done.
