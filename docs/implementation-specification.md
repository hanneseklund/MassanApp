# MassanApp Implementation Specification

This document defines how the MassanApp prototype is built. It is derived
from `docs/functional-specification.md` and must stay consistent with it.
Anything here that conflicts with the functional specification is a bug
in this document.

## Technology stack

- Frontend: static HTML, CSS, and JavaScript, with Alpine.js for
  client-side state and reactivity. Alpine.js is delivered via a CDN
  script tag or a small vendored copy so the frontend can remain buildless
  for the prototype.
- Hosting: Cloudflare Pages. The site is deployable as static assets.
- Backend: Supabase project hosting Postgres, Auth, and optional Storage.
  Supabase Auth handles email sign-up and sign-in through the Supabase
  JavaScript client. Social sign-in for Google and Microsoft is simulated
  on top of Supabase anonymous sessions (see the "User" entity under Data
  model and "Simulated integrations" below), structured so that real
  Supabase OAuth providers can replace it later.
- Data access: Supabase JavaScript client from the frontend. No custom
  backend service is introduced in the prototype.
- Icons and fonts: open web assets only. No paid SDKs.

This stack matches the prototype constraints in issue #1.

## Repository layout

The prototype aims for a shallow, readable layout:

```
/                       repo root
  README.md             project intro and doc pointers
  AGENTS.md             agent workflow rules
  docs/                 specifications and research
  web/                  static frontend (Cloudflare Pages root)
    index.html          app shell
    assets/
      css/              stylesheets
      env.js            committed Supabase URL + anon key
      images/           static images (event hero images live under events/)
      js/               ES modules (see "Frontend app structure" below)
    data/               reference copy of the seed shape (not loaded at runtime)
  supabase/             Supabase migrations and seed scripts
    migrations/
    seed/
  agent/                agent task queues
```

This layout is a target, not a completed state. Scaffolding tasks are
allowed to create these directories as they are needed.

## Frontend architecture

### App shell

The frontend is a single-page prototype built around a small number of
views:

- `calendar` — the upcoming-events calendar.
- `event` — the selected event's mini-homepage. The event hero and
  section navigation render for every event subview. The event view
  has a default `home` subview (the landing state when an event is
  first opened) and named subviews for News, Articles, Program,
  Exhibitor index, Exhibitor detail, Practical information, and
  Newsletter. Hash routes that target an event without a subview
  (for example `#/event/nordbygg-2026`) resolve to `home`.
- `auth` — registration and sign-in.
- `me` — logged-in "My Pages", with profile basics, a link to My
  Tickets, and newsletter preferences (including the venue-wide
  "All Stockholmsmassan events" toggle).
- `tickets` — the signed-in user's My Tickets wallet. Reached from
  `me`, from the purchase confirmation screen, and from the
  "View ticket" affordance on an event home view.
- `purchase` — three-step simulated ticket purchase scoped to the
  currently selected event. A visitor who lands here while signed
  out is routed through `auth` and returned afterwards.

View switching is driven by hash-based routing: the URL hash is the
canonical route and Alpine.js state mirrors it. `stores/app.js` parses
the hash on load, subscribes to `hashchange`, and exposes navigation
verbs (`goCalendar`, `selectEvent`, `goEventSubview`, `goAuth`,
`goMe`, `goTickets`, `startPurchase`) that write
`window.location.hash`; the parsed state in turn drives which view
renders. The supported routes are:

```
#/                                           calendar
#/event/<slug>                               event home
#/event/<slug>/<subview>                     event subview
#/event/<slug>/exhibitors/<exhibitor-id>     exhibitor detail
#/event/<slug>/purchase                      simulated ticket purchase
#/auth                                       registration / sign-in
#/me                                         signed-in My Pages
#/tickets                                    My Tickets wallet
```

`<subview>` is one of `home`, `news`, `articles`, `program`,
`exhibitors`, `practical`, or `newsletter`. An unknown or missing
subview resolves to `home` so a stale or hand-edited link still lands
on the event's main page.

### Frontend app structure

The frontend is buildless: `web/` is served directly and no bundler,
transpiler, or package step runs over the JavaScript. Browser-native
ES modules carry the split. `web/index.html` loads the entrypoint with
`<script type="module" src="assets/js/app.js">`.

