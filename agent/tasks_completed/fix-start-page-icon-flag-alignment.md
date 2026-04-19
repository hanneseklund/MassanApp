# Fix right-justification of me icon + language flags on start page

Follow-up to issue #10 (https://github.com/hanneseklund/MassanApp/issues/10)
per new comment:
https://github.com/hanneseklund/MassanApp/issues/10#issuecomment-4275255157

The user reports that the "me" icon and language flags are not right-justified
on the start page where all events are listed. Verify the header/menu layout on
that page and ensure both are right-justified there, matching behavior on other
pages.

## Resolution (2026-04-19)

Root cause: `.chrome` uses `grid-template-columns: 1fr auto 1fr`, with the back
button intended for column 1, the title for column 2, and the actions cluster
for column 3. None of those columns were assigned explicitly. On the start page
the back button has `x-show="$store.app.view !== 'calendar'"`, which Alpine
implements with `display: none` — that removes the back button from the grid,
so CSS Grid auto-placement re-flows the remaining items into the first
available cells: title → col 1, actions → col 2, leaving col 3 empty. The
`justify-self: end` on `.chrome__actions` then only pushed the cluster to the
right edge of the centre `auto` column — visually mid-page, not right.

Fix: pin each chrome child to its intended column.

- `web/assets/css/app.css` — added `grid-column: 1` to `.chrome__back`,
  `grid-column: 2` to `.chrome__title`, and `grid-column: 3` to
  `.chrome__actions`. The actions cluster now sits flush to the chrome's right
  padding regardless of whether the back button is shown.
- `tests/playwright/smoke.spec.js` — added "Chrome layout" describe block with
  step 31 asserting that `.chrome__actions`'s right edge equals `.chrome`'s
  right edge minus the chrome's right padding (within 1px) on the calendar
  view.
- `docs/installation-testing-specification.md` — added step 31 under a new
  "Chrome layout" subsection in the Smoke test checklist, mirroring the
  automated assertion.

Could not execute `npm run smoke` in this sandbox (Playwright's bundled
chromium-headless-shell is not installed here — same constraint noted in
`agent/tasks_completed/revisit-language-support-2.md`). `npm run test:unit`
still passes (59/59); the change is CSS-only with no impact on the unit
suites.
