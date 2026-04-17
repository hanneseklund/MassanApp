// MassanApp prototype — Alpine.js stores and view components.
//
// The prototype uses hash-based routing so views are linkable:
//   #/                                               -> calendar
//   #/event/<slug>                                   -> event home
//   #/event/<slug>/<subview>                         -> event subview
//   #/event/<slug>/exhibitors/<exhibitor-id>         -> exhibitor detail
//   #/auth                                           -> registration / sign-in
//   #/me                                             -> signed-in My Pages
//
// Data is loaded from web/data/catalog.json, which mirrors the Supabase
// table structure documented in docs/implementation-specification.md.

const EVENT_SUBVIEWS = [
  "home",
  "news",
  "articles",
  "program",
  "exhibitors",
  "practical",
  "newsletter",
];

const SECTION_LABELS = [
  { id: "news", label: "News" },
  { id: "articles", label: "Articles" },
  { id: "program", label: "Program" },
  { id: "exhibitors", label: "Exhibitors" },
  { id: "practical", label: "Practical info" },
  { id: "newsletter", label: "Newsletter" },
];

async function loadCatalog() {
  const response = await fetch("data/catalog.json", { cache: "no-store" });
  if (!response.ok) {
    throw new Error(`Failed to load catalog: ${response.status}`);
  }
  return response.json();
}

