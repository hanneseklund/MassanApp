# Load Stockholmsmassan Event Data

References:
- issue #1: Start project
- depends on `agent/tasks/research-stockholmsmassan-and-venue-apps.md`
- depends on `agent/tasks/write-prototype-specification-and-agents-guide.md`

Objective:
- Populate the prototype backend or seed files with event data derived from Stockholmsmassan's real upcoming events.

Deliverables:
- Define the prototype data model needed for events, schedules, exhibitors, venue information, tickets, and newsletters.
- Extract upcoming event data from `https://stockholmsmassan.se/en/calendar/` and related event pages.
- Load the collected data into Supabase or an interim seed/import format that the app can consume.
- Fill gaps with clearly simulated content when the source site does not provide enough information.

Acceptance Criteria:
- The prototype includes real upcoming Stockholmsmassan events rather than fully invented placeholders.
- At least one event has enough detail to support news, articles, program content, exhibitors, and practical information in the UI.
- Mock data is used only where issue #1 allows simulation.
