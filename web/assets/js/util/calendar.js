// Pure helpers behind the calendar view. Kept out of
// `views/calendar.js` so they can be unit-tested without Alpine or a
// browser; the view binds them to `$store.catalog.events` and
// `$store.filters`.

import { monthLabel } from "./dates.js";

// Calendar list policy (issue #26): events stay visible on the
// calendar while ongoing/upcoming AND for `PAST_EVENT_GRACE_DAYS` days
// after they end, so a visitor who attended an event recently can
// still find it on the main list (e.g. to revisit content or reach a
// referenced ticket). After the grace window the event drops off.
export const PAST_EVENT_GRACE_DAYS = 21;

// Local-date ISO string (YYYY-MM-DD). `end_date` in Postgres is a DATE
// with no timezone, so comparing against the visitor's local date
// keeps "upcoming" meaningful across the day boundary.
export function todayLocalIso(now = new Date()) {
  const yyyy = now.getFullYear();
  const mm = String(now.getMonth() + 1).padStart(2, "0");
  const dd = String(now.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

// Shift a YYYY-MM-DD date by a (signed) number of days. Pure date
// math via UTC since the inputs and outputs are date-only and
// timezone-agnostic.
export function shiftIsoDate(iso, days) {
  if (!iso) return iso;
  const [y, m, d] = iso.split("-").map(Number);
  const dt = new Date(Date.UTC(y, m - 1, d));
  dt.setUTCDate(dt.getUTCDate() + days);
  const yyyy = dt.getUTCFullYear();
  const mm = String(dt.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(dt.getUTCDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

// "Ended on" reduces to `end_date` when present, otherwise
// `start_date`. Every seeded Stockholmsmassan event carries both, so
// the fallback is mostly defensive (and matches how `isCalendarVisible`
// has always treated dateless events).
function endsOnIso(event) {
  return event.end_date || event.start_date;
}

// True when the event still belongs on the calendar list: it has not
// yet ended, OR it ended within the last `PAST_EVENT_GRACE_DAYS`
// days. Events missing dates stay visible — the calendar never hides
// them silently.
export function isCalendarVisible(event, today = todayLocalIso()) {
  const endsOn = endsOnIso(event);
  if (!endsOn) return true;
  return endsOn >= shiftIsoDate(today, -PAST_EVENT_GRACE_DAYS);
}

// True when the event is ongoing or has not yet started. Used to
// partition the calendar list so recently-ended events appear after
// ongoing/upcoming ones.
export function isOngoingOrUpcoming(event, today = todayLocalIso()) {
  const endsOn = endsOnIso(event);
  if (!endsOn) return true;
  return endsOn >= today;
}

export function calendarVisibleEvents(events, today = todayLocalIso()) {
  return events.filter((e) => isCalendarVisible(e, today));
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
// sort the result. `month` is matched against the same `monthLabel`
// value the month dropdown is populated from, so the active UI locale
// affects comparison. Callers must pass filter values resolved under
// the same locale (in practice, both come from `monthLabel` reads on
// the same render).
//
// Sort policy (issue #26 follow-up): partition as if the current date
// were `PAST_EVENT_GRACE_DAYS` earlier, so events that ended within
// the grace window keep the on-top position they would have had three
// weeks ago — sorted alongside ongoing/upcoming events by `start_date`
// asc rather than relegated below them. Visibility (`isCalendarVisible`)
// still uses the real today, so the 21-day window is unchanged. The
// optional `today` arg is exposed for tests; production calls let it
// default to the visitor's local date.
export function filterEvents(events, filters, today = todayLocalIso()) {
  const { query = "", type = "", category = "", month = "" } = filters ?? {};
  const matched = events.filter((e) => {
    if (type && e.type !== type) return false;
    if (category && e.category !== category) return false;
    if (month && monthLabel(e.start_date) !== month) return false;
    return eventMatchesQuery(e, query);
  });
  const sortToday = shiftIsoDate(today, -PAST_EVENT_GRACE_DAYS);
  const upcoming = [];
  const ended = [];
  for (const e of matched) {
    if (isOngoingOrUpcoming(e, sortToday)) upcoming.push(e);
    else ended.push(e);
  }
  upcoming.sort((a, b) =>
    (a.start_date || "").localeCompare(b.start_date || ""),
  );
  ended.sort((a, b) =>
    (b.end_date || b.start_date || "").localeCompare(
      a.end_date || a.start_date || "",
    ),
  );
  return [...upcoming, ...ended];
}
