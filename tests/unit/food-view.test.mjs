// foodView() in views/food.js drives the two-interaction simulated
// food-ordering flow (step 1 = pick menu, step 2 = pick delivery +
// confirm, step 3 = confirmation). The `confirm()` path chains
// `simulatedPayment`, a `foodOrders.add` insert, and a
// `points.tryEarn` call — the happy-path branches touch those and are
// left for the smoke suite; the form validation, step navigation,
// delivery-mode switch, and signed-out auth guard are pure state
// transitions that are worth pinning down without a browser.
//
// Follows the Alpine.store stub pattern from purchase.test.mjs and
// my-tickets.test.mjs — no browser, no Supabase, no Alpine runtime.

import test from "node:test";
import assert from "node:assert/strict";

import { foodView } from "../../web/assets/js/views/food.js";
import {
  FOOD_MENUS,
  PICKUP_LOCATIONS,
  RESTAURANTS,
  menuById,
} from "../../web/assets/js/util/food.js";
import { withAlpine } from "./_alpine.mjs";

// Returns `key` verbatim so tests assert which i18n key the view
// picked without depending on the English copy in i18n.js.
function langStub() {
  return {
    t(key) {
      return key;
    },
  };
}

function makeEvent(overrides = {}) {
  return {
    id: "nordbygg-2026",
    name: "Nordbygg 2026",
    category: "Construction and real estate",
    ...overrides,
  };
}

function makeStores({
  view = "event",
  eventSubview = "food",
  eventId = "nordbygg-2026",
  user = null,
  event = makeEvent(),
  goAuthCalls = [],
  foodOrdersAdd = async (draft) => ({ ...draft }),
  pointsTryEarnCalls = [],
} = {}) {
  return {
    lang: langStub(),
    app: {
      view,
      eventSubview,
      eventId,
      goAuth(...args) {
        goAuthCalls.push(args);
      },
    },
    session: {
      get isSignedIn() {
        return !!user;
      },
      user,
    },
    catalog: {
      eventById(id) {
        return id === event?.id ? event : null;
      },
    },
    foodOrders: {
      add: foodOrdersAdd,
    },
    points: {
      async tryEarn(args) {
        pointsTryEarnCalls.push(args);
      },
    },
    goAuthCalls,
    pointsTryEarnCalls,
  };
}

test("initial state: step 1, nothing selected, default delivery mode is pickup", () => {
  const view = foodView();
  assert.equal(view.step, 1);
  assert.equal(view.menuId, null);
  assert.equal(view.deliveryMode, "pickup");
  assert.equal(view.pickupId, null);
  assert.equal(view.restaurantId, null);
  assert.equal(view.timeslotId, null);
  assert.equal(view.processing, false);
  assert.equal(view.error, "");
  assert.equal(view.confirmedOrder, null);
  // The view freezes the catalog onto the component so templates can
  // bind without reaching through the util module again.
  assert.equal(view.menus.length, FOOD_MENUS.length);
  assert.equal(view.pickupLocations.length, PICKUP_LOCATIONS.length);
  assert.equal(view.restaurants.length, RESTAURANTS.length);
});

test("_hydrate: resets every form field and populates timeslots", () => {
  const view = foodView();
  view.step = 3;
  view.menuId = "burger_classic";
  view.deliveryMode = "timeslot";
  view.pickupId = "entrance_north";
  view.restaurantId = "smakverket";
  view.timeslotId = "some-slot";
  view.timeslots = [];
  view.processing = true;
  view.error = "boom";
  view.confirmedOrder = { id: "o1" };

  view._hydrate();

  assert.equal(view.step, 1);
  assert.equal(view.menuId, null);
  assert.equal(view.deliveryMode, "pickup");
  assert.equal(view.pickupId, null);
  assert.equal(view.restaurantId, null);
  assert.equal(view.timeslotId, null);
  assert.equal(view.processing, false);
  assert.equal(view.error, "");
  assert.equal(view.confirmedOrder, null);
  // `upcomingTimeslots()` returns five slots anchored on the next half
  // hour; the exact labels depend on the wall clock, so assert shape.
  assert.equal(view.timeslots.length, 5);
  for (const slot of view.timeslots) {
    assert.equal(typeof slot.id, "string");
    assert.equal(typeof slot.from, "string");
    assert.equal(typeof slot.to, "string");
    assert.equal(typeof slot.label, "string");
  }
});

