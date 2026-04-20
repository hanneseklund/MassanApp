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
9. The visitor can order food for the selected event, choosing either an
   on-site pickup location or a 30-minute timeslot at one of the venue
   restaurants, and pay through the simulated payment flow.
10. At any step after selecting an event, the visitor can return to the
    broader event list and pick a different event.

## Navigation model

- Top-level screen: Event calendar.
- Event-selected mode: All navigation is scoped to the selected event
  until the visitor explicitly leaves it. Returning to the calendar is
  reachable through the hamburger menu's "Other events" entry (see
  below).
- Account: "My Pages" is reachable from the app chrome (user-silhouette
  icon on the right and the always-visible "My pages" entry in the
  hamburger menu). It exposes the profile, "My Tickets", and newsletter
  preferences.
- Shared venue information: Reachable from within each event's practical
  information section so it reads as part of that event's content.

### Chrome hamburger menu

- A hamburger button in the upper-left of the chrome opens a
  navigation panel. The panel is a dropdown anchored under the
  button; it closes on outside click, the Escape key, and after an
  entry is picked.
- The menu entries, in order, are:
  1. **My tickets** — only shown when an event is selected. Routes
     to `#/tickets` via the usual auth detour.
  2. **Food** — only shown when an event is selected. Opens the
     event's dedicated food page.
  3. **Program** — only shown when an event is selected. Opens the
     event's dedicated program page.
  4. **Exhibitors** — only shown when an event is selected. Opens
     the event's dedicated exhibitors page.
  5. **Practical information** — only shown when an event is
     selected. Navigates to the `#/event/<id>/practical` route,
     which collapses back to the stacked landing view and scrolls
     the practical-info section anchor into view.
  6. **Other events** — only shown when an event is selected.
     Navigates to the calendar (`#/`).
  7. **My pages** — always shown. Same destination as the
     user-silhouette icon; routes through auth when necessary.
- "An event is selected" means the app's `eventId` is set. That
  remains true on an event's stacked landing view, its dedicated
  section pages, its exhibitor detail pages, and the purchase flow,
  so the event-gated entries stay visible throughout event context.
- The menu button exposes `aria-expanded`, `aria-controls`, and a
  translated `aria-label`. The panel uses `role="menu"` with each
  entry as `role="menuitem"`.

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
- Renders every event section as a stacked, scrollable layout below the
  hero. The order is fixed: News, Articles, Program, Exhibitor index,
  Practical information, Food, Newsletter. There is no tab bar; the
  visitor scrolls the page rather than switching views.
- Lists that can grow long (News, Articles, Program, Exhibitors, Food)
  truncate to the first 5 items inline. When the underlying list has
  more than 5 items, a single "see all" link below the list opens a
  dedicated full-list page for that section.
- Practical information renders inline in full and the Newsletter
  signup form renders inline in full. Neither has a "see all" page.
- Provides a clear ticket call-to-action when the event has ticketing.
- Returning to the broader event list is reached through the chrome
  hamburger menu's "Other events" entry (see "Chrome hamburger menu"
  above).

### Section full-list pages

- Each truncated section's "see all" link navigates to a dedicated
  page that shows only that section's full list plus a "back to event"
  link. The hero, other sections, and the section nav are not shown
  on these pages.
- The Program full-list page keeps the by-day grouping; the inline
  preview on the event landing collapses across days to fit the
  5-item limit.
- The Exhibitor full-list page keeps the search box; the inline
  preview does not.
- The Food full-list page is the full 3-step ordering flow; the inline
  preview shows up to 5 menu thumbnails as a teaser.
- Practical information and Newsletter do not have full-list pages.
  Visiting `#/event/<id>/practical` or `#/event/<id>/newsletter`
  collapses to the stacked landing view and scrolls to the matching
  section anchor.

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

### Food

- Reachable from the event landing's Food section (via its "see all"
  link) and from the hamburger-menu "Food" entry while an event is
  selected. The flow is scoped to the selected event but the menu
  catalog and venue locations are shared across every event because
  Stockholmsmassan has one set of on-site food vendors.
