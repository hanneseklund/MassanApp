---
name: Revisit scrape more images
issue: https://github.com/hanneseklund/MassanApp/issues/11
---

Issue #11 has new activity (likely reopened) — the previous attempt
(`tasks_completed/scrape-more-images.md`) did not fully resolve it.

Re-check the current state of image coverage across all content types
(events, news items, articles, exhibitors, etc.) and complete what is
still missing. Investigate why the prior attempt was insufficient before
re-doing work.

## Verification (2026-04-19)

Checked both GitHub state and on-disk coverage. Issue #11 is still
closed — no reopen event in the timeline; the last activity was the
bot's own "Done" comment (commit b1e657f). The "revisit" signal was a
false positive.

Coverage verified against `web/data/catalog.json`:
- 42/42 events have `branding.hero_image`, all resolving to files in
  `web/assets/images/events/`.
- 7/7 news, 3/3 articles have `hero_image` resolving to files.
- 15/15 exhibitors have `logo`, 3/3 speakers have `avatar` (inline
  initial-based SVGs per `_image_credits`).
- Program items (schedule rows) intentionally have no image.

No further action needed.
