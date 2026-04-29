// Pure helpers behind the calendar view. The view wires them to
// `$store.catalog.events` and `$store.filters`; the suite below checks
// the behavior without Alpine so filter regressions fail fast.

import test from "node:test";
import assert from "node:assert/strict";

import {
  PAST_EVENT_GRACE_DAYS,
  todayLocalIso,
  shiftIsoDate,
  isCalendarVisible,
  isOngoingOrUpcoming,
  calendarVisibleEvents,
  eventMatchesQuery,
  filterEvents,
} from "../../web/assets/js/util/calendar.js";

test("PAST_EVENT_GRACE_DAYS: keeps events for three weeks after they end", () => {
  assert.equal(PAST_EVENT_GRACE_DAYS, 21);
});

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

test("shiftIsoDate: subtracts days across a month boundary", () => {
  assert.equal(shiftIsoDate("2026-04-21", -21), "2026-03-31");
});

test("shiftIsoDate: adds days across a year boundary", () => {
  assert.equal(shiftIsoDate("2026-12-25", 10), "2027-01-04");
});

test("shiftIsoDate: zero shift is the identity", () => {
  assert.equal(shiftIsoDate("2026-04-21", 0), "2026-04-21");
});

test("isCalendarVisible: event ending today is visible", () => {
  assert.equal(
    isCalendarVisible(
      { start_date: "2026-04-20", end_date: "2026-04-21" },
      "2026-04-21",
    ),
    true,
  );
});

test("isCalendarVisible: event ended within grace window stays visible", () => {
  // Ended 5 days ago — within the 21-day grace window.
  assert.equal(
    isCalendarVisible(
      { start_date: "2026-04-15", end_date: "2026-04-16" },
      "2026-04-21",
    ),
    true,
  );
});

test("isCalendarVisible: event ended exactly on the cutoff stays visible", () => {
  // 21 days before today — still inside the inclusive cutoff.
  assert.equal(
    isCalendarVisible(
      { start_date: "2026-03-30", end_date: "2026-03-31" },
      "2026-04-21",
    ),
    true,
  );
});

test("isCalendarVisible: event ended more than 21 days ago drops off", () => {
  // 22 days before today — past the cutoff.
  assert.equal(
    isCalendarVisible(
      { start_date: "2026-03-29", end_date: "2026-03-30" },
      "2026-04-21",
    ),
    false,
  );
});

test("isCalendarVisible: single-day event in the future is visible", () => {
  assert.equal(
    isCalendarVisible({ start_date: "2026-05-01" }, "2026-04-21"),
    true,
  );
});

test("isCalendarVisible: single-day event ended yesterday stays visible", () => {
  // No end_date — fall back to start_date for the cutoff.
  assert.equal(
    isCalendarVisible({ start_date: "2026-04-20" }, "2026-04-21"),
    true,
  );
});

test("isCalendarVisible: events missing dates stay visible", () => {
  assert.equal(isCalendarVisible({}, "2026-04-21"), true);
  assert.equal(
    isCalendarVisible({ start_date: null, end_date: null }, "2026-04-21"),
    true,
  );
});

test("isOngoingOrUpcoming: ongoing event is upcoming-or-ongoing", () => {
  assert.equal(
    isOngoingOrUpcoming(
      { start_date: "2026-04-20", end_date: "2026-04-22" },
      "2026-04-21",
    ),
    true,
  );
});

test("isOngoingOrUpcoming: event that already ended is not", () => {
  assert.equal(
    isOngoingOrUpcoming(
      { start_date: "2026-04-19", end_date: "2026-04-20" },
      "2026-04-21",
    ),
    false,
  );
});

test("isOngoingOrUpcoming: dateless event is treated as ongoing", () => {
  assert.equal(isOngoingOrUpcoming({}, "2026-04-21"), true);
});

test("calendarVisibleEvents: keeps future, ongoing, recently-ended, and dateless; drops long-past", () => {
  const events = [
    { id: "long-past", start_date: "2025-01-01", end_date: "2025-01-02" },
    { id: "future", start_date: "2026-05-01", end_date: "2026-05-02" },
    { id: "today", start_date: "2026-04-21", end_date: "2026-04-21" },
    { id: "recently-ended", start_date: "2026-04-10", end_date: "2026-04-12" },
    { id: "dateless" },
  ];
  const out = calendarVisibleEvents(events, "2026-04-21").map((e) => e.id);
  assert.deepEqual(
    out.sort(),
    ["dateless", "future", "recently-ended", "today"],
  );
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
  const out = filterEvents(events, { type: "Trade fair" }, "2026-03-01");
  assert.deepEqual(out.map((e) => e.id), ["a"]);
});

test("filterEvents: category filter keeps matching rows", () => {
  const events = [
    { id: "a", name: "A", type: "Trade fair", category: "Industry", start_date: "2026-04-01" },
    { id: "b", name: "B", type: "Trade fair", category: "Food & drink", start_date: "2026-05-01" },
  ];
  const out = filterEvents(events, { category: "Food & drink" }, "2026-03-01");
  assert.deepEqual(out.map((e) => e.id), ["b"]);
});

