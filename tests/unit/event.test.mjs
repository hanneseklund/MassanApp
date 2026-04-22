// eventView() in views/event.js drives the selected event's stacked
// landing page and its dedicated section routes. Most of its behaviour
// is data shaping: truncating long lists to the inline 5-item limit,
// deciding when the event add-ons section is visible, resolving
// override labels through i18n, and falling back to the event hero
// when a section item has no own image. Those helpers are worth
// pinning down so a template refactor that changes the truncation
// rule fails a fast unit check rather than a slower Playwright run.
//
// Follows the Alpine.store stub pattern from my-tickets.test.mjs and
// me.test.mjs — no browser, no Supabase, no Alpine runtime.

import test from "node:test";
import assert from "node:assert/strict";

import { eventView } from "../../web/assets/js/views/event.js";
import { withAlpine } from "./_alpine.mjs";

// Minimal lang stub. Returns `key` verbatim so tests assert which key
// was picked without depending on i18n.js copy.
function langStub() {
  return {
    t(key) {
      return key;
    },
  };
}

// Catalog stub: every selector is keyed off an id so tests can wire
// per-event fixture rows without building a full catalog store.
function makeCatalog({
  events = {},
  news = {},
  articles = {},
  program = {},
  exhibitors = {},
  addons = {},
  speakers = {},
  venue = {},
} = {}) {
  return {
    venue,
    eventById(id) {
      return events[id] ?? null;
    },
    newsForEvent(id) {
      return news[id] ?? [];
    },
    articlesForEvent(id) {
      return articles[id] ?? [];
    },
    programByDayForEvent(id) {
      return program[id] ?? [];
    },
    exhibitorsForEvent(id) {
      return exhibitors[id] ?? [];
    },
    exhibitorById(id) {
      for (const list of Object.values(exhibitors)) {
        const hit = list.find((e) => e.id === id);
        if (hit) return hit;
      }
      return null;
    },
    addonsForEvent(id) {
      return addons[id] ?? [];
    },
    speakerById(id) {
      return speakers[id] ?? null;
    },
  };
}

function makeStores({
  eventId = null,
  exhibitorId = null,
  user = null,
  userTickets = [],
  catalog = makeCatalog(),
} = {}) {
  return {
    lang: langStub(),
    app: { eventId, exhibitorId, pendingScrollSection: null },
    session: { user },
    tickets: {
      hasForEvent(userId, eId) {
        return userTickets.some(
          (t) => t.user_id === userId && t.event_id === eId,
        );
      },
    },
    catalog,
  };
}

function makeNews(count, prefix = "n") {
  return Array.from({ length: count }, (_, i) => ({
    id: `${prefix}${i + 1}`,
    title: `News ${i + 1}`,
  }));
}

function makeArticles(count, prefix = "a") {
  return Array.from({ length: count }, (_, i) => ({
    id: `${prefix}${i + 1}`,
    title: `Article ${i + 1}`,
  }));
}

function makeExhibitors(count, prefix = "x") {
  return Array.from({ length: count }, (_, i) => ({
    id: `${prefix}${i + 1}`,
    name: `Exhibitor ${i + 1}`,
    booth: `A${i + 1}`,
    description: `Booth ${i + 1} description`,
  }));
}

test("event(): returns null when no event is selected", () => {
  withAlpine(makeStores({ eventId: null }), () => {
    assert.equal(eventView().event(), null);
  });
});

test("event(): returns the catalog row for the selected event id", () => {
  const ev = { id: "e-1", name: "Event 1" };
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({ events: { "e-1": ev } }),
    }),
    () => {
      assert.equal(eventView().event(), ev);
    },
  );
});

