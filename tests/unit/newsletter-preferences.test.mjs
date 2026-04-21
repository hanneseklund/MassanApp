// newsletterPreferences() in views/newsletter-preferences.js drives the
// My Pages newsletter section. The selectors that build the per-event
// list and resolve the venue-wide row decide what the visitor sees, so
// pinning them down catches regressions (a wrong filter would either
// hide a per-event row or surface the venue-wide row twice) without a
// browser round-trip.
//
// Follows the Alpine.store stub pattern from me.test.mjs — no browser,
// no Supabase, no Alpine runtime.

import test from "node:test";
import assert from "node:assert/strict";

import { newsletterPreferences } from "../../web/assets/js/views/newsletter-preferences.js";

function withAlpine(stores, body) {
  const prev = globalThis.Alpine;
  globalThis.Alpine = {
    store(id) {
      return stores[id];
    },
  };
  try {
    return body();
  } finally {
    globalThis.Alpine = prev;
  }
}

function makeStores({ user = null, subscriptions = [], events = {} } = {}) {
  return {
    session: { user },
    newsletter: {
      forUser(userId) {
        return subscriptions.filter((s) => s.user_id === userId);
      },
      findForEvent({ email, userId, eventId }) {
        const eid = eventId ?? null;
        return (
          subscriptions.find((s) => {
            if ((s.event_id ?? null) !== eid) return false;
            if (userId && s.user_id === userId) return true;
            if (email && (s.email || "").toLowerCase() === email.toLowerCase()) {
              return true;
            }
            return false;
          }) ?? null
        );
      },
    },
    catalog: {
      eventById(id) {
        return events[id] ?? null;
      },
    },
  };
}

test("subscriptions(): empty when signed out", () => {
  withAlpine(
    makeStores({
      user: null,
      subscriptions: [
        { id: "s1", user_id: "u", event_id: "nordbygg-2026" },
      ],
    }),
    () => {
      assert.deepEqual(newsletterPreferences().subscriptions(), []);
    },
  );
});

test("subscriptions(): only the signed-in user's per-event rows are returned", () => {
  withAlpine(
    makeStores({
      user: { id: "u-1", email: "u1@example.com" },
      subscriptions: [
        { id: "a", user_id: "u-1", event_id: "nordbygg-2026" },
        { id: "b", user_id: "u-2", event_id: "nordbygg-2026" },
        { id: "c", user_id: "u-1", event_id: "estro-2026" },
      ],
      events: {
        "nordbygg-2026": { id: "nordbygg-2026", name: "Nordbygg 2026" },
        "estro-2026": { id: "estro-2026", name: "ESTRO 2026" },
      },
    }),
    () => {
      const ids = newsletterPreferences()
        .subscriptions()
        .map((s) => s.id);
      assert.deepEqual(ids.sort(), ["a", "c"]);
    },
  );
});

test("subscriptions(): the venue-wide row (event_id IS NULL) is excluded", () => {
  withAlpine(
    makeStores({
      user: { id: "u-1", email: "u1@example.com" },
      subscriptions: [
        { id: "venue", user_id: "u-1", event_id: null },
        { id: "evt", user_id: "u-1", event_id: "nordbygg-2026" },
      ],
      events: {
        "nordbygg-2026": { id: "nordbygg-2026", name: "Nordbygg 2026" },
      },
    }),
    () => {
      const ids = newsletterPreferences()
        .subscriptions()
        .map((s) => s.id);
      assert.deepEqual(ids, ["evt"]);
    },
  );
});

test("subscriptions(): rows are enriched with the catalog event name", () => {
  withAlpine(
    makeStores({
      user: { id: "u-1", email: "u1@example.com" },
      subscriptions: [
        { id: "a", user_id: "u-1", event_id: "nordbygg-2026" },
      ],
      events: {
        "nordbygg-2026": { id: "nordbygg-2026", name: "Nordbygg 2026" },
      },
    }),
    () => {
      const [row] = newsletterPreferences().subscriptions();
      assert.equal(row.event_name, "Nordbygg 2026");
    },
  );
});

test("subscriptions(): unknown event ids fall back to the id as the event name", () => {
  withAlpine(
    makeStores({
      user: { id: "u-1", email: "u1@example.com" },
      subscriptions: [
        { id: "a", user_id: "u-1", event_id: "missing-evt" },
      ],
    }),
    () => {
      const [row] = newsletterPreferences().subscriptions();
      assert.equal(row.event_name, "missing-evt");
    },
  );
});

test("subscriptions(): rows are sorted by resolved event_name", () => {
  withAlpine(
    makeStores({
      user: { id: "u-1", email: "u1@example.com" },
      subscriptions: [
        { id: "z", user_id: "u-1", event_id: "z-evt" },
        { id: "a", user_id: "u-1", event_id: "a-evt" },
        { id: "m", user_id: "u-1", event_id: "m-evt" },
      ],
      events: {
        "z-evt": { id: "z-evt", name: "Zeppelin Expo" },
        "a-evt": { id: "a-evt", name: "Aviation Days" },
        "m-evt": { id: "m-evt", name: "Maker Fair" },
      },
    }),
    () => {
      const names = newsletterPreferences()
        .subscriptions()
        .map((s) => s.event_name);
      assert.deepEqual(names, ["Aviation Days", "Maker Fair", "Zeppelin Expo"]);
    },
  );
});

test("venueWide(): null when signed out", () => {
  withAlpine(
    makeStores({
      user: null,
      subscriptions: [{ id: "venue", user_id: "u", event_id: null }],
    }),
    () => {
      assert.equal(newsletterPreferences().venueWide(), null);
    },
  );
});

test("venueWide(): null when no venue-wide row exists for the signed-in user", () => {
  withAlpine(
    makeStores({
      user: { id: "u-1", email: "u1@example.com" },
      subscriptions: [
        { id: "evt", user_id: "u-1", event_id: "nordbygg-2026" },
      ],
    }),
    () => {
      assert.equal(newsletterPreferences().venueWide(), null);
    },
  );
});

test("venueWide(): returns the user's venue-wide row when present", () => {
  withAlpine(
    makeStores({
      user: { id: "u-1", email: "u1@example.com" },
      subscriptions: [
        { id: "venue", user_id: "u-1", event_id: null },
        { id: "evt", user_id: "u-1", event_id: "nordbygg-2026" },
      ],
    }),
    () => {
      const row = newsletterPreferences().venueWide();
      assert.equal(row?.id, "venue");
    },
  );
});

test("venueWide(): another user's venue-wide row is not returned", () => {
  withAlpine(
    makeStores({
      user: { id: "u-1", email: "u1@example.com" },
      subscriptions: [
        { id: "venue-other", user_id: "u-2", event_id: null },
      ],
    }),
    () => {
      assert.equal(newsletterPreferences().venueWide(), null);
    },
  );
});
