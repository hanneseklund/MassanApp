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
