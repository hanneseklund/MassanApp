# Research: Stockholmsmassan, Venue Operations, and Venue-App Patterns

Research date: 2026-04-17

This note captures the research requested in issue `#1` and is intended to feed the later specification, data-loading, and prototype tasks.

## Executive Summary

- Stockholmsmassan is a large single-site event venue in Alvsjo, Stockholm, with strong transport, parking, food, safety, and digital-infrastructure support. It hosts trade fairs, congresses, conferences, concerts, gala events, and high-profile international meetings.
- The official calendar already exposes the discovery model MassanApp needs: category filter, type filter, month filter, and free-text search, followed by an event detail page.
- The best first prototype event is `Nordbygg 2026` because its public web footprint already covers the end-user flow the prototype needs: event landing page, ticket registration, exhibitor list, seminar program, news, and shared venue logistics.
- A second event archetype should come from a congress such as `ESTRO 2026` or `EHA2026 Congress`, because those events stress different needs: gated registration, multi-track programs, abstracts/posters, delegate services, and hybrid/on-demand content.
- Compared with a cinema, theater, or stadium app, a venue like Stockholmsmassan needs much richer event content and planning tools. The app should borrow ticket-wallet and visit-convenience patterns from smaller venues, but the core product should stay event-first.

## Basic Facts About Stockholmsmassan

| Topic | Finding | Why it matters |
| --- | --- | --- |
| Venue role | The official site describes Stockholmsmassan as the Nordic region's leading facility for sustainable trade fairs, conferences, and events. | The product has to cover multiple event archetypes, not just ticketed public fairs. |
| Ownership | The City of Stockholm owns Stockholmsmassan. | Public ownership and destination-marketing goals explain the broad event mix and civic role. |
| Site history | Founded in 1942; moved to Alvsjo in 1971; expanded over time; by 2009 the site reached 70,000 square meters and became the largest exhibition and congress center in the Nordic region. | The venue is large enough that wayfinding, hall-level information, and practical visit support are first-class product needs. |
| Premises | The venue markets flexible premises for conferences, congresses, exhibitions, events, gala dinners, concerts, and entertainment. Its venue pages list exhibition halls, foyers, auditoriums, entrances, and conference rooms. | The app data model should support event-type-specific sections and location metadata. |
| Capacity | Official venue materials describe up to 70,000 square meters of event space and support for very large participant volumes. | The app should assume crowded, multi-day, multi-hall events rather than a single auditorium flow. |
| Transport | Alvsjo station is adjacent to the venue; commuter trains from Stockholm City take about 9 minutes; direct travel from Arlanda to Alvsjo is available. | "Practical information" can be largely shared across events and branded per event. |
| Parking | Stockholmsmassan provides about 2,000 parking spaces on site, additional nearby spaces, and EV charging. | Parking guidance belongs in the shared venue-information layer. |
| Food | The venue operates 12 restaurants/cafes and adapts food offerings to the active event. | Restaurant info can be shared venue data with event-specific availability or messaging. |
| Safety | Stockholmsmassan states that it is the first exhibition venue in Sweden certified to the SHORE safety standard and supports event-specific bag rules, access controls, and special entry procedures. | The app should support event-specific safety and access notices, not just generic venue content. |
| Sustainability | Stockholmsmassan highlights ISO 20121 certification and ongoing sustainability work. | Sustainability can be part of venue and event content, especially for B2B and congress audiences. |
| Digital infrastructure | The venue history and recent news highlight major wireless-network investments and digital signage. | This supports an app design that assumes heavy mobile usage on site. |

Inference:
The official website presents one operating venue and one address in Alvsjo. Issue `#1` also states that Stockholmsmassan AB only operates this one physical venue. I found no evidence on the official site of a second operating venue.

## Strategic Context

- Official November and December 2025 updates show a strategic shift toward congresses, exhibitions, and business meetings.
- Stockholmsmassan says public fairs will no longer be organized in-house and that Numera Massor is taking over the public-fair portfolio while continuing to host those fairs at Stockholmsmassan.
- Product implication: the app should not assume every event is a broad public-consumer event. It needs event-level audience rules and different content depth depending on whether the event is a public fair, business fair, congress, or invite-only meeting.

## Official Calendar Snapshot As Of 2026-04-17

The official calendar already includes:

- Category filters: Congress, Construction and real estate, Education and training, Entertainment, Food & drink, Gaming, Health & Medicine, Industry, Interior design, Leisure and consumer, Other, Travel.
- Type filters: Conference, Congress, Event, Public fair, Trade fair.
- Month filters and free-text search.

Upcoming events visible on 2026-04-17 included:

