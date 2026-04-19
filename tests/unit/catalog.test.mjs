// Catalog store selectors. The network-loading path in `init()` can't
// run without Supabase, but the selectors over the loaded rows are
// pure functions of `this.{events,news,articles,...}` and drive every
// event view. Seed regressions that flip sort order are caught here
// without needing the browser.

import test from "node:test";
import assert from "node:assert/strict";

import { catalogStore } from "../../web/assets/js/stores/catalog.js";

function withRows(rows) {
  const store = catalogStore();
  Object.assign(store, rows);
  return store;
}

test("eventById: returns the matching event or null", () => {
  const store = withRows({
    events: [
      { id: "nordbygg-2026", name: "Nordbygg" },
      { id: "estro-2026", name: "ESTRO" },
    ],
  });
  assert.equal(store.eventById("estro-2026").name, "ESTRO");
  assert.equal(store.eventById("missing"), null);
});

test("newsForEvent: filters by event_id and sorts by published_at descending", () => {
  const store = withRows({
    news: [
      { id: "n-old", event_id: "e1", published_at: "2026-01-01T00:00:00Z" },
      { id: "n-new", event_id: "e1", published_at: "2026-03-15T00:00:00Z" },
      { id: "n-mid", event_id: "e1", published_at: "2026-02-10T00:00:00Z" },
      { id: "other", event_id: "e2", published_at: "2026-05-01T00:00:00Z" },
    ],
  });
  assert.deepEqual(
    store.newsForEvent("e1").map((n) => n.id),
    ["n-new", "n-mid", "n-old"],
  );
  assert.deepEqual(store.newsForEvent("missing"), []);
});

test("newsForEvent: tolerates missing published_at without throwing", () => {
  const store = withRows({
    news: [
      { id: "a", event_id: "e1", published_at: "2026-02-10T00:00:00Z" },
      { id: "b", event_id: "e1" },
    ],
  });
  // The dated row sorts ahead of the one with no date because
  // localeCompare treats "" as lower.
  assert.deepEqual(
    store.newsForEvent("e1").map((n) => n.id),
    ["a", "b"],
  );
});

test("articlesForEvent: filters by event_id and preserves insertion order", () => {
  const store = withRows({
    articles: [
      { id: "x", event_id: "e1", title: "X" },
      { id: "y", event_id: "e2", title: "Y" },
      { id: "z", event_id: "e1", title: "Z" },
    ],
  });
  assert.deepEqual(
    store.articlesForEvent("e1").map((a) => a.id),
    ["x", "z"],
  );
});

test("programForEvent: sorts by day ascending then start_time ascending", () => {
  const store = withRows({
    program: [
      { id: "p3", event_id: "e1", day: "2026-04-22", start_time: "09:00" },
      { id: "p1", event_id: "e1", day: "2026-04-21", start_time: "10:30" },
      { id: "p2", event_id: "e1", day: "2026-04-21", start_time: "14:00" },
      { id: "other", event_id: "e2", day: "2026-04-21", start_time: "09:00" },
    ],
  });
  assert.deepEqual(
    store.programForEvent("e1").map((p) => p.id),
    ["p1", "p2", "p3"],
  );
});

test("programByDayForEvent: groups sessions per day in chronological order", () => {
  const store = withRows({
    program: [
      { id: "p3", event_id: "e1", day: "2026-04-22", start_time: "09:00" },
      { id: "p1", event_id: "e1", day: "2026-04-21", start_time: "10:30" },
      { id: "p2", event_id: "e1", day: "2026-04-21", start_time: "14:00" },
      { id: "other", event_id: "e2", day: "2026-04-21", start_time: "09:00" },
    ],
  });
  const groups = store.programByDayForEvent("e1");
  assert.deepEqual(
    groups.map((g) => g.day),
    ["2026-04-21", "2026-04-22"],
  );
  assert.deepEqual(
    groups[0].sessions.map((s) => s.id),
    ["p1", "p2"],
  );
  assert.deepEqual(
    groups[1].sessions.map((s) => s.id),
    ["p3"],
  );
});

test("programByDayForEvent: returns [] for an event with no sessions", () => {
  const store = withRows({
    program: [{ id: "p1", event_id: "e1", day: "2026-04-21", start_time: "09:00" }],
  });
  assert.deepEqual(store.programByDayForEvent("missing"), []);
});

test("exhibitorsForEvent: filters by event_id and sorts by name", () => {
  const store = withRows({
    exhibitors: [
      { id: "b", event_id: "e1", name: "Beta" },
      { id: "a", event_id: "e1", name: "Alpha" },
      { id: "c", event_id: "e1", name: "Gamma" },
      { id: "x", event_id: "e2", name: "Zzz" },
    ],
  });
  assert.deepEqual(
    store.exhibitorsForEvent("e1").map((e) => e.id),
    ["a", "b", "c"],
  );
});

test("exhibitorById / speakerById: look up by id across events", () => {
  const store = withRows({
    exhibitors: [
      { id: "acme", event_id: "e1", name: "Acme" },
      { id: "beta", event_id: "e2", name: "Beta" },
    ],
    speakers: [{ id: "s1", name: "Jane Doe" }],
  });
  assert.equal(store.exhibitorById("acme").name, "Acme");
  assert.equal(store.exhibitorById("missing"), null);
  assert.equal(store.speakerById("s1").name, "Jane Doe");
  assert.equal(store.speakerById("missing"), null);
});

test("addonsForEvent: filters by event_id and sorts by points_cost ascending", () => {
  const store = withRows({
    addons: [
      { id: "a", event_id: "e1", points_cost: 150, active: true },
      { id: "b", event_id: "e1", points_cost: 80, active: true },
      { id: "c", event_id: "e2", points_cost: 50, active: true },
      { id: "d", event_id: "e1", points_cost: 120, active: true },
    ],
  });
  assert.deepEqual(
    store.addonsForEvent("e1").map((a) => a.id),
    ["b", "d", "a"],
  );
  assert.deepEqual(store.addonsForEvent("missing"), []);
});

test("addonsForEvent: hides inactive rows", () => {
  const store = withRows({
    addons: [
      { id: "a", event_id: "e1", points_cost: 80, active: true },
      { id: "b", event_id: "e1", points_cost: 50, active: false },
    ],
  });
  assert.deepEqual(
    store.addonsForEvent("e1").map((a) => a.id),
    ["a"],
  );
});

test("addonById: looks up across events", () => {
  const store = withRows({
    addons: [
      { id: "a", event_id: "e1", points_cost: 80 },
      { id: "b", event_id: "e2", points_cost: 50 },
    ],
  });
  assert.equal(store.addonById("b").event_id, "e2");
  assert.equal(store.addonById("missing"), null);
});

test("activeMerchandise: filters inactive rows and sorts by points_cost", () => {
  const store = withRows({
    merchandise: [
      { id: "x", points_cost: 120, active: true },
      { id: "y", points_cost: 60, active: true },
      { id: "z", points_cost: 30, active: false },
    ],
  });
  assert.deepEqual(
    store.activeMerchandise().map((m) => m.id),
    ["y", "x"],
  );
});
