// Ticket-purchase questionnaire helpers.
//
// See "Ticket purchase (simulated)" in docs/functional-specification.md
// and the "Ticket" entity in docs/implementation-specification.md for
// the persisted shape. The purchase view uses these helpers to build
// the initial form state (pre-filling general-profile fields from the
// signed-in user's saved profile) and to serialize the form back into
// the `{ profile: {...}, subjects: [...] }` JSONB payload written to
// `public.tickets.questionnaire`.

export const PROFILE_FIELDS = [
  "gender",
  "country",
  "region",
  "visit_type",
  "company",
  "role",
];

// Build the initial form values for the questionnaire step. The
// returned object is mutated by the Alpine component as the visitor
// edits the form. Unanswered optional fields round-trip as empty
// strings so the persisted JSONB shape stays consistent across
// purchases.
export function defaultQuestionnaire(event, profile) {
  const source = profile && typeof profile === "object" ? profile : {};
  return {
    profile: {
      gender: source.gender ?? "",
      country: source.country ?? "",
      region: source.region ?? "",
      visit_type: source.visit_type ?? "",
      company: source.company ?? "",
      role: source.role ?? "",
    },
    subjects: [],
    subjectOptions: subjectsFor(event),
  };
}

// Event-relevant subjects sourced from `events.questionnaire_subjects`.
// A missing or non-array value means "no subjects configured" and the
// subjects block is omitted from the UI. Display uses `pickLang` at
// render time so the dual-language seed shape (sub-task 01c) renders
// in the active UI language; before 01c the entries are still plain
// strings and pickLang's transitional fallback returns them as-is.
export function subjectsFor(event) {
  if (!event || !Array.isArray(event.questionnaire_subjects)) return [];
  return event.questionnaire_subjects.filter(
    (s) => typeof s === "string" && s.length > 0,
  );
}

// Serialize the questionnaire form state into the JSONB shape written
// to `tickets.questionnaire`.
export function buildQuestionnairePayload(form) {
  const profile = form?.profile ?? {};
  const isProfessional = profile.visit_type === "professional";
  return {
    profile: {
      gender: profile.gender ?? "",
      country: profile.country ?? "",
      region: profile.region ?? "",
      visit_type: profile.visit_type ?? "",
      // Non-professional purchases never carry company/role even if the
      // visitor filled them in before switching visit types.
      company: isProfessional ? profile.company ?? "" : "",
      role: isProfessional ? profile.role ?? "" : "",
    },
    subjects: Array.isArray(form?.subjects) ? [...form.subjects] : [],
  };
}

// Profile subset persisted back to the user's Supabase account so
// subsequent purchases can pre-fill. Always a full PROFILE_FIELDS
// object (empty strings for unanswered fields) so a partial update
// cannot leave half a profile behind.
export function buildProfileUpdate(form) {
  const payload = buildQuestionnairePayload(form);
  return payload.profile;
}
