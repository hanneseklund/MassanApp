---
issue: 21
url: https://github.com/hanneseklund/MassanApp/issues/21
title: GUI changes — hamburger menu
parent: gui-changes-issue-21.md
---

# GUI changes — hamburger menu

Part 3 of the issue #21 split. See `gui-changes-issue-21.md` for the
original umbrella task. This task depends on subtask 02 landing first,
because several menu entries link to the dedicated section pages
introduced there.

## Objective

Add a hamburger menu in the upper-left corner of the chrome. Tapping
it opens a menu panel; tapping an entry navigates to the corresponding
view and closes the panel.

## Menu entries

In order, top to bottom:

- My tickets — only shown when an event is selected
- Food — only shown when an event is selected; links to the dedicated
  food page (`#/event/<id>/food`) from subtask 02
- Program — only shown when an event is selected; links to the
  dedicated program page (`#/event/<id>/program`)
- Exhibitors — only shown when an event is selected; links to the
  dedicated exhibitors page (`#/event/<id>/exhibitors`)
- Practical information — only shown when an event is selected;
  scrolls/navigates to the practical-info section on the event page
  (see subtask 02 for the chosen mechanism)
- Other events — only shown when an event is selected; navigates to
  the calendar (`#/`)
- My pages — always shown

"An event is selected" means `$store.app.eventId` is set. Note this
stays set while the user is in a subview or a dedicated full-list
page of that event, so the gated entries remain visible in those
contexts.

## Scope (do)

- Add the hamburger button to the chrome in `web/index.html`. Place
  it at the upper-left. It replaces the "Back to events" button in
  that slot — the "back to events" action is now reached through the
  "Other events" hamburger entry and through the calendar/home icon
  flow; confirm this in the functional spec update.
- Implement the panel with Alpine. Options:
  - Inline dropdown panel anchored under the hamburger button.
  - Off-canvas sidebar sliding in from the left.
  Pick the simpler mobile-first option — off-canvas sidebar is fine
  and matches common conventions; inline dropdown is also acceptable.
- Close on outside click, Escape, and after an entry is selected.
- Accessibility: `aria-expanded`, `aria-controls`, `role="menu"` /
  `role="menuitem"` on entries, and `aria-label` on the hamburger
  button (translated via `$store.lang`).
- Add i18n keys for the button label and every entry in
  `web/assets/js/i18n.js`, English and Swedish.
- Style in `web/assets/css/app.css`.
- Update `docs/functional-specification.md` to describe the
  hamburger menu, its entries, and the gating rule.
- Update smoke tests if any relied on the top-left back button that
  is being replaced.

## Scope (do not)

- Do not restructure the stacked event view — that is subtask 02.
- Do not change the language dropdown on the right — that is
  subtask 01.
- Do not change what "My tickets" / "My pages" / "Food" / "Program" /
  "Exhibitors" / "Practical information" / calendar do — only add
  the new entry point.

## Acceptance criteria

- Hamburger icon is visible in the upper-left in every view.
- Tapping it opens the menu; the visible entries obey the gating
  rules above.
- Each entry navigates to the correct route and closes the menu.
- Keyboard and screen reader support works (tabbable toggle,
  Escape closes, roles set).
- Functional spec updated.
