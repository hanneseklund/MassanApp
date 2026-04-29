-- Dual-language seed shape, sub-task 01c4: points-system catalog.
--
-- Converts user-facing text columns on the points-system catalog tables —
-- `public.point_addons` and `public.merchandise` — to the dual-language
-- `jsonb { "en", "sv" }` shape introduced in agent task
-- -01a-helper-and-views.md and described in the issue #27 plan. The
-- render-time helper `pickLang` (web/assets/js/util/i18n-content.js)
-- resolves the active language and treats a plain string as a
-- transitional fallback, so the views continue to render correctly with
-- mixed-shape data while the seed catches up.
--
-- This migration is idempotent. Each top-level text column is converted
-- to jsonb only if its current data type is still `text`; a second run
-- is a no-op because the type checks fall through.
--
-- Companion sub-tasks 01c1, 01c2, 01c3 carry the equivalent migrations
-- for events/venues, editorial content, and exhibitors. With this
-- migration in place every multilingual catalog text column is `jsonb`.
-- Real Swedish translations land in sub-task 05. Both `en` and `sv`
-- slots carry the existing seeded English copy until then.
--
-- Columns intentionally **not** converted:
--   `point_addons.image`, `merchandise.image` — asset paths.
--   `point_addons.id`, `merchandise.id`       — stable identifiers.

-- 1. point_addons: name, description -> jsonb { en, sv }.
do $$
begin
  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'point_addons'
          and column_name = 'name') = 'text' then
    alter table public.point_addons
      alter column name type jsonb
      using jsonb_build_object('en', name, 'sv', name);
  end if;

  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'point_addons'
          and column_name = 'description') = 'text' then
    alter table public.point_addons
      alter column description type jsonb
      using case
        when description is null then null
        else jsonb_build_object('en', description, 'sv', description)
      end;
  end if;
end$$;

-- 2. merchandise: name, description -> jsonb { en, sv }.
do $$
begin
  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'merchandise'
          and column_name = 'name') = 'text' then
    alter table public.merchandise
      alter column name type jsonb
      using jsonb_build_object('en', name, 'sv', name);
  end if;

  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'merchandise'
          and column_name = 'description') = 'text' then
    alter table public.merchandise
      alter column description type jsonb
      using case
        when description is null then null
        else jsonb_build_object('en', description, 'sv', description)
      end;
  end if;
end$$;
