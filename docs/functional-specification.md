# MassanApp Functional Specification

This document defines what the MassanApp prototype does from the user's
point of view. It is the source of truth for the behavior that the
implementation and installation/testing specifications must satisfy.

The prototype scope is set by
[issue #1: Start project](https://github.com/hanneseklund/MassanApp/issues/1)
and by the research captured in
`docs/research-stockholmsmassan-and-venue-apps.md`.

## Product vision

MassanApp is the mobile web companion for visitors to Stockholmsmassan.
The venue hosts multiple event archetypes — public fairs, trade fairs,
congresses, conferences, events, and high-profile meetings — at one
physical site in Alvsjo, Stockholm. The prototype shows how one app can
serve all of those archetypes while keeping the user on one event at a
time.

## Product principles

- Mobile-first. The target device is a smartphone. Layouts and tap targets
  assume one-handed use on small screens.
- Event-first navigation. Once a visitor picks an event, the app becomes
  that event's mini-homepage. A persistent route back to the event list is
  always available.
- One event at a time. The selected event controls the content and
  navigation until the visitor switches events.
- Shared venue data, event-branded delivery. Transport, parking,
  restaurants, and security facts are modeled once for Stockholmsmassan and
  reused across every event, optionally with event-specific overrides.
- Simulate real integrations cleanly. Where the prototype does not talk to
  real payment, social sign-in, or ticketing systems, it fakes them with
  obvious but realistic placeholders instead of leaving dead UI.
- Visual consistency with Stockholmsmässan. The app uses the venue
  site's palette (deep navy ink, electric-blue accent, white surfaces,
  tight 3-4px corners) and a LabGrotesque-compatible grotesque
  typeface so that a visitor who has seen the venue website
  recognizes the app as the same brand. See
  `docs/implementation-specification.md` for the token values.

## Primary personas

- Public visitor to a trade fair or public fair. Examples: `Nordbygg 2026`,
  `Yrkes-SM`, `European Dog Show and Swedish Winner Show`.
- Professional delegate at a congress or conference. Examples:
  `ESTRO 2026`, `EHA2026 Congress`.
- Unauthenticated browser exploring the calendar before deciding whether
  to register or buy a ticket.

Secondary personas such as exhibitors, shareholders at a governance
meeting, or accredited media are considered when shaping the data model
and access-rule hooks, but they are not exercised by the prototype UI.

## End-to-end user journey

The prototype must support this end-to-end path without gaps:

1. The visitor opens the app and lands on the upcoming-events calendar.
2. The visitor filters the calendar by category, type, month, or free-text
   search.
3. The visitor selects one event. The app switches into that event's
   mini-homepage.
4. The visitor browses the event's news, articles, program, exhibitor
   index, specific exhibitor pages, and practical information.
5. The visitor registers for an account or signs in. Email is the primary
   identity. Google and Microsoft sign-in appear as options but are
   simulated.
6. The logged-in visitor starts a simulated ticket purchase, completes the
   flow without real payment processing, and confirms the ticket.
7. The visitor opens "My Tickets" and sees the new ticket with a QR-code
   presentation for venue entry.
8. The visitor can sign up for the event newsletter and adjust newsletter
   preferences.
9. At any step after selecting an event, the visitor can return to the
   broader event list and pick a different event.

## Navigation model

- Top-level screen: Event calendar.
- Event-selected mode: All navigation is scoped to the selected event
  until the visitor explicitly leaves it. "Back to events" is always
  reachable from the event's primary chrome.
- Account: "My Pages" is reachable from the app chrome. It exposes the
  profile, "My Tickets", and newsletter preferences.
- Shared venue information: Reachable from within each event's practical
  information section so it reads as part of that event's content.

## Screen-by-screen behavior

### Event calendar

- Displays upcoming events ordered by start date.
- Filters: category (Congress, Construction and real estate, Education and
  training, Entertainment, Food & drink, Gaming, Health & Medicine,
  Industry, Interior design, Leisure and consumer, Other, Travel), type
  (Conference, Congress, Event, Public fair, Trade fair), month, and
  free-text search.
