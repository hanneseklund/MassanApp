# Keep recently-ended events on top of the event list (issue #26 follow-up)

Follow-up to issue #26 based on the new comment from hanneseklund (2026-04-29):

> keep old events on top of page even if they have ended, as if the current date is three weeks ago

https://github.com/hanneseklund/MassanApp/issues/26#issuecomment-4341092795

## Background

The original task (`agent/tasks_completed/keep-past-events-three-weeks.md`)
was implemented to keep events on the event list for three weeks after they
end. The user has now clarified the intended behaviour: those recently-ended
events should still appear at the **top** of the event list — i.e. the list
should sort/filter as if the current date were three weeks earlier, so that
events which ended within the last three weeks are treated as if they have
not yet ended.

## Scope

- Locate the current event-list filtering and sorting logic (added by the
  prior task — search for the 21-day / three-week cutoff in
  `web/assets/js/views/` and any seed/data layer).
- Change the behaviour so that the "current date" used for sorting (and any
  upcoming-vs-ended classification) is shifted three weeks into the past.
  Concretely: events that ended within the last 21 days should appear in
  the same on-top position they would have had three weeks ago — i.e.
  alongside / above ongoing and upcoming events, not relegated below them.
- The original three-week visibility window should still hold: events that
  ended more than 21 days ago drop off the list entirely.
- Make sure the visual indication of an event being "ended" / "past" is
  still correct for the user (we only want the *ordering* to behave as if
  it were three weeks ago, not to mislead the user about whether an event
  has actually ended).

## Notes

- Reuse the existing date utility / cutoff constant rather than
  duplicating it.
- Verify with the existing seed data plus, if needed, a fixture event that
  ended within the last 21 days and another that ended more than 21 days
  ago, so both code paths are covered.
- When done, move this file to `agent/tasks_completed/` via `git mv` and
  comment on / close issue #26 with a short summary of the change.
