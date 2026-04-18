// Date and list formatting helpers shared by several view components.
// `formatDates` renders an event date range. `formatShortDate`,
// `formatDayHeading`, and `monthLabel` format single-point dates for
// news items, ticket purchases, day headings in a program, and the
// calendar month filter. `uniqueSorted` is used by filter dropdowns.
//
// Each formatter reads the active UI language from the `lang` store so
// Swedish renders weekday and month names in Swedish. A fallback path
// covers the pre-init window where the store may not yet exist.

const DEFAULT_LOCALE = "en-GB";

function activeLocale() {
  try {
    return globalThis.Alpine?.store?.("lang")?.dateLocale?.() ?? DEFAULT_LOCALE;
  } catch {
    return DEFAULT_LOCALE;
  }
}

export function formatDates(event) {
  if (!event?.start_date) return "";
  const start = new Date(event.start_date);
  const end = event.end_date ? new Date(event.end_date) : null;
  const locale = activeLocale();
  const opts = { day: "numeric", month: "short", year: "numeric" };
  if (!end || event.start_date === event.end_date) {
    return start.toLocaleDateString(locale, opts);
  }
  const sameYear = start.getFullYear() === end.getFullYear();
  const sameMonth = sameYear && start.getMonth() === end.getMonth();
  const startStr = start.toLocaleDateString(locale, {
    day: "numeric",
    month: sameMonth ? undefined : "short",
    year: sameYear ? undefined : "numeric",
  });
  const endStr = end.toLocaleDateString(locale, opts);
  return `${startStr} – ${endStr}`;
}

export function formatShortDate(iso) {
  if (!iso) return "";
  return new Date(iso).toLocaleDateString(activeLocale(), {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

export function formatDayHeading(iso) {
  if (!iso) return "";
  return new Date(iso).toLocaleDateString(activeLocale(), {
    weekday: "long",
    day: "numeric",
    month: "long",
  });
}

export function monthLabel(iso) {
  if (!iso) return "";
  const d = new Date(iso);
  return d.toLocaleDateString(activeLocale(), {
    month: "long",
    year: "numeric",
  });
}

export function uniqueSorted(values) {
  return [...new Set(values.filter(Boolean))].sort((a, b) => a.localeCompare(b));
}
