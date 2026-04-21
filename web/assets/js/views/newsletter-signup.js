// Newsletter signup form for an event's Newsletter subview. Pre-fills
// the email from the signed-in user when available, re-hydrates any
// prior subscription for this (user, event) pair from Supabase, and
// toggles into a success state after submit. Anonymous signups show a
// success state in-session but cannot be re-read after reload because
// RLS on newsletter_subscriptions requires `auth.uid() = user_id`.

import {
  defaultNewsletterPreferences,
  NEWSLETTER_TOPICS,
} from "../util/newsletter.js";
import { simulatedEmail } from "../simulations/email.js";

export function newsletterSignup() {
  return {
    topics: NEWSLETTER_TOPICS,
    email: "",
    preferences: defaultNewsletterPreferences(),
    submitted: false,
    processing: false,
    error: "",

    event() {
      const id = Alpine.store("app").eventId;
      return id ? Alpine.store("catalog").eventById(id) : null;
    },

    init() {
      this.$watch(
        () => [Alpine.store("app").eventId, Alpine.store("session").user?.id],
        () => this._hydrate()
      );
      this._hydrate();
    },

    _hydrate() {
      this.error = "";
      this.submitted = false;
      const user = Alpine.store("session").user;
      const eventId = Alpine.store("app").eventId;
      this.email = user?.email ?? "";
      const existing = user
        ? Alpine.store("newsletter").findForEvent({
            email: user.email,
            userId: user.id,
            eventId,
          })
        : null;
      if (existing) {
        this.email = existing.email;
        this.preferences = { ...existing.preferences };
        this.submitted = true;
      } else {
        this.preferences = defaultNewsletterPreferences();
      }
    },

    async submit() {
      if (this.processing) return;
      this.error = "";
      this.processing = true;
      try {
        const user = Alpine.store("session").user;
        const eventId = Alpine.store("app").eventId;
        const record = await Alpine.store("newsletter").subscribe({
          email: this.email,
          userId: user?.id ?? null,
          eventId,
          preferences: this.preferences,
        });
        const event = Alpine.store("catalog").eventById(eventId);
        simulatedEmail("newsletter_confirmation", {
          to: record.email,
          user_id: record.user_id,
          event_id: record.event_id,
          event_name: event?.name ?? null,
          preferences: record.preferences,
        });
        this.submitted = true;
      } catch (err) {
        this.error =
          err.message || Alpine.store("lang").t("newsletter.err_signup");
      } finally {
        this.processing = false;
      }
    },

    editAgain() {
      this.submitted = false;
    },
  };
}
