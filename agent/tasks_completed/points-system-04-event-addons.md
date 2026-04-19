# Points system: event-specific add-ons

Fourth of five sub-tasks for issue #16
(https://github.com/hanneseklund/MassanApp/issues/16). Depends on
`points-system-02-schema-and-earning.md` (schema + seed) and
ideally 03 (so reviewers can see the balance update after a
redemption).

## Scope

- On the ticket purchase confirmation screen (or as a section on
  the event home view for users who already own a ticket — whichever
  the spec in sub-task 01 chose), surface the `point_addons` rows
  for the active event with `active = true`.
- Each add-on card shows: image, name, description, points cost,
  and a "Redeem" button.
- The Redeem button is disabled with an explanatory message when
  the user's balance is below the cost. Signed-out or
  ticketless users are routed through the existing auth / purchase
  path first, matching how the food flow handles it.
- On redeem:
  - Insert a `point_transactions` row with
    `source = 'addon_redemption'`, `source_ref = <addon_id>`,
    `event_id = <event_id>`, `delta = -points_cost`.
  - Show a success confirmation reusing the same simulated-chip
    pattern as ticket/food confirmations.
  - Update the balance in place via the points store.
- Keep the existing "View ticket" affordance on event home so the
  new section does not displace it.
- Translate all chrome strings in `en` and `sv`.
- Add smoke coverage: log in, purchase a ticket (earns points),
  redeem an add-on, verify balance deducted and the confirmation
  screen renders.

## Constraints

- Stock: if a row has `stock` set and `>0`, allow redemption and
  decrement visually in the UI for this session. A real stock
  decrement is out of scope — document this as a prototype
  simulation in the spec if it hasn't already been.
- Redeeming does not create a "shippable" artefact in the
  prototype; the confirmation screen is the whole user-visible
  result.

## Deliverables

- `point_addons` rows rendered on the correct screen for the two
  fully-seeded events.
- Successful redemption produces a `point_transactions` row with
  negative delta visible on the recent-transactions list on
  `#/me`.
