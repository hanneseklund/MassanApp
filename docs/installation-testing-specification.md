# MassanApp Installation and Testing Specification

This document explains how to install, run, and verify the MassanApp
prototype locally. It is derived from `docs/implementation-specification.md`
and must stay consistent with it.

## Prerequisites

- Git.
- Node.js (LTS). Node is used for tooling such as a static dev server and
  for running Supabase CLI scripts. The frontend itself does not require a
  build step.
- Any modern mobile-capable browser. Chrome DevTools device emulation is
  the recommended way to verify mobile-first behavior.
- Optional: the Supabase CLI, if working against a local or remote
  Supabase project.

No paid tooling is required to run the prototype locally.

## Getting the code

```
git clone https://github.com/hanneseklund/MassanApp.git
cd MassanApp
```

## Shared Supabase backend

The prototype uses a single shared Supabase project for all testing,
both from the `agent` branch Cloudflare Pages deployment
(`https://agent.massanapp-prototype.pages.dev/`) and the `main` branch
deployment. There is no per-branch, per-developer, or per-environment
backend.

- Project: `massanapp-prototype`
- Ref: `esvyrbsypfgpdhijyywz`
- URL: `https://esvyrbsypfgpdhijyywz.supabase.co`
- Region: `eu-north-1`
- Only the publishable (anon) key is used from the frontend. Row Level
  Security (see `supabase/migrations/0001_init.sql`) enforces
  per-user access for tickets and newsletter subscriptions.

Because the shared project serves both deployments, schema and seed
changes are applied to it immediately when they are developed — see
the rule in `AGENTS.md` under "Publishing database changes". A migration
that is in the repository but not yet applied to the shared project is
a bug and will break the `agent` deployment.

## Running the frontend

The frontend reads its catalog (venue, events, news, articles, program,
exhibitors, speakers) from the shared Supabase prototype project on
every load. An internet connection and the committed Supabase config
in `web/assets/env.js` are required; there is no offline fallback.

1. Start a static HTTP server from the `web/` directory. Any minimal
   server works; examples:

   - `npx http-server web -p 8080`
   - `python3 -m http.server 8080 --directory web`

2. Open `http://localhost:8080/` in a browser.

3. In DevTools, switch to a mobile device emulation profile (for example
   iPhone 14) to confirm mobile-first behavior.

4. To run the automated smoke suite against the same local server, use
   `npm install` once and then `npm run smoke` from the repo root. The
   script starts its own http-server instance and executes the
   Playwright suite in `tests/playwright/`. See "Automated smoke suite"
   below for configuration and teardown behavior.

To point a local dev run at a different Supabase project (an escape
hatch, not the default), create `web/assets/env.local.js` (gitignored)
that reassigns `window.MASSANAPP_ENV`. Otherwise the Cloudflare Pages
deployments and local dev both hit the shared project.

Authentication, ticket purchase, and newsletter signup all talk to the
shared Supabase project: accounts are created in Supabase Auth,
purchased tickets insert rows into `public.tickets` under Row Level
Security, and newsletter signups insert rows into
`public.newsletter_subscriptions`. Payments and Google / Microsoft
sign-in remain simulated — see "Known simulated behaviors" below.

For this to work the shared project's Auth configuration must have
email confirmation disabled (so `signUp` returns a usable session
immediately) and anonymous sign-ins enabled (so the simulated
Google / Microsoft buttons can create a session without real OAuth).
Both settings live in the Supabase dashboard under Authentication →
Providers / Sign In.

### Smoke testing against the shared project

Because every local run, every `agent` deploy, and every `main` deploy
shares one Supabase project, a smoke-test run leaves rows behind in
`auth.users`, `public.tickets`, `public.newsletter_subscriptions`,
`public.food_orders`, and `public.point_transactions`. The prototype
does not reset the database between runs. When running the checklist:

- Prefer a deterministic `@example.com` email address per tester (for
  example `smoke+your-initials@example.com`). Reusing the same address
  across runs means `signUp` will refuse after the first run, so sign
  in instead of registering on subsequent runs.
