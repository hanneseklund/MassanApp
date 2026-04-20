// Points earning rules in util/points.js and the selectors +
// write-path behavior in stores/points.js. `_onSessionChange` still
// goes through `loadUserRows` in session-sync.test.mjs; this suite
// covers the pure earning-rate calculators, the balance/forUser
// selectors, and the `earn`/`redeem` insert path with stubbed
// Supabase and Alpine globals.

import test from "node:test";
import assert from "node:assert/strict";

import {
  POINTS_PER_TICKET,
  pointsForTicket,
  pointsForFoodOrder,
} from "../../web/assets/js/util/points.js";

import { pointsStore } from "../../web/assets/js/stores/points.js";

// Fake Supabase client shaped like the `.from(t).insert(r).select("*").single()`
// chain the points store uses. Each call returns `this` so the chain
// resolves to `_nextResult`.
const fakeDb = {
  _nextResult: { data: null, error: null },
  _lastInsert: null,
  _reset() {
    this._nextResult = { data: null, error: null };
    this._lastInsert = null;
  },
  from(_table) {
    return this;
  },
  insert(row) {
    this._lastInsert = row;
    return this;
  },
  select(_cols) {
    return this;
  },
  single() {
    return Promise.resolve(this._nextResult);
  },
};

globalThis.window = {
  MASSANAPP_ENV: {
    SUPABASE_URL: "http://fake.local",
    SUPABASE_ANON_KEY: "fake-anon",
  },
  supabase: { createClient: () => fakeDb },
};

const fakeAlpineStore = {};
globalThis.Alpine = {
  store(id) {
    return fakeAlpineStore[id];
  },
};

function setupInsertSuite() {
  fakeDb._reset();
  for (const key of Object.keys(fakeAlpineStore)) {
    delete fakeAlpineStore[key];
  }
  fakeAlpineStore.session = { user: { id: "u-1" } };
}

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

test("earn: persists the inserted row and clears a prior error on success", async () => {
  setupInsertSuite();
  const row = {
    id: "p-1",
    user_id: "u-1",
    event_id: "nordbygg-2026",
    source: "ticket",
    source_ref: "t-1",
    delta: 100,
  };
  fakeDb._nextResult = { data: row, error: null };
  const store = pointsStore();
  store.error = "earlier load failure";
  await store.earn({
    source: "ticket",
    source_ref: "t-1",
    amount: 100,
    event_id: "nordbygg-2026",
  });
  assert.equal(store.error, null);
  assert.deepEqual(store.transactions[0], row);
  assert.equal(fakeDb._lastInsert.delta, 100);
  assert.equal(fakeDb._lastInsert.source, "ticket");
  assert.equal(fakeDb._lastInsert.user_id, "u-1");
});

test("earn: surfaces a write failure through store.error and rethrows", async () => {
  setupInsertSuite();
  fakeDb._nextResult = { data: null, error: { message: "rls denied" } };
  const store = pointsStore();
  store.error = null;
  await assert.rejects(
    () =>
      store.earn({
        source: "ticket",
        source_ref: "t-1",
        amount: 100,
        event_id: "nordbygg-2026",
      }),
    /rls denied/,
  );
  assert.equal(store.error, "rls denied");
  assert.deepEqual(store.transactions, []);
});

test("redeem: writes a negative delta and clears a prior error", async () => {
  setupInsertSuite();
  const row = {
    id: "p-2",
    user_id: "u-1",
    event_id: null,
    source: "merch_redemption",
    source_ref: "tote-bag",
    delta: -150,
  };
  fakeDb._nextResult = { data: row, error: null };
  const store = pointsStore();
  store.error = "earlier";
  await store.redeem({
    source: "merch_redemption",
    source_ref: "tote-bag",
    amount: 150,
    event_id: null,
  });
  assert.equal(fakeDb._lastInsert.delta, -150);
  assert.equal(fakeDb._lastInsert.event_id, null);
  assert.equal(store.error, null);
  assert.deepEqual(store.transactions[0], row);
});

test("redeem: coerces a positive amount into a negative delta", async () => {
  setupInsertSuite();
  fakeDb._nextResult = {
    data: { id: "p-3", delta: -25 },
    error: null,
  };
  const store = pointsStore();
  await store.redeem({
    source: "addon_redemption",
    source_ref: "a-1",
    amount: 25,
    event_id: "nordbygg-2026",
  });
  assert.equal(fakeDb._lastInsert.delta, -25);
});

test("earn: throws a clear error when no session user is present", async () => {
  setupInsertSuite();
  fakeAlpineStore.session = { user: null };
  const store = pointsStore();
  await assert.rejects(
    () =>
      store.earn({
        source: "ticket",
        source_ref: "t-1",
        amount: 100,
        event_id: "nordbygg-2026",
      }),
    /no signed-in user/,
  );
});
