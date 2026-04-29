// newsletterSignup() in views/newsletter-signup.js drives the
// in-event Newsletter signup form. The form's job is to pre-fill the
// email from the signed-in user, re-hydrate any existing
// (user, event) subscription from the newsletter store, guard against
// concurrent submits, fire `simulatedEmail("newsletter_confirmation")`
// on success, and flip into / out of the submitted state. All of those
// are pure state transitions that are worth pinning down without a
// browser.
//
// Follows the Alpine.store stub pattern from auth.test.mjs and
// newsletter-preferences.test.mjs — no browser, no Supabase, no Alpine
// runtime. `simulatedEmail` is exercised through its console.info side
// effect (the same hook the smoke suite asserts on); see
// email.test.mjs for the host allowlist.

import test from "node:test";
import assert from "node:assert/strict";

import { newsletterSignup } from "../../web/assets/js/views/newsletter-signup.js";
import {
  NEWSLETTER_PREF_KEYS,
  defaultNewsletterPreferences,
} from "../../web/assets/js/util/newsletter.js";
import { withAlpine } from "./_alpine.mjs";

async function captureConsoleInfo(fn) {
  const original = console.info;
  const calls = [];
  console.info = (...args) => calls.push(args);
  try {
    await fn();
  } finally {
    console.info = original;
  }
  return calls;
}

function langStub() {
  return {
    current: "en",
    t: (key) => key,
    pick(value) {
      if (value == null) return "";
      if (typeof value === "string") return value;
      return value.en ?? "";
    },
  };
}

function makeStores({
  user = null,
  eventId = "nordbygg-2026",
  event = { id: "nordbygg-2026", name: "Nordbygg 2026" },
  existing = null,
  subscribe,
  subscribeCalls = [],
} = {}) {
  return {
    lang: langStub(),
    session: { user },
    app: { eventId },
    catalog: {
      eventById(id) {
        return event && id === event.id ? event : null;
      },
    },
    newsletter: {
      findForEvent() {
        // Tests set `existing` directly and assume the view reads it
        // for the current (user, event) pair.
        return existing;
      },
      async subscribe(payload) {
        subscribeCalls.push(payload);
        if (subscribe) return subscribe(payload);
        // Echo the payload back in the shape the store's happy path
        // returns for a signed-in subscriber (a synthetic id plus the
        // normalized fields).
        return {
          id: "sub-1",
          user_id: payload.userId ?? null,
          email: payload.email,
          event_id: payload.eventId ?? null,
          preferences: payload.preferences,
        };
      },
    },
    subscribeCalls,
  };
}

test("initial state: empty form, default preferences, not submitted, no error", () => {
  const view = newsletterSignup();
  assert.equal(view.email, "");
  assert.equal(view.submitted, false);
  assert.equal(view.processing, false);
  assert.equal(view.error, "");
  // The view freezes the topic list onto the component so templates
  // can bind without reaching back into util/newsletter.js.
  assert.equal(view.topics.length, NEWSLETTER_PREF_KEYS.length);
  assert.deepEqual(view.preferences, defaultNewsletterPreferences());
});

test("_hydrate (signed out): email empty, defaults restored, submitted cleared", async () => {
  await withAlpine(makeStores({ user: null }), () => {
    const view = newsletterSignup();
    view.error = "stale";
    view.submitted = true;
    view._hydrate();
    assert.equal(view.email, "");
    assert.equal(view.submitted, false);
    assert.equal(view.error, "");
    assert.deepEqual(view.preferences, defaultNewsletterPreferences());
  });
});

test("_hydrate (signed in, no existing row): pre-fills email from the user, defaults preferences", async () => {
  await withAlpine(
    makeStores({
      user: { id: "u-1", email: "visitor@example.com" },
      existing: null,
    }),
    () => {
      const view = newsletterSignup();
      view._hydrate();
      assert.equal(view.email, "visitor@example.com");
      assert.equal(view.submitted, false);
      assert.deepEqual(view.preferences, defaultNewsletterPreferences());
    },
  );
});