- Simulated Google / Microsoft runs produce an anonymous
  `auth.users` row each time. This is acceptable prototype behavior;
  they can be cleaned up from the Supabase dashboard if the list
  becomes noisy.

`web/data/catalog.json` is kept in the repo as a reference copy of the
seed shape for reviewers. It is not loaded by the running app.

## Applying migrations and seed to the shared project

Agents working in Claude or Claude Code apply migrations through the
Supabase MCP rather than the `supabase` CLI:

- Schema change: `mcp__claude_ai_Supabase__apply_migration` with
  `project_id=esvyrbsypfgpdhijyywz`, a snake_case `name` matching the
  filename (for example `0002_add_user_profiles`), and the SQL body
  copied from `supabase/migrations/NNNN_name.sql`.
- Seed change: `mcp__claude_ai_Supabase__execute_sql` with
  `project_id=esvyrbsypfgpdhijyywz` and the updated `supabase/seed/seed.sql`.

If you do not have MCP access, the Supabase CLI equivalents are:

```
supabase link --project-ref esvyrbsypfgpdhijyywz
supabase db push
psql "$SUPABASE_DB_URL" -f supabase/seed/seed.sql
```

## Hosted preview

A Cloudflare Pages deploy mirrors the `agent` branch at
<https://agent.massanapp-prototype.pages.dev/>. Any push to `agent` is
auto-published, so the preview reflects the latest committed state on
that branch — uncommitted local changes are not visible there until they
are pushed.

Use the hosted preview when a reviewer or tester wants to exercise the
prototype without installing Node, cloning the repo, or running a local
server. Run it locally instead when you need to test changes that are
not yet committed, or when you need to point the frontend at a Supabase
project using a local `env.local.js`.

The hosted build reads its catalog, authentication, tickets, and
newsletter subscriptions from the shared Supabase prototype project via
the committed `web/assets/env.js`, so a local run and the hosted
preview share one database. Payments and Google / Microsoft sign-in
remain simulated — see "Known simulated behaviors" below.

## Environment variables

The prototype reads a small number of values at runtime:

- `SUPABASE_URL` — Supabase project URL. Committed for the shared
  prototype project; overridable via `web/assets/env.local.js` for
  local dev against a different project.
- `SUPABASE_ANON_KEY` — Supabase publishable (anon) key. Committed
  alongside the URL for the same reason; RLS enforces access.

No service-role key is ever required or used by the frontend.

## Smoke test checklist

Before marking a change ready for review, run through this checklist in
mobile emulation. Each item maps to acceptance criteria in
`docs/functional-specification.md`.

The checklist is phrased as numbered action/assert steps so it can be
executed by a human in a browser or by the automated Playwright suite
in `tests/playwright/smoke.spec.js`. The two must stay in sync; a new
step here requires a matching assertion in the suite, and vice versa.

The checklist can be run against either a local server (for uncommitted
changes or Supabase-backed builds) or the hosted preview at
<https://agent.massanapp-prototype.pages.dev/> for changes that have
already been pushed to the `agent` branch — see the Hosted preview
section above for the caveats.

### Calendar and event selection

1. Open the app. Assert: a brief "Loading events…" hint appears and
   then the calendar shows at least one event card (the Supabase
   catalog load resolved without error).
2. Select a type filter such as "Trade fair" and a month filter.
   Assert: the event list updates and only matching cards remain.
3. Clear the filters and search for `Nordbygg` in the free-text box.
   Assert: the `Nordbygg 2026` card appears in the results.
4. Tap `Nordbygg 2026`. Assert: the chrome title becomes
   `Nordbygg 2026`, the calendar is no longer visible, and the URL
   hash becomes `#/event/nordbygg-2026`.

### Event content

5. From `Nordbygg 2026`, open each of News, Articles, Program,
   Exhibitors, Practical info, Food, and Newsletter in turn by
   scrolling the stacked landing and following each section's
   "see all" link (or the matching hamburger-menu entry). Assert:
   each subview either renders content or a documented empty-state
   placeholder. The Food dedicated page renders the ten-menu picker
   even while signed out — it only requires sign-in to confirm an
   order.
