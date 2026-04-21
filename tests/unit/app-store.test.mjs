// appStore() in stores/app.js. router.test.mjs covers the pure
// parseHash / buildHash functions; this suite exercises the stateful
// navigation verbs (goCalendar, _requireAuth, goAuth, afterAuth,
// selectEvent, goEventSubview, selectExhibitor, backToExhibitors,
// startPurchase, goMe/goTickets/goPoints) and the _applyHash redirect
// for scroll-only subviews. The store reads and writes window.location
// and window.history, subscribes to hashchange, and delegates to
// Alpine.store("session" | "catalog" | "lang"), so each test stubs
// those globals and restores them on completion.

import test from "node:test";
import assert from "node:assert/strict";

import { appStore } from "../../web/assets/js/stores/app.js";

function makeFakeHistory() {
  const calls = [];
  return {
    calls,
    replaceState(state, title, url) {
      calls.push({ state, title, url });
    },
  };
}

// Stub `window` and `Alpine` just long enough to run `body`. The
// previous globals are always restored, even if `body` throws, so
// tests cannot leak state into each other.
//
// The fake location setter fires the registered `hashchange` listener
// whenever the hash actually changes, matching real-browser behavior.
// Without that, `_applyHash` would never run after `_navigate` wrote
// the new hash and store state would stay behind.
function makeFakeLocalStorage(initial = {}) {
  const store = { ...initial };
  return {
    _store: store,
    getItem(key) {
      return Object.prototype.hasOwnProperty.call(store, key)
        ? store[key]
        : null;
    },
    setItem(key, value) {
      store[key] = String(value);
    },
    removeItem(key) {
      delete store[key];
    },
  };
}

function withStubbedGlobals(
  {
    initialHash = "",
    signedIn = false,
    events = [],
    storedEventId = null,
    translate = (key, params) =>
      params ? `${key}:${JSON.stringify(params)}` : key,
  } = {},
  body,
) {
  const prevWindow = globalThis.window;
  const prevAlpine = globalThis.Alpine;
  const history = makeFakeHistory();
  const listeners = {};
  let hash = initialHash;
  const location = {
    get hash() {
      return hash;
    },
    set hash(value) {
      if (hash === value) return;
      hash = value;
      listeners.hashchange?.();
    },
    _set(value) {
      hash = value;
    },
  };
  const localStorage = makeFakeLocalStorage(
    storedEventId
      ? { "massanapp.selected_event_id": storedEventId }
      : {},
  );
  globalThis.window = {
    location,
    history,
    localStorage,
    addEventListener(event, handler) {
      listeners[event] = handler;
    },
  };
  const stores = {
    session: { isSignedIn: signedIn },
    catalog: {
      eventById(id) {
        return events.find((e) => e.id === id) ?? null;
      },
    },
    lang: { t: translate },
  };
  globalThis.Alpine = {
    store(id) {
      return stores[id];
    },
  };
  try {
    return body({ location, history, listeners, stores, localStorage });
  } finally {
    globalThis.window = prevWindow;
    globalThis.Alpine = prevAlpine;
  }
}

test("init(): applies the current hash and subscribes to hashchange", () => {
  withStubbedGlobals(
    { initialHash: "#/event/nordbygg-2026/program" },
    ({ listeners }) => {
      const store = appStore();
      store.init();
      assert.equal(store.view, "event");
      assert.equal(store.eventId, "nordbygg-2026");
      assert.equal(store.eventSubview, "program");
      assert.equal(typeof listeners.hashchange, "function");
    },
  );
});

test("init(): the hashchange listener re-applies the hash", () => {
  withStubbedGlobals({ initialHash: "#/" }, ({ location, listeners }) => {
    const store = appStore();
    store.init();
    assert.equal(store.view, "calendar");
    location._set("#/me");
    listeners.hashchange();
    assert.equal(store.view, "me");
  });
});