test("inlineNews / hasMoreNews: truncate to the 5-item limit", () => {
  const ev = { id: "e-1", name: "Event 1" };
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({
        events: { "e-1": ev },
        news: { "e-1": makeNews(7) },
      }),
    }),
    () => {
      const view = eventView();
      assert.equal(view.inlineNews().length, 5);
      assert.equal(view.hasMoreNews(), true);
      assert.deepEqual(
        view.inlineNews().map((n) => n.id),
        ["n1", "n2", "n3", "n4", "n5"],
      );
    },
  );
});

test("inlineNews / hasMoreNews: no 'see all' when the list is short", () => {
  const ev = { id: "e-1" };
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({
        events: { "e-1": ev },
        news: { "e-1": makeNews(3) },
      }),
    }),
    () => {
      const view = eventView();
      assert.equal(view.inlineNews().length, 3);
      assert.equal(view.hasMoreNews(), false);
    },
  );
});

test("inlineArticles / hasMoreArticles: mirror the news truncation rule", () => {
  const ev = { id: "e-1" };
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({
        events: { "e-1": ev },
        articles: { "e-1": makeArticles(6) },
      }),
    }),
    () => {
      const view = eventView();
      assert.equal(view.inlineArticles().length, 5);
      assert.equal(view.hasMoreArticles(), true);
    },
  );
});

test("inlineExhibitors / hasMoreExhibitors: mirror the news truncation rule", () => {
  const ev = { id: "e-1" };
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({
        events: { "e-1": ev },
        exhibitors: { "e-1": makeExhibitors(5) },
      }),
    }),
    () => {
      const view = eventView();
      assert.equal(view.inlineExhibitors().length, 5);
      assert.equal(view.hasMoreExhibitors(), false);
    },
  );
});

test("inlineProgramByDay(): truncates across days while keeping the grouping", () => {
  // Two days of 4 sessions each (8 total). The inline preview must keep
  // the first day's 4 sessions intact and then take 1 from the second
  // day to reach the 5-item limit — not five sessions flattened.
  const ev = { id: "e-1" };
  const groups = [
    {
      day: "2026-03-01",
      sessions: [
        { id: "s1", title: "s1" },
        { id: "s2", title: "s2" },
        { id: "s3", title: "s3" },
        { id: "s4", title: "s4" },
      ],
    },
    {
      day: "2026-03-02",
      sessions: [
        { id: "s5", title: "s5" },
        { id: "s6", title: "s6" },
        { id: "s7", title: "s7" },
        { id: "s8", title: "s8" },
      ],
    },
  ];
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({
        events: { "e-1": ev },
        program: { "e-1": groups },
      }),
    }),
    () => {
      const view = eventView();
      const preview = view.inlineProgramByDay();
      assert.equal(preview.length, 2);
      assert.equal(preview[0].day, "2026-03-01");
      assert.equal(preview[0].sessions.length, 4);
      assert.equal(preview[1].day, "2026-03-02");
      assert.equal(preview[1].sessions.length, 1);
      assert.equal(view.programSessionCount(), 8);
      assert.equal(view.hasMoreProgram(), true);
    },
  );
});

test("inlineProgramByDay(): drops trailing empty day groups", () => {
  // If the first day already exhausts the limit, later days must not
  // appear as empty-group entries in the preview.
  const ev = { id: "e-1" };
  const groups = [
    {
      day: "2026-03-01",
      sessions: [
        { id: "s1", title: "s1" },
        { id: "s2", title: "s2" },
        { id: "s3", title: "s3" },
        { id: "s4", title: "s4" },
        { id: "s5", title: "s5" },
      ],
    },
    {
      day: "2026-03-02",
      sessions: [{ id: "s6", title: "s6" }],
    },
  ];
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({
        events: { "e-1": ev },
        program: { "e-1": groups },
      }),
    }),
    () => {
      const view = eventView();
      const preview = view.inlineProgramByDay();
      assert.equal(preview.length, 1);
      assert.equal(preview[0].sessions.length, 5);
    },
  );
});

