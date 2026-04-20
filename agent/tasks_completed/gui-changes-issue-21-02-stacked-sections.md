---
issue: 21
url: https://github.com/hanneseklund/MassanApp/issues/21
title: GUI changes — stacked event sections and full-list pages
parent: gui-changes-issue-21.md
---

# GUI changes — stacked event sections with full-list pages

Part 2 of the issue #21 split. See `gui-changes-issue-21.md` for the
original umbrella task.

## Objective

Change the event view from a tab-per-section layout to a long,
scrollable page where every section is rendered one below the other.
For lists that can grow long (News, Articles, Program, Exhibitors,
Food), show only the first 5 items and a "see all" link below the
list. That link opens a dedicated page showing only that section's
full list plus a "back" link — no event hero, no other sections.

Practical info and Newsletter stay inline in the scroll layout with
their full content and do not get "see all" pages.

## Affected sections

Stacked on the event page, in this order:

1. News (truncate to 5, link to full list)
2. Articles (truncate to 5, link to full list)
3. Program (truncate to 5 sessions total across all days, link to
   full list — keep the by-day grouping on the full page)
4. Exhibitors (truncate to 5, link to full list; the detail page for a
   single exhibitor keeps its current route and back-to-list behavior)
5. Practical info (full content inline, no "see all")
6. Food (truncate — see note below — link to full list)
7. Newsletter (full content inline, no "see all")

Note on Food: the Food section is a 3-step order flow, not a list.
Interpret "first 5 items" as truncating the menu grid (step 1) to 5
menus on the inline summary and linking out to the full Food page for
the rest of the flow. If there are 5 or fewer menus, show them all
inline and omit the link, matching the general rule.

## Routing

Add new hash routes for dedicated full-list pages:

- `#/event/<id>/news` — full news list (keep current path; now only
  full list + back)
- `#/event/<id>/articles` — full articles list
- `#/event/<id>/program` — full program grouped by day
- `#/event/<id>/exhibitors` — full exhibitor index (the
  `#/event/<id>/exhibitors/<exhibitorId>` detail route is unchanged)
- `#/event/<id>/food` — full food order flow

These already exist in `parseHash` / `buildHash` in
`web/assets/js/stores/app.js`. Keep them, but the views they render
must switch from the current tab-inside-event layout to the
"only this section + back link" layout described in the issue.

The event landing route `#/event/<id>` now renders the stacked layout
(hero + all sections). The `eventSubview` concept stays in the store
for backwards compatibility with routing, but the event view no longer
renders one-section-at-a-time based on it; the landing route simply
maps to the stacked layout, and each subview route maps to its
dedicated full-list page.

The practical info and newsletter "subview" routes should redirect or
scroll to the corresponding anchor on the stacked event page, since
they don't have dedicated full-list pages. Pick whichever is simplest
to implement cleanly — anchor scroll is fine and matches the stacked
layout.

## Scope (do)

- Refactor `web/index.html` event section so the stacked layout replaces
  the tab navigation + single-subview render. Remove the `event-nav`
  tab bar.
- Extract the per-section rendering into reusable blocks. The inline
  event layout uses the truncated view; the dedicated `#/event/<id>/<x>`
  routes use a new view (or a flag on the existing one) that renders
  only the full list plus a back link.
- Add a helper in `web/assets/js/views/event.js` (or a new view file
  per dedicated page — prefer the former for small additions and the
  latter if a view gets large) that returns the first 5 items and an
  "hasMore" flag for each section.
- Add a "back" link on each dedicated full-list page that returns to
  the event landing route `#/event/<id>`.
- Add translation keys for the "all news" / "all articles" / etc.
  links and the back link in `web/assets/js/i18n.js`. Cover both
  English and Swedish.
- Update `docs/functional-specification.md` to describe the stacked
  layout, the 5-item truncation rule, and the dedicated full-list
  pages.
- Update `docs/implementation-specification.md` to describe the
  routing shape and the split between the stacked landing view and
  the dedicated section pages.
- Update any smoke tests in `tests/` that navigate via the tab bar to
  instead scroll to the section or follow the "see all" link, if
  applicable. Do not break the food-ordering smoke test — confirm the
  dedicated food page still supports the full 3-step flow.

## Scope (do not)

- Do not change the data model or catalog.
- Do not change the exhibitor detail page (still `/<id>` under
  `exhibitors`).
- Do not add the hamburger menu here — that is subtask 03. However,
  be mindful that the hamburger's "food", "program", "exhibitors",
  "practical information" entries will link to the dedicated pages
  introduced here, so the routes must be stable.

## Acceptance criteria

- Visiting `#/event/<id>` shows the hero followed by all sections in
  the order above, each truncated to 5 items where applicable.
- Each truncated section with more than 5 items shows a single link
  below the list labelled like "all news (42)" / "all articles (17)"
  (exact copy per spec update; include the total count is a nice-to-
  have but not required).
- Clicking the "see all" link navigates to the dedicated page, which
  shows only the list + back link.
- Practical info and Newsletter render in full inline with no "see
  all".
- Exhibitor detail (`#/event/<id>/exhibitors/<exhibitorId>`) still
  works and still offers "back to exhibitors" to the dedicated
  exhibitor index page.
- Specs updated. Smoke tests pass.
