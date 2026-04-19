// parseHash / buildHash in stores/app.js own the URL hash routing
// table. Exercising them directly catches regressions in route
// parsing or serialization without spinning up Alpine and a browser.

import test from "node:test";
import assert from "node:assert/strict";

import {
  parseHash,
  buildHash,
} from "../../web/assets/js/stores/app.js";

test("parseHash: empty and root map to the calendar view", () => {
  assert.deepEqual(parseHash(""), { view: "calendar" });
  assert.deepEqual(parseHash("#"), { view: "calendar" });
  assert.deepEqual(parseHash("#/"), { view: "calendar" });
});

test("parseHash: top-level chrome routes", () => {
  assert.deepEqual(parseHash("#/auth"), { view: "auth" });
  assert.deepEqual(parseHash("#/me"), { view: "me" });
  assert.deepEqual(parseHash("#/tickets"), { view: "tickets" });
  assert.deepEqual(parseHash("#/points"), { view: "points" });
});

test("parseHash: unknown top-level route falls back to calendar", () => {
  assert.deepEqual(parseHash("#/does-not-exist"), { view: "calendar" });
});

test("parseHash: event home defaults the subview to 'home'", () => {
  assert.deepEqual(parseHash("#/event/nordbygg-2026"), {
    view: "event",
    eventId: "nordbygg-2026",
    eventSubview: "home",
    exhibitorId: null,
  });
});

test("parseHash: recognized event subviews round-trip", () => {
  for (const sub of [
    "home",
    "news",
    "articles",
    "program",
    "exhibitors",
    "practical",
    "food",
    "newsletter",
  ]) {
    assert.deepEqual(parseHash(`#/event/nordbygg-2026/${sub}`), {
      view: "event",
      eventId: "nordbygg-2026",
      eventSubview: sub,
      exhibitorId: null,
    });
  }
});

test("parseHash: unknown event subview collapses to 'home'", () => {
  assert.deepEqual(parseHash("#/event/nordbygg-2026/bogus"), {
    view: "event",
    eventId: "nordbygg-2026",
    eventSubview: "home",
    exhibitorId: null,
  });
});

test("parseHash: exhibitor detail carries both ids", () => {
  assert.deepEqual(
    parseHash("#/event/nordbygg-2026/exhibitors/acme-builders"),
    {
      view: "event",
      eventId: "nordbygg-2026",
      eventSubview: "exhibitors",
      exhibitorId: "acme-builders",
    },
  );
});

test("parseHash: purchase deep link", () => {
  assert.deepEqual(parseHash("#/event/nordbygg-2026/purchase"), {
    view: "purchase",
    eventId: "nordbygg-2026",
  });
});

test("buildHash: top-level chrome routes", () => {
  assert.equal(buildHash({ view: "calendar" }), "#/");
  assert.equal(buildHash({ view: "auth" }), "#/auth");
  assert.equal(buildHash({ view: "me" }), "#/me");
  assert.equal(buildHash({ view: "tickets" }), "#/tickets");
  assert.equal(buildHash({ view: "points" }), "#/points");
});

test("buildHash: event home suppresses the 'home' segment", () => {
  assert.equal(
    buildHash({
      view: "event",
      eventId: "nordbygg-2026",
      eventSubview: "home",
    }),
    "#/event/nordbygg-2026",
  );
});

test("buildHash: event subview emits the subview segment", () => {
  assert.equal(
    buildHash({
      view: "event",
      eventId: "nordbygg-2026",
      eventSubview: "program",
    }),
    "#/event/nordbygg-2026/program",
  );
});

test("buildHash: exhibitor detail requires both ids", () => {
  assert.equal(
    buildHash({
      view: "event",
      eventId: "nordbygg-2026",
      eventSubview: "exhibitors",
      exhibitorId: "acme-builders",
    }),
    "#/event/nordbygg-2026/exhibitors/acme-builders",
  );
  // Without an exhibitorId we stay on the exhibitors index.
  assert.equal(
    buildHash({
      view: "event",
      eventId: "nordbygg-2026",
      eventSubview: "exhibitors",
    }),
    "#/event/nordbygg-2026/exhibitors",
  );
});

test("buildHash: purchase deep link", () => {
  assert.equal(
    buildHash({ view: "purchase", eventId: "nordbygg-2026" }),
    "#/event/nordbygg-2026/purchase",
  );
});

test("buildHash: purchase without an eventId falls back to calendar", () => {
  assert.equal(buildHash({ view: "purchase" }), "#/");
});

test("parseHash / buildHash round-trip", () => {
  const routes = [
    "#/",
    "#/auth",
    "#/me",
    "#/tickets",
    "#/points",
    "#/event/nordbygg-2026",
    "#/event/nordbygg-2026/program",
    "#/event/nordbygg-2026/exhibitors",
    "#/event/nordbygg-2026/exhibitors/acme-builders",
    "#/event/nordbygg-2026/purchase",
  ];
  for (const hash of routes) {
    assert.equal(buildHash(parseHash(hash)), hash, `round-trip ${hash}`);
  }
});
