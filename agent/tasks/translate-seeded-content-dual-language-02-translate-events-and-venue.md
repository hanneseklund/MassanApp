# Translate seeded content — 02: events and venue

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: see `translate-seeded-content-dual-language.md` and the
  five sub-tasks. This task depends on
  `-01-shape-and-render-helpers.md` having landed (the `{en, sv}`
  shape and `pickLang` helper must exist).

## Objective

Backfill real Swedish translations for every event-level and
venue-level user-facing seeded field. Every `{en, sv}` slot that
sub-task 01 populated by duplication gets a natural Swedish translation
in this task.

## Scope (do)

In `supabase/seed/seed.sql` (and the mirror `web/data/catalog.json`),
write Swedish copy for the following fields, on every event row:

- `events.name` — for fairs and events (e.g. "Nordbygg 2026" stays as
  the canonical brand name in both languages, but where the English
  string is descriptive — e.g. "European Dog Show and Swedish Winner
  Show 2026" — provide a natural Swedish version). Use judgement: brand
  names stay; descriptive words translate.
- `events.subtitle` — every subtitle is descriptive copy and gets
  translated.
- `events.summary` — full natural translations.
- `events.branding.hero_image_credit` — translate "Stockholmsmassan",
  "Stockholmsmassan (reused from earlier edition)" etc. into Swedish
  ("Stockholmsmässan" with the `ä`, "Stockholmsmässan (återanvänd från
  tidigare upplaga)").
- `events.overrides.{entrance,bag_rules,access_notes}` — natural
  translations.
- `events.questionnaire_subjects[]` — translate each subject naturally
  (e.g. "Sustainable construction" → "Hållbart byggande").

For the venue row (`stockholmsmassan`), translate every text leaf in:

- `venues.transport.summary` and every `transport.modes[].mode` /
  `transport.modes[].detail` (translate the mode label too — "Commuter
  train" → "Pendeltåg", "From Arlanda Airport" → "Från Arlanda
  flygplats", etc.).
- `venues.parking.summary` and `parking.notes`.
- `venues.restaurants[].name` and `restaurants[].description`.
  Restaurant brand names like "Cafe Kista", "Bistro Nordic" stay; the
  descriptive ones like "Hall Cafeteria East" / "Espresso Bar Foyer"
  translate naturally ("Hallkafeteria öster" / "Espressobar i foajén").
  Use Swedish-language menu/category words.
- `venues.security.summary` and `security.general_rules[]`.
- `venues.sustainability` (top-level multilingual field).
- `venues.maps[].name` and `maps[].description`.

Also update `web/assets/js/i18n.js` for the `event.type.*` and
`event.category.*` keys introduced in sub-task 01: replace any
duplicate-English Swedish slots with natural translations (e.g. "Trade
fair" → "Mässa", "Congress" → "Kongress", "Construction and real
estate" → "Bygg och fastighet", "Health & Medicine" → "Hälsa och
medicin", and so on for every type/category appearing in the seed).

## Validation

- `npm run test:unit` passes.
- Re-run the `availableKeys` parity test — should still pass.
- Toggle the language flag in the running app and:
  - Open the calendar — every event card title, subtitle, type, and
    category renders in Swedish.
  - Open at least one fully-seeded event (Nordbygg 2026) and visit
    Practical info — the venue copy (transport, parking, restaurants,
    security, sustainability, maps) and event overrides render in
    Swedish.
  - Open the ticket purchase flow on Nordbygg 2026 and confirm the
    questionnaire subjects render in Swedish.

## Scope (do not)

- Do **not** touch news, articles, program, exhibitors, speakers,
  add-ons, or merchandise — those are sub-tasks 03–05.
- Do **not** change the `pickLang` helper or the schema.
- Do **not** translate brand/proper names (event brand names like
  "Nordbygg", "ESTRO", restaurant brand names, person names).

## Notes

- Where the English copy contains "Simulated." prefixes (per the
  prototype convention), keep the prefix in Swedish too ("Simulerad.").
- Run translations through a quick sanity pass — these are
  user-facing and should read fluently to a Swedish-speaking visitor.
- Move this file to `agent/tasks_completed/` via `git mv` when done.
