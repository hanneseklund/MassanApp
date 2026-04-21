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

import { activeTranslate, canonicalTranslate } from "../i18n.js";

const t = activeTranslate;

// Build a translated catalog from a list of entries shaped
// `{ id, name_key, desc_key, extra?, extra_keys? }`. Returns the
// public-facing `list` of items (with `label` / `description` /
// `extras` getters that re-read the active language on access), an
// `byId` lookup, and a `canonicalLabel` that resolves against English
// regardless of the current UI language. `extra_keys` is an array of
// translation keys for bundled sides/drinks shown under the menu name
// — empty/missing means no included items. The three food catalogs
// below share this shape; the ticket-type catalog in util/sections.js
// differs enough (grouped by event.ticket_model) that it is not built
// through this helper.
function buildCatalog(entries) {
  const list = entries.map((entry) => ({
    id: entry.id,
    ...(entry.extra ?? {}),
    get label() {
      return t(entry.name_key);
    },
    get description() {
      return t(entry.desc_key);
    },
    get extras() {
      return (entry.extra_keys ?? []).map((key) => t(key));
    },
  }));
  return {
    list,
    byId(id) {
      return list.find((item) => item.id === id) ?? null;
    },
    canonicalLabel(id) {
      const entry = entries.find((e) => e.id === id);
      return entry ? canonicalTranslate(entry.name_key) : id;
    },
  };
}

// Ten typical fast-food menus. Each entry carries a stable id, the
// translation keys for the user-facing name + description, a price in
// SEK, the path to a bundled photo, and a list of translation keys for
// the bundled sides/drinks that come with the menu (resolved at
// access time via the `extras` getter).
const MENU_ENTRIES = [
  { id: "burger_classic",      name_key: "food.menus.burger_classic.name",      desc_key: "food.menus.burger_classic.desc",      price: "SEK 129", image: "/assets/images/food/burger_classic.jpg",      extra_keys: ["food.extras.small_fries", "food.extras.soft_drink"] },
  { id: "cheeseburger_double", name_key: "food.menus.cheeseburger_double.name", desc_key: "food.menus.cheeseburger_double.desc", price: "SEK 159", image: "/assets/images/food/cheeseburger_double.jpg", extra_keys: ["food.extras.small_fries", "food.extras.soft_drink"] },
  { id: "pizza_margherita",    name_key: "food.menus.pizza_margherita.name",    desc_key: "food.menus.pizza_margherita.desc",    price: "SEK 139", image: "/assets/images/food/pizza_margherita.jpg",    extra_keys: ["food.extras.garlic_bread", "food.extras.soft_drink"] },
  { id: "hotdog_classic",      name_key: "food.menus.hotdog_classic.name",      desc_key: "food.menus.hotdog_classic.desc",      price: "SEK 79",  image: "/assets/images/food/hotdog_classic.png",      extra_keys: ["food.extras.small_fries", "food.extras.soft_drink"] },
  { id: "chicken_nuggets",     name_key: "food.menus.chicken_nuggets.name",     desc_key: "food.menus.chicken_nuggets.desc",     price: "SEK 99",  image: "/assets/images/food/chicken_nuggets.jpg",     extra_keys: ["food.extras.small_fries", "food.extras.dip", "food.extras.soft_drink"] },
  { id: "fries_large",         name_key: "food.menus.fries_large.name",         desc_key: "food.menus.fries_large.desc",         price: "SEK 49",  image: "/assets/images/food/fries_large.jpg",         extra_keys: ["food.extras.dip"] },
  { id: "caesar_salad",        name_key: "food.menus.caesar_salad.name",        desc_key: "food.menus.caesar_salad.desc",        price: "SEK 119", image: "/assets/images/food/caesar_salad.jpg",        extra_keys: ["food.extras.garlic_bread", "food.extras.bottled_water"] },
  { id: "wrap_chicken",        name_key: "food.menus.wrap_chicken.name",        desc_key: "food.menus.wrap_chicken.desc",        price: "SEK 109", image: "/assets/images/food/wrap_chicken.jpg",        extra_keys: ["food.extras.small_fries", "food.extras.soft_drink"] },
  { id: "sushi_box",           name_key: "food.menus.sushi_box.name",           desc_key: "food.menus.sushi_box.desc",           price: "SEK 149", image: "/assets/images/food/sushi_box.jpg",           extra_keys: ["food.extras.edamame", "food.extras.miso_soup", "food.extras.bottled_water"] },
  { id: "ice_cream",           name_key: "food.menus.ice_cream.name",           desc_key: "food.menus.ice_cream.desc",           price: "SEK 39",  image: "/assets/images/food/ice_cream.jpg",           extra_keys: ["food.extras.waffle_cone", "food.extras.toppings"] },
].map(normaliseMenuEntry);

