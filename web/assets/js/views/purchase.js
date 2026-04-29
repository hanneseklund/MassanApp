// Purchase view: four-step simulated ticket purchase flow. Local
// Alpine state owns the step counter and form values; the persisted
// ticket is written via `Alpine.store("tickets").add` once simulated
// payment succeeds. The questionnaire step (step 2) captures the
// general-profile answers and event-relevant subjects defined in
// docs/functional-specification.md under "Ticket purchase (simulated)".

import { formatDates } from "../util/dates.js";
import { ticketTypesFor, canonicalTicketTypeLabel } from "../util/sections.js";
import { simulatedPayment } from "../simulations/payment.js";
import { simulatedEmail } from "../simulations/email.js";
import { ticketQrPayload, ticketQrSvgFor } from "../simulations/qr.js";
import { pointsForTicket } from "../util/points.js";
import { supabaseClient } from "../supabase.js";
import {
  defaultQuestionnaire,
  subjectsFor,
  subjectKey,
  buildQuestionnairePayload,
  buildProfileUpdate,
} from "../util/questionnaire.js";

export function purchaseView() {
  return {
    step: 1,
    ticketTypeId: null,
    attendeeName: "",
    attendeeEmail: "",
    questionnaire: defaultQuestionnaire(null, {}),
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
          Alpine.store("session").loading,
        ],
        () => this._applyAuthGuardAndHydrate(),
      );
      this._applyAuthGuardAndHydrate();
    },

    // A visitor who lands on the purchase route while signed out is
    // routed through auth and returned afterwards (see "Ticket purchase
    // (simulated)" in docs/functional-specification.md). The CTA path
    // handles this via app._requireAuth; this guard covers direct URL
    // navigation. Waits for session.loading to finish so a still-loading
    // Supabase session is never mistaken for "signed out".
    _applyAuthGuardAndHydrate() {
      const app = Alpine.store("app");
      if (app.view !== "purchase") return;
      const session = Alpine.store("session");
      if (session.loading) return;
      if (!session.user) {
        app.goAuth({ view: "purchase", eventId: app.eventId });
        return;
      }
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
      this.questionnaire = defaultQuestionnaire(this.event(), user?.profile);
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

    subjects() {
      return subjectsFor(this.event());
    },

    subjectKey(subject) {
      return subjectKey(subject);
    },

    hasSubjects() {
      return this.subjects().length > 0;
    },

    toggleSubject(subject) {
      const key = subjectKey(subject);
      if (!key) return;
      const set = new Set(this.questionnaire.subjects);
      if (set.has(key)) set.delete(key);
      else set.add(key);
      this.questionnaire.subjects = [...set];
    },

    isSubjectSelected(subject) {
      return this.questionnaire.subjects.includes(subjectKey(subject));
    },

    isProfessional() {
      return this.questionnaire.profile.visit_type === "professional";
    },

    goToStep(step) {
      this.step = step;
      this.error = "";
    },

    continueToQuestionnaire() {
      if (!this.ticketTypeId) {
        this.error = Alpine.store("lang").t("purchase.err_pick_type");
        return;
      }
      this.goToStep(2);
    },

    continueToDetails() {
      if (!this.questionnaire.profile.visit_type) {
        this.error = Alpine.store("lang").t("purchase.err_pick_visit_type");
        return;
      }
      this.goToStep(3);
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
      if (!this.questionnaire.profile.visit_type) {
        this.error = tStore.t("purchase.err_pick_visit_type");
        this.step = 2;
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
        // Assign the id client-side so the QR payload embeds it
        // without a second round trip; otherwise every ticket for a
        // given event hashes to the same visual QR.
        const questionnairePayload = buildQuestionnairePayload(
          this.questionnaire,
        );
        const draft = {
          id: crypto.randomUUID(),
          user_id: user.id,
          event_id: ev.id,
          ticket_type: type.id,
          ticket_type_label: canonicalTicketTypeLabel(type.id),
          attendee_name: name,
          attendee_email: email,
          transaction_ref: payment.transaction_ref,
          purchased_at: new Date().toISOString(),
          questionnaire: questionnairePayload,
        };
        draft.qr_payload = ticketQrPayload(draft);
        const ticket = await Alpine.store("tickets").add(draft);
        // Persist the general-profile answers back to the user's
        // Supabase account so the next purchase pre-fills. A failure
        // here must not fail the purchase — mirror the points-earn
        // error-tolerance rule.
        try {
          const profileUpdate = buildProfileUpdate(this.questionnaire);
          const { error: profileErr } = await supabaseClient().auth.updateUser({
            data: { profile: profileUpdate },
          });
          if (profileErr) throw new Error(profileErr.message);
        } catch (profileErr) {
          console.warn(
            "Saving purchase profile failed:",
            profileErr.message,
          );
        }
        // Award points for the simulated purchase. `tryEarn` swallows
        // a failed insert so the user-visible "ticket purchased"
        // outcome stands; the failure surfaces through the points
        // store's `error` state instead.
        await Alpine.store("points").tryEarn({
          source: "ticket",
          source_ref: ticket.id,
          amount: pointsForTicket(ticket),
          event_id: ticket.event_id,
        });
        simulatedEmail("ticket_confirmation", {
          to: email,
          user_id: user.id,
          event_id: ev.id,
          event_name: Alpine.store("lang").pick(ev.name),
          ticket_id: ticket.id,
          ticket_type: ticket.ticket_type,
          transaction_ref: ticket.transaction_ref,
        });
        this.confirmedTicket = ticket;
        this.step = 4;
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