test("hasMoreProgram(): false when the total session count fits the limit", () => {
  const ev = { id: "e-1" };
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({
        events: { "e-1": ev },
        program: {
          "e-1": [
            {
              day: "2026-03-01",
              sessions: [
                { id: "s1" },
                { id: "s2" },
              ],
            },
          ],
        },
      }),
    }),
    () => {
      const view = eventView();
      assert.equal(view.programSessionCount(), 2);
      assert.equal(view.hasMoreProgram(), false);
    },
  );
});

test("inlineFoodMenus(): themed items lead the preview, then regular menus fill", () => {
  const ev = { id: "e-1" };
  const themed = [
    { id: "th1", label: "Themed 1" },
    { id: "th2", label: "Themed 2" },
  ];
  const regular = [
    { id: "r1" },
    { id: "r2" },
    { id: "r3" },
    { id: "r4" },
    { id: "r5" },
  ];
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({ events: { "e-1": ev } }),
    }),
    () => {
      const view = eventView();
      view.foodMenus = regular;
      view.themedFoodMenuItems = () => themed;
      const preview = view.inlineFoodMenus().map((m) => m.id);
      assert.deepEqual(preview, ["th1", "th2", "r1", "r2", "r3"]);
      assert.equal(view.hasMoreFoodMenus(), true);
    },
  );
});

test("inlineFoodMenus(): no themed items falls back to the regular grid", () => {
  const ev = { id: "e-1" };
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({ events: { "e-1": ev } }),
    }),
    () => {
      const view = eventView();
      view.foodMenus = [
        { id: "r1" },
        { id: "r2" },
        { id: "r3" },
      ];
      view.themedFoodMenuItems = () => [];
      const preview = view.inlineFoodMenus().map((m) => m.id);
      assert.deepEqual(preview, ["r1", "r2", "r3"]);
      assert.equal(view.hasMoreFoodMenus(), false);
    },
  );
});

test("addons / addonsVisible: hidden until the signed-in visitor owns a ticket", () => {
  const ev = { id: "e-1", name: "Event 1" };
  const addonRows = [{ id: "ad1", event_id: "e-1", name: "Gift bag" }];
  // No user.
  withAlpine(
    makeStores({
      eventId: "e-1",
      user: null,
      catalog: makeCatalog({
        events: { "e-1": ev },
        addons: { "e-1": addonRows },
      }),
    }),
    () => {
      const view = eventView();
      assert.deepEqual(view.addons(), addonRows);
      assert.equal(view.addonsVisible(), false);
    },
  );
  // Signed-in but no ticket.
  withAlpine(
    makeStores({
      eventId: "e-1",
      user: { id: "u-1" },
      userTickets: [],
      catalog: makeCatalog({
        events: { "e-1": ev },
        addons: { "e-1": addonRows },
      }),
    }),
    () => {
      assert.equal(eventView().addonsVisible(), false);
    },
  );
  // Signed-in with a ticket for this event, but no addon rows.
  withAlpine(
    makeStores({
      eventId: "e-1",
      user: { id: "u-1" },
      userTickets: [{ user_id: "u-1", event_id: "e-1" }],
      catalog: makeCatalog({
        events: { "e-1": ev },
        addons: { "e-1": [] },
      }),
    }),
    () => {
      assert.equal(eventView().addonsVisible(), false);
    },
  );
  // Ticket + addons → visible.
  withAlpine(
    makeStores({
      eventId: "e-1",
      user: { id: "u-1" },
      userTickets: [{ user_id: "u-1", event_id: "e-1" }],
      catalog: makeCatalog({
        events: { "e-1": ev },
        addons: { "e-1": addonRows },
      }),
    }),
    () => {
      assert.equal(eventView().addonsVisible(), true);
    },
  );
});

