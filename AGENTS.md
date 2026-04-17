# AGENTS.md

This file tells human and AI contributors how to work on MassanApp. It is
short on purpose. Read the specifications in `docs/` before starting
non-trivial work.

## Core workflow rule: specify first, implement second, reconcile docs after

All changes to this project follow this order:

1. Specify the change first. Update `docs/functional-specification.md`,
   `docs/implementation-specification.md`, or
   `docs/installation-testing-specification.md` so the intended behavior
   is written down before any code is written. For very small changes a
   brief note in the task file is enough, but user-visible behavior
   must still be reflected in the functional specification before it
   ships.
2. Implement the change second. Code changes should match the updated
   specifications. If implementation reveals that a spec assumption was
   wrong, update the spec before continuing.
3. Reconcile the documentation after implementation. Once the change is
   in place, re-read the specifications and the README, and fix any
   drift or stale references the implementation introduced.

If you cannot follow this order for a specific change, say why in the
task file or the pull request description. Do not silently skip the
rule.

## Documentation layout

- `README.md` — project starting point for a new contributor.
- `AGENTS.md` — this file.
- `docs/functional-specification.md` — user-visible behavior.
- `docs/implementation-specification.md` — how the prototype is built.
- `docs/installation-testing-specification.md` — how to run and verify
  the prototype.
- `docs/research-stockholmsmassan-and-venue-apps.md` — research notes
  that inform the specifications. Treat it as background; update it
  only when the research itself is extended.

## Task queues

- `agent/tasks/` — runnable tasks.
- `agent/tasks_blocked/` — tasks waiting on user input or decisions.
- `agent/tasks_completed/` — tasks that have been finished. Files are
  moved here with `git mv` rather than deleted.

An agent session typically picks the single most important runnable task,
completes it, and moves it to `agent/tasks_completed/`. Larger tasks are
split into smaller files in `agent/tasks/` before any work is done.

## Prototype boundaries

MassanApp is a prototype. The following are simulated on purpose:

- Payments and ticket issuance.
- Google and Microsoft OAuth.
- Email delivery.
- Congress-platform and on-demand-content integrations.

Do not replace a simulation with a real integration without first
updating `docs/functional-specification.md` and
`docs/implementation-specification.md`.

## Stack at a glance

- Frontend: static HTML, CSS, JavaScript, Alpine.js.
- Hosting: Cloudflare Pages.
- Backend: Supabase (Postgres, Auth, optional Storage).
- No custom backend service. The frontend talks to Supabase directly.

See `docs/implementation-specification.md` for the authoritative version.

## Seed events

- Primary seeded event: `Nordbygg 2026` (trade fair).
- Secondary seeded event for congress coverage: `ESTRO 2026` or
  `EHA2026 Congress`.

New seeded events should still follow the shared-venue-data rule: do not
duplicate transport, parking, restaurant, or security copy per event.

## Pull request expectations

- Link the relevant GitHub issue where possible (for example issue #1).
- Call out any specification updates made as part of the change.
- Call out any simulations added or removed.
- Keep changes scoped. If a change turns out to require a broader
  refactor, split it into a new task rather than expanding the current
  one silently.

## When in doubt

If a change is ambiguous, stop and ask on the relevant GitHub issue
before implementing. Record that you asked in the task file and, if the
task cannot proceed, move it to `agent/tasks_blocked/`.
