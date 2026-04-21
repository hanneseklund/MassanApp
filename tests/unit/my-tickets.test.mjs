// myTicketsView() in views/my-tickets.js sorts the signed-in user's
// tickets. Issue #22 requires tickets for the currently selected event
// to appear on top, with tickets for other events below and the two
// groups each ordered by purchased_at descending.

import test from "node:test";
import assert from "node:assert/strict";

import { myTicketsView } from "../../web/assets/js/views/my-tickets.js";

function withAlpine(stores, body) {
  const prev = globalThis.Alpine;
  globalThis.Alpine = {
    store(id) {
      return stores[id];
    },
  };
  try {
    return body();
  } finally {
    globalThis.Alpine = prev;
  }
}

function makeStores({ user, tickets, selectedEventId = null }) {
  return {
    session: { user },
    app: { eventId: selectedEventId },
    tickets: {
      forUser(userId) {
        return tickets.filter((t) => t.user_id === userId);
      },
    },
    catalog: {
      eventById() {
        return null;
      },
    },
  };
}

test("tickets(): returns an empty array when signed out", () => {
  withAlpine(
    makeStores({ user: null, tickets: [], selectedEventId: "e-1" }),
    () => {
      assert.deepEqual(myTicketsView().tickets(), []);
    },
  );
});

test("tickets(): without a selected event, sorts by purchased_at descending", () => {
  withAlpine(
    makeStores({
      user: { id: "u-1" },
      tickets: [
        { id: "t1", user_id: "u-1", event_id: "e-1", purchased_at: "2026-03-01" },
        { id: "t2", user_id: "u-1", event_id: "e-2", purchased_at: "2026-04-01" },
        { id: "t3", user_id: "u-1", event_id: "e-3", purchased_at: "2026-02-01" },
      ],
      selectedEventId: null,
    }),
    () => {
      const ids = myTicketsView()
        .tickets()
        .map((t) => t.id);
      assert.deepEqual(ids, ["t2", "t1", "t3"]);
    },
  );
});

test("tickets(): with a selected event, lists tickets for that event on top", () => {
  // Even though t3 is the most recently purchased overall, t1 and t2
  // belong to the selected event and must appear first. Within each
  // group the purchased_at descending order is preserved.
  withAlpine(
    makeStores({
      user: { id: "u-1" },
      tickets: [
        { id: "t1", user_id: "u-1", event_id: "e-1", purchased_at: "2026-03-01" },
        { id: "t2", user_id: "u-1", event_id: "e-1", purchased_at: "2026-01-01" },
        { id: "t3", user_id: "u-1", event_id: "e-2", purchased_at: "2026-04-01" },
        { id: "t4", user_id: "u-1", event_id: "e-3", purchased_at: "2026-02-01" },
      ],
      selectedEventId: "e-1",
    }),
    () => {
      const ids = myTicketsView()
        .tickets()
        .map((t) => t.id);
      assert.deepEqual(ids, ["t1", "t2", "t3", "t4"]);
    },
  );
});

test("tickets(): only the signed-in user's rows are considered", () => {
  withAlpine(
    makeStores({
      user: { id: "u-1" },
      tickets: [
        { id: "t1", user_id: "u-1", event_id: "e-1", purchased_at: "2026-03-01" },
        { id: "t2", user_id: "u-2", event_id: "e-1", purchased_at: "2026-04-01" },
      ],
      selectedEventId: "e-1",
    }),
    () => {
      const ids = myTicketsView()
        .tickets()
        .map((t) => t.id);
      assert.deepEqual(ids, ["t1"]);
    },
  );
});
