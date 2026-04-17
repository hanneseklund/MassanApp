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

## Running the frontend without Supabase

The prototype is designed to run with local seed data when Supabase is
not configured, so it can be demoed without cloud credentials.

1. Start a static HTTP server from the `web/` directory. Any minimal
   server works; examples:

   - `npx http-server web -p 8080`
   - `python3 -m http.server 8080 --directory web`

2. Open `http://localhost:8080/` in a browser.

3. In DevTools, switch to a mobile device emulation profile (for example
   iPhone 14) to confirm mobile-first layout.

In this mode, authentication, ticket purchase, and newsletter signup are
backed by simulations and in-memory state. Refreshing the page resets
any simulated tickets and sessions.

The seed content the frontend reads in this mode lives in
`web/data/catalog.json`. It contains the shared venue record for
Stockholmsmassan and seeded events (`Nordbygg 2026`, `ESTRO 2026`,
`EHA2026 Congress`) along with their news, articles, program items,
exhibitors, and speaker entries.

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

## Running the frontend against the shared Supabase project

1. Configure the frontend with the shared project URL and publishable
   key. These values are safe to commit because the publishable key is
   the public anon key gated by Row Level Security. The Cloudflare Pages
   deployments pick up the committed values automatically.
2. Optionally override locally with `web/assets/env.local.js` (gitignored,
   see `.gitignore`) to point a local dev run at a different Supabase
   project. This is an escape hatch, not the default.
3. Start the static server as described above.

When the frontend is wired to Supabase, email sign-up and sign-in go
through Supabase Auth. Simulated social sign-in and simulated payment
remain simulated regardless of Supabase configuration.

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

### Calendar and event selection

- Open the app. The calendar shows upcoming events.
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

- Register with an email. Confirm that the app enters a logged-in state
  or clearly simulates the email-confirmation step.
- Sign out. Sign back in with the same email.
- Trigger the simulated Google sign-in. Confirm the session is created
  and that the UI indicates the provider is simulated.

### Ticket purchase (simulated)

- While signed in, start a ticket purchase from an event that supports
  tickets (for example `Nordbygg 2026`).
- Complete the flow. Confirm the success state.
- Open My Tickets and confirm the new ticket appears with a QR code.

### Newsletter

- On an event's Newsletter subview, submit the signup form with an
  email address. Confirm the UI shows a success state and that a
  `newsletter_confirmation` entry is logged to the browser console.
- Reload the page and confirm the success state persists for that
  email (the subscription is keyed by email).
- Sign in, then on another event's Newsletter subview sign up again.
  Confirm that in My Pages → Newsletter preferences the new
  subscription appears under the signed-in user.
- Toggle one of the per-event topic preferences and unsubscribe from
  one event. Reload the page and confirm both changes persist.
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
- Google and Microsoft sign-in do not contact real providers.
- Email delivery is logged to the browser console in development and
  does not leave the browser.
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
