// Purchase view: three-step simulated ticket purchase flow. Local
// Alpine state owns the step counter and form values; the persisted
// ticket is written via `Alpine.store("tickets").add` once simulated
// payment succeeds.

import { formatDates } from "../util/dates.js";
import { ticketTypesFor, canonicalTicketTypeLabel } from "../util/sections.js";
import { simulatedPayment } from "../simulations/payment.js";
import { simulatedEmail } from "../simulations/email.js";
import { ticketQrPayload, ticketQrSvgFor } from "../simulations/qr.js";

export function purchaseView() {
  return {
    step: 1,
    ticketTypeId: null,
    attendeeName: "",
    attendeeEmail: "",
    processing: false,
    error: "",
    confirmedTicket: null,
    formatDates,

    init() {
      this.$watch(
        () => [
          Alpine.store("app").view,
          Alpine.store("app").eventId,
          Alpine.store("session").user?.id,
        ],
        () => {
          if (Alpine.store("app").view === "purchase") this._hydrate();
        }
      );
      this._hydrate();
    },

    _hydrate() {
      this.step = 1;
      this.ticketTypeId = null;
      this.processing = false;
      this.error = "";
      this.confirmedTicket = null;
      const user = Alpine.store("session").user;
      this.attendeeName = user?.display_name ?? "";
      this.attendeeEmail = user?.email ?? "";
    },

    event() {
      const id = Alpine.store("app").eventId;
      return id ? Alpine.store("catalog").eventById(id) : null;
    },

    ticketTypes() {
      return ticketTypesFor(this.event());
    },

    selectedTicketType() {
      const id = this.ticketTypeId;
      return this.ticketTypes().find((t) => t.id === id) ?? null;
    },

    goToStep(step) {
      this.step = step;
      this.error = "";
    },

    continueToDetails() {
      if (!this.ticketTypeId) {
        this.error = Alpine.store("lang").t("purchase.err_pick_type");
        return;
      }
      this.goToStep(2);
    },

    async confirm() {
      const tStore = Alpine.store("lang");
      const ev = this.event();
      const type = this.selectedTicketType();
      if (!ev || !type) {
        this.error = tStore.t("purchase.err_pick_first");
        this.step = 1;
        return;
      }
      const user = Alpine.store("session").user;
      if (!user) {
        this.error = tStore.t("purchase.err_sign_in");
        return;
      }
      const name = String(this.attendeeName || "").trim();
      const email = String(this.attendeeEmail || "").trim();
      if (!name || !email) {
        this.error = tStore.t("purchase.err_attendee_required");
        return;
      }
      this.error = "";
      this.processing = true;
      try {
        const payment = await simulatedPayment({
          user_id: user.id,
          event_id: ev.id,
          ticket_type: type.id,
          attendee_email: email,
        });
        const draft = {
          user_id: user.id,
          event_id: ev.id,
          ticket_type: type.id,
          ticket_type_label: canonicalTicketTypeLabel(type.id),
          attendee_name: name,
          attendee_email: email,
          transaction_ref: payment.transaction_ref,
          purchased_at: new Date().toISOString(),
        };
        draft.qr_payload = ticketQrPayload(draft);
        const ticket = await Alpine.store("tickets").add(draft);
        // If the returned row did not include a persisted qr_payload,
        // fall back to the draft so the confirmation screen still has one.
        if (!ticket.qr_payload) ticket.qr_payload = draft.qr_payload;
        simulatedEmail("ticket_confirmation", {
          to: email,
          user_id: user.id,
          event_id: ev.id,
          event_name: ev.name,
          ticket_id: ticket.id,
          ticket_type: ticket.ticket_type,
          transaction_ref: ticket.transaction_ref,
        });
        this.confirmedTicket = ticket;
        this.step = 3;
      } catch (err) {
        this.error =
          err.message || Alpine.store("lang").t("purchase.err_generic");
      } finally {
        this.processing = false;
      }
    },

    qrSvgFor: ticketQrSvgFor,
  };
}
