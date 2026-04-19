// Food ordering catalog: menus, pickup locations, and restaurant
// timeslots. The prototype ships with a fixed catalog (10 fast-food
// menus at the single venue) so the frontend can render ordering flows
// without extra DB tables. Persisted orders live in public.food_orders
// (see supabase/migrations/0004_food_orders.sql) and reference this
// catalog by id.
//
// User-visible copy is resolved against the active language at access
// time via getters. Persisted fields (menu_label, delivery_label) use
// the canonical English copy so saved orders stay stable across
// language switches — same pattern as ticket_type_label in sections.js.

import { activeTranslate, translate, DEFAULT_LANGUAGE } from "../i18n.js";

const t = activeTranslate;

function tCanonical(key) {
  return translate(key, DEFAULT_LANGUAGE);
}

// Ten typical fast-food menus. Each entry carries a stable id, the
// translation keys for the user-facing name + description, a price in
// SEK, and an emoji used by the view to generate an inline SVG image
// (keeps the prototype buildless; no binary assets required).
const MENU_ENTRIES = [
  { id: "burger_classic", name_key: "food.menus.burger_classic.name", desc_key: "food.menus.burger_classic.desc", price: "SEK 129", emoji: "🍔", bg: "#c14a1a" },
  { id: "cheeseburger_double", name_key: "food.menus.cheeseburger_double.name", desc_key: "food.menus.cheeseburger_double.desc", price: "SEK 159", emoji: "🍔", bg: "#8a1f57" },
  { id: "pizza_margherita", name_key: "food.menus.pizza_margherita.name", desc_key: "food.menus.pizza_margherita.desc", price: "SEK 139", emoji: "🍕", bg: "#b35b1c" },
  { id: "hotdog_classic", name_key: "food.menus.hotdog_classic.name", desc_key: "food.menus.hotdog_classic.desc", price: "SEK 79", emoji: "🌭", bg: "#c41e3a" },
  { id: "chicken_nuggets", name_key: "food.menus.chicken_nuggets.name", desc_key: "food.menus.chicken_nuggets.desc", price: "SEK 99", emoji: "🍗", bg: "#b38018" },
  { id: "fries_large", name_key: "food.menus.fries_large.name", desc_key: "food.menus.fries_large.desc", price: "SEK 49", emoji: "🍟", bg: "#c49a14" },
  { id: "caesar_salad", name_key: "food.menus.caesar_salad.name", desc_key: "food.menus.caesar_salad.desc", price: "SEK 119", emoji: "🥗", bg: "#3b7a2a" },
  { id: "wrap_chicken", name_key: "food.menus.wrap_chicken.name", desc_key: "food.menus.wrap_chicken.desc", price: "SEK 109", emoji: "🥙", bg: "#6b5226" },
  { id: "sushi_box", name_key: "food.menus.sushi_box.name", desc_key: "food.menus.sushi_box.desc", price: "SEK 149", emoji: "🍣", bg: "#005a6b" },
  { id: "ice_cream", name_key: "food.menus.ice_cream.name", desc_key: "food.menus.ice_cream.desc", price: "SEK 39", emoji: "🍦", bg: "#8b5cb6" },
];

function menuImageDataUri(emoji, bg) {
  const svg =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 140">` +
    `<rect width="200" height="140" fill="${bg}"/>` +
    `<text x="50%" y="54%" font-size="80" text-anchor="middle" dominant-baseline="middle">${emoji}</text>` +
    `</svg>`;
  return "data:image/svg+xml;utf8," + encodeURIComponent(svg);
}

// Each menu's label / description are getters so switching language
// re-renders bound templates (same pattern as SECTION_LABELS).
export const FOOD_MENUS = MENU_ENTRIES.map((entry) => ({
  id: entry.id,
  price: entry.price,
  image: menuImageDataUri(entry.emoji, entry.bg),
  get label() {
    return t(entry.name_key);
  },
  get description() {
    return t(entry.desc_key);
  },
}));

export function menuById(id) {
  return FOOD_MENUS.find((m) => m.id === id) ?? null;
}

// Canonical English label for a menu id. Used when persisting a food
// order so the wallet entry does not flip language later.
export function canonicalMenuLabel(id) {
  const entry = MENU_ENTRIES.find((e) => e.id === id);
  return entry ? tCanonical(entry.name_key) : id;
}

// Pickup locations within the venue. Static data — the prototype has a
// single venue (Stockholmsmassan) so locations are shared across all
// events.
const PICKUP_ENTRIES = [
  { id: "entrance_north", name_key: "food.pickup.entrance_north.name", desc_key: "food.pickup.entrance_north.desc" },
  { id: "hall_b_lobby", name_key: "food.pickup.hall_b_lobby.name", desc_key: "food.pickup.hall_b_lobby.desc" },
  { id: "central_plaza", name_key: "food.pickup.central_plaza.name", desc_key: "food.pickup.central_plaza.desc" },
];

export const PICKUP_LOCATIONS = PICKUP_ENTRIES.map((entry) => ({
  id: entry.id,
  get label() {
    return t(entry.name_key);
  },
  get description() {
    return t(entry.desc_key);
  },
}));

export function pickupById(id) {
  return PICKUP_LOCATIONS.find((p) => p.id === id) ?? null;
}

export function canonicalPickupLabel(id) {
  const entry = PICKUP_ENTRIES.find((e) => e.id === id);
  return entry ? tCanonical(entry.name_key) : id;
}

// Restaurants that serve a 30-minute timeslot. The slot list is
// generated once per session from the current clock so demo users
// always see a handful of slots in the near future.
const RESTAURANT_ENTRIES = [
  { id: "smakverket", name_key: "food.restaurants.smakverket.name", desc_key: "food.restaurants.smakverket.desc" },
  { id: "torget_bistro", name_key: "food.restaurants.torget_bistro.name", desc_key: "food.restaurants.torget_bistro.desc" },
];

export const RESTAURANTS = RESTAURANT_ENTRIES.map((entry) => ({
  id: entry.id,
  get label() {
    return t(entry.name_key);
  },
  get description() {
    return t(entry.desc_key);
  },
}));

export function restaurantById(id) {
  return RESTAURANTS.find((r) => r.id === id) ?? null;
}

export function canonicalRestaurantLabel(id) {
  const entry = RESTAURANT_ENTRIES.find((e) => e.id === id);
  return entry ? tCanonical(entry.name_key) : id;
}

// Build a list of five upcoming 30-minute timeslots starting on the
// next half hour. Pure function so it stays easy to unit test; callers
// can pass a base `Date` to control the clock.
export function upcomingTimeslots(base = new Date(), count = 5) {
  const start = new Date(base.getTime());
  const minutes = start.getMinutes();
  const bump = minutes < 30 ? 30 - minutes : 60 - minutes;
  start.setMinutes(minutes + bump, 0, 0);
  const slots = [];
  for (let i = 0; i < count; i++) {
    const from = new Date(start.getTime() + i * 30 * 60 * 1000);
    const to = new Date(from.getTime() + 30 * 60 * 1000);
    slots.push({
      id: from.toISOString(),
      from: from.toISOString(),
      to: to.toISOString(),
      label: `${formatClock(from)}–${formatClock(to)}`,
    });
  }
  return slots;
}

function formatClock(date) {
  const h = String(date.getHours()).padStart(2, "0");
  const m = String(date.getMinutes()).padStart(2, "0");
  return `${h}:${m}`;
}