| Event | Dates | Type / Category | Prototype value |
| --- | --- | --- | --- |
| Nordbygg | 2026-04-21 to 2026-04-24 | Trade fair / Construction and real estate | Best first seed event. Public ticket flow, exhibitor list, program, news, and shared venue logistics are all available. |
| Yrkes-SM | 2026-05-04 to 2026-05-06 | Event | Useful as a simpler public event archetype. |
| ESTRO 2026 | 2026-05-15 to 2026-05-19 | Congress / Health & Medicine | Good congress archetype with program, exhibition, abstracts/posters, accommodation, and media/delegate flows. |
| Ung Foretagsamhet 2026 | 2026-05-26 to 2026-05-27 | Event | Useful for youth/education/event-community patterns. |
| EHA2026 Congress | 2026-06-11 to 2026-06-14 | Congress or event / Health & Medicine | Strong hybrid congress example with registration, program, delegate services, congress platform, and networking hooks. |
| Samhallsbyggararenan | 2026-06-23 to 2026-06-25 | Event | Useful for policy/professional meeting patterns. |
| Formex | 2026-08-25 to 2026-08-27 | Trade fair / Interior design | Strong second trade-fair candidate with exhibitor list, lectures, trend content, and visitor/exhibitor content. |
| European Dog Show and Swedish Winner Show | 2026-09-04 to 2026-09-06 | Event | Example of a large public-interest event with narrower domain content. |

## Candidate Prototype Data Sources

### Best Primary Event: Nordbygg

Why Nordbygg is the strongest first seed:

- The Stockholmsmassan calendar page links to a dedicated Nordbygg event page.
- The Nordbygg site exposes a public ticket CTA, a public seminar-program link, a public exhibitor-list link, latest news, and newsletter signup.
- The Nordbygg ticket flow lives on `ticket.stockholmsmassan.se`, which is useful for modeling the prototype's simulated ticket purchase.
- The Nordbygg exhibitor directory is on `exhibit.stockholmsmassan.se`, which is a strong fit for later exhibitor-index and exhibitor-page work.

Practical source set:

- Calendar event page on `stockholmsmassan.se`
- Event site on `nordbygg.se`
- Ticket page on `ticket.stockholmsmassan.se`
- Exhibitor pages on `exhibit.stockholmsmassan.se`
- Program page on `invitepeople.com`
- Shared venue info from Stockholmsmassan's parking, find-us, restaurants, and security pages

### Best Congress Pattern: ESTRO 2026 or EHA2026 Congress

Use these to shape the congress data model:

- `ESTRO 2026` explicitly exposes venue, accommodation, media, exhibition, searchable programme, program overview, and poster-related content.
- `EHA2026 Congress` exposes registration, program, delegate services, accommodation, congress platform, late-breaking abstract submission, details/deadlines, travel grants, and sponsorship pages.
- `EHA2026 registration` explicitly includes networking support and on-demand congress-platform access through 2026-10-15.

Practical source set:

- Stockholmsmassan event pages
- Congress home pages
- Registration pages
- Program pages
- Accommodation / delegate-services pages
- Abstract / poster / speaker pages

### Shared Venue Data To Reuse Across Many Events

The following pages should become reusable shared content in the prototype backend:

- Official event calendar and event detail pages
- Find us / transport
- Parking and EV charging
- Restaurants
- Security and event-specific safety rules
- Venue maps and hall maps

## Venue Operation Patterns By Event Type

This section is a synthesis from the official venue, event, and app sources below.

| Event type | What the venue has to handle | App implication |
| --- | --- | --- |
| Public fair / trade show | Registration or ticketing, exhibitor discovery, product discovery, program schedule, booth wayfinding, sponsor content, practical visit planning | Event home, tickets, searchable exhibitor index, booth/location metadata, program, favorites, practical info |
| Professional congress | Member/non-member registration rules, multi-track schedules, speakers, abstracts/posters, exhibition, accommodation, delegate services, hybrid platform access | Rich program model, speaker/session detail, possibly gated content, document/media support |
| Annual member meeting / shareholder meeting | Identity verification, restricted audience, agenda documents, notifications, Q&A, voting or decision tracking, post-meeting results | Event-level access rules, secure entry state, document center, alerts, and room for future voting/Q&A integrations |
| Political summit / high-security international meeting | Accreditation, access control, security notices, continuity planning, media flows, transport coordination | Role-based access, special-entry notices, incident messaging, media-facing vs delegate-facing content separation |
| Cinema / live theater / stadium | Fast ticket lookup, seating, concessions, parking, one-show or one-game planning, loyalty/membership | Borrow digital-ticket wallet, seat-aware information, concessions/restaurant guidance, notifications, and visit convenience patterns |

