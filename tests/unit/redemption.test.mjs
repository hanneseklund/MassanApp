// createRedemptionController in util/redemption.js is shared by the
// event add-ons section and the venue-wide merchandise shop. The pure
// selectors (remainingStock, canRedeem, disabledReason) and the
// per-session stock tracking are exercised here without Alpine or
// Supabase by stubbing the two stores the controller reads
// (`points` for balance and `lang` for translations). The async
// `redeem()` path needs an Alpine.store("points").redeem() writer
// stub as well.

import test from "node:test";
import assert from "node:assert/strict";

import { createRedemptionController } from "../../web/assets/js/util/redemption.js";

function installAlpineStubs({
  balance = 0,
  signedIn = true,
  redeemResult = { ok: true },
  redeemError = null,
} = {}) {
  const lang = {
    current: "en",
    t: (key, params) => {
      if (!params) return key;
      const parts = Object.entries(params).map(([k, v]) => `${k}=${v}`);
      return `${key}[${parts.join(",")}]`;
    },
    pick(value) {
      if (value == null) return "";
      if (typeof value === "string") return value;
      return value.en ?? "";
    },
  };
  const points = {
    balance,
    async redeem(payload) {
      points.lastPayload = payload;
      if (redeemError) throw new Error(redeemError);
      return redeemResult;
    },
    lastPayload: null,
  };
  const session = { isSignedIn: signedIn };
  globalThis.Alpine = {
    store(id) {
      if (id === "points") return points;
      if (id === "lang") return lang;
      if (id === "session") return session;
      throw new Error(`Unknown store id ${id} in test stub`);
    },
  };
  return { lang, points, session };
}

function makeController(overrides = {}) {
  return createRedemptionController({
    source: "addon_redemption",
    eventIdFor: (item) => item.event_id ?? null,
    insufficientKey: "event.addons_insufficient_balance",
    soldOutKey: "event.addons_sold_out",
    genericErrorKey: "event.addons_err_generic",
    ...overrides,
  });
}

test("remainingStock: null when the item has no stock cap", () => {
  installAlpineStubs();
  const ctl = makeController();
  assert.equal(ctl.remainingStock({ id: "a", stock: null }), null);
  assert.equal(ctl.remainingStock({ id: "a" }), null);
});

test("remainingStock: subtracts this session's redemptions", () => {
  installAlpineStubs();
  const ctl = makeController();
  ctl.stockConsumed = { a: 2 };
  assert.equal(ctl.remainingStock({ id: "a", stock: 5 }), 3);
});

test("remainingStock: clamped at zero when we have overshot", () => {
  installAlpineStubs();
  const ctl = makeController();
  ctl.stockConsumed = { a: 10 };
  assert.equal(ctl.remainingStock({ id: "a", stock: 5 }), 0);
});

test("canRedeem: true when balance covers cost and stock is open", () => {
  installAlpineStubs({ balance: 200 });
  const ctl = makeController();
  assert.equal(
    ctl.canRedeem({ id: "a", points_cost: 100, stock: 3 }),
    true,
  );
});

test("canRedeem: false while a redemption is already pending", () => {
  installAlpineStubs({ balance: 200 });
  const ctl = makeController();
  ctl.pending = { a: true };
  assert.equal(
    ctl.canRedeem({ id: "a", points_cost: 100, stock: 3 }),
    false,
  );
});

test("canRedeem: false when the balance is below the cost", () => {
  installAlpineStubs({ balance: 50 });
  const ctl = makeController();
  assert.equal(
    ctl.canRedeem({ id: "a", points_cost: 100 }),
    false,
  );
});

test("canRedeem: false when no stock remains", () => {
  installAlpineStubs({ balance: 200 });
  const ctl = makeController();
  ctl.stockConsumed = { a: 5 };
  assert.equal(
    ctl.canRedeem({ id: "a", points_cost: 100, stock: 5 }),
    false,
  );
});

test("disabledReason: insufficient balance translation carries cost param", () => {
  installAlpineStubs({ balance: 10 });
  const ctl = makeController();
  const reason = ctl.disabledReason({ id: "a", points_cost: 100 });
  assert.equal(reason, "event.addons_insufficient_balance[cost=100]");
});

