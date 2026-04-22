// purchaseView() in views/purchase.js drives the four-step simulated
// ticket purchase. The `confirm()` path is heavy — it chains simulated
// payment, tickets-store insert, profile update, and a points-earn
// call — but the form validation, step navigation, subject toggling,
// and the signed-out auth-guard redirect are all pure state
// transitions worth pinning down without a browser.
//
// Follows the Alpine.store stub pattern from my-tickets.test.mjs and
// auth.test.mjs — no browser, no Supabase, no Alpine runtime.

import test from "node:test";
import assert from "node:assert/strict";

import { purchaseView } from "../../web/assets/js/views/purchase.js";

async function withAlpine(stores, body) {
  const prev = globalThis.Alpine;
  globalThis.Alpine = {
    store(id) {
      return stores[id];
    },
  };
  try {
    return await body();
  } finally {
    globalThis.Alpine = prev;
  }
}

// Minimal lang stub. Returns `key` verbatim so tests assert which key
// was picked without depending on i18n.js copy.
function langStub() {
  return {
    t(key) {
      return key;
    },
  };
}

function makeEvent(overrides = {}) {
  return {
    id: "nordbygg-2026",
    name: "Nordbygg 2026",
    ticket_model: "public_ticket",
    questionnaire_subjects: ["Renovation", "BIM and digital tools"],
    ...overrides,
  };
}

function makeStores({
  view = "purchase",
  eventId = "nordbygg-2026",
  sessionLoading = false,
  user = null,
  event = makeEvent(),
  goAuthCalls = [],
} = {}) {
  return {
    lang: langStub(),
    app: {
      view,
      eventId,
      goAuth(...args) {
        goAuthCalls.push(args);
      },
    },
    session: {
      loading: sessionLoading,
      user,
    },
    catalog: {
      eventById(id) {
        return id === event?.id ? event : null;
      },
    },
    tickets: {
      async add(draft) {
        return { ...draft };
      },
    },
    points: {
      async tryEarn() {},
    },
    goAuthCalls,
  };
}

test("initial state: step 1, no ticket type, empty attendee, default questionnaire", () => {
  const view = purchaseView();
  assert.equal(view.step, 1);
  assert.equal(view.ticketTypeId, null);
  assert.equal(view.attendeeName, "");
  assert.equal(view.attendeeEmail, "");
  assert.equal(view.processing, false);
  assert.equal(view.error, "");
  assert.equal(view.confirmedTicket, null);
  assert.deepEqual(view.questionnaire.profile, {
    gender: "",
    country: "",
    region: "",
    visit_type: "",
    company: "",
    role: "",
  });
  assert.deepEqual(view.questionnaire.subjects, []);
});

test("_hydrate: pre-fills attendee fields and questionnaire from the signed-in user's profile", async () => {
  const stores = makeStores({
    user: {
      id: "u-1",
      email: "alice@example.com",
      display_name: "Alice",
      profile: {
        gender: "female",
        country: "Sweden",
        region: "Stockholm",
        visit_type: "professional",
        company: "Acme",
        role: "Architect",
      },
    },
  });
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view._hydrate();
    assert.equal(view.attendeeName, "Alice");
    assert.equal(view.attendeeEmail, "alice@example.com");
    assert.equal(view.questionnaire.profile.gender, "female");
    assert.equal(view.questionnaire.profile.visit_type, "professional");
    assert.equal(view.questionnaire.profile.company, "Acme");
    assert.deepEqual(view.questionnaire.subjectOptions, [
      "Renovation",
      "BIM and digital tools",
    ]);
  });
});

test("_hydrate: resets to step 1 and clears any in-flight error / confirmed ticket", async () => {
  const stores = makeStores({ user: { id: "u-1", email: "a@b.c" } });
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view.step = 3;
    view.ticketTypeId = "day_pass";
    view.error = "boom";
    view.confirmedTicket = { id: "t1" };
    view.processing = true;
    view._hydrate();
    assert.equal(view.step, 1);
    assert.equal(view.ticketTypeId, null);
    assert.equal(view.error, "");
    assert.equal(view.confirmedTicket, null);
    assert.equal(view.processing, false);
  });
});

