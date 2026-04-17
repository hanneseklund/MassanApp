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
// Catalog data is loaded from the shared Supabase prototype project.
// The URL and publishable key come from window.MASSANAPP_ENV (set in
// assets/env.js). See docs/implementation-specification.md.

const EVENT_SUBVIEWS = [
  "home",
  "news",
  "articles",
  "program",
  "exhibitors",
  "practical",
  "newsletter",
];

// Simulated ticket-type catalog keyed by event.ticket_model. Kept in
// the frontend so the same catalog applies whether the event was
// loaded from catalog.json or Supabase.
const TICKET_TYPES = {
  public_ticket: [
    {
      id: "day_pass",
      label: "Day pass",
      description: "Entry for one day of the event.",
      price: "SEK 295",
    },
    {
      id: "full_event",
      label: "Full event pass",
      description: "Entry for every day of the event.",
      price: "SEK 595",
    },
  ],
  registration: [
    {
      id: "delegate",
      label: "Delegate registration",
      description: "Full congress access for all program days.",
      price: "EUR 450",
    },
  ],
};

function ticketTypesFor(event) {
  if (!event) return [];
  return TICKET_TYPES[event.ticket_model] ?? [];
}

function ticketCtaLabel(event) {
  if (!event) return "";
  if (event.ticket_model === "public_ticket") return "Get tickets";
  if (event.ticket_model === "registration") return "Register as delegate";
  return "";
}

const SECTION_LABELS = [
  { id: "news", label: "News" },
  { id: "articles", label: "Articles" },
  { id: "program", label: "Program" },
  { id: "exhibitors", label: "Exhibitors" },
  { id: "practical", label: "Practical info" },
  { id: "newsletter", label: "Newsletter" },
];

function supabaseClient() {
  const env = window.MASSANAPP_ENV;
  if (!env?.SUPABASE_URL || !env?.SUPABASE_ANON_KEY) {
    throw new Error(
      "Supabase config missing. Check that assets/env.js is loaded.",
    );
  }
  if (!window.supabase?.createClient) {
    throw new Error("Supabase JS SDK not loaded.");
  }
  return window.supabase.createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY);
}

async function loadCatalog() {
  const db = supabaseClient();
  const [venue, events, news, articles, program, exhibitors, speakers] =
    await Promise.all([
      db.from("venues").select("*").limit(1).single(),
      db.from("events").select("*"),
      db.from("news_items").select("*"),
      db.from("articles").select("*"),
      db.from("program_items").select("*"),
      db.from("exhibitors").select("*"),
      db.from("speakers").select("*"),
    ]);
  const firstError = [venue, events, news, articles, program, exhibitors, speakers]
    .map((r) => r.error)
    .find(Boolean);
  if (firstError) {
    throw new Error(`Failed to load catalog: ${firstError.message}`);
  }
  return {
    venue: venue.data,
    events: events.data,
    news: news.data,
    articles: articles.data,
    program: program.data,
    exhibitors: exhibitors.data,
    speakers: speakers.data,
  };
}

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

// Newsletter subscription persistence. In local-seed mode subscriptions
// live in localStorage; a Supabase-backed mode will replace these helpers.
const NEWSLETTER_KEY = "massan.newsletter";
const NEWSLETTER_PREF_KEYS = [
  "program_highlights",
  "news",
  "exhibitor_updates",
];

function defaultNewsletterPreferences() {
  return Object.fromEntries(NEWSLETTER_PREF_KEYS.map((k) => [k, true]));
}

function normalizeNewsletterPreferences(pref) {
  const out = defaultNewsletterPreferences();
  if (pref && typeof pref === "object") {
    for (const k of NEWSLETTER_PREF_KEYS) {
      if (k in pref) out[k] = !!pref[k];
    }
  }
  return out;
}

