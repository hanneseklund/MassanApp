// Ticket-type catalog and CTA helpers from util/sections.js. The
// catalog is keyed by an event's `ticket_model`; persisted fields
// (canonicalTicketTypeLabel) must stay in English so a saved wallet
// entry does not flip language based on who later opens it.

import test from "node:test";
import assert from "node:assert/strict";

import {
  SECTION_LABELS,
  ticketTypesFor,
  ticketCtaLabel,
  canonicalTicketTypeLabel,
} from "../../web/assets/js/util/sections.js";

test("ticketTypesFor: public_ticket events expose day_pass and full_event", () => {
  const types = ticketTypesFor({ ticket_model: "public_ticket" });
  const ids = types.map((t) => t.id);
  assert.deepEqual(ids, ["day_pass", "full_event"]);
});

test("ticketTypesFor: registration events expose a single delegate type", () => {
  const types = ticketTypesFor({ ticket_model: "registration" });
  assert.equal(types.length, 1);
  assert.equal(types[0].id, "delegate");
});

test("ticketTypesFor: unknown ticket_model yields an empty list", () => {
  assert.deepEqual(ticketTypesFor({ ticket_model: "none" }), []);
  assert.deepEqual(ticketTypesFor({}), []);
  assert.deepEqual(ticketTypesFor(null), []);
});

test("ticketCtaLabel: public_ticket yields the English 'Get tickets'", () => {
  assert.equal(ticketCtaLabel({ ticket_model: "public_ticket" }), "Get tickets");
});

test("ticketCtaLabel: registration yields 'Register as delegate'", () => {
  assert.equal(
    ticketCtaLabel({ ticket_model: "registration" }),
    "Register as delegate",
  );
});

test("ticketCtaLabel: no ticket model or unknown model returns empty", () => {
  assert.equal(ticketCtaLabel(null), "");
  assert.equal(ticketCtaLabel({ ticket_model: "none" }), "");
});

test("canonicalTicketTypeLabel: known ids resolve to English labels", () => {
  assert.equal(canonicalTicketTypeLabel("day_pass"), "Day pass");
  assert.equal(canonicalTicketTypeLabel("full_event"), "Full event pass");
  assert.equal(canonicalTicketTypeLabel("delegate"), "Delegate registration");
});

test("canonicalTicketTypeLabel: unknown id falls back to the id itself", () => {
  assert.equal(canonicalTicketTypeLabel("not-a-real-type"), "not-a-real-type");
});

test("SECTION_LABELS: ids match the event-nav subview order", () => {
  // The event nav tabs render in this order in index.html. Reordering
  // would change the visible tab order; a mismatch with the hash-route
  // subview list in stores/app.js would break deep-linking.
  assert.deepEqual(
    SECTION_LABELS.map((s) => s.id),
    ["news", "articles", "program", "exhibitors", "practical", "food", "newsletter"],
  );
});

test("SECTION_LABELS: labels resolve against the default language", () => {
  // Labels are getters that read the active UI language. In Node
  // without Alpine, activeTranslate falls back to English.
  const byId = Object.fromEntries(SECTION_LABELS.map((s) => [s.id, s.label]));
  assert.equal(byId.news, "News");
  assert.equal(byId.articles, "Articles");
  assert.equal(byId.program, "Program");
  assert.equal(byId.exhibitors, "Exhibitors");
  assert.equal(byId.practical, "Practical info");
  assert.equal(byId.food, "Food");
  assert.equal(byId.newsletter, "Newsletter");
});
