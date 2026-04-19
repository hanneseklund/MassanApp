-- Food ordering: persisted orders placed from the event "Food" tab.
-- The menu catalog (10 menus), pickup locations, and restaurant
-- timeslots are static data in web/assets/js/util/food.js and do not
-- need DB tables. Only the user-placed orders are persisted.

create table if not exists public.food_orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  event_id text not null references public.events(id) on delete restrict,
  menu_id text not null,
  menu_label text not null,
  price text not null,
  delivery_mode text not null check (delivery_mode in ('pickup', 'timeslot')),
  delivery_id text not null,
  delivery_label text not null,
  timeslot_from timestamptz,
  timeslot_to timestamptz,
  transaction_ref text not null,
  ordered_at timestamptz not null default now()
);

create index if not exists food_orders_user_idx
  on public.food_orders (user_id);
create index if not exists food_orders_event_idx
  on public.food_orders (event_id);

alter table public.food_orders enable row level security;

create policy "owners read food orders" on public.food_orders
  for select using (auth.uid() = user_id);
create policy "owners insert food orders" on public.food_orders
  for insert with check (auth.uid() = user_id);
