// My Tickets view: lists the signed-in user's tickets with QR-code
// presentation. Visitors arriving here without a session get a prompt
// to sign in.

import { formatDates, formatShortDate } from "../util/dates.js";
import { ticketQrSvgFor } from "../simulations/qr.js";

export function myTicketsView() {
  return {
    formatDates,
    formatShortDate,
    signedIn() {
      return !!Alpine.store("session").user;
    },
    tickets() {
      const user = Alpine.store("session").user;
      if (!user) return [];
      return Alpine.store("tickets")
        .forUser(user.id)
        .slice()
        .sort((a, b) =>
          (b.purchased_at || "").localeCompare(a.purchased_at || "")
        );
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