6. From the Exhibitors index, open one exhibitor. Assert: the
   exhibitor detail view renders and a "Back to exhibitors" button is
   visible.
7. Open Practical info. Assert: the shared Stockholmsmassan facts are
   present — at minimum the word `Alvsjo` appears in transport copy,
   and "Parking", "Restaurants and cafes", and "Security and entry"
   sections render.
8. Open the hamburger menu in the top-left chrome and pick the
   "Other events" entry. Assert: the URL hash returns to `#/` and
   the calendar is visible again.

### Congress archetype

9. From the calendar, open `ESTRO 2026` (or `EHA2026 Congress`).
   Assert: the event home view loads with the event name in the chrome
   title and the ticket CTA reads "Register as delegate".
10. Open Program. Assert: at least one day heading and one session row
    render.
11. Open Practical info. Assert: the shared venue facts render for this
    event too (same transport / parking / restaurants / security
    sections as Nordbygg).

### Registration and sign-in

12. From My Pages (while signed out) choose "Sign in or register" and
    register with a deterministic `@example.com` email (see "Test
    account strategy" below). Assert: the session becomes signed-in —
    My Pages shows the email and a "Sign out" button — without
    requiring email confirmation. (If the email is already registered
    from a prior run, sign in instead; both outcomes count as pass.)
13. Sign out. Assert: the signed-out placeholder returns.
14. Sign back in with the same email and password. Assert: My Pages
    again shows the signed-in state.
15. From the auth view choose "Continue with Google". Assert: the
    session becomes signed-in, My Pages shows "Signed in with Google"
    and a `simulated` chip, and the user is distinct from the email
    user from step 12.

### Ticket purchase (simulated)

16. While signed out, open `Nordbygg 2026` and tap "Get tickets".
    Assert: the app navigates to the auth view.
17. Sign in with the step-12 account. Assert: the app returns to the
    purchase view (hash `#/event/nordbygg-2026/purchase`).
18. Step 1: pick "Day pass". Step 2: fill the questionnaire — pick a
    visit type ("Professional" exposes optional company/role rows) and,
    if the event has a subjects block, tick at least one subject.
    Step 3: keep the defaulted attendee name and email, confirm the
    order summary shows event name, dates, and price. Step 4: confirm.
    Assert: the confirmation screen shows a `simulated` chip, a
    transaction reference, and a rendered QR SVG. Assert: a
    `[simulatedEmail] ticket_confirmation` entry is logged to the
    browser console.
19. From the confirmation, open My Tickets. Assert: a ticket for
    `Nordbygg 2026` appears with ticket type label, attendee name,
    attendee email, a purchase date, and an SVG QR code.
20. Return to `Nordbygg 2026`. Assert: the event home now shows both
    "Get tickets" and "View ticket" CTAs. Tap "View ticket" and
    assert: the app navigates to My Tickets (hash `#/tickets`) and the
    Nordbygg ticket is visible.
21. Open `ESTRO 2026`, tap "Register as delegate", and complete the
    flow. Assert: the questionnaire step pre-fills the visit type
    saved during step 18 (no manual re-entry of the general profile).
    Pick at least one subject and confirm. Assert: the delegate
    ticket appears in My Tickets alongside the Nordbygg ticket.
22. Reload the page. Assert: the session is restored and both tickets
    still appear in My Tickets.

### Newsletter

23. Sign out. Open `Nordbygg 2026` → Newsletter, submit the form with
    a fresh `@example.com` address. Assert: the success state renders
    and a `[simulatedEmail] newsletter_confirmation` entry is logged.
24. Reload the page and open the same Newsletter subview. Assert: the
    form returns to its blank state (the anonymous row is not visible
    through RLS).
25. Sign in again. Open `Nordbygg 2026` → Newsletter and submit.
    Assert: the success state renders with the signed-in email
    prefilled.
26. Open My Pages → Newsletter preferences. Assert: the Nordbygg
    subscription is listed.
27. Toggle one per-event topic off and reload. Assert: the toggle
    state persists.
28. Toggle "All Stockholmsmassan events" on and reload. Assert: the
    venue-wide toggle stays on. Toggle it off and reload. Assert: the
    toggle stays off.

### Food ordering (simulated)

29. Sign in with the step-12 account. Open `Nordbygg 2026` → Food.
    Assert: the menu picker renders at least one menu card.
30. Pick the first menu card (`Classic Burger`) and tap Continue. Keep
    the "Pick up in the venue" delivery mode, pick the first pickup
    location (`North Entrance kiosk`), and tap "Pay and order".
    Assert: the confirmation title reads "Order confirmed" alongside a
    `simulated` chip, the transaction reference starts with `SIM-`,
    the confirmed ticket card shows the menu label `Classic Burger`,
    and the pickup instructions name `North Entrance kiosk`.
31. With the confirmation still on screen, open the language dropdown
    in the top chrome and pick Swedish. Assert: the chrome copy and
    the confirmation's template prose switch to Swedish, but the
    persisted menu label (`Classic Burger`) and pickup location
    (`North Entrance kiosk`) in the confirmed ticket card stay in
    English — `menu_label` and `delivery_label` in
    `public.food_orders` are canonical English, same rule as
    `ticket_type_label` in `public.tickets`. Open the dropdown again
    and pick English to restore English for the next step.
32. Tap "Order another". Pick the first menu, Continue, switch
    delivery to "Book a restaurant slot", pick `Smakverket`, pick the
    first timeslot, and tap "Pay and order". Assert: the confirmation
    references both the chosen restaurant (`Smakverket`) and the
    timeslot in the instructions paragraph.

### Points (simulated)

These steps assume the step-12 account has just completed the ticket
purchase (step 18) and the food order (step 30) earlier in the run,
so the balance is non-zero before the first check here.

33. Open My Pages. Assert: a "Points" section is visible showing a
    non-zero balance (at least 100 from the Nordbygg ticket plus the
    food-order earns), a "how you earn points" blurb, a link to the
    points shop, and a recent-transactions list containing at least
    a ticket-source entry for Nordbygg 2026 and a food-source entry.
    The section carries the `simulated` chip used elsewhere.
34. Sign out. Assert: the Points section is no longer visible — a
    signed-out visitor never sees a balance.
35. Sign back in with the step-12 account. Open `Nordbygg 2026`.
    Assert: an "Event add-ons" section is visible on the event home
    view alongside "View ticket", and lists at least one add-on
    card for Nordbygg with name, description, points cost, image,
    and a Redeem button. The `simulated` chip is present.
36. Tap Redeem on an add-on whose points cost is at or below the
    current balance. Assert: a confirmation screen renders with the
    `simulated` chip and the add-on name, the My Pages balance
    decreases by the cost when revisited, and a negative
    `addon_redemption` transaction is listed in the recent
    transactions.
37. Open `#/points` from the Points section on My Pages. Assert:
    the venue-wide merchandise shop renders with at least the
    seeded items (for example tote bag, cap, notebook, enamel pin).
    Cards whose cost exceeds the current balance render the Redeem
    button disabled with an explanatory message.
38. Redeem a merchandise item the balance covers. Assert: a
    confirmation screen renders, the shop returns afterwards, and
    My Pages shows the new negative `merch_redemption` transaction
    and a reduced balance.

### Language toggle

39. From any view, open the language dropdown in the top chrome (the
    single button shows the active language's flag and a chevron;
    `aria-expanded` flips to `true` on open) and pick the other
    language from the listbox. Assert: the chrome title, primary nav
    labels, and hint copy switch language, and the dropdown collapses
    (`aria-expanded` returns to `false`). Reload the page. Assert: the
    choice is preserved.
40. Open the dropdown again and pick English. Assert: the chrome
    re-renders in English without requiring a reload, and the
    dropdown closes on outside click or the Escape key. Event content
    (event names, summaries, news, articles, exhibitor copy,
    practical-info venue copy) stays in the language it was seeded in
    regardless of the toggle.

### Chrome layout

41. Open the start page (calendar of events). Assert: the language
    dropdown toggle and the "me" silhouette icon sit flush against
    the right edge of the chrome (within the chrome's right padding),
    matching their position on event subviews.

## Automated smoke suite

The automated counterpart to the checklist lives at
`tests/playwright/smoke.spec.js` and is driven by Playwright.

### Running it

From the repo root:

```
npm install      # once, to pull playwright + http-server
npx playwright install chromium  # once, to fetch the browser binary
npm run smoke
```

`npm run smoke` launches http-server on `http://127.0.0.1:8787/`
serving `web/`, runs the suite, and shuts the server down when done.
Port 8787 is used to avoid the 8080 / 8081 ports that the manual
instructions above and many local dev tools occupy; override it with
`PW_PORT=8080 npm run smoke` if needed. To run against a different URL
(for example the hosted preview) pass
`PW_BASE_URL=https://agent.massanapp-prototype.pages.dev npm run smoke`.

The suite uses the Playwright "Pixel 7" device profile (Chromium
engine, smartphone viewport). The manual checklist uses iPhone 14 in
Chrome DevTools; both are Chromium, so behavior matches even if the
reported user agent differs.

### Test account strategy

Because the shared Supabase project is not reset between runs, the
suite uses a deterministic email and password per repo checkout:

- Email: `smoke+e2e@example.com`
- Password: `MassanApp-smoke-2026!`

The first run registers the account; subsequent runs sign in instead
(`signUp` returns a "User already registered" error, which the suite
treats as a pass signal and falls back to `signIn`). Simulated Google
sign-in, anonymous newsletter signups, and simulated food orders leave
additional `auth.users`, `public.newsletter_subscriptions`, and
`public.food_orders` rows behind on every run; this is accepted
prototype behavior and noisy rows can be cleaned up from the Supabase
dashboard.

The suite does not truncate any Supabase tables. A cleaner teardown
would require a service-role key, which this repository does not ship.

### Coverage

Every numbered item in the checklist above maps to at least one
assertion in the suite. When the checklist changes, update the suite
in the same pull request.

## Unit tests

Pure-function helpers in the frontend (hash routing in
`stores/app.js` plus the store's stateful navigation verbs —
`goCalendar`, `selectEvent`, `goEventSubview`, `selectExhibitor`,
`backToExhibitors`, `goAuth`, `goMe`, `goTickets`, `goPoints`,
`startPurchase`, `afterAuth` — and its `_applyHash` redirect for
scroll-only subviews, date formatting in `util/dates.js`, ticket-type
catalog and stacked-layout section order in `util/sections.js`,
calendar filter/sort in `util/calendar.js`, newsletter-preference
shape in `newsletter/preferences.js`, the QR payload builder in
`simulations/qr.js`, the transaction-ref format of
`simulations/payment.js` that both the ticket and food flows
resolve against, the prototype-host allowlist in
`simulations/email.js` that gates the `[simulatedEmail]` console
log, the UI translation lookup in `i18n.js` plus a meta-check
that walks `web/` for literal `t('...')` callsites and asserts
each referenced key is in the dictionary, the
deterministic exhibitor/speaker placeholder SVGs in
`util/placeholders.js`, the food-ordering catalog and the
`upcomingTimeslots` next-half-hour generator in `util/food.js`
that back the Food subview's menu picker and restaurant
timeslots, the catalog-store selectors in
`stores/catalog.js` that fan per-event rows into views, the
ticket-ownership selectors in `stores/tickets.js`
(`forUser`, `forUserAndEvent`, `hasForEvent`) that back the
"View ticket" CTA and the My Tickets list, the food-orders
store `forUser` selector in `stores/food-orders.js` that scopes
persisted orders to the signed-in user, the earning-rate
calculators in `util/points.js`
(`pointsForTicket`, `pointsForFoodOrder`) and the points-store
balance selector in `stores/points.js` that sums `delta` across a
user's rows, the newsletter-store
lookup in `stores/newsletter.js` (`forUser`, `findForEvent`)
that resolves the per-event / venue-wide subscription a signup
form should update vs. insert, the shared sign-in / sign-out
fetch contract and the shared user-owned-row insert contract in
`util/session-sync.js` (`loadUserRows`, `insertOwnedRow`, and
`notifySessionStores`) that the four user-scoped stores
delegate their `_onSessionChange` to and that the tickets, food
orders, and points inserts delegate through, the lang-store
wiring in
`stores/lang.js` (persisted-language validation, `set()`'s
same-language guard, storage / `<html lang>` side effects, and
the `t()` / `dateLocale()` delegation to the i18n helpers),
the Supabase-user mapping in `stores/session.js` that resolves
the signed-in provider, display name, and simulated flag,
the shared redemption controller in `util/redemption.js`
(`createRedemptionController`) that backs the event add-ons
section and the venue-wide points shop — `remainingStock`,
`canRedeem`, `disabledReason`, and the `redeem` writer that
delegates to the `points` store, and the ticket-purchase
questionnaire helpers in `util/questionnaire.js`
(`defaultQuestionnaire`, `subjectsFor`,
`buildQuestionnairePayload`, `buildProfileUpdate`,
`PROFILE_FIELDS`) that seed the form state from a saved
profile and serialize it back into the JSONB shape written
to `public.tickets.questionnaire`) have a fast unit suite
under `tests/unit/` that does not require a browser or
Supabase.

The suite runs against the same source files the browser loads —
tests import the ES modules under `web/assets/js/` directly, so a
behavior drift in a helper fails unit tests before the slower smoke
suite runs. Tests are `.mjs` files driven by Node's built-in
`node:test` runner, so no extra dependency is needed beyond Node
itself.

Run them from the repo root:

```
npm run test:unit
```

When the smoke suite changes to rely on a new pure helper, add a
unit test for that helper in the same pull request. The unit suite
is orthogonal to the Supabase-backed smoke suite — both must pass
before a change ships.

## Regression checks for shared venue data

When editing venue-shared content:

- Verify the same practical-info strings appear on at least two different
  events.
- Verify that an event-specific override only changes that event and
  does not leak to other events.

## Known simulated behaviors

These are expected in the prototype and are not bugs:

- Payments succeed without real charges. The same `simulatedPayment`
  helper backs both ticket purchase and food ordering, so a food order
  also resolves with a `SIM-` transaction reference.
- Food orders persist to `public.food_orders` but no kitchen, pickup
  point, or restaurant system is contacted; the resulting confirmation
  screen is the only delivery surface.
- Loyalty-point balances are computed as `sum(delta)` over a user's
  `public.point_transactions` rows. Earning rows are inserted
  client-side as part of the simulated-payment flow under an
  `auth.uid() = user_id` RLS policy. A malicious prototype client
  could in principle insert arbitrary positive deltas — this matches
  the simulated-payment trust model already used by tickets and food
  orders. Point add-on and merchandise "stock" values are advisory
  in the UI; the database row is not decremented on redemption.
  Redemption does not produce a shippable artefact.
- Google and Microsoft sign-in do not contact real providers; they
  create a Supabase anonymous session and tag it with the chosen
  provider name.
- `simulatedEmail` entries (`ticket_confirmation`,
  `newsletter_confirmation`) are logged to the browser console on
  prototype hosts — local dev servers and the Cloudflare Pages
  preview at `*.pages.dev` — and do not leave the browser. Any other
  host suppresses the log so a future non-prototype deployment does
  not leak the payload. Supabase Auth may still send real account
  emails (password reset, etc.) if a feature that triggers one is
  exercised.
- QR codes generated for tickets are not valid credentials at the real
  venue.

If any of these begin to behave differently, the change should be
specified first, then implemented, per `AGENTS.md`.

## Reporting issues

- Frontend issues: open a GitHub issue on the `MassanApp` repository with
  steps to reproduce, the device/emulation profile used, and a screenshot
  if possible.
- Specification gaps found during testing: file an issue labeled
  `spec-gap` and propose the smallest specification change that would
  cover the missing behavior. Do not implement changes that drift from
  the current specifications without updating them first.