One view per file is normative. `web/assets/js/app.js` is a thin
module that imports every store factory, every view factory, and the
simulation helpers they need, and registers them on the
`alpine:init` event. Each Alpine view (and each Alpine store) lives in
its own file so a reviewer can open the single file that backs a given
template. The layout is:

```
web/assets/js/
  app.js                       entrypoint; registers stores and view
                               factories on alpine:init
  i18n.js                      UI translation table (en, sv) +
                               translate(), activeTranslate(),
                               dateLocaleFor() helpers
  supabase.js                  singleton Supabase JS client
  util/
    dates.js                   formatDates, formatShortDate,
                               formatDayHeading, monthLabel, uniqueSorted
    sections.js                SECTION_LABELS, ticketCtaLabel,
                               ticketTypesFor, canonicalTicketTypeLabel
    calendar.js                todayLocalIso, isUpcoming,
                               upcomingEvents, eventMatchesQuery,
                               filterEvents (pure filter/sort behind
                               the calendar view)
    placeholders.js            logoDataUri, avatarDataUri (deterministic
                               SVG fallbacks for exhibitors and speakers)
  simulations/
    qr.js                      ticketQrPayload, ticketQrSvgFor +
                               internal hash / matrix helpers
    payment.js                 simulatedPayment
    email.js                   simulatedEmail
  newsletter/
    preferences.js             default/normalize preferences,
                               NEWSLETTER_PREF_KEYS, NEWSLETTER_TOPICS
  stores/
    app.js                     Alpine.store("app", ...) (navigation,
                               hash routing, post-auth return target).
                               Exports `parseHash` and `buildHash` as
                               named exports so the unit suite can test
                               the routing table without Alpine.
    lang.js                    Alpine.store("lang", ...) (active UI
                               language, localStorage persistence,
                               t(key) translator)
    session.js                 Alpine.store("session", ...) (Supabase
                               Auth mapping)
    catalog.js                 Alpine.store("catalog", ...) (venue,
                               events, news, articles, program,
                               exhibitors, speakers)
    tickets.js                 Alpine.store("tickets", ...)
    newsletter.js              Alpine.store("newsletter", ...)
    filters.js                 Alpine.store("filters", ...) (calendar
                               free-text, type, category, month)
  views/
    calendar.js                calendarView()
    event.js                   eventView()
    auth.js                    authView()
    me.js                      meView()
    purchase.js                purchaseView()
    my-tickets.js              myTicketsView()
    newsletter-signup.js       newsletterSignup()
    newsletter-preferences.js  newsletterPreferences()
```

The view factory names (`calendarView`, `eventView`, `authView`,
`meView`, `purchaseView`, `myTicketsView`, `newsletterSignup`,
`newsletterPreferences`) are exposed on `window` inside the
`alpine:init` handler so the `x-data="<factory>()"` bindings in
`index.html` continue to resolve. Stores keep their existing ids
(`app`, `session`, `catalog`, `tickets`, `newsletter`, `filters`).

When adding a new view or store, place it in its own module under
`views/` or `stores/` and import it from `app.js`. Do not inline new
view or store definitions into `app.js` or into another view's file.

### State management

Alpine.js stores and components own the following state:

- `app`: current view, selected event, selected event subview, selected
  exhibitor, simulated-mode flag, and post-auth return target.
- `lang`: active UI language (`en` or `sv`), the list of supported
  languages, and a `t(key, params)` translator backed by
  `web/assets/js/i18n.js`. The chosen language is persisted to
  `localStorage` under `massanapp_lang` so it survives reloads; the
  default on first load is English. `dateLocale()` returns the Intl
  locale used by the date formatters in `util/dates.js`. Templates
  read translations as `$store.lang.t('key')` so a switch re-renders
  every bound label reactively.
- `session`: the Supabase Auth user mapped into a flat record with `id`,
  `email`, `display_name`, `auth_provider`, and `simulated` flags. The
  store subscribes to `supabase.auth.onAuthStateChange` so that sign-in,
  sign-out, and token refresh propagate to the UI.
- `catalog`: venue, events, news, articles, program items, exhibitors,
  and speakers loaded from the shared Supabase project, plus
  `loading` / `error` flags for the initial fetch.
- `filters`: free-text query, type, category, and month filters for the
  calendar view.
- `tickets`: the signed-in user's ticket rows, loaded from
  `public.tickets` through RLS and refetched on sign-in. Ticket inserts
  go through the Supabase client so RLS enforces ownership.
