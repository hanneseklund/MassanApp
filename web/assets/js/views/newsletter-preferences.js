// Newsletter preferences list shown in My Pages. Lists the signed-in
// user's subscriptions by event plus a venue-wide row that can be
// toggled on and off.

import {
  defaultNewsletterPreferences,
  NEWSLETTER_TOPICS,
} from "../newsletter/preferences.js";
import { simulatedEmail } from "../simulations/email.js";

export function newsletterPreferences() {
  return {
    topics: NEWSLETTER_TOPICS,

    subscriptions() {
      const user = Alpine.store("session").user;
      if (!user) return [];
      return Alpine.store("newsletter")
        .forUser(user.id)
        .filter((s) => s.event_id !== null)
        .map((s) => ({
          ...s,
          event_name:
            Alpine.store("catalog").eventById(s.event_id)?.name ?? s.event_id,
        }))
        .sort((a, b) => (a.event_name || "").localeCompare(b.event_name || ""));
    },

    venueWide() {
      const user = Alpine.store("session").user;
      if (!user) return null;
      return Alpine.store("newsletter").findForEvent({
        email: user.email,
        userId: user.id,
        eventId: null,
      });
    },

    async togglePreference(sub, key) {
      try {
        await Alpine.store("newsletter").updatePreferences(sub.id, {
          [key]: !sub.preferences[key],
        });
      } catch (err) {
        console.warn("Could not update preference:", err.message);
      }
    },

    async unsubscribe(id) {
      try {
        await Alpine.store("newsletter").unsubscribe(id);
      } catch (err) {
        console.warn("Could not unsubscribe:", err.message);
      }
    },

    async toggleVenueWide() {
      const user = Alpine.store("session").user;
      if (!user) return;
      const existing = this.venueWide();
      if (existing) {
        try {
          await Alpine.store("newsletter").unsubscribe(existing.id);
        } catch (err) {
          console.warn("Could not unsubscribe venue-wide:", err.message);
        }
        return;
      }
      try {
        const record = await Alpine.store("newsletter").subscribe({
          email: user.email,
          userId: user.id,
          eventId: null,
          preferences: defaultNewsletterPreferences(),
        });
        simulatedEmail("newsletter_confirmation", {
          to: record.email,
          user_id: record.user_id,
          event_id: null,
          event_name: Alpine.store("lang").t(
            "newsletter.venue_wide_event_name",
          ),
          preferences: record.preferences,
        });
      } catch (err) {
        console.warn("Could not subscribe venue-wide:", err.message);
      }
    },
  };
}
