---
issue: 21
url: https://github.com/hanneseklund/MassanApp/issues/21
title: GUI changes (language flag dropdown, scrollable sections, hamburger menu)
---

Implement the GUI changes specified in issue #21:

1. **Language flags dropdown** — replace the inline language flags with a dropdown (collapsed by default, expand to choose language).

2. **Scrollable event sections** — when an event is selected, render all of these sections stacked vertically so the user can scroll through them:
   - News
   - Articles
   - Program
   - Exhibitors
   - Practical info
   - Food
   - Newsletter

   For every section *except* Practical info and Newsletter:
   - Show only the first 5 items.
   - If there are more than 5 items, show a link below the list (e.g. "all news", "all articles") that navigates to a dedicated page.
   - That dedicated page must show only that section's full list plus a "back" navigation link — no event info or other sections.

3. **Hamburger menu** — add a hamburger icon (three horizontal lines) in the upper-left corner. Menu entries:
   - My tickets *(only when an event is selected)*
   - Food *(only when an event is selected)*
   - Program *(only when an event is selected)*
   - Exhibitors *(only when an event is selected)*
   - Practical information *(only when an event is selected)*
   - Other events *(only when an event is selected)*
   - My pages *(always shown)*

Refer to issue #21 for the canonical spec; update there if scope shifts.
