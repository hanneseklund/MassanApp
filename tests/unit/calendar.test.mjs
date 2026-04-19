// Pure helpers behind the calendar view. The view wires them to
// `$store.catalog.events` and `$store.filters`; the suite below checks
// the behavior without Alpine so filter regressions fail fast.

import test from "node:test";
import assert from "node:assert/strict";

import {
  todayLocalIso,
  isUpcoming,
  upcomingEvents,
  eventMatchesQuery,
  filterEvents,
} from "../../web/assets/js/util/calendar.js";

test("todayLocalIso: formats YYYY-MM-DD in local time", () => {
  // Build a date in the local timezone so the assertion is independent
  // of where the suite runs.
  const d = new Date(2026, 3, 21, 10, 30); // 2026-04-21 local
  assert.equal(todayLocalIso(d), "2026-04-21");
});

test("todayLocalIso: zero-pads single-digit month and day", () => {
  const d = new Date(2026, 0, 5, 0, 0); // 2026-01-05 local
  assert.equal(todayLocalIso(d), "2026-01-05");
});

test("isUpcoming: event ending today is upcoming", () => {
  assert.equal(
    isUpcoming({ start_date: "2026-04-20", end_date: "2026-04-21" }, "2026-04-21"),
    true,
  );
});

test("isUpcoming: event that already ended is not upcoming", () => {
  assert.equal(
    isUpcoming({ start_date: "2026-04-19", end_date: "2026-04-20" }, "2026-04-21"),
    false,
  );
});

test("isUpcoming: single-day event in the future is upcoming", () => {
  assert.equal(
    isUpcoming({ start_date: "2026-05-01" }, "2026-04-21"),
    true,
  );
});

test("isUpcoming: events missing dates stay visible", () => {
  assert.equal(isUpcoming({}, "2026-04-21"), true);
  assert.equal(isUpcoming({ start_date: null, end_date: null }, "2026-04-21"), true);
});

test("upcomingEvents: drops events that already ended, keeps future and dateless ones", () => {
  const events = [
    { id: "past", start_date: "2025-01-01", end_date: "2025-01-02" },
    { id: "future", start_date: "2026-05-01", end_date: "2026-05-02" },
    { id: "today", start_date: "2026-04-21", end_date: "2026-04-21" },
    { id: "dateless" },
  ];
  const out = upcomingEvents(events, "2026-04-21").map((e) => e.id);
  assert.deepEqual(out.sort(), ["dateless", "future", "today"]);
});

test("eventMatchesQuery: empty query matches everything", () => {
  assert.equal(eventMatchesQuery({ name: "Anything", summary: "" }, ""), true);
  assert.equal(eventMatchesQuery({ name: "Anything" }, "   "), true);
  assert.equal(eventMatchesQuery({ name: "Anything" }, null), true);
  assert.equal(eventMatchesQuery({ name: "Anything" }, undefined), true);
});

test("eventMatchesQuery: matches name case-insensitively", () => {
  assert.equal(
    eventMatchesQuery({ name: "Nordbygg 2026", summary: "" }, "NORDBYGG"),
    true,
  );
});

test("eventMatchesQuery: matches summary case-insensitively", () => {
  assert.equal(
    eventMatchesQuery({ name: "Event", summary: "Nordic construction fair" }, "construction"),
    true,
  );
});

test("eventMatchesQuery: no match on either field returns false", () => {
  assert.equal(
    eventMatchesQuery({ name: "Foo", summary: "Bar" }, "xyz"),
    false,
  );
});

test("eventMatchesQuery: missing summary is tolerated", () => {
  assert.equal(
    eventMatchesQuery({ name: "Nordbygg" }, "nordbygg"),
    true,
  );
  assert.equal(eventMatchesQuery({ name: "Foo" }, "nordbygg"), false);
});

test("filterEvents: type filter keeps matching rows", () => {
  const events = [
    { id: "a", name: "A", type: "Trade fair", category: "Industry", start_date: "2026-04-01" },
    { id: "b", name: "B", type: "Congress", category: "Health & Medicine", start_date: "2026-05-01" },
  ];
  const out = filterEvents(events, { type: "Trade fair" });
  assert.deepEqual(out.map((e) => e.id), ["a"]);
});

test("filterEvents: category filter keeps matching rows", () => {
  const events = [
    { id: "a", name: "A", type: "Trade fair", category: "Industry", start_date: "2026-04-01" },
    { id: "b", name: "B", type: "Trade fair", category: "Food & drink", start_date: "2026-05-01" },
  ];
  const out = filterEvents(events, { category: "Food & drink" });
  assert.deepEqual(out.map((e) => e.id), ["b"]);
});

test("filterEvents: month filter uses monthLabel and en-GB locale", () => {
  // In the Node test env (no Alpine), monthLabel falls back to en-GB
  // per the existing dates.test.mjs — April 2026 for a 2026-04-xx date.
  const events = [
    { id: "april", name: "April event", start_date: "2026-04-21" },
    { id: "may", name: "May event", start_date: "2026-05-15" },
  ];
  const out = filterEvents(events, { month: "April 2026" });
  assert.deepEqual(out.map((e) => e.id), ["april"]);
});

test("filterEvents: query filter narrows by name or summary", () => {
  const events = [
    { id: "nord", name: "Nordbygg 2026", summary: "Nordic construction fair", start_date: "2026-04-01" },
    { id: "estro", name: "ESTRO 2026", summary: "Radiation oncology congress", start_date: "2026-05-01" },
  ];
  assert.deepEqual(
    filterEvents(events, { query: "construction" }).map((e) => e.id),
    ["nord"],
  );
  assert.deepEqual(
    filterEvents(events, { query: "ESTRO" }).map((e) => e.id),
    ["estro"],
  );
});

test("filterEvents: filters combine (AND) across fields", () => {
  const events = [
    { id: "a", name: "Nordbygg", type: "Trade fair", category: "Industry", start_date: "2026-04-01" },
    { id: "b", name: "Nordbygg", type: "Congress", category: "Industry", start_date: "2026-05-01" },
    { id: "c", name: "Other", type: "Trade fair", category: "Industry", start_date: "2026-06-01" },
  ];
  const out = filterEvents(events, {
    type: "Trade fair",
    category: "Industry",
    query: "Nordbygg",
  });
  assert.deepEqual(out.map((e) => e.id), ["a"]);
});

test("filterEvents: sorts by start_date ascending", () => {
  const events = [
    { id: "late", name: "Late", start_date: "2026-06-01" },
    { id: "early", name: "Early", start_date: "2026-01-01" },
    { id: "mid", name: "Mid", start_date: "2026-03-01" },
  ];
  const out = filterEvents(events, {});
  assert.deepEqual(out.map((e) => e.id), ["early", "mid", "late"]);
});

test("filterEvents: empty filters returns every event sorted", () => {
  const events = [
    { id: "b", name: "B", start_date: "2026-02-01" },
    { id: "a", name: "A", start_date: "2026-01-01" },
  ];
  const out = filterEvents(events, {});
  assert.deepEqual(out.map((e) => e.id), ["a", "b"]);
});

test("filterEvents: missing start_date sorts to the front stably", () => {
  const events = [
    { id: "dated", name: "Dated", start_date: "2026-02-01" },
    { id: "dateless", name: "Dateless" },
  ];
  const out = filterEvents(events, {});
  // `localeCompare` treats the empty string as less than any non-empty,
  // so the dateless row lands first — stable and deterministic.
  assert.deepEqual(out.map((e) => e.id), ["dateless", "dated"]);
});
