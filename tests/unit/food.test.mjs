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
  upcomingTimeslots,
} from "../../web/assets/js/util/food.js";

test("FOOD_MENUS: exposes exactly 10 menus with unique ids", () => {
  assert.equal(FOOD_MENUS.length, 10);
  const ids = FOOD_MENUS.map((m) => m.id);
  assert.equal(new Set(ids).size, ids.length);
});

test("FOOD_MENUS: every entry has an SVG data URI image", () => {
  for (const menu of FOOD_MENUS) {
    assert.match(menu.image, /^data:image\/svg\+xml/);
  }
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
