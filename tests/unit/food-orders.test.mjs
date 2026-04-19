// Food-orders-store selector. The network path in `_onSessionChange`
// can't run without Supabase, but the in-memory `forUser` selector
// filters persisted orders to the signed-in user and must stay
// correct when a session swap leaves stale rows in memory before
// the next fetch lands — same rule as the tickets store.

import test from "node:test";
import assert from "node:assert/strict";

import { foodOrdersStore } from "../../web/assets/js/stores/food-orders.js";

function withOrders(orders) {
  const store = foodOrdersStore();
  store.orders = orders;
  return store;
}

test("forUser: filters rows by user_id", () => {
  const store = withOrders([
    { id: "o1", user_id: "u-1", event_id: "e-1" },
    { id: "o2", user_id: "u-2", event_id: "e-1" },
    { id: "o3", user_id: "u-1", event_id: "e-2" },
  ]);
  assert.deepEqual(
    store.forUser("u-1").map((o) => o.id),
    ["o1", "o3"],
  );
  assert.deepEqual(
    store.forUser("u-2").map((o) => o.id),
    ["o2"],
  );
});

test("forUser: returns an empty array for null or missing user_id", () => {
  const store = withOrders([{ id: "o1", user_id: "u-1", event_id: "e-1" }]);
  assert.deepEqual(store.forUser(null), []);
  assert.deepEqual(store.forUser(undefined), []);
  assert.deepEqual(store.forUser(""), []);
});
