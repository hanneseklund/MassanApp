// Ticket-purchase questionnaire helpers in
// web/assets/js/util/questionnaire.js. `defaultQuestionnaire` seeds the
// form state from the signed-in user's saved profile and the event's
// subject list; `buildQuestionnairePayload` and `buildProfileUpdate`
// serialize the form back into the persisted JSONB shape documented in
// docs/implementation-specification.md under "Ticket".

import test from "node:test";
import assert from "node:assert/strict";

import {
  defaultQuestionnaire,
  subjectsFor,
  buildQuestionnairePayload,
  buildProfileUpdate,
  PROFILE_FIELDS,
} from "../../web/assets/js/util/questionnaire.js";

test("PROFILE_FIELDS: matches the documented persisted shape", () => {
  assert.deepEqual(PROFILE_FIELDS, [
    "gender",
    "country",
    "region",
    "visit_type",
    "company",
    "role",
  ]);
});

test("defaultQuestionnaire: empty profile produces empty-string defaults", () => {
  const q = defaultQuestionnaire(null, {});
  assert.deepEqual(q.profile, {
    gender: "",
    country: "",
    region: "",
    visit_type: "",
    company: "",
    role: "",
  });
  assert.deepEqual(q.subjects, []);
  assert.deepEqual(q.subjectOptions, []);
});

test("defaultQuestionnaire: pre-fills from the saved profile", () => {
  const q = defaultQuestionnaire(
    { id: "nordbygg-2026", questionnaire_subjects: ["Smart buildings"] },
    {
      gender: "female",
      country: "Sweden",
      region: "Stockholm",
      visit_type: "professional",
      company: "Acme",
      role: "Architect",
    },
  );
  assert.equal(q.profile.gender, "female");
  assert.equal(q.profile.visit_type, "professional");
  assert.equal(q.profile.company, "Acme");
  assert.deepEqual(q.subjectOptions, ["Smart buildings"]);
});

test("subjectsFor: returns [] for events without a configured list", () => {
  assert.deepEqual(subjectsFor(null), []);
  assert.deepEqual(subjectsFor({}), []);
  assert.deepEqual(subjectsFor({ questionnaire_subjects: null }), []);
  assert.deepEqual(subjectsFor({ questionnaire_subjects: "nope" }), []);
});

test("subjectsFor: returns the string entries for seeded events", () => {
  assert.deepEqual(
    subjectsFor({
      questionnaire_subjects: ["Renovation", "BIM and digital tools"],
    }),
    ["Renovation", "BIM and digital tools"],
  );
});

test("subjectsFor: filters out non-string and empty entries defensively", () => {
  assert.deepEqual(
    subjectsFor({
      questionnaire_subjects: ["Renovation", "", null, 42, "BIM"],
    }),
    ["Renovation", "BIM"],
  );
});

test("buildQuestionnairePayload: strips company/role when visit_type is private", () => {
  const payload = buildQuestionnairePayload({
    profile: {
      gender: "male",
      country: "Sweden",
      region: "",
      visit_type: "private",
      company: "Left over from a previous pick",
      role: "Left over too",
    },
    subjects: ["Renovation"],
  });
  assert.equal(payload.profile.visit_type, "private");
  assert.equal(payload.profile.company, "");
  assert.equal(payload.profile.role, "");
  assert.deepEqual(payload.subjects, ["Renovation"]);
});

test("buildQuestionnairePayload: keeps company/role when visit_type is professional", () => {
  const payload = buildQuestionnairePayload({
    profile: {
      gender: "",
      country: "",
      region: "",
      visit_type: "professional",
      company: "Acme",
      role: "Architect",
    },
    subjects: [],
  });
  assert.equal(payload.profile.company, "Acme");
  assert.equal(payload.profile.role, "Architect");
  assert.deepEqual(payload.subjects, []);
});

test("buildQuestionnairePayload: returns a detached subjects array", () => {
  // Subjects round-trip by value, not by reference — the payload must
  // not share the Alpine-reactive array.
  const form = {
    profile: { visit_type: "private" },
    subjects: ["Renovation"],
  };
  const payload = buildQuestionnairePayload(form);
  payload.subjects.push("Mutated");
  assert.deepEqual(form.subjects, ["Renovation"]);
});

test("buildProfileUpdate: mirrors the serialized profile block", () => {
  const update = buildProfileUpdate({
    profile: {
      gender: "female",
      country: "Sweden",
      region: "Stockholm",
      visit_type: "professional",
      company: "Acme",
      role: "Architect",
    },
    subjects: ["Renovation"],
  });
  assert.deepEqual(update, {
    gender: "female",
    country: "Sweden",
    region: "Stockholm",
    visit_type: "professional",
    company: "Acme",
    role: "Architect",
  });
});