function parseHash(hash) {
  const clean = hash.replace(/^#\/?/, "");
  if (!clean) return { view: "calendar" };
  const parts = clean.split("/").filter(Boolean);
  if (parts[0] === "auth") return { view: "auth" };
  if (parts[0] === "me") return { view: "me" };
  if (parts[0] === "event" && parts[1]) {
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

// Session persistence. Password hashing is intentionally lightweight —
// the prototype stores user records in localStorage only, and there is
// no real security model until Supabase Auth replaces this layer.
const SESSION_KEY = "massan.session";
const USERS_KEY = "massan.users";

function hashPassword(pw) {
  let h = 0;
  const s = String(pw ?? "");
  for (let i = 0; i < s.length; i++) {
    h = ((h << 5) - h + s.charCodeAt(i)) | 0;
  }
  return `h${h}`;
}

function newUserId() {
  return "user-" + Math.random().toString(36).slice(2, 10);
}

function loadUsersFromStorage() {
  try {
    const raw = localStorage.getItem(USERS_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function saveUsersToStorage(users) {
  localStorage.setItem(USERS_KEY, JSON.stringify(users));
}

function loadSessionFromStorage() {
  try {
    const raw = localStorage.getItem(SESSION_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

function saveSessionToStorage(user) {
  if (user) {
    localStorage.setItem(SESSION_KEY, JSON.stringify(user));
  } else {
    localStorage.removeItem(SESSION_KEY);
  }
}

function publicUserRecord(user) {
  return {
    id: user.id,
    email: user.email,
    display_name: user.display_name,
    auth_provider: user.auth_provider,
    simulated: !!user.simulated,
  };
}

document.addEventListener("alpine:init", () => {
  // App-wide navigation and simulation state.
  Alpine.store("app", {
    view: "calendar",
    eventId: null,
    eventSubview: "home",
    exhibitorId: null,
    isSimulated: true,
    toast: "",
    _toastTimer: null,
    // View to return to once the user completes an auth flow. Defaults
    // to the calendar when entering auth from the chrome "Me" button.
    _preAuthView: "calendar",

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
        this._preAuthView = "calendar";
        this._navigate({ view: "auth" });
      }
    },
    goAuth(preAuthView) {
      this._preAuthView = preAuthView || "calendar";
      this._navigate({ view: "auth" });
    },
    afterAuth() {
      const target = this._preAuthView || "calendar";
      this._preAuthView = "calendar";
      if (target === "me") this._navigate({ view: "me" });
      else this._navigate({ view: "calendar" });
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
      if (this.view === "event") {
        const ev = Alpine.store("catalog").eventById(this.eventId);
        return ev ? ev.name : "Event";
      }
      return "MassanApp";
    },

    notImplemented(label) {
      this.toast = `${label} is coming in a later task`;
      clearTimeout(this._toastTimer);
      this._toastTimer = setTimeout(() => (this.toast = ""), 2400);
    },
  });

  // Session store: local-only authentication for the prototype.
  // Users and the signed-in session persist in localStorage so refreshes
  // keep the same user signed in. When Supabase Auth is wired in later,
  // `register`, `signIn`, and `signOut` become the only hook points that
  // need to switch implementation.
  Alpine.store("session", {
    user: null,

    init() {
      this.user = loadSessionFromStorage();
    },

    get isSignedIn() {
      return !!this.user;
    },

    register({ email, displayName, password }) {
      const trimmedEmail = String(email || "").trim();
      if (!trimmedEmail) throw new Error("Enter an email address.");
      const users = loadUsersFromStorage();
      const existing = users.find(
        (u) => u.email.toLowerCase() === trimmedEmail.toLowerCase()
      );
      if (existing) {
        throw new Error("An account with that email already exists.");
      }
      const record = {
        id: newUserId(),
        email: trimmedEmail,
        display_name: String(displayName || "").trim() || trimmedEmail,
        auth_provider: "email",
        simulated: false,
        password_hash: hashPassword(password),
      };
      users.push(record);
      saveUsersToStorage(users);
      const user = publicUserRecord(record);
      this.user = user;
      saveSessionToStorage(user);
      return user;
    },

    signIn({ email, password }) {
      const trimmedEmail = String(email || "").trim();
      const users = loadUsersFromStorage();
      const record = users.find(
        (u) =>
          u.email.toLowerCase() === trimmedEmail.toLowerCase() &&
          u.password_hash === hashPassword(password) &&
          u.auth_provider === "email"
      );
      if (!record) throw new Error("Email or password is incorrect.");
      const user = publicUserRecord(record);
      this.user = user;
      saveSessionToStorage(user);
      return user;
    },

    signOut() {
      this.user = null;
      saveSessionToStorage(null);
    },

    // `simulatedSocialSignIn(provider)` returns a fake session for Google
    // or Microsoft without contacting the provider. The resulting session
    // carries `simulated: true` so the UI can label it clearly.
    simulatedSocialSignIn(provider) {
      if (!["google", "microsoft"].includes(provider)) {
        throw new Error(`Unknown provider: ${provider}`);
      }
      const users = loadUsersFromStorage();
      const placeholderEmail = `${provider}-simulated@massanapp.local`;
      let record = users.find(
        (u) => u.email === placeholderEmail && u.auth_provider === provider
      );
      if (!record) {
        record = {
          id: newUserId(),
          email: placeholderEmail,
          display_name:
            provider === "google" ? "Google user" : "Microsoft user",
          auth_provider: provider,
          simulated: true,
        };
        users.push(record);
        saveUsersToStorage(users);
      }
      const user = publicUserRecord(record);
      this.user = user;
      saveSessionToStorage(user);
      return user;
    },
  });

  // Catalog store: venue, events, and per-event content. Loaded from the
  // seed JSON so the prototype can run without Supabase credentials.
  Alpine.store("catalog", {
    venue: null,
    events: [],
    news: [],
    articles: [],
    program: [],
    exhibitors: [],
    speakers: [],
    loading: true,
    error: null,

    async init() {
      try {
        const data = await loadCatalog();
        this.venue = data.venue ?? null;
        this.events = data.events ?? [];
        this.news = data.news ?? [];
        this.articles = data.articles ?? [];
        this.program = data.program ?? [];
        this.exhibitors = data.exhibitors ?? [];
        this.speakers = data.speakers ?? [];
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    },

    eventById(id) {
      return this.events.find((e) => e.id === id) ?? null;
    },
    newsForEvent(eventId) {
      return this.news
        .filter((n) => n.event_id === eventId)
        .sort((a, b) => (b.published_at || "").localeCompare(a.published_at || ""));
    },
    articlesForEvent(eventId) {
      return this.articles.filter((a) => a.event_id === eventId);
    },
    programForEvent(eventId) {
      return this.program
        .filter((p) => p.event_id === eventId)
        .sort((a, b) => {
          const d = (a.day || "").localeCompare(b.day || "");
          return d !== 0 ? d : (a.start_time || "").localeCompare(b.start_time || "");
        });
    },
    exhibitorsForEvent(eventId) {
      return this.exhibitors
        .filter((e) => e.event_id === eventId)
        .sort((a, b) => a.name.localeCompare(b.name));
    },
    exhibitorById(id) {
      return this.exhibitors.find((e) => e.id === id) ?? null;
    },
    speakerById(id) {
      return this.speakers.find((s) => s.id === id) ?? null;
    },
    practicalInfoForEvent(eventId) {
      // Shared venue data plus per-event overrides. Event overrides only
      // replace the specific fields that legitimately differ; transport,
      // parking, restaurants, and security stay shared across events.
      const ev = this.eventById(eventId);
      return {
        venue: this.venue,
        overrides: ev?.overrides ?? {},
      };
    },
  });

  // Filter state for the calendar view.
  Alpine.store("filters", {
    query: "",
    type: "",
    category: "",
    month: "",
  });
});

function formatDates(event) {
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

function monthLabel(iso) {
  if (!iso) return "";
  const d = new Date(iso);
  return d.toLocaleDateString("en-GB", { month: "long", year: "numeric" });
}

function calendarView() {
  return {
    get types() {
      return uniqueSorted(Alpine.store("catalog").events.map((e) => e.type));
    },
    get categories() {
      return uniqueSorted(Alpine.store("catalog").events.map((e) => e.category));
    },
    get months() {
      return uniqueSorted(
        Alpine.store("catalog").events.map((e) => monthLabel(e.start_date))
      );
    },
    formatDates,
    filtered() {
      const { query, type, category, month } = Alpine.store("filters");
      const q = query.trim().toLowerCase();
      return Alpine.store("catalog")
        .events.filter((e) => {
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

const OVERRIDE_LABELS = {
  entrance: "Entrance",
  bag_rules: "Bag rules",
  access_notes: "Access notes",
};

function eventView() {
  return {
    sections: SECTION_LABELS,
    exhibitorQuery: "",
    formatDates,
    formatNewsDate,
    formatDayHeading,
    event() {
      const id = Alpine.store("app").eventId;
      return id ? Alpine.store("catalog").eventById(id) : null;
    },
    news() {
      const ev = this.event();
      return ev ? Alpine.store("catalog").newsForEvent(ev.id) : [];
    },
    articles() {
      const ev = this.event();
      return ev ? Alpine.store("catalog").articlesForEvent(ev.id) : [];
    },
    programByDay() {
      const ev = this.event();
      if (!ev) return [];
      const sessions = Alpine.store("catalog").programForEvent(ev.id);
      const groups = new Map();
      for (const s of sessions) {
        if (!groups.has(s.day)) groups.set(s.day, []);
        groups.get(s.day).push(s);
      }
      return [...groups.entries()].map(([day, list]) => ({ day, sessions: list }));
    },
    speakerNames(session) {
      if (!session.speaker_ids?.length) return [];
      return session.speaker_ids
        .map((id) => Alpine.store("catalog").speakerById(id))
        .filter(Boolean)
        .map((s) => s.name);
    },
    filteredExhibitors() {
      const ev = this.event();
      if (!ev) return [];
      const list = Alpine.store("catalog").exhibitorsForEvent(ev.id);
      const q = this.exhibitorQuery.trim().toLowerCase();
      if (!q) return list;
      return list.filter(
        (e) =>
          e.name.toLowerCase().includes(q) ||
          (e.booth ?? "").toLowerCase().includes(q) ||
          (e.description ?? "").toLowerCase().includes(q)
      );
    },
    exhibitor() {
      const id = Alpine.store("app").exhibitorId;
      return id ? Alpine.store("catalog").exhibitorById(id) : null;
    },
    venue() {
      return Alpine.store("catalog").venue ?? {};
    },
    overrides() {
      return this.event()?.overrides ?? {};
    },
    hasOverrides() {
      return Object.keys(this.overrides()).length > 0;
    },
    overrideLabel(key) {
      return OVERRIDE_LABELS[key] ?? key.replace(/_/g, " ");
    },
  };
}

function formatNewsDate(iso) {
  if (!iso) return "";
  return new Date(iso).toLocaleDateString("en-GB", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

function formatDayHeading(iso) {
  if (!iso) return "";
  return new Date(iso).toLocaleDateString("en-GB", {
    weekday: "long",
    day: "numeric",
    month: "long",
  });
}

function uniqueSorted(values) {
  return [...new Set(values.filter(Boolean))].sort((a, b) => a.localeCompare(b));
}

const PROVIDER_LABELS = {
  email: "Email",
  google: "Google",
  microsoft: "Microsoft",
};

function providerLabel(provider) {
  return PROVIDER_LABELS[provider] ?? provider;
}

function authView() {
  return {
    mode: "signin",
    email: "",
    displayName: "",
    password: "",
    error: "",
    setMode(mode) {
      this.mode = mode;
      this.error = "";
    },
    submit() {
      this.error = "";
      try {
        if (this.mode === "register") {
          Alpine.store("session").register({
            email: this.email,
            displayName: this.displayName,
            password: this.password,
          });
        } else {
          Alpine.store("session").signIn({
            email: this.email,
            password: this.password,
          });
        }
        this.email = "";
        this.displayName = "";
        this.password = "";
        Alpine.store("app").afterAuth();
      } catch (err) {
        this.error = err.message || "Something went wrong.";
      }
    },
    socialSignIn(provider) {
      this.error = "";
      try {
        Alpine.store("session").simulatedSocialSignIn(provider);
        Alpine.store("app").afterAuth();
      } catch (err) {
        this.error = err.message || "Something went wrong.";
      }
    },
  };
}

function meView() {
  return {
    providerLabel,
    user() {
      return Alpine.store("session").user;
    },
    isSimulated() {
      return !!this.user()?.simulated;
    },
    signOut() {
      Alpine.store("session").signOut();
      Alpine.store("app").goCalendar();
    },
    openTickets() {
      Alpine.store("app").notImplemented("My Tickets");
    },
    openNewsletter() {
      Alpine.store("app").notImplemented("Newsletter preferences");
    },
  };
}
