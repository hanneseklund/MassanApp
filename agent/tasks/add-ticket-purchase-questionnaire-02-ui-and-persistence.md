# Add ticket-purchase questionnaire — UI and persistence

References:
- issue #20: questionaire (https://github.com/hanneseklund/MassanApp/issues/20)
- depends on `add-ticket-purchase-questionnaire-01-schema-and-spec.md`,
  which lands the schema (`tickets.questionnaire`,
  `events.questionnaire_subjects`) and the spec language this task
  implements against.

Objective:
- Wire the questionnaire into the existing simulated ticket-purchase
  flow so that completing a purchase requires answering the questions
  defined in issue #20 and persists the answers to
  `tickets.questionnaire`. Pre-fill general profile fields from the
  signed-in user's previously-saved answers (stored in Supabase
  `user_metadata.profile`).

Scope (do):
- Add a new step to `views/purchase.js`. The flow becomes:
  1. Pick ticket type (unchanged).
  2. Questionnaire (new):
     - General questions: gender, country, region, visit type
       (`professional` | `private`); if professional, also company
       and role.
     - Event-relevant questions: subjects of interest, sourced from
       the event's `questionnaire_subjects` (multi-select). If the
       event has no subjects configured, the subjects block is
       omitted.
  3. Attendee details + summary (currently step 2 — same content,
     just renumbered).
  4. Confirmation (currently step 3 — unchanged).
- Persist on confirm:
  - Pass `questionnaire` through `tickets.add(...)` so it lands on the
    `public.tickets` row. Shape:
    `{ profile: { gender, country, region, visit_type, company,
    role }, subjects: [...selected subject strings] }`.
    Empty / unselected fields become null or empty string consistently
    (decide in implementation; document in the spec note).
  - Save the general-profile answers back to `user_metadata.profile`
    via `supabase.auth.updateUser({ data: { profile: {...} } })` so
    subsequent purchases pre-fill. Failure here must not fail the
    purchase — surface to console and continue, mirroring the points
    earn pattern.
- Pre-fill on entering the questionnaire step: read defaults from
  `Alpine.store("session").user.profile` (extend the session-store
  `mapSupabaseUser` to surface `user_metadata.profile` as
  `user.profile`). Empty profile → empty form.
- Add i18n keys for every new visible string in both `en` and `sv`
  (the unit suite enforces parity in `i18n.test.mjs`).
- Update `tests/unit/`:
  - Extend `session.test.mjs` to cover `user.profile` mapping.
  - Add a small helper module if helpers are introduced (e.g. a
    `defaultQuestionnaire(event, profile)` in
    `web/assets/js/util/questionnaire.js`) and unit-test it.
- Update `tests/playwright/smoke.spec.js`:
  - The Nordbygg purchase test must fill the questionnaire step before
    confirming. Pick at least one subject so the persisted answer is
    non-empty.
  - The ESTRO / EHA purchase test must do the same.
  - Add an assertion that on a second purchase the general-profile
    fields come back pre-filled.
- Optionally surface the persisted answers on the My Tickets card
  (compact summary). If included, document in the functional spec and
  add a smoke assertion. If skipped, leave a note in the
  implementation spec that the data is captured but not yet
  user-visible.
- Reconcile both spec docs after implementation per the
  AGENTS.md workflow rule (specify first, implement second, reconcile
  after) — confirm that the persisted shape and pre-fill rule match
  what subtask 1 wrote down, and fix any drift.

Scope (do not):
- No schema changes — those landed in subtask 1.
- No new tables. The questionnaire lives entirely in
  `tickets.questionnaire` and `user_metadata.profile`.
- No analytics or aggregation features over the answers. Storing them
  is enough for the prototype.

Acceptance criteria:
- A signed-in visitor cannot complete a Nordbygg ticket purchase
  without answering the questionnaire's required questions.
  "Required" means at minimum: visit type. Other fields are optional
  but pre-filled when known.
- A successful purchase results in a `public.tickets` row whose
  `questionnaire` JSONB contains the entered profile fields and the
  selected subjects.
- After a successful purchase, starting a second purchase pre-fills
  the general-profile fields from the prior answers without manual
  re-entry.
- The smoke suite passes against the shared Supabase project.
- The functional and implementation specifications match the shipped
  behaviour.