test("event(): resolves the selected event through the catalog", async () => {
  const stores = makeStores();
  await withAlpine(stores, async () => {
    const view = foodView();
    assert.equal(view.event()?.id, "nordbygg-2026");
  });
});

test("event(): null when no event is selected", async () => {
  const stores = makeStores({ eventId: null });
  await withAlpine(stores, async () => {
    assert.equal(foodView().event(), null);
  });
});

test("themedMenu(): returns a themed section keyed off the event category", async () => {
  const stores = makeStores(); // Construction category -> construction theme
  await withAlpine(stores, async () => {
    const themed = foodView().themedMenu();
    assert.equal(themed?.id, "construction");
    assert.ok(Array.isArray(themed?.items));
    assert.ok(themed.items.length >= 1);
  });
});

test("themedMenu(): returns the default theme when the event category has no specific mapping", async () => {
  const stores = makeStores({ event: makeEvent({ category: "Other" }) });
  await withAlpine(stores, async () => {
    assert.equal(foodView().themedMenu()?.id, "default");
  });
});

test("themedMenu(): null when there is no selected event", async () => {
  const stores = makeStores({ eventId: null });
  await withAlpine(stores, async () => {
    assert.equal(foodView().themedMenu(), null);
  });
});

test("selectedMenu / selectedPickup / selectedRestaurant: look up ids against the static catalog", async () => {
  const stores = makeStores();
  await withAlpine(stores, async () => {
    const view = foodView();
    assert.equal(view.selectedMenu(), null);
    assert.equal(view.selectedPickup(), null);
    assert.equal(view.selectedRestaurant(), null);

    view.menuId = "burger_classic";
    view.pickupId = "entrance_north";
    view.restaurantId = "smakverket";
    assert.equal(view.selectedMenu()?.id, "burger_classic");
    assert.equal(view.selectedPickup()?.id, "entrance_north");
    assert.equal(view.selectedRestaurant()?.id, "smakverket");

    view.menuId = "not-a-real-menu";
    assert.equal(view.selectedMenu(), null);
  });
});

test("selectedTimeslot: returns the matching slot from the local list or null", () => {
  const view = foodView();
  view.timeslots = [
    { id: "a", from: "x", to: "y", label: "A" },
    { id: "b", from: "x", to: "y", label: "B" },
  ];
  assert.equal(view.selectedTimeslot(), null);
  view.timeslotId = "b";
  assert.equal(view.selectedTimeslot()?.id, "b");
  view.timeslotId = "missing";
  assert.equal(view.selectedTimeslot(), null);
});

test("confirmedExtras: resolves the bundled sides/drinks from the confirmed menu id", () => {
  const view = foodView();
  assert.deepEqual(view.confirmedExtras(), []);
  view.confirmedOrder = { menu_id: "burger_classic" };
  const expected = menuById("burger_classic").extras;
  assert.deepEqual(view.confirmedExtras(), expected);
  view.confirmedOrder = { menu_id: "not-a-real-menu" };
  assert.deepEqual(view.confirmedExtras(), []);
});

test("setDeliveryMode: updates the mode and clears any leftover error", () => {
  const view = foodView();
  view.error = "boom";
  view.setDeliveryMode("timeslot");
  assert.equal(view.deliveryMode, "timeslot");
  assert.equal(view.error, "");
});

test("goToStep: sets the step and clears the error", () => {
  const view = foodView();
  view.step = 1;
  view.error = "boom";
  view.goToStep(2);
  assert.equal(view.step, 2);
  assert.equal(view.error, "");
});

