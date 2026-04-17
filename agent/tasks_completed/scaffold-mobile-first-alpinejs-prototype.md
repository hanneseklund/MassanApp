# Scaffold Mobile-First Alpinejs Prototype

References:
- issue #1: Start project
- depends on `agent/tasks/write-prototype-specification-and-agents-guide.md`

Objective:
- Build the initial application shell for the smartphone-sized web prototype described in issue #1.

Deliverables:
- Set up a static frontend suitable for Cloudflare hosting.
- Add Alpine.js-based state management for the main prototype flows.
- Implement a mobile-first shell with an upcoming-events calendar, search, category filtering, and event selection.
- Ensure the selected-event view is focused on one event at a time and exposes a clear route back to the broader event calendar.

Acceptance Criteria:
- The app runs locally as a single-page or few-page prototype.
- Navigation matches the event-centric behavior required in issue #1.
- The scaffold is ready for Supabase-backed data and auth flows.
