// calendarView() in views/calendar.js wires the catalog, filters, and
// lang stores into the pure helpers in util/calendar.js (covered by
// `calendar.test.mjs`). The wiring itself — that the view feeds the
// store-resident events through `calendarVisibleEvents`, surfaces
// type/category/month dropdown values from those visible events, and
// passes the active language into `filterEvents` — is what this suite
// pins down.

import test from "node:test";
import assert from "node:assert/strict";

import { calendarView } from "../../web/assets/js/views/calendar.js";
import { withAlpine } from "./_alpine.mjs";

function makeStores({ events, filters = {}, lang = "en" }) {
  return {
    catalog: { events },
    filters: {
      query: "",
      type: "",
      category: "",
      month: "",
      ...filters,
    },
    lang: { current: lang },
  };
}

// One ongoing event + one ended-long-ago event so the visibility
// helper has work to do; the suite asserts the view drops the latter
// from `visible()` rather than re-asserting the underlying calendar
// rules (those are pinned in `calendar.test.mjs`).
function sampleEvents() {
  return [
    {
      id: "e-current",
      type: "Trade fair",
      category: "Construction",
      start_date: "2099-05-01",
      end_date: "2099-05-03",
      name: "Future Fair",
      summary: "A future trade fair",
    },
    {
      id: "e-old",
      type: "Conference",
      category: "Health",
      start_date: "2000-01-01",
      end_date: "2000-01-02",
      name: "Ancient Conference",
      summary: "Long over",
    },
  ];
}

test("visible(): hides events past the calendar grace window", () => {
  withAlpine(makeStores({ events: sampleEvents() }), () => {
    const ids = calendarView()
      .visible()
      .map((e) => e.id);
    assert.deepEqual(ids, ["e-current"]);
  });
});

test("types/categories/months: only reflect visible events", () => {
  withAlpine(makeStores({ events: sampleEvents() }), () => {
    const view = calendarView();
    // The ended-long-ago event's "Conference" / "Health" never make it
    // into the dropdowns because they're filtered out upstream.
    assert.deepEqual(view.types, ["Trade fair"]);
    assert.deepEqual(view.categories, ["Construction"]);
    // monthLabel formats `2099-05-01` against the active locale; we
    // only assert it's a single non-empty value rather than the exact
    // string, since locale formatting differs across runtimes.
    assert.equal(view.months.length, 1);
    assert.equal(typeof view.months[0], "string");
    assert.notEqual(view.months[0], "");
  });
});

test("filtered(): applies a type filter on the visible set", () => {
  const events = [
    ...sampleEvents(),
    {
      id: "e-other",
      type: "Congress",
      category: "Construction",
      start_date: "2099-06-01",
      end_date: "2099-06-02",
      name: "Other Congress",
      summary: "Different type",
    },
  ];
  withAlpine(makeStores({ events, filters: { type: "Trade fair" } }), () => {
    const ids = calendarView()
      .filtered()
      .map((e) => e.id);
    assert.deepEqual(ids, ["e-current"]);
  });
});

test("filtered(): free-text query reads against the active language slot", () => {
  // `name` is a dual-language `{ en, sv }` jsonb leaf in the seeded
  // schema. The view must pass `lang.current` so a Swedish search hits
  // the Swedish slot and an English search misses it (or vice versa).
  const events = [
    {
      id: "e-dual",
      type: "Trade fair",
      category: "Construction",
      start_date: "2099-05-01",
      end_date: "2099-05-03",
      name: { en: "Builder Show", sv: "Byggmässan" },
      summary: { en: "An expo", sv: "En mässa" },
    },
  ];

  withAlpine(
    makeStores({ events, filters: { query: "byggmäss" }, lang: "sv" }),
    () => {
      const ids = calendarView()
        .filtered()
        .map((e) => e.id);
      assert.deepEqual(ids, ["e-dual"]);
    },
  );

  withAlpine(
    makeStores({ events, filters: { query: "byggmäss" }, lang: "en" }),
    () => {
      const ids = calendarView()
        .filtered()
        .map((e) => e.id);
      assert.deepEqual(ids, []);
    },
  );
});
