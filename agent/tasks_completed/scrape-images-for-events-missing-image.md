---
name: Scrape images for events missing image
issue: https://github.com/hanneseklund/MassanApp/issues/14
---

Implement issue #14: scrape images for the events that are currently
missing an image.

Steps:
- Identify which events in the seed data lack an image.
- Extend/adjust the existing scraping scripts to fetch images for those
  specific events from their source pages (Stockholmsmässan et al.).
- Store the images using the established asset convention and update the
  event records to reference them.
- Verify in the live preview that previously image-less events now render
  an image on both list and detail views.

Prior related work: `tasks_completed/scrape-more-images.md` and
`tasks_completed/add-images-from-event-sources.md`.
