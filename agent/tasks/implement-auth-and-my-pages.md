# Implement Auth And My Pages

References:
- issue #1: Start project
- parent split: this task and the other `implement-*` siblings replace
  `implement-auth-ticketing-and-event-flows.md`, which was too large for a
  single session.
- depends on `render-event-subviews-from-seed.md` only loosely; the auth
  UI should not need the new subview content, but keep the "Back to
  events" chrome working regardless of what the active view is.

Objective:
- Let a visitor register, sign in, see a logged-in "My Pages" view, and
  sign out. Authentication is local-only in the prototype; no real
  Supabase call is required. Simulated Google and Microsoft sign-in
  options must exist and be labeled as simulated.

Scope (do):
- Add an `auth` view reachable from the app chrome when signed-out
  visitors tap "Me". It shows a register form (email, display name,
  password — password is accepted but not validated) and a sign-in form
  (email + password), plus buttons for simulated Google and Microsoft
  sign-in.
- Add an Alpine `$store.session` store that owns the current user
  record (id, email, display_name, auth_provider, simulated flag) and
  persists it to `localStorage` so a refresh keeps the user signed in.
- Implement `simulatedSocialSignIn(provider)` per
  `docs/implementation-specification.md`. It must set
  `session.auth_provider` and `session.simulated = true`, and must not
  contact any external service. Label the resulting session clearly in
  the UI (a "simulated provider" chip or similar).
- Replace the current My Pages placeholder with a logged-in view that
  shows the display name, email, auth provider (with a simulated chip
  when applicable), links to My Tickets and Newsletter preferences
  (both of which may still be stubs from later tasks), and a sign-out
  button.
- When signed-out users tap "Me" they see the auth view instead of the
  placeholder.
- After sign-in, return the visitor to where they were before signing
  in (the calendar if they entered auth from the chrome).

Scope (do not):
- Ticket purchase, My Tickets, newsletter signup, newsletter preferences
  — stub them in My Pages but do not implement them here.
- Real Supabase Auth wiring. The prototype stays local-only; the hook
  points should make adding it straightforward later.

Acceptance Criteria:
- A visitor can register with an email + display name + password and
  becomes signed in.
- Signing out and signing back in with the same email + password works.
- Simulated Google sign-in produces a session labeled as simulated.
- Refreshing the page preserves the signed-in state.
- The smoke-test "Registration and sign-in" checklist in
  `docs/installation-testing-specification.md` passes.
- `docs/functional-specification.md` is updated only if the
  implementation reveals a missing or incorrect user-visible behavior.
