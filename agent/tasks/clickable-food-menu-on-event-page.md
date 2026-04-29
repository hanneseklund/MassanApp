---
issue: 28
url: https://github.com/hanneseklund/MassanApp/issues/28
---

# Make event-page food menu items clickable

On the event page, where food is displayed inline with other content, make the
food menu items clickable so that clicking one navigates to the food ordering
page with the clicked menu item selected.

See issue #28 for the full request.

## Notes
- Identify how food is rendered inline on the event page and how the food
  ordering page selects/preselects items.
- Pass the clicked item's identifier through navigation (route param, query
  string, or shared state) so the ordering page can preselect it.
- Verify with the food-ordering smoke test (or extend it) that the preselection
  works end-to-end.