test("addonsVisible(): a ticket for a different event does not unlock addons here", () => {
  const ev = { id: "e-1" };
  withAlpine(
    makeStores({
      eventId: "e-1",
      user: { id: "u-1" },
      userTickets: [{ user_id: "u-1", event_id: "e-2" }],
      catalog: makeCatalog({
        events: { "e-1": ev },
        addons: { "e-1": [{ id: "ad1", event_id: "e-1" }] },
      }),
    }),
    () => {
      assert.equal(eventView().addonsVisible(), false);
    },
  );
});

test("addonImage(): falls back to the event hero when the addon has no image", () => {
  const ev = { id: "e-1", branding: { hero_image: "/img/hero.jpg" } };
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({ events: { "e-1": ev } }),
    }),
    () => {
      const view = eventView();
      assert.equal(
        view.addonImage({ image: "/img/addon.png" }),
        "/img/addon.png",
      );
      assert.equal(view.addonImage({}), "/img/hero.jpg");
      assert.equal(view.addonImage(null), "/img/hero.jpg");
    },
  );
});

test("addonImage(): null when neither the addon nor the event carries an image", () => {
  const ev = { id: "e-1" };
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({ events: { "e-1": ev } }),
    }),
    () => {
      assert.equal(eventView().addonImage({}), null);
    },
  );
});

test("newsImage(): uses the news item's own image when present", () => {
  const ev = { id: "e-1", branding: { hero_image: "/img/hero.jpg" } };
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({ events: { "e-1": ev } }),
    }),
    () => {
      const view = eventView();
      assert.equal(
        view.newsImage({ hero_image: "/img/news.jpg" }),
        "/img/news.jpg",
      );
    },
  );
});

test("newsImage() / articleImage(): fall back to the event hero when unset", () => {
  const ev = { id: "e-1", branding: { hero_image: "/img/hero.jpg" } };
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({ events: { "e-1": ev } }),
    }),
    () => {
      const view = eventView();
      assert.equal(view.newsImage({}), "/img/hero.jpg");
      assert.equal(view.newsImage(null), "/img/hero.jpg");
      assert.equal(view.articleImage({}), "/img/hero.jpg");
      assert.equal(view.articleImage(null), "/img/hero.jpg");
    },
  );
});

test("overrides / hasOverrides: empty when the event has none", () => {
  const ev = { id: "e-1" };
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({ events: { "e-1": ev } }),
    }),
    () => {
      const view = eventView();
      assert.deepEqual(view.overrides(), {});
      assert.equal(view.hasOverrides(), false);
    },
  );
});

test("overrides / hasOverrides: surfaces the event's overrides block", () => {
  const ev = {
    id: "e-1",
    overrides: { entrance: "East entrance", bag_rules: "No large bags" },
  };
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({ events: { "e-1": ev } }),
    }),
    () => {
      const view = eventView();
      assert.deepEqual(view.overrides(), ev.overrides);
      assert.equal(view.hasOverrides(), true);
    },
  );
});

test("overrideLabel(): known keys resolve through i18n; unknown keys humanize the field name", () => {
  withAlpine(makeStores(), () => {
    const view = eventView();
    assert.equal(view.overrideLabel("entrance"), "overrides.entrance");
    assert.equal(view.overrideLabel("bag_rules"), "overrides.bag_rules");
    assert.equal(view.overrideLabel("access_notes"), "overrides.access_notes");
    // Unknown key falls back to the key with underscores replaced,
    // so a forward-looking override still renders with a readable label.
    assert.equal(view.overrideLabel("new_future_field"), "new future field");
  });
});

test("filteredExhibitors(): empty query returns the full list", () => {
  const ev = { id: "e-1" };
  const rows = makeExhibitors(3);
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({
        events: { "e-1": ev },
        exhibitors: { "e-1": rows },
      }),
    }),
    () => {
      assert.deepEqual(eventView().filteredExhibitors(), rows);
    },
  );
});