test("_applyHash: scroll-only subview (practical) collapses to home and records pendingScrollSection", () => {
  withStubbedGlobals(
    { initialHash: "#/event/nordbygg-2026/practical" },
    ({ history }) => {
      const store = appStore();
      store.init();
      assert.equal(store.view, "event");
      assert.equal(store.eventSubview, "home");
      assert.equal(store.pendingScrollSection, "practical");
      // history.replaceState rewrites the URL to the landing route so
      // the back button does not return to the collapsed path.
      assert.equal(history.calls.length, 1);
      assert.equal(history.calls[0].url, "#/event/nordbygg-2026");
    },
  );
});

test("_applyHash: scroll-only subview (newsletter) also collapses to home", () => {
  withStubbedGlobals(
    { initialHash: "#/event/nordbygg-2026/newsletter" },
    () => {
      const store = appStore();
      store.init();
      assert.equal(store.eventSubview, "home");
      assert.equal(store.pendingScrollSection, "newsletter");
    },
  );
});

test("_applyHash: does not replaceState when the URL already matches the landing route", () => {
  // Guard path: if the hash already normalizes to the landing route
  // the collapse should still record pendingScrollSection, but the
  // extra replaceState call is avoided. We fake this by manually
  // setting the location to the landing target before calling init.
  withStubbedGlobals(
    { initialHash: "#/event/nordbygg-2026" },
    ({ history }) => {
      const store = appStore();
      store.init();
      assert.equal(store.eventSubview, "home");
      assert.equal(store.pendingScrollSection, null);
      assert.equal(history.calls.length, 0);
    },
  );
});

test("goCalendar: writes the calendar hash", () => {
  withStubbedGlobals({ initialHash: "#/me" }, ({ location }) => {
    const store = appStore();
    store.init();
    store.goCalendar();
    assert.equal(location.hash, "#/");
    assert.equal(store.view, "calendar");
  });
});

test("goCalendar: no-op navigation still re-applies state via _applyHash", () => {
  // If the hash does not change (already on calendar) the setter
  // assignment does not fire hashchange, so _navigate falls through
  // to _applyHash directly to keep store state in sync.
  withStubbedGlobals({ initialHash: "#/" }, ({ location }) => {
    const store = appStore();
    store.init();
    store.view = "bogus";
    store.goCalendar();
    assert.equal(location.hash, "#/");
    assert.equal(store.view, "calendar");
  });
});

test("selectEvent: navigates to the event landing route with home subview", () => {
  withStubbedGlobals({}, ({ location }) => {
    const store = appStore();
    store.init();
    store.selectEvent("nordbygg-2026");
    assert.equal(location.hash, "#/event/nordbygg-2026");
    assert.equal(store.view, "event");
    assert.equal(store.eventId, "nordbygg-2026");
    assert.equal(store.eventSubview, "home");
  });
});

test("goEventSubview: navigates only when an event is selected", () => {
  withStubbedGlobals({}, ({ location }) => {
    const store = appStore();
    store.init();
    // No event yet → goEventSubview is a no-op.
    store.goEventSubview("program");
    assert.equal(location.hash, "");
    // After selecting an event, subview navigation works.
    store.selectEvent("nordbygg-2026");
    store.goEventSubview("program");
    assert.equal(location.hash, "#/event/nordbygg-2026/program");
    assert.equal(store.eventSubview, "program");
  });
});

test("selectExhibitor: requires an event and carries exhibitorId in the hash", () => {
  withStubbedGlobals({}, ({ location }) => {
    const store = appStore();
    store.init();
    store.selectExhibitor("acme-builders");
    assert.equal(location.hash, "");
    store.selectEvent("nordbygg-2026");
    store.selectExhibitor("acme-builders");
    assert.equal(
      location.hash,
      "#/event/nordbygg-2026/exhibitors/acme-builders",
    );
    assert.equal(store.exhibitorId, "acme-builders");
  });
});

test("backToExhibitors: drops exhibitorId and returns to the index", () => {
  withStubbedGlobals(
    { initialHash: "#/event/nordbygg-2026/exhibitors/acme-builders" },
    ({ location }) => {
      const store = appStore();
      store.init();
      assert.equal(store.exhibitorId, "acme-builders");
      store.backToExhibitors();
      assert.equal(location.hash, "#/event/nordbygg-2026/exhibitors");
      assert.equal(store.exhibitorId, null);
    },
  );
});

