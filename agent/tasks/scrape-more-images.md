# Scrape more images

Find and include images for all content types across the app, not just events.

Reference: issue #11 (https://github.com/hanneseklund/MassanApp/issues/11)

## Scope

- Extend the image scraping/sourcing done for events (see
  `add-images-from-event-sources.md` in `tasks_completed`) to cover the
  remaining content types: news items, articles, exhibitors, and any other
  item types rendered in the app.
- For each content type, identify the source(s) already used for data and
  scrape representative images from there.
- Store and reference images consistently with the existing event-image
  approach.
- Wire images into the corresponding views so each item renders with an
  associated image where available.
- Handle missing images gracefully (placeholder or hidden), matching how
  events already handle this case.

## Notes

- Respect source sites' terms; keep attribution where provided.
- Keep image sizes reasonable for a mobile-first app.
