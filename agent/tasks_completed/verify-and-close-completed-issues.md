# Verify completed work against open agent issues and close them

Recent activity surfaced six `agent`-labelled issues that already have
matching files in `agent/tasks_completed/`. Confirm the work satisfies each
issue and close the issues (with a short pointer to the relevant commits /
live preview) so they stop resurfacing as "new activity".

## Issues to verify

- #1 Start project — covered by `research-stockholmsmassan-and-venue-apps.md`,
  `write-prototype-specification-and-agents-guide.md`,
  `scaffold-mobile-first-alpinejs-prototype.md`,
  `load-stockholmsmassan-event-data.md`,
  `implement-auth-and-my-pages.md`,
  `implement-ticket-purchase-and-my-tickets.md`,
  `implement-newsletter-signup-and-preferences.md`.
- #4 cloudflare pages configured — covered by
  `document-cloudflare-pages-preview.md`.
- #6 add images — covered by `add-images-from-event-sources.md` and
  `scrape-more-images.md`.
- #7 graphical style — covered by
  `apply-stockholmsmassan-graphical-style.md`.
- #9 scrape more events as testdata — covered by
  `scrape-more-events-as-testdata.md`.
- #10 me icon + language flags — covered by
  `me-icon-and-language-flags.md` and
  `fix-start-page-icon-flag-alignment.md`.

## Steps

1. For each issue, re-read the issue body and skim the referenced completed
   task(s) plus the actual code / docs to confirm every requirement is met.
2. For #1, double-check the full requirement list (calendar, registration,
   my pages, tickets, my tickets, event subviews with news/articles/program/
   exhibitors/practical info, newsletter, single-event focus with clear
   "other events" navigation) against the live app.
3. Re-check the issue on GitHub for any new comments not shown in the
   activity digest — if a comment introduces new requirements, spin off a
   fresh task in `agent/tasks/` instead of closing.
4. If satisfied, close the issue with a one-line comment pointing at the
   live preview (https://agent.massanapp-prototype.pages.dev/) and the
   relevant commit(s).
5. If something is missing or ambiguous, open a new focused task in
   `agent/tasks/` describing exactly what is left, and leave the issue
   open.

## Notes

- Do not create duplicate implementation tasks for work that is already
  done — prefer closing the issue or writing a narrowly-scoped follow-up.
- Keep comments on issues short; link rather than summarise.
