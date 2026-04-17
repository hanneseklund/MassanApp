# Implement Ticket Purchase And My Tickets

References:
- issue #1: Start project
- parent split: this task and the other `implement-*` siblings replace
  `implement-auth-ticketing-and-event-flows.md`, which was too large for a
  single session.
- depends on `implement-auth-and-my-pages.md` for the session store and
  signed-in user record.

Objective:
- Let a signed-in visitor simulate buying a ticket for an event that
  supports public ticketing (`ticket_model === "public_ticket"`) and see
  the resulting ticket in "My Tickets" with a QR-code presentation for
  venue entry.

Scope (do):
- Ticket purchase flow, reached from the "Get tickets" CTA on an
  event's home view:
  - Step 1: pick a ticket type (Day pass / Full event — at least two
    simulated types). If the visitor is not signed in, route them to
    the auth view first and return here after sign-in.
  - Step 2: attendee details (name + email, defaulting to the signed-in
    user's values) and an order summary.
  - Step 3: confirm. Call `simulatedPayment(order)` per the
    implementation spec, which always succeeds after a short delay and
    returns a plausible transaction reference.
  - On success, show a confirmation screen linking to My Tickets.
- `$store.tickets` store owning purchased tickets, persisted in
  `localStorage` keyed by user id.
- `generateTicketQr(ticket)` helper that produces a QR payload string
  from the ticket id and a salted event id (no real venue credential).
  Render it as an SVG in the ticket card; a small inline QR library or
  a hand-rolled SVG renderer is acceptable as long as it stays
  buildless and has no heavy CDN cost.
- My Tickets view: list of the signed-in user's tickets, each showing
  event name, event dates, ticket type, attendee, purchase date, and
  the QR presentation. Tickets are scoped to the current user id.
- Event home view: if the signed-in user already owns a ticket for this
  event, show "View ticket" in addition to or instead of "Get tickets".
- Congress-style events (`ticket_model === "registration"`) get a
  simulated "Register as delegate" CTA that flows through the same code
  path, producing a delegate ticket type.

Scope (do not):
- Real payment integration or collecting card details.
- Transferring or refunding tickets.
- Newsletter — separate task.

Acceptance Criteria:
- While signed in, starting a ticket purchase from `Nordbygg 2026`,
  completing the flow, and opening My Tickets shows the ticket with a
  visible QR code.
- The same flow for `ESTRO 2026` produces a delegate registration with
  its own ticket record.
- Refreshing the page preserves the user's tickets.
- `simulatedPayment` is the only code path that "charges" the user, and
  its simulated nature is visible in the UI (for example a "simulated"
  label on the confirmation screen).
- The smoke-test "Ticket purchase (simulated)" checklist in
  `docs/installation-testing-specification.md` passes.
