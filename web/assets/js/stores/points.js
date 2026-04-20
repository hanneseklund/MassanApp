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
import { loadUserRows } from "../util/session-sync.js";

export function pointsStore() {
  return {
    transactions: [],
    loading: false,
    error: null,

    init() {},

    async _onSessionChange() {
      await loadUserRows(this, {
        table: "point_transactions",
        field: "transactions",
        orderBy: "created_at",
        logLabel: "point transactions",
      });
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

    // Error-tolerant wrapper around `earn` for the simulated purchase
    // flows. A failed insert must not fail the parent purchase (see
    // docs/implementation-specification.md, "Points earning and
    // redemption"), so `tryEarn` swallows the error, logs it, and
    // resolves to `null`. The underlying failure is still visible on
    // `this.error`, which drives the My Pages points banner.
    async tryEarn({ source, source_ref, amount, event_id }) {
      try {
        return await this.earn({ source, source_ref, amount, event_id });
      } catch (err) {
        console.warn("Points earn failed:", err.message);
        return null;
      }
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
      // Clear any error from a prior write so a successful earn/redeem
      // does not leave a stale "Could not load your points" banner on
      // My Pages. loadUserRows follows the same pattern on reload.
      this.error = null;
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
