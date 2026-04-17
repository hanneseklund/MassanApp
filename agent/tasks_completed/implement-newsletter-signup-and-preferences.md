# Implement Newsletter Signup And Preferences

References:
- issue #1: Start project
- parent split: this task and the other `implement-*` siblings replace
  `implement-auth-ticketing-and-event-flows.md`, which was too large for a
  single session.
- depends on `implement-auth-and-my-pages.md` for the session store used
  by per-user preference storage.

Objective:
- Let a visitor sign up for an event newsletter from the event page, and
  let a signed-in visitor adjust newsletter preferences per event and at
  the account level from My Pages.

Scope (do):
- Event newsletter subview: a form that collects an email and offers a
  small set of topic toggles (for example: Program highlights, News,
  Exhibitor updates). Submitting the form produces a subscription
  record and shows a success state. If the visitor is signed in, the
  email defaults to their account email and submission is tied to that
  user.
- `$store.newsletter` store that owns subscriptions, persisted in
  `localStorage`. Subscription record fields mirror the data-model
  `Newsletter subscription` entity in
  `docs/implementation-specification.md`: `id`, `user_id` (nullable),
  `email`, `event_id` (nullable for venue-wide), `preferences` (JSON).
- `simulatedEmail("newsletter_confirmation", payload)` call on signup.
  In development it logs the would-be email to the console; in
  production hosting it is a no-op. Centralize with any other
  simulated-email calls introduced by earlier tasks.
- Newsletter preferences section in My Pages, listing the signed-in
  user's subscriptions by event with toggles for the same topic flags
  and an unsubscribe action per event. A venue-wide subscription
  ("All Stockholmsmassan events") is available as a separate row.

Scope (do not):
- Real email delivery, ESP integration, or double opt-in. All email is
  simulated per `docs/functional-specification.md`.

Acceptance Criteria:
- Signing up for the `Nordbygg 2026` newsletter as an anonymous visitor
  shows a success state and persists the subscription across reloads
  (keyed by email).
- A signed-in visitor can sign up for another event's newsletter and
  the subscription appears under My Pages → Newsletter preferences
  tied to their user id.
- Toggling a preference and unsubscribing both persist across reloads.
- `simulatedEmail` is called on signup and logs a recognizable payload
  to the console during development.
- The smoke-test "Newsletter" checklist in
  `docs/installation-testing-specification.md` passes.
