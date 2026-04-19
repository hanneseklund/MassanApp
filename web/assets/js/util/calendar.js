// Pure helpers behind the calendar view. Kept out of
// `views/calendar.js` so they can be unit-tested without Alpine or a
// browser; the view binds them to `$store.catalog.events` and
// `$store.filters`.

import { monthLabel } from "./dates.js";

// Local-date ISO string (YYYY-MM-DD). `end_date` in Postgres is a DATE
// with no timezone, so comparing against the visitor's local date
// keeps "upcoming" meaningful across the day boundary.
export function todayLocalIso(now = new Date()) {
  const yyyy = now.getFullYear();
  const mm = String(now.getMonth() + 1).padStart(2, "0");
  const dd = String(now.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

// An event is upcoming while it has not yet ended. Events missing a
// date are kept visible — the calendar never hides them silently.
export function isUpcoming(event, today) {
  const endsOn = event.end_date || event.start_date;
  if (!endsOn) return true;
  return endsOn >= today;
}

export function upcomingEvents(events, today = todayLocalIso()) {
  return events.filter((e) => isUpcoming(e, today));
}

export function eventMatchesQuery(event, query) {
  const q = String(query ?? "").trim().toLowerCase();
  if (!q) return true;
  return (
    (event.name ?? "").toLowerCase().includes(q) ||
    (event.summary ?? "").toLowerCase().includes(q)
  );
}

// Apply the calendar's type / category / month / free-text filters and
// sort by start_date ascending. `month` is matched against the same
// `monthLabel` value the month dropdown is populated from, so the
// active UI locale affects comparison. Callers must pass filter values
// resolved under the same locale (in practice, both come from
// `monthLabel` reads on the same render).
export function filterEvents(events, filters) {
  const { query = "", type = "", category = "", month = "" } = filters ?? {};
  return events
    .filter((e) => {
      if (type && e.type !== type) return false;
      if (category && e.category !== category) return false;
      if (month && monthLabel(e.start_date) !== month) return false;
      return eventMatchesQuery(e, query);
    })
    .sort((a, b) => (a.start_date || "").localeCompare(b.start_date || ""));
}
