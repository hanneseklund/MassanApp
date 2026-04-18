// App-wide navigation and simulation state. The prototype uses
// hash-based routing so views are linkable:
//   #/                                               -> calendar
//   #/event/<slug>                                   -> event home
//   #/event/<slug>/<subview>                         -> event subview
//   #/event/<slug>/exhibitors/<exhibitor-id>         -> exhibitor detail
//   #/event/<slug>/purchase                          -> simulated ticket purchase
//   #/auth                                           -> registration / sign-in
//   #/me                                             -> signed-in My Pages
//   #/tickets                                        -> My Tickets wallet

const EVENT_SUBVIEWS = [
  "home",
  "news",
  "articles",
  "program",
  "exhibitors",
  "practical",
  "newsletter",
];

function parseHash(hash) {
  const clean = hash.replace(/^#\/?/, "");
  if (!clean) return { view: "calendar" };
  const parts = clean.split("/").filter(Boolean);
  if (parts[0] === "auth") return { view: "auth" };
  if (parts[0] === "me") return { view: "me" };
  if (parts[0] === "tickets") return { view: "tickets" };
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

function buildHash(state) {
  if (state.view === "calendar") return "#/";
  if (state.view === "auth") return "#/auth";
  if (state.view === "me") return "#/me";
  if (state.view === "tickets") return "#/tickets";
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
    isSimulated: true,
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
      this.eventSubview = parsed.eventSubview ?? "home";
      this.exhibitorId = parsed.exhibitorId ?? null;
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
    goMe() {
      if (Alpine.store("session").isSignedIn) {
        this._navigate({ view: "me" });
      } else {
        this._preAuth = { view: "me" };
        this._navigate({ view: "auth" });
      }
    },
    goTickets() {
      if (Alpine.store("session").isSignedIn) {
        this._navigate({ view: "tickets" });
      } else {
        this._preAuth = { view: "tickets" };
        this._navigate({ view: "auth" });
      }
    },
    startPurchase(eventId) {
      if (!eventId) return;
      if (Alpine.store("session").isSignedIn) {
        this._navigate({ view: "purchase", eventId });
      } else {
        this._preAuth = { view: "purchase", eventId };
        this._navigate({ view: "auth" });
      }
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
      if (target.view === "me") this._navigate({ view: "me" });
      else if (target.view === "tickets") this._navigate({ view: "tickets" });
      else if (target.view === "purchase" && target.eventId) {
        this._navigate({ view: "purchase", eventId: target.eventId });
      } else this._navigate({ view: "calendar" });
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
      if (this.view === "calendar") return "Events";
      if (this.view === "auth") return "Sign in";
      if (this.view === "me") return "My Pages";
      if (this.view === "tickets") return "My Tickets";
      if (this.view === "purchase") {
        const ev = Alpine.store("catalog").eventById(this.eventId);
        return ev ? `Get tickets · ${ev.name}` : "Get tickets";
      }
      if (this.view === "event") {
        const ev = Alpine.store("catalog").eventById(this.eventId);
        return ev ? ev.name : "Event";
      }
      return "MassanApp";
    },
  };
}
