# Translate seeded/catalog content to both languages (issue #27 follow-up)

> **Status:** split into five runnable sub-tasks on 2026-04-29 because
> the change touches 8+ catalog tables, ~880 exhibitor rows, and a
> 4,400-line seed file — too large for a single agent session.
>
> Sub-tasks (in `agent/tasks/`, must land in order):
>
> 1. `translate-seeded-content-dual-language-01-shape-and-render-helpers.md`
>    — picks the `{en, sv}` jsonb shape, ships the migration, adds the
>    `pickLang` render helper, and seeds both slots with duplicated
>    English copy so the app keeps rendering. **Must land first.**
> 2. `translate-seeded-content-dual-language-02-translate-events-and-venue.md`
> 3. `translate-seeded-content-dual-language-03-translate-news-articles-program-speakers.md`
> 4. `translate-seeded-content-dual-language-04-translate-exhibitors.md`
>    — by far the largest payload (~870 exhibitor descriptions).
> 5. `translate-seeded-content-dual-language-05-translate-addons-and-merchandise.md`
>
> Sub-tasks 02–05 only depend on 01 having landed; among themselves
> they can run in any order or in parallel.

Address the new comment on issue #27 from @hanneseklund:

> translate seeded content also, so that all texts including content is dual language

https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4341441409

## Background

The earlier sweeps (`agent/tasks_completed/translate-all-texts-both-languages.md` for issue #19 and `agent/tasks_completed/translate-all-texts-both-languages-recheck.md` for issue #27) confirmed parity for UI chrome, but explicitly carved out **catalog/seeded content** (event names, summaries, news, articles, program items, exhibitors, practical-info venue copy, event add-on names/descriptions, venue-wide merchandise names/descriptions, food menus, etc.) per `docs/functional-specification.md` §"Accessibility and internationalization (baseline)".

The user is now reversing that carve-out: seeded content must also be dual-language.

## Scope

- Extend the seed data so every user-facing field on catalog items has both Swedish and English variants. Likely surfaces (verify against the current code/seed):
  - Events: name, summary, description, news items, articles, program items, exhibitor names/descriptions, practical-info copy.
  - Food menus / menu items: names, descriptions, item details.
  - Event add-ons: names, descriptions.
  - Venue-wide merchandise: names, descriptions.
  - Any other seeded text the previous sweeps catalogued as intentionally single-language.
- Update the render layer so it picks the right language variant from the seed based on the active language store, instead of rendering whatever raw string is in the catalog.
- Translate any currently-untranslated seeded copy. If a field was authored in Swedish, add an English variant; vice versa. Use natural translations — these are user-facing and should read fluently.
- Update `docs/functional-specification.md` §"Accessibility and internationalization (baseline)" to remove (or invert) the catalog-content carve-out, since it no longer applies.
- Update the persisted-identity carve-out comment on `web/assets/js/util/sections.js` if any of the affected fields (e.g. `ticket_type_label`, `menu_label`) are now expected to be dual-language too — confirm with the user's intent ("all texts including content") whether persisted display labels are in scope.

## Validation

- Re-run the i18n parity unit test (`availableKeys: every supported language has the same key set` in `tests/unit/i18n.test.mjs`) — should still pass since this task is mostly about catalog data shape, not new translation keys.
- Add or extend a unit test that asserts every catalog text field has both `en` and `sv` variants (and that the render helpers pick the right one).
- Toggle the language flag in the running app and visually scan every catalog surface (events list, event detail, news, program, exhibitors, food menus, merchandise, add-ons) to confirm copy switches correctly in both directions.
- Run the full unit suite (`npm run test:unit`).

## Notes

- This will be a larger change than the prior re-verify pass — touches seed files, render helpers, the functional spec, and likely test fixtures.
- Decide on a consistent shape for dual-language seed fields (e.g. `{ en: "...", sv: "..." }` vs. parallel `name_en` / `name_sv` columns) and apply it uniformly. Pick whichever fits the existing seed pattern best, and document the choice in the PR.
- Persisted-identity strings ("Guest" fallback, simulated social-sign-in labels) are a separate concern from seeded catalog content — leave them alone unless the user clarifies otherwise.
- When complete, move this file to `agent/tasks_completed/` via `git mv` and add a resolution summary on issue #27 (don't necessarily re-close the issue — the user may want to verify first).
