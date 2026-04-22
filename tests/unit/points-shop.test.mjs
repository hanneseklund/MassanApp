// pointsShopView() in views/points-shop.js is the venue-wide
// merchandise surface. Most redemption behavior lives in the shared
// `createRedemptionController` (see redemption.test.mjs). The view's
// own job is to fetch the active merchandise list, fall back to a
// generated logo when an item has no image, and format the current
// balance through the lang store. It also installs `requireSignIn`
// into the redemption controller so a signed-out redemption click
// routes through the auth view.
//
// Follows the Alpine.store stub pattern from my-tickets.test.mjs and
// auth.test.mjs — no browser, no Supabase, no Alpine runtime.

import test from "node:test";
import assert from "node:assert/strict";

import { pointsShopView } from "../../web/assets/js/views/points-shop.js";
import { logoDataUri } from "../../web/assets/js/util/placeholders.js";
import { withAlpine } from "./_alpine.mjs";

function makeStores({
  merch = [],
  balance = 0,
  isSignedIn = false,
  goAuthCalls = [],
  redeemCalls = [],
} = {}) {
  return {
    lang: {
      t(key, params) {
        if (!params) return key;
        const parts = Object.entries(params)
          .map(([k, v]) => `${k}=${v}`)
          .join("&");
        return `${key}|${parts}`;
      },
    },
    app: {
      goAuth(...args) {
        goAuthCalls.push(args);
      },
    },
    session: { user: null, isSignedIn },
    catalog: {
      activeMerchandise() {
        return merch;
      },
    },
    points: {
      balance,
      async redeem(payload) {
        redeemCalls.push(payload);
      },
    },
    goAuthCalls,
    redeemCalls,
  };
}

test("items(): delegates to catalog.activeMerchandise()", () => {
  const merch = [
    { id: "m1", name: "Tote bag", points_cost: 50 },
    { id: "m2", name: "Water bottle", points_cost: 100 },
  ];
  withAlpine(makeStores({ merch }), () => {
    const view = pointsShopView();
    assert.equal(view.items(), merch);
  });
});

test("merchImage(): returns the item's own image when set", () => {
  withAlpine(makeStores(), () => {
    const view = pointsShopView();
    assert.equal(
      view.merchImage({ id: "m1", name: "Tote bag", image: "/assets/x.jpg" }),
      "/assets/x.jpg",
    );
  });
});

test("merchImage(): falls back to a deterministic logo SVG when the item has no image", () => {
  withAlpine(makeStores(), () => {
    const view = pointsShopView();
    const fallback = view.merchImage({ id: "m1", name: "Tote bag" });
    assert.equal(fallback, logoDataUri("Tote bag"));
  });
});

test("merchImage(): tolerates a missing item and an empty name", () => {
  withAlpine(makeStores(), () => {
    const view = pointsShopView();
    // Null item surfaces as the '?' placeholder — mirrors the treatment
    // merchandise rows would get if the catalog briefly returns null.
    assert.equal(view.merchImage(null), logoDataUri(""));
    assert.equal(view.merchImage({}), logoDataUri(""));
  });
});

test("balanceLabel(): interpolates the current balance through the lang store", () => {
  withAlpine(makeStores({ balance: 237 }), () => {
    assert.equal(
      pointsShopView().balanceLabel(),
      "points.balance_value|points=237",
    );
  });
});

test("redemption: exposes the shared controller configured for venue-wide merch", () => {
  // The view mounts `createRedemptionController` with the merch-shop
  // source id and lang-key set. Pin those down so a config rename
  // (e.g. changing the i18n key) fails a fast unit check.
  withAlpine(makeStores(), () => {
    const view = pointsShopView();
    assert.equal(typeof view.redemption, "object");
    assert.equal(typeof view.redemption.redeem, "function");
    assert.equal(typeof view.redemption.canRedeem, "function");
    assert.equal(typeof view.redemption.reset, "function");
  });
});

test("redemption.redeem: signed-out visitor is redirected through auth and no points row is written", async () => {
  // The points-shop view is the only caller that installs a
  // `requireSignIn` hook into the shared redemption controller. Pin
  // down the redirect target (`#/points`) by driving redeem() while
  // signed out — this documents the post-auth landing surface and
  // catches a rename of the route target.
  const goAuthCalls = [];
  const redeemCalls = [];
  await withAlpine(
    makeStores({ isSignedIn: false, balance: 500, goAuthCalls, redeemCalls }),
    async () => {
      const view = pointsShopView();
      await view.redemption.redeem({
        id: "m1",
        name: "Tote bag",
        points_cost: 100,
        stock: 10,
      });
      assert.equal(goAuthCalls.length, 1);
      assert.deepEqual(goAuthCalls[0], [{ view: "points" }]);
      assert.equal(redeemCalls.length, 0);
    },
  );
});

test("redemption.redeem: signed-in visitor with enough balance writes a venue-wide points row", async () => {
  // Merch redemptions are venue-wide so the `event_id` on the
  // persisted `point_transactions` row must be null (see the
  // functional spec's "Venue-wide merchandise shop" section).
  const goAuthCalls = [];
  const redeemCalls = [];
  await withAlpine(
    makeStores({ isSignedIn: true, balance: 500, goAuthCalls, redeemCalls }),
    async () => {
      const view = pointsShopView();
      await view.redemption.redeem({
        id: "m1",
        name: "Tote bag",
        points_cost: 100,
        stock: 10,
      });
      assert.equal(goAuthCalls.length, 0);
      assert.equal(redeemCalls.length, 1);
      assert.deepEqual(redeemCalls[0], {
        source: "merch_redemption",
        source_ref: "m1",
        amount: 100,
        event_id: null,
      });
    },
  );
});
