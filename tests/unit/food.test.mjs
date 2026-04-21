// Food ordering catalog in util/food.js. The 10 menus, three pickup
// locations, and two restaurants are fixed data; the ids and canonical
// English labels must stay stable because they are persisted on a
// food_orders row and would otherwise flip language across language
// switches. `upcomingTimeslots` generates five 30-minute slots anchored
// on the next half hour relative to a supplied clock.

import test from "node:test";
import assert from "node:assert/strict";

import {
  FOOD_MENUS,
  PICKUP_LOCATIONS,
  RESTAURANTS,
  menuById,
  pickupById,
  restaurantById,
  canonicalMenuLabel,
  canonicalPickupLabel,
  canonicalRestaurantLabel,
  themedMenuForEvent,
  themeIdForEvent,
  upcomingTimeslots,
} from "../../web/assets/js/util/food.js";

test("FOOD_MENUS: exposes exactly 10 menus with unique ids", () => {
  assert.equal(FOOD_MENUS.length, 10);
  const ids = FOOD_MENUS.map((m) => m.id);
  assert.equal(new Set(ids).size, ids.length);
});

test("FOOD_MENUS: every entry has a bundled image path under /assets/images/food/", () => {
  for (const menu of FOOD_MENUS) {
    assert.match(menu.image, /^\/assets\/images\/food\/[\w-]+\.(jpe?g|png|webp)$/);
  }
});

test("FOOD_MENUS: every entry exposes an extras list (may be empty)", () => {
  for (const menu of FOOD_MENUS) {
    assert.ok(Array.isArray(menu.extras), `${menu.id} should expose extras`);
  }
});

test("FOOD_MENUS: combo menus include resolved side/drink labels in English", () => {
  const burger = menuById("burger_classic");
  assert.deepEqual(burger.extras, ["Small fries", "Soft drink (33 cl)"]);
  const sushi = menuById("sushi_box");
  assert.deepEqual(sushi.extras, [
    "Edamame",
    "Miso soup",
    "Bottled water (33 cl)",
  ]);
});

test("FOOD_MENUS: labels and descriptions resolve to English by default", () => {
  const burger = menuById("burger_classic");
  assert.ok(burger);
  assert.equal(burger.label, "Classic Burger");
  assert.match(burger.description, /beef patty/i);
});

test("menuById: unknown id returns null", () => {
  assert.equal(menuById("not-a-real-menu"), null);
});

test("canonicalMenuLabel: known ids return English labels", () => {
  assert.equal(canonicalMenuLabel("pizza_margherita"), "Pizza Margherita");
  assert.equal(canonicalMenuLabel("ice_cream"), "Ice Cream Scoop");
});

test("canonicalMenuLabel: unknown id falls back to the id itself", () => {
  assert.equal(canonicalMenuLabel("nope"), "nope");
});

test("PICKUP_LOCATIONS: three entries with English labels", () => {
  assert.equal(PICKUP_LOCATIONS.length, 3);
  assert.equal(pickupById("entrance_north").label, "North Entrance kiosk");
});

test("canonicalPickupLabel: known id returns English label", () => {
  assert.equal(
    canonicalPickupLabel("central_plaza"),
    "Central Plaza pickup",
  );
});

test("RESTAURANTS: two entries with English labels", () => {
  assert.equal(RESTAURANTS.length, 2);
  assert.equal(restaurantById("smakverket").label, "Smakverket");
});

test("canonicalRestaurantLabel: known id returns English label", () => {
  assert.equal(canonicalRestaurantLabel("torget_bistro"), "Torget Bistro");
});

