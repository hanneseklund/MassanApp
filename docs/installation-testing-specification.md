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

## Running the frontend against Supabase

1. Create a Supabase project (or reuse the shared prototype project
   when one is available).
2. Apply the migrations in `supabase/migrations/` and seed the data in
   `supabase/seed/`. Using the Supabase CLI:

   ```
   supabase db push
   supabase db seed
   ```

3. Provide the anon key and project URL to the frontend through a local
   configuration file (for example `web/assets/env.local.js`) that sets
   the Supabase URL and anon key at runtime. This file must be gitignored.
4. Start the static server as above.

When Supabase is configured, email sign-up and sign-in go through
Supabase Auth. Simulated social sign-in and simulated payment remain
simulated regardless of Supabase configuration.

## Environment variables

The prototype reads a small number of values at runtime:

- `SUPABASE_URL` — Supabase project URL. Optional; absence triggers
  local-seed fallback.
- `SUPABASE_ANON_KEY` — Supabase anon key. Optional; must be absent or
  paired with `SUPABASE_URL`.

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

- Sign up for the event newsletter. Confirm the UI indicates success.
- As a logged-in user, open newsletter preferences and change at least
  one preference.

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
