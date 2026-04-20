// Catalog store: venue, events, and per-event content. Loaded from
// the shared Supabase prototype project on first app load with nine
// parallel select queries. Rows are kept in memory for the life of
// the session and filtered per event in view components.

import { supabaseClient } from "../supabase.js";

async function loadCatalog() {
  const db = supabaseClient();
  const [
    venue,
    events,
    news,
    articles,
    program,
    exhibitors,
    speakers,
    addons,
    merchandise,
  ] = await Promise.all([
    db.from("venues").select("*").limit(1).single(),
    db.from("events").select("*"),
    db.from("news_items").select("*"),
    db.from("articles").select("*"),
    db.from("program_items").select("*"),
    db.from("exhibitors").select("*"),
    db.from("speakers").select("*"),
    db.from("point_addons").select("*").eq("active", true),
    db.from("merchandise").select("*").eq("active", true),
  ]);
  const firstError = [
    venue,
    events,
    news,
    articles,
    program,
    exhibitors,
    speakers,
    addons,
    merchandise,
  ]
    .map((r) => r.error)
    .find(Boolean);
  if (firstError) {
    throw new Error(`Failed to load catalog: ${firstError.message}`);
  }
  return {
    venue: venue.data,
    events: events.data,
    news: news.data,
    articles: articles.data,
    program: program.data,
    exhibitors: exhibitors.data,
    speakers: speakers.data,
    addons: addons.data,
    merchandise: merchandise.data,
  };
}

export function catalogStore() {
  return {
    venue: null,
    events: [],
    news: [],
    articles: [],
    program: [],
    exhibitors: [],
    speakers: [],
    addons: [],
    merchandise: [],
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
        this.addons = data.addons ?? [];
        this.merchandise = data.merchandise ?? [];
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
    programByDayForEvent(eventId) {
      const sessions = this.programForEvent(eventId);
      const groups = new Map();
      for (const s of sessions) {
        if (!groups.has(s.day)) groups.set(s.day, []);
        groups.get(s.day).push(s);
      }
      return [...groups.entries()].map(([day, list]) => ({ day, sessions: list }));
    },
    exhibitorsForEvent(eventId) {
      return this.exhibitors
        .filter((e) => e.event_id === eventId)
        .sort((a, b) => a.name.localeCompare(b.name));
    },
    exhibitorById(id) {
      return this.exhibitors.find((e) => e.id === id) ?? null;
    },
    speakerById(id) {
      return this.speakers.find((s) => s.id === id) ?? null;
    },
    addonsForEvent(eventId) {
      return this.addons
        .filter((a) => a.event_id === eventId && a.active !== false)
        .sort((a, b) => (a.points_cost || 0) - (b.points_cost || 0));
    },
    addonById(id) {
      return this.addons.find((a) => a.id === id) ?? null;
    },
    activeMerchandise() {
      return this.merchandise
        .filter((m) => m.active !== false)
        .sort((a, b) => (a.points_cost || 0) - (b.points_cost || 0));
    },
    merchandiseById(id) {
      return this.merchandise.find((m) => m.id === id) ?? null;
    },
  };
}
