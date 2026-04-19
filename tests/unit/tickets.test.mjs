// Tickets-store selectors. The network path in `_onSessionChange` can't
// run without Supabase, but the in-memory selectors over `this.tickets`
// drive the event "View ticket" CTA and the My Tickets view, and must
// stay correct when a session swap leaves stale rows in memory before
// the next fetch lands.

import test from "node:test";
import assert from "node:assert/strict";

import { ticketsStore } from "../../web/assets/js/stores/tickets.js";

function withTickets(tickets) {
  const store = ticketsStore();
  store.tickets = tickets;
  return store;
}

test("forUser: filters rows by user_id", () => {
  const store = withTickets([
    { id: "t1", user_id: "u-1", event_id: "e-1" },
    { id: "t2", user_id: "u-2", event_id: "e-1" },
    { id: "t3", user_id: "u-1", event_id: "e-2" },
  ]);
  assert.deepEqual(
    store.forUser("u-1").map((t) => t.id),
    ["t1", "t3"],
  );
  assert.deepEqual(store.forUser("u-2").map((t) => t.id), ["t2"]);
});

test("forUser: returns an empty array for null or missing user_id", () => {
  const store = withTickets([{ id: "t1", user_id: "u-1", event_id: "e-1" }]);
  assert.deepEqual(store.forUser(null), []);
  assert.deepEqual(store.forUser(undefined), []);
  assert.deepEqual(store.forUser(""), []);
});

test("forUserAndEvent: filters by both user_id and event_id", () => {
  const store = withTickets([
    { id: "t1", user_id: "u-1", event_id: "e-1" },
    { id: "t2", user_id: "u-1", event_id: "e-2" },
    { id: "t3", user_id: "u-2", event_id: "e-1" },
  ]);
  assert.deepEqual(
    store.forUserAndEvent("u-1", "e-1").map((t) => t.id),
    ["t1"],
  );
  assert.deepEqual(store.forUserAndEvent("u-1", "missing"), []);
});

test("forUserAndEvent: returns empty when either id is missing", () => {
  const store = withTickets([{ id: "t1", user_id: "u-1", event_id: "e-1" }]);
  assert.deepEqual(store.forUserAndEvent(null, "e-1"), []);
  assert.deepEqual(store.forUserAndEvent("u-1", null), []);
  assert.deepEqual(store.forUserAndEvent(null, null), []);
});

test("hasForEvent: true when the user owns at least one ticket for the event", () => {
  const store = withTickets([
    { id: "t1", user_id: "u-1", event_id: "e-1" },
    { id: "t2", user_id: "u-1", event_id: "e-1" },
  ]);
  assert.equal(store.hasForEvent("u-1", "e-1"), true);
  assert.equal(store.hasForEvent("u-1", "e-2"), false);
  assert.equal(store.hasForEvent("u-2", "e-1"), false);
});

test("hasForEvent: false when either id is missing", () => {
  const store = withTickets([{ id: "t1", user_id: "u-1", event_id: "e-1" }]);
  assert.equal(store.hasForEvent(null, "e-1"), false);
  assert.equal(store.hasForEvent("u-1", null), false);
});