- Each event card shows the event name, dates, type, and a short summary.
- When the event has a hero image, the card shows it above the text.
  Cards without an image fall back to the text-only layout.
- Tapping an event opens that event's home screen.

### Event home

- Identifies the selected event at the top of the screen.
- Displays the event's hero image above the title when one is available,
  with a small image credit below it. Events without an image degrade to
  text-only without an empty frame.
- Summarizes what the event is and when it runs.
- Surfaces the core event sections: News, Articles, Program, Exhibitor
  index, Practical information, Newsletter.
- Provides a clear ticket call-to-action when the event has ticketing.
- Provides a persistent "Back to events" route.

### News and Articles

- News is a chronological list of short updates for the event.
- Articles are long-form editorial pieces for the event.
- Where the source does not provide enough content, clearly simulated
  content is acceptable.

### Program

- Shows the event's sessions or program items in day/time order.
- Program detail shows title, time, location within the venue, and a short
  description.
- For congress archetypes, the program is rich enough to represent
  multi-track scheduling and speaker slots even if the UI does not yet
  expose every detail.

### Exhibitor index and exhibitor pages

- Exhibitor index lists the event's exhibitors and supports text search.
- Exhibitor detail pages show the exhibitor name, booth or location,
  description, and links where available.

### Practical information

- Pulls from the shared Stockholmsmassan venue data: transport to Alvsjo,
  parking and EV charging, on-site restaurants, and security and access
  rules.
- Allows event-specific overrides such as bag rules, special entrances,
  and event-specific safety notices.

### Newsletter

- Visitors can sign up for the event newsletter with an email.
- Logged-in visitors can manage their newsletter preferences per event
  and at the account level.

### Registration and sign-in

- Email registration is the primary path. Accounts are created in
  Supabase Auth; email confirmation is disabled on the shared prototype
  project so sign-up completes without waiting on an email. If
  confirmation is ever enabled, the UI must show a "check your email"
  state and continue to work once the visitor confirms.
- Google and Microsoft sign-in options are visible. In the prototype they
  are simulated: selecting them creates a fake signed-in session without
  contacting the real provider.
- After sign-in, the visitor is returned to where they were in the event
  flow.

### My Pages

- Shows profile basics (name, email).
- Links to My Tickets and newsletter preferences.
- Provides sign-out.

### Ticket purchase (simulated)

- The flow starts from the event's ticket call-to-action: "Get tickets"
  on events with public ticketing and "Register as delegate" on
  congress-style events that use registration.
- A visitor who is not signed in is sent to the auth view first and
  returned to the purchase flow after sign-in.
- The flow has three steps:
  1. Pick a ticket type. Public-ticketing events offer at least two
     simulated types (for example "Day pass" and "Full event pass").
     Congress events offer a single "Delegate registration" type.
  2. Confirm attendee details (name and email, defaulted from the
     signed-in profile) and review an order summary.
  3. Confirm the purchase. No real payment is taken; the confirmation
     step always succeeds and is visibly marked as simulated.
- On success the visitor sees a confirmation screen with a link to My
  Tickets, and the new ticket appears there.
- Once a visitor owns a ticket for an event, the event home view also
  shows a "View ticket" affordance that opens My Tickets.

### My Tickets

- Lists the tickets the signed-in visitor has purchased, scoped to that
  user id.
- Each ticket shows the event, dates, ticket type, attendee, purchase
  date, and a QR code for venue entry. The QR code is generated locally
  from ticket metadata and does not need to be a valid venue-access
  credential.
- Tickets persist across page reloads.

## Event archetype coverage

The prototype must model two distinct archetypes in depth, with full
per-event news, articles, program items, and exhibitors:

- Trade-fair archetype, seeded with `Nordbygg 2026`. This exercises public
  ticketing, an exhibitor index with exhibitor pages, a seminar program,
  news, and shared venue logistics.
