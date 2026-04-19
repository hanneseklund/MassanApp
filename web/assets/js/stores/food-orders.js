// Food orders store: mirrors the signed-in user's rows from
// public.food_orders. Row Level Security scopes selects to
// auth.uid() = user_id, same pattern as the tickets store.

import { supabaseClient } from "../supabase.js";

export function foodOrdersStore() {
  return {
    orders: [],
    loading: false,
    error: null,

    init() {},

    async _onSessionChange() {
      const user = Alpine.store("session").user;
      if (!user) {
        this.orders = [];
        return;
      }
      this.loading = true;
      this.error = null;
      const db = supabaseClient();
      const { data, error } = await db
        .from("food_orders")
        .select("*")
        .order("ordered_at", { ascending: false });
      this.loading = false;
      if (error) {
        console.warn("Could not load food orders:", error.message);
        this.error = error.message;
        this.orders = [];
        return;
      }
      this.orders = data || [];
    },

    forUser(userId) {
      if (!userId) return [];
      return this.orders.filter((o) => o.user_id === userId);
    },

    async add(order) {
      const db = supabaseClient();
      const row = {
        ...(order.id ? { id: order.id } : {}),
        user_id: order.user_id,
        event_id: order.event_id,
        menu_id: order.menu_id,
        menu_label: order.menu_label,
        price: order.price,
        delivery_mode: order.delivery_mode,
        delivery_id: order.delivery_id,
        delivery_label: order.delivery_label,
        timeslot_from: order.timeslot_from ?? null,
        timeslot_to: order.timeslot_to ?? null,
        transaction_ref: order.transaction_ref,
        ordered_at: order.ordered_at,
      };
      const { data, error } = await db
        .from("food_orders")
        .insert(row)
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      this.orders.unshift(data);
      return data;
    },
  };
}
