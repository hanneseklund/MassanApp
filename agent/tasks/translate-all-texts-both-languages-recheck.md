# Re-verify all texts have both-language versions (issue #27)

Address issue #27: "make sure all texts on all items have versions in both languages, translate if missing".

https://github.com/hanneseklund/MassanApp/issues/27

The issue body is empty — only the title is provided. This is a follow-up sweep to the earlier translation pass tracked in `agent/tasks_completed/translate-all-texts-both-languages.md` (issue #19, resolved 2026-04-20). Since that resolution, new features and content have landed (food ordering, points/merchandise, ticket questionnaire, hamburger menu, event add-ons, etc.), so re-verify that every newly-added user-facing string has translations in both supported languages (Swedish and English).

## Scope

- Re-walk the app's UI (templates/components/views) and seeded data surfaces and find any text that is currently only available in one language, hardcoded, or missing a translation key — focusing on anything added since the 2026-04-20 sweep.
- Add the missing translations so every visible string renders correctly when the user toggles the language flag in either direction.
- Cover both static UI chrome (buttons, labels, headers, nav, errors, empty states) and seeded data surfaces (events, food menus, merchandise items, points/addon copy, questionnaire copy, etc.) where translations are expected.
- Re-run the i18n parity unit test (`availableKeys: every supported language has the same key set` in `tests/unit/i18n.test.mjs`) and add new keys to both locales together so the test continues to pass.
- Verify by toggling the language flag and visually scanning each main view; note in the PR any places intentionally left untranslated (proper nouns, persisted-identity strings — see the carve-outs documented in `docs/functional-specification.md` §"Accessibility and internationalization (baseline)" and the prior task's resolution notes).

## Notes

- Reuse the existing i18n mechanism in `web/assets/js/i18n.js` — do not introduce a new one.
- Catalog-based content (event names, summaries, news, articles, program items, exhibitors, practical-info venue copy, add-on names/descriptions, venue-wide merchandise names/descriptions) is intentionally seeded in one language per the functional spec. Don't translate it at render time; if scope demands translating new catalog content, extend the seed and call out the choice in the PR.
- Persisted user-identity strings (display-name fallback "Guest", simulated social-sign-in labels) are intentionally English — see the comment on `web/assets/js/util/sections.js`.
- When done, move this file to `agent/tasks_completed/` via `git mv` and close issue #27 with a summary of what was translated (or, if the existing coverage is already complete, what was checked and the test results that prove it).
