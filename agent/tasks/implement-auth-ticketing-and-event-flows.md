# Implement Auth Ticketing And Event Flows

References:
- issue #1: Start project
- depends on `agent/tasks/scaffold-mobile-first-alpinejs-prototype.md`
- depends on `agent/tasks/load-stockholmsmassan-event-data.md`

Objective:
- Implement the core end-user prototype flows requested in issue #1.

Deliverables:
- Registration and login using email, with simulated or Supabase-backed social sign-in options such as Google and Microsoft.
- Logged-in "My Pages" state.
- Simulated ticket purchase flow that completes without real payment processing.
- "My Tickets" view with QR-code presentation for venue entry.
- Event detail sections for news, articles, program, exhibitor index and exhibitor pages, practical information, and newsletter signup/preferences.

Acceptance Criteria:
- A user can register, sign in, browse events, select one event, simulate a ticket purchase, and see the ticket in "My Tickets".
- Newsletter signup/preferences and other missing integrations are faked cleanly where necessary.
- The implemented flows remain aligned with the specifications and prototype limits from issue #1.
