// Formatters in util/dates.js are used by the calendar, program, news,
// and ticket views. They read the active UI locale from the Alpine
// store when available and fall back to `en-GB` otherwise. Without
// Alpine in the Node environment the fallback locale is what applies
// here.

import test from "node:test";
import assert from "node:assert/strict";

import {
  formatDates,
  formatShortDate,
  formatDayHeading,
  monthLabel,
  uniqueSorted,
} from "../../web/assets/js/util/dates.js";

test("formatDates: single-day event renders one date", () => {
  const out = formatDates({
    start_date: "2026-04-21",
    end_date: "2026-04-21",
  });
  assert.match(out, /21 Apr 2026/);
});

test("formatDates: multi-day range within one month omits the repeated month", () => {
  const out = formatDates({
    start_date: "2026-04-21",
    end_date: "2026-04-24",
  });
  // The start should be bare ("21") while the end carries the month.
  assert.match(out, /^\s*21\s+–/);
  assert.match(out, /24 Apr 2026/);
});

test("formatDates: range spanning months keeps month on both ends", () => {
  const out = formatDates({
    start_date: "2026-04-29",
    end_date: "2026-05-02",
  });
  assert.match(out, /29 Apr/);
  assert.match(out, /2 May 2026/);
});

test("formatDates: missing start_date returns empty string", () => {
  assert.equal(formatDates({}), "");
  assert.equal(formatDates(null), "");
  assert.equal(formatDates(undefined), "");
});

test("formatShortDate: ISO string -> localized short date", () => {
  assert.match(formatShortDate("2026-01-15T10:00:00Z"), /15 Jan 2026/);
});

test("formatShortDate: empty string stays empty", () => {
  assert.equal(formatShortDate(""), "");
  assert.equal(formatShortDate(null), "");
});

test("formatDayHeading: includes weekday and month", () => {
  const out = formatDayHeading("2026-04-21");
  // en-GB: "Tuesday, 21 April"
  assert.match(out, /Tuesday/);
  assert.match(out, /April/);
});

test("monthLabel: returns month + year", () => {
  assert.match(monthLabel("2026-04-21"), /April 2026/);
});

test("monthLabel: empty input stays empty", () => {
  assert.equal(monthLabel(""), "");
});

test("uniqueSorted: dedupes, drops falsy values, and sorts by locale", () => {
  assert.deepEqual(
    uniqueSorted(["b", "a", "b", "", null, undefined, "c"]),
    ["a", "b", "c"],
  );
});