## Existing App Patterns Worth Copying

### Trade Fair / Convention Patterns

Official trade-fair apps consistently provide:

- Ticket wallet or digital admission
- Exhibitor and product search
- Interactive hall or fairground maps
- Event schedule and personal planning
- Favorites / watchlists
- Push notifications
- Networking or lead capture in more professional events

Strong references:

- Messe Frankfurt Navigator: online ticket in app, exhibitor search, fairground plan, events, news, favorites, QR scanning/contact saving
- EISENWARENMESSE app: ticket wallet, hall plan, push notifications, location-based services, networking, lead tracking, favorites
- NACS Show app: keyword search, exhibitors, booths, education sessions, speakers, interactive maps, personal agenda sync, push notifications

### Congress / Annual-Meeting Patterns

Official congress and association apps consistently provide:

- Personal schedule planning
- People finder / attendee directory
- Session and speaker detail
- Handouts, evaluations, or abstracts
- Indoor navigation
- Notifications for updates and schedule changes
- Sometimes hybrid or on-demand access

Strong references:

- AAOS Annual Meeting app: schedule planning, people finder, exhibitor offerings, handouts/evaluations, indoor navigation
- AAG Annual Meeting app: program browsing, personal calendar, maps, presenters, abstracts, attendee list, exhibitor list, alerts
- EHA2026 and ESTRO 2026 web patterns: registration, searchable program, abstract/poster content, accommodation, delegate services, online platform access

### Stadium Patterns

Official stadium apps consistently provide:

- Mobile tickets and wallet support
- Ticket transfer
- Parking passes and directions
- Venue maps
- Concessions or food finder
- Event-day alerts and gate updates

Strong references:

- Gillette Stadium app: mobile ticketing, chatbot, notifications, directions, parking, seating charts, maps, concessions finder
- SoFi Stadium app: ticketing, parking passes, stadium navigation, food and beverage locations, ticket transfer, mobile-wallet support
- MLB Ballpark: venue-specific info, check-in offers, stadium maps, concession info, in-game features, gate updates, newer friction-reduction entry options

### Cinema Patterns

Official cinema apps consistently provide:

- Simple ticket buying
- Reserved seating
- Concessions pre-order
- Loyalty or rewards
- Digital ticket barcode

Strong reference:

- AMC Theatres app: movie discovery, rewards, tickets, reserved seating, concessions ordering, digital tickets, membership card

### Theater / Performing-Arts Patterns

Official theater apps consistently provide:

- Mobile tickets
- Upcoming events discovery
- Digital playbill or program book
- Parking/directions
- Ticket sharing or transfer
- Membership or donation hooks

Strong references:

- The Ruth app: upcoming events, digital playbill, mobile tickets, purchase/reservation, notifications
- Penn State Arts Ticket Center app: tickets from multiple presenters, wallet support, transfers, event discovery
- Mayo Performing Arts Center app: mobile tickets, purchase flow, parking and directions, digital program book, notifications, donations/membership

### Closed / Governance Meeting Patterns

Shareholder and governance apps emphasize:

- Identity-linked access
- Vote and agenda review
- Alerts
- Post-meeting results
- Multi-meeting visibility in one account

Strong reference:

- Broadridge ProxyVote app: review and vote proxies, control-number or account-linked access, alerts, voting preferences, final meeting results

## Recommended MassanApp Feature List

### Must-Have For The Prototype

- Upcoming-events calendar with category filter, type filter, and free-text search
- Event-first navigation where selecting an event turns the app into that event's mini-homepage
- Clear and always-available route back to "other events"
- Email-based registration and sign-in
- Simulated social sign-in options such as Google and Microsoft
- Logged-in "My Pages"
- Simulated ticket purchase flow
- "My Tickets" wallet with QR presentation
- Event sections for news, articles, program, exhibitors, exhibitor pages, and practical information
- Newsletter signup and preferences
- Shared venue-information layer for transport, parking, restaurants, security, and common venue facts

### Strongly Recommended In The Initial Architecture

- Event-type flags so the UI can enable or disable sections depending on whether the event is a fair, congress, conference, or simpler public event
- Saved/favorited sessions and exhibitors
- Session reminders or simulated notifications
- Per-event audience rules: public, professional-only, invite-only
- Reusable venue map and hall-location model
- Room in the schema for speakers, abstracts, sponsors, and access-control notes even if the first UI does not expose all of them

### Good Future Extensions, But Not Required For Issue #1

