# Load Stockholmsmassan Event Data

References:
- issue #1: Start project
- informed by `docs/research-stockholmsmassan-and-venue-apps.md`
- follows completed task `agent/tasks_completed/research-stockholmsmassan-and-venue-apps.md`
- depends on `agent/tasks/write-prototype-specification-and-agents-guide.md`

Objective:
- Populate the prototype backend or seed files with event data derived from Stockholmsmassan's real upcoming events, using the completed research findings to prioritize the best prototype sources.

Deliverables:
- Define the prototype data model needed for shared venue information plus event-specific data for events, schedules, exhibitors, tickets, and newsletters.
- Extract `Nordbygg 2026` as the primary prototype event from `https://stockholmsmassan.se/en/calendar/` and related event pages, since the research note identifies it as the strongest first seed.
- Reuse shared Stockholmsmassan venue data for transport, parking, restaurants, and safety across seeded events.
- Add at least one congress-oriented reference event such as `ESTRO 2026` or `EHA2026 Congress` so the dataset can represent richer congress-specific fields where needed.
- Load the collected data into Supabase or an interim seed/import format that the app can consume.
- Fill gaps with clearly simulated content when the source site does not provide enough information.

Acceptance Criteria:
- The prototype includes real upcoming Stockholmsmassan events rather than fully invented placeholders.
- `Nordbygg 2026` has enough detail to support news, articles, program content, exhibitors, and practical information in the UI.
- Shared venue data is modeled separately enough to be reused across multiple events.
- At least one congress-style event is represented well enough to validate event-type-specific content and access rules, even if the first UI focus stays on one primary event.
- Mock data is used only where issue #1 allows simulation.
