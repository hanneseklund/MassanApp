# Write Prototype Specification And Agents Guide

References:
- issue #1: Start project
- informed by `docs/research-stockholmsmassan-and-venue-apps.md`
- follows completed task `agent/tasks_completed/research-stockholmsmassan-and-venue-apps.md`

Objective:
- Turn the issue requirements and completed research findings into the project documentation structure requested in issue #1.

Deliverables:
- Replace the placeholder `README.md` with a useful project starting point.
- Create `docs/functional-specification.md`.
- Create `docs/implementation-specification.md`.
- Create `docs/installation-testing-specification.md`.
- Create `AGENTS.md` with the workflow rule that changes should be specified first, implemented second, and documentation reconciled after implementation.
- Capture the research-driven prototype scope in the specs, including `Nordbygg 2026` as the primary prototype event, shared venue-information reuse, and congress-style secondary references such as `ESTRO 2026` or `EHA2026 Congress`.

Acceptance Criteria:
- The functional specification defines the event-first mobile experience, including the one-event-at-a-time focus and the clear path back to other events.
- The functional specification identifies how shared Stockholmsmassan venue data and event-specific content should appear in the product.
- The implementation specification covers Alpine.js on the frontend, Supabase as backend, Cloudflare hosting, and simulated integrations where real ones are missing.
- The specifications reflect the completed research conclusions about the official calendar filters and the need to support both trade-fair and congress event patterns.
- The installation and testing specification explains how to set up, run, and verify the prototype locally.
