---
issue: 27
title: Ensure all texts on all items have versions in both languages
url: https://github.com/hanneseklund/MassanApp/issues/27
---

# Ensure all texts on all items have versions in both languages

Address issue #27: make sure all texts on all items have versions in
both languages (Swedish and English). Translate any missing strings.

This is broader than the in-progress per-letter exhibitor translation
tasks (nordbygg K–Z) — it covers every item type across the app
(events, venues, news/editorial, program/speakers, exhibitors, addons,
merchandise, points docs, UI strings, etc.).

## Scope

- Audit all seed/content data and any embedded text in the app for
  items that are missing either the Swedish or English variant.
- Translate the missing language for each affected item.
- Verify rendering in both language modes for all item categories,
  not just the ones recently touched.

## References

- Issue: https://github.com/hanneseklund/MassanApp/issues/27
- Prior related work (already completed) lives in
  agent/tasks_completed/translate-seeded-content-dual-language*.md
  and translate-all-texts-both-languages*.md — use those for context
  on the i18n shape and helpers; do not redo work already merged.
- Coordinate with any still-pending nordbygg exhibitor translation
  tasks remaining in agent/tasks (letters K–Z) so coverage is
  complete and not duplicated.

## Done when

- Every item rendered by the app has both `sv` and `en` text for
  every user-visible string.
- Switching language never falls back to the other language for a
  missing translation.
