# Revisit language support (issue #8) — round 2

Issue #8 (https://github.com/hanneseklund/MassanApp/issues/8) received further
activity on 2026-04-18 18:05 UTC, after both `add-language-support.md` and
`revisit-language-support.md` had already been completed (see
`agent/tasks_completed/`).

Steps:
1. Fetch the latest state of issue #8 (comments, edits, reopen) to determine
   what the new activity is asking for. Check whether the user has reported a
   bug, requested an additional language, asked for UX changes, or commented
   on the existing implementation.
2. Verify the current English/Swedish language switch still works end-to-end
   (toggle in UI, persistence across navigation/reload, all user-facing
   strings translated).
3. Address whatever the new activity surfaces.

If the new activity needs clarification from the user, move this task to
`agent/tasks_blocked` with a note describing the open question.

When done, move this file to `agent/tasks_completed` with `git mv`.

## Resolution (2026-04-18)

The "activity at 2026-04-18 18:05 UTC" referenced above is the bot's own
close event for issue #8 (`closed` at `2026-04-18T18:05:57Z` by
`hannes-agent-scheduler[bot]`, immediately after the completion comment at
18:02:32). The full issue-8 timeline contains exactly three entries:

1. `labeled` `agent` by `hanneseklund` — 17:43:42Z
2. `commented` (completion message) by the bot — 18:02:32Z
3. `closed` by the bot — 18:05:57Z

There is no new user comment, reopen, or edit. The trigger for this
follow-up task was therefore the bot's own close, not user feedback.

Verified that the existing implementation is still wired up correctly:

- `web/assets/js/i18n.js` exports 143 keys per language with full en/sv
  parity (no missing keys in either direction).
- `web/assets/js/stores/lang.js` initialises from `localStorage`
  (`massanapp_lang`), defaults to English, and supports `set` + `toggle`.
- `web/index.html` chrome bindings reference `$store.lang.t(...)` and the
  toggle button (`.chrome__lang`) flips between `EN`/`SV`.
- The Playwright smoke spec at `tests/playwright/smoke.spec.js:559`
  ("29-30: chrome switches between English and Swedish and persists across
  reload") already covers toggle + reload persistence.

Could not execute Playwright in this sandbox (missing system library
`libglib-2.0.so.0` for the bundled chromium-headless-shell), but the i18n
module's `translate(...)` returns the expected strings for both languages
when imported directly via Node, which is the same data path the templates
exercise.

No user action required, no code changes needed. Moving to
`agent/tasks_completed`.
