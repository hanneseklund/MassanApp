# Add images from event sources

Scrape images from the sources of event information and include them in the app.

Reference: issue #6 (https://github.com/hanneseklund/MassanApp/issues/6)

## Scope

- Identify the source(s) of event information already used by the app (see
  `load-stockholmsmassan-event-data.md` in `tasks_completed` and the current
  seed/data files for starting points).
- Scrape representative images for events from those sources.
- Store the images so the app can reference them (decide: commit locally vs.
  load at runtime — pick the approach consistent with how event data is
  currently loaded).
- Wire the images into the event views so each event renders with an
  associated image where available.
- Handle the case where an event has no image gracefully (placeholder or
  hidden).

## Notes

- Respect the source sites' terms where reasonable; include attribution in
  the data if the source provides it.
- Keep image sizes reasonable for a mobile-first app.