test("_hydrate (signed in, existing row): restores email + preferences and marks submitted", async () => {
  const stored = { program_highlights: false, news: true, exhibitor_updates: false };
  await withAlpine(
    makeStores({
      user: { id: "u-1", email: "login@example.com" },
      existing: {
        id: "sub-1",
        user_id: "u-1",
        email: "subscribed@example.com",
        event_id: "nordbygg-2026",
        preferences: stored,
      },
    }),
    () => {
      const view = newsletterSignup();
      view._hydrate();
      // The stored email wins over the user's current email so the
      // visitor sees the address they actually subscribed with.
      assert.equal(view.email, "subscribed@example.com");
      assert.equal(view.submitted, true);
      assert.deepEqual(view.preferences, stored);
    },
  );
});

test("_hydrate: the restored preferences object is a copy, not a shared reference", async () => {
  const stored = { program_highlights: false, news: true, exhibitor_updates: false };
  await withAlpine(
    makeStores({
      user: { id: "u-1", email: "login@example.com" },
      existing: {
        id: "sub-1",
        user_id: "u-1",
        email: "sub@example.com",
        event_id: "nordbygg-2026",
        preferences: stored,
      },
    }),
    () => {
      const view = newsletterSignup();
      view._hydrate();
      view.preferences.program_highlights = true;
      assert.equal(stored.program_highlights, false);
    },
  );
});

test("event(): returns the catalog event for the current app.eventId", async () => {
  await withAlpine(
    makeStores({
      eventId: "nordbygg-2026",
      event: { id: "nordbygg-2026", name: "Nordbygg 2026" },
    }),
    () => {
      const view = newsletterSignup();
      assert.deepEqual(view.event(), {
        id: "nordbygg-2026",
        name: "Nordbygg 2026",
      });
    },
  );
});

test("event(): null when no event is selected", async () => {
  await withAlpine(makeStores({ eventId: null }), () => {
    const view = newsletterSignup();
    assert.equal(view.event(), null);
  });
});

test("submit (signed in): forwards email, userId, eventId, and preferences to the store", async () => {
  const stores = makeStores({
    user: { id: "u-1", email: "visitor@example.com" },
  });
  await withAlpine(stores, async () => {
    await captureConsoleInfo(async () => {
      const view = newsletterSignup();
      view.email = "visitor@example.com";
      view.preferences = {
        program_highlights: true,
        news: false,
        exhibitor_updates: true,
      };
      await view.submit();
      assert.equal(stores.subscribeCalls.length, 1);
      assert.deepEqual(stores.subscribeCalls[0], {
        email: "visitor@example.com",
        userId: "u-1",
        eventId: "nordbygg-2026",
        preferences: {
          program_highlights: true,
          news: false,
          exhibitor_updates: true,
        },
      });
      assert.equal(view.submitted, true);
      assert.equal(view.processing, false);
      assert.equal(view.error, "");
    });
  });
});

test("submit (anonymous): passes userId null; the store handles the anon insert path", async () => {
  const stores = makeStores({ user: null });
  await withAlpine(stores, async () => {
    await captureConsoleInfo(async () => {
      const view = newsletterSignup();
      view.email = "anon@example.com";
      await view.submit();
      assert.equal(stores.subscribeCalls.length, 1);
      assert.equal(stores.subscribeCalls[0].userId, null);
      assert.equal(stores.subscribeCalls[0].email, "anon@example.com");
      assert.equal(view.submitted, true);
    });
  });
});

