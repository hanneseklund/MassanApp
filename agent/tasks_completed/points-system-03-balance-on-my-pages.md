# Points system: balance on My Pages

Third of five sub-tasks for issue #16
(https://github.com/hanneseklund/MassanApp/issues/16). Depends on
`points-system-02-schema-and-earning.md`.

## Scope

- In `views/me.js` and the corresponding template block in
  `web/index.html`, add a "Points" section that shows:
  - Current balance (sum over the signed-in user's
    `point_transactions`).
  - A short "how you earn points" blurb sourced from i18n.
  - A link to the points shop (route from sub-task 05; use a
    placeholder route for now if 05 hasn't landed yet, and make it
    replace cleanly).
  - A short list of the user's most recent transactions (last ~5),
    each with the earn/redeem label, event if any, and delta.
- Follow the existing load-error pattern used by tickets and
  newsletter: if the points store's `error` is set, surface it
  rather than silently rendering an empty balance.
- Translate every new chrome string in both `en` and `sv` in
  `web/assets/js/i18n.js`. The `tests/unit/i18n.test.mjs` suite
  requires parity.
- Update relevant smoke tests under `tests/` to assert the balance
  reflects a simulated ticket or food purchase made earlier in the
  same run. Reuse the existing auth / purchase / food-order fixtures
  rather than inventing new ones.

## Not in this task

- Schema or seed changes (sub-task 02).
- Redemption UI (sub-tasks 04 and 05).

## Deliverables

- Points section visible on `#/me` after signing in.
- i18n parity preserved.
- Smoke coverage for the balance displaying a non-zero value after
  a simulated purchase.