- `newsletter`: for signed-in users, subscription rows for the current
  user loaded from `public.newsletter_subscriptions` through RLS
  (including the venue-wide subscription where `event_id IS NULL`). For
  anonymous visitors the store holds only the in-session success state —
  the row exists in Supabase but cannot be read back through RLS until
  the visitor signs in.

In-progress ticket purchase state lives in the local Alpine component
behind the `purchase` view rather than in a store, because nothing
outside that view needs to read it.

Data is loaded from the shared Supabase prototype project. Supabase is
a hard dependency of the frontend: the calendar, event views, and
practical-info views all read from Postgres through the Supabase JS
client. The earlier `web/data/catalog.json` fallback is retained only
as a reference copy of the seed shape; the app does not read it at
runtime.

### Catalog loading

On first app load the `catalog` store issues seven parallel `select *`
queries against the shared project: `venues` (single row),
`events`, `news_items`, `articles`, `program_items`, `exhibitors`,
and `speakers`. The rows are kept in memory for the life of the
session and filtered per event in view components. The Supabase URL
and publishable (anon) key are read from `window.MASSANAPP_ENV`, set
by `web/assets/env.js` (committed) with optional override from
`web/assets/env.local.js` (gitignored).

If the Supabase queries fail, the app surfaces the error through the
`catalog.error` state and the calendar view shows a failure message
instead of silently falling back to stale data.

### Alpine.js usage rules

- One view per file. Every Alpine view component (`calendarView`,
  `eventView`, `authView`, `meView`, `purchaseView`, `myTicketsView`,
  `newsletterSignup`, `newsletterPreferences`, and any future
  component) lives in its own module under `web/assets/js/views/`, and
  every Alpine store lives in its own module under
  `web/assets/js/stores/`. See "Frontend app structure" above.
- Use Alpine `$store` for cross-view state (session, cart, selected
  event).
- Derived values go in Alpine `x-data` getters, not duplicated in the
  template.
- Avoid introducing a component framework (React, Vue, Svelte). If a UI
  need cannot be met in Alpine.js cleanly, propose a specification
  change.

### Styling

- Mobile-first CSS with a single stylesheet or a tiny utility layer.
- Layouts assume a narrow viewport (roughly 360-430 CSS pixels wide).
- No heavy CSS frameworks. Tailwind CDN is acceptable if it stays
  buildless.
