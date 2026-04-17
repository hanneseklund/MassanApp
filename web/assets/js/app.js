// MassanApp prototype — Alpine.js stores and view components.
//
// The prototype uses hash-based routing so views are linkable:
//   #/                          -> calendar
//   #/event/<slug>              -> event home
//   #/event/<slug>/<subview>    -> event subview
//   #/me                        -> My Pages (stub until auth task)
//
// Data is loaded from web/data/catalog.json, which mirrors the Supabase
// table structure documented in docs/implementation-specification.md.

const EVENT_SUBVIEWS = [
  "home",
  "news",
  "articles",
  "program",
  "exhibitors",
  "practical",
  "newsletter",
];

const SECTION_LABELS = [
  { id: "news", label: "News" },
  { id: "articles", label: "Articles" },
  { id: "program", label: "Program" },
  { id: "exhibitors", label: "Exhibitors" },
  { id: "practical", label: "Practical info" },
  { id: "newsletter", label: "Newsletter" },
];

async function loadCatalog() {
  const response = await fetch("data/catalog.json", { cache: "no-store" });
  if (!response.ok) {
    throw new Error(`Failed to load catalog: ${response.status}`);
  }
  return response.json();
}

function parseHash(hash) {
  const clean = hash.replace(/^#\/?/, "");
  if (!clean) return { view: "calendar" };
  const parts = clean.split("/").filter(Boolean);
  if (parts[0] === "me") return { view: "me" };
  if (parts[0] === "event" && parts[1]) {
    const subview = parts[2] && EVENT_SUBVIEWS.includes(parts[2]) ? parts[2] : "home";
    return { view: "event", eventId: parts[1], eventSubview: subview };
  }
  return { view: "calendar" };
}

function buildHash(state) {
  if (state.view === "calendar") return "#/";
  if (state.view === "me") return "#/me";
  if (state.view === "event") {
    const sub = state.eventSubview && state.eventSubview !== "home"
      ? `/${state.eventSubview}`
      : "";
    return `#/event/${state.eventId}${sub}`;
  }
  return "#/";
}

document.addEventListener("alpine:init", () => {
  // App-wide navigation and simulation state.
  Alpine.store("app", {
    view: "calendar",
    eventId: null,
    eventSubview: "home",
    isSimulated: true,
    toast: "",
    _toastTimer: null,

    init() {
      this._applyHash();
      window.addEventListener("hashchange", () => this._applyHash());
    },

    _applyHash() {
      const parsed = parseHash(window.location.hash);
      this.view = parsed.view;
      this.eventId = parsed.eventId ?? null;
      this.eventSubview = parsed.eventSubview ?? "home";
    },

    _navigate(next) {
      const hash = buildHash(next);
      if (window.location.hash !== hash) {
        window.location.hash = hash;
      } else {
        this._applyHash();
      }
    },

    goCalendar() {
      this._navigate({ view: "calendar" });
    },
    goMe() {
      this._navigate({ view: "me" });
    },
    selectEvent(eventId) {
      this._navigate({ view: "event", eventId, eventSubview: "home" });
    },
    goEventSubview(subview) {
      if (!this.eventId) return;
      this._navigate({
        view: "event",
        eventId: this.eventId,
        eventSubview: subview,
      });
    },

    chromeTitle() {
      if (this.view === "calendar") return "Events";
      if (this.view === "me") return "My Pages";
      if (this.view === "event") {
        const ev = Alpine.store("catalog").eventById(this.eventId);
        return ev ? ev.name : "Event";
      }
      return "MassanApp";
    },

    notImplemented(label) {
      this.toast = `${label} is coming in a later task`;
      clearTimeout(this._toastTimer);
      this._toastTimer = setTimeout(() => (this.toast = ""), 2400);
    },
  });

  // Catalog store: venue, events, and per-event content. Loaded from the
  // seed JSON so the prototype can run without Supabase credentials.
  Alpine.store("catalog", {
    venue: null,
    events: [],
    news: [],
    articles: [],
    program: [],
    exhibitors: [],
    speakers: [],
    loading: true,
    error: null,

    async init() {
      try {
        const data = await loadCatalog();
        this.venue = data.venue ?? null;
        this.events = data.events ?? [];
        this.news = data.news ?? [];
        this.articles = data.articles ?? [];
        this.program = data.program ?? [];
        this.exhibitors = data.exhibitors ?? [];
        this.speakers = data.speakers ?? [];
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    },

    eventById(id) {
      return this.events.find((e) => e.id === id) ?? null;
    },
    newsForEvent(eventId) {
      return this.news
        .filter((n) => n.event_id === eventId)
        .sort((a, b) => (b.published_at || "").localeCompare(a.published_at || ""));
    },
    articlesForEvent(eventId) {
      return this.articles.filter((a) => a.event_id === eventId);
    },
    programForEvent(eventId) {
      return this.program
        .filter((p) => p.event_id === eventId)
        .sort((a, b) => {
          const d = (a.day || "").localeCompare(b.day || "");
          return d !== 0 ? d : (a.start_time || "").localeCompare(b.start_time || "");
        });
    },
    exhibitorsForEvent(eventId) {
      return this.exhibitors
        .filter((e) => e.event_id === eventId)
        .sort((a, b) => a.name.localeCompare(b.name));
    },
    speakerById(id) {
      return this.speakers.find((s) => s.id === id) ?? null;
    },
    practicalInfoForEvent(eventId) {
      // Shared venue data plus per-event overrides. Event overrides only
      // replace the specific fields that legitimately differ; transport,
      // parking, restaurants, and security stay shared across events.
      const ev = this.eventById(eventId);
      return {
        venue: this.venue,
        overrides: ev?.overrides ?? {},
      };
    },
  });

  // Filter state for the calendar view.
  Alpine.store("filters", {
    query: "",
    type: "",
    category: "",
    month: "",
  });
});

function formatDates(event) {
  if (!event?.start_date) return "";
  const start = new Date(event.start_date);
  const end = event.end_date ? new Date(event.end_date) : null;
  const opts = { day: "numeric", month: "short", year: "numeric" };
  if (!end || event.start_date === event.end_date) {
    return start.toLocaleDateString("en-GB", opts);
  }
  const sameYear = start.getFullYear() === end.getFullYear();
  const sameMonth = sameYear && start.getMonth() === end.getMonth();
  const startStr = start.toLocaleDateString("en-GB", {
    day: "numeric",
    month: sameMonth ? undefined : "short",
    year: sameYear ? undefined : "numeric",
  });
  const endStr = end.toLocaleDateString("en-GB", opts);
  return `${startStr} – ${endStr}`;
}

function monthLabel(iso) {
  if (!iso) return "";
  const d = new Date(iso);
  return d.toLocaleDateString("en-GB", { month: "long", year: "numeric" });
}

function calendarView() {
  return {
    get types() {
      return uniqueSorted(Alpine.store("catalog").events.map((e) => e.type));
    },
    get categories() {
      return uniqueSorted(Alpine.store("catalog").events.map((e) => e.category));
    },
    get months() {
      return uniqueSorted(
        Alpine.store("catalog").events.map((e) => monthLabel(e.start_date))
      );
    },
    formatDates,
    filtered() {
      const { query, type, category, month } = Alpine.store("filters");
      const q = query.trim().toLowerCase();
      return Alpine.store("catalog")
        .events.filter((e) => {
          if (type && e.type !== type) return false;
          if (category && e.category !== category) return false;
          if (month && monthLabel(e.start_date) !== month) return false;
          if (!q) return true;
          return (
            e.name.toLowerCase().includes(q) ||
            (e.summary ?? "").toLowerCase().includes(q)
          );
        })
        .sort((a, b) => (a.start_date || "").localeCompare(b.start_date || ""));
    },
  };
}

function eventView() {
  return {
    sections: SECTION_LABELS,
    formatDates,
    event() {
      const id = Alpine.store("app").eventId;
      return id ? Alpine.store("catalog").eventById(id) : null;
    },
  };
}

function uniqueSorted(values) {
  return [...new Set(values.filter(Boolean))].sort((a, b) => a.localeCompare(b));
}
