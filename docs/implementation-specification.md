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
  scripts/              one-off Node helpers for seed maintenance
                        (e.g. dual-language wrapping and translation
                        application) — run by hand, not part of any
                        build
  tests/                test suites
    unit/               node:test ES modules covering the pure
                        helpers in web/assets/js/util and the view
                        and store factories
    playwright/         Playwright smoke suite that mirrors the
                        manual checklist in the
                        installation-testing specification
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
  Exhibitor index, Exhibitor detail, Practical information, Food, and
  Newsletter. Hash routes that target an event without a subview
  (for example `#/event/nordbygg-2026`) resolve to `home`.
- `auth` — registration and sign-in.
- `me` — logged-in "My Pages", with profile basics, a link to My
  Tickets, and newsletter preferences (including the venue-wide
  "All Stockholmsmassan events" toggle).
- `tickets` — the signed-in user's My Tickets wallet. Reached from
  `me`, from the purchase confirmation screen, and from the
  "View ticket" affordance on an event home view.
- `purchase` — four-step simulated ticket purchase scoped to the
  currently selected event (pick ticket type, fill questionnaire,
  attendee details, confirm). A visitor who lands here while signed
  out is routed through `auth` and returned afterwards.
- `points` — the venue-wide Stockholmsmässan merchandise shop at
  `#/points`. Independent of any event selection. A visitor who
  lands here while signed out is routed through `auth` and returned
  afterwards, same pattern as `purchase` and the food flow.

View switching is driven by hash-based routing: the URL hash is the
canonical route and Alpine.js state mirrors it. `stores/app.js` parses
the hash on load, subscribes to `hashchange`, and exposes navigation
verbs (`goCalendar`, `selectEvent`, `goEventSubview`, `goEventFood`,
`selectExhibitor`, `backToExhibitors`, `goAuth`, `goMe`, `goTickets`,
`goPoints`, `startPurchase`, `afterAuth`) that write
`window.location.hash`; the parsed state in turn drives which view
renders. `goMe`, `goTickets`, `goPoints`, and `startPurchase` route
through the internal `_requireAuth` guard: if the session is signed
in they navigate directly, otherwise they stash the intended target
on `_preAuth` and redirect to `#/auth`. The auth view calls
`afterAuth()` once sign-in resolves to replay the stashed target.
`goEventFood(menuId)` is the variant used by the event landing's
food preview: it navigates to the event's food subview and stashes
the optionally-supplied `menuId` on `pendingFoodMenuId` so the food
view can preselect that menu on step 1 (see `pendingFoodMenuId`
below).

The `me`, `tickets`, `auth`, and `points` routes have no event
segment in their URL but inherit the currently selected event in
memory. `stores/app.js` keeps `eventId` populated across those
views and persists the last selected event to `localStorage` under
`massanapp.selected_event_id`, so the hamburger menu keeps showing
event-scoped entries and My Tickets can prioritize tickets for the
current event. The calendar route is the one that explicitly clears
the selection.
The supported routes are:

```
#/                                           calendar
#/event/<slug>                               event landing (stacked layout)
#/event/<slug>/news|articles|program|food    dedicated full-list page
#/event/<slug>/exhibitors                    dedicated exhibitor index
#/event/<slug>/exhibitors/<exhibitor-id>     exhibitor detail
#/event/<slug>/practical|newsletter          stacked landing + scroll to section
#/event/<slug>/purchase                      simulated ticket purchase
#/auth                                       registration / sign-in
#/me                                         signed-in My Pages
#/tickets                                    My Tickets wallet
#/points                                     venue-wide points shop
```

`<subview>` is one of `home`, `news`, `articles`, `program`,
`exhibitors`, `practical`, `food`, or `newsletter`. An unknown or
missing subview resolves to `home` so a stale or hand-edited link
still lands on the event's main page.

The event landing route (`home`) renders the hero followed by every
section in a stacked, scrollable layout. Each section that can grow
long (News, Articles, Program, Exhibitors, Food) shows up to the
first 5 items inline with a "see all" link to its dedicated
`#/event/<slug>/<section>` page; the dedicated page renders only the
full list plus a back link to the landing route. Practical info and
Newsletter render in full inline and have no dedicated page —
landing on `#/event/<slug>/practical` or
`#/event/<slug>/newsletter` is rewritten via `history.replaceState`
to the landing route, with a `pendingScrollSection` field on the
`app` store telling the event view to scroll the matching section
anchor (`event-section-practical` / `event-section-newsletter`) into
view. The `eventSubview` field stays in the app store because the
dedicated section routes still drive what the event view renders;
only the practical/newsletter routes are collapsed to the landing
view.

