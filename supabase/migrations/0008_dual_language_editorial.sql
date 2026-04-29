-- Dual-language seed shape, sub-task 01c2: editorial content.
--
-- Converts user-facing text columns on the editorial-content tables —
-- `public.news_items`, `public.articles`, `public.speakers`,
-- `public.program_items` — to the dual-language `jsonb { "en", "sv" }`
-- shape introduced in agent task -01a-helper-and-views.md and described
-- in the issue #27 plan. The render-time helper `pickLang`
-- (web/assets/js/util/i18n-content.js) resolves the active language
-- and treats a plain string as a transitional fallback, so the views
-- continue to render correctly with mixed-shape data while the seed
-- catches up.
--
-- This migration is idempotent. Each top-level text column is converted
-- to jsonb only if its current data type is still `text`; a second run
-- is a no-op because the type checks fall through.
--
-- Companion sub-tasks 01c1, 01c3, 01c4 carry the equivalent migrations
-- for events/venues, exhibitors, and the points/merchandise tables;
-- this migration intentionally does not touch them. Real Swedish
-- translations land in sub-task 03. Both `en` and `sv` slots carry
-- the existing seeded English copy until then.
--
-- Columns intentionally **not** converted:
--   `speakers.name`     — person name, single canonical string.
--   `program_items.track` — canonical-English category key, surfaced
--                           in the UI through the i18n label table.

-- 1. news_items: title, body → jsonb { en, sv }.
do $$
begin
  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'news_items'
          and column_name = 'title') = 'text' then
    alter table public.news_items
      alter column title type jsonb
      using jsonb_build_object('en', title, 'sv', title);
  end if;

  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'news_items'
          and column_name = 'body') = 'text' then
    alter table public.news_items
      alter column body type jsonb
      using jsonb_build_object('en', body, 'sv', body);
  end if;
end$$;

-- 2. articles: title, body → jsonb { en, sv }.
do $$
begin
  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'articles'
          and column_name = 'title') = 'text' then
    alter table public.articles
      alter column title type jsonb
      using jsonb_build_object('en', title, 'sv', title);
  end if;

  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'articles'
          and column_name = 'body') = 'text' then
    alter table public.articles
      alter column body type jsonb
      using jsonb_build_object('en', body, 'sv', body);
  end if;
end$$;

-- 3. speakers: bio, affiliation → jsonb { en, sv }.
--    `name` stays a single text string (person names).
do $$
begin
  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'speakers'
          and column_name = 'bio') = 'text' then
    alter table public.speakers
      alter column bio type jsonb
      using case
        when bio is null then null
        else jsonb_build_object('en', bio, 'sv', bio)
      end;
  end if;

  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'speakers'
          and column_name = 'affiliation') = 'text' then
    alter table public.speakers
      alter column affiliation type jsonb
      using case
        when affiliation is null then null
        else jsonb_build_object('en', affiliation, 'sv', affiliation)
      end;
  end if;
end$$;

-- 4. program_items: title, description, location → jsonb { en, sv }.
--    `track` stays a single text string (canonical category key).
do $$
begin
  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'program_items'
          and column_name = 'title') = 'text' then
    alter table public.program_items
      alter column title type jsonb
      using jsonb_build_object('en', title, 'sv', title);
  end if;

  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'program_items'
          and column_name = 'description') = 'text' then
    alter table public.program_items
      alter column description type jsonb
      using case
        when description is null then null
        else jsonb_build_object('en', description, 'sv', description)
      end;
  end if;

  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'program_items'
          and column_name = 'location') = 'text' then
    alter table public.program_items
      alter column location type jsonb
      using case
        when location is null then null
        else jsonb_build_object('en', location, 'sv', location)
      end;
  end if;
end$$;
