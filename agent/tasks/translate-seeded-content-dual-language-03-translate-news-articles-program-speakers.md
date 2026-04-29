# Translate seeded content — 03: news, articles, program, speakers

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: see `translate-seeded-content-dual-language.md` and the
  five sub-tasks. Depends on `-01-shape-and-render-helpers.md` having
  landed.

## Objective

Backfill Swedish translations for the per-event editorial content:
news items, articles, program items, and speaker bios.

## Scope (do)

In `supabase/seed/seed.sql` (and the `web/data/catalog.json` mirror),
write Swedish copy for every `{en, sv}` field on:

- `news_items` — `title` and `body` for every row (Nordbygg, ESTRO,
  EHA news rows). Keep the "Simulated." / "Simulerad." prefix where
  the English copy uses it.
- `articles` — `title` and `body` for every row.
- `program_items` — `title`, `description`, `location` for every row.
  Program tracks (`Plenary`, `Clinical`, `Sustainability`, etc.) stay
  as canonical English keys (translated via i18n keys added in
  sub-task 01 if any tracks surface in the UI; otherwise leave as is).
  Locations like "Sustainability Stage, B-Hall" translate the
  descriptive part ("Hållbarhetsscen, hall B"); proper hall labels
  ("A-Hall", "Hall B") stay or are localised consistently.
- `speakers` — `bio` and `affiliation` for every row. `name` is a
  person and stays a single string. Affiliations like "Karolinska
  University Hospital" — keep the official name (use the Swedish form
  if the institution has one, e.g. "Karolinska Universitetssjukhuset").

## Validation

- `npm run test:unit` passes.
- Toggle the language flag in the running app:
  - Nordbygg 2026 News tab — every news item title and body renders
    in Swedish.
  - Nordbygg 2026 Articles tab — every article title and body renders
    in Swedish.
  - Nordbygg 2026 Program tab — every session title, description, and
    location renders in Swedish.
  - ESTRO 2026 Speakers (program rows tied to speakers) — speaker
    bios and affiliations render in Swedish.
  - Repeat the program / speaker check for ESTRO 2026 and EHA2026.

## Scope (do not)

- Do **not** translate person names (`speakers.name`).
- Do **not** touch event-level fields (those landed in sub-task 02).
- Do **not** touch exhibitors, add-ons, or merchandise (those are 04
  and 05).

## Notes

- Move this file to `agent/tasks_completed/` via `git mv` when done.
