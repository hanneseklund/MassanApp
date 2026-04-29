-- Dual-language seed shape, sub-task 01c1: events + venues.
--
-- Converts user-facing text columns / jsonb leaves on `public.events`
-- and `public.venues` to the dual-language `jsonb { "en", "sv" }` shape
-- introduced in agent task -01a-helper-and-views.md and described in
-- the issue #27 plan. The render-time helper `pickLang`
-- (web/assets/js/util/i18n-content.js) resolves the active language
-- and treats a plain string as a transitional fallback, so the views
-- continue to render correctly with mixed-shape data while the seed
-- catches up.
--
-- This migration is idempotent. Top-level text columns are converted
-- to jsonb only if their current data type is still `text`; jsonb
-- leaves are wrapped only when they are still a JSON string. A
-- second run is a no-op because the type checks fall through.
--
-- Companion sub-tasks 01c2-01c4 carry the equivalent migrations for
-- editorial content, exhibitors, and the points/merchandise tables;
-- this migration intentionally does not touch them. Real Swedish
-- translations land in sub-task 02. Both `en` and `sv` slots carry
-- the existing seeded English copy until then.

-- Helper: wrap a jsonb leaf into `{ en, sv }` if it is still a JSON
-- string, otherwise return it unchanged. Created during the migration
-- and dropped at the end so we don't leave migration scaffolding in
-- the schema.
create or replace function public._wrap_lang_leaf(v jsonb)
  returns jsonb
  language sql
  immutable
as $$
  select case
    when v is null then null
    when jsonb_typeof(v) = 'string'
      then jsonb_build_object('en', v #>> '{}', 'sv', v #>> '{}')
    else v
  end
$$;

-- 1. events: top-level text columns → jsonb { en, sv }.
do $$
begin
  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'events'
          and column_name = 'name') = 'text' then
    alter table public.events
      alter column name type jsonb
      using jsonb_build_object('en', name, 'sv', name);
  end if;

  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'events'
          and column_name = 'subtitle') = 'text' then
    alter table public.events
      alter column subtitle type jsonb
      using case
        when subtitle is null then null
        else jsonb_build_object('en', subtitle, 'sv', subtitle)
      end;
  end if;

  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'events'
          and column_name = 'summary') = 'text' then
    alter table public.events
      alter column summary type jsonb
      using case
        when summary is null then null
        else jsonb_build_object('en', summary, 'sv', summary)
      end;
  end if;
end$$;

-- 2. events.branding.hero_image_credit (jsonb leaf).
update public.events
set branding = branding
  || jsonb_build_object(
       'hero_image_credit',
       public._wrap_lang_leaf(branding -> 'hero_image_credit')
     )
where branding is not null
  and jsonb_typeof(branding -> 'hero_image_credit') = 'string';

-- 3. events.overrides.{entrance, bag_rules, access_notes} (jsonb leaves).
update public.events
set overrides = overrides
  || (case when jsonb_typeof(overrides -> 'entrance') = 'string'
           then jsonb_build_object(
                  'entrance',
                  public._wrap_lang_leaf(overrides -> 'entrance'))
           else '{}'::jsonb end)
  || (case when jsonb_typeof(overrides -> 'bag_rules') = 'string'
           then jsonb_build_object(
                  'bag_rules',
                  public._wrap_lang_leaf(overrides -> 'bag_rules'))
           else '{}'::jsonb end)
  || (case when jsonb_typeof(overrides -> 'access_notes') = 'string'
           then jsonb_build_object(
                  'access_notes',
                  public._wrap_lang_leaf(overrides -> 'access_notes'))
           else '{}'::jsonb end)
where overrides is not null
  and (
    jsonb_typeof(overrides -> 'entrance') = 'string'
    or jsonb_typeof(overrides -> 'bag_rules') = 'string'
    or jsonb_typeof(overrides -> 'access_notes') = 'string'
  );

