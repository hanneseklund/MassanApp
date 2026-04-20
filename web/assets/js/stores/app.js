// App-wide navigation and simulation state. The prototype uses
// hash-based routing so views are linkable:
//   #/                                               -> calendar
//   #/event/<slug>                                   -> event landing (stacked layout)
//   #/event/<slug>/news|articles|program|food        -> dedicated full-list page
//   #/event/<slug>/exhibitors                        -> dedicated exhibitor index
//   #/event/<slug>/exhibitors/<exhibitor-id>         -> exhibitor detail
//   #/event/<slug>/practical|newsletter              -> stacked landing + scroll to section
//   #/event/<slug>/purchase                          -> simulated ticket purchase
//   #/auth                                           -> registration / sign-in
//   #/me                                             -> signed-in My Pages
//   #/tickets                                        -> My Tickets wallet
//   #/points                                         -> venue-wide points shop

const EVENT_SUBVIEWS = [
  "home",
  "news",
  "articles",
  "program",
  "exhibitors",
  "practical",
  "food",
  "newsletter",
];

// Subviews that no longer have a dedicated full-list page in the
// stacked layout. Visiting either route collapses to the landing view
// and asks the event view to scroll to the section anchor instead.
const SCROLL_ONLY_SUBVIEWS = new Set(["practical", "newsletter"]);

export function parseHash(hash) {
  const clean = hash.replace(/^#\/?/, "");
  if (!clean) return { view: "calendar" };
  const parts = clean.split("/").filter(Boolean);
  if (parts[0] === "auth") return { view: "auth" };
  if (parts[0] === "me") return { view: "me" };
  if (parts[0] === "tickets") return { view: "tickets" };
  if (parts[0] === "points") return { view: "points" };
  if (parts[0] === "event" && parts[1]) {
    if (parts[2] === "purchase") {
      return { view: "purchase", eventId: parts[1] };
    }
    if (parts[2] === "exhibitors" && parts[3]) {
      return {
        view: "event",
        eventId: parts[1],
        eventSubview: "exhibitors",
        exhibitorId: parts[3],
      };
    }
    const subview = parts[2] && EVENT_SUBVIEWS.includes(parts[2]) ? parts[2] : "home";
    return { view: "event", eventId: parts[1], eventSubview: subview, exhibitorId: null };
  }
  return { view: "calendar" };
}

export function buildHash(state) {
  if (state.view === "calendar") return "#/";
  if (state.view === "auth") return "#/auth";
  if (state.view === "me") return "#/me";
  if (state.view === "tickets") return "#/tickets";
  if (state.view === "points") return "#/points";
  if (state.view === "purchase" && state.eventId) {
    return `#/event/${state.eventId}/purchase`;
  }
  if (state.view === "event") {
    if (state.eventSubview === "exhibitors" && state.exhibitorId) {
      return `#/event/${state.eventId}/exhibitors/${state.exhibitorId}`;
    }
    const sub = state.eventSubview && state.eventSubview !== "home"
      ? `/${state.eventSubview}`
      : "";
    return `#/event/${state.eventId}${sub}`;
  }
  return "#/";
}

export function appStore() {
  return {
    view: "calendar",
    eventId: null,
    eventSubview: "home",
    exhibitorId: null,
    // Set when a route lands on a section that no longer has a
    // dedicated page (practical, newsletter); the event view watches
    // this and scrolls the matching section anchor into view.
    pendingScrollSection: null,
    // Where to go after an auth flow completes. Stored as a route-like
    // object so that deep targets (e.g. the purchase flow for a given
    // event) can be resumed after sign-in.
    _preAuth: { view: "calendar" },

    init() {
      this._applyHash();
      window.addEventListener("hashchange", () => this._applyHash());
    },

    _applyHash() {
      const parsed = parseHash(window.location.hash);
      this.view = parsed.view;
      this.eventId = parsed.eventId ?? null;
      this.exhibitorId = parsed.exhibitorId ?? null;
      const subview = parsed.eventSubview ?? "home";
      if (
        this.view === "event" &&
        SCROLL_ONLY_SUBVIEWS.has(subview) &&
        this.eventId
      ) {
        // Collapse to the stacked landing view and ask the event view
        // to scroll to the section anchor. replaceState avoids creating
        // a back-button entry for the redirect.
        this.eventSubview = "home";
        this.pendingScrollSection = subview;
        const target = buildHash({
          view: "event",
          eventId: this.eventId,
          eventSubview: "home",
        });
        if (window.location.hash !== target) {
          window.history.replaceState(null, "", target);
        }
      } else {
        this.eventSubview = subview;
      }
    },

    _navigate(next) {
      const hash = buildHash(next);
      if (window.location.hash !== hash) {
        window.location.hash = hash;
      } else {
        this._applyHash();
      }
    },

    goCalendar() {
      this._navigate({ view: "calendar" });
    },
    _requireAuth(target) {
      if (Alpine.store("session").isSignedIn) {
        this._navigate(target);
      } else {
        this._preAuth = { ...target };
        this._navigate({ view: "auth" });
      }
    },
    goMe() {
      this._requireAuth({ view: "me" });
    },
    goTickets() {
      this._requireAuth({ view: "tickets" });
    },
    goPoints() {
      this._requireAuth({ view: "points" });
    },
    startPurchase(eventId) {
      if (!eventId) return;
      this._requireAuth({ view: "purchase", eventId });
    },
    goAuth(target) {
      if (typeof target === "string") {
        this._preAuth = { view: target };
      } else if (target && typeof target === "object") {
        this._preAuth = { ...target };
      } else {
        this._preAuth = { view: "calendar" };
      }
      this._navigate({ view: "auth" });
    },
    afterAuth() {
      const target = this._preAuth || { view: "calendar" };
      this._preAuth = { view: "calendar" };
      this._navigate(target);
    },
    selectEvent(eventId) {
      this._navigate({ view: "event", eventId, eventSubview: "home" });
    },
    goEventSubview(subview) {
      if (!this.eventId) return;
      this._navigate({
        view: "event",
        eventId: this.eventId,
        eventSubview: subview,
      });
    },
    selectExhibitor(exhibitorId) {
      if (!this.eventId) return;
      this._navigate({
        view: "event",
        eventId: this.eventId,
        eventSubview: "exhibitors",
        exhibitorId,
      });
    },
    backToExhibitors() {
      if (!this.eventId) return;
      this._navigate({
        view: "event",
        eventId: this.eventId,
        eventSubview: "exhibitors",
      });
    },

    chromeTitle() {
      const t = (key, params) => Alpine.store("lang").t(key, params);
      if (this.view === "calendar") return t("title.events");
      if (this.view === "auth") return t("title.sign_in");
      if (this.view === "me") return t("title.my_pages");
      if (this.view === "tickets") return t("title.my_tickets");
      if (this.view === "points") return t("title.points_shop");
      if (this.view === "purchase") {
        const ev = Alpine.store("catalog").eventById(this.eventId);
        return ev
          ? t("title.get_tickets_for", { name: ev.name })
          : t("title.get_tickets");
      }
      if (this.view === "event") {
        const ev = Alpine.store("catalog").eventById(this.eventId);
        return ev ? ev.name : t("title.event_default");
      }
      return t("title.app_default");
    },
  };
}
