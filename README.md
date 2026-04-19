# MassanApp

MassanApp is a smartphone-sized web prototype for Stockholmsmassan, the
single-site event venue in Alvsjo, Stockholm owned by the City of Stockholm.
The prototype demonstrates an event-first mobile experience that turns the
venue's public calendar, ticketing, and event content into one coherent app.

The prototype is the starting point for the work requested in
[issue #1: Start project](https://github.com/hanneseklund/MassanApp/issues/1).

## What the prototype does

- Shows an upcoming-events calendar with category, type, and free-text
  filtering that mirrors the official Stockholmsmassan calendar controls.
- Lets a visitor select one event. Once an event is selected the app becomes
  that event's mini-homepage, with an always-available route back to the
  broader event list.
- Supports email registration, simulated social sign-in (Google and
  Microsoft), and a logged-in "My Pages" state.
- Simulates a ticket purchase flow without real payment processing and
  stores the purchased ticket in a "My Tickets" wallet that presents a QR
  code for venue entry.
- Renders event sections for news, articles, program, exhibitor index and
  exhibitor pages, practical information, and newsletter signup and
  preferences.
- Reuses shared Stockholmsmassan venue data (transport, parking,
  restaurants, security) across every seeded event.
- Supports English and Swedish app chrome. A compact toggle in the
  top chrome switches between the two languages and the choice is
  persisted across reloads.

The first fully seeded event is `Nordbygg 2026`. A congress-style reference
event (`ESTRO 2026` or `EHA2026 Congress`) is included so the data model
covers both trade-fair and congress patterns.

## Project documentation

Read these before making non-trivial changes:

- [AGENTS.md](AGENTS.md) — workflow rule that changes must be specified
  first, implemented second, and documented after implementation.
- [docs/functional-specification.md](docs/functional-specification.md) —
  what the prototype does from the user's point of view.
- [docs/implementation-specification.md](docs/implementation-specification.md) —
  how the prototype is built: Alpine.js on Cloudflare, Supabase backend,
  data model, and simulated integrations.
- [docs/installation-testing-specification.md](docs/installation-testing-specification.md) —
  how to install, run, and verify the prototype locally.
- [docs/research-stockholmsmassan-and-venue-apps.md](docs/research-stockholmsmassan-and-venue-apps.md) —
  background research on the venue, event archetypes, and comparable
  venue-app patterns that the specs draw on.

## Prototype scope

This repository is a prototype. It targets the flows in issue #1 and the
research recommendations in `docs/research-stockholmsmassan-and-venue-apps.md`.
Payments, real social sign-in, production ticketing integrations, and other
real third-party systems are faked cleanly. Anything beyond that should be
proposed as a specification change before it is implemented.

## Status

The end-to-end prototype flow in
[docs/functional-specification.md](docs/functional-specification.md) is
implemented: calendar with filtering, event mini-homepages (news,
articles, program, exhibitors, practical info, newsletter), email
registration and sign-in, simulated social sign-in, simulated ticket
purchase, and My Tickets. The catalog, authentication, tickets, and
newsletter subscriptions are all served from the shared Supabase
project. Payments and Google / Microsoft sign-in remain simulated.

## Reviewing a change

Review walks through the smoke-test checklist in
[docs/installation-testing-specification.md](docs/installation-testing-specification.md).
The automated counterpart of that checklist lives in
`tests/playwright/smoke.spec.js`. Run it locally with:

```
npm install
npx playwright install chromium
npm run smoke
```

Pure-function helpers (hash routing, date formatting, calendar
filter/sort, QR payload, newsletter preferences, ticket-type
catalog) also have a fast unit suite that does not need a browser
or Supabase:

```
npm run test:unit
```

The frontend in `web/` stays buildless; `package.json` exists only to
host the smoke-test harness and the unit runner.

Agent-driven tasks live under `agent/tasks/`, with completed tasks
moved to `agent/tasks_completed/` and tasks waiting on user input
moved to `agent/tasks_blocked/`.
