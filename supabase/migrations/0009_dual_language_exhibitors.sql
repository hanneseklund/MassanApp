-- Dual-language seed shape, sub-task 01c3: exhibitors.
--
-- Converts `public.exhibitors.description` from `text` to the
-- dual-language `jsonb { "en", "sv" }` shape introduced in agent task
-- -01a-helper-and-views.md and described in the issue #27 plan. The
-- render-time helper `pickLang` (web/assets/js/util/i18n-content.js)
-- resolves the active language and treats a plain string as a
-- transitional fallback, so the views continue to render correctly
-- with mixed-shape data while the seed catches up.
--
-- This migration is idempotent. The column is converted to jsonb only
-- if its current data type is still `text`; a second run is a no-op
-- because the type check falls through.
--
-- Companion sub-tasks 01c1, 01c2, 01c4 carry the equivalent migrations
-- for events/venues, editorial content, and the points/merchandise
-- tables; this migration intentionally does not touch them. Real
-- Swedish translations land in sub-task 04. Both `en` and `sv` slots
-- carry the existing seeded description (which for the scraped
-- Nordbygg directory is sometimes already Swedish) until then.
--
-- Columns intentionally **not** converted:
--   `exhibitors.name`    — company brand name, single canonical string.
--   `exhibitors.booth`   — short alphanumeric label, no translation.
--   `exhibitors.website` — URL.
--   `exhibitors.logo`    — asset path.

do $$
begin
  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'exhibitors'
          and column_name = 'description') = 'text' then
    alter table public.exhibitors
      alter column description type jsonb
      using case
        when description is null then null
        else jsonb_build_object('en', description, 'sv', description)
      end;
  end if;
end$$;