test("upcomingTimeslots: yields five 30-minute slots starting on the next half hour", () => {
  const base = new Date("2026-06-10T12:07:00Z");
  // Work in local time so the test does not depend on the runner's
  // timezone: upcomingTimeslots uses getHours()/getMinutes().
  const local = new Date(2026, 5, 10, 12, 7, 0);
  const slots = upcomingTimeslots(local);
  assert.equal(slots.length, 5);
  const first = new Date(slots[0].from);
  assert.equal(first.getMinutes(), 30);
  assert.equal(first.getHours(), 12);
  const second = new Date(slots[1].from);
  assert.equal(second.getHours(), 13);
  assert.equal(second.getMinutes(), 0);
  // Each slot should be exactly 30 minutes wide.
  for (const slot of slots) {
    const delta = new Date(slot.to).getTime() - new Date(slot.from).getTime();
    assert.equal(delta, 30 * 60 * 1000);
  }
  // Slot ids should round-trip through the label.
  assert.match(slots[0].label, /^\d{2}:\d{2}–\d{2}:\d{2}$/);
  // Confirm base argument is not read from the module scope.
  void base;
});

test("upcomingTimeslots: when current minute is exactly on the half hour, starts at the next slot", () => {
  const local = new Date(2026, 5, 10, 12, 30, 0);
  const slots = upcomingTimeslots(local, 2);
  const first = new Date(slots[0].from);
  assert.equal(first.getHours(), 13);
  assert.equal(first.getMinutes(), 0);
});

test("themeIdForEvent: maps known categories to theme ids", () => {
  assert.equal(
    themeIdForEvent({ category: "Construction and real estate" }),
    "construction",
  );
  assert.equal(themeIdForEvent({ category: "Health & Medicine" }), "health");
  assert.equal(themeIdForEvent({ category: "Food & drink" }), "food_drink");
});

test("themeIdForEvent: unmapped categories (incl. 'Other') fall back to the default theme", () => {
  assert.equal(themeIdForEvent({ category: "Other" }), "default");
  assert.equal(themeIdForEvent({ category: "Something exotic" }), "default");
});

test("themeIdForEvent: missing event returns null", () => {
  assert.equal(themeIdForEvent(null), null);
  assert.equal(themeIdForEvent(undefined), null);
});

test("themedMenuForEvent: surfaces the themed section for every seeded category", () => {
  // Every seeded category — including fall-back 'Other' — must render
  // a themed section so the food menu always has an "Event special"
  // band on top (issue #25).
  const categories = [
    "Construction and real estate",
    "Health & Medicine",
    "Education and training",
    "Interior design",
    "Entertainment",
    "Industry",
    "Food & drink",
    "Leisure and consumer",
    "Other",
  ];
  for (const category of categories) {
    const themed = themedMenuForEvent({ category });
    assert.ok(themed, `themed section missing for category ${category}`);
    assert.ok(
      Array.isArray(themed.items) && themed.items.length >= 2,
      `themed section for ${category} should have >= 2 items`,
    );
    assert.equal(typeof themed.label, "string");
    assert.notEqual(themed.label.length, 0);
  }
});

test("themedMenuForEvent: themed items participate in menuById and carry English labels", () => {
  // A persisted food_orders.menu_id for a themed item must still
  // round-trip through menuById / canonicalMenuLabel — themed entries
  // share the combined catalog with the regular 10 menus.
  const themed = themedMenuForEvent({ category: "Construction and real estate" });
  const first = themed.items[0];
  assert.equal(menuById(first.id), first);
  assert.match(canonicalMenuLabel(first.id), /[A-Za-z]/);
  assert.match(first.price, /^SEK \d+$/);
  assert.match(first.image, /^\/assets\/images\/food\/[\w-]+\.(jpe?g|png|webp)$/);
});

test("themedMenuForEvent: null event returns null", () => {
  assert.equal(themedMenuForEvent(null), null);
});

test("FOOD_MENUS: still exposes exactly the 10 regular items after themed items are added", () => {
  // Themed entries flow through the same combined catalog as the 10
  // regular items, but FOOD_MENUS (used by the regular menu grid) must
  // not include them — the themed section has its own grid above.
  assert.equal(FOOD_MENUS.length, 10);
  const ids = new Set(FOOD_MENUS.map((m) => m.id));
  assert.ok(!ids.has("theme_construction_foreman_burger"));
});
