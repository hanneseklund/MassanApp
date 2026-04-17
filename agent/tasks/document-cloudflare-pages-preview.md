## Document Cloudflare Pages Preview Deploy

References:
- issue #4: cloudflare pages configured

Context:
- Cloudflare Pages is wired to this repository. Pushes to the `agent`
  branch are automatically published to
  https://agent.massanapp-prototype.pages.dev/.
- This is currently undocumented; testers have no canonical pointer to
  the live preview.

Objective:
- Add the Cloudflare Pages preview URL and its update behavior to the
  testing documentation so reviewers can exercise the prototype without
  running it locally.

Scope (do):
- Update `docs/installation-testing-specification.md` to add a section
  (or extend an existing one) covering the hosted preview:
  - URL: https://agent.massanapp-prototype.pages.dev/
  - Source branch: `agent` (auto-published on push).
  - When to use the hosted preview vs. running locally — note that the
    hosted build runs in the Supabase-less local-seed mode unless/until
    Supabase env wiring is added on the Pages project.
  - Note that the hosted preview lags any uncommitted local changes.
- Cross-link the new section from the smoke-test checklist intro so a
  tester knows they can run the checklist against the hosted URL.
- If `README.md` has a "Try it" / live demo section, add the URL there
  too; otherwise leave the README alone — testing details belong in the
  testing spec per `AGENTS.md`.

Scope (do not):
- Add Cloudflare deployment configuration, build commands, or Pages
  project settings to the repo. The configuration lives in the Cloudflare
  dashboard and is out of scope for this task.
- Document Supabase env wiring on Cloudflare Pages until that is
  actually set up — speculative instructions would mislead testers.
- Update the implementation specification — hosting is a deploy concern,
  not part of the prototype's implementation contract.

Acceptance Criteria:
- `docs/installation-testing-specification.md` contains the preview URL
  and a one-paragraph explanation of the auto-publish behavior.
- The smoke-test checklist makes clear that it can be run against either
  a local server or the hosted preview.
- No references to the URL exist as bare strings without the
  surrounding context (branch, auto-publish, simulated mode).
