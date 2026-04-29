# Translate seeded content — 04b: Nordbygg exhibitors E–J

> **Status:** split into five per-letter runnable sub-tasks on
> 2026-04-29 because the change touches ~142 non-null exhibitor
> descriptions across letters E–J — too many natural-language
> translations for one agent session (the per-letter precedent
> from 04a-cont-{b,c,d} already established that one letter is
> roughly the upper bound). Each chunk can land independently.
>
> Sub-tasks (in `agent/tasks/`, can land in any order; none of
> them carry the milestone comment — that still waits for 04d):
>
> 1. `translate-seeded-content-dual-language-04b-cont-e-nordbygg.md`
>    — Nordbygg names starting with E (~40 rows).
> 2. `translate-seeded-content-dual-language-04b-cont-f-nordbygg.md`
>    — Nordbygg names starting with F (~25 rows).
> 3. `translate-seeded-content-dual-language-04b-cont-g-nordbygg.md`
>    — Nordbygg names starting with G (~24 rows).
> 4. `translate-seeded-content-dual-language-04b-cont-h-nordbygg.md`
>    — Nordbygg names starting with H (~35 rows).
> 5. `translate-seeded-content-dual-language-04b-cont-i-j-nordbygg.md`
>    — Nordbygg names starting with I or J (~18 rows).
>
> The original task content is preserved below for context.

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: see
  `translate-seeded-content-dual-language-04-translate-exhibitors.md`
  (in `tasks_completed/`) for the rationale and the four-way split
  of 04. See `-04a-simulated-and-nordbygg-a-d.md` for shared
  guidance on translation tooling, terminology mapping, and the
  language-detection heuristic.

This task **depends on** `-01c3-exhibitors.md` having landed and is
**independent** of the other 04N sub-tasks.

## Objective

Backfill natural translations for Nordbygg 2026 exhibitors whose
`name` starts with the letters **E, F, G, H, I, or J** (~139 rows).
Most carry Swedish-only source copy; produce a natural English
counterpart. A minority carry English-only source copy; produce a
natural Swedish counterpart.

The exhibitor `name` column stays a single string.

## Scope (do)

In `supabase/seed/seed.sql` (and the `web/data/catalog.json` mirror),
for every Nordbygg row in the E–J range:

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
    where id = '<some E–J row id>'`
  - `select count(*) from exhibitors where event_id = 'nordbygg-2026'
    and description is not null and description->'en' =
    description->'sv'` — should drop by ~139 after this task lands.

## Tooling

- Reuse the row-walking parser from
  `scripts/wrap_exhibitor_descriptions.mjs`.
- Reuse (or extend) the per-row translation-payload + applier
  pattern set up in 04a. Save the payload as
  `scripts/translations/exhibitors-04b.json` so it can be reviewed
  and replayed independently of the other ranges.

## Validation

- `npm run test:unit` passes.
- Toggle the language flag in the running app:
  - Open Nordbygg 2026 Exhibitors and scroll to the E–J range.
    Spot-check 10–15 cards; both languages render fluently.
- Search-filter check: confirm the existing SV-language search test
  from 04a still works (no regression).

## Scope (do not)

- Do **not** translate descriptions for Nordbygg names outside E–J,
  or for the simulated exhibitors — those live in their own 04N
  sub-tasks.
- Do **not** translate exhibitor `name`, `booth`, `website`, or
  `logo` — out of scope.
- Do **not** post a milestone comment on issue #27 — the milestone
  announcement waits until the final 04N sub-task closes the set.

## Notes

- Move this file to `agent/tasks_completed/` via `git mv` when done.