A parallel `pendingFoodMenuId` field on the `app` store carries a
food-menu id from the event landing's clickable food preview into
the food subview. `goEventFood(menuId)` navigates to
`#/event/<slug>/food` and stashes the id; the food view consumes it
on hydrate (`_consumePendingMenuId`) and preselects that menu on
step 1, matching the functional-spec behaviour where each preview
thumbnail jumps into the ordering flow with the clicked menu
selected. The id stays out of the URL because it is a one-shot
selection hint, not a routable state.

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
                               canonicalTranslate(), dateLocaleFor(),
                               availableKeys(), labelKey(),
                               translateLabel() helpers
                               (`labelKey` / `translateLabel` resolve
                               canonical-English seeded identifiers
                               like `event.type`, `event.category`,
                               and `program.track` into display
                               labels in the active language)
  supabase.js                  singleton Supabase JS client
  util/
    dates.js                   formatDates, formatShortDate,
                               formatDayHeading, monthLabel, uniqueSorted
    sections.js                SECTION_LABELS, ticketCtaLabel,
                               ticketTypesFor, canonicalTicketTypeLabel
    calendar.js                PAST_EVENT_GRACE_DAYS, todayLocalIso,
                               shiftIsoDate, isCalendarVisible,
                               isOngoingOrUpcoming,
                               calendarVisibleEvents, eventMatchesQuery,
                               filterEvents (pure filter/sort behind
                               the calendar view; events stay on the
                               list for 21 days after they end —
                               issue #26)
    placeholders.js            initialsFromName, logoDataUri,
                               avatarDataUri (deterministic SVG
                               fallbacks for exhibitors and speakers)
    food.js                    FOOD_MENUS, PICKUP_LOCATIONS,
                               RESTAURANTS, menuById, pickupById,
                               restaurantById, canonical*Label,
                               upcomingTimeslots, themeIdForEvent,
                               themedMenuForEvent (food ordering catalog,
                               30-minute timeslot generator, and per-event
                               themed-menu lookup driven by event.category)
    points.js                  POINTS_PER_TICKET (=100),
                               pointsForTicket(ticket),
                               pointsForFoodOrder(order),
                               parseSekPrice (private) — earning-rate
                               calculators used by the points store
    session-sync.js            SESSION_SYNC_STORE_IDS,
                               notifySessionStores(),
                               loadUserRows(store, options),
                               insertOwnedRow(store, options) — shared
                               by the user-scoped stores so the
                               clear-on-signed-out, select-plus-error
                               fetch contract and the
                               insert-plus-unshift write contract are
                               each written once
    redemption.js              createRedemptionController(config) —
                               shared per-session redemption state
                               (stockConsumed, pending, lastRedemption,
                               error) + remainingStock / canRedeem /
                               disabledReason / redeem /
                               dismissLastRedemption / reset behaviour
                               used by the event add-ons section on
                               views/event.js and the venue-wide points
                               shop on views/points-shop.js
    questionnaire.js           defaultQuestionnaire(event, profile),
                               subjectsFor(event),
                               buildQuestionnairePayload(form),
                               buildProfileUpdate(form),
                               PROFILE_FIELDS — ticket-purchase
                               questionnaire form state + JSONB
                               serialization used by views/purchase.js
    newsletter.js              defaultNewsletterPreferences,
                               normalizeNewsletterPreferences,
                               NEWSLETTER_PREF_KEYS, NEWSLETTER_TOPICS —
                               newsletter-preference shape shared by the
                               newsletter store and the signup /
                               preferences views
    i18n-content.js            pickLang(value, lang),
                               pickLangArray(value, lang) — render-time
                               resolver for dual-language seeded catalog
                               leaves (`jsonb { en, sv }`) with a
                               plain-string fallback used during the
                               transitional window before a column is
                               migrated
  simulations/
    qr.js                      ticketQrPayload, ticketQrSvgFor +
                               internal hash / matrix helpers
    payment.js                 simulatedPayment
    email.js                   simulatedEmail
  stores/
    app.js                     Alpine.store("app", ...) (navigation,
                               hash routing, post-auth return target).
                               Exports `parseHash` and `buildHash` as
                               named exports so the unit suite can test
                               the routing table without Alpine.
    lang.js                    Alpine.store("lang", ...) (active UI
                               language, localStorage persistence,
                               t(key) translator, pick(value) for
                               dual-language jsonb leaves,
                               label(prefix, value) for seeded
                               canonical-English identifiers, and
                               dateLocale() for the date helpers)
    session.js                 Alpine.store("session", ...) (Supabase
                               Auth mapping). Exports `mapSupabaseUser`
                               as a named export so the unit suite can
                               exercise the provider-detection branches
                               without a live Supabase session.
    catalog.js                 Alpine.store("catalog", ...) (venue,
                               events, news, articles, program,
                               exhibitors, speakers, point add-ons,
                               merchandise)
    tickets.js                 Alpine.store("tickets", ...)
    newsletter.js              Alpine.store("newsletter", ...)
    food-orders.js             Alpine.store("foodOrders", ...) (signed-in
                               user's rows from public.food_orders)
    points.js                  Alpine.store("points", ...) (signed-in
                               user's point_transactions, balance
                               getter, earn/redeem methods)
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
    food.js                    foodView()
    points-shop.js             pointsShopView()
```

The view factory names (`calendarView`, `eventView`, `authView`,
`meView`, `purchaseView`, `myTicketsView`, `newsletterSignup`,
`newsletterPreferences`, `foodView`, `pointsShopView`) are exposed on
`window` inside the `alpine:init` handler so the
`x-data="<factory>()"` bindings in `index.html` continue to resolve.
Stores keep their existing ids (`lang`, `app`, `session`, `catalog`,
`tickets`, `newsletter`, `foodOrders`, `points`, `filters`). `lang` is
registered first in `alpine:init` so store `init()` hooks that read
the active locale (date formatters, titles) see the right value on
first render.

When adding a new view or store, place it in its own module under
`views/` or `stores/` and import it from `app.js`. Do not inline new
view or store definitions into `app.js` or into another view's file.

### State management

Alpine.js stores and components own the following state:

- `app`: current view, selected event, selected event subview, selected
  exhibitor, post-auth return target, and the one-shot
  `pendingScrollSection` / `pendingFoodMenuId` selection hints
  consumed by the event and food views (see the `pendingScrollSection`
  and `pendingFoodMenuId` paragraphs under "App shell" above).
- `lang`: active UI language (`en` or `sv`), the list of supported
  languages, and a `t(key, params)` translator backed by
  `web/assets/js/i18n.js`. The chosen language is persisted to
  `localStorage` under `massanapp_lang` so it survives reloads; the
  default on first load is English. `dateLocale()` returns the Intl
  locale used by the date formatters in `util/dates.js`. Templates
  read translations as `$store.lang.t('key')` so a switch re-renders
  every bound label reactively.
- `session`: the Supabase Auth user mapped into a flat record with `id`,
  `email`, `display_name`, `auth_provider`, `simulated`, and a
  `profile` block holding the saved ticket-purchase general-profile
  answers (`gender`, `country`, `region`, `visit_type`, `company`,
  `role`) that the purchase view reads to pre-fill the questionnaire.
  The store exposes `loading` while the initial session restore is in
  flight, an `isSignedIn` getter, and `register`, `signIn`, `signOut`,
  and `simulatedSocialSignIn(provider)` methods that wrap the
  Supabase JS client. The store subscribes to
  `supabase.auth.onAuthStateChange` so that sign-in, sign-out, and
  token refresh propagate to the UI.
- `catalog`: venue, events, news, articles, program items, exhibitors,
  speakers, point add-ons, and merchandise loaded from the shared
  Supabase project, plus `loading` / `error` flags for the initial
  fetch.
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
  the visitor signs in. Exposes `subscribe`, `updatePreferences`, and
  `unsubscribe(id)` methods. `unsubscribe(id)` deletes the row via the
  owner-scoped DELETE policy added in migration 0002 and drops it from
  the in-memory `subscriptions` list; the newsletter-preferences view
  calls it both for the per-event "Unsubscribe" button and when the
  venue-wide toggle is switched off.
- `foodOrders`: the signed-in user's food order rows loaded from
  `public.food_orders` through RLS. Inserts go through the Supabase
  client so RLS enforces ownership. Anonymous visitors are routed to
  the auth view before an order can be placed; there is no anonymous
  food order path.
- `points`: the signed-in user's `point_transactions` rows loaded
  from `public.point_transactions` through RLS. Exposes `balance`
  (`sum(delta)` over the loaded rows), a `transactions` list sorted
  by `created_at desc`, `loading` / `error` flags, an `earn({ source,
  source_ref, amount, event_id })` method that inserts a positive
  transaction, and a `redeem({ source, source_ref, amount, event_id })`
  method that inserts a negative transaction and locally updates the
  balance. Subscribes to `supabase.auth.onAuthStateChange` the same
  way `tickets`, `newsletter`, and `foodOrders` do; clears its state
  on sign-out so a newly signed-in user never inherits another
  session's balance.

In-progress ticket purchase and food ordering state both live in the
local Alpine component behind their respective views (`purchase` and
the `food` event subview) rather than in a store, because nothing
outside those views needs to read it. The points shop and the event
add-ons section follow the same rule: the redemption-in-progress
state (selected item, pending confirmation screen) lives in the
local component; only the persistent balance and transaction list
live in the `points` store.

Data is loaded from the shared Supabase prototype project. Supabase is
a hard dependency of the frontend: the calendar, event views, and
practical-info views all read from Postgres through the Supabase JS
client. The earlier `web/data/catalog.json` fallback is retained only
as a reference copy of the seed shape; the app does not read it at
runtime.

### Catalog loading

On first app load the `catalog` store issues nine parallel `select *`
queries against the shared project: `venues` (single row),
`events`, `news_items`, `articles`, `program_items`, `exhibitors`,
`speakers`, `point_addons` (filtered to `active = true`), and
`merchandise` (filtered to `active = true`). The rows are kept in
memory for the life of the session and filtered per event in view
components. The Supabase URL and publishable (anon) key are read
from `window.MASSANAPP_ENV`, set by `web/assets/env.js` (committed)
with optional override from `web/assets/env.local.js` (gitignored).

If the Supabase queries fail, the app surfaces the error through the
`catalog.error` state and the calendar view shows a failure message
instead of silently falling back to stale data. The `tickets` and
`newsletter` stores follow the same pattern: on a failed fetch the
My Tickets view and the My Pages newsletter-preferences section each
show a load-error message keyed off the store's `error` state, so a
signed-in visitor is not misled into thinking the empty state means
they own no tickets or have no subscriptions.

The user-scoped stores (`tickets`, `newsletter`, `foodOrders`,
`points`) share their sign-in / sign-out fetch contract through
`util/session-sync.js`. `stores/session.js` calls
`notifySessionStores()` from its `onAuthStateChange` callback and
once after the initial `getSession` resolves; each target store's
`_onSessionChange` delegates to `loadUserRows(this, { table, field,
orderBy, logLabel, normalize })`, so the clear-on-signed-out, set
loading/error, `select *`, `console.warn`-plus-`store.error`-on-
failure sequence is written once rather than duplicated per store.
When adding a new user-scoped store, register its id in
`SESSION_SYNC_STORE_IDS` and route its `_onSessionChange` through
`loadUserRows`.

The matching insert half is `insertOwnedRow(this, { table, field,
row })` from the same module: it runs
`insert(row).select("*").single()` and, on success, prepends the
returned row to `store[field]` so the in-memory list stays
consistent with the database without a refetch.
`stores/tickets.js` (`add`), `stores/food-orders.js` (`add`), and
`stores/points.js` (`_insert`) all delegate to it. Supabase errors
are rethrown so callers can show an inline error; `points._insert`
additionally records the failure on `this.error` before rethrowing,
because `tryEarn` swallows the rethrow and the error has to reach
the My Pages points banner through the store instead. The newsletter
store keeps its own insert path because anonymous signups have to
skip the `.select()` return — see the comment in
`stores/newsletter.js`.

### Alpine.js usage rules

- One view per file. Every Alpine view component (`calendarView`,
  `eventView`, `authView`, `meView`, `purchaseView`, `myTicketsView`,
  `newsletterSignup`, `newsletterPreferences`, `foodView`,
  `pointsShopView`, and any future component) lives in its own module
  under `web/assets/js/views/`, and every Alpine store lives in its
  own module under `web/assets/js/stores/`. See "Frontend app
  structure" above.
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
- Catalog content (event names/subtitles/summaries, the shared venue's
  practical-info fields, news, articles, program items, exhibitors,
  speaker bios, point add-ons, and venue-wide merchandise) is stored
  in a dual-language `jsonb { "en", "sv" }` shape and rendered in the
  active UI language by the `pickLang` helper in
  `web/assets/js/util/i18n-content.js`. Views read either through
  `pickLang(value, $store.lang.current)` or the ergonomic
  `$store.lang.pick(value)` getter, and the helper accepts a plain
  string as a transitional fallback so the views remain robust against
  any column that is still being migrated. The schema migration was
  split across `0007_dual_language_events_venues.sql`,
  `0008_dual_language_editorial.sql`,
  `0009_dual_language_exhibitors.sql`, and
  `0010_dual_language_points.sql` — one per table group — so each
  migration could land independently with its matching seed rewrite.
- A handful of seeded columns stay as canonical English identifiers
  rather than dual-language jsonb so filter comparisons keep working:
  `events.type`, `events.category`, and `program_items.track`.
  Templates render them in the active language by calling
  `$store.lang.label(prefix, value)` (where `prefix` is `event.type`,
  `event.category`, or `program.track`). The store delegates to
  `translateLabel` in `web/assets/js/i18n.js`, which slugifies the
  value into a `<prefix>.<slug>` lookup key (via `labelKey`) and
  resolves it in the dictionary. Unmapped values render as the raw
  string so unknown identifiers stay visible. New seed values added
  under one of these prefixes need a matching `<prefix>.<slug>` key
  in both `en` and `sv` entries in `i18n.js`.
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
  The same suite also walks `web/` for literal `t('...')` /
  `activeTranslate('...')` / `canonicalTranslate('...')` callsites and
  fails if any references a key that is not in the dictionary, so a
  template referencing a missing key fails the unit run too. (Keys
  built from variables — for example the per-menu `name_key` /
  `desc_key` lookups in `util/food.js` — are not literal and so are
  not scanned; those modules carry the originating literal references
  in their entry tables.)
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
- `questionnaire_subjects` (JSONB array of strings, optional) — the
  event-relevant subject list offered to the visitor during the
  ticket-purchase questionnaire (see the "Ticket" entity below).
  Null or missing means no subject list is configured for this event
  and the subjects step is skipped. Fully seeded events carry a
  short, event-archetype-appropriate list (for example construction
  topics on `Nordbygg 2026` and oncology topics on `ESTRO 2026`);
  lightweight calendar-only events leave the field null.

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
- `user_metadata.profile` stores the visitor's saved ticket-purchase
  general-profile answers (`gender`, `country`, `region`,
  `visit_type`, `company`, `role`) so the ticket-purchase
  questionnaire can pre-fill those fields on the next purchase. The
  profile is written at the end of a successful purchase; a failure
  to persist it does not fail the purchase.
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
  `purchased_at`, `questionnaire`
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
- `questionnaire` is a nullable JSONB column that captures the
  answers to the purchase questionnaire (see "Ticket purchase
  (simulated)" in the functional specification). Expected shape:

  ```json
  {
    "profile": {
      "gender": "...",
      "country": "...",
      "region": "...",
      "visit_type": "professional" | "private",
      "company": "...",
      "role": "..."
    },
    "subjects": ["subject", "..."]
  }
  ```

  Unanswered optional fields are serialized as empty strings so the
  persisted shape is predictable across purchases; `visit_type` is
  always present because it is required. When the event has no
  `questionnaire_subjects`, the `subjects` array is an empty array.
  For non-professional purchases `company` and `role` are always
  written as empty strings, even if the visitor typed into those
  fields before switching visit types. Tickets created before this
  column existed stay null, which the UI treats the same as "no
  answers captured".
- The general-profile block is also persisted to the Supabase user's
  `user_metadata.profile` (via `supabase.auth.updateUser`) so
  subsequent ticket purchases can pre-fill the general-profile form
  from the signed-in user. The session store surfaces this profile on
  the mapped session user so the purchase view can read it without
  calling Supabase directly. Failure to persist to `user_metadata`
  never fails the purchase; the same error-tolerance rule as the
  points-earn path applies.

### Food order

- `id`, `user_id`, `event_id`, `menu_id`, `menu_label`, `price`,
  `delivery_mode` (`pickup` or `timeslot`), `delivery_id`,
  `delivery_label`, `timeslot_from`, `timeslot_to`, `transaction_ref`,
  `ordered_at`.
- Rows live in `public.food_orders` (see
  `supabase/migrations/0004_food_orders.sql`) with Row Level Security
  scoped to `auth.uid() = user_id` for both read and insert. Only
  signed-in visitors can place an order; the food view routes through
  auth first if there is no session.
- The menu catalog (10 menus), pickup locations, and restaurant list
  are static data in `web/assets/js/util/food.js` and do not have
  database tables. A persisted order references them by id.
- Event-specific themed menus also live in `util/food.js` as static
  per-theme definitions (`THEMED_MENU_DEFS`) and a `CATEGORY_TO_THEME`
  map from `event.category` to a theme id. Unmapped categories fall
  through to the `default` theme. `themedMenuForEvent(event)` returns
  a `{ id, label, items }` object consumed by `views/food.js` (step 1
  in the ordering flow) and `views/event.js` (the event landing food
  preview). Themed entries share the combined `buildCatalog` output
  with the regular 10 items, so `menuById` / `canonicalMenuLabel`
  round-trip a persisted themed `menu_id` without a separate branch.
  Themed entries reuse existing photography under
  `web/assets/images/food/` — only copy and ids are new.
- Each menu carries an `extras` list (sides and drinks bundled with
  the main, e.g. `["food.extras.small_fries", "food.extras.soft_drink"]`)
  resolved against the active language at access time. The bundle is
  presentational only — it is shown on the menu card, the order
  summary, and the confirmation card, but is not stored on the
  `food_orders` row. Re-resolving the bundle on confirmation is done
  by looking up the saved `menu_id` against the static catalog.
- Menu photographs live as bundled binary assets in
  `web/assets/images/food/<menu_id>.<jpg|png>`. They were sourced from
  Wikimedia Commons (public domain, CC0, and CC BY) — see
  `web/assets/images/food/CREDITS.md` for per-file attribution.
- Persisted display fields (`menu_label`, `delivery_label`) use the
  canonical English copy via the `canonical*Label` helpers, same rule
  as `ticket_type_label` on tickets — the wallet entry must not flip
  language depending on who later views it.

### Point transaction

- `id`, `user_id`, `event_id` (nullable), `source`, `source_ref`,
  `delta` (integer, positive for earns, negative for redemptions),
  `created_at`.
- `source` is one of `ticket`, `food`, `addon_redemption`,
  `merch_redemption`. `source_ref` stores the id of the row the
  transaction relates to: a ticket id or food-order id for earns, a
  `point_addons.id` or `merchandise.id` for redemptions. No
  `source_ref` type enforcement is added in the prototype — the
  source column alone is enough to disambiguate.
- The user's current balance is `sum(delta)` over their rows. A
  denormalised balance column is deliberately avoided so the balance
  cannot drift from the history.
- Rows live in `public.point_transactions` (see
  `supabase/migrations/0005_points_system.sql`, which also defines
  `public.point_addons` and `public.merchandise`) with Row Level
  Security scoped to `auth.uid() = user_id` for both read and insert.
  Because
  the prototype's simulated-payment flow runs entirely in the
  frontend, the insert policy accepts any `delta` a signed-in user
  sends — a malicious prototype client could in principle insert
  arbitrary positive deltas. This matches the existing
  simulated-payment trust model (tickets and food orders insert
  client-side too) and is called out in the functional spec.
- Redemption records are point-transaction rows with a negative
  `delta` and `source_ref` pointing at the redeemed
  `point_addons.id` or `merchandise.id`. Redemption detail (name,
  description, image) lives in those catalog tables; no separate
  redemption table is introduced in the prototype.

### Point add-on

- `id`, `event_id`, `name`, `description`, `points_cost`,
  `image` (optional), `stock` (nullable integer — advisory only in
  the prototype), `active` (bool), `created_at`.
- Rows live in `public.point_addons`. Row Level Security allows
  public read on `active = true` rows; no client writes.
- Seeded ~3 rows per fully-seeded event (Nordbygg 2026 and the
  congress event) in `supabase/seed/seed.sql`, mirrored in
  `web/data/catalog.json`.

### Merchandise item

- `id`, `name`, `description`, `points_cost`, `image` (optional),
  `stock` (nullable integer — advisory only in the prototype),
  `active` (bool), `created_at`.
- Venue-wide catalog: no `event_id`. Rows live in
  `public.merchandise`. Row Level Security allows public read on
  `active = true` rows; no client writes.
- Seeded as ~4 venue-wide rows (examples: tote bag, cap, notebook,
  enamel pin) in `supabase/seed/seed.sql`, mirrored in
  `web/data/catalog.json`.

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
  a user can read and write only their own tickets, newsletter
  subscriptions, food orders, and point transactions, while shared
  venue and event content (including `point_addons` and
  `merchandise`) is readable without authentication.
- Migrations live in `supabase/migrations/`. Seed data lives in
  `supabase/seed/` and may be a mix of SQL and JSON. The numbered
  migrations to date are:
  - `0001_init.sql` — initial schema: venue, events, news_items,
    articles, program_items, exhibitors, speakers, tickets, and
    newsletter_subscriptions, with owner-scoped RLS on the
    user-owned tables.
  - `0002_newsletter_delete_policy.sql` — adds an owner-scoped
    DELETE policy on `public.newsletter_subscriptions` so the
    `unsubscribe(id)` method on the newsletter store can remove a
    signed-in user's row.
  - `0003_news_items_hero_image.sql` — adds `news_items.hero_image`
    so news cards can carry their own image, falling back to the
    parent event's hero when unset.
  - `0004_food_orders.sql` — adds `public.food_orders` with
    owner-scoped RLS for the simulated food-ordering flow.
  - `0005_points_system.sql` — adds `public.point_transactions`,
    `public.point_addons`, and `public.merchandise` for the
    simulated loyalty-points feature.
  - `0006_ticket_questionnaire.sql` — adds
    `tickets.questionnaire` (JSONB) and
    `events.questionnaire_subjects` (JSONB) for the
    ticket-purchase questionnaire.
  - `0007_dual_language_events_venues.sql` — converts user-facing
    text columns on `events` (`name`, `subtitle`, `summary`,
    branding/overrides leaves) and the shared `venues` row
    (`transport`, `parking`, `restaurants`, `security`,
    `sustainability`, `maps`) to the dual-language
    `jsonb { en, sv }` shape resolved by `pickLang`.
  - `0008_dual_language_editorial.sql` — converts the editorial
    tables (`news_items.title/body`, `articles.title/body`,
    `program_items.title/description/location`, `speakers.bio` and
    `speakers.affiliation`) to the same shape. `speakers.name` and
    `program_items.track` stay single-string by design.
  - `0009_dual_language_exhibitors.sql` — converts
    `exhibitors.description` to `jsonb { en, sv }`. The exhibitor
    `name` stays a single canonical string (company brand name).
  - `0010_dual_language_points.sql` — converts
    `point_addons.name/description` and
    `merchandise.name/description` to `jsonb { en, sv }`, completing
    the dual-language rollout across every catalog text column.
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
  "venue":         { ... one shared venue record ... },
  "events":        [ ... event records with venue_id and overrides ... ],
  "news":          [ ... news items keyed by event_id ... ],
  "articles":      [ ... articles keyed by event_id ... ],
  "program":       [ ... program items keyed by event_id ... ],
  "exhibitors":    [ ... exhibitors keyed by event_id ... ],
  "speakers":      [ ... optional speakers for congress events ... ],
  "point_addons":  [ ... per-event points-redeemable add-ons ... ],
  "merchandise":   [ ... venue-wide points shop catalog ... ]
}
```

User-facing text leaves on the catalog tables are stored as
`{ "en": "...", "sv": "..." }` objects (jsonb) and resolved at render
time by `pickLang`. Brand/proper-name leaves — `events.id`,
`exhibitors.name`, `speakers.name`, `program_items.track`,
`venues.id`, asset paths, slugs, and similar canonical identifiers —
remain single strings. Both `seed.sql` and the `catalog.json` mirror
emit the same shape; when a leaf is updated, it must be updated in
both files.

Per-entity `event_id` values match the `id` of the event they belong to.
The venue is a single object, not a list, because the prototype only
models Stockholmsmassan. When `seed.sql` changes, update
`catalog.json` in the same change so the reference copy stays useful.

The `nordbygg-2026` exhibitor rows are scraped from the official
Stockholmsmassan digital-stand directory at
`https://exhibit.stockholmsmassan.se/api/exhibitors?eventId=12316`
rather than hand-authored. Each row's `id` is `nordbygg-2026-exhibitor-<DigitalStandId>`
so reruns produce stable identifiers, and `logo` paths point at JPGs
under `web/assets/images/exhibitors/nordbygg-2026-<slug>.jpg` (200 px
preview, slugged from the upstream name).

The scrape is a one-off agent run captured in
`agent/tasks_completed/scrape-nordbygg-exhibitors.md`: the upstream
API was fetched once, the resulting rows were written into the
`public.exhibitors` insert in `supabase/seed/seed.sql` (mirrored in
`web/data/catalog.json`), and the preview JPGs were downloaded into
`web/assets/images/exhibitors/`. There is no committed scraper
script and no Supabase Edge Function — refreshing the catalog from
upstream requires another agent session to re-run the scrape and
update both seed.sql and catalog.json by hand. The downloaded JPGs
similarly need to be refreshed in the same change if upstream image
URLs change.

Maintenance helpers for the dual-language migration of the scraped
descriptions live under `scripts/` and are run by hand:
`scripts/wrap_exhibitor_descriptions.mjs` rewrites plain-string
descriptions into the `jsonb { en, sv }` shape (idempotent; safe to
re-run after a rescrape), and
`scripts/apply_exhibitor_translations.mjs` applies a per-row
`{ id, en, sv }` payload from `scripts/translations/*.json` into
both `seed.sql` and `catalog.json`.

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
  is contacted. The delay lets the UI show a "processing" state. Used
  by both the ticket purchase flow and the food ordering flow.
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

### Points earning and redemption

- Earning-rate logic lives in `web/assets/js/util/points.js` as pure
  functions (`pointsForTicket`, `pointsForFoodOrder`,
  `POINTS_PER_TICKET`). `pointsForFoodOrder` parses the SEK amount
  out of the food menu's `price` string. These functions are unit
  tested the same way the rest of `util/` is.
- Earning is wired into the existing purchase flows after the
  simulated payment resolves and the `ticket` or `food_order` row is
  inserted:
  - `views/purchase.js` calls
    `points.tryEarn({ source: 'ticket', source_ref: ticket.id, amount:
    pointsForTicket(ticket), event_id: ticket.event_id })`.
  - `views/food.js` calls
    `points.tryEarn({ source: 'food', source_ref: order.id, amount:
    pointsForFoodOrder(order), event_id: order.event_id })`.
- `tryEarn` is the caller-facing method for the purchase flows because
  an earning insert that fails (Supabase outage, RLS misconfig) must
  not fail the parent purchase — the user-visible "ticket purchased"
  or "order placed" outcome stands. The error is surfaced through
  the `points` store's `error` state (set by the underlying `earn`
  call) and logged to the console by `tryEarn` itself, so the view
  code does not need to repeat the try/catch contract in two places.
  `earn` remains available as the throwing primitive for any future
  caller that needs to react to a failure.
- Redemption is performed via `points.redeem(...)` which inserts a
  negative-delta `point_transactions` row. The event-add-ons section
  on `views/event.js` and the `views/points-shop.js` screen both
  call through the store; no view talks to the `point_transactions`
  table directly. Both views share the local per-session redemption
  state (stock-consumed counters, pending indicator, last-success
  banner, and error) through `createRedemptionController(...)` in
  `util/redemption.js`, so the two surfaces cannot drift on guard
  logic (`canRedeem`, `disabledReason`) or translation-key plumbing.

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
