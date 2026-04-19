-- Points system: simulated loyalty points.
--
-- A signed-in visitor earns points on simulated ticket and food
-- purchases and can redeem them for event-specific add-ons or
-- venue-wide merchandise. See "Points" in docs/functional-specification.md
-- and "Point transaction", "Point add-on", and "Merchandise item" in
-- docs/implementation-specification.md.
--
-- Balance is computed as `sum(delta)` over the user's rows — no
-- denormalised balance column, so the balance cannot drift from the
-- history. Earns carry positive deltas; redemptions carry negative
-- deltas with `source_ref` pointing at the catalog row redeemed.

create table if not exists public.point_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  event_id text references public.events(id) on delete set null,
  source text not null check (
    source in ('ticket', 'food', 'addon_redemption', 'merch_redemption')
  ),
  source_ref text,
  delta integer not null,
  created_at timestamptz not null default now()
);

create index if not exists point_transactions_user_idx
  on public.point_transactions (user_id);
create index if not exists point_transactions_user_created_idx
  on public.point_transactions (user_id, created_at desc);

create table if not exists public.point_addons (
  id text primary key,
  event_id text not null references public.events(id) on delete cascade,
  name text not null,
  description text,
  points_cost integer not null check (points_cost >= 0),
  image text,
  stock integer,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists point_addons_event_active_idx
  on public.point_addons (event_id, active);

create table if not exists public.merchandise (
  id text primary key,
  name text not null,
  description text,
  points_cost integer not null check (points_cost >= 0),
  image text,
  stock integer,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists merchandise_active_idx
  on public.merchandise (active);

alter table public.point_transactions enable row level security;
alter table public.point_addons enable row level security;
alter table public.merchandise enable row level security;

create policy "owners read point transactions" on public.point_transactions
  for select using (auth.uid() = user_id);
create policy "owners insert point transactions" on public.point_transactions
  for insert with check (auth.uid() = user_id);

create policy "public read point addons" on public.point_addons
  for select using (true);

create policy "public read merchandise" on public.merchandise
  for select using (true);