function loadNewsletterFromStorage() {
  try {
    const raw = localStorage.getItem(NEWSLETTER_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function saveNewsletterToStorage(list) {
  localStorage.setItem(NEWSLETTER_KEY, JSON.stringify(list));
}

function newSubscriptionId() {
  return "sub-" + Math.random().toString(36).slice(2, 10);
}

// Ticket persistence. In local-seed mode tickets live in localStorage
// as a flat list and are filtered by user_id at read time. A Supabase
// mode will swap this for a `tickets` table with RLS.
const TICKETS_KEY = "massan.tickets";

function loadTicketsFromStorage() {
  try {
    const raw = localStorage.getItem(TICKETS_KEY);
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function saveTicketsToStorage(list) {
  localStorage.setItem(TICKETS_KEY, JSON.stringify(list));
}

function newTicketId() {
  return "ticket-" + Math.random().toString(36).slice(2, 10);
}

// `simulatedPayment(order)` — always resolves after a short delay with
// a plausible transaction reference. No payment service is contacted.
function simulatedPayment(order) {
  return new Promise((resolve) => {
    const ref = "SIM-" + Math.random().toString(36).slice(2, 10).toUpperCase();
    setTimeout(() => resolve({ ok: true, transaction_ref: ref, order }), 600);
  });
}

// QR code for a ticket. The payload binds the ticket id to its event
// id with a salt so two tickets with the same id across events would
// still produce distinct payloads. The SVG renderer draws a visually
// QR-like matrix: three finder patterns in the corners and a
// hash-driven body fill. It is not a valid venue-access credential.
const QR_SALT = "stockholmsmassan-prototype";
const QR_SIZE = 25;

function ticketQrPayload(ticket) {
  return `massan:${ticket.id}:${ticket.event_id}:${QR_SALT}`;
}

function qrHashBytes(str, length) {
  const out = new Uint8Array(length);
  let h = 0x811c9dc5;
  for (let i = 0; i < str.length; i++) {
    h ^= str.charCodeAt(i);
    h = Math.imul(h, 0x01000193);
  }
  for (let i = 0; i < length; i++) {
    h ^= (i + 1) * 0x9e3779b1;
    h = Math.imul(h, 0x01000193);
    out[i] = (h >>> (i % 24)) & 0xff;
  }
  return out;
}

function ticketQrMatrix(payload) {
  const size = QR_SIZE;
  const m = Array.from({ length: size }, () => new Array(size).fill(0));
  const finders = [
    [0, 0],
    [0, size - 7],
    [size - 7, 0],
  ];
  for (const [fr, fc] of finders) {
    for (let r = 0; r < 7; r++) {
      for (let c = 0; c < 7; c++) {
        const on =
          r === 0 ||
          r === 6 ||
          c === 0 ||
          c === 6 ||
          (r >= 2 && r <= 4 && c >= 2 && c <= 4);
        m[fr + r][fc + c] = on ? 1 : 0;
      }
    }
  }
  const inFinderZone = (r, c) => {
    const tl = r < 8 && c < 8;
    const tr = r < 8 && c >= size - 8;
    const bl = r >= size - 8 && c < 8;
    return tl || tr || bl;
  };
  const bytes = qrHashBytes(payload, size * size);
  for (let r = 0; r < size; r++) {
    for (let c = 0; c < size; c++) {
      if (inFinderZone(r, c)) continue;
      m[r][c] = bytes[r * size + c] & 1;
    }
  }
  return m;
}

function ticketQrSvg(payload) {
  const matrix = ticketQrMatrix(payload);
  const size = matrix.length;
  const cell = 8;
  const quiet = 2;
  const total = (size + quiet * 2) * cell;
  let cells = "";
  for (let r = 0; r < size; r++) {
    for (let c = 0; c < size; c++) {
      if (!matrix[r][c]) continue;
      const x = (c + quiet) * cell;
      const y = (r + quiet) * cell;
      cells += `<rect x="${x}" y="${y}" width="${cell}" height="${cell}"/>`;
    }
  }
  return (
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${total} ${total}" ` +
    `width="100%" height="100%" role="img" aria-label="Ticket QR code">` +
    `<rect width="100%" height="100%" fill="#ffffff"/>` +
    `<g fill="#0f172a">${cells}</g></svg>`
  );
}

function generateTicketQr(ticket) {
  const payload = ticketQrPayload(ticket);
  return { payload, svg: ticketQrSvg(payload) };
}

// `simulatedEmail(kind, payload)` — no-op in production hosting; logs a
// structured record to the console during development so reviewers can
// see the would-be email. The kind values are documented in
// docs/implementation-specification.md.
function simulatedEmail(kind, payload) {
  const host = typeof window !== "undefined" ? window.location?.hostname : "";
  const isDev =
    !host ||
    host === "localhost" ||
    host === "127.0.0.1" ||
    host.endsWith(".local");
  if (isDev && typeof console !== "undefined") {
    console.info("[simulatedEmail]", kind, payload);
  }
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

    _linkNewsletter(user) {
      const store = Alpine.store("newsletter");
      if (store && typeof store.attachUser === "function") {
        store.attachUser(user);
      }
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
      this._linkNewsletter(user);
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
      this._linkNewsletter(user);
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
      this._linkNewsletter(user);
      return user;
    },
  });

  // Catalog store: venue, events, and per-event content. Loaded from
  // the shared Supabase prototype project via loadCatalog().
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

  // Newsletter store: subscriptions by (email/user, event). Persisted in
  // localStorage so anonymous signups survive reloads and sign-in
  // attaches matching anonymous subscriptions to the new user.
  Alpine.store("newsletter", {
    subscriptions: [],

    init() {
      this.subscriptions = loadNewsletterFromStorage().map((s) => ({
        ...s,
        preferences: normalizeNewsletterPreferences(s.preferences),
      }));
      const current = Alpine.store("session")?.user;
      if (current) this.attachUser(current);
    },

    _persist() {
      saveNewsletterToStorage(this.subscriptions);
    },

    findForEvent({ email, userId, eventId }) {
      const eid = eventId ?? null;
      return (
        this.subscriptions.find((s) => {
          if ((s.event_id ?? null) !== eid) return false;
          if (userId && s.user_id === userId) return true;
          if (email && (s.email || "").toLowerCase() === email.toLowerCase()) {
            return true;
          }
          return false;
        }) ?? null
      );
    },

    forUser(userId, email) {
      return this.subscriptions.filter(
        (s) =>
          (userId && s.user_id === userId) ||
          (email && (s.email || "").toLowerCase() === email.toLowerCase())
      );
    },

    subscribe({ email, userId, eventId, preferences }) {
      const cleanEmail = String(email || "").trim();
      if (!cleanEmail) throw new Error("Enter an email address.");
      const prefs = normalizeNewsletterPreferences(preferences);
      const eid = eventId ?? null;
      const existing = this.findForEvent({
        email: cleanEmail,
        userId,
        eventId: eid,
      });
      if (existing) {
        existing.email = cleanEmail;
        existing.preferences = prefs;
        if (userId && !existing.user_id) existing.user_id = userId;
        this._persist();
        return existing;
      }
      const record = {
        id: newSubscriptionId(),
        user_id: userId ?? null,
        email: cleanEmail,
        event_id: eid,
        preferences: prefs,
      };
      this.subscriptions.push(record);
      this._persist();
      return record;
    },

    updatePreferences(id, preferences) {
      const sub = this.subscriptions.find((s) => s.id === id);
      if (!sub) return null;
      sub.preferences = normalizeNewsletterPreferences({
        ...sub.preferences,
        ...preferences,
      });
      this._persist();
      return sub;
    },

    unsubscribe(id) {
      const before = this.subscriptions.length;
      this.subscriptions = this.subscriptions.filter((s) => s.id !== id);
      if (this.subscriptions.length !== before) this._persist();
    },

    // When a visitor signs in, link any anonymous subscriptions that
    // match their email to the new user id so preferences carry over.
    attachUser(user) {
      if (!user?.id || !user.email) return;
      let changed = false;
      for (const s of this.subscriptions) {
        if (
          !s.user_id &&
          (s.email || "").toLowerCase() === user.email.toLowerCase()
        ) {
          s.user_id = user.id;
          changed = true;
        }
      }
      if (changed) this._persist();
    },
  });

  // Tickets store: flat list persisted in localStorage and filtered by
  // user_id at read time. When Supabase is wired in, `add`, `forUser`,
  // and `hasForEvent` become the only hook points that need to switch
  // implementation.
  Alpine.store("tickets", {
    tickets: [],

    init() {
      this.tickets = loadTicketsFromStorage();
    },

    _persist() {
      saveTicketsToStorage(this.tickets);
    },

    forUser(userId) {
      if (!userId) return [];
      return this.tickets.filter((t) => t.user_id === userId);
    },

    forUserAndEvent(userId, eventId) {
      if (!userId || !eventId) return [];
      return this.tickets.filter(
        (t) => t.user_id === userId && t.event_id === eventId
      );
    },

    hasForEvent(userId, eventId) {
      return this.forUserAndEvent(userId, eventId).length > 0;
    },

    add(ticket) {
      this.tickets.push(ticket);
      this._persist();
      return ticket;
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
    ticketCtaLabel,
    event() {
      const id = Alpine.store("app").eventId;
      return id ? Alpine.store("catalog").eventById(id) : null;
    },
    hasTicket() {
      const ev = this.event();
      const user = Alpine.store("session").user;
      if (!ev || !user) return false;
      return Alpine.store("tickets").hasForEvent(user.id, ev.id);
    },
    startPurchase() {
      const ev = this.event();
      if (ev) Alpine.store("app").startPurchase(ev.id);
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
      Alpine.store("app").goTickets();
    },
    ticketCountHint() {
      const user = this.user();
      if (!user) return "";
      const count = Alpine.store("tickets").forUser(user.id).length;
      if (!count) return "No tickets yet";
      return count === 1 ? "1 ticket" : `${count} tickets`;
    },
  };
}

// Purchase view: three-step simulated ticket purchase flow. Local
// Alpine state owns the step counter and form values; the persisted
// ticket is written via `Alpine.store("tickets").add` once simulated
// payment succeeds.
function purchaseView() {
  return {
    step: 1,
    ticketTypeId: null,
    attendeeName: "",
    attendeeEmail: "",
    processing: false,
    error: "",
    confirmedTicket: null,
    formatDates,

    init() {
      this.$watch(
        () => [
          Alpine.store("app").view,
          Alpine.store("app").eventId,
          Alpine.store("session").user?.id,
        ],
        () => {
          if (Alpine.store("app").view === "purchase") this._hydrate();
        }
      );
      this._hydrate();
    },

    _hydrate() {
      this.step = 1;
      this.ticketTypeId = null;
      this.processing = false;
      this.error = "";
      this.confirmedTicket = null;
      const user = Alpine.store("session").user;
      this.attendeeName = user?.display_name ?? "";
      this.attendeeEmail = user?.email ?? "";
    },

    event() {
      const id = Alpine.store("app").eventId;
      return id ? Alpine.store("catalog").eventById(id) : null;
    },

    ticketTypes() {
      return ticketTypesFor(this.event());
    },

    selectedTicketType() {
      const id = this.ticketTypeId;
      return this.ticketTypes().find((t) => t.id === id) ?? null;
    },

    goToStep(step) {
      this.step = step;
      this.error = "";
    },

    continueToDetails() {
      if (!this.ticketTypeId) {
        this.error = "Pick a ticket type to continue.";
        return;
      }
      this.goToStep(2);
    },

    async confirm() {
      const ev = this.event();
      const type = this.selectedTicketType();
      if (!ev || !type) {
        this.error = "Pick a ticket type first.";
        this.step = 1;
        return;
      }
      const user = Alpine.store("session").user;
      if (!user) {
        this.error = "Sign in to complete the purchase.";
        return;
      }
      const name = String(this.attendeeName || "").trim();
      const email = String(this.attendeeEmail || "").trim();
      if (!name || !email) {
        this.error = "Attendee name and email are required.";
        return;
      }
      this.error = "";
      this.processing = true;
      try {
        const payment = await simulatedPayment({
          user_id: user.id,
          event_id: ev.id,
          ticket_type: type.id,
          attendee_email: email,
        });
        const ticket = {
          id: newTicketId(),
          user_id: user.id,
          event_id: ev.id,
          ticket_type: type.id,
          ticket_type_label: type.label,
          attendee_name: name,
          attendee_email: email,
          transaction_ref: payment.transaction_ref,
          purchased_at: new Date().toISOString(),
        };
        ticket.qr_payload = ticketQrPayload(ticket);
        Alpine.store("tickets").add(ticket);
        simulatedEmail("ticket_confirmation", {
          to: email,
          user_id: user.id,
          event_id: ev.id,
          event_name: ev.name,
          ticket_id: ticket.id,
          ticket_type: ticket.ticket_type,
          transaction_ref: ticket.transaction_ref,
        });
        this.confirmedTicket = ticket;
        this.step = 3;
      } catch (err) {
        this.error = err.message || "Could not complete the purchase.";
      } finally {
        this.processing = false;
      }
    },

    qrSvgFor(ticket) {
      return generateTicketQr(ticket).svg;
    },
  };
}

// My Tickets view: lists the signed-in user's tickets with QR-code
// presentation. Visitors arriving here without a session get a prompt
// to sign in.
function myTicketsView() {
  return {
    formatDates,
    signedIn() {
      return !!Alpine.store("session").user;
    },
    tickets() {
      const user = Alpine.store("session").user;
      if (!user) return [];
      return Alpine.store("tickets")
        .forUser(user.id)
        .slice()
        .sort((a, b) =>
          (b.purchased_at || "").localeCompare(a.purchased_at || "")
        );
    },
    eventName(ticket) {
      return (
        Alpine.store("catalog").eventById(ticket.event_id)?.name ??
        ticket.event_id
      );
    },
    eventForTicket(ticket) {
      return Alpine.store("catalog").eventById(ticket.event_id);
    },
    formatPurchaseDate(iso) {
      if (!iso) return "";
      return new Date(iso).toLocaleDateString("en-GB", {
        day: "numeric",
        month: "short",
        year: "numeric",
      });
    },
    qrSvgFor(ticket) {
      return generateTicketQr(ticket).svg;
    },
  };
}

const NEWSLETTER_TOPICS = [
  { key: "program_highlights", label: "Program highlights" },
  { key: "news", label: "News" },
  { key: "exhibitor_updates", label: "Exhibitor updates" },
];

// Newsletter signup form for an event's Newsletter subview. Pre-fills
// the email from the signed-in user when available, re-hydrates any
// prior subscription for this (email, event) pair, and toggles into a
// success state after submit.
function newsletterSignup() {
  return {
    topics: NEWSLETTER_TOPICS,
    email: "",
    preferences: defaultNewsletterPreferences(),
    submitted: false,
    error: "",

    event() {
      const id = Alpine.store("app").eventId;
      return id ? Alpine.store("catalog").eventById(id) : null;
    },

    init() {
      this.$watch(
        () => [Alpine.store("app").eventId, Alpine.store("session").user?.id],
        () => this._hydrate()
      );
      this._hydrate();
    },

    _hydrate() {
      this.error = "";
      this.submitted = false;
      const user = Alpine.store("session").user;
      const eventId = Alpine.store("app").eventId;
      this.email = user?.email ?? "";
      const existing = user
        ? Alpine.store("newsletter").findForEvent({
            email: user.email,
            userId: user.id,
            eventId,
          })
        : null;
      if (existing) {
        this.email = existing.email;
        this.preferences = { ...existing.preferences };
        this.submitted = true;
      } else {
        this.preferences = defaultNewsletterPreferences();
      }
    },

    submit() {
      this.error = "";
      try {
        const user = Alpine.store("session").user;
        const eventId = Alpine.store("app").eventId;
        const record = Alpine.store("newsletter").subscribe({
          email: this.email,
          userId: user?.id ?? null,
          eventId,
          preferences: this.preferences,
        });
        const event = Alpine.store("catalog").eventById(eventId);
        simulatedEmail("newsletter_confirmation", {
          to: record.email,
          user_id: record.user_id,
          event_id: record.event_id,
          event_name: event?.name ?? null,
          preferences: record.preferences,
        });
        this.submitted = true;
      } catch (err) {
        this.error = err.message || "Could not sign up.";
      }
    },

    editAgain() {
      this.submitted = false;
    },
  };
}

// Newsletter preferences list shown in My Pages. Lists the signed-in
// user's subscriptions by event plus a venue-wide row that can be
// toggled on and off.
function newsletterPreferences() {
  return {
    topics: NEWSLETTER_TOPICS,

    subscriptions() {
      const user = Alpine.store("session").user;
      if (!user) return [];
      return Alpine.store("newsletter")
        .forUser(user.id, user.email)
        .filter((s) => s.event_id !== null)
        .map((s) => ({
          ...s,
          event_name:
            Alpine.store("catalog").eventById(s.event_id)?.name ?? s.event_id,
        }))
        .sort((a, b) => (a.event_name || "").localeCompare(b.event_name || ""));
    },

    venueWide() {
      const user = Alpine.store("session").user;
      if (!user) return null;
      return Alpine.store("newsletter").findForEvent({
        email: user.email,
        userId: user.id,
        eventId: null,
      });
    },

    togglePreference(sub, key) {
      Alpine.store("newsletter").updatePreferences(sub.id, {
        [key]: !sub.preferences[key],
      });
    },

    unsubscribe(id) {
      Alpine.store("newsletter").unsubscribe(id);
    },

    toggleVenueWide() {
      const user = Alpine.store("session").user;
      if (!user) return;
      const existing = this.venueWide();
      if (existing) {
        Alpine.store("newsletter").unsubscribe(existing.id);
        return;
      }
      const record = Alpine.store("newsletter").subscribe({
        email: user.email,
        userId: user.id,
        eventId: null,
        preferences: defaultNewsletterPreferences(),
      });
      simulatedEmail("newsletter_confirmation", {
        to: record.email,
        user_id: record.user_id,
        event_id: null,
        event_name: "All Stockholmsmassan events",
        preferences: record.preferences,
      });
    },
  };
}
