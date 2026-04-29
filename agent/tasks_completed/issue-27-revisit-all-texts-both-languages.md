---
issue: 27
title: Revisit — ensure all texts on all items have versions in both languages
url: https://github.com/hanneseklund/MassanApp/issues/27
---

# Revisit issue #27 — all texts in both languages

Issue #27 has new activity (updated 2026-04-29). A prior pass on this
issue was completed (see
`agent/tasks_completed/issue-27-ensure-all-texts-both-languages.md`),
so this is a re-check: review the latest state of the issue (any new
comments, examples, or reopened scope) and address whatever still
remains.

## Steps

- Read the current state of issue #27 (comments and any newly-listed
  items) to understand what triggered the new activity.
- Re-audit seed/content data and embedded UI strings for items that
  are still missing either the Swedish or English variant.
- Translate any newly-identified missing strings.
- Verify rendering in both `sv` and `en` modes for all item
  categories, including any specific examples called out in the
  issue's new comments.

## References

- Issue: https://github.com/hanneseklund/MassanApp/issues/27
- Prior pass:
  `agent/tasks_completed/issue-27-ensure-all-texts-both-languages.md`
- Background context on i18n shape and helpers:
  `agent/tasks_completed/translate-seeded-content-dual-language*.md`
  and `translate-all-texts-both-languages*.md`.

## Done when

- The new activity on issue #27 is addressed (any specific items
  called out are fixed).
- Every item rendered by the app still has both `sv` and `en` text
  for every user-visible string; switching language never falls back
  to the other language for a missing translation.
