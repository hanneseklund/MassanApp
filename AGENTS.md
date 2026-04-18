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
- Hosting: Cloudflare Pages. The `agent` branch auto-deploys to
  `https://agent.massanapp-prototype.pages.dev/`; the `main` branch
  auto-deploys to the production URL.
- Backend: Supabase (Postgres, Auth, optional Storage).
- No custom backend service. The frontend talks to Supabase directly.

See `docs/implementation-specification.md` for the authoritative version.

## Shared Supabase backend

The prototype uses **one** Supabase project for all testing. Both the
`agent` branch Cloudflare Pages deployment and the `main` branch
deployment read from the same database.

- Project name: `massanapp-prototype`
- Project ref: `esvyrbsypfgpdhijyywz`
- Region: `eu-north-1`
- URL: `https://esvyrbsypfgpdhijyywz.supabase.co`

Only the publishable (anon) key is used in the frontend. The service
role key is never committed or used anywhere in this repository.

### Publishing database changes

When an agent develops a database schema or seed change, it must land in
the shared project **in the same task** — do not let the repository
drift ahead of the live database.

1. Add the SQL to the repository under `supabase/migrations/NNNN_name.sql`
   for schema changes, or update `supabase/seed/seed.sql` for seed
   changes. Migration filenames are zero-padded and strictly increasing.
2. Apply the change to the shared project via the Supabase MCP in the
   same session:
   - Schema: call `mcp__claude_ai_Supabase__apply_migration` with
     `project_id=esvyrbsypfgpdhijyywz`, a snake_case `name` matching the
     filename, and the SQL body.
   - Seed / data: call `mcp__claude_ai_Supabase__execute_sql` with the
     updated seed SQL.
3. Verify the change landed. For schema: `list_tables` or
   `list_migrations`. For seed: a `select count(*)` via `execute_sql`.
4. When `supabase/seed/seed.sql` changes, update `web/data/catalog.json`
   in the same commit so the reference copy of the seed shape stays
   useful for reviewers. See the "Seed data layout" section of
   `docs/implementation-specification.md`.

If the MCP is not available in the current session, the task is
blocked — move it to `agent/tasks_blocked/` rather than committing a
migration that has not been applied. The reverse is also not allowed:
never apply a migration to the shared project that has not been
committed to `supabase/migrations/`.

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
