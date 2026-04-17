# Render Event Subviews From Seed

References:
- issue #1: Start project
- parent split: this task and the other `implement-*` siblings replace
  `implement-auth-ticketing-and-event-flows.md`, which was too large for a
  single session.

Objective:
- Replace the placeholder copy in each event subview with real content
  rendered from `web/data/catalog.json`, so a visitor can actually browse
  an event's news, articles, program, exhibitor index, exhibitor detail,
  and practical information.

Scope (do):
- News subview: chronological list of news items for the selected event
  with title, date, and body.
- Articles subview: list of long-form articles with title and body;
  render in a readable mobile layout.
- Program subview: sessions grouped by day and sorted by start time;
  each session shows title, time window, location, track, and
  description. Speaker names (looked up via `speaker_ids`) appear when
  present.
- Exhibitor index subview: searchable list (reuse the calendar search
  pattern) of the event's exhibitors, sorted alphabetically, showing
  name, booth, and short description.
- Exhibitor detail view: tapping an exhibitor opens a detail view with
  name, booth, description, and website link. Use a new hash route like
  `#/event/<event-id>/exhibitors/<exhibitor-id>` so it is linkable.
  "Back to exhibitors" returns to the index; the existing "Back to
  events" still returns to the calendar.
- Practical information subview: render the shared Stockholmsmassan
  venue data (transport modes, parking, restaurants, security, maps
  placeholder) followed by per-event `overrides` when present. Do not
  duplicate venue copy per event — it must read from the shared venue
  record.
- Update `docs/functional-specification.md` only if the implementation
  reveals a missing or incorrect user-visible behavior.

Scope (do not):
- Auth, ticket purchase, My Pages, My Tickets, newsletter signup or
  preferences — these belong to the other split tasks.

Acceptance Criteria:
- Opening `Nordbygg 2026` and each of its subviews shows seeded content
  instead of the "will appear here once event data is loaded"
  placeholders.
- Opening `ESTRO 2026` or `EHA2026 Congress` renders a multi-track
  program with at least one session that lists a speaker name.
- The same practical-info strings (transport, parking, restaurants,
  security) appear on at least two different events, per the shared
  venue regression check in
  `docs/installation-testing-specification.md`.
- Exhibitor detail pages are reachable via a linkable hash route and
  have a "Back to exhibitors" affordance.
- Placeholder subviews for Newsletter remain in place (implemented in a
  later task) and continue to show a "coming soon" message, not broken
  UI.
