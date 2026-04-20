---
issue: 21
url: https://github.com/hanneseklund/MassanApp/issues/21
title: GUI changes (language flag dropdown, scrollable sections, hamburger menu)
status: split
---

# GUI changes (issue #21) — umbrella

This task was split into three independently-shippable subtasks, each
covering one of the three changes requested in the GitHub issue:

- `gui-changes-issue-21-01-language-dropdown.md` — collapse the two
  language flag buttons into a single dropdown.
- `gui-changes-issue-21-02-stacked-sections.md` — replace the event
  subview tab navigation with a stacked scroll layout. Lists (News,
  Articles, Program, Exhibitors, Food) truncate to 5 items with a
  "see all" link to a dedicated page containing only that list plus a
  back link. Practical info and Newsletter remain inline in full.
- `gui-changes-issue-21-03-hamburger-menu.md` — add a hamburger
  button to the upper-left chrome with a context-aware menu. Depends
  on subtask 02 landing first (it links to the dedicated full-list
  pages introduced there).

## Original spec

Refer to the subtask files for detailed scope. The canonical source is
issue #21 on GitHub.

## Why split

Each of the three changes touches a different part of the app and can
be reviewed and shipped independently. The stacked-sections work is
the largest and introduces new routes; the other two are smaller,
contained changes.
