// Points store: mirrors the signed-in user's rows from
// public.point_transactions. Row Level Security scopes selects and
// inserts to auth.uid() = user_id, same pattern as tickets and food
// orders. Balance is computed as `sum(delta)` over the loaded rows —
// no denormalised column — so the balance cannot drift from the
// history.
//
// Earning is wired into the purchase and food flows via `earn(...)`;
// redemption goes through `redeem(...)` from the event-add-ons
// section on `views/event.js` and the `views/points-shop.js`
// screen for venue-wide merchandise.

import { supabaseClient } from "../supabase.js";

export function pointsStore() {
  return {
    transactions: [],
    loading: false,
    error: null,

    init() {},

    async _onSessionChange() {
      const user = Alpine.store("session").user;
      if (!user) {
        this.transactions = [];
        this.error = null;
        return;
      }
      this.loading = true;
      this.error = null;
      const db = supabaseClient();
      const { data, error } = await db
        .from("point_transactions")
        .select("*")
        .order("created_at", { ascending: false });
      this.loading = false;
      if (error) {
        console.warn("Could not load point transactions:", error.message);
        this.error = error.message;
        this.transactions = [];
        return;
      }
      this.transactions = data || [];
    },

    get balance() {
      return this.transactions.reduce(
        (sum, row) => sum + (row.delta || 0),
        0,
      );
    },

    forUser(userId) {
      if (!userId) return [];
      return this.transactions.filter((t) => t.user_id === userId);
    },

    async earn({ source, source_ref, amount, event_id }) {
      return this._insert({
        source,
        source_ref,
        event_id: event_id ?? null,
        delta: amount,
      });
    },

    async redeem({ source, source_ref, amount, event_id }) {
      return this._insert({
        source,
        source_ref,
        event_id: event_id ?? null,
        delta: -Math.abs(amount),
      });
    },

    async _insert({ source, source_ref, event_id, delta }) {
      const user = Alpine.store("session").user;
      if (!user) {
        throw new Error("Cannot record points: no signed-in user.");
      }
      const db = supabaseClient();
      const { data, error } = await db
        .from("point_transactions")
        .insert({
          user_id: user.id,
          event_id,
          source,
          source_ref: source_ref ?? null,
          delta,
        })
        .select("*")
        .single();
      if (error) {
        this.error = error.message;
        throw new Error(error.message);
      }
      this.transactions.unshift(data);
      return data;
    },
  };
}
