// Shared helpers for the user-scoped stores that mirror Supabase rows
// behind Row Level Security (tickets, food orders, points, newsletter
// subscriptions). `stores/session.js` owns the auth subscription and
// fans sign-in / sign-out events out to these stores through
// `notifySessionStores`; each store's `_onSessionChange` delegates to
// `loadUserRows` so the clear-on-signed-out, set-loading, select,
// console.warn-plus-store.error-on-failure contract is written once.
// `insertOwnedRow` covers the matching insert half: `tickets.add`,
// `foodOrders.add`, and `points._insert` all follow the same
// `insert → select("*").single() → throw on error → unshift to field`
// shape and delegate here so the three paths cannot drift.

import { supabaseClient } from "../supabase.js";

// Stores notified on every Supabase auth state change. Keep this in
// sync with the Alpine.store ids registered in `app.js`.
export const SESSION_SYNC_STORE_IDS = [
  "tickets",
  "newsletter",
  "foodOrders",
  "points",
];

export function notifySessionStores() {
  for (const id of SESSION_SYNC_STORE_IDS) {
    Alpine.store(id)?._onSessionChange?.();
  }
}

export async function loadUserRows(
  store,
  { table, field, orderBy, logLabel, normalize },
) {
  const label = logLabel || table;
  const user = Alpine.store("session").user;
  if (!user) {
    store[field] = [];
    store.error = null;
    return;
  }
  store.loading = true;
  store.error = null;
  const db = supabaseClient();
  let query = db.from(table).select("*");
  if (orderBy) {
    query = query.order(orderBy, { ascending: false });
  }
  const { data, error } = await query;
  store.loading = false;
  if (error) {
    console.warn(`Could not load ${label}:`, error.message);
    store.error = error.message;
    store[field] = [];
    return;
  }
  const rows = data || [];
  store[field] = normalize ? rows.map(normalize) : rows;
}

// Insert a user-owned row through the Supabase client and prepend the
// returned row to `store[field]` so the in-memory list stays consistent
// with the database without a refetch. Throws on Supabase errors so
// callers can show an inline error; a caller that needs the row to
// land in `store.error` too (like the points store, which is read
// error-tolerantly by `tryEarn`) can wrap the call.
export async function insertOwnedRow(store, { table, field, row }) {
  const db = supabaseClient();
  const { data, error } = await db
    .from(table)
    .insert(row)
    .select("*")
    .single();
  if (error) throw new Error(error.message);
  store[field].unshift(data);
  return data;
}