- Congress archetype, seeded with `ESTRO 2026` or `EHA2026 Congress`. This
  exercises richer program content and the idea of a professional or
  gated audience, even if the prototype's UI does not yet enforce strict
  audience gating.

The calendar additionally seeds every upcoming Stockholmsmassan event
published on the official calendar as lightweight entries (name, dates,
type, category, audience rule, ticket model, branding, and an
event-level overrides block) so the calendar reflects the real upcoming
schedule rather than a small subset. These lightweight entries do not
carry per-event news, articles, program items, or exhibitors; opening
one shows the hero, practical information, and a newsletter hook.

The data model must leave room for additional archetypes (annual member
meetings, shareholder meetings, high-security international meetings) by
supporting event-type flags and per-event audience rules, without
implementing those flows in the prototype UI.

## Shared venue information

Shared venue information is modeled once and reused across every seeded
event:

- Transport: Alvsjo station adjacency, commuter-train times from
  Stockholm City and Arlanda.
- Parking: about 2,000 spaces on site, nearby overflow parking, EV
  charging.
- Restaurants: the on-site restaurants and cafes the venue operates.
- Security: SHORE-certified venue status, general bag and entry rules.

Events can override or extend these facts with event-specific notices.

## Simulated integrations

The prototype explicitly simulates:

- Payment processing during ticket purchase.
- Google and Microsoft social sign-in.
- Email delivery for ticket-purchase confirmation and newsletter-signup
  confirmation. Registration email is handled by Supabase Auth directly
  (email confirmation is turned off on the shared prototype project, so
  no email is actually sent during sign-up).
- Any congress-platform or on-demand-content integrations that real
  events expose but the prototype does not wire up.

Simulations must be visibly labeled in development and test contexts so
that reviewers understand they are not real integrations.

## Accessibility and internationalization (baseline)

- Interactive elements must have accessible names and sufficient tap size
  on a phone screen.
- The app chrome supports English and Swedish. A compact language
  toggle in the top chrome switches between the two and the chosen
  language is remembered across reloads. English is the default on
  first load.
- "Chrome" in this context means everything the app itself produces:
  titles, buttons, tab labels, placeholders, hints, error copy, step
  labels, and both simulated-payment and simulated-email UI. Event
  content sourced from outside the app — event names, summaries, news,
  articles, program items, exhibitors, practical-info venue copy —
  stays in the language it was seeded in. If a future task seeds
  translated content for events, the UI is already wired to render it
  through the same switch.
- Dates render in the active language (weekday and month names use the
  UI language's locale). Saved ticket labels remain in English so a
  wallet entry does not change wording based on whoever later opens
  My Tickets.

## Out of scope for the prototype

The following are explicitly out of scope for the prototype and must not
be implemented without a specification change:

- Real payment processing and real ticket issuance.
- Real OAuth with Google or Microsoft.
- On-site wayfinding, hall/booth navigation, and indoor positioning.
- Lead capture and networking features for exhibitors.
- Hybrid or on-demand congress content playback.
- Secure document centers, voting, or Q&A for governance meetings.
- Food pre-ordering.
- Real email delivery or real push notifications.

## Acceptance criteria

The prototype satisfies this specification when:

- A first-time visitor can land on the calendar, filter, select
  `Nordbygg 2026`, browse its news, articles, program, exhibitor index,
  an exhibitor detail page, and practical information, and return to the
  calendar.
- A visitor can register with email, sign in, see "My Pages", simulate a
  ticket purchase for `Nordbygg 2026`, and find the ticket with a QR code
  in "My Tickets".
- The same visitor can navigate to at least one congress-style event such
  as `ESTRO 2026` or `EHA2026 Congress` and see program and practical
  information populated from seeded data.
- Shared venue information is visibly reused across the seeded events
  rather than duplicated per event.
- Newsletter signup and preferences persist to the shared Supabase
  project's `newsletter_subscriptions` table. The confirmation email for
  the signup is simulated.