test("_applyAuthGuardAndHydrate: no-op when not on the purchase view", async () => {
  const goAuthCalls = [];
  const stores = makeStores({ view: "calendar", user: null, goAuthCalls });
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view.ticketTypeId = "day_pass"; // should stay put because hydrate does not run
    view._applyAuthGuardAndHydrate();
    assert.equal(view.ticketTypeId, "day_pass");
    assert.equal(goAuthCalls.length, 0);
  });
});

test("_applyAuthGuardAndHydrate: waits while session.loading is true", async () => {
  const goAuthCalls = [];
  const stores = makeStores({
    sessionLoading: true,
    user: null,
    goAuthCalls,
  });
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view._applyAuthGuardAndHydrate();
    // A still-loading Supabase session must not be treated as signed out.
    assert.equal(goAuthCalls.length, 0);
  });
});

test("_applyAuthGuardAndHydrate: signed-out visitor is redirected through auth and returned to purchase", async () => {
  const goAuthCalls = [];
  const stores = makeStores({ user: null, goAuthCalls });
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view._applyAuthGuardAndHydrate();
    assert.equal(goAuthCalls.length, 1);
    assert.deepEqual(goAuthCalls[0], [
      { view: "purchase", eventId: "nordbygg-2026" },
    ]);
  });
});

test("_applyAuthGuardAndHydrate: signed-in visitor triggers hydrate", async () => {
  const goAuthCalls = [];
  const stores = makeStores({
    user: { id: "u-1", email: "a@b.c", display_name: "A" },
    goAuthCalls,
  });
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view._applyAuthGuardAndHydrate();
    assert.equal(goAuthCalls.length, 0);
    assert.equal(view.attendeeEmail, "a@b.c");
  });
});

test("event() / ticketTypes(): resolve through the catalog and sections helpers", async () => {
  const stores = makeStores({ user: { id: "u-1" } });
  await withAlpine(stores, async () => {
    const view = purchaseView();
    const ev = view.event();
    assert.equal(ev?.id, "nordbygg-2026");
    const types = view.ticketTypes();
    // public_ticket has two canonical types: day_pass and full_event.
    assert.deepEqual(
      types.map((t) => t.id).sort(),
      ["day_pass", "full_event"],
    );
  });
});

test("event(): null when the app has no selected event", async () => {
  const stores = makeStores({ eventId: null });
  await withAlpine(stores, async () => {
    assert.equal(purchaseView().event(), null);
  });
});

test("selectedTicketType(): returns the matching ticket-type entry or null", async () => {
  const stores = makeStores({ user: { id: "u-1" } });
  await withAlpine(stores, async () => {
    const view = purchaseView();
    assert.equal(view.selectedTicketType(), null);
    view.ticketTypeId = "day_pass";
    assert.equal(view.selectedTicketType()?.id, "day_pass");
    view.ticketTypeId = "not-a-real-type";
    assert.equal(view.selectedTicketType(), null);
  });
});

test("subjects() / hasSubjects(): reflect the event's configured list", async () => {
  const stores = makeStores();
  await withAlpine(stores, async () => {
    const view = purchaseView();
    assert.deepEqual(view.subjects(), [
      "Renovation",
      "BIM and digital tools",
    ]);
    assert.equal(view.hasSubjects(), true);
  });
});

test("hasSubjects(): false when the event carries no questionnaire_subjects", async () => {
  const stores = makeStores({
    event: makeEvent({ questionnaire_subjects: null }),
  });
  await withAlpine(stores, async () => {
    assert.equal(purchaseView().hasSubjects(), false);
  });
});