- The flow has three steps:
  1. Pick a menu. The prototype offers ten typical fast-food menus
     (burgers, pizza, hot dog, chicken nuggets, fries, salad, wrap,
     sushi box, ice cream) with name, short description, price, and an
     illustrative image.
  2. Pick delivery. The visitor chooses either a pickup location at one
     of a small set of points within the venue, or a 30-minute timeslot
     at one of the on-site restaurants. The shown timeslots start on
     the next half hour from the visitor's local clock.
  3. Confirm. A simulated payment runs and the order is persisted. A
     visitor who is not signed in is sent to the auth view first and
     returned to the food flow after sign-in.
- On success the visitor sees a confirmation screen with the
  transaction reference and either the pickup location or the
  restaurant + timeslot to expect, marked with the same `simulated`
  chip used elsewhere.
- A signed-in visitor is awarded points for the order (see "Points"
  below). A failed or cancelled order awards nothing.
- Persisted orders live with the visitor and are scoped to their
  user id. Cross-event ordering history is not currently surfaced in
  the UI.

### Points

The prototype includes a simulated loyalty-points feature so visitors
can see how MassanApp would recognise engagement across events at
Stockholmsmässan. Everything on this screen carries the same
`simulated` chip used by tickets and food orders.

Earning
- Only signed-in visitors earn points. Anonymous visitors never
  accrue a balance.
- Rules:
  - A successful simulated ticket purchase awards **100 points**, one
    award per ticket, regardless of ticket type or event.
  - A successful simulated food order awards **1 point per SEK of the
    menu price** (for example `Classic Burger` at `SEK 129` awards
    129 points).
- Points are awarded as part of the simulated-payment confirmation
  step, alongside the ticket row or food-order row. A failed or
  cancelled payment awards nothing.
- Points do not expire in the prototype.

Visibility
- The current balance and a short list of recent transactions are
  shown on My Pages (see above). The balance never appears for
  signed-out visitors.
- Recent transactions list the source (ticket, food order,
  add-on redemption, merch redemption), the event if any, and the
  signed delta.

Spending — event add-ons
- Each fully-seeded event carries a small catalog of
  points-redeemable add-ons (for example "Exhibitor gift bag" or
  "VIP access to keynote"). Add-ons are points-only and cannot be
  purchased with currency.
- Add-ons appear as a clearly-marked "Event add-ons" section on the
  event home view, visible only once the signed-in visitor owns a
  ticket for that event. Add-on redemption is a separate flow from
  ticket purchase and does not change the ticket-purchase step count.
- Each add-on card shows an image, name, description, points cost,
  and a "Redeem" button. The button is disabled with an explanatory
  message when the visitor's balance is below the cost. Signed-out
  or ticketless visitors follow the same auth/purchase routing the
  food flow uses before reaching the Redeem button.
- A successful redemption deducts the cost atomically, creates a
  negative point transaction visible on My Pages, and shows a
  confirmation reusing the `simulated` chip pattern.
- Stock is advisory in the prototype: if an add-on carries a stock
  number, it displays but the prototype does not decrement the
  database row. This is called out as a simulation.
- Redemption does not produce a shippable artefact; the
  confirmation screen is the entire user-visible result.

Spending — venue-wide merchandise shop
- A dedicated points shop at `#/points` lists venue-wide
  Stockholmsmässan merchandise (examples: tote bag, cap, notebook,
  enamel pin). The shop is independent of event selection — no
  event is required to browse or redeem.
- The shop is reachable from the Points section on My Pages. A
  signed-out visitor who lands on `#/points` is routed through the
  auth view first and returned afterwards, matching the food and
  purchase flows.
- Cards show image, name, description, points cost, and a Redeem
  button with the same disabled-with-message behaviour as event
  add-ons.
- A successful redemption deducts the cost, creates a negative
  point transaction, and shows a confirmation reusing the
  `simulated` chip before returning the visitor to the shop.

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
- Shows the signed-in visitor's current points balance, a one-line
  "how you earn points" blurb, a link to the venue-wide points shop
  (`#/points`), and a short list of the ~5 most recent point
  transactions (each with an earn/redeem label, the event name if
  any, and the signed delta).
- Provides sign-out.

Anonymous / signed-out visitors never see a points balance on this
screen and never earn points from any flow.

### Ticket purchase (simulated)

- The flow starts from the event's ticket call-to-action: "Get tickets"
  on events with public ticketing and "Register as delegate" on
  congress-style events that use registration.
- A visitor who is not signed in is sent to the auth view first and
  returned to the purchase flow after sign-in.