test("filterEvents: month filter uses monthLabel and en-GB locale", () => {
  // In the Node test env (no Alpine), monthLabel falls back to en-GB
  // per the existing dates.test.mjs — April 2026 for a 2026-04-xx date.
  const events = [
    { id: "april", name: "April event", start_date: "2026-04-21" },
    { id: "may", name: "May event", start_date: "2026-05-15" },
  ];
  const out = filterEvents(events, { month: "April 2026" }, "2026-03-01");
  assert.deepEqual(out.map((e) => e.id), ["april"]);
});

test("filterEvents: query filter narrows by name or summary", () => {
  const events = [
    { id: "nord", name: "Nordbygg 2026", summary: "Nordic construction fair", start_date: "2026-04-01" },
    { id: "estro", name: "ESTRO 2026", summary: "Radiation oncology congress", start_date: "2026-05-01" },
  ];
  assert.deepEqual(
    filterEvents(events, { query: "construction" }, "2026-03-01").map((e) => e.id),
    ["nord"],
  );
  assert.deepEqual(
    filterEvents(events, { query: "ESTRO" }, "2026-03-01").map((e) => e.id),
    ["estro"],
  );
});

test("filterEvents: filters combine (AND) across fields", () => {
  const events = [
    { id: "a", name: "Nordbygg", type: "Trade fair", category: "Industry", start_date: "2026-04-01" },
    { id: "b", name: "Nordbygg", type: "Congress", category: "Industry", start_date: "2026-05-01" },
    { id: "c", name: "Other", type: "Trade fair", category: "Industry", start_date: "2026-06-01" },
  ];
  const out = filterEvents(
    events,
    { type: "Trade fair", category: "Industry", query: "Nordbygg" },
    "2026-03-01",
  );
  assert.deepEqual(out.map((e) => e.id), ["a"]);
});

test("filterEvents: ongoing/upcoming events sort by start_date ascending", () => {
  // Pin `today` before all events so each one is upcoming and the
  // recently-ended partition stays empty.
  const events = [
    { id: "late", name: "Late", start_date: "2026-06-01" },
    { id: "early", name: "Early", start_date: "2026-01-01" },
    { id: "mid", name: "Mid", start_date: "2026-03-01" },
  ];
  const out = filterEvents(events, {}, "2025-12-01");
  assert.deepEqual(out.map((e) => e.id), ["early", "mid", "late"]);
});

test("filterEvents: empty filters returns every event sorted ascending when all are upcoming", () => {
  const events = [
    { id: "b", name: "B", start_date: "2026-02-01" },
    { id: "a", name: "A", start_date: "2026-01-01" },
  ];
  const out = filterEvents(events, {}, "2025-12-01");
  assert.deepEqual(out.map((e) => e.id), ["a", "b"]);
});

test("filterEvents: missing start_date sorts to the front stably", () => {
  const events = [
    { id: "dated", name: "Dated", start_date: "2026-02-01" },
    { id: "dateless", name: "Dateless" },
  ];
  // Pin today so the dated event is upcoming. Dateless events are
  // treated as ongoing; both end up in the upcoming partition.
  const out = filterEvents(events, {}, "2025-12-01");
  // `localeCompare` treats the empty string as less than any non-empty,
  // so the dateless row lands first — stable and deterministic.
  assert.deepEqual(out.map((e) => e.id), ["dateless", "dated"]);
});

test("filterEvents: recently-ended events sort alongside upcoming by start_date (issue #26 follow-up)", () => {
  const events = [
    { id: "ended-7d", name: "Ended 7d ago", start_date: "2026-04-13", end_date: "2026-04-14" },
    { id: "future-jun", name: "Future Jun", start_date: "2026-06-01", end_date: "2026-06-02" },
    { id: "ended-3d", name: "Ended 3d ago", start_date: "2026-04-17", end_date: "2026-04-18" },
    { id: "future-may", name: "Future May", start_date: "2026-05-01", end_date: "2026-05-02" },
  ];
  // Today: 2026-04-21. The partition uses today − 21 days = 2026-03-31,
  // so all four events fall in the upcoming bucket and sort by
  // `start_date` asc — recently-ended events keep the on-top position
  // they would have had three weeks ago.
  const out = filterEvents(events, {}, "2026-04-21").map((e) => e.id);
  assert.deepEqual(out, ["ended-7d", "ended-3d", "future-may", "future-jun"]);
});

test("filterEvents: events ending more than 21 days ago drop into the ended partition", () => {
  // `filterEvents` itself does not enforce visibility (the view
  // composes `calendarVisibleEvents` first). With the shifted partition
  // today (= today − 21 days), only events that ended >21 days ago
  // land in the ended bucket, sorted by end_date desc.
  const events = [
    { id: "long-past", name: "Long past", start_date: "2026-03-01", end_date: "2026-03-02" },
    { id: "ended-3d", name: "Ended 3d ago", start_date: "2026-04-17", end_date: "2026-04-18" },
    { id: "future-may", name: "Future May", start_date: "2026-05-01", end_date: "2026-05-02" },
  ];
  const out = filterEvents(events, {}, "2026-04-21").map((e) => e.id);
  assert.deepEqual(out, ["ended-3d", "future-may", "long-past"]);
});
