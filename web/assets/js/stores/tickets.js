// Tickets store: mirrors the signed-in user's rows from
// public.tickets. Row Level Security filters to rows where
// auth.uid() = user_id, so a plain `select` returns only the
// signed-in user's tickets. Inserts go through the Supabase client.

import { insertOwnedRow, loadUserRows } from "../util/session-sync.js";

export function ticketsStore() {
  return {
    tickets: [],
    loading: false,
    error: null,

    init() {},

    async _onSessionChange() {
      await loadUserRows(this, {
        table: "tickets",
        field: "tickets",
        orderBy: "purchased_at",
      });
    },

    forUser(userId) {
      if (!userId) return [];
      return this.tickets.filter((t) => t.user_id === userId);
    },

    forUserAndEvent(userId, eventId) {
      if (!userId || !eventId) return [];
      return this.tickets.filter(
        (t) => t.user_id === userId && t.event_id === eventId,
      );
    },

    hasForEvent(userId, eventId) {
      return this.forUserAndEvent(userId, eventId).length > 0;
    },

    async add(ticket) {
      const row = {
        ...(ticket.id ? { id: ticket.id } : {}),
        user_id: ticket.user_id,
        event_id: ticket.event_id,
        ticket_type: ticket.ticket_type,
        ticket_type_label: ticket.ticket_type_label,
        attendee_name: ticket.attendee_name,
        attendee_email: ticket.attendee_email,
        qr_payload: ticket.qr_payload,
        transaction_ref: ticket.transaction_ref,
        purchased_at: ticket.purchased_at,
        ...(ticket.questionnaire !== undefined
          ? { questionnaire: ticket.questionnaire }
          : {}),
      };
      return insertOwnedRow(this, {
        table: "tickets",
        field: "tickets",
        row,
      });
    },
  };
}
