// Calendar view: ongoing/upcoming events plus recently-ended ones
// (within the past-event grace window — see `util/calendar.js`).

import { formatDates, monthLabel, uniqueSorted } from "../util/dates.js";
import { calendarVisibleEvents, filterEvents } from "../util/calendar.js";

export function calendarView() {
  return {
    visible() {
      return calendarVisibleEvents(Alpine.store("catalog").events);
    },
    get types() {
      return uniqueSorted(this.visible().map((e) => e.type));
    },
    get categories() {
      return uniqueSorted(this.visible().map((e) => e.category));
    },
    get months() {
      return uniqueSorted(this.visible().map((e) => monthLabel(e.start_date)));
    },
    formatDates,
    filtered() {
      return filterEvents(
        this.visible(),
        Alpine.store("filters"),
        undefined,
        Alpine.store("lang").current,
      );
    },
  };
}