// Per-theme menu definitions. Each theme gets a short section rendered
// at the top of the food menu when the event maps to that theme (see
// `themedMenuForEvent`). Entries share the shape of MENU_ENTRIES so
// themed items participate in the same `menuById` lookup and can be
// selected through the ordering flow like regular items — the only
// surface difference is a themed heading above their grid. All themed
// items reuse existing venue photography; only copy and ids are new.
const THEMED_MENU_DEFS = {
  construction: {
    label_key: "food.themes.construction.label",
    entries: [
      { id: "theme_construction_foreman_burger", name_key: "food.menus.theme_construction_foreman_burger.name", desc_key: "food.menus.theme_construction_foreman_burger.desc", price: "SEK 149", image: "/assets/images/food/burger_classic.jpg", extra_keys: ["food.extras.small_fries", "food.extras.soft_drink"] },
      { id: "theme_construction_scaffold_hotdog", name_key: "food.menus.theme_construction_scaffold_hotdog.name", desc_key: "food.menus.theme_construction_scaffold_hotdog.desc", price: "SEK 89", image: "/assets/images/food/hotdog_classic.png", extra_keys: ["food.extras.small_fries", "food.extras.soft_drink"] },
    ],
  },
  health: {
    label_key: "food.themes.health.label",
    entries: [
      { id: "theme_health_recovery_bowl", name_key: "food.menus.theme_health_recovery_bowl.name", desc_key: "food.menus.theme_health_recovery_bowl.desc", price: "SEK 129", image: "/assets/images/food/caesar_salad.jpg", extra_keys: ["food.extras.bottled_water"] },
      { id: "theme_health_vitality_wrap", name_key: "food.menus.theme_health_vitality_wrap.name", desc_key: "food.menus.theme_health_vitality_wrap.desc", price: "SEK 119", image: "/assets/images/food/wrap_chicken.jpg", extra_keys: ["food.extras.bottled_water"] },
    ],
  },
  education: {
    label_key: "food.themes.education.label",
    entries: [
      { id: "theme_education_study_snack", name_key: "food.menus.theme_education_study_snack.name", desc_key: "food.menus.theme_education_study_snack.desc", price: "SEK 99", image: "/assets/images/food/chicken_nuggets.jpg", extra_keys: ["food.extras.small_fries", "food.extras.dip", "food.extras.soft_drink"] },
      { id: "theme_education_campus_caesar", name_key: "food.menus.theme_education_campus_caesar.name", desc_key: "food.menus.theme_education_campus_caesar.desc", price: "SEK 109", image: "/assets/images/food/caesar_salad.jpg", extra_keys: ["food.extras.bottled_water"] },
    ],
  },
  design: {
    label_key: "food.themes.design.label",
    entries: [
      { id: "theme_design_curated_sushi", name_key: "food.menus.theme_design_curated_sushi.name", desc_key: "food.menus.theme_design_curated_sushi.desc", price: "SEK 159", image: "/assets/images/food/sushi_box.jpg", extra_keys: ["food.extras.edamame", "food.extras.bottled_water"] },
      { id: "theme_design_minimalist_margherita", name_key: "food.menus.theme_design_minimalist_margherita.name", desc_key: "food.menus.theme_design_minimalist_margherita.desc", price: "SEK 139", image: "/assets/images/food/pizza_margherita.jpg", extra_keys: ["food.extras.soft_drink"] },
    ],
  },
  entertainment: {
    label_key: "food.themes.entertainment.label",
    entries: [
      { id: "theme_entertainment_headliner_burger", name_key: "food.menus.theme_entertainment_headliner_burger.name", desc_key: "food.menus.theme_entertainment_headliner_burger.desc", price: "SEK 169", image: "/assets/images/food/cheeseburger_double.jpg", extra_keys: ["food.extras.small_fries", "food.extras.soft_drink"] },
      { id: "theme_entertainment_backstage_nuggets", name_key: "food.menus.theme_entertainment_backstage_nuggets.name", desc_key: "food.menus.theme_entertainment_backstage_nuggets.desc", price: "SEK 99", image: "/assets/images/food/chicken_nuggets.jpg", extra_keys: ["food.extras.small_fries", "food.extras.dip", "food.extras.soft_drink"] },
    ],
  },
  industry: {
    label_key: "food.themes.industry.label",
    entries: [
      { id: "theme_industry_engineers_lunch", name_key: "food.menus.theme_industry_engineers_lunch.name", desc_key: "food.menus.theme_industry_engineers_lunch.desc", price: "SEK 129", image: "/assets/images/food/burger_classic.jpg", extra_keys: ["food.extras.small_fries", "food.extras.soft_drink"] },
      { id: "theme_industry_workshop_fries", name_key: "food.menus.theme_industry_workshop_fries.name", desc_key: "food.menus.theme_industry_workshop_fries.desc", price: "SEK 79", image: "/assets/images/food/fries_large.jpg", extra_keys: ["food.extras.dip", "food.extras.soft_drink"] },
    ],
  },
  food_drink: {
    label_key: "food.themes.food_drink.label",
    entries: [
      { id: "theme_food_drink_chefs_tasting", name_key: "food.menus.theme_food_drink_chefs_tasting.name", desc_key: "food.menus.theme_food_drink_chefs_tasting.desc", price: "SEK 169", image: "/assets/images/food/sushi_box.jpg", extra_keys: ["food.extras.edamame", "food.extras.miso_soup"] },
      { id: "theme_food_drink_sommelier_pairing", name_key: "food.menus.theme_food_drink_sommelier_pairing.name", desc_key: "food.menus.theme_food_drink_sommelier_pairing.desc", price: "SEK 149", image: "/assets/images/food/pizza_margherita.jpg", extra_keys: ["food.extras.garlic_bread", "food.extras.bottled_water"] },
    ],
  },
  leisure: {
    label_key: "food.themes.leisure.label",
    entries: [
      { id: "theme_leisure_weekend_burger", name_key: "food.menus.theme_leisure_weekend_burger.name", desc_key: "food.menus.theme_leisure_weekend_burger.desc", price: "SEK 129", image: "/assets/images/food/burger_classic.jpg", extra_keys: ["food.extras.small_fries", "food.extras.soft_drink"] },
      { id: "theme_leisure_family_wrap", name_key: "food.menus.theme_leisure_family_wrap.name", desc_key: "food.menus.theme_leisure_family_wrap.desc", price: "SEK 119", image: "/assets/images/food/wrap_chicken.jpg", extra_keys: ["food.extras.small_fries", "food.extras.soft_drink"] },
    ],
  },
  default: {
    label_key: "food.themes.default.label",
    entries: [
      { id: "theme_default_visitors_burger", name_key: "food.menus.theme_default_visitors_burger.name", desc_key: "food.menus.theme_default_visitors_burger.desc", price: "SEK 129", image: "/assets/images/food/burger_classic.jpg", extra_keys: ["food.extras.small_fries", "food.extras.soft_drink"] },
      { id: "theme_default_event_day_wrap", name_key: "food.menus.theme_default_event_day_wrap.name", desc_key: "food.menus.theme_default_event_day_wrap.desc", price: "SEK 109", image: "/assets/images/food/wrap_chicken.jpg", extra_keys: ["food.extras.small_fries", "food.extras.soft_drink"] },
    ],
  },
};

