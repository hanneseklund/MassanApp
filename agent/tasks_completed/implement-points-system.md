# Implement points system

Implement the points system as specified in issue #16 (https://github.com/hanneseklund/MassanApp/issues/16).

Summary of requirements from the issue:
- Users earn points when buying tickets and food at the venue.
- Users see their points balance on "My pages" in the app.
- Points cannot be used to buy tickets directly, but when users buy a ticket
  to an event they can purchase event-specific add-ons with points. Examples:
  a bag of presents from various exhibitors, or VIP access to specific
  program points within the event. These add-ons are points-only.
- There is also a points shop for Stockholmsmässan merchandise that is
  always available and independent of any event.

Refer to the issue for authoritative details before implementing.

## Outcome

This task was split into five runnable sub-tasks on 2026-04-19 because
a single session cannot responsibly land the schema, earning wiring,
My Pages surface, event add-on flow, and venue merchandise shop at
once. The sub-tasks live in `agent/tasks/`:

1. `points-system-01-spec.md`
2. `points-system-02-schema-and-earning.md`
3. `points-system-03-balance-on-my-pages.md`
4. `points-system-04-event-addons.md`
5. `points-system-05-merchandise-shop.md`

Issue #16 remains open until sub-task 05 lands.
