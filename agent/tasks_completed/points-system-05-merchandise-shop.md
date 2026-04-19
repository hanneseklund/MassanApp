# Points system: merchandise shop

Fifth and final sub-task for issue #16
(https://github.com/hanneseklund/MassanApp/issues/16). Depends on
sub-tasks 02 and 03. Can run before or after 04; the two do not
share code paths beyond the shared points store.

## Scope

- Add a new `#/points` route and `views/points-shop.js` rendering
  the venue-wide `merchandise` catalog. This screen is reachable
  from the "Points" section on `#/me` (added in sub-task 03) and
  is independent of any event selection — no event is required to
  browse or redeem.
- Cards show image, name, description, points cost, and a Redeem
  button. Same disabled-with-message behavior as event add-ons
  when the balance is insufficient.
- On redeem: insert a `point_transactions` row with
  `source = 'merch_redemption'`, `source_ref = <merch_id>`,
  `event_id = NULL`, `delta = -points_cost`; show a confirmation
  screen with the simulated chip and return the user to the shop.
- Route handling in `stores/app.js`: `#/points` resolves to the
  new view. Signed-out visitors on `#/points` are routed through
  `auth` first and returned after sign-in, the same pattern food
  and purchase already use.
- Translation keys added to both `en` and `sv` in `i18n.js`.
- Smoke coverage: log in, earn points (e.g. via a simulated food
  order), navigate from `#/me` to the shop, redeem one item,
  verify balance updates and the transaction appears in the
  recent-transactions list.

## Definition of done for issue #16

With this sub-task merged:
- A signed-in visitor earns points on simulated ticket and food
  purchases, sees the balance on `#/me`, can redeem event-specific
  add-ons during the ticket flow, and can redeem venue merchandise
  at any time from the shop.
- The seed contains at least one add-on per fully-seeded event and
  a small merchandise catalog, mirrored in
  `web/data/catalog.json`.
- Spec changes are in place before each code change (AGENTS.md
  workflow rule).
- Issue #16 can be closed in the same PR that merges this sub-task.
