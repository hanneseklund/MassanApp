# Add ticket-purchase questionnaire — schema and spec

References:
- issue #20: questionaire (https://github.com/hanneseklund/MassanApp/issues/20)
- parent split: `add-ticket-purchase-questionnaire.md` was split into this
  task and `add-ticket-purchase-questionnaire-02-ui-and-persistence.md`
  because the schema change needs to land in the shared Supabase project
  (and the spec needs to describe the data model) before the UI work can
  reference the new columns.

Objective:
- Define how questionnaire answers are persisted, both in the schema and
  in the functional / implementation specifications, and ship the
  database changes to the shared Supabase project. No UI changes in this
  task — the existing purchase view continues to work unchanged.

Scope (do):
- Add a migration `supabase/migrations/0006_ticket_questionnaire.sql`
  that:
  - Adds a `questionnaire` JSONB column to `public.tickets`. Nullable;
    older rows stay null.
  - Adds a `questionnaire_subjects` JSONB column to `public.events`
    (array of strings). Nullable; events without configured subjects
    omit the subjects question entirely.
  - Does NOT change RLS — the existing "owners read tickets" /
    "owners insert tickets" policies cover the new column transparently.
- Apply the migration to the shared project via
  `mcp__claude_ai_Supabase__apply_migration` and verify with
  `list_tables` / `list_migrations`.
- Update `supabase/seed/seed.sql` to set `questionnaire_subjects` for
  the two fully-seeded events (`Nordbygg 2026` and the chosen
  congress event — `ESTRO 2026` or `EHA2026 Congress`):
  - Nordbygg 2026: roughly 6 construction-fair subjects (e.g.
    "Sustainable construction", "BIM and digital tools",
    "Renovation", "Heating and ventilation", "Smart buildings",
    "Building safety"). Pick what reads naturally for the seeded
    audience copy.
  - The congress event: roughly 6 oncology / haematology subjects
    appropriate to the event archetype.
  - Lightweight calendar-only events get NULL `questionnaire_subjects`
    so the subjects question is skipped for them.
- Mirror the seed change in `web/data/catalog.json` per the seed-data
  layout rule in `docs/implementation-specification.md`.
- Apply the seed update via `mcp__claude_ai_Supabase__execute_sql` and
  verify with a `select count(*)` or similar.
- Update the specs:
  - `docs/functional-specification.md` — under "Ticket purchase
    (simulated)", describe the new questionnaire step (general
    profile + per-event subjects), the pre-fill rule from the user's
    saved profile, and that the answers are stored with the ticket.
    Add the same to "My Tickets" if the answers will eventually be
    visible there (subtask 2 will decide; this task only needs to
    leave the door open).
  - `docs/implementation-specification.md` — under the Ticket entity,
    document the new `questionnaire` JSONB shape. Document the new
    `events.questionnaire_subjects` field. Mention that the
    saved general-profile defaults live in Supabase
    `user_metadata.profile` (set by the purchase flow in subtask 2)
    so subsequent purchases can pre-fill them.
- Add a brief follow-up note at the bottom of the new
  `add-ticket-purchase-questionnaire-02-ui-and-persistence.md` task
  file referencing this one.

Scope (do not):
- No UI changes. Do not touch `web/assets/js/views/purchase.js`,
  `web/assets/js/stores/tickets.js`, or `web/assets/js/stores/session.js`
  in this task.
- No new i18n keys (those land with the UI in subtask 2).
- No smoke-test or unit-test updates.

Acceptance criteria:
- `supabase/migrations/0006_ticket_questionnaire.sql` exists and the
  migration is applied to the shared `massanapp-prototype` project.
- `select column_name from information_schema.columns where table_name
  = 'tickets'` shows `questionnaire`, and the same query for `events`
  shows `questionnaire_subjects`.
- `supabase/seed/seed.sql` and `web/data/catalog.json` carry
  `questionnaire_subjects` for the fully-seeded events and remain in
  sync.
- Both spec docs describe the questionnaire and the new schema fields
  consistently with the planned UI behaviour.
