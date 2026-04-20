// util/session-sync.js — the shared sign-in / sign-out fetch contract
// used by the user-scoped stores (tickets, newsletter, foodOrders,
// points). The store-specific tests cover the selectors over
// already-loaded rows; this suite locks in the load path itself so the
// four stores keep the same clear-on-signed-out, set-loading,
// select-plus-console.warn-on-failure behavior.
//
// The helpers reach for `Alpine.store(...)` and for the singleton
// Supabase client. Both are stubbed through `globalThis` before the
// module is imported; `supabase.js` only reads `window` inside
// `supabaseClient()`, so a static import is safe.

import test from "node:test";
import assert from "node:assert/strict";

const fakeDb = {
  _nextResult: { data: [], error: null },
  _calls: [],
  _reset() {
    this._nextResult = { data: [], error: null };
    this._calls = [];
  },
  from(table) {
    this._calls.push({ op: "from", table });
    return this;
  },
  select(cols) {
    this._calls.push({ op: "select", cols });
    return this;
  },
  order(col, opts) {
    this._calls.push({ op: "order", col, opts });
    return this;
  },
  then(onFulfilled, onRejected) {
    return Promise.resolve(this._nextResult).then(onFulfilled, onRejected);
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

const { loadUserRows, notifySessionStores, SESSION_SYNC_STORE_IDS } =
  await import("../../web/assets/js/util/session-sync.js");

function resetSuite() {
  fakeDb._reset();
  for (const key of Object.keys(fakeAlpineStore)) {
    delete fakeAlpineStore[key];
  }
  fakeAlpineStore.session = { user: null };
}

function captureWarnings(run) {
  const original = console.warn;
  const warnings = [];
  console.warn = (...args) => warnings.push(args);
  return run().finally(() => {
    console.warn = original;
  }).then(() => warnings);
}

test("SESSION_SYNC_STORE_IDS: the four user-scoped stores notified on auth change", () => {
  assert.deepEqual(SESSION_SYNC_STORE_IDS, [
    "tickets",
    "newsletter",
    "foodOrders",
    "points",
  ]);
});

test("notifySessionStores: calls _onSessionChange on every registered store", () => {
  resetSuite();
  const called = [];
  for (const id of SESSION_SYNC_STORE_IDS) {
    fakeAlpineStore[id] = {
      _onSessionChange() {
        called.push(id);
      },
    };
  }
  notifySessionStores();
  assert.deepEqual(called, [...SESSION_SYNC_STORE_IDS]);
});

test("notifySessionStores: tolerates a store id with no Alpine entry", () => {
  resetSuite();
  // None of the user-scoped stores are registered; the optional-chain
  // in notifySessionStores must swallow the missing entry.
  assert.doesNotThrow(() => notifySessionStores());
});

test("notifySessionStores: tolerates a store without _onSessionChange", () => {
  resetSuite();
  for (const id of SESSION_SYNC_STORE_IDS) {
    fakeAlpineStore[id] = { unrelated: true };
  }
  assert.doesNotThrow(() => notifySessionStores());
});

test("loadUserRows: clears rows and error and skips the fetch when signed out", async () => {
  resetSuite();
  const store = {
    items: [{ id: "stale" }],
    loading: false,
    error: "earlier",
  };
  await loadUserRows(store, { table: "tickets", field: "items" });
  assert.deepEqual(store.items, []);
  assert.equal(store.error, null);
  assert.equal(store.loading, false);
  assert.equal(fakeDb._calls.length, 0);
});

test("loadUserRows: loads rows into store[field] for a signed-in user", async () => {
  resetSuite();
  fakeAlpineStore.session = { user: { id: "u-1" } };
  fakeDb._nextResult = {
    data: [{ id: "t-1" }, { id: "t-2" }],
    error: null,
  };
  const store = { items: [], loading: false, error: null };
  await loadUserRows(store, { table: "tickets", field: "items" });
  assert.deepEqual(store.items, [{ id: "t-1" }, { id: "t-2" }]);
  assert.equal(store.loading, false);
  assert.equal(store.error, null);
  assert.deepEqual(fakeDb._calls, [
    { op: "from", table: "tickets" },
    { op: "select", cols: "*" },
  ]);
});

test("loadUserRows: applies orderBy descending when provided", async () => {
  resetSuite();
  fakeAlpineStore.session = { user: { id: "u-1" } };
  fakeDb._nextResult = { data: [], error: null };
  const store = { items: [], loading: false, error: null };
  await loadUserRows(store, {
    table: "tickets",
    field: "items",
    orderBy: "purchased_at",
  });
  assert.deepEqual(fakeDb._calls, [
    { op: "from", table: "tickets" },
    { op: "select", cols: "*" },
    { op: "order", col: "purchased_at", opts: { ascending: false } },
  ]);
});

test("loadUserRows: maps rows through normalize when provided", async () => {
  resetSuite();
  fakeAlpineStore.session = { user: { id: "u-1" } };
  fakeDb._nextResult = {
    data: [{ id: "s-1", raw: true }],
    error: null,
  };
  const store = { items: [], loading: false, error: null };
  await loadUserRows(store, {
    table: "newsletter_subscriptions",
    field: "items",
    normalize: (row) => ({ ...row, normalized: true }),
  });
  assert.deepEqual(store.items, [
    { id: "s-1", raw: true, normalized: true },
  ]);
});

test("loadUserRows: records the error and clears rows on a failed fetch", async () => {
  resetSuite();
  fakeAlpineStore.session = { user: { id: "u-1" } };
  fakeDb._nextResult = {
    data: null,
    error: { message: "rls denied" },
  };
  const store = {
    items: [{ id: "stale" }],
    loading: false,
    error: null,
  };
  const warnings = await captureWarnings(() =>
    loadUserRows(store, {
      table: "tickets",
      field: "items",
      logLabel: "ticket rows",
    }),
  );
  assert.deepEqual(store.items, []);
  assert.equal(store.error, "rls denied");
  assert.equal(store.loading, false);
  assert.equal(warnings.length, 1);
  assert.match(warnings[0][0], /ticket rows/);
  assert.equal(warnings[0][1], "rls denied");
});

test("loadUserRows: uses the table name as log label when logLabel is omitted", async () => {
  resetSuite();
  fakeAlpineStore.session = { user: { id: "u-1" } };
  fakeDb._nextResult = { data: null, error: { message: "boom" } };
  const store = { items: [], loading: false, error: null };
  const warnings = await captureWarnings(() =>
    loadUserRows(store, { table: "tickets", field: "items" }),
  );
  assert.equal(warnings.length, 1);
  assert.match(warnings[0][0], /tickets/);
});

test("loadUserRows: coerces a null data response to an empty array", async () => {
  resetSuite();
  fakeAlpineStore.session = { user: { id: "u-1" } };
  fakeDb._nextResult = { data: null, error: null };
  const store = {
    items: [{ id: "stale" }],
    loading: false,
    error: null,
  };
  await loadUserRows(store, { table: "tickets", field: "items" });
  assert.deepEqual(store.items, []);
  assert.equal(store.error, null);
});
