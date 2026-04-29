# Translate seeded content — 04a: simulated exhibitors + Nordbygg A–D

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: see
  `translate-seeded-content-dual-language-04-translate-exhibitors.md`
  (in `tasks_completed/`) for the rationale and the four-way split of
  04. The parent task was too large for one session: ~566 exhibitor
  descriptions need natural-language translation across both
  directions (some are seeded in English, others scraped in Swedish
  from the Nordbygg directory).

This task **depends on** `-01c3-exhibitors.md` having landed (the
schema is already `jsonb {en, sv}` and both slots are duplicate-
filled with the original source text — typically the source language
only). It is **independent** of the other 04N sub-tasks (04b/04c/
04d) and they can land in any order.

## Objective

Backfill natural translations for the **subset of exhibitors covered
by this sub-task**:

- All simulated exhibitors (events `estro-2026` and `eha-2026`,
  3 rows total — currently in English, need Swedish).
- All Nordbygg 2026 exhibitors whose `name` starts with the letters
  **A, B, C, or D** (~146 rows). Most carry Swedish-only source
  copy; produce a natural English counterpart. A minority carry
  English-only source copy; produce a natural Swedish counterpart.

The exhibitor `name` column stays a single string (company brand
names are not translated).

## Scope (do)

In `supabase/seed/seed.sql` (and the `web/data/catalog.json` mirror),
for every in-scope row:

- Detect which slot is the natural source. The duplicate-fill from
  01c3 means both `en` and `sv` slots currently hold the same raw
  string; that string was scraped or hand-authored in one language.
  Heuristics that work well in practice:
  - Swedish-likely if the text contains characters `å`, `ä`, `ö`
    (in any case) **or** the standalone word tokens `och`, `är`,
    `vi`, `för`, `med`, `på`, `eller`.
  - Otherwise treat as English.
- Replace the **non-source slot** with a natural translation of the
  source text. Keep paragraph breaks, bullet lists, and embedded
  HTML/punctuation intact.
- For the simulated exhibitors (`estro-2026-exhibitor-*`,
  `eha-2026-exhibitor-*`), the source is English; produce a natural
  Swedish counterpart in the `sv` slot.
- For the scraped Nordbygg descriptions — short, formulaic, often
  copied verbatim from the source page — apply consistent
  terminology mapping. Document the chosen mapping in a short
  comment at the top of the exhibitors `INSERT` block in `seed.sql`
  if the comment is not already there from a prior 04N task; if it
  is, extend it with any new mappings introduced here. Suggested
  starter mappings:
  - "supplier of …" ↔ "leverantör av …"
  - "manufacturer of …" ↔ "tillverkare av …"
  - "distributes …" ↔ "distribuerar …"
  - "develops and manufactures …" ↔ "utvecklar och tillverkar …"
- Apply the rewritten seed to the shared Supabase project via
  `mcp__claude_ai_Supabase__execute_sql` and verify with spot-check
  selects, e.g.:
  - `select description->'en', description->'sv' from exhibitors
    where id = 'estro-2026-exhibitor-radonicsolutions'`
  - `select count(*) from exhibitors where event_id = 'nordbygg-2026'
    and description is not null and description->'en' =
    description->'sv'` — should drop by ~146 after this task lands.

## Tooling

- The existing `scripts/wrap_exhibitor_descriptions.mjs` parses the
  exhibitor INSERT block correctly (handles `''` escapes, embedded
  newlines, and nested parens). Reuse its row-walking helpers for
  any new translation tooling rather than rewriting the parser.
- Strongly consider extracting the translation into a per-row JSON
  payload checked into `scripts/translations/exhibitors-04a.json`
  (id → `{en, sv}`) and a small applier script that reads that file
  and rewrites the seed/catalog. Keeping the translation payload
  separate from the seed makes review and re-application easier.
  Commit the payload and the script.
- If the per-row translation list grows unwieldy, leave any work
  not finished in the same applier-payload format and split out
  whatever remains into a new sub-task (`-04a-cont-…`) — do not
  ship a half-applied seed.

## Validation

- `npm run test:unit` passes.
- Toggle the language flag in the running app:
  - Open ESTRO 2026 Exhibitors. Both simulated rows render natural
    Swedish copy when SV is active and natural English when EN is
    active.
  - Open EHA 2026 Exhibitors. Same check for the single simulated
    row.
  - Open Nordbygg 2026 Exhibitors and scroll to the A–D range.
    Spot-check 10–15 cards; both languages render fluently.
- Search-filter check: in the SV state, type `leverantör` (or any
  Swedish word that occurs in a translated description) into the
  exhibitor search. The filter should match rows whose Swedish
  description contains the term. If the filter matches against the
  raw `description` object instead of the active-language string,
  fix `view/event.js`'s `filteredExhibitors` to run the search
  through `pickLang($store.lang.current)`.

## Scope (do not)

- Do **not** translate exhibitor `name` (company brand names stay
  the canonical single string).
- Do **not** translate descriptions for Nordbygg names starting with
  letters E–Z — those land in 04b/04c/04d.
- Do **not** rescrape or change exhibitor logos, websites, or booth
  numbers.
- Do **not** add or remove exhibitor rows.
- Do **not** post a milestone comment on issue #27 in this task —
  the milestone announcement waits until the final 04N sub-task
  closes the set.

## Notes

- Move this file to `agent/tasks_completed/` via `git mv` when done.
- If the search-filter fix is needed, prefer to land it here (the
  first 04N sub-task) so later sub-tasks inherit a working filter.
