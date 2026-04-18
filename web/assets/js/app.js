// MassanApp prototype — Alpine.js stores and view components.
//
// The prototype uses hash-based routing so views are linkable:
//   #/                                               -> calendar
//   #/event/<slug>                                   -> event home
//   #/event/<slug>/<subview>                         -> event subview
//   #/event/<slug>/exhibitors/<exhibitor-id>         -> exhibitor detail
//   #/event/<slug>/purchase                          -> simulated ticket purchase
//   #/auth                                           -> registration / sign-in
//   #/me                                             -> signed-in My Pages
//   #/tickets                                        -> My Tickets wallet
//
// Catalog data, authentication, tickets, and newsletter subscriptions
// all run against the shared Supabase prototype project. The URL and
// publishable key come from window.MASSANAPP_ENV (set in assets/env.js).
// See docs/implementation-specification.md.

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
// the frontend so the catalog stays stable regardless of how the
// event was loaded.
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

// Singleton Supabase client. A single client per page keeps the auth
// session consistent and lets `onAuthStateChange` fan out to stores.
let _supabaseClient = null;
function supabaseClient() {
  if (_supabaseClient) return _supabaseClient;
  const env = window.MASSANAPP_ENV;
  if (!env?.SUPABASE_URL || !env?.SUPABASE_ANON_KEY) {
    throw new Error(
      "Supabase config missing. Check that assets/env.js is loaded.",
    );
  }
  if (!window.supabase?.createClient) {
    throw new Error("Supabase JS SDK not loaded.");
  }
  _supabaseClient = window.supabase.createClient(
    env.SUPABASE_URL,
    env.SUPABASE_ANON_KEY,
  );
  return _supabaseClient;
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

// Map a Supabase auth user into the flat shape the UI consumes. Works
// for email-backed users and for anonymous users carrying simulated
// social-sign-in metadata.
function mapSupabaseUser(supabaseUser) {
  if (!supabaseUser) return null;
  const metadata = supabaseUser.user_metadata || {};
  const isAnonymous =
    supabaseUser.is_anonymous === true ||
    (!supabaseUser.email && !!metadata.simulated);
  const provider =
    metadata.auth_provider ||
    supabaseUser.app_metadata?.provider ||
    (isAnonymous ? "anonymous" : "email");
  const email = supabaseUser.email || metadata.email || "";
  const displayName =
    metadata.display_name || supabaseUser.email || "Guest";
  return {
    id: supabaseUser.id,
    email,
    display_name: displayName,
    auth_provider: provider,
    simulated: !!metadata.simulated,
  };
}

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
  return `massan:${ticket.id || "new"}:${ticket.event_id}:${QR_SALT}`;
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

function ticketQrSvgFor(ticket) {
  const payload = ticket.qr_payload || ticketQrPayload(ticket);
  return ticketQrSvg(payload);
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
  });

  // Session store: backed by Supabase Auth. `register`, `signIn`,
  // `signOut`, and `simulatedSocialSignIn` call into the Supabase JS
  // client; the store subscribes to `onAuthStateChange` so sign-in
  // state, including token refresh and persisted sessions across
  // reloads, propagates through the UI.
  Alpine.store("session", {
    user: null,
    loading: true,

    async init() {
      const db = supabaseClient();
      const { data, error } = await db.auth.getSession();
      if (error) {
        console.warn("Could not restore session:", error.message);
      }
      this.user = mapSupabaseUser(data?.session?.user);
      this.loading = false;
      db.auth.onAuthStateChange((_event, session) => {
        this.user = mapSupabaseUser(session?.user);
        Alpine.store("tickets")?._onSessionChange?.();
        Alpine.store("newsletter")?._onSessionChange?.();
      });
      Alpine.store("tickets")?._onSessionChange?.();
      Alpine.store("newsletter")?._onSessionChange?.();
    },

    get isSignedIn() {
      return !!this.user;
    },

    async register({ email, displayName, password }) {
      const trimmedEmail = String(email || "").trim();
      if (!trimmedEmail) throw new Error("Enter an email address.");
      const db = supabaseClient();
      const { data, error } = await db.auth.signUp({
        email: trimmedEmail,
        password: String(password || ""),
        options: {
          data: {
            display_name:
              String(displayName || "").trim() || trimmedEmail,
            auth_provider: "email",
          },
        },
      });
      if (error) throw new Error(error.message);
      if (!data.session) {
        throw new Error(
          "Check your email to confirm the account, then sign in.",
        );
      }
      return this.user;
    },

    async signIn({ email, password }) {
      const trimmedEmail = String(email || "").trim();
      const db = supabaseClient();
      const { error } = await db.auth.signInWithPassword({
        email: trimmedEmail,
        password: String(password || ""),
      });
      if (error) throw new Error("Email or password is incorrect.");
      return this.user;
    },

    async signOut() {
      const db = supabaseClient();
      const { error } = await db.auth.signOut();
      if (error) throw new Error(error.message);
    },

    // Simulated Google / Microsoft sign-in. Creates a Supabase
    // anonymous session and stamps provider metadata so the UI can
    // label the session as simulated. RLS treats the anonymous
    // user_id like any other for ticket and newsletter ownership.
    async simulatedSocialSignIn(provider) {
      if (!["google", "microsoft"].includes(provider)) {
        throw new Error(`Unknown provider: ${provider}`);
      }
      const displayName =
        provider === "google" ? "Google user" : "Microsoft user";
      const placeholderEmail = `${provider}-simulated@massanapp.local`;
      const db = supabaseClient();
      const { error } = await db.auth.signInAnonymously({
        options: {
          data: {
            auth_provider: provider,
            simulated: true,
            display_name: displayName,
            email: placeholderEmail,
          },
        },
      });
      if (error) {
        throw new Error(
          `Could not start simulated ${provider} sign-in: ${error.message}`,
        );
      }
      return this.user;
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

  // Tickets store: mirrors the signed-in user's rows from
  // public.tickets. Row Level Security filters to rows where
  // auth.uid() = user_id, so a plain `select` returns only the
  // signed-in user's tickets. Inserts go through the Supabase client.
  Alpine.store("tickets", {
    tickets: [],
    loading: false,
    error: null,

    init() {},

    async _onSessionChange() {
      const user = Alpine.store("session").user;
      if (!user) {
        this.tickets = [];
        return;
      }
      this.loading = true;
      this.error = null;
      const db = supabaseClient();
      const { data, error } = await db
        .from("tickets")
        .select("*")
        .order("purchased_at", { ascending: false });
      this.loading = false;
      if (error) {
        console.warn("Could not load tickets:", error.message);
        this.error = error.message;
        this.tickets = [];
        return;
      }
      this.tickets = data || [];
    },

    forUser(userId) {
      if (!userId) return [];
      return this.tickets.filter((t) => t.user_id === userId);
    },

    forUserAndEvent(userId, eventId) {
      if (!userId || !eventId) return [];
      return this.tickets.filter(
        (t) => t.user_id === userId && t.event_id === eventId,
      );
    },

    hasForEvent(userId, eventId) {
      return this.forUserAndEvent(userId, eventId).length > 0;
    },

    async add(ticket) {
      const db = supabaseClient();
      const row = {
        user_id: ticket.user_id,
        event_id: ticket.event_id,
        ticket_type: ticket.ticket_type,
        ticket_type_label: ticket.ticket_type_label,
        attendee_name: ticket.attendee_name,
        attendee_email: ticket.attendee_email,
        qr_payload: ticket.qr_payload,
        transaction_ref: ticket.transaction_ref,
        purchased_at: ticket.purchased_at,
      };
      const { data, error } = await db
        .from("tickets")
        .insert(row)
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      this.tickets.unshift(data);
      return data;
    },
  });

  // Newsletter store: for signed-in users, mirrors their rows in
  // public.newsletter_subscriptions (including the venue-wide row
  // where event_id IS NULL). Anonymous signups insert through the
  // "anyone insert newsletter" RLS policy but cannot be read back,
  // so the store only carries in-session state for those.
  Alpine.store("newsletter", {
    subscriptions: [],
    loading: false,
    error: null,

    init() {},

    async _onSessionChange() {
      const user = Alpine.store("session").user;
      if (!user) {
        this.subscriptions = [];
        return;
      }
      this.loading = true;
      this.error = null;
      const db = supabaseClient();
      const { data, error } = await db
        .from("newsletter_subscriptions")
        .select("*");
      this.loading = false;
      if (error) {
        console.warn("Could not load newsletter subscriptions:", error.message);
        this.error = error.message;
        this.subscriptions = [];
        return;
      }
      this.subscriptions = (data || []).map((s) => ({
        ...s,
        preferences: normalizeNewsletterPreferences(s.preferences),
      }));
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

    forUser(userId) {
      if (!userId) return [];
      return this.subscriptions.filter((s) => s.user_id === userId);
    },

    async subscribe({ email, userId, eventId, preferences }) {
      const cleanEmail = String(email || "").trim();
      if (!cleanEmail) throw new Error("Enter an email address.");
      const prefs = normalizeNewsletterPreferences(preferences);
      const eid = eventId ?? null;
      if (userId) {
        const existing = this.findForEvent({
          email: cleanEmail,
          userId,
          eventId: eid,
        });
        if (existing) {
          return this._updateRow(existing.id, { email: cleanEmail, preferences: prefs });
        }
      }
      const db = supabaseClient();
      const row = {
        user_id: userId ?? null,
        email: cleanEmail,
        event_id: eid,
        preferences: prefs,
      };
      // Anonymous inserts can't chain `.select()`: the SELECT RLS policy
      // on newsletter_subscriptions requires `auth.uid() = user_id`, and
      // RETURNING the just-inserted row under that policy raises a
      // 42501 RLS violation. Omit the representation for anon and
      // synthesize the UI record from the submitted payload.
      if (!userId) {
        const { error } = await db
          .from("newsletter_subscriptions")
          .insert(row);
        if (error) throw new Error(error.message);
        return {
          id: null,
          user_id: null,
          email: cleanEmail,
          event_id: eid,
          preferences: prefs,
        };
      }
      const { data, error } = await db
        .from("newsletter_subscriptions")
        .insert(row)
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      const normalized = {
        ...data,
        preferences: normalizeNewsletterPreferences(data.preferences),
      };
      this.subscriptions.push(normalized);
      return normalized;
    },

    async updatePreferences(id, preferencesPatch) {
      const sub = this.subscriptions.find((s) => s.id === id);
      if (!sub) return null;
      const merged = normalizeNewsletterPreferences({
        ...sub.preferences,
        ...preferencesPatch,
      });
      return this._updateRow(id, { preferences: merged });
    },

    async _updateRow(id, patch) {
      const db = supabaseClient();
      const { data, error } = await db
        .from("newsletter_subscriptions")
        .update(patch)
        .eq("id", id)
        .select("*")
        .single();
      if (error) throw new Error(error.message);
      const normalized = {
        ...data,
        preferences: normalizeNewsletterPreferences(data.preferences),
      };
      const idx = this.subscriptions.findIndex((s) => s.id === id);
      if (idx >= 0) this.subscriptions[idx] = normalized;
      else this.subscriptions.push(normalized);
      return normalized;
    },

    async unsubscribe(id) {
      const db = supabaseClient();
      const { error } = await db
        .from("newsletter_subscriptions")
        .delete()
        .eq("id", id);
      if (error) throw new Error(error.message);
      this.subscriptions = this.subscriptions.filter((s) => s.id !== id);
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
    formatShortDate,
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

// Short-form single-date formatter used for news items, ticket
// purchase dates, and similar single-point dates. `formatDates`
// handles event date ranges separately.
function formatShortDate(iso) {
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
  anonymous: "Guest",
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
    processing: false,
    setMode(mode) {
      this.mode = mode;
      this.error = "";
    },
    async submit() {
      if (this.processing) return;
      this.error = "";
      this.processing = true;
      try {
        if (this.mode === "register") {
          await Alpine.store("session").register({
            email: this.email,
            displayName: this.displayName,
            password: this.password,
          });
        } else {
          await Alpine.store("session").signIn({
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
      } finally {
        this.processing = false;
      }
    },
    async socialSignIn(provider) {
      if (this.processing) return;
      this.error = "";
      this.processing = true;
      try {
        await Alpine.store("session").simulatedSocialSignIn(provider);
        Alpine.store("app").afterAuth();
      } catch (err) {
        this.error = err.message || "Something went wrong.";
      } finally {
        this.processing = false;
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
    async signOut() {
      try {
        await Alpine.store("session").signOut();
      } catch (err) {
        console.warn("Sign-out failed:", err.message);
      }
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
        const draft = {
          user_id: user.id,
          event_id: ev.id,
          ticket_type: type.id,
          ticket_type_label: type.label,
          attendee_name: name,
          attendee_email: email,
          transaction_ref: payment.transaction_ref,
          purchased_at: new Date().toISOString(),
        };
        draft.qr_payload = ticketQrPayload(draft);
        const ticket = await Alpine.store("tickets").add(draft);
        // If the returned row did not include a persisted qr_payload,
        // fall back to the draft so the confirmation screen still has one.
        if (!ticket.qr_payload) ticket.qr_payload = draft.qr_payload;
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

    qrSvgFor: ticketQrSvgFor,
  };
}

// My Tickets view: lists the signed-in user's tickets with QR-code
// presentation. Visitors arriving here without a session get a prompt
// to sign in.
function myTicketsView() {
  return {
    formatDates,
    formatShortDate,
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
    qrSvgFor: ticketQrSvgFor,
  };
}

const NEWSLETTER_TOPICS = [
  { key: "program_highlights", label: "Program highlights" },
  { key: "news", label: "News" },
  { key: "exhibitor_updates", label: "Exhibitor updates" },
];

// Newsletter signup form for an event's Newsletter subview. Pre-fills
// the email from the signed-in user when available, re-hydrates any
// prior subscription for this (user, event) pair from Supabase, and
// toggles into a success state after submit. Anonymous signups show a
// success state in-session but cannot be re-read after reload because
// RLS on newsletter_subscriptions requires `auth.uid() = user_id`.
function newsletterSignup() {
  return {
    topics: NEWSLETTER_TOPICS,
    email: "",
    preferences: defaultNewsletterPreferences(),
    submitted: false,
    processing: false,
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

    async submit() {
      if (this.processing) return;
      this.error = "";
      this.processing = true;
      try {
        const user = Alpine.store("session").user;
        const eventId = Alpine.store("app").eventId;
        const record = await Alpine.store("newsletter").subscribe({
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
      } finally {
        this.processing = false;
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
        .forUser(user.id)
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

    async togglePreference(sub, key) {
      try {
        await Alpine.store("newsletter").updatePreferences(sub.id, {
          [key]: !sub.preferences[key],
        });
      } catch (err) {
        console.warn("Could not update preference:", err.message);
      }
    },

    async unsubscribe(id) {
      try {
        await Alpine.store("newsletter").unsubscribe(id);
      } catch (err) {
        console.warn("Could not unsubscribe:", err.message);
      }
    },

    async toggleVenueWide() {
      const user = Alpine.store("session").user;
      if (!user) return;
      const existing = this.venueWide();
      if (existing) {
        try {
          await Alpine.store("newsletter").unsubscribe(existing.id);
        } catch (err) {
          console.warn("Could not unsubscribe venue-wide:", err.message);
        }
        return;
      }
      try {
        const record = await Alpine.store("newsletter").subscribe({
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
      } catch (err) {
        console.warn("Could not subscribe venue-wide:", err.message);
      }
    },
  };
}