test("toggleSubject / isSubjectSelected: add, remove, and dedupe subjects", async () => {
  const stores = makeStores();
  await withAlpine(stores, async () => {
    const view = purchaseView();
    assert.equal(view.isSubjectSelected("Renovation"), false);
    view.toggleSubject("Renovation");
    assert.equal(view.isSubjectSelected("Renovation"), true);
    view.toggleSubject("BIM and digital tools");
    assert.deepEqual(view.questionnaire.subjects, [
      "Renovation",
      "BIM and digital tools",
    ]);
    view.toggleSubject("Renovation");
    assert.deepEqual(view.questionnaire.subjects, ["BIM and digital tools"]);
  });
});

test("isProfessional(): tracks the profile.visit_type value", async () => {
  const stores = makeStores();
  await withAlpine(stores, async () => {
    const view = purchaseView();
    assert.equal(view.isProfessional(), false);
    view.questionnaire.profile.visit_type = "private";
    assert.equal(view.isProfessional(), false);
    view.questionnaire.profile.visit_type = "professional";
    assert.equal(view.isProfessional(), true);
  });
});

test("goToStep: sets the step and clears any leftover error", () => {
  const view = purchaseView();
  view.step = 1;
  view.error = "boom";
  view.goToStep(3);
  assert.equal(view.step, 3);
  assert.equal(view.error, "");
});

test("continueToQuestionnaire: blocked without a ticket type, surfaces lang key", async () => {
  const stores = makeStores();
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view.continueToQuestionnaire();
    assert.equal(view.step, 1);
    assert.equal(view.error, "purchase.err_pick_type");
  });
});

test("continueToQuestionnaire: advances to step 2 when a ticket type is selected", async () => {
  const stores = makeStores();
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view.ticketTypeId = "day_pass";
    view.continueToQuestionnaire();
    assert.equal(view.step, 2);
    assert.equal(view.error, "");
  });
});

test("continueToDetails: blocked without a visit_type, surfaces lang key", async () => {
  const stores = makeStores();
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view.continueToDetails();
    assert.equal(view.step, 1); // unchanged because goToStep was not called
    assert.equal(view.error, "purchase.err_pick_visit_type");
  });
});

test("continueToDetails: advances to step 3 when visit_type is set", async () => {
  const stores = makeStores();
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view.step = 2;
    view.questionnaire.profile.visit_type = "private";
    view.continueToDetails();
    assert.equal(view.step, 3);
    assert.equal(view.error, "");
  });
});

test("confirm(): resets to step 1 and surfaces an error when event or ticket type is missing", async () => {
  const stores = makeStores({ eventId: null });
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view.step = 3;
    await view.confirm();
    assert.equal(view.step, 1);
    assert.equal(view.error, "purchase.err_pick_first");
    assert.equal(view.processing, false);
  });
});

test("confirm(): routes back to step 2 and surfaces an error when visit_type is missing", async () => {
  const stores = makeStores({ user: { id: "u-1" } });
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view.step = 3;
    view.ticketTypeId = "day_pass";
    view.questionnaire.profile.visit_type = "";
    await view.confirm();
    assert.equal(view.step, 2);
    assert.equal(view.error, "purchase.err_pick_visit_type");
  });
});

test("confirm(): surfaces the sign-in error when the visitor is not authenticated", async () => {
  const stores = makeStores({ user: null });
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view.step = 3;
    view.ticketTypeId = "day_pass";
    view.questionnaire.profile.visit_type = "private";
    await view.confirm();
    assert.equal(view.error, "purchase.err_sign_in");
    assert.equal(view.processing, false);
  });
});

test("confirm(): surfaces the attendee-required error when name or email is blank", async () => {
  const stores = makeStores({
    user: { id: "u-1", email: "", display_name: "" },
  });
  await withAlpine(stores, async () => {
    const view = purchaseView();
    view.step = 3;
    view.ticketTypeId = "day_pass";
    view.questionnaire.profile.visit_type = "private";
    view.attendeeName = "   ";
    view.attendeeEmail = "";
    await view.confirm();
    assert.equal(view.error, "purchase.err_attendee_required");
    assert.equal(view.processing, false);
  });
});