test("goMe: routes through auth when signed out and stashes the target", () => {
  withStubbedGlobals({ signedIn: false }, ({ location }) => {
    const store = appStore();
    store.init();
    store.goMe();
    assert.equal(location.hash, "#/auth");
    assert.deepEqual(store._preAuth, { view: "me" });
  });
});

test("goMe: navigates directly when already signed in", () => {
  withStubbedGlobals({ signedIn: true }, ({ location }) => {
    const store = appStore();
    store.init();
    store.goMe();
    assert.equal(location.hash, "#/me");
    assert.equal(store.view, "me");
  });
});

test("goTickets and goPoints follow the same auth gate", () => {
  withStubbedGlobals({ signedIn: false }, ({ location }) => {
    const store = appStore();
    store.init();
    store.goTickets();
    assert.equal(location.hash, "#/auth");
    assert.deepEqual(store._preAuth, { view: "tickets" });
    store.goPoints();
    assert.deepEqual(store._preAuth, { view: "points" });
  });
  withStubbedGlobals({ signedIn: true }, ({ location }) => {
    const store = appStore();
    store.init();
    store.goTickets();
    assert.equal(location.hash, "#/tickets");
    store.goPoints();
    assert.equal(location.hash, "#/points");
  });
});

test("startPurchase: no-op without an eventId", () => {
  withStubbedGlobals({ signedIn: true }, ({ location }) => {
    const store = appStore();
    store.init();
    store.startPurchase(null);
    assert.equal(location.hash, "");
    store.startPurchase(undefined);
    assert.equal(location.hash, "");
  });
});

test("startPurchase: routes through auth when signed out and stashes the event", () => {
  withStubbedGlobals({ signedIn: false }, ({ location }) => {
    const store = appStore();
    store.init();
    store.startPurchase("nordbygg-2026");
    assert.equal(location.hash, "#/auth");
    assert.deepEqual(store._preAuth, {
      view: "purchase",
      eventId: "nordbygg-2026",
    });
  });
});

test("startPurchase: navigates directly to the purchase route when signed in", () => {
  withStubbedGlobals({ signedIn: true }, ({ location }) => {
    const store = appStore();
    store.init();
    store.startPurchase("nordbygg-2026");
    assert.equal(location.hash, "#/event/nordbygg-2026/purchase");
    assert.equal(store.view, "purchase");
    assert.equal(store.eventId, "nordbygg-2026");
  });
});

test("goAuth: accepts a string view shortcut", () => {
  withStubbedGlobals({}, ({ location }) => {
    const store = appStore();
    store.init();
    store.goAuth("me");
    assert.equal(location.hash, "#/auth");
    assert.deepEqual(store._preAuth, { view: "me" });
  });
});

test("goAuth: accepts a full route object", () => {
  withStubbedGlobals({}, () => {
    const store = appStore();
    store.init();
    store.goAuth({ view: "purchase", eventId: "nordbygg-2026" });
    assert.deepEqual(store._preAuth, {
      view: "purchase",
      eventId: "nordbygg-2026",
    });
  });
});

test("goAuth: defaults to the calendar when called without a target", () => {
  withStubbedGlobals({}, () => {
    const store = appStore();
    store.init();
    store.goAuth();
    assert.deepEqual(store._preAuth, { view: "calendar" });
  });
});

test("afterAuth: resumes the stashed target and resets _preAuth", () => {
  withStubbedGlobals({}, ({ location }) => {
    const store = appStore();
    store.init();
    store._preAuth = { view: "purchase", eventId: "nordbygg-2026" };
    store.afterAuth();
    assert.equal(location.hash, "#/event/nordbygg-2026/purchase");
    assert.deepEqual(store._preAuth, { view: "calendar" });
  });
});

test("afterAuth: without a stashed target lands on calendar", () => {
  withStubbedGlobals({}, ({ location }) => {
    const store = appStore();
    store.init();
    store._preAuth = null;
    store.afterAuth();
    assert.equal(location.hash, "#/");
  });
});