// Map an event.category string to a theme id. Unmapped categories
// (notably "Other") resolve to the `default` theme so every event
// always surfaces a themed section.
const CATEGORY_TO_THEME = {
  "Construction and real estate": "construction",
  "Health & Medicine": "health",
  "Education and training": "education",
  "Interior design": "design",
  "Entertainment": "entertainment",
  "Industry": "industry",
  "Food & drink": "food_drink",
  "Leisure and consumer": "leisure",
};

// Flatten themed entries for the shared `menuById` lookup. Regular and
// themed items live in one combined catalog so a persisted `menu_id`
// round-trips through `menuById` / `canonicalMenuLabel` regardless of
// which bucket it came from.
const THEMED_ENTRIES = Object.values(THEMED_MENU_DEFS).flatMap((def) =>
  def.entries.map(normaliseMenuEntry),
);
const menus = buildCatalog([...MENU_ENTRIES, ...THEMED_ENTRIES]);
export const FOOD_MENUS = menus.list.slice(0, MENU_ENTRIES.length);
export const menuById = menus.byId;
export const canonicalMenuLabel = menus.canonicalLabel;

// Themed menus keyed by theme id. Each entry carries a live `label`
// getter (resolved against the active language like regular menu
// labels) and the ordered list of themed items (references into the
// combined catalog so their fields stay in sync).
const THEMED_MENUS = Object.fromEntries(
  Object.entries(THEMED_MENU_DEFS).map(([themeId, def]) => [
    themeId,
    {
      id: themeId,
      get label() {
        return t(def.label_key);
      },
      items: def.entries.map((entry) => menus.byId(entry.id)),
    },
  ]),
);