test("continueToDelivery: blocked without a menu, surfaces the lang key and stays on step 1", async () => {
  const stores = makeStores();
  await withAlpine(stores, async () => {
    const view = foodView();
    view.continueToDelivery();
    assert.equal(view.step, 1);
    assert.equal(view.error, "food.err_pick_menu");
  });
});

test("continueToDelivery: advances to step 2 when a menu is selected", async () => {
  const stores = makeStores();
  await withAlpine(stores, async () => {
    const view = foodView();
    view.menuId = "burger_classic";
    view.continueToDelivery();
    assert.equal(view.step, 2);
    assert.equal(view.error, "");
  });
});

test("confirm(): resets to step 1 and surfaces err_pick_menu_first when no menu is selected", async () => {
  const stores = makeStores({ user: { id: "u-1" } });
  await withAlpine(stores, async () => {
    const view = foodView();
    view.step = 2;
    await view.confirm();
    assert.equal(view.step, 1);
    assert.equal(view.error, "food.err_pick_menu_first");
    assert.equal(view.processing, false);
  });
});

test("confirm(): resets to step 1 and surfaces err_pick_menu_first when no event is selected", async () => {
  const stores = makeStores({ eventId: null });
  await withAlpine(stores, async () => {
    const view = foodView();
    view.menuId = "burger_classic";
    view.step = 2;
    await view.confirm();
    assert.equal(view.step, 1);
    assert.equal(view.error, "food.err_pick_menu_first");
  });
});

test("confirm(): signed-out visitor is redirected through auth with a return target that resumes the food flow", async () => {
  const goAuthCalls = [];
  const stores = makeStores({ user: null, goAuthCalls });
  await withAlpine(stores, async () => {
    const view = foodView();
    view.menuId = "burger_classic";
    view.step = 2;
    await view.confirm();
    assert.equal(goAuthCalls.length, 1);
    assert.deepEqual(goAuthCalls[0], [
      { view: "event", eventId: "nordbygg-2026", eventSubview: "food" },
    ]);
    // The view must not set an error or flip processing when the
    // auth-gate routes away — the auth view takes over.
    assert.equal(view.error, "");
    assert.equal(view.processing, false);
  });
});

test("confirm(): pickup mode without a pickup id surfaces err_pick_pickup and stays on step 2", async () => {
  const stores = makeStores({ user: { id: "u-1" } });
  await withAlpine(stores, async () => {
    const view = foodView();
    view.menuId = "burger_classic";
    view.deliveryMode = "pickup";
    view.step = 2;
    await view.confirm();
    assert.equal(view.error, "food.err_pick_pickup");
    assert.equal(view.step, 2);
    assert.equal(view.processing, false);
  });
});

test("confirm(): timeslot mode without a restaurant or slot surfaces err_pick_slot", async () => {
  const stores = makeStores({ user: { id: "u-1" } });
  await withAlpine(stores, async () => {
    const view = foodView();
    view.menuId = "burger_classic";
    view.deliveryMode = "timeslot";
    view.step = 2;
    await view.confirm();
    assert.equal(view.error, "food.err_pick_slot");
    assert.equal(view.step, 2);
    assert.equal(view.processing, false);
  });
});

test("confirm(): timeslot mode with a restaurant but no slot still surfaces err_pick_slot", async () => {
  const stores = makeStores({ user: { id: "u-1" } });
  await withAlpine(stores, async () => {
    const view = foodView();
    view.menuId = "burger_classic";
    view.deliveryMode = "timeslot";
    view.restaurantId = "smakverket";
    view.timeslots = [{ id: "a", from: "x", to: "y", label: "A" }];
    view.timeslotId = null;
    await view.confirm();
    assert.equal(view.error, "food.err_pick_slot");
  });
});

test("confirm(): unknown delivery mode surfaces err_pick_delivery", async () => {
  const stores = makeStores({ user: { id: "u-1" } });
  await withAlpine(stores, async () => {
    const view = foodView();
    view.menuId = "burger_classic";
    view.deliveryMode = "something-else";
    view.step = 2;
    await view.confirm();
    assert.equal(view.error, "food.err_pick_delivery");
    assert.equal(view.processing, false);
  });
});
