// Calendar view: upcoming events with filters and search.

import { formatDates, monthLabel, uniqueSorted } from "../util/dates.js";

export function calendarView() {
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
