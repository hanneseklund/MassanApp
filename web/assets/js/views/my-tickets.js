// My Tickets view: lists the signed-in user's tickets with QR-code
// presentation. Visitors arriving here without a session get a prompt
// to sign in.

import { formatDates, formatShortDate } from "../util/dates.js";
import { ticketQrSvgFor } from "../simulations/qr.js";

export function myTicketsView() {
  return {
    formatDates,
    formatShortDate,
    tickets() {
      const user = Alpine.store("session").user;
      if (!user) return [];
      const selectedEventId = Alpine.store("app").eventId;
      return Alpine.store("tickets")
        .forUser(user.id)
        .slice()
        .sort((a, b) => {
          if (selectedEventId) {
            const aMatch = a.event_id === selectedEventId ? 0 : 1;
            const bMatch = b.event_id === selectedEventId ? 0 : 1;
            if (aMatch !== bMatch) return aMatch - bMatch;
          }
          return (b.purchased_at || "").localeCompare(a.purchased_at || "");
        });
    },
    eventName(ticket) {
      return (
        Alpine.store("catalog").eventById(ticket.event_id)?.name ??
        ticket.event_id
      );
    },
    eventForTicket(ticket) {
      return Alpine.store("catalog").eventById(ticket.event_id);
    },
    qrSvgFor: ticketQrSvgFor,
  };
}
