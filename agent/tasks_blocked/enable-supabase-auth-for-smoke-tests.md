# Enable Supabase auth config so the smoke suite can cover auth flows

Status: blocked — waiting on the user to flip two toggles in the
Supabase dashboard for project `esvyrbsypfgpdhijyywz`. Tracked on
GitHub issue #5
(https://github.com/hanneseklund/MassanApp/issues/5). Rechecked on
2026-04-18: `POST /auth/v1/signup` still returns
`over_email_send_rate_limit` (confirm-email still ON) and
`signInAnonymously` still returns `anonymous_provider_disabled`. The
available Supabase MCP exposes SQL / migrations / branches but not the
auth-config update endpoint, so this remains a one-time manual step.

References:
- GitHub issue #5 — `Flip Supabase auth toggles so the smoke suite can
  cover auth flows`.
- `agent/tasks_completed/add-automated-smoke-tests.md` — introduced
  the suite and gated auth-dependent tests behind `SMOKE_AUTH=1`.
- `docs/installation-testing-specification.md` — "Smoke testing
  against the shared project" and "Automated smoke suite" both
  document the current Supabase auth drift.
- `AGENTS.md` — "Shared Supabase backend" notes that the committed
  anon key + RLS are the only frontend contract, and that the
  prototype uses one shared project.

Objective:
- Flip the shared Supabase prototype project's Authentication
  settings so the running config matches the installation-testing
  spec, and remove the `SMOKE_AUTH` gate from
  `tests/playwright/smoke.spec.js` so the full checklist (steps
  12–28) runs under the default `npm run smoke`.

Context / why this exists:
- The smoke suite was landed against the current Supabase config.
  Inspection on 2026-04-18 showed:
  - Email confirmation is ON. `supabase.auth.signUp` returns
    "confirmation email sent" instead of a usable session, and
    repeated calls trip the project-wide email rate limit
    (`over_email_send_rate_limit`).
  - Anonymous sign-ins are OFF. The simulated Google / Microsoft
    buttons call `signInAnonymously`, which errors with
    `anonymous_provider_disabled`.
- The installation-testing spec has always assumed both toggles are
  in the opposite state. The drift blocks five of the eight smoke
  tests: Registration and sign-in (12–15), Ticket purchase (16–22),
  and Newsletter (23–28).

Scope (do):
- In the Supabase dashboard for project `esvyrbsypfgpdhijyywz`:
  - Authentication → Sign In / Providers → Email: disable "Confirm
    email".
  - Authentication → Sign In / Providers → Anonymous: enable
    anonymous sign-ins.
- Verify by running `SMOKE_AUTH=1 npm run smoke` locally. Expect all
  eight test blocks to pass.
- Remove the `SMOKE_AUTH` env gate in
  `tests/playwright/smoke.spec.js` (replace `describeAuth` with
  `test.describe` and drop the comment block and the constant).
- Remove the `SMOKE_AUTH=1` paragraph from the "Automated smoke
  suite" section of
  `docs/installation-testing-specification.md` so the spec no longer
  advertises an opt-in flag.
- Keep the "Smoke testing against the shared project" subsection of
  the spec — it still applies because the project is not reset
  between runs.

Scope (do not):
- Do not commit a service-role key or admin API call to the
  repository. The fix belongs in the dashboard, which is a one-time
  manual change.
- Do not introduce a separate "test" Supabase project. The prototype
  intentionally uses one shared project; splitting it adds config to
  keep in sync and no benefit until payments or real OAuth land.
- Do not add a migration that inserts a pre-confirmed user. The
  smoke suite exercises the public signup path on purpose; a
  baked-in user would silently mask a regression in the user flow.

Acceptance Criteria:
- `SMOKE_AUTH=1 npm run smoke` passes before the env gate is removed.
- `npm run smoke` passes after the env gate is removed (no env var
  required).
- `docs/installation-testing-specification.md` no longer mentions
  `SMOKE_AUTH`.
- The Nordbygg and ESTRO tickets and newsletter subscriptions created
  by the run are present in `public.tickets` and
  `public.newsletter_subscriptions` under the smoke test user, and
  noisy rows are acceptable per the existing "Smoke testing against
  the shared project" note.

Notes:
- The tests use a deterministic account
  (`smoke+e2e@example.com` / `MassanApp-smoke-2026!`). If the shared
  project has been rate-limited during the earlier failed runs, wait
  for the Supabase rate-limit window to lapse (typically an hour)
  before the first successful run.
