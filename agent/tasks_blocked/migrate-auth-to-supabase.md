# Migrate Auth To Supabase

References:
- issue #1: Start project
- depends on `implement-auth-and-my-pages.md` (completed) which
  established the local-only auth surface and the Alpine `$store.session`
  contract this task will rewire.
- `docs/implementation-specification.md` — the "User", "Ticket", and
  "Newsletter subscription" sections already describe the target
  Supabase-backed behavior; this task implements it.
- `supabase/migrations/0001_init.sql` — the `tickets.user_id` and
  `newsletter_subscriptions.user_id` columns already reference
  `auth.users(id)`, so the schema is ready. RLS policies are already
  written but are effectively unused today because all callers are
  unauthenticated.

Objective:
- Replace the `localStorage`-backed auth, tickets, and newsletter
  persistence with a Supabase Auth session and Supabase-stored tickets
  and newsletter subscriptions, so the prototype demonstrates the full
  production path rather than a browser-local stub.

Context / why this exists:
- Today `web/assets/js/app.js` hashes passwords locally (`hashPassword`
  around line 167) and stores the user record, tickets, and newsletter
  subscriptions under `massan.*` localStorage keys.
- The implementation spec (Data model → User, Ticket, Newsletter
  subscription) explicitly flags this as "will be replaced by Supabase
  Auth". The README Status section and the installation-testing spec
  say the same thing to visitors and reviewers.
- The migration has two concerns that need to be addressed together:
  1. Swap the storage/identity layer (Supabase Auth + tables with RLS).
  2. Decide what happens to data created during the localStorage era
     (most likely: do nothing — the prototype has no real users — but
     the task should make that call explicit).

Scope (do):
- Update `docs/implementation-specification.md` first so the
  authoritative description stops saying "Supabase Auth will replace"
  and instead describes the active wiring. Update
  `docs/functional-specification.md` only if user-visible behavior
  changes (for example an email-confirmation step that was previously
  faked may now be real).
- Wire Supabase Auth email sign-up and sign-in through the Supabase JS
  client already present via CDN. Route the existing auth forms in
  `index.html` to call `supabase.auth.signUp` / `signInWithPassword`
  and map the resulting session into `$store.session` with the same
  shape the rest of the app consumes (id, email, display_name,
  auth_provider, simulated). `display_name` should be carried in the
  Supabase user `user_metadata`.
- Rewire simulated Google / Microsoft sign-in so it keeps working
  without real OAuth: the easiest path is to call
  `supabase.auth.signInAnonymously` and then set a `simulated: true`
  flag plus the chosen provider label in the session layer (or simply
  keep the current client-side fake but key the local ticket/newsletter
  writes off the anon auth user's UUID so RLS does not reject them).
  The functional spec rule that the label "simulated" must remain
  visible still applies.
- Move tickets to the `public.tickets` table. Replace
  `loadTicketsFromStorage` / `saveTicketsToStorage` with Supabase
  `select` / `insert` calls filtered by `auth.uid()` through the
  existing RLS policy. Keep `qr_payload`, `transaction_ref`,
  `purchased_at`, and `ticket_type_label` columns in sync with the
  current in-memory shape so `ticketQrSvgFor` and the My Tickets view
  do not need to change.
- Move newsletter subscriptions to
  `public.newsletter_subscriptions`. Anonymous signups (no session)
  must still work per the functional spec, so keep the "anyone insert
  newsletter" RLS policy. Signed-in reads/updates must go through
  `auth.uid() = user_id`. Venue-wide subscriptions (`event_id IS NULL`)
  stay representable.
- Remove the `massan.users`, `massan.session`, `massan.tickets`, and
  `massan.newsletter` localStorage stores once the Supabase path is in
  place. Do not leave migration shims: the prototype has no users we
  need to keep.
- Update `docs/installation-testing-specification.md`:
  - "Running the frontend" no longer claims auth is simulated in
    `localStorage`. The "Known simulated behaviors" list shrinks
    (payments and social sign-in stay simulated; email sign-up becomes
    real Supabase Auth).
  - The smoke-test checklist items for Registration, Ticket purchase,
    and Newsletter should read out against Supabase, not localStorage.
    Note that Supabase will actually send a confirmation email unless
    the project's Auth settings are set up for prototype use — call
    that out as a prerequisite.
- If Supabase Auth is configured to require email confirmation, either
  disable confirmation in the shared project settings (document the
  choice in the installation-testing spec) or teach the UI to handle
  the "confirm your email" state.

Scope (do not):
- Real Google / Microsoft OAuth. Keep them simulated. This task only
  replaces the local persistence layer; changing OAuth is a separate
  specification change per `AGENTS.md`.
- Real payment processing. The simulated payment stays.
- A new backend service. The frontend continues to talk to Supabase
  directly.

Acceptance Criteria:
- `supabase.auth.getSession()` returns a real session after a fresh
  sign-up through the UI.
- A reload preserves the signed-in state via Supabase's persisted
  session, not via `massan.session`.
- The `public.tickets` table contains a row with the correct
  `user_id`, `event_id`, and `ticket_type` after a simulated purchase,
  and that row is visible in My Tickets after reload.
- The `public.newsletter_subscriptions` table contains both anonymous
  and signed-in rows as appropriate, with RLS blocking cross-user
  reads.
- `grep -n "massan\." web/assets/js/app.js` returns no matches for the
  removed localStorage keys.
- The smoke-test checklist in
  `docs/installation-testing-specification.md` passes end to end after
  the updates to that document are applied.
- Implementation and functional specs and the README Status section
  are reconciled so no document still claims auth / tickets /
  newsletter live in `localStorage`.

Notes:
- Confirm via `mcp__claude_ai_Supabase__get_project` that the shared
  project's Auth settings are appropriate before changing them.
  Changes to a shared project need to be called out in the PR per
  `AGENTS.md`.
- If email confirmation is left on, prefer teaching the UI to reflect
  it over adding a service-role workaround; the prototype must never
  hold a service-role key.

## Status: blocked on shared-project Auth config (2026-04-18)

The code, schema migration (`0002_newsletter_delete_policy`), and all
three specifications and the README are updated in the working tree.
Acceptance-criteria verification is blocked on two project-level Auth
settings on the shared `massanapp-prototype` Supabase project. Both
must be flipped in the Supabase dashboard (they are not exposed via
the Supabase MCP and the prototype must never hold a service-role
key):

1. **Allow anonymous sign-ins** — currently `false`. Needed for the
   simulated Google / Microsoft buttons which call
   `supabase.auth.signInAnonymously` to create a real `auth.uid()` for
   ticket / newsletter ownership.
2. **Confirm email** — currently enabled (`mailer_autoconfirm: false`).
   Needed disabled so `supabase.auth.signUp` returns a usable session
   immediately for smoke testing with `@example.com` addresses.

Asked on issue #1 (comment of 2026-04-18). Once both toggles are
flipped, move this file back to `agent/tasks/` and the next session
will run the smoke-test checklist end to end.
