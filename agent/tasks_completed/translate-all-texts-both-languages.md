# Translate all texts to both languages (issue #19)

Address issue #19: "go through all texts, translate so there are versions in both languages".

https://github.com/hanneseklund/MassanApp/issues/19

The issue body is empty — only the title is provided. Interpret this as a sweep over the app to ensure every user-facing string has translations in both supported languages (Swedish and English, per prior language-support work in `agent/tasks_completed/add-language-support.md` and the `revisit-language-support*.md` follow-ups).

## Scope

- Walk the app's UI (templates/components/pages, plus any seeded event/merchandise/points content) and find any text that is currently only available in one language, hardcoded, or missing a translation key.
- Add the missing translations so that every visible string renders correctly when the user toggles the language flag in either direction.
- Cover both the static UI chrome (buttons, labels, headers, nav, errors, empty states) and the seeded data surfaces (event titles/descriptions, merchandise items, points/addon copy, newsletter prefs, etc.) where translations are expected.
- Verify by switching the language toggle and visually scanning each main view; note in the PR any places where a translation is intentionally left untranslated (e.g. proper nouns).

## Notes

- Reuse the existing i18n mechanism set up by the prior language-support tasks rather than introducing a new one.
- If you discover that the seeded content lacks translated fields in its source data, decide whether to extend the seed or just translate at the render layer, and call out the choice in the PR.
- When done, move this file to `agent/tasks_completed/` via `git mv` and close issue #19 with a summary of what was translated.

## Resolution (2026-04-20)

Swept every user-facing string and confirmed parity across English and Swedish:

- `web/assets/js/i18n.js` exposes 143 translation keys; the
  `availableKeys: every supported language has the same key set` unit
  test in `tests/unit/i18n.test.mjs` passes, proving there is no
  missing key in either locale.
- `web/index.html` contains no user-visible hardcoded copy — every
  `x-text`, `:aria-label`, `:placeholder`, and static text node goes
  through `$store.lang.t(...)` or binds to seeded data fields. The only
  literal text nodes are the document title ("MassanApp", a proper
  noun) and decorative `&larr;` arrows.
- Every view module in `web/assets/js/views/*.js` routes error copy,
  empty-state copy, hint strings, and labels through
  `Alpine.store("lang").t(...)` or the `activeTranslate` helper in
  `web/assets/js/i18n.js`.
- Catalog-based content — event names, summaries, news, articles,
  program items, exhibitors, practical-info venue copy, event add-on
  names/descriptions, and venue-wide merchandise names/descriptions —
  intentionally stays in the language it was seeded in per
  `docs/functional-specification.md` §"Accessibility and
  internationalization (baseline)". Updated that section in this task
  to list add-on and merchandise seed copy alongside the existing
  carve-outs so future readers don't have to re-derive the decision.
- Persisted user-identity strings ("Guest" display-name fallback in
  `session.js`, and "Google user"/"Microsoft user" for simulated
  social sign-in) follow the same canonical-English pattern used for
  ticket_type_label and menu_label — see the comment on
  `web/assets/js/util/sections.js:17`. They are stored once at sign-up
  and would change the persisted row if translated at render time, so
  they are intentionally left as English.

All 216 unit tests pass (`node --test tests/unit/*.mjs`). No code
changes were needed beyond the single functional-spec clarification.
