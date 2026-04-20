// Food orders store: mirrors the signed-in user's rows from
// public.food_orders. Row Level Security scopes selects to
// auth.uid() = user_id, same pattern as the tickets store.

import { insertOwnedRow, loadUserRows } from "../util/session-sync.js";

export function foodOrdersStore() {
  return {
    orders: [],
    loading: false,
    error: null,

    init() {},

    async _onSessionChange() {
      await loadUserRows(this, {
        table: "food_orders",
        field: "orders",
        orderBy: "ordered_at",
        logLabel: "food orders",
      });
    },

    forUser(userId) {
      if (!userId) return [];
      return this.orders.filter((o) => o.user_id === userId);
    },

    async add(order) {
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
      return insertOwnedRow(this, {
        table: "food_orders",
        field: "orders",
        row,
      });
    },
  };
}