-- 4. events.questionnaire_subjects: array of strings → array of objects.
update public.events
set questionnaire_subjects = (
  select coalesce(jsonb_agg(
    case
      when jsonb_typeof(elem) = 'string'
        then jsonb_build_object('en', elem #>> '{}', 'sv', elem #>> '{}')
      else elem
    end
    order by ord
  ), '[]'::jsonb)
  from jsonb_array_elements(questionnaire_subjects)
       with ordinality as t(elem, ord)
)
where jsonb_typeof(questionnaire_subjects) = 'array'
  and exists (
    select 1
    from jsonb_array_elements(questionnaire_subjects) e
    where jsonb_typeof(e) = 'string'
  );

-- 5. venues.sustainability (top-level text → jsonb).
do $$
begin
  if (select data_type
        from information_schema.columns
        where table_schema = 'public'
          and table_name = 'venues'
          and column_name = 'sustainability') = 'text' then
    alter table public.venues
      alter column sustainability type jsonb
      using case
        when sustainability is null then null
        else jsonb_build_object('en', sustainability, 'sv', sustainability)
      end;
  end if;
end$$;

-- 6. venues.transport.summary + transport.modes[].{mode, detail}.
update public.venues
set transport = transport
  || (case when jsonb_typeof(transport -> 'summary') = 'string'
           then jsonb_build_object(
                  'summary', public._wrap_lang_leaf(transport -> 'summary'))
           else '{}'::jsonb end)
  || (case when jsonb_typeof(transport -> 'modes') = 'array'
           then jsonb_build_object('modes', (
             select coalesce(jsonb_agg(
               elem
               || (case when jsonb_typeof(elem -> 'mode') = 'string'
                        then jsonb_build_object(
                               'mode', public._wrap_lang_leaf(elem -> 'mode'))
                        else '{}'::jsonb end)
               || (case when jsonb_typeof(elem -> 'detail') = 'string'
                        then jsonb_build_object(
                               'detail', public._wrap_lang_leaf(elem -> 'detail'))
                        else '{}'::jsonb end)
               order by ord
             ), '[]'::jsonb)
             from jsonb_array_elements(transport -> 'modes')
                  with ordinality as t(elem, ord)
           ))
           else '{}'::jsonb end)
where transport is not null;

-- 7. venues.parking.{summary, notes}.
update public.venues
set parking = parking
  || (case when jsonb_typeof(parking -> 'summary') = 'string'
           then jsonb_build_object(
                  'summary', public._wrap_lang_leaf(parking -> 'summary'))
           else '{}'::jsonb end)
  || (case when jsonb_typeof(parking -> 'notes') = 'string'
           then jsonb_build_object(
                  'notes', public._wrap_lang_leaf(parking -> 'notes'))
           else '{}'::jsonb end)
where parking is not null
  and (
    jsonb_typeof(parking -> 'summary') = 'string'
    or jsonb_typeof(parking -> 'notes') = 'string'
  );

-- 8. venues.restaurants[].{name, description}.
update public.venues
set restaurants = (
  select coalesce(jsonb_agg(
    elem
    || (case when jsonb_typeof(elem -> 'name') = 'string'
             then jsonb_build_object(
                    'name', public._wrap_lang_leaf(elem -> 'name'))
             else '{}'::jsonb end)
    || (case when jsonb_typeof(elem -> 'description') = 'string'
             then jsonb_build_object(
                    'description', public._wrap_lang_leaf(elem -> 'description'))
             else '{}'::jsonb end)
    order by ord
  ), '[]'::jsonb)
  from jsonb_array_elements(restaurants)
       with ordinality as t(elem, ord)
)
where jsonb_typeof(restaurants) = 'array'
  and exists (
    select 1
    from jsonb_array_elements(restaurants) e
    where jsonb_typeof(e -> 'name') = 'string'
       or jsonb_typeof(e -> 'description') = 'string'
  );

-- 9. venues.security.summary + security.general_rules[].
update public.venues
set security = security
  || (case when jsonb_typeof(security -> 'summary') = 'string'
           then jsonb_build_object(
                  'summary', public._wrap_lang_leaf(security -> 'summary'))
           else '{}'::jsonb end)
  || (case when jsonb_typeof(security -> 'general_rules') = 'array'
           then jsonb_build_object('general_rules', (
             select coalesce(jsonb_agg(
               case
                 when jsonb_typeof(elem) = 'string'
                   then jsonb_build_object(
                          'en', elem #>> '{}', 'sv', elem #>> '{}')
                 else elem
               end
               order by ord
             ), '[]'::jsonb)
             from jsonb_array_elements(security -> 'general_rules')
                  with ordinality as t(elem, ord)
           ))
           else '{}'::jsonb end)
where security is not null
  and (
    jsonb_typeof(security -> 'summary') = 'string'
    or exists (
      select 1
      from jsonb_array_elements(coalesce(security -> 'general_rules', '[]'::jsonb)) e
      where jsonb_typeof(e) = 'string'
    )
  );

-- 10. venues.maps[].{name, description}.
update public.venues
set maps = (
  select coalesce(jsonb_agg(
    elem
    || (case when jsonb_typeof(elem -> 'name') = 'string'
             then jsonb_build_object(
                    'name', public._wrap_lang_leaf(elem -> 'name'))
             else '{}'::jsonb end)
    || (case when jsonb_typeof(elem -> 'description') = 'string'
             then jsonb_build_object(
                    'description', public._wrap_lang_leaf(elem -> 'description'))
             else '{}'::jsonb end)
    order by ord
  ), '[]'::jsonb)
  from jsonb_array_elements(maps)
       with ordinality as t(elem, ord)
)
where jsonb_typeof(maps) = 'array'
  and exists (
    select 1
    from jsonb_array_elements(maps) e
    where jsonb_typeof(e -> 'name') = 'string'
       or jsonb_typeof(e -> 'description') = 'string'
  );

drop function if exists public._wrap_lang_leaf(jsonb);
