-- MassanApp prototype schema.
--
-- Mirrors the data model in docs/implementation-specification.md and the
-- seed shape in web/data/catalog.json. The prototype uses a single venue
-- record, multiple events tied to that venue, and per-event content
-- (news, articles, program items, exhibitors, speakers).

create table if not exists public.venues (
  id text primary key,
  name text not null,
  address jsonb,
  transport jsonb,
  parking jsonb,
  restaurants jsonb,
  security jsonb,
  sustainability text,
  maps jsonb
);

create table if not exists public.events (
  id text primary key,
  venue_id text not null references public.venues(id) on delete restrict,
  name text not null,
  subtitle text,
  type text not null,
  category text not null,
  audience_rule text not null default 'public',
  ticket_model text not null default 'public_ticket',
  start_date date not null,
  end_date date not null,
  summary text,
  branding jsonb,
  overrides jsonb
);

create table if not exists public.news_items (
  id text primary key,
  event_id text not null references public.events(id) on delete cascade,
  published_at timestamptz not null,
  title text not null,
  body text not null
);

create index if not exists news_items_event_idx
  on public.news_items (event_id, published_at desc);

create table if not exists public.articles (
  id text primary key,
  event_id text not null references public.events(id) on delete cascade,
  title text not null,
  body text not null,
  hero_image text
);

create index if not exists articles_event_idx
  on public.articles (event_id);

create table if not exists public.speakers (
  id text primary key,
  name text not null,
  bio text,
  affiliation text,
  avatar text
);

create table if not exists public.program_items (
  id text primary key,
  event_id text not null references public.events(id) on delete cascade,
  day date not null,
  start_time time not null,
  end_time time not null,
  title text not null,
  description text,
  location text,
  track text,
  speaker_ids text[] not null default '{}'
);

create index if not exists program_items_event_idx
  on public.program_items (event_id, day, start_time);

create table if not exists public.exhibitors (
  id text primary key,
  event_id text not null references public.events(id) on delete cascade,
  name text not null,
  booth text,
  description text,
  website text,
  logo text
);

create index if not exists exhibitors_event_idx
  on public.exhibitors (event_id);

-- Tickets and newsletter subscriptions are stored for the later
-- auth/ticketing task, but the tables are created here so the seed and
-- frontend code paths can assume they exist.

create table if not exists public.tickets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  event_id text not null references public.events(id) on delete restrict,
  ticket_type text not null default 'standard',
  attendee_name text not null,
  attendee_email text not null,
  qr_payload text not null,
  purchased_at timestamptz not null default now()
);

create index if not exists tickets_user_idx on public.tickets (user_id);
create index if not exists tickets_event_idx on public.tickets (event_id);

create table if not exists public.newsletter_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  email text not null,
  event_id text references public.events(id) on delete cascade,
  preferences jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists newsletter_email_idx
  on public.newsletter_subscriptions (email);

-- Row level security: shared content is readable by anyone, tickets and
-- newsletter subscriptions are scoped to the authenticated owner.

alter table public.venues enable row level security;
alter table public.events enable row level security;
alter table public.news_items enable row level security;
alter table public.articles enable row level security;
alter table public.program_items enable row level security;
alter table public.exhibitors enable row level security;
alter table public.speakers enable row level security;
alter table public.tickets enable row level security;
alter table public.newsletter_subscriptions enable row level security;

create policy "public read venues" on public.venues
  for select using (true);
create policy "public read events" on public.events
  for select using (true);
create policy "public read news" on public.news_items
  for select using (true);
create policy "public read articles" on public.articles
  for select using (true);
create policy "public read program" on public.program_items
  for select using (true);
create policy "public read exhibitors" on public.exhibitors
  for select using (true);
create policy "public read speakers" on public.speakers
  for select using (true);

create policy "owners read tickets" on public.tickets
  for select using (auth.uid() = user_id);
create policy "owners insert tickets" on public.tickets
  for insert with check (auth.uid() = user_id);

create policy "owners read newsletter" on public.newsletter_subscriptions
  for select using (auth.uid() = user_id);
create policy "anyone insert newsletter" on public.newsletter_subscriptions
  for insert with check (true);
create policy "owners update newsletter" on public.newsletter_subscriptions
  for update using (auth.uid() = user_id);