test("submit: fires simulatedEmail('newsletter_confirmation') with the record + catalog event name", async () => {
  const stores = makeStores({
    user: { id: "u-1", email: "visitor@example.com" },
    event: { id: "nordbygg-2026", name: "Nordbygg 2026" },
  });
  await withAlpine(stores, async () => {
    const calls = [];
    const original = console.info;
    console.info = (...args) => calls.push(args);
    try {
      const view = newsletterSignup();
      view.email = "visitor@example.com";
      await view.submit();
    } finally {
      console.info = original;
    }
    assert.equal(calls.length, 1);
    assert.equal(calls[0][0], "[simulatedEmail]");
    assert.equal(calls[0][1], "newsletter_confirmation");
    const payload = calls[0][2];
    assert.equal(payload.to, "visitor@example.com");
    assert.equal(payload.user_id, "u-1");
    assert.equal(payload.event_id, "nordbygg-2026");
    assert.equal(payload.event_name, "Nordbygg 2026");
    assert.deepEqual(payload.preferences, defaultNewsletterPreferences());
  });
});

test("submit: simulatedEmail payload carries event_name null when the event cannot be resolved", async () => {
  const stores = makeStores({
    user: { id: "u-1", email: "v@example.com" },
    eventId: "missing-evt",
    event: null,
  });
  await withAlpine(stores, async () => {
    const calls = [];
    const original = console.info;
    console.info = (...args) => calls.push(args);
    try {
      const view = newsletterSignup();
      view.email = "v@example.com";
      await view.submit();
    } finally {
      console.info = original;
    }
    assert.equal(calls.length, 1);
    assert.equal(calls[0][2].event_name, null);
  });
});

test("submit: surfaces the store error in view.error and does not mark submitted", async () => {
  const stores = makeStores({
    user: { id: "u-1", email: "v@example.com" },
    subscribe: () => {
      throw new Error("network failed");
    },
  });
  await withAlpine(stores, async () => {
    const view = newsletterSignup();
    view.email = "v@example.com";
    await view.submit();
    assert.equal(view.error, "network failed");
    assert.equal(view.submitted, false);
    assert.equal(view.processing, false);
  });
});

test("submit: falls back to newsletter.err_signup when the thrown error has no message", async () => {
  const stores = makeStores({
    user: { id: "u-1", email: "v@example.com" },
    subscribe: () => {
      const err = new Error();
      err.message = "";
      throw err;
    },
  });
  await withAlpine(stores, async () => {
    const view = newsletterSignup();
    view.email = "v@example.com";
    await view.submit();
    assert.equal(view.error, "newsletter.err_signup");
    assert.equal(view.submitted, false);
  });
});

test("submit: ignores concurrent calls while processing is true", async () => {
  let release;
  const inflight = new Promise((r) => {
    release = r;
  });
  const stores = makeStores({
    user: { id: "u-1", email: "v@example.com" },
    subscribe: () => inflight,
  });
  await withAlpine(stores, async () => {
    const calls = [];
    const original = console.info;
    console.info = (...args) => calls.push(args);
    try {
      const view = newsletterSignup();
      view.email = "v@example.com";
      const first = view.submit();
      // Second call while the first is in flight must early-return
      // and leave the store-call count at 1.
      const second = view.submit();
      await second;
      assert.equal(stores.subscribeCalls.length, 1);
      release({
        id: "sub-1",
        user_id: "u-1",
        email: "v@example.com",
        event_id: "nordbygg-2026",
        preferences: defaultNewsletterPreferences(),
      });
      await first;
      assert.equal(stores.subscribeCalls.length, 1);
    } finally {
      console.info = original;
    }
  });
});

test("submit: clears any previous error before calling the store", async () => {
  const stores = makeStores({
    user: { id: "u-1", email: "v@example.com" },
  });
  await withAlpine(stores, async () => {
    await captureConsoleInfo(async () => {
      const view = newsletterSignup();
      view.error = "leftover";
      view.email = "v@example.com";
      await view.submit();
      assert.equal(view.error, "");
    });
  });
});

test("editAgain(): flips submitted back to false so the form becomes editable again", () => {
  const view = newsletterSignup();
  view.submitted = true;
  view.editAgain();
  assert.equal(view.submitted, false);
});
