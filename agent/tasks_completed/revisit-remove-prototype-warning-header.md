---
name: Revisit remove prototype warning header
issue: https://github.com/hanneseklund/MassanApp/issues/13
---

Issue #13 has new activity (likely reopened) — the previous attempt
(`tasks_completed/remove-prototype-warning-header.md`) did not fully
resolve it.

Re-check whether the prototype warning header is still present anywhere
(any page, any breakpoint) and remove it. Inspect why the prior change
was insufficient before applying a new fix.

## Resolution

No new activity required a fix. The previous removal (commit 8d7b1f3) fully
eliminated the `.sim-banner` element, the `sim-banner` CSS rules, the
`--sim-h` spacing variable, and the `sim.banner` i18n keys. The "new
activity" on issue #13 was the bot's own close event (2026-04-19T18:51:58Z),
not a reopen. Verified no remaining references to `sim-banner` / `sim.banner`
under `web/`.