test("filteredExhibitors(): matches against name, booth, and description, case-insensitively", () => {
  const ev = { id: "e-1" };
  const rows = [
    { id: "x1", name: "Alpha Construction", booth: "A1", description: "Concrete and steel" },
    { id: "x2", name: "Beta Interiors", booth: "B2", description: "Furniture design" },
    { id: "x3", name: "Gamma Safety", booth: "C3", description: "Helmets, boots, gloves" },
  ];
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({
        events: { "e-1": ev },
        exhibitors: { "e-1": rows },
      }),
    }),
    () => {
      const view = eventView();
      // Name match, case-insensitive.
      view.exhibitorQuery = "alpha";
      assert.deepEqual(
        view.filteredExhibitors().map((e) => e.id),
        ["x1"],
      );
      // Booth match.
      view.exhibitorQuery = "B2";
      assert.deepEqual(
        view.filteredExhibitors().map((e) => e.id),
        ["x2"],
      );
      // Description match.
      view.exhibitorQuery = "GLOVES";
      assert.deepEqual(
        view.filteredExhibitors().map((e) => e.id),
        ["x3"],
      );
      // No match → empty list.
      view.exhibitorQuery = "zzz";
      assert.deepEqual(view.filteredExhibitors(), []);
    },
  );
});

test("filteredExhibitors(): tolerates rows that are missing booth or description", () => {
  const ev = { id: "e-1" };
  const rows = [{ id: "x1", name: "Solo" }];
  withAlpine(
    makeStores({
      eventId: "e-1",
      catalog: makeCatalog({
        events: { "e-1": ev },
        exhibitors: { "e-1": rows },
      }),
    }),
    () => {
      const view = eventView();
      view.exhibitorQuery = "solo";
      assert.deepEqual(
        view.filteredExhibitors().map((e) => e.id),
        ["x1"],
      );
    },
  );
});

test("exhibitor(): resolves the selected exhibitor id against the catalog", () => {
  const ev = { id: "e-1" };
  const rows = makeExhibitors(2);
  withAlpine(
    makeStores({
      eventId: "e-1",
      exhibitorId: "x2",
      catalog: makeCatalog({
        events: { "e-1": ev },
        exhibitors: { "e-1": rows },
      }),
    }),
    () => {
      assert.equal(eventView().exhibitor()?.id, "x2");
    },
  );
});

test("exhibitorLogo / speakerAvatar: fall back to a deterministic SVG when no asset is set", () => {
  withAlpine(makeStores(), () => {
    const view = eventView();
    const logo = view.exhibitorLogo({ name: "Alpha" });
    assert.ok(
      logo.startsWith("data:image/svg+xml"),
      `expected a data: SVG fallback, got ${logo.slice(0, 40)}`,
    );
    const avatar = view.speakerAvatar({ name: "Dr Alice" });
    assert.ok(
      avatar.startsWith("data:image/svg+xml"),
      `expected a data: SVG fallback, got ${avatar.slice(0, 40)}`,
    );
    // A supplied asset passes through.
    assert.equal(
      view.exhibitorLogo({ name: "Alpha", logo: "/img/alpha.png" }),
      "/img/alpha.png",
    );
    assert.equal(
      view.speakerAvatar({ name: "Alice", avatar: "/img/alice.jpg" }),
      "/img/alice.jpg",
    );
  });
});

test("sessionSpeakers(): resolves speaker ids through the catalog and drops unknowns", () => {
  withAlpine(
    makeStores({
      catalog: makeCatalog({
        speakers: {
          sp1: { id: "sp1", name: "Alice" },
          sp2: { id: "sp2", name: "Bob" },
        },
      }),
    }),
    () => {
      const view = eventView();
      const out = view.sessionSpeakers({ speaker_ids: ["sp1", "missing", "sp2"] });
      assert.deepEqual(
        out.map((s) => s.id),
        ["sp1", "sp2"],
      );
      // No speaker_ids → empty list.
      assert.deepEqual(view.sessionSpeakers({}), []);
    },
  );
});
