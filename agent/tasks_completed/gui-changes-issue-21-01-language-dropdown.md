---
issue: 21
url: https://github.com/hanneseklund/MassanApp/issues/21
title: GUI changes — language flags in a dropdown
parent: gui-changes-issue-21.md
---

# GUI changes — language flags dropdown

Part 1 of the issue #21 split. The umbrella task
`gui-changes-issue-21.md` was split into three subtasks so each change
can ship independently:

- 01 — language flags dropdown (this file)
- 02 — stacked event sections with dedicated full-list pages
- 03 — hamburger menu

## Objective

Replace the inline language flag buttons in the top chrome with a
collapsed dropdown. Tapping the currently-selected flag expands the
dropdown so the user can switch language; selecting a language collapses
it again.

## Scope (do)

- Update `web/index.html` so the `.chrome__actions` language controls
  render as a single button that shows the current flag, with a popover
  / dropdown that lists the other language(s). Keep the `$store.lang`
  API unchanged (`$store.lang.current`, `$store.lang.set(code)`).
- Drive the open/closed state with Alpine (`x-data="{ open: false }"`
  on the chrome or a small language store). Close on outside click and
  on Escape, per standard dropdown conventions already used nowhere
  else in the prototype — it's fine to keep this simple.
- Style the dropdown in `web/assets/css/app.css`. Keep it mobile-first
  and aligned with the existing chrome styling. The toggle button must
  show the active flag and a small chevron; the panel lists the
  available languages by flag + label.
- Maintain accessibility parity with the existing flag buttons:
  `aria-haspopup="listbox"`, `aria-expanded`, per-item `role="option"`
  with `aria-selected`, and preserve the `$store.lang.labels.*` labels
  for screen readers.
- Update `docs/functional-specification.md` where the language toggle
  is described so it reflects the dropdown behavior.

## Scope (do not)

- Do not change which languages are available or their ordering — this
  is purely a UI re-shape.
- Do not touch the hamburger menu, event subviews, or routing. Those
  are in subtasks 02 and 03.
- Do not rename existing i18n keys.

## Acceptance criteria

- In both desktop and mobile widths, only one flag is visible in the
  chrome by default; expanding the dropdown reveals the alternate
  language(s).
- Clicking a language in the dropdown still invokes `$store.lang.set`
  and collapses the dropdown.
- Keyboard: the toggle is reachable via tab, Enter/Space expands it,
  Escape collapses it, and items inside can be selected with the
  keyboard.
- Smoke tests still pass (the language switch is exercised via
  `data-lang="en"` / `data-lang="sv"` attributes — keep those on the
  actual language option elements inside the dropdown so the tests
  continue to target them).
- Functional spec updated.
