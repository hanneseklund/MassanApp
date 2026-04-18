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
`auth.users`, `public.tickets`, and `public.newsletter_subscriptions`.
The prototype does not reset the database between runs. When running
the checklist:

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
   Exhibitors, Practical info, and Newsletter in turn. Assert: each
   subview either renders content or a documented empty-state
   placeholder, and the active tab indicator tracks the selection.
6. From the Exhibitors index, open one exhibitor. Assert: the
   exhibitor detail view renders and a "Back to exhibitors" button is
   visible.
7. Open Practical info. Assert: the shared Stockholmsmassan facts are
   present — at minimum the word `Alvsjo` appears in transport copy,
   and "Parking", "Restaurants and cafes", and "Security and entry"
   sections render.
8. Use the "Events" back button in the top chrome. Assert: the URL
   hash returns to `#/` and the calendar is visible again.

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
18. Step 1: pick "Day pass". Step 2: keep the defaulted attendee name
    and email, confirm the order summary shows event name, dates, and
    price. Step 3: confirm. Assert: the confirmation screen shows a
    `simulated` chip, a transaction reference, and a rendered QR SVG.
    Assert: a `[simulatedEmail] ticket_confirmation` entry is logged
    to the browser console.
19. From the confirmation, open My Tickets. Assert: a ticket for
    `Nordbygg 2026` appears with ticket type label, attendee name,
    attendee email, a purchase date, and an SVG QR code.
20. Return to `Nordbygg 2026`. Assert: the event home now shows both
    "Get tickets" and "View ticket" CTAs.
21. Open `ESTRO 2026`, tap "Register as delegate", and complete the
    flow. Assert: the delegate ticket appears in My Tickets alongside
    the Nordbygg ticket.
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

`npm run smoke` launches http-server on `http://127.0.0.1:8080/`
serving `web/`, runs the suite, and shuts the server down when done.
To run against a different URL (for example the hosted preview) pass
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
sign-in and anonymous newsletter signups leave additional
`auth.users` and `public.newsletter_subscriptions` rows behind on every
run; this is accepted prototype behavior and noisy rows can be cleaned
up from the Supabase dashboard.

The suite does not truncate any Supabase tables. A cleaner teardown
would require a service-role key, which this repository does not ship.

### Coverage

Every numbered item in the checklist above maps to at least one
assertion in the suite. When the checklist changes, update the suite
in the same pull request.

Steps 1–11 (calendar, event content, congress archetype) run by
default. Steps 12–28 (auth, ticket purchase, newsletter) require the
shared Supabase project to have email confirmation disabled and
anonymous sign-ins enabled, which are Authentication → Providers /
Sign In toggles in the Supabase dashboard. They also require
anonymous provider to be on for simulated Google / Microsoft
sign-in. Because both are currently off, the auth-dependent tests are
gated behind `SMOKE_AUTH=1` to keep the default `npm run smoke` green
on the config as it ships. Run them once the dashboard is corrected:

```
SMOKE_AUTH=1 npm run smoke
```

The tracking task for flipping the dashboard and removing the gate
is `agent/tasks/enable-supabase-auth-for-smoke-tests.md`.

## Regression checks for shared venue data

When editing venue-shared content:

- Verify the same practical-info strings appear on at least two different
  events.
- Verify that an event-specific override only changes that event and
  does not leak to other events.

## Known simulated behaviors

These are expected in the prototype and are not bugs:

- Payments succeed without real charges.
- Google and Microsoft sign-in do not contact real providers; they
  create a Supabase anonymous session and tag it with the chosen
  provider name.
- `simulatedEmail` entries (`ticket_confirmation`,
  `newsletter_confirmation`) are logged to the browser console in
  development and do not leave the browser. Supabase Auth may still
  send real account emails (password reset, etc.) if a feature that
  triggers one is exercised.
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
