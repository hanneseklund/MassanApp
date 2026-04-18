// Calendar view: upcoming events with filters and search.

import { formatDates, monthLabel, uniqueSorted } from "../util/dates.js";

// Local-date ISO string (YYYY-MM-DD). `end_date` in Postgres is a DATE
// with no timezone, so comparing against the visitor's local date
// keeps "upcoming" meaningful across the day boundary.
function todayLocalIso() {
  const d = new Date();
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

// An event is upcoming while it has not yet ended. Events missing a
// date are kept visible — the calendar never hides them silently.
function isUpcoming(event, today) {
  const endsOn = event.end_date || event.start_date;
  if (!endsOn) return true;
  return endsOn >= today;
}

export function calendarView() {
  return {
    upcoming() {
      const today = todayLocalIso();
      return Alpine.store("catalog").events.filter((e) =>
        isUpcoming(e, today),
      );
    },
    get types() {
      return uniqueSorted(this.upcoming().map((e) => e.type));
    },
    get categories() {
      return uniqueSorted(this.upcoming().map((e) => e.category));
    },
    get months() {
      return uniqueSorted(this.upcoming().map((e) => monthLabel(e.start_date)));
    },
    formatDates,
    filtered() {
      const { query, type, category, month } = Alpine.store("filters");
      const q = query.trim().toLowerCase();
      return this.upcoming()
        .filter((e) => {
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
