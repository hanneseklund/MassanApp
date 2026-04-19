// Calendar view: upcoming events with filters and search.

import { formatDates, monthLabel, uniqueSorted } from "../util/dates.js";
import { filterEvents, upcomingEvents } from "../util/calendar.js";

export function calendarView() {
  return {
    upcoming() {
      return upcomingEvents(Alpine.store("catalog").events);
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
      return filterEvents(this.upcoming(), Alpine.store("filters"));
    },
  };
}
