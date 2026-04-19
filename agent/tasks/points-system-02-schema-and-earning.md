# Points system: schema and earning

Second of five sub-tasks for issue #16
(https://github.com/hanneseklund/MassanApp/issues/16). Depends on
`points-system-01-spec.md` having landed (spec-first rule). If that
task is not yet merged, wait or coordinate rather than starting here.

## Scope

- Add a new migration `supabase/migrations/000N_points_system.sql`
  creating:
  - `public.point_transactions` (id, user_id, event_id nullable,
    source, source_ref, delta int, created_at).
  - `public.point_addons` (id, event_id, name, description,
    points_cost int, image, stock nullable, active bool,
    created_at).
  - `public.merchandise` (id, name, description, points_cost int,
    image, stock nullable, active bool, created_at).
  - Row Level Security: `point_transactions` — owner read + owner
    insert (`auth.uid() = user_id`). `point_addons` and `merchandise`
    — public read, no public write.
  - Indexes on `point_transactions(user_id)`,
    `point_transactions(user_id, created_at desc)`,
    `point_addons(event_id, active)`, and
    `merchandise(active)`.
- Apply the migration to the shared project via
  `mcp__claude_ai_Supabase__apply_migration` in the same session
  (AGENTS.md "Publishing database changes"). If the MCP is not
  available, block the task.
- Seed a small catalog:
  - `point_addons`: ~3 rows per seeded event (Nordbygg 2026 and the
    congress event). Examples: "Exhibitor gift bag", "VIP access to
    keynote", "Event catalog hardcover".
  - `merchandise`: ~4 rows venue-wide. Examples: "Stockholmsmässan
    tote bag", "Stockholmsmässan cap", "Notebook", "Enamel pin".
  Update `supabase/seed/seed.sql` and apply via
  `mcp__claude_ai_Supabase__execute_sql`. Mirror in
  `web/data/catalog.json`.
- Add `web/assets/js/util/points.js` with `pointsForTicket(ticket)`
  and `pointsForFoodOrder(order)` implementing the earning rule
  chosen in the spec.
- Add `web/assets/js/stores/points.js` exposing `balance`,
  transactions list, `loading`, `error`, and `earn(...)` / `redeem(...)`
  methods. Subscribe to session changes.
- Wire earning into the existing flows:
  - `views/purchase.js`: after `simulatedPayment` succeeds and the
    ticket row is inserted, insert a matching
    `point_transactions` row via the store.
  - `views/food.js`: same, after a food order is persisted.
- The earning insert must not fail the ticket or food order if it
  errors — the spec-side user outcome is still "purchase succeeded".
  Surface the error to console and the points store's `error`
  state but keep the happy path visible.
- Translation keys for any new user-visible strings (even if most of
  the visible UI lands in later sub-tasks).

## Not in this task

- The My Pages balance surface (sub-task 03).
- The add-on redemption flow (sub-task 04).
- The merchandise shop (sub-task 05).

## Deliverables

- Migration file applied to the shared project and verified via
  `mcp__claude_ai_Supabase__list_tables` or `list_migrations`.
- Seed rows present in the shared project (verify with a
  `select count(*)`).
- `web/data/catalog.json` updated alongside the seed change.
- Earning rows visible in `public.point_transactions` after placing
  a simulated ticket or food order in the agent-branch preview.
