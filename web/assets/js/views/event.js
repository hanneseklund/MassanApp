// Event view: mini-homepage scoped to the currently selected event.
// Renders the event hero and fans out to the News, Articles, Program,
// Exhibitors (index and detail), Practical info, and Newsletter
// subviews via `$store.app.eventSubview`.

import {
  formatDates,
  formatShortDate,
  formatDayHeading,
} from "../util/dates.js";
import { SECTION_LABELS, ticketCtaLabel } from "../util/sections.js";

const OVERRIDE_KEYS = {
  entrance: "overrides.entrance",
  bag_rules: "overrides.bag_rules",
  access_notes: "overrides.access_notes",
};

export function eventView() {
  return {
    sections: SECTION_LABELS,
    exhibitorQuery: "",
    formatDates,
    formatShortDate,
    formatDayHeading,
    ticketCtaLabel,
    event() {
      const id = Alpine.store("app").eventId;
      return id ? Alpine.store("catalog").eventById(id) : null;
    },
    hasTicket() {
      const ev = this.event();
      const user = Alpine.store("session").user;
      if (!ev || !user) return false;
      return Alpine.store("tickets").hasForEvent(user.id, ev.id);
    },
    startPurchase() {
      const ev = this.event();
      if (ev) Alpine.store("app").startPurchase(ev.id);
    },
    news() {
      const ev = this.event();
      return ev ? Alpine.store("catalog").newsForEvent(ev.id) : [];
    },
    articles() {
      const ev = this.event();
      return ev ? Alpine.store("catalog").articlesForEvent(ev.id) : [];
    },
    programByDay() {
      const ev = this.event();
      if (!ev) return [];
      const sessions = Alpine.store("catalog").programForEvent(ev.id);
      const groups = new Map();
      for (const s of sessions) {
        if (!groups.has(s.day)) groups.set(s.day, []);
        groups.get(s.day).push(s);
      }
      return [...groups.entries()].map(([day, list]) => ({ day, sessions: list }));
    },
    speakerNames(session) {
      if (!session.speaker_ids?.length) return [];
      return session.speaker_ids
        .map((id) => Alpine.store("catalog").speakerById(id))
        .filter(Boolean)
        .map((s) => s.name);
    },
    filteredExhibitors() {
      const ev = this.event();
      if (!ev) return [];
      const list = Alpine.store("catalog").exhibitorsForEvent(ev.id);
      const q = this.exhibitorQuery.trim().toLowerCase();
      if (!q) return list;
      return list.filter(
        (e) =>
          e.name.toLowerCase().includes(q) ||
          (e.booth ?? "").toLowerCase().includes(q) ||
          (e.description ?? "").toLowerCase().includes(q)
      );
    },
    exhibitor() {
      const id = Alpine.store("app").exhibitorId;
      return id ? Alpine.store("catalog").exhibitorById(id) : null;
    },
    venue() {
      return Alpine.store("catalog").venue ?? {};
    },
    overrides() {
      return this.event()?.overrides ?? {};
    },
    hasOverrides() {
      return Object.keys(this.overrides()).length > 0;
    },
    overrideLabel(key) {
      const translationKey = OVERRIDE_KEYS[key];
      if (translationKey) return Alpine.store("lang").t(translationKey);
      return key.replace(/_/g, " ");
    },
  };
}
