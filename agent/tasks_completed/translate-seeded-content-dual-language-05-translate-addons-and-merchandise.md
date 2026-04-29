# Translate seeded content — 05: point add-ons and merchandise

References:
- issue #27 follow-up comment:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409
- parent split: see `translate-seeded-content-dual-language.md` and the
  five sub-tasks. Depends on `-01-shape-and-render-helpers.md` having
  landed.

## Objective

Backfill Swedish translations for the point-system catalog: per-event
add-ons and venue-wide merchandise.

## Scope (do)

In `supabase/seed/seed.sql` (and the `web/data/catalog.json` mirror),
write Swedish copy for the `name` and `description` fields on every
row in:

- `public.point_addons` — roughly six rows (Nordbygg + ESTRO add-ons).
  Examples to translate:
  - "Exhibitor gift bag" → "Utställargåvopåse" (or similar natural
    rendering)
  - "Sustainability Stage seat reservation" → "Sittplatsreservation,
    Hållbarhetsscenen"
  - "Event catalog hardcover" → "Evenemangskatalog inbunden"
  - … etc. Use natural Swedish phrasing.
- `public.merchandise` — venue-wide souvenir catalog. Examples:
  - "Stockholmsmassan tote bag" → "Stockholmsmässan-tygkasse"
  - "Stockholmsmassan cap" → "Stockholmsmässan-keps"
  - "Notebook" → "Anteckningsbok"
  - "Enamel pin" → "Emaljpin"

Keep the "Simulated …" / "Simulerad …" prefix convention consistent
with the other prototype copy.

## Validation

- `npm run test:unit` passes.
- Toggle the language flag in the running app:
  - On Nordbygg 2026 (with a simulated ticket purchased to surface
    the add-on grid), every add-on card name and description renders
    in Swedish.
  - On the points shop (`#/points`), every merchandise name and
    description renders in Swedish.
  - The redemption confirmation banner (`event.addons_confirmed_body`
    / `shop.confirmed_body`) interpolates the picked-language item
    name correctly. If the banner currently uses a persisted English
    label for the redeemed item, verify that's still the right
    behaviour (consistency with the points-balance transaction log)
    or update it to use the live-translated name. Document the
    decision in the PR.

## Scope (do not)

- Do **not** change `points_cost`, `image`, or `stock` values — copy
  is the only thing in scope.
- Do **not** alter the redemption flow itself.

## Notes

- After this sub-task lands, all five sub-tasks of the
  `translate-seeded-content-dual-language` umbrella are done. As the
  final sub-task, post a short milestone comment on issue #27
  summarising the rollout (schema shape, sub-task list, "ready for
  review") and consider whether to close the issue or leave that to
  the user.
- Move this file to `agent/tasks_completed/` via `git mv` when done.
- Move the umbrella file
  `translate-seeded-content-dual-language.md` (already in
  `agent/tasks_completed/` from the splitting step) — no further
  action needed there.