test("chromeTitle: maps top-level views to translated titles", () => {
  withStubbedGlobals({}, () => {
    const store = appStore();
    store.init();
    assert.equal(store.chromeTitle(), "title.events");
    store.view = "auth";
    assert.equal(store.chromeTitle(), "title.sign_in");
    store.view = "me";
    assert.equal(store.chromeTitle(), "title.my_pages");
    store.view = "tickets";
    assert.equal(store.chromeTitle(), "title.my_tickets");
    store.view = "points";
    assert.equal(store.chromeTitle(), "title.points_shop");
  });
});

test("chromeTitle: purchase uses the event name when known", () => {
  withStubbedGlobals(
    { events: [{ id: "nordbygg-2026", name: "Nordbygg 2026" }] },
    () => {
      const store = appStore();
      store.init();
      store.view = "purchase";
      store.eventId = "nordbygg-2026";
      assert.equal(
        store.chromeTitle(),
        'title.get_tickets_for:{"name":"Nordbygg 2026"}',
      );
      store.eventId = "unknown";
      assert.equal(store.chromeTitle(), "title.get_tickets");
    },
  );
});

test("chromeTitle: event view uses the event name or a default", () => {
  withStubbedGlobals(
    { events: [{ id: "nordbygg-2026", name: "Nordbygg 2026" }] },
    () => {
      const store = appStore();
      store.init();
      store.view = "event";
      store.eventId = "nordbygg-2026";
      assert.equal(store.chromeTitle(), "Nordbygg 2026");
      store.eventId = "missing";
      assert.equal(store.chromeTitle(), "title.event_default");
    },
  );
});

test("_applyHash: navigating from an event to #/me preserves eventId", () => {
  // Bug #22: clicking My Pages from an event cleared the selected
  // event, hiding event-scoped nav links and losing the context
  // My Tickets uses to prioritize the current event's tickets.
  withStubbedGlobals(
    { initialHash: "#/event/nordbygg-2026", signedIn: true },
    ({ location, listeners }) => {
      const store = appStore();
      store.init();
      assert.equal(store.eventId, "nordbygg-2026");
      location._set("#/me");
      listeners.hashchange();
      assert.equal(store.view, "me");
      assert.equal(store.eventId, "nordbygg-2026");
    },
  );
});

test("_applyHash: auth and tickets routes also preserve the event context", () => {
  withStubbedGlobals(
    { initialHash: "#/event/nordbygg-2026" },
    ({ location, listeners }) => {
      const store = appStore();
      store.init();
      for (const hash of ["#/auth", "#/tickets", "#/points"]) {
        location._set(hash);
        listeners.hashchange();
        assert.equal(
          store.eventId,
          "nordbygg-2026",
          `eventId preserved for ${hash}`,
        );
      }
    },
  );
});

test("_applyHash: visiting the calendar clears the event context", () => {
  withStubbedGlobals(
    { initialHash: "#/event/nordbygg-2026" },
    ({ location, listeners, localStorage }) => {
      const store = appStore();
      store.init();
      assert.equal(
        localStorage.getItem("massanapp.selected_event_id"),
        "nordbygg-2026",
      );
      location._set("#/");
      listeners.hashchange();
      assert.equal(store.view, "calendar");
      assert.equal(store.eventId, null);
      assert.equal(
        localStorage.getItem("massanapp.selected_event_id"),
        null,
      );
    },
  );
});

test("_applyHash: #/me hydrates eventId from localStorage on first apply", () => {
  // A direct visit to #/me after a reload should still remember the
  // last selected event so chrome nav and ticket sorting stay scoped.
  withStubbedGlobals(
    {
      initialHash: "#/me",
      storedEventId: "nordbygg-2026",
    },
    () => {
      const store = appStore();
      store.init();
      assert.equal(store.view, "me");
      assert.equal(store.eventId, "nordbygg-2026");
    },
  );
});

test("selectEvent: persists the selected event id to localStorage", () => {
  withStubbedGlobals({}, ({ localStorage }) => {
    const store = appStore();
    store.init();
    store.selectEvent("nordbygg-2026");
    assert.equal(
      localStorage.getItem("massanapp.selected_event_id"),
      "nordbygg-2026",
    );
  });
});
