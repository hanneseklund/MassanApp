---
name: Real images on articles and news on Nordbygg 2026
issue: https://github.com/hanneseklund/MassanApp/issues/30
---

Implement issue #30: replace any drawn/placeholder/illustrated images on
articles and news items related to Nordbygg 2026 with real photographic
images. Each item must have a unique image (no reuse across items), and
each image must be relevant to that specific item's subject matter.

Steps:
- Identify all articles and news items associated with Nordbygg 2026 in
  the seed data.
- Audit current images for those items; flag any that are drawn,
  illustrated, generic, or duplicated across items.
- Source real photographs (relevant to each item's subject) from the
  event source pages or other appropriate channels, ensuring uniqueness
  per item.
- Store images using the established asset convention and update the
  records to reference them.
- Verify in the live preview that each Nordbygg 2026 article/news item
  shows its own unique, subject-relevant photo on both list and detail
  views.

Prior related work: `tasks_completed/scrape-more-images.md`,
`tasks_completed/add-images-from-event-sources.md`,
`tasks_completed/scrape-images-for-events-missing-image.md`.
