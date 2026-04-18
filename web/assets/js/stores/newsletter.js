// Newsletter store: for signed-in users, mirrors their rows in
// public.newsletter_subscriptions (including the venue-wide row
// where event_id IS NULL). Anonymous signups insert through the
// "anyone insert newsletter" RLS policy but cannot be read back,
// so the store only carries in-session state for those.

import { supabaseClient } from "../supabase.js";
import { normalizeNewsletterPreferences } from "../newsletter/preferences.js";
import { activeTranslate } from "../i18n.js";

export function newsletterStore() {
  return {
    subscriptions: [],
    loading: false,
    error: null,

    init() {},

    async _onSessionChange() {
      const user = Alpine.store("session").user;
      if (!user) {
        this.subscriptions = [];
        return;
      }
      this.loading = true;
      this.error = null;
      const db = supabaseClient();
      const { data, error } = await db
        .from("newsletter_subscriptions")
        .select("*");
      this.loading = false;
      if (error) {
        console.warn("Could not load newsletter subscriptions:", error.message);
        this.error = error.message;
        this.subscriptions = [];
        return;
      }
      this.subscriptions = (data || []).map((s) => ({
        ...s,
        preferences: normalizeNewsletterPreferences(s.preferences),
      }));
    },

    findForEvent({ email, userId, eventId }) {
      const eid = eventId ?? null;
      return (
        this.subscriptions.find((s) => {
          if ((s.event_id ?? null) !== eid) return false;
          if (userId && s.user_id === userId) return true;
          if (email && (s.email || "").toLowerCase() === email.toLowerCase()) {
            return true;
          }
          return false;
        }) ?? null
      );
    },

    forUser(userId) {
      if (!userId) return [];
      return this.subscriptions.filter((s) => s.user_id === userId);
    },

    async subscribe({ email, userId, eventId, preferences }) {
      const cleanEmail = String(email || "").trim();
      if (!cleanEmail) {
        throw new Error(activeTranslate("newsletter.err_email_required"));
      }
      const prefs = normalizeNewsletterPreferences(preferences);
      const eid = eventId ?? null;
      if (userId) {
        const existing = this.findForEvent({
          email: cleanEmail,
          userId,
          eventId: eid,
        });
        if (existing) {
          return this._updateRow(existing.id, { email: cleanEmail, preferences: prefs });
        }
      }
      const db = supabaseClient();
      const row = {
        user_id: userId ?? null,
        email: cleanEmail,
        event_id: eid,
        preferences: prefs,
      };
      // Anonymous inserts can't chain `.select()`: the SELECT RLS policy
      // on newsletter_subscriptions requires `auth.uid() = user_id`, and
      // RETURNING the just-inserted row under that policy raises a
      // 42501 RLS violation. Omit the representation for anon and
      // synthesize the UI record from the submitted payload.
      if (!userId) {
        const { error } = await db
          .from("newsletter_subscriptions")
          .insert(row);
        if (error) throw new Error(error.message);
        return {
          id: null,
          user_id: null,
          email: cleanEmail,
          event_id: eid,
          preferences: prefs,
        };
      }
      const { data, error } = await db
        .from("newsletter_subscriptions")
        .insert(row)
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      const normalized = {
        ...data,
        preferences: normalizeNewsletterPreferences(data.preferences),
      };
      this.subscriptions.push(normalized);
      return normalized;
    },

    async updatePreferences(id, preferencesPatch) {
      const sub = this.subscriptions.find((s) => s.id === id);
      if (!sub) return null;
      const merged = normalizeNewsletterPreferences({
        ...sub.preferences,
        ...preferencesPatch,
      });
      return this._updateRow(id, { preferences: merged });
    },

    async _updateRow(id, patch) {
      const db = supabaseClient();
      const { data, error } = await db
        .from("newsletter_subscriptions")
        .update(patch)
        .eq("id", id)
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      const normalized = {
        ...data,
        preferences: normalizeNewsletterPreferences(data.preferences),
      };
      const idx = this.subscriptions.findIndex((s) => s.id === id);
      if (idx >= 0) this.subscriptions[idx] = normalized;
      else this.subscriptions.push(normalized);
      return normalized;
    },

    async unsubscribe(id) {
      const db = supabaseClient();
      const { error } = await db
        .from("newsletter_subscriptions")
        .delete()
        .eq("id", id);
      if (error) throw new Error(error.message);
      this.subscriptions = this.subscriptions.filter((s) => s.id !== id);
    },
  };
}
