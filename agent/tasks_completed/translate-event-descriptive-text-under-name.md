# Translate the descriptive text shown under each event name (issue #27 follow-up)

The user reports on issue #27 that the descriptive text of the event —
the text shown right under the event name, visible both on the event
list (calendar) and on the event page itself — is still untranslated
when toggling the language.

References:
- https://github.com/hanneseklund/MassanApp/issues/27
- comment that triggered this task:
  https://github.com/hanneseklund/MassanApp/issues/27#issuecomment-4345290986
- prior pass on event/venue translations:
  `agent/tasks_completed/translate-seeded-content-dual-language-02-translate-events-and-venue.md`
- parity sweep that signed off on i18n the day before:
  `agent/tasks_completed/translate-all-texts-both-languages-recheck.md`

## What to do

1. Identify which seeded field actually renders right under the event
   name on the calendar/list view and on the event detail page (likely
   `events.subtitle` and/or `events.summary`, but verify by reading the
   relevant view components rather than assuming — start with
   `web/assets/js/views/calendar.js` and the event detail view).
2. Confirm whether the field has already been migrated to the
   `{en, sv}` shape and whether the renderer is going through `pickLang`
   (or the equivalent helper). The earlier task 02 in the translate
   series claims to have translated `events.subtitle` and
   `events.summary`, so the regression is most likely either:
   - a row in the seed (or `web/data/catalog.json`) that still has a
     plain-string value or a duplicate-English Swedish slot, or
   - a renderer that reads the field as a plain string and bypasses
     `pickLang`.
3. Fix whichever side is broken:
   - If it's a renderer issue, route the field through the same
     language-aware helper used elsewhere.
   - If it's missing data, add proper Swedish translations to every
     event row (in both `supabase/seed/seed.sql` and the mirror
     `web/data/catalog.json`). Don't translate brand/proper names; do
     translate descriptive copy.
4. Validate by toggling the language flag and visually checking the
   calendar list and at least one event detail page — the descriptive
   line under the event name must render in the selected language.
5. Re-run `npm run test:unit` — the i18n parity test must still pass.

## Scope guards

- Do not change the broader i18n mechanism; reuse `pickLang` /
  `web/assets/js/i18n.js`.
- Stay focused on the descriptive line under the event name on the
  list and detail pages. If you discover other untranslated event
  surfaces while investigating, file them as separate tasks rather
  than expanding this one — the user explicitly called out this one
  surface.

## Done

- Move this file to `agent/tasks_completed/` via `git mv` and add a
  short resolution note describing what was actually broken (data vs
  renderer) and what changed.
- Comment on issue #27 with the fix summary; only close the issue if
  the user has confirmed there are no other untranslated surfaces
  remaining.

## Resolution

**Root cause: data, not renderer.** The renderer
(`web/index.html:361,403` → `$store.lang.pick(event.summary)`) and the
seed file (`supabase/seed/seed.sql`) were both correct — every event
already had natural Swedish copy in `summary`, `subtitle`, and the
overrides/branding leaves. The live Supabase project
(`esvyrbsypfgpdhijyywz`), however, still held the duplicate-fill from
sub-task 01 of the dual-language migration: 42/42 events had
`summary->>'en' = summary->>'sv'`, same for `subtitle` and `name`. The
catalog store (`web/assets/js/stores/catalog.js`) loads from Supabase,
so the UI rendered English in both languages despite the seed and
`web/data/catalog.json` carrying real translations.

**Fix.** Re-applied the two `insert into public.events ... on conflict
(id) do update set ...` blocks from `supabase/seed/seed.sql`
(lines 104-186 and 196-720) to the live Supabase project via
`mcp__claude_ai_Supabase__execute_sql`. Idempotent — the upsert
overwrote the duplicated slots without touching anything else.

**Post-apply verification (live DB):**
- `summary_dup = 0`, `subtitle_dup = 0` across all 42 events.
- `name_dup = 32` remains as intended (brand names like "Nordbygg
  2026", "ESTRO 2026", "Skydd 2032" stay identical in both languages
  per task 02 guidance).
- Spot-check on `nordbygg-2026`, `yrkes-sm-2026`, `skydd-2032`
  confirms natural Swedish copy.

**No code changed.** `npm run test:unit` still passes (442 tests).
