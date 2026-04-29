# Translate seeded content — 04: exhibitors

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: see `translate-seeded-content-dual-language.md` and the
  five sub-tasks. Depends on `-01-shape-and-render-helpers.md` having
  landed.

## Objective

Backfill Swedish translations for every exhibitor `description` in the
seed. The `name` column stays a single string (company brand names).

## Scope (do)

In `supabase/seed/seed.sql` (and the `web/data/catalog.json` mirror),
write Swedish copy for the `description` field on every row in
`public.exhibitors`. There are roughly **870 rows**, the bulk of which
belong to `nordbygg-2026` (scraped from the official Stockholmsmassan
exhibitor directory). The simulated exhibitors for ESTRO, EHA, and
other events are also in scope.

This is a high-volume, repetitive translation task. Treat it as:

- Read the existing English description for each row.
- Produce a natural Swedish equivalent.
- Wrap both in the `{en, sv}` shape that sub-task 01 set up.

For the scraped Nordbygg exhibitor descriptions — which are short,
formulaic, and often copied verbatim from the source page — feel free
to apply consistent terminology mapping (e.g. "supplier of …" →
"leverantör av …", "manufacturer of …" → "tillverkare av …",
"distributes …" → "distribuerar …"). Document the chosen mapping in a
short comment at the top of the exhibitor INSERT block in
`seed.sql`, so future updates stay consistent.

## Validation

- `npm run test:unit` passes.
- Toggle the language flag in the running app:
  - Open Nordbygg 2026 Exhibitors. Spot-check a sample of 10–20
    exhibitor cards across the alphabet — every description renders
    in Swedish.
  - Open the search box, type a Swedish-language query (e.g.
    "leverantör"), and confirm the search filter still matches
    rows. Note: depending on how `view/event.js` `filteredExhibitors`
    works, search may match the `pickLang(description)` value or the
    raw object — verify the existing implementation handles the
    dual-language shape correctly. If it does not, fix the search to
    match against the active-language description.
  - Repeat for ESTRO 2026 and any other event with simulated
    exhibitors.

## Scope (do not)

- Do **not** translate exhibitor `name` (company brand names stay as
  the canonical single string).
- Do **not** rescrape or change exhibitor logos, websites, or booth
  numbers.
- Do **not** add or remove exhibitor rows in this task.

## Notes

- Given the volume, consider:
  - Splitting the change into two PRs (Nordbygg first, the rest in a
    second PR) if review becomes unwieldy, but the seed and frontend
    must always be in sync inside any single landed PR.
  - Using a script under `scripts/` to generate the Swedish payload
    and produce the SQL diff. If you write such a script, commit it
    so the next exhibitor rescrape can re-run it.
- Move this file to `agent/tasks_completed/` via `git mv` when done.
