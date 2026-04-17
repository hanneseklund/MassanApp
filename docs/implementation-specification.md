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
  Supabase Auth handles email-based authentication. Social sign-in for
  Google and Microsoft is simulated in the prototype but is structured so
  that real Supabase OAuth providers can replace it later.
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
    assets/             css, js, images
    data/               optional seed JSON for local dev
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
- `event` — the selected event's mini-homepage, which itself contains
  subviews for News, Articles, Program, Exhibitor index, Exhibitor detail,
  Practical information, and Newsletter.
- `auth` — registration and sign-in.
- `me` — logged-in "My Pages", including My Tickets and newsletter
  preferences.

View switching is handled in Alpine.js state. The prototype may also use
hash-based routing (for example `#/event/nordbygg-2026/program`) to make
views linkable, but stateful client-side routing is sufficient for the
prototype.

### State management

Alpine.js stores and components own the following state:

- `session`: current authenticated user, tokens, and "simulated provider"
  flag.
- `catalog`: cached list of events, exhibitors, program items, news,
  articles, and shared venue data.
- `ui`: current view, selected event, filter state, modal state.
- `cart` and `tickets`: in-progress ticket purchase and the user's owned
  tickets.

Data is loaded lazily per view. The catalog is populated either from
Supabase or from local seed JSON during development.

### Alpine.js usage rules

- Keep Alpine.js templates small and focused. One view per file or
  section.
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
- `branding` (optional colors/logo)
- `overrides` (JSON of event-specific practical-info overrides)

### News item

- `id`, `event_id`, `published_at`, `title`, `body`

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
  `microsoft`) — social providers carry a `simulated: true` flag in the
  prototype.

### Ticket

- `id`, `user_id`, `event_id`, `ticket_type`, `attendee_name`,
  `attendee_email`, `qr_payload`, `purchased_at`

### Newsletter subscription

- `id`, `user_id` (nullable for anonymous signup), `email`, `event_id`
  (nullable for venue-wide), `preferences` (JSON)

## Supabase usage

- Use Supabase Auth for email sign-up, sign-in, and session management.
- Tables mirror the data model above. Use Row Level Security so users can
  only read their own tickets and newsletter subscriptions, but can read
  shared venue and event content without authentication.
- Migrations live in `supabase/migrations/`. Seed data lives in
  `supabase/seed/` and may be a mix of SQL and JSON.
- The frontend talks to Supabase directly using the anon key. There is no
  separate API layer in the prototype.

Where Supabase is not configured for local development, the frontend
falls back to local seed JSON in `web/data/` so the prototype remains
demoable without credentials.

### Seed data layout

The prototype ships a single seed file, `web/data/catalog.json`, that
mirrors the Supabase table structure so the same data shape can be
consumed with or without Supabase:

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
models Stockholmsmassan.

Supabase migrations live in `supabase/migrations/` and create tables
that mirror these collections. The matching seed SQL lives in
`supabase/seed/seed.sql`. The SQL seed and the JSON seed are kept in
sync by hand: when one is updated the other should be updated in the
same change.

## Simulated integrations

All simulations must be centralized and easy to replace:

- `simulatedSocialSignIn(provider)` — returns a fake session for Google
  or Microsoft without calling the provider. It sets
  `session.auth_provider = provider` and `session.simulated = true`.
- `simulatedPayment(order)` — always succeeds after a short delay. It
  produces a plausible transaction reference but does not contact any
  payment service.
- `simulatedEmail(kind, payload)` — no-op in production prototype
  hosting; in development it logs the would-be email to the console.
- `generateTicketQr(ticket)` — produces a QR payload from the ticket ID
  and a salted event ID. The QR does not have to validate at a real venue.

Simulations must be clearly labeled in the UI during development and
testing, for example with a small "simulated" chip, so reviewers can see
that no real service is being hit.

## Event-first navigation implementation

- The `event` view is the root of its own navigation tree once an event is
  selected.
- Every event subview (News, Program, Exhibitors, Practical info,
  Newsletter) exposes a "Back to events" affordance in the top chrome.
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
- Do not commit real Supabase service keys. Only the anon key is used at
  runtime, supplied via a Cloudflare Pages environment variable or a
  local `.env.local`-style file that is gitignored.

## Deployability

- Cloudflare Pages deploys the `web/` directory as a static site.
- Supabase is a managed project and is provisioned out-of-band; the
  repository carries migrations and seed data, not credentials.
- The prototype must run locally without Supabase using the seed JSON
  fallback, so that demos and reviews do not block on cloud setup.

## Change control

Implementation changes must be consistent with the functional
specification. If an implementation decision requires a user-visible
change, update `docs/functional-specification.md` first per the workflow
rule in `AGENTS.md`.
