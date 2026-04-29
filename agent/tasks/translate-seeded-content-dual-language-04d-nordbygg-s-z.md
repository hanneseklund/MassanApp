# Translate seeded content — 04d: Nordbygg exhibitors S–Z + milestone

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: see
  `translate-seeded-content-dual-language-04-translate-exhibitors.md`
  (in `tasks_completed/`) for the rationale and the four-way split
  of 04. See `-04a-simulated-and-nordbygg-a-d.md` for shared
  guidance on translation tooling, terminology mapping, and the
  language-detection heuristic.

This task **depends on** `-01c3-exhibitors.md` having landed. It
should land **last** of the 04N sub-tasks (after 04a, 04b, 04c)
because it carries the milestone comment that closes out the
exhibitor-translation roll-up.

## Objective

Backfill natural translations for Nordbygg 2026 exhibitors whose
`name` starts with the letters **S, T, U, V, W, X, Y, or Z**
(~148 rows; S alone has ~71). Most carry Swedish-only source copy;
produce a natural English counterpart. A minority carry English-
only source copy; produce a natural Swedish counterpart.

The exhibitor `name` column stays a single string.

## Scope (do)

In `supabase/seed/seed.sql` (and the `web/data/catalog.json` mirror),
for every Nordbygg row in the S–Z range:

- Detect the natural source slot via the heuristic in 04a (presence
  of `å/ä/ö` or Swedish stop-word tokens → Swedish source).
- Replace the non-source slot with a natural translation. Preserve
  paragraph breaks, bullet lists, and any embedded punctuation.
- Apply the consistent terminology mapping documented in the
  comment at the top of the exhibitors `INSERT` block in `seed.sql`
  (added in 04a). Extend the mapping if you introduce new
  recurring patterns and call them out in the same comment.
- Apply the rewritten seed to the shared Supabase project via
  `mcp__claude_ai_Supabase__execute_sql` and verify with spot-check
  selects:
  - `select description->'en', description->'sv' from exhibitors
    where id = '<some S–Z row id>'`
  - `select count(*) from exhibitors where event_id = 'nordbygg-2026'
    and description is not null and description->'en' =
    description->'sv'` — should reach **0** after this task lands.
- After the seed lands and the count above is 0, post a single
  milestone comment on issue #27 announcing that exhibitor
  descriptions are now natural-language dual-language across all
  ~566 non-null Nordbygg rows plus the simulated ESTRO/EHA rows.
  Cross-link the four 04N PRs.

## Closing checks (across all 04N)

- `select count(*) from exhibitors where description is not null
  and description->'en' = description->'sv'` returns **0**.
- `select count(*) from exhibitors where description is not null
  and (description->'en' is null or description->'sv' is null)`
  returns **0**.

If either count is non-zero, do **not** post the milestone comment.
File a follow-up sub-task (`-04e-cleanup-…`) listing the residual
rows by id and stop.

## Tooling

- Reuse the row-walking parser from
  `scripts/wrap_exhibitor_descriptions.mjs`.
- Reuse (or extend) the per-row translation-payload + applier
  pattern set up in 04a. Save the payload as
  `scripts/translations/exhibitors-04d.json` so it can be reviewed
  and replayed independently of the other ranges.

## Validation

- `npm run test:unit` passes.
- Toggle the language flag in the running app:
  - Open Nordbygg 2026 Exhibitors and scroll to the S–Z range.
    Spot-check 10–15 cards (especially the long S range); both
    languages render fluently.
- Confirm the search-filter check from 04a still works in both
  languages.

## Scope (do not)

- Do **not** translate descriptions for Nordbygg names outside S–Z
  or for the simulated exhibitors — those land in 04a/04b/04c.
- Do **not** translate exhibitor `name`, `booth`, `website`, or
  `logo` — out of scope.
- Do **not** post a milestone comment unless the closing checks
  above all pass.

## Notes

- Move this file to `agent/tasks_completed/` via `git mv` when done.
