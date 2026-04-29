# Translate seeded content — 04b-cont-h: Nordbygg exhibitors H

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent: see
  `translate-seeded-content-dual-language-04b-nordbygg-e-j.md`
  (in `tasks_completed/`). The 04b parent was scoped to Nordbygg
  E–J but was too large for one agent session (~142 rows with
  non-null descriptions), so it was split into five per-letter
  continuation tasks. This file is the H portion.
- shared tooling: see
  `translate-seeded-content-dual-language-04a-simulated-and-nordbygg-a-d.md`
  (in `tasks_completed/`) for the language-detection heuristic,
  the terminology-mapping comment in `seed.sql`, and the applier
  script.

This task **depends on** `-04a-…` having landed (the tooling and
the shared terminology comment in `seed.sql` are already in place).
It is **independent** of the other 04b-cont sub-tasks and they can
land in any order.

## Objective

Backfill natural translations for Nordbygg 2026 exhibitors whose
`name` starts with the letter **H** (or `h`). At time of split this
is **35 rows with non-null descriptions** (out of 46 total H-rows;
the other 11 have no description).

The exhibitor `name` column stays a single string (company brand
names are not translated).

## Scope (do)

- Use the same applier-payload pattern as 04a:
  - The applier script `scripts/apply_exhibitor_translations.mjs`
    already exists and accepts a payload path on the CLI. Pass it
    a payload at `scripts/translations/exhibitors-04b-cont-h.json`
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
  `node scripts/apply_exhibitor_translations.mjs scripts/translations/exhibitors-04b-cont-h.json`
- Apply the same delta to the shared Supabase project via
  `mcp__claude_ai_Supabase__execute_sql`. Build a VALUES-list UPDATE
  per ~8 rows to stay under MCP arg-size limits.
- Verify with a spot-check select (any updated H-row).

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
  Exhibitors and scroll to the H range. Spot-check 5–10 cards;
  both languages render fluently.

## Scope (do not)

- Do **not** translate exhibitor `name`.
- Do **not** translate descriptions for letters other than H in
  this task — E, F, G, I, J each land in their own
  `-04b-cont-<letter>.md` sub-tasks.
- Do **not** rescrape or change exhibitor logos, websites, or booth
  numbers.
- Do **not** add or remove exhibitor rows.
- Do **not** post a milestone comment on issue #27 — the milestone
  announcement waits until the final 04N sub-task closes the set.

## Notes

- Move this file to `agent/tasks_completed/` via `git mv` when done.
