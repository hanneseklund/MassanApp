# Points system: specification

Per AGENTS.md's "specify first" workflow, nail down the points system
design before any code lands. This is the first of five sub-tasks that
together implement issue #16
(https://github.com/hanneseklund/MassanApp/issues/16); later sub-tasks
depend on decisions made here.

Update `docs/functional-specification.md` and
`docs/implementation-specification.md` to cover:

## Functional spec additions

- A user-facing points balance visible on "My Pages" for signed-in
  visitors. Anonymous / logged-out users never see a balance and never
  earn points.
- Earning rules:
  - Ticket purchases award points. Pick a simple prototype rule (e.g.
    10 points per simulated ticket, or 1 point per SEK of the simulated
    price) and write it down.
  - Food orders award points under the same rule.
  - Points are awarded as part of the existing simulated-payment
    confirmation step; a failed payment awards nothing.
- Two ways to spend points:
  1. Event-specific add-ons, offered as an optional fourth step of the
     existing ticket purchase flow after payment confirmation (or as a
     clearly-marked section on the event home after a ticket is owned —
     pick one and document the choice). Add-ons are points-only and
     cannot be purchased with currency. Examples from the issue:
     exhibitor gift bag, VIP access to a specific program item.
  2. A venue-wide points shop for Stockholmsmässan merchandise. Always
     available from "My Pages", independent of any event. Examples:
     tote bag, cap, notebook.
- Both spend paths deduct points atomically and create a persistent
  redemption record the user can see alongside their balance.
- Points do not expire in the prototype.
- Visually label the feature as simulated in the same way tickets and
  food orders are labelled.

## Implementation spec additions

- Data model additions. Proposed shape (refine during design):
  - `point_transactions` (id, user_id, event_id nullable, source
    (`ticket`, `food`, `addon_redemption`, `merch_redemption`),
    source_ref, delta int, created_at). The user's balance is
    `sum(delta)` over their rows. This avoids storing a denormalised
    balance that can drift.
  - `point_addons` (id, event_id, name, description, points_cost,
    image, stock nullable, active). Seed a small catalog per
    `Nordbygg 2026` and `ESTRO 2026` or `EHA2026 Congress`.
  - `merchandise` (id, name, description, points_cost, image, stock
    nullable, active). Venue-wide catalog, one shared set of rows.
  - Redemptions are represented as `point_transactions` rows with a
    negative delta plus the source row id stored in `source_ref`
    (redemption detail lives in `point_addons` / `merchandise`
    referenced by that id, so no separate redemption table is needed
    for the prototype unless review surfaces a reason to split it).
- Row Level Security:
  - `point_transactions`: a user can read only their own rows; inserts
    come from the frontend as part of the simulated purchase flow, so
    the insert policy is `auth.uid() = user_id`. Accept that a
    prototype frontend could theoretically insert arbitrary positive
    deltas — this matches the existing simulated-payment trust model
    and is called out in the spec.
  - `point_addons` and `merchandise`: public read, no client writes.
- Frontend additions:
  - `stores/points.js` — Alpine store exposing `balance`, `loading`,
    `error`, `earn({ source, source_ref, amount, event_id })`,
    `redeem({ source, source_ref, amount })`, and a transaction list
    getter. Subscribes to session changes the same way the other
    authenticated stores do.
  - `util/points.js` — earning-rate calculators (`pointsForTicket`,
    `pointsForFoodOrder`) so the rules live in one place.
  - `views/points-shop.js` — the venue-wide merchandise shop.
  - New `#/points` route for the shop. Event-specific add-ons live as
    a subview / section of the ticket purchase or event home flow as
    decided above and route accordingly.
  - Translation keys for all new chrome strings in both `en` and `sv`.
- Seed updates: add a handful of rows to `point_addons` (per seeded
  event) and `merchandise` in `supabase/seed/seed.sql`, and mirror the
  shape in `web/data/catalog.json`.
- Testing: the installation/testing spec must describe how to verify
  the earn/spend loop manually and call out any new smoke-test
  coverage needed.

## Deliverables

- Updates to `docs/functional-specification.md`,
  `docs/implementation-specification.md`, and
  `docs/installation-testing-specification.md`.
- No code, schema, or seed changes in this task. Those land in
  sub-tasks 02–05.
- If any design decision here needs user input, ask on issue #16 and
  move this task to `agent/tasks_blocked/`.

## Follow-up tasks (already queued)

- `points-system-02-schema-and-earning.md` — migration, seed, and
  wiring points earning into the ticket + food purchase flows.
- `points-system-03-balance-on-my-pages.md` — surface the balance and
  recent redemptions on `#/me`.
- `points-system-04-event-addons.md` — event-specific points-only
  add-ons on the ticket flow.
- `points-system-05-merchandise-shop.md` — venue-wide points shop at
  `#/points`.
