-- Add a hero_image column to news_items so each news card can render
-- an associated image. For the prototype, seeded values point at the
-- parent event's hero image to keep the card visually connected to
-- the event without committing a separate set of news thumbnails.

alter table public.news_items
  add column if not exists hero_image text;
