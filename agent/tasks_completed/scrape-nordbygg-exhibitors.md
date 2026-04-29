# Scrape Nordbygg exhibitors (issue #29)

Implement issue #29: scrape real exhibitor info for Nordbygg from
https://exhibit.stockholmsmassan.se/nordbygg/12316 — including descriptive
texts and images.

https://github.com/hanneseklund/MassanApp/issues/29

## Scope

- Use the existing scraping setup (look at prior scraping tasks in
  `agent/tasks_completed/`, e.g. `load-stockholmsmassan-event-data.md`,
  `scrape-more-events-as-testdata.md`, `scrape-more-images.md`,
  `add-images-from-event-sources.md`) and follow the same conventions for
  storage, naming, and image handling.
- Crawl the Nordbygg exhibitor index page
  (`https://exhibit.stockholmsmassan.se/nordbygg/12316`) and each
  individual exhibitor's detail page.
- Capture for each exhibitor: name, descriptive text(s), category/tags if
  available, link back to source page, and the main image(s).
- Persist scraped data alongside the existing event seed data in whatever
  format the rest of the app already consumes (JSON seed file +
  downloaded image assets under the existing assets path).
- Wire the scraped exhibitors into the Nordbygg event in the app so they
  show up where exhibitors are rendered (or, if the app does not yet have
  an exhibitors view for an event, surface them in a sensible place — but
  prefer the smallest-scope change that makes the scraped data visible).

## Notes

- Do not commit a scraping run that hammers the source site — be polite
  (sequential requests, small delay) and cache results.
- Image assets should be checked into the repo (consistent with prior
  scraping tasks) unless they are unreasonably large; in that case flag
  it and ask before deviating.
- If the source page structure or anti-scraping measures block automated
  scraping, document what was tried and move this task to
  `agent/tasks_blocked/` with a clear question for the user.
- When done, move this file to `agent/tasks_completed/` via `git mv` and
  close issue #29 with a summary of what was scraped and where it lives.
