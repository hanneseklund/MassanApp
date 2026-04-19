// Ticket-type catalog and CTA helpers from util/sections.js. The
// catalog is keyed by an event's `ticket_model`; persisted fields
// (canonicalTicketTypeLabel) must stay in English so a saved wallet
// entry does not flip language based on who later opens it.

import test from "node:test";
import assert from "node:assert/strict";

import {
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
