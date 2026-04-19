// Newsletter-store selectors. `findForEvent` is the non-trivial bit:
// it resolves an existing subscription for a given (user_id or email,
// event_id) pair and is how the signup view decides between insert and
// update. `event_id IS NULL` represents the venue-wide subscription
// and must match only when the caller explicitly passes a null eventId.
// The network path in `_onSessionChange` can't run without Supabase,
// but the pure selectors over `this.subscriptions` don't need it.

import test from "node:test";
import assert from "node:assert/strict";

import { newsletterStore } from "../../web/assets/js/stores/newsletter.js";

function withSubscriptions(subscriptions) {
  const store = newsletterStore();
  store.subscriptions = subscriptions;
  return store;
}

test("forUser: filters rows by user_id", () => {
  const store = withSubscriptions([
    { id: "s1", user_id: "u-1", event_id: "e-1" },
    { id: "s2", user_id: "u-2", event_id: "e-1" },
    { id: "s3", user_id: "u-1", event_id: null },
  ]);
  assert.deepEqual(
    store.forUser("u-1").map((s) => s.id),
    ["s1", "s3"],
  );
});

test("forUser: returns an empty array for missing user_id", () => {
  const store = withSubscriptions([{ id: "s1", user_id: "u-1", event_id: "e-1" }]);
  assert.deepEqual(store.forUser(null), []);
  assert.deepEqual(store.forUser(undefined), []);
  assert.deepEqual(store.forUser(""), []);
});

test("findForEvent: matches by userId and eventId", () => {
  const store = withSubscriptions([
    { id: "s1", user_id: "u-1", email: "jane@example.com", event_id: "e-1" },
    { id: "s2", user_id: "u-2", email: "rob@example.com", event_id: "e-1" },
  ]);
  const out = store.findForEvent({ userId: "u-1", eventId: "e-1" });
  assert.equal(out?.id, "s1");
});

test("findForEvent: falls back to case-insensitive email match when userId is absent", () => {
  const store = withSubscriptions([
    { id: "s1", user_id: null, email: "Jane@Example.com", event_id: "e-1" },
  ]);
  const out = store.findForEvent({ email: "jane@example.com", eventId: "e-1" });
  assert.equal(out?.id, "s1");
});

test("findForEvent: venue-wide row is matched only when eventId is explicitly null", () => {
  const store = withSubscriptions([
    { id: "venue", user_id: "u-1", email: "a@b.com", event_id: null },
    { id: "event", user_id: "u-1", email: "a@b.com", event_id: "e-1" },
  ]);
  assert.equal(
    store.findForEvent({ userId: "u-1", eventId: null })?.id,
    "venue",
  );
  assert.equal(
    store.findForEvent({ userId: "u-1", eventId: "e-1" })?.id,
    "event",
  );
});

test("findForEvent: returns null when no subscription matches", () => {
  const store = withSubscriptions([
    { id: "s1", user_id: "u-1", email: "jane@example.com", event_id: "e-1" },
  ]);
  assert.equal(
    store.findForEvent({ userId: "u-2", eventId: "e-1" }),
    null,
  );
  assert.equal(
    store.findForEvent({ email: "other@example.com", eventId: "e-1" }),
    null,
  );
  assert.equal(
    store.findForEvent({ userId: "u-1", eventId: "e-other" }),
    null,
  );
});

test("findForEvent: event_id mismatch rules the row out before user/email match", () => {
  // Ensures the event-id gate comes first: a perfect user/email match
  // under a different event_id must not resolve as venue-wide.
  const store = withSubscriptions([
    { id: "other-event", user_id: "u-1", email: "jane@example.com", event_id: "e-2" },
  ]);
  assert.equal(
    store.findForEvent({ userId: "u-1", eventId: null }),
    null,
  );
});
