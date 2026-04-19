// Points earning rules in util/points.js and the balance selector in
// stores/points.js. The network paths in `_onSessionChange`, `earn`,
// and `redeem` require Supabase and Alpine, so we test the pure
// earning-rate calculators directly and exercise the store's
// `balance` / `forUser` selectors over an injected transaction list.

import test from "node:test";
import assert from "node:assert/strict";

import {
  POINTS_PER_TICKET,
  pointsForTicket,
  pointsForFoodOrder,
} from "../../web/assets/js/util/points.js";

import { pointsStore } from "../../web/assets/js/stores/points.js";

test("POINTS_PER_TICKET: fixed at 100", () => {
  assert.equal(POINTS_PER_TICKET, 100);
});

test("pointsForTicket: always returns 100 regardless of ticket type or event", () => {
  assert.equal(pointsForTicket({ ticket_type: "day_pass" }), 100);
  assert.equal(
    pointsForTicket({ ticket_type: "delegate", event_id: "estro-2026" }),
    100,
  );
});

test("pointsForFoodOrder: 1 point per SEK parsed from the price string", () => {
  assert.equal(pointsForFoodOrder({ price: "SEK 129" }), 129);
  assert.equal(pointsForFoodOrder({ price: "SEK 39" }), 39);
  assert.equal(pointsForFoodOrder({ price: "SEK 49" }), 49);
});

test("pointsForFoodOrder: 0 for unparseable or missing prices", () => {
  assert.equal(pointsForFoodOrder({ price: "free" }), 0);
  assert.equal(pointsForFoodOrder({ price: null }), 0);
  assert.equal(pointsForFoodOrder({}), 0);
  assert.equal(pointsForFoodOrder(null), 0);
});

function withTransactions(rows) {
  const store = pointsStore();
  store.transactions = rows;
  return store;
}

test("balance: sums `delta` across loaded transactions", () => {
  const store = withTransactions([
    { delta: 100, user_id: "u-1" },
    { delta: 129, user_id: "u-1" },
    { delta: -80, user_id: "u-1" },
  ]);
  assert.equal(store.balance, 149);
});

test("balance: zero when the user has no transactions", () => {
  const store = withTransactions([]);
  assert.equal(store.balance, 0);
});

test("forUser: filters rows by user_id", () => {
  const store = withTransactions([
    { id: "p1", user_id: "u-1", delta: 100 },
    { id: "p2", user_id: "u-2", delta: 100 },
    { id: "p3", user_id: "u-1", delta: -50 },
  ]);
  assert.deepEqual(
    store.forUser("u-1").map((t) => t.id),
    ["p1", "p3"],
  );
  assert.deepEqual(store.forUser(null), []);
});
