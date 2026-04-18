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

The checklist can be run against either a local server (for uncommitted
changes or Supabase-backed builds) or the hosted preview at
<https://agent.massanapp-prototype.pages.dev/> for changes that have
already been pushed to the `agent` branch — see the Hosted preview
section above for the caveats.

### Calendar and event selection

- Open the app. A brief "Loading events…" hint appears while the
  catalog is fetched from Supabase, then the calendar shows upcoming
  events. If the Supabase fetch fails, the calendar replaces the list
  with an error message instead of a silently empty grid.
- Apply a category filter and a month filter. The list updates.
- Use free-text search to find `Nordbygg`. The Nordbygg 2026 card
  appears.
- Tap `Nordbygg 2026`. The app switches into the event home view and the
  calendar is no longer the active view.

### Event content

- From `Nordbygg 2026`, open News, Articles, Program, Exhibitor index,
  an exhibitor detail page, and Practical information in turn.
- Confirm that practical information shows shared Stockholmsmassan venue
  facts (transport to Alvsjo, parking, restaurants, security).
- Confirm the presence of a "Back to events" route from at least one
  subview and use it to return to the calendar.

### Congress archetype

- Open at least one congress event (`ESTRO 2026` or `EHA2026 Congress`)
  from the calendar.
- Confirm the program and practical information render with seeded
  data.

### Registration and sign-in

- Register with a fresh `@example.com` email. The app enters a
  logged-in state immediately (email confirmation is disabled on the
  shared project). A row appears in `auth.users`.
- Sign out. Sign back in with the same email and password.
- Trigger the simulated Google sign-in. Confirm the session is created,
  the UI indicates the provider is simulated, and a new anonymous row
  appears in `auth.users` (simulated social sign-in rides on Supabase
  anonymous auth).

### Ticket purchase (simulated)

- While signed out, tap "Get tickets" on `Nordbygg 2026`. Confirm the
  app routes through the auth view and returns to the purchase flow
  after sign-in.
- In step 1 pick a ticket type (for example "Day pass"). In step 2
  confirm the attendee details (defaulted from the profile) and review
  the order summary. In step 3 confirm the purchase. A "simulated"
  label is visible at least on the confirmation screen.
- Confirm that a `ticket_confirmation` entry is logged to the browser
  console when the purchase completes.
- Open My Tickets from the confirmation screen and confirm the new
  ticket appears with event name, dates, ticket type, attendee,
  purchase date, and a QR code rendered as SVG. A row with the
  matching `user_id`, `event_id`, and `ticket_type` appears in
  `public.tickets`.
- Return to the `Nordbygg 2026` event home view and confirm the CTA
  now also offers "View ticket".
- Open `ESTRO 2026`, tap "Register as delegate", complete the flow, and
  confirm a delegate ticket appears in My Tickets.
- Reload the page. The Supabase session is restored automatically and
  the tickets still appear in My Tickets.

### Newsletter

- While signed out, open an event's Newsletter subview and submit the
  signup form with an email address. The UI shows a success state and
  a `newsletter_confirmation` entry is logged to the browser console.
  A row appears in `public.newsletter_subscriptions` with a `null`
  `user_id` and the submitted email. The anonymous visitor cannot
  read the row back through RLS; reloading the page returns the form
  to its blank state rather than to the success state.
- Sign in. On an event's Newsletter subview sign up. The success state
  appears, and a row appears with the signed-in user's `user_id`.
  In My Pages → Newsletter preferences the new subscription appears
  under the signed-in user.
- Toggle one of the per-event topic preferences and unsubscribe from
  one event. Reload the page and confirm both changes persist (they
  are now reads and updates against Supabase, not `localStorage`).
- Toggle the venue-wide "All Stockholmsmassan events" subscription on
  and off and confirm the state persists across reloads.

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
