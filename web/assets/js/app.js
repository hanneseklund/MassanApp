// MassanApp prototype — module entrypoint. Registers Alpine stores
// and view-factory globals on `alpine:init`. Each store and view
// lives in its own module under `stores/` and `views/`; see
// docs/implementation-specification.md under "Frontend app structure".

import { appStore } from "./stores/app.js";
import { sessionStore } from "./stores/session.js";
import { catalogStore } from "./stores/catalog.js";
import { ticketsStore } from "./stores/tickets.js";
import { newsletterStore } from "./stores/newsletter.js";
import { filtersStore } from "./stores/filters.js";
import { langStore } from "./stores/lang.js";

import { calendarView } from "./views/calendar.js";
import { eventView } from "./views/event.js";
import { authView } from "./views/auth.js";
import { meView } from "./views/me.js";
import { purchaseView } from "./views/purchase.js";
import { myTicketsView } from "./views/my-tickets.js";
import { newsletterSignup } from "./views/newsletter-signup.js";
import { newsletterPreferences } from "./views/newsletter-preferences.js";

document.addEventListener("alpine:init", () => {
  // `lang` must register before the others so `init` hooks that may
  // read the active locale (date formatters, titles) see the right
  // value on first render.
  Alpine.store("lang", langStore());
  Alpine.store("app", appStore());
  Alpine.store("session", sessionStore());
  Alpine.store("catalog", catalogStore());
  Alpine.store("tickets", ticketsStore());
  Alpine.store("newsletter", newsletterStore());
  Alpine.store("filters", filtersStore());

  // View factories are referenced from `index.html` as
  // `x-data="calendarView()"` etc., so they must be resolvable in the
  // global scope. ES modules do not implicitly add exports to
  // `window`, so attach each factory here.
  window.calendarView = calendarView;
  window.eventView = eventView;
  window.authView = authView;
  window.meView = meView;
  window.purchaseView = purchaseView;
  window.myTicketsView = myTicketsView;
  window.newsletterSignup = newsletterSignup;
  window.newsletterPreferences = newsletterPreferences;
});
