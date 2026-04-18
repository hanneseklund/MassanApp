# Modularize `web/assets/js/app.js`

## Problem

`web/assets/js/app.js` has grown to ~1,470 lines and now contains every
Alpine component, every Alpine store, the QR simulation, the simulated
payment and email helpers, and the newsletter preference utilities, all
as top-level functions in one file. The implementation specification
says (line 132) "Keep Alpine.js templates small and focused. One view
per file or section." The HTML side honors that rule — `index.html`
cleanly separates each view — but the JavaScript does not.

Concretely, the file today mixes:

- Utilities and constants (`ticketCtaLabel`, `SECTION_LABELS`,
  `QR_SALT`, date formatters).
- QR simulation (`ticketQrPayload`, `ticketQrMatrix`, `ticketQrSvg`,
  `ticketQrSvgFor`, plus the FNV-ish hash helper).
- Simulated payments and emails (`simulatedPayment`, `simulatedEmail`).
- Newsletter preference helpers (`defaultNewsletterPreferences`,
  `normalizeNewsletterPreferences`).
- Alpine stores: `app`, `session`, `catalog`, `tickets`,
  `newsletter`.
- View components: `calendarView`, `eventView`, `authView`, `meView`,
  `purchaseView`, `myTicketsView`, `newsletterSignup`,
  `newsletterPreferences`.

Reviewers have to navigate ~1,500 lines to follow a single change, and
it is easy to accidentally introduce cross-component coupling because
everything shares a top-level scope.

## Goal

Split `app.js` into a small number of buildless ES modules (still no
bundler, still served directly by Cloudflare Pages) so each component
and simulation lives in its own file. The public behavior — including
the Alpine `Alpine.store(...)` and component-factory names referenced
from `index.html` — must stay identical.

## Proposed layout

```
web/assets/js/
  app.js                    // Tiny entry: imports everything and
                            // registers stores + Alpine globals on
                            // `alpine:init`. Nothing else lives here.
  util/
    dates.js                // `formatDates`, helpers currently inline.
    sections.js             // `SECTION_LABELS`, `ticketCtaLabel`.
  simulations/
    qr.js                   // `ticketQrPayload`, `ticketQrSvgFor`,
                            // and internals.
    payment.js              // `simulatedPayment`.
    email.js                // `simulatedEmail`.
  newsletter/
    preferences.js          // `defaultNewsletterPreferences`,
                            // `normalizeNewsletterPreferences`.
  stores/
    app.js                  // Alpine.store("app", ...) definition.
    session.js              // Alpine.store("session", ...).
    catalog.js              // Alpine.store("catalog", ...).
    tickets.js              // Alpine.store("tickets", ...).
    newsletter.js           // Alpine.store("newsletter", ...).
  views/
    calendar.js             // `calendarView()`.
    event.js                // `eventView()`.
    auth.js                 // `authView()`.
    me.js                   // `meView()`.
    purchase.js             // `purchaseView()`.
    my-tickets.js           // `myTicketsView()`.
    newsletter-signup.js    // `newsletterSignup()`.
    newsletter-preferences.js // `newsletterPreferences()`.
```

`web/index.html` switches its single `<script src="assets/js/app.js">`
to `<script type="module" src="assets/js/app.js">`. Alpine itself can
stay as the existing `<script defer src=".../cdn.min.js">` tag.

## Acceptance criteria

1. `web/assets/js/app.js` is the module entrypoint and is under ~80
   lines. It imports every store factory and every view factory and
   registers them on `document.addEventListener("alpine:init", ...)`.
2. Every view factory and store factory referenced from
   `web/index.html` (`calendarView`, `eventView`, `authView`,
   `meView`, `purchaseView`, `myTicketsView`, `newsletterSignup`,
   `newsletterPreferences`, and the `Alpine.store(...)` ids) remains
   available with the same name. `index.html` templates must not need
   renaming.
3. `npm run smoke` passes locally and on the `agent` Cloudflare Pages
   preview deployment.
4. Spec files are updated in the same commit:
   - `docs/implementation-specification.md` under "Frontend app
     structure" documents the new folder layout and makes the
     one-view-per-file rule normative.
   - Any path references in other specs are fixed.
5. No behavior change. The smoke suite and the manual checklist in
   `docs/installation-testing-specification.md` produce the same
   results as before.

## Out of scope

- Adding a build step, TypeScript, or a bundler. The frontend stays
  buildless.
- Refactoring Alpine store internals beyond moving them into their
  own files. Keep diffs to `git mv`-style splits where possible.
- Any functional change to the simulations (QR, payment, email) or
  the newsletter preference shape.

## Workflow rule reminder

Per `AGENTS.md`: update
`docs/implementation-specification.md` (spec first) before moving any
code, then split the code, then re-read the README and the testing
spec to fix any drift the split introduces.
