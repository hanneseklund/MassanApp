// Date and list formatting helpers shared by several view components.
// `formatDates` renders an event date range. `formatShortDate`,
// `formatDayHeading`, and `monthLabel` format single-point dates for
// news items, ticket purchases, day headings in a program, and the
// calendar month filter. `uniqueSorted` is used by filter dropdowns.

export function formatDates(event) {
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

export function formatShortDate(iso) {
  if (!iso) return "";
  return new Date(iso).toLocaleDateString("en-GB", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

export function formatDayHeading(iso) {
  if (!iso) return "";
  return new Date(iso).toLocaleDateString("en-GB", {
    weekday: "long",
    day: "numeric",
    month: "long",
  });
}

export function monthLabel(iso) {
  if (!iso) return "";
  const d = new Date(iso);
  return d.toLocaleDateString("en-GB", { month: "long", year: "numeric" });
}

export function uniqueSorted(values) {
  return [...new Set(values.filter(Boolean))].sort((a, b) => a.localeCompare(b));
}
