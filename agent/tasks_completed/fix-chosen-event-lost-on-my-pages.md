# Fix: chosen event lost when navigating to My Pages / My Tickets

See issue #22: https://github.com/hanneseklund/MassanApp/issues/22

## Problem

When navigating to My Pages or My Tickets (and ending up on the login page),
the app forgets the chosen event.

## Requirements

1. Event context should always prevail, even in My Pages / My Tickets flows
   (including the login redirect flow).
2. On the My Tickets view, tickets for the currently selected event should
   be listed on top; tickets for other events appear below, if any.

## Notes

- Investigate how the selected event is persisted (likely localStorage /
  Alpine store) and confirm it survives the login redirect.
- Confirm the sort/group logic for My Tickets against the selected event.
