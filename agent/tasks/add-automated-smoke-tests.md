# Add Automated Smoke Tests

References:
- issue #1: Start project
- `docs/installation-testing-specification.md` — the "Smoke test
  checklist" section currently describes a manual checklist run in a
  mobile emulation profile. This task adds an automated mirror.
- `AGENTS.md` "Core workflow rule" — the installation-testing spec is
  the document that must be updated first if the checklist changes.

Objective:
- Mirror the smoke-test checklist in an automated browser suite so
  regressions in the calendar, event subviews, auth, ticket purchase,
  and newsletter flows can be caught without a human walking through
  the checklist every time.

Context / why this exists:
- The prototype has no automated tests today. The repository contains
  no `package.json`, test harness, or CI workflow, so every review
  relies on a manual run against the hosted preview at
  `https://agent.massanapp-prototype.pages.dev/` or a local dev server.
- As the prototype grows (auth migration, further simulated flows,
  congress-specific behavior), the manual checklist becomes the
  bottleneck. A lightweight Playwright or Cypress suite that can run
  against the hosted preview is the smallest addition that still
  catches real regressions.
- Keeping the checklist and the automated suite as a single source of
  truth is the main design choice: the spec defines the steps, the
  automated suite asserts them.

Scope (do):
- Update `docs/installation-testing-specification.md` first so the
  smoke-test checklist is written in a form that can be executed by
  both a human and a script (numbered, with an explicit assertion per
  step). Note where the suite lives and how to run it.
- Add a minimal test harness at the repo root (for example
  `tests/playwright/` plus a `package.json` pinned to a single
  Playwright version) that targets either `http://localhost:8080/` for
  local runs or the hosted preview URL for CI smoke runs. The harness
  must not require a frontend build step — the prototype is buildless
  and must stay buildless per the implementation spec.
- Implement at least one assertion per section of the existing manual
  checklist:
  - Calendar loads from Supabase, category/month/free-text filters
    narrow the list.
  - Event navigation into Nordbygg 2026 reaches all six subviews
    (News, Articles, Program, Exhibitors, Practical info, Newsletter)
    and "Back to events" returns to the calendar.
  - Congress archetype: ESTRO 2026 or EHA2026 Congress loads program
    and practical info.
  - Registration, sign-in, simulated Google sign-in, sign-out.
  - Simulated ticket purchase end to end (including the auth detour
    from "Get tickets" while signed out) and persistence across
    reload.
  - Newsletter anonymous signup and signed-in per-event toggles
    persist across reload.
- Decide what the suite does against a shared Supabase project that it
  cannot reset. Safe options:
  - Use a fixed `@example.com` email per run and tolerate leftover
    rows (document it in the installation-testing spec), or
  - Gate writes behind a dedicated test user whose rows are cleaned up
    in a teardown step using the Supabase MCP.
  Pick one and write it into the installation-testing spec.
- Add a npm script (`npm run smoke`) and document it in the
  installation-testing spec's "Running the frontend" section.
- Optional but preferred: a GitHub Actions workflow that runs the
  suite against the hosted preview on push to `agent` and `main`. If
  added, it must not leak the anon key in logs and must use the
  committed public anon key only.

Scope (do not):
- Unit tests. Alpine.js components are thin; a browser-level smoke
  suite catches more than per-function unit tests would.
- A visual-regression system. Screenshot diffing is noise for a
  prototype that is still changing layout.
- Bringing in a bundler, TypeScript, or any build step for `web/`.
  The test harness is allowed its own `node_modules`; the frontend
  stays as static HTML/CSS/JS.

Acceptance Criteria:
- `npm run smoke` (from the repo root) runs the automated suite
  against a local dev server and exits non-zero on any failure.
- Every bullet in the "Smoke test checklist" section of
  `docs/installation-testing-specification.md` has at least one
  corresponding automated assertion, and the spec links to the suite.
- A test run leaves the shared Supabase project in the documented
  state (either cleaned up or with a documented test user's rows
  persisting).
- README is updated to mention the automated suite as part of the
  review flow.

Notes:
- Keep the suite under ~500 lines and dependency-light. The goal is a
  regression net, not an exhaustive testing system.
- If the suite is added before the Supabase Auth migration
  (`migrate-auth-to-supabase.md`) lands, its auth assertions must be
  written against the current localStorage behavior and then updated
  as part of that migration rather than left stale.