- The flow has four steps:
  1. Pick a ticket type. Public-ticketing events offer at least two
     simulated types (for example "Day pass" and "Full event pass").
     Congress events offer a single "Delegate registration" type.
  2. Answer a short questionnaire before payment:
     - General profile: gender, country, region of residence, visit
       type (professional or private). If the visit type is
       professional, company and role are also collected. Visit type
       is required; the remaining general-profile fields are
       optional.
     - Event-relevant subjects: if the event has a configured subject
       list (`events.questionnaire_subjects`), the visitor picks the
       subjects they are interested in from that list. Events without
       a configured list skip this block entirely.
     General-profile fields are pre-filled from the visitor's saved
     profile so that a returning purchaser does not have to re-enter
     them. Answers are stored with the ticket, and the general-profile
     fields are saved back to the visitor's account so subsequent
     purchases keep them pre-filled.
  3. Confirm attendee details (name and email, defaulted from the
     signed-in profile) and review an order summary.
  4. Confirm the purchase. No real payment is taken; the confirmation
     step always succeeds and is visibly marked as simulated.
- On success the visitor sees a confirmation screen with a link to My
  Tickets, and the new ticket appears there.
- On a successful purchase, the signed-in visitor is awarded points
  (see "Points" below). A failed or cancelled purchase awards nothing.
- Once a visitor owns a ticket for an event, the event home view also
  shows a "View ticket" affordance that opens My Tickets, and an
  "Event add-ons" section that lists any points-redeemable add-ons
  configured for that event (see "Points" below).

### My Tickets

- Lists the tickets the signed-in visitor has purchased, scoped to that
  user id.
- Each ticket shows the event, dates, ticket type, attendee, purchase
  date, and a QR code for venue entry. The QR code is generated locally
  from ticket metadata and does not need to be a valid venue-access
  credential.
- Tickets persist across page reloads.
- If the ticket fetch fails (for example a Supabase outage), the view
  surfaces the load error rather than silently rendering the empty
  state, so a signed-in visitor is not misled into thinking they own
  no tickets. The same rule applies to the newsletter preferences
  section in My Pages.
- Questionnaire answers captured at purchase are stored on the ticket
  record. Whether My Tickets surfaces those answers in the UI is an
  implementation choice for the UI subtask; the data is always
  captured whether or not it is shown here.

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

- Payment processing during ticket purchase and food ordering.
- Google and Microsoft social sign-in.
- Email delivery for ticket-purchase confirmation and newsletter-signup
  confirmation. Registration email is handled by Supabase Auth directly
  (email confirmation is turned off on the shared prototype project, so
  no email is actually sent during sign-up).
- Any congress-platform or on-demand-content integrations that real
  events expose but the prototype does not wire up.
- Food fulfilment: the order is persisted but no kitchen, restaurant,
  or pickup-location system is contacted.
- Loyalty-points awarding, balance, and redemption. Points are
  persisted to Supabase but no external loyalty programme is
  contacted. Merchandise and event-add-on redemptions do not produce
  a shippable artefact.

Simulations must be visibly labeled in development and test contexts so
that reviewers understand they are not real integrations.

## Accessibility and internationalization (baseline)

- Interactive elements must have accessible names and sufficient tap size
  on a phone screen.
- The app chrome supports English and Swedish. A compact language
  dropdown in the top chrome switches between the two and the chosen
  language is remembered across reloads. English is the default on
  first load. The dropdown collapses to a single button that shows
  the active flag; tapping it expands a panel listing the other
  language(s), and picking a language swaps the chrome and collapses
  the panel. The panel also closes on outside click and on Escape.
- "Chrome" in this context means everything the app itself produces:
  titles, buttons, tab labels, placeholders, hints, error copy, step
  labels, accessible names (aria labels) for chrome regions, and both
  simulated-payment and simulated-email UI. Event content sourced from
  outside the app — event names, summaries, news, articles, program
  items, exhibitors, practical-info venue copy, event add-on names and
  descriptions, and venue-wide merchandise names and descriptions —
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
- A signed-in visitor who simulates a ticket purchase and a food order
  sees their points balance rise on My Pages, can redeem an event
  add-on from the corresponding event home view, can redeem a
  merchandise item from `#/points`, and sees each redemption as a
  negative transaction on My Pages. Signed-out visitors never see a
  balance.