export function themeIdForEvent(event) {
  if (!event) return null;
  return CATEGORY_TO_THEME[event.category] ?? "default";
}

// Return the themed menu section for an event, or null when the event
// itself is missing. Unmapped categories fall through to the default
// theme so callers can always render a themed section for a valid
// event.
export function themedMenuForEvent(event) {
  const themeId = themeIdForEvent(event);
  if (!themeId) return null;
  return THEMED_MENUS[themeId] ?? null;
}

function normaliseMenuEntry(entry) {
  return {
    id: entry.id,
    name_key: entry.name_key,
    desc_key: entry.desc_key,
    extra_keys: entry.extra_keys,
    extra: {
      price: entry.price,
      image: entry.image,
    },
  };
}

// Pickup locations within the venue. Static data — the prototype has a
// single venue (Stockholmsmassan) so locations are shared across all
// events.
const PICKUP_ENTRIES = [
  { id: "entrance_north", name_key: "food.pickup.entrance_north.name", desc_key: "food.pickup.entrance_north.desc" },
  { id: "hall_b_lobby", name_key: "food.pickup.hall_b_lobby.name", desc_key: "food.pickup.hall_b_lobby.desc" },
  { id: "central_plaza", name_key: "food.pickup.central_plaza.name", desc_key: "food.pickup.central_plaza.desc" },
];

const pickups = buildCatalog(PICKUP_ENTRIES);
export const PICKUP_LOCATIONS = pickups.list;
export const pickupById = pickups.byId;
export const canonicalPickupLabel = pickups.canonicalLabel;

// Restaurants that serve a 30-minute timeslot. The slot list is
// generated once per session from the current clock so demo users
// always see a handful of slots in the near future.
const RESTAURANT_ENTRIES = [
  { id: "smakverket", name_key: "food.restaurants.smakverket.name", desc_key: "food.restaurants.smakverket.desc" },
  { id: "torget_bistro", name_key: "food.restaurants.torget_bistro.name", desc_key: "food.restaurants.torget_bistro.desc" },
];

const restaurants = buildCatalog(RESTAURANT_ENTRIES);
export const RESTAURANTS = restaurants.list;
export const restaurantById = restaurants.byId;
export const canonicalRestaurantLabel = restaurants.canonicalLabel;

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
