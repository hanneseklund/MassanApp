# Keep events on the event list for three weeks after they have happened (issue #26)

Address issue #26: "keep events on the event list for three weeks after they have happened".

https://github.com/hanneseklund/MassanApp/issues/26

The issue body is empty — only the title is provided. Interpret it as: events should remain visible on the event list view for three weeks (21 days) after their end date, then drop off automatically.

## Scope

- Find where the event list is filtered/sorted (likely a view module under `web/assets/js/views/` plus any seed/data layer that exposes events) and adjust the visibility cutoff so an event that ended within the last 21 days is still shown.
- Make sure events that ended more than 21 days ago are excluded from the main event list.
- Decide and document whether "ended" means the event's end date/time or the start date when no end is available — pick the field that's already on the seeded events and call it out in the PR.
- Keep ordering sensible: ongoing/upcoming events first, recently-ended events after them (or however the current sort already works — don't regress it).
- Verify with the existing seed data plus, if needed, a tweaked fixture so at least one "ended within 3 weeks" and one "ended more than 3 weeks ago" case is exercised.

## Notes

- Reuse the existing time/date utilities and the existing event filter rather than introducing a new one.
- If the My Pages "chosen event" or other views key off the same list, double-check they still behave correctly for an event that has just ended (the user should still be able to see it in their history for the 3-week window).
- When done, move this file to `agent/tasks_completed/` via `git mv` and close issue #26 with a summary of what changed.