- Visual language mirrors the Stockholmsmässan venue site
  (<https://stockholmsmassan.se/>). Design tokens live at the top of
  `web/assets/css/app.css` as CSS custom properties:
  - Ink (primary text, headings, chrome): `#002e77` — the SM deep navy.
  - Accent (primary CTAs, focus ring): `#0646fb` — the SM electric
    blue. Hover: `#0335c9`.
  - Link (inline hyperlinks, subtle affordances): `#066aab`.
  - Surface: `#ffffff`. App background: `#f4f5f7`. Border: `#d8dde8`
    (strong variant `#b4bdd1`).
  - Corner radius: `4px` for controls and cards, `999px` for pill tabs
    and chips. This matches SM's flat, slightly-rounded style.
  - Typography: `Inter` from Google Fonts as an open-source stand-in
    for the proprietary LabGrotesque used on the venue site, with a
    `"Helvetica Neue", Helvetica, Arial, sans-serif` fallback chain.
    Headings are set in the same family with slightly tighter letter
    spacing (`-0.01em`).
- Buttons expose a primary style (filled electric blue), a secondary
  style (white with an accent outline), and a tertiary/ghost style
  (text-only, ink color). Hover and `:focus-visible` states are defined
  for every interactive control and the default focus outline uses the
  accent color against a 2px offset.
- Per-event `branding.primary_color` values in the seed remain as data
  for future per-event theming and do not override the global tokens.

### Internationalization

- All user-visible app chrome is looked up through `$store.lang.t(key)`
  against the dictionaries in `web/assets/js/i18n.js`. Currently
  supported languages are `en` and `sv`. English is the canonical
  source; missing keys in another language fall back to the English
  value.
- Event content (event names, summaries, news, articles, program
  items, exhibitor copy, and the shared venue's practical-info fields)
  is not translated by the app. The data model does not preclude
  per-language content; a later task can seed translated columns and
  extend the selectors without changing the i18n infrastructure.
- Date helpers in `util/dates.js` read the active language's Intl
  locale from `$store.lang.dateLocale()` so weekday and month names
  render in the active language.
- Persisted display fields must stay canonical to avoid flipping when
  a later viewer has a different language. The purchase flow uses
  `canonicalTicketTypeLabel(ticket_type)` (English) for
  `ticket_type_label`. Newer features that persist display strings
  should follow the same rule.
- Adding a new translation key: add it to both `en` and `sv` entries in
  `i18n.js`. The `tests/unit/i18n.test.mjs` suite asserts every key
  exists in every supported language via the `availableKeys(lang)`
  helper, so a one-sided key fails the unit run before it ships.
  Adding a new language: extend `SUPPORTED_LANGUAGES`,
  `LANGUAGE_LABELS`, `DATE_LOCALES`, and the `TRANSLATIONS` object,
  then update the chrome toggle if the two-language toggle no longer
  fits.

## Data model

The following entities capture the minimum needed to satisfy the
functional specification. Field lists are indicative and will be refined
during data loading.

### Venue (shared)

- `id`
- `name` (Stockholmsmassan)
- `address`
- `transport` (text or structured object)
- `parking` (text or structured object)
- `restaurants` (list of {name, description})
- `security` (text or structured object)
- `sustainability` (text) — ISO 20121 / sustainability-program note,
  reserved for later surfacing in the practical-info UI
- `maps` (optional list of venue/hall maps)

Exactly one venue record is expected in the prototype.

### Event

- `id` (slug, e.g. `nordbygg-2026`)
- `name`
- `subtitle` or short tagline
- `start_date`, `end_date`
- `category` (matches calendar categories)
- `type` (`Conference`, `Congress`, `Event`, `Public fair`, `Trade fair`)
- `audience_rule` (`public`, `professional`, `invite_only`) — hook only;
  not enforced in the prototype UI
- `ticket_model` (`public_ticket`, `registration`, `none`)
- `summary`
- `venue_id` (FK to Venue)
- `branding` (optional colors/logo; also carries `hero_image` as a
  relative path into `web/assets/images/events/` and `hero_image_credit`
  for attribution of scraped event imagery)
- `overrides` (JSON of event-specific practical-info overrides). The
  prototype recognises the following optional string keys; each is
  rendered under the event's Practical info section below the shared
  venue data, with a translated label resolved from the `overrides.*`
  i18n keys:
  - `entrance` — event-specific entrance or badge-pickup copy.
  - `bag_rules` — bag, luggage, or cloakroom copy for this event.
  - `access_notes` — access or seating notes for this event.
  Additional keys in the JSON render with a fallback label derived from
  the key (underscores replaced with spaces), so the catalog can carry
  forward-looking keys without breaking the view — but new keys should
  be added to `OVERRIDE_KEYS` in `web/assets/js/views/event.js` and to
  both language entries in `web/assets/js/i18n.js` so the label
  translates correctly.

### News item

- `id`, `event_id`, `published_at`, `title`, `body`, `hero_image`
  (optional). When set, the news card renders that image; otherwise the
  card falls back to the parent event's `branding.hero_image`.

### Article

- `id`, `event_id`, `title`, `body`, `hero_image` (optional)

### Program item (session)

- `id`, `event_id`, `day`, `start_time`, `end_time`, `title`,
  `description`, `location`, `track` (optional), `speaker_ids` (optional)

### Exhibitor

- `id`, `event_id`, `name`, `booth`, `description`, `website` (optional),
  `logo` (optional)

### Speaker (optional for congress events)

- `id`, `name`, `bio`, `affiliation`, `avatar` (optional)

### User

- `id`, `email`, `display_name`, `auth_provider` (`email`, `google`,
  `microsoft`, or `anonymous` as a defensive fallback when a session
  exposes no provider metadata), `simulated` (bool).
- Users are Supabase Auth accounts in `auth.users`. Email sign-up and
  sign-in use `supabase.auth.signUp` and
  `supabase.auth.signInWithPassword`; no password material is stored in
  the browser. `display_name` is carried in the Supabase user
  `user_metadata` so it survives across sessions.
- Simulated Google and Microsoft sign-in reuse Supabase's anonymous
  authentication (`supabase.auth.signInAnonymously`) and stamp
  `user_metadata` with `auth_provider = 'google' | 'microsoft'`,
  `simulated = true`, and a `display_name` / placeholder `email` the UI
  can show. The resulting anonymous user still has a stable `auth.uid()`
  so Row Level Security on tickets and newsletter subscriptions applies
  uniformly to both real and simulated sessions.
- The frontend maps the Supabase user into a flat `session.user` record
  with the fields above so the rest of the app can consume it without
  knowing whether the user is anonymous, simulated, or email-backed.

### Ticket

- `id`, `user_id`, `event_id`, `ticket_type`, `ticket_type_label`,
  `attendee_name`, `attendee_email`, `qr_payload`, `transaction_ref`,
  `purchased_at`
- Tickets live in `public.tickets` with Row Level Security so a user can
  read and insert only rows where `auth.uid() = user_id`. The frontend
  inserts a new row at the end of the simulated purchase flow and reads
  the signed-in user's rows for the My Tickets view. There is no
  `localStorage` tickets store.
- Available ticket types are derived from the event's `ticket_model`:
  - `public_ticket` events offer `day_pass` ("Day pass") and
    `full_event` ("Full event pass") at minimum.
  - `registration` events offer a single `delegate` ("Delegate
    registration") type.
  Ticket-type catalogs live in the frontend (not in seed JSON) so the
  same simulated catalog applies regardless of how an event was loaded.

### Newsletter subscription

- `id`, `user_id` (nullable for anonymous signup), `email`, `event_id`
  (nullable for venue-wide), `preferences` (JSON), `created_at`.
- `preferences` in the prototype is an object of boolean topic flags:
  `program_highlights`, `news`, and `exhibitor_updates`. All three
  default to `true` on signup. New topic keys may be added later;
  missing keys are treated as `true` so older records remain valid.
- Logical uniqueness is per (`user_id`, `event_id`) for signed-in users
  and per (`email`, `event_id`) for anonymous signups.
  `event_id IS NULL` represents the venue-wide "All Stockholmsmassan
  events" subscription. The prototype does not enforce uniqueness with a
  database constraint — the frontend re-uses the existing row when it
  finds one and the "anyone insert" RLS policy tolerates duplicate
  anonymous rows.
- Rows live in `public.newsletter_subscriptions`. RLS allows anyone to
  insert a row (so the anonymous signup form works without a session)
  but only the owning user to read or update their rows. Anonymous rows
  therefore persist in the database but are not readable back by the
  visitor who inserted them.

## Supabase usage

- Supabase Auth handles email sign-up, sign-in, and session management.
  Simulated Google and Microsoft sign-in ride on anonymous Supabase
  sessions so every signed-in user — real or simulated — has a stable
  `auth.uid()` (see "User" under Data model).
- Tables mirror the data model above. Row Level Security enforces that
  a user can read and write only their own tickets and newsletter
  subscriptions, while shared venue and event content is readable
  without authentication.
- Migrations live in `supabase/migrations/`. Seed data lives in
  `supabase/seed/` and may be a mix of SQL and JSON.
- The frontend talks to Supabase directly using the anon key. There is no
  separate API layer in the prototype.
- Email confirmation in Supabase Auth is left disabled for the shared
  prototype project so a fresh `signUp` produces a usable session
  immediately. The UI still handles the "no session returned" case
  defensively so that enabling confirmation later does not break the
  flow.

Supabase is a hard dependency for catalog loading — see the
"Catalog loading" section above. There is no runtime JSON fallback.

### Seed data layout

The authoritative seed is `supabase/seed/seed.sql`, applied to the
shared project via the workflow in `AGENTS.md`. The schema it targets
is defined in `supabase/migrations/`.

`web/data/catalog.json` is retained in the repository as a reference
copy of the seed shape so reviewers can inspect the expected data
without querying Supabase:

```
{
  "venue":      { ... one shared venue record ... },
  "events":     [ ... event records with venue_id and overrides ... ],
  "news":       [ ... news items keyed by event_id ... ],
  "articles":   [ ... articles keyed by event_id ... ],
  "program":    [ ... program items keyed by event_id ... ],
  "exhibitors": [ ... exhibitors keyed by event_id ... ],
  "speakers":   [ ... optional speakers for congress events ... ]
}
```

Per-entity `event_id` values match the `id` of the event they belong to.
The venue is a single object, not a list, because the prototype only
models Stockholmsmassan. When `seed.sql` changes, update
`catalog.json` in the same change so the reference copy stays useful.

## Simulated integrations

All simulations must be centralized and easy to replace:

- `simulatedSocialSignIn(provider)` — creates a Supabase anonymous
  session via `supabase.auth.signInAnonymously` and stamps the user's
  metadata with `auth_provider = provider` and `simulated = true`. No
  real OAuth request is made. The resulting `session.auth_provider` and
  `session.simulated` flags drive the visible "simulated" label.
- `simulatedPayment(order)` — returns a Promise that resolves after a
  short delay with `{ ok: true, transaction_ref }`. The reference is a
  plausible-looking string (e.g. `SIM-XXXXXXXX`) but no payment service
  is contacted. The delay lets the UI show a "processing" state.
- `simulatedEmail(kind, payload)` — logs the would-be email to the
  browser console on prototype hosts (local dev and the Cloudflare
  Pages preview at `*.pages.dev`) so reviewers and the smoke suite can
  see the event. Silent on any other host so a future non-prototype
  deployment does not leak the payload. Known `kind` values:
  `newsletter_confirmation` (sent on newsletter signup, including the
  venue-wide toggle) and `ticket_confirmation` (sent when a simulated
  ticket purchase completes). Email-registration confirmation mail is
  handled by Supabase Auth itself and is therefore not produced
  through `simulatedEmail`.
- `ticketQrPayload(ticket)` and `ticketQrSvgFor(ticket)` — together
  simulate a ticket QR. `ticketQrPayload` returns a payload string of
  the form `massan:<ticket-id>:<event-id>:<salt>` (so two tickets with
  the same id across events still produce distinct payloads).
  `ticketQrSvgFor` renders a QR-like SVG matrix deterministically
  derived from that payload — three finder patterns in the corners and
  a body fill driven by a hash of the payload — by calling the
  internal `ticketQrMatrix` and `ticketQrSvg` helpers. The result is
  visually recognizable as a QR code but is not a real QR-encoded
  credential, so it does not validate at a real venue.

Simulations must be clearly labeled in the UI during development and
testing, for example with a small "simulated" chip, so reviewers can see
that no real service is being hit.

## Event-first navigation implementation

- The `event` view is the root of its own navigation tree once an event is
  selected.
- Every event subview (News, Articles, Program, Exhibitors, Practical
  info, Newsletter) exposes a "Back to events" affordance in the top
  chrome.
- Switching events always routes through the calendar view so the
  "one event at a time" invariant stays visible.

## Shared venue data reuse

- Practical information screens read from the single Venue record first
  and then apply the event's `overrides`.
- Do not duplicate transport, parking, restaurant, or security copy per
  event. Override only the fields that legitimately differ for that
  event (for example, bag rules or special entrances).

## Accessibility and performance guidelines

- Target a good Lighthouse mobile score on a mid-range phone.
- No blocking third-party scripts other than Alpine.js and Supabase.
- Images are served at mobile-appropriate sizes. Use responsive `<img>`
  attributes.
- All interactive elements must be keyboard reachable and have accessible
  names.

## Security and privacy

- Never store payment details. The simulated payment flow must not
  collect card numbers.
- Treat email addresses as personal data even in the prototype: store
  only what the flows use; never log emails to the browser console in a
  non-development build.
- Do not commit real Supabase service keys. Only the publishable (anon)
  key is used at runtime and is committed to `web/assets/env.js` for the
  shared prototype project; a gitignored `web/assets/env.local.js` can
  override it for local dev against a different project. RLS in
  `supabase/migrations/` is what enforces access, not key secrecy.

## Deployability

- Cloudflare Pages deploys the `web/` directory as a static site.
- Supabase is a managed project and is provisioned out-of-band. The
  repository carries migrations, seed data, and the publishable (anon)
  key via `web/assets/env.js`; the service-role key is never committed.
- Running the frontend requires network access to the shared Supabase
  project for catalog loading, authentication, ticket purchase, and
  newsletter signup. There is no `localStorage` fallback for these
  flows: without Supabase the calendar errors out and auth, tickets,
  and newsletter all fail.

## Change control

Implementation changes must be consistent with the functional
specification. If an implementation decision requires a user-visible
change, update `docs/functional-specification.md` first per the workflow
rule in `AGENTS.md`.