test("disabledReason: sold-out translation when stock is exhausted", () => {
  installAlpineStubs({ balance: 200 });
  const ctl = makeController();
  ctl.stockConsumed = { a: 5 };
  const reason = ctl.disabledReason({ id: "a", points_cost: 100, stock: 5 });
  assert.equal(reason, "event.addons_sold_out");
});

test("disabledReason: empty when the item is redeemable", () => {
  installAlpineStubs({ balance: 200 });
  const ctl = makeController();
  assert.equal(
    ctl.disabledReason({ id: "a", points_cost: 100, stock: 5 }),
    "",
  );
});

test("redeem: bumps pending, writes a transaction, and records lastRedemption", async () => {
  const { points } = installAlpineStubs({ balance: 200 });
  const ctl = makeController();
  await ctl.redeem({
    id: "a",
    name: "Gift bag",
    points_cost: 100,
    event_id: "nordbygg-2026",
  });
  assert.deepEqual(points.lastPayload, {
    source: "addon_redemption",
    source_ref: "a",
    amount: 100,
    event_id: "nordbygg-2026",
  });
  assert.equal(ctl.stockConsumed.a, 1);
  assert.equal(ctl.lastRedemption.id, "a");
  assert.equal(ctl.lastRedemption.name, "Gift bag");
  assert.equal(ctl.lastRedemption.cost, 100);
  assert.equal(ctl.pending.a, false);
  assert.equal(ctl.error, "");
});

test("redeem: no-op when the item is not redeemable (e.g. balance below cost)", async () => {
  const { points } = installAlpineStubs({ balance: 50 });
  const ctl = makeController();
  await ctl.redeem({ id: "a", name: "Gift bag", points_cost: 100 });
  assert.equal(points.lastPayload, null);
  assert.equal(ctl.lastRedemption, null);
});

test("redeem: records the error when the transaction insert fails", async () => {
  installAlpineStubs({ balance: 200, redeemError: "RLS: denied" });
  const ctl = makeController();
  await ctl.redeem({ id: "a", name: "Gift bag", points_cost: 100 });
  assert.equal(ctl.error, "RLS: denied");
  assert.equal(ctl.lastRedemption, null);
  assert.equal(ctl.pending.a, false);
});

test("redeem: shop variant skips through requireSignIn hook when signed out", async () => {
  const { points } = installAlpineStubs({ balance: 200, signedIn: false });
  let requireSignInCalled = false;
  const ctl = makeController({
    source: "merch_redemption",
    eventIdFor: () => null,
    insufficientKey: "shop.insufficient_balance",
    soldOutKey: "shop.sold_out",
    genericErrorKey: "shop.err_generic",
    requireSignIn: () => {
      requireSignInCalled = true;
    },
  });
  await ctl.redeem({ id: "m1", name: "Tote bag", points_cost: 100 });
  assert.equal(requireSignInCalled, true);
  assert.equal(points.lastPayload, null);
  assert.equal(ctl.lastRedemption, null);
});

test("redeem: uses eventIdFor to route per-item event_id into the transaction", async () => {
  const { points } = installAlpineStubs({ balance: 500 });
  const ctl = makeController();
  await ctl.redeem({
    id: "a",
    name: "Event gift",
    points_cost: 100,
    event_id: "estro-2026",
  });
  assert.equal(points.lastPayload.event_id, "estro-2026");
});

test("reset: clears stockConsumed, pending, lastRedemption, and error", () => {
  installAlpineStubs();
  const ctl = makeController();
  ctl.stockConsumed = { a: 1 };
  ctl.pending = { a: true };
  ctl.lastRedemption = { id: "a", name: "x", cost: 100 };
  ctl.error = "boom";
  ctl.reset();
  assert.deepEqual(ctl.stockConsumed, {});
  assert.deepEqual(ctl.pending, {});
  assert.equal(ctl.lastRedemption, null);
  assert.equal(ctl.error, "");
});

test("dismissLastRedemption: clears only the banner, not the stock or error", () => {
  installAlpineStubs();
  const ctl = makeController();
  ctl.stockConsumed = { a: 1 };
  ctl.lastRedemption = { id: "a", name: "x", cost: 100 };
  ctl.error = "boom";
  ctl.dismissLastRedemption();
  assert.equal(ctl.lastRedemption, null);
  assert.deepEqual(ctl.stockConsumed, { a: 1 });
  assert.equal(ctl.error, "boom");
});
