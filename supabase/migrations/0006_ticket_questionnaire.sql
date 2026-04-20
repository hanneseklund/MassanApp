-- Ticket purchase questionnaire.
--
-- A signed-in visitor must answer a short questionnaire before a
-- simulated ticket purchase completes (see "Ticket purchase
-- (simulated)" in docs/functional-specification.md and the "Ticket"
-- entity in docs/implementation-specification.md). The answers are
-- stored with the ticket on `tickets.questionnaire`, and the
-- per-event subject list is configured on
-- `events.questionnaire_subjects`.
--
-- Both columns are nullable so this migration is safe against the
-- existing data: older tickets keep `questionnaire = null`, and
-- lightweight calendar-only events keep
-- `questionnaire_subjects = null` which the UI treats as "omit the
-- subjects question for this event".
--
-- Row Level Security is already scoped to
-- `auth.uid() = tickets.user_id` for both read and insert (see
-- `0001_init.sql`), so the new JSONB column is covered by the
-- existing owner policies without any further change.

alter table public.tickets
  add column if not exists questionnaire jsonb;

alter table public.events
  add column if not exists questionnaire_subjects jsonb;