- Ticket transfer or sharing
- On-site wayfinding with hall and booth navigation
- Lead capture / networking for B2B visitors
- Hybrid or on-demand congress content
- Secure document center and voting/Q&A tooling for member meetings or shareholder meetings
- Food pre-ordering

## Recommendation For Later Tasks

- Use `Nordbygg 2026` as the first fully seeded event because it best matches the prototype's required user journey.
- Add one congress dataset, preferably `ESTRO 2026` or `EHA2026 Congress`, to force the data model to handle richer program and restricted-audience cases.
- Treat venue logistics as shared data, not event-local data. Then brand or subset that content per event.
- Keep the UI event-first and mobile-first. Do not let the app become a generic venue shell with equal weight on venue services and event content.

## Sources

- GitHub issue #1: https://github.com/hanneseklund/MassanApp/issues/1
- Stockholmsmassan home: https://stockholmsmassan.se/en/
- Stockholmsmassan about us: https://stockholmsmassan.se/en/about-us/
- Stockholmsmassan history: https://stockholmsmassan.se/en/about-us/our-history/
- Stockholmsmassan create-event / venues: https://stockholmsmassan.se/en/create-event/venues/
- Stockholmsmassan calendar: https://stockholmsmassan.se/en/calendar/
- Stockholmsmassan find us: https://stockholmsmassan.se/en/prior-to-your-visit/how-to-find-us/
- Stockholmsmassan parking: https://stockholmsmassan.se/en/prior-to-your-visit/parking/
- Stockholmsmassan restaurants: https://stockholmsmassan.se/en/prior-to-your-visit/restaurants/
- Stockholmsmassan security: https://stockholmsmassan.se/en/prior-to-your-visit/security/
- Stockholmsmassan our fairs: https://stockholmsmassan.se/en/our-fairs/
- Stockholmsmassan 2024 summary / 2025 readiness: https://stockholmsmassan.se/en/nyheter/stockholmsmassan-well-prepared-for-2025-focuses-on-sustainability-and-future-technology/
- Stockholmsmassan strategic-direction article: https://stockholmsmassan.se/en/nyheter/stockholmsmassan-looks-ahead-strengthening-its-role-as-the-nordic-regions-leading-exhibition-and-congress-venue/
- Stockholmsmassan public-fair handover article: https://stockholmsmassan.se/en/nyheter/new-organiser-of-public-fairs-at-stockholmsmassan/
- Nordbygg event page: https://stockholmsmassan.se/en/calendar/nordbygg/
- Nordbygg site: https://nordbygg.se/en/
- Nordbygg ticket entry: https://ticket.stockholmsmassan.se/cgi-bin/fmsm/lib/pub/tt.cgi/Hem.html?lang=11&oid=1875&ticket=g_u_e_s_t
- Formex event page: https://stockholmsmassan.se/en/calendar/formex-aug-2026/
- Formex site: https://formex.se/en/
- ESTRO 2026 Stockholmsmassan page: https://stockholmsmassan.se/en/calendar/estro-2026/
- ESTRO 2026 official page: https://www.estro.org/Congresses/ESTRO-2026
- EHA2026 Stockholmsmassan page: https://stockholmsmassan.se/en/calendar/eha2026-congress-2026-2/
- EHA2026 congress home: https://ehaweb.org/connect-network/eha2026-congress
- EHA2026 registration: https://ehaweb.org/connect-network/eha2026-congress/eha2026-registration
- Messe Frankfurt apps: https://www.messefrankfurt.com/frankfurt/en/services/apps.html
- EISENWARENMESSE app: https://www.eisenwarenmesse.com/trade-fair/eisenwarenmesse/app/
- NACS Show planner and app: https://www.nacsshow.com/MyShow-Planner
- AAOS annual meeting app: https://www.aaos.org/annual/attend/onsite-experiences/annual-meeting-mobile-app/
- AAG mobile app guide: https://www.aag.org/mobile-app-guide/
- T-Mobile Arena app: https://www.t-mobilearena.com/plan-your-visit/mobile-app-1
- Gillette Stadium app: https://www.gillettestadium.com/app/
- SoFi Stadium app: https://www.sofistadium.com/events/mobile-app
- MLB Ballpark app: https://www.mlb.com/apps/ballpark
- AMC Theatres app: https://apps.apple.com/us/app/amc-theatres-movies-more/id509199715
- The Ruth ticketing app: https://www.theruth.org/ticket-info/ticketing-app
- Penn State Arts Ticket Center app: https://cpa.psu.edu/arts-tickets-app
- Mayo Performing Arts Center mobile app: https://www.mayoarts.org/visitor-info/mobile-app/
- Broadridge ProxyVote app: https://www.shareholdereducation.com/se/proxyvote-app
