-- MassanApp prototype seed data.
--
-- This file is the authoritative seed for the shared Supabase prototype
-- project. The frontend reads its catalog from Supabase at runtime; there
-- is no JSON fallback. `web/data/catalog.json` is a hand-maintained
-- reference copy of the shape produced by this seed and must be updated
-- in the same change whenever this file changes (see
-- docs/implementation-specification.md, "Seed data layout").
--
-- Venue facts are from public Stockholmsmassan sources (see
-- docs/research-stockholmsmassan-and-venue-apps.md). Per-event news,
-- articles, program items, and speakers below are clearly simulated
-- content scoped to this prototype. The `nordbygg-2026` exhibitor
-- block is the exception: it is scraped from the official
-- Stockholmsmassan digital-stand directory (see
-- docs/implementation-specification.md, "Seed data layout") and the
-- corresponding logo JPGs live under
-- web/assets/images/exhibitors/nordbygg-2026-*.jpg. Exhibitors for
-- other events stay simulated.
--
-- Event hero images (branding.hero_image) reference files committed at
-- web/assets/images/events/ that were downloaded from the public
-- Stockholmsmassan calendar event pages on 2026-04-18 (Nordbygg, ESTRO,
-- and EHA2026) and 2026-04-19 (the remaining calendar events, see
-- issue #14) and are used here with attribution
-- (branding.hero_image_credit). Future editions that do not yet have a
-- calendar page (e.g. skydd-2030, gymnasiemassan-2028) reuse the latest
-- scraped edition's image; their hero_image_credit notes this.
--
-- News items and articles reuse their parent event's hero image so
-- each item renders with a visually connected thumbnail. Speaker
-- avatars (speakers.avatar) and the simulated exhibitor logos for
-- non-Nordbygg events reference auto-generated initial-based SVGs
-- committed under web/assets/images/speakers/ and
-- web/assets/images/exhibitors/. The `nordbygg-2026` exhibitor logos
-- are real 200 px JPEG previews scraped alongside the catalog data;
-- exhibitors whose source page provides no logo render through the
-- frontend's `logoDataUri` initial-based SVG fallback.

begin;

insert into public.venues (
  id, name, address, transport, parking, restaurants, security, sustainability, maps
) values (
  'stockholmsmassan',
  'Stockholmsmassan',
  jsonb_build_object(
    'street', 'Massvagen 1',
    'postal_code', '125 80',
    'city', 'Alvsjo',
    'country', 'Sweden'
  ),
  jsonb_build_object(
    'summary', jsonb_build_object('en', 'Alvsjo station is adjacent to Stockholmsmassan. Commuter trains from Stockholm City take about 9 minutes. Direct travel from Arlanda Airport to Alvsjo is also available.', 'sv', 'Älvsjö station ligger intill Stockholmsmässan. Pendeltåg från Stockholm City tar cirka 9 minuter. Det går också direkttåg från Arlanda flygplats till Älvsjö.'),
    'modes', jsonb_build_array(
      jsonb_build_object('mode', jsonb_build_object('en', 'Commuter train', 'sv', 'Pendeltåg'), 'detail', jsonb_build_object('en', 'SL pendeltag from Stockholm City stops directly at Alvsjo station in about 9 minutes.', 'sv', 'SL:s pendeltåg från Stockholm City stannar direkt vid Älvsjö station efter cirka 9 minuter.')),
      jsonb_build_object('mode', jsonb_build_object('en', 'From Arlanda Airport', 'sv', 'Från Arlanda flygplats'), 'detail', jsonb_build_object('en', 'Direct services from Arlanda to Alvsjo are available without changing in central Stockholm.', 'sv', 'Det går direkttrafik från Arlanda till Älvsjö utan byte i centrala Stockholm.')),
      jsonb_build_object('mode', jsonb_build_object('en', 'Bus', 'sv', 'Buss'), 'detail', jsonb_build_object('en', 'Several SL bus lines stop at Alvsjo stationsplan, which is a short walk from the main entrance.', 'sv', 'Flera av SL:s busslinjer stannar vid Älvsjö stationsplan, som ligger en kort promenad från huvudentrén.')),
      jsonb_build_object('mode', jsonb_build_object('en', 'Bike', 'sv', 'Cykel'), 'detail', jsonb_build_object('en', 'Marked cycle paths connect Alvsjo to central Stockholm. Covered bike parking is available near the main entrance.', 'sv', 'Markerade cykelvägar förbinder Älvsjö med centrala Stockholm. Det finns övertäckt cykelparkering nära huvudentrén.'))
    )
  ),
  jsonb_build_object(
    'summary', jsonb_build_object('en', 'About 2,000 parking spaces on site, additional nearby overflow parking, and EV charging.', 'sv', 'Cirka 2 000 parkeringsplatser på området, ytterligare avlastningsparkering i närheten samt laddning för elbilar.'),
    'onsite_spaces', 2000,
    'ev_charging', true,
    'notes', jsonb_build_object('en', 'Parking is paid and fills quickly during large trade fairs and congresses. Pre-booking is recommended for events with heavy visitor volumes.', 'sv', 'Parkering är avgiftsbelagd och fylls snabbt vid stora mässor och kongresser. Förbokning rekommenderas vid evenemang med många besökare.')
  ),
  jsonb_build_array(
    jsonb_build_object('name', jsonb_build_object('en', 'Restaurant Rattvik', 'sv', 'Restaurant Rattvik'), 'description', jsonb_build_object('en', 'Full-service on-site restaurant serving lunch during events.', 'sv', 'Fullservicerestaurang på området som serverar lunch under evenemangen.')),
    jsonb_build_object('name', jsonb_build_object('en', 'Cafe Kista', 'sv', 'Cafe Kista'), 'description', jsonb_build_object('en', 'Coffee, pastries, and quick lunch options near the main foyer.', 'sv', 'Kaffe, bakverk och snabba lunchalternativ nära huvudfoajén.')),
    jsonb_build_object('name', jsonb_build_object('en', 'Bistro Nordic', 'sv', 'Bistro Nordic'), 'description', jsonb_build_object('en', 'Seasonal a-la-carte menu oriented to business lunches and congress delegates.', 'sv', 'Säsongsbaserad à la carte-meny inriktad på affärsluncher och kongressdelegater.')),
    jsonb_build_object('name', jsonb_build_object('en', 'Hall Cafeteria East', 'sv', 'Hallkafeteria öster'), 'description', jsonb_build_object('en', 'Buffet-style cafeteria close to the East Halls for peak-lunch throughput.', 'sv', 'Buffékafeteria intill östra hallarna för hög genomströmning under lunchtoppen.')),
    jsonb_build_object('name', jsonb_build_object('en', 'Hall Cafeteria West', 'sv', 'Hallkafeteria väster'), 'description', jsonb_build_object('en', 'Buffet-style cafeteria close to the West Halls.', 'sv', 'Buffékafeteria intill västra hallarna.')),
    jsonb_build_object('name', jsonb_build_object('en', 'Espresso Bar Foyer', 'sv', 'Espressobar i foajén'), 'description', jsonb_build_object('en', 'Quick espresso and grab-and-go snacks inside the main foyer.', 'sv', 'Snabb espresso och tilltugg att ta med inne i huvudfoajén.'))
  ),
  jsonb_build_object(
    'summary', jsonb_build_object('en', 'Stockholmsmassan is the first exhibition venue in Sweden certified to the SHORE safety standard. Bag checks, access control, and event-specific entry procedures are in place.', 'sv', 'Stockholmsmässan är den första utställningsanläggningen i Sverige som certifierats enligt säkerhetsstandarden SHORE. Väskkontroller, tillträdeskontroll och evenemangsspecifika entrérutiner finns på plats.'),
    'general_rules', jsonb_build_array(
      jsonb_build_object('en', 'Bags are subject to visual inspection at entry.', 'sv', 'Väskor kan komma att kontrolleras visuellt vid entrén.'),
      jsonb_build_object('en', 'Oversize luggage should be left at the cloakroom or returned to a hotel.', 'sv', 'Skrymmande bagage ska lämnas i garderoben eller återföras till hotellet.'),
      jsonb_build_object('en', 'Follow staff and signage regarding special entrances for specific events.', 'sv', 'Följ personal och skyltning om särskilda entréer för enskilda evenemang.'),
      jsonb_build_object('en', 'Report anything suspicious to on-site security; emergency exits are marked throughout the venue.', 'sv', 'Anmäl misstänkta händelser till väktarna på plats; nödutgångar är markerade i hela anläggningen.')
    )
  ),
  jsonb_build_object('en', 'Stockholmsmassan is ISO 20121 certified and runs an active sustainability program spanning energy, waste, catering, and supplier choices.', 'sv', 'Stockholmsmässan är certifierad enligt ISO 20121 och driver ett aktivt hållbarhetsprogram som omfattar energi, avfall, mat och leverantörsval.'),
  jsonb_build_array(
    jsonb_build_object(
      'id', 'stockholmsmassan-overview',
      'name', jsonb_build_object('en', 'Venue overview', 'sv', 'Översiktskarta'),
      'description', jsonb_build_object('en', 'High-level map of entrances, halls, foyers, and conference rooms. The prototype lists available maps without rendering them.', 'sv', 'Översiktskarta över entréer, hallar, foajéer och konferensrum. Prototypen listar tillgängliga kartor utan att rendera dem.')
    )
  )
)
on conflict (id) do update set
  name = excluded.name,
  address = excluded.address,
  transport = excluded.transport,
  parking = excluded.parking,
  restaurants = excluded.restaurants,
  security = excluded.security,
  sustainability = excluded.sustainability,
  maps = excluded.maps;

insert into public.events (
  id, venue_id, name, subtitle, type, category, audience_rule, ticket_model,
  start_date, end_date, summary, branding, overrides, questionnaire_subjects
) values
  (
    'nordbygg-2026', 'stockholmsmassan', jsonb_build_object('en', 'Nordbygg 2026', 'sv', 'Nordbygg 2026'), jsonb_build_object('en', 'Nordic construction trade fair', 'sv', 'Nordisk byggmässa'),
    'Trade fair', 'Construction and real estate', 'public', 'public_ticket',
    date '2026-04-21', date '2026-04-24',
    jsonb_build_object('en', 'Nordbygg is the leading Nordic meeting place for the construction and real-estate industry, with exhibitors, seminars, and industry news across four days at Stockholmsmassan.', 'sv', 'Nordbygg är den ledande nordiska mötesplatsen för bygg- och fastighetsbranschen, med utställare, seminarier och branschnyheter under fyra dagar på Stockholmsmässan.'),
    jsonb_build_object(
      'primary_color', '#0b3d91', 'accent_color', '#f4b400', 'logo', null,
      'hero_image', 'assets/images/events/nordbygg-2026.jpg',
      'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')
    ),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Enter through the main foyer at Stockholmsmassan. Nordbygg signage guides visitors to registration in the A-Hall foyer.', 'sv', 'Gå in genom huvudfoajén på Stockholmsmässan. Nordbyggs skyltning vägleder besökare till registreringen i A-hallens foajé.'),
      'bag_rules', jsonb_build_object('en', 'Work bags and smaller backpacks are allowed on the fair floor; oversize luggage should be checked at the cloakroom.', 'sv', 'Arbetsväskor och mindre ryggsäckar är tillåtna på mässgolvet; skrymmande bagage ska lämnas i garderoben.'),
      'access_notes', jsonb_build_object('en', 'A visitor ticket grants access to all exhibition halls and seminar rooms. Some seminars have limited seating on a first-come basis.', 'sv', 'En besöksbiljett ger tillträde till alla utställningshallar och seminarierum. Vissa seminarier har begränsat antal platser enligt först-till-kvarn-principen.')
    ),
    jsonb_build_array(
      jsonb_build_object('en', 'Sustainable construction', 'sv', 'Hållbart byggande'),
      jsonb_build_object('en', 'BIM and digital tools', 'sv', 'BIM och digitala verktyg'),
      jsonb_build_object('en', 'Renovation', 'sv', 'Renovering'),
      jsonb_build_object('en', 'Heating and ventilation', 'sv', 'Värme och ventilation'),
      jsonb_build_object('en', 'Smart buildings', 'sv', 'Smarta byggnader'),
      jsonb_build_object('en', 'Building safety', 'sv', 'Byggsäkerhet')
    )
  ),
  (
    'estro-2026', 'stockholmsmassan', jsonb_build_object('en', 'ESTRO 2026', 'sv', 'ESTRO 2026'), jsonb_build_object('en', 'European Society for Radiotherapy and Oncology Annual Congress', 'sv', 'Europeiska sällskapet för strålbehandling och onkologi – årlig kongress'),
    'Congress', 'Health & Medicine', 'professional', 'registration',
    date '2026-05-15', date '2026-05-19',
    jsonb_build_object('en', 'ESTRO 2026 is the European Society for Radiotherapy and Oncology annual congress, covering clinical practice, physics, radiobiology, and technology across a multi-track program.', 'sv', 'ESTRO 2026 är den årliga kongressen för europeiska sällskapet för strålbehandling och onkologi och täcker klinisk praktik, fysik, strålningsbiologi och teknik i ett program med flera spår.'),
    jsonb_build_object(
      'primary_color', '#123f66', 'accent_color', '#ce3f4a', 'logo', null,
      'hero_image', 'assets/images/events/estro-2026.webp',
      'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')
    ),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Registration and badge pickup for ESTRO 2026 are located in the North Foyer. Delegates should bring photo ID on the first day.', 'sv', 'Registrering och utlämning av kongressbrickor för ESTRO 2026 finns i norra foajén. Delegater ska ta med fotolegitimation den första dagen.'),
      'bag_rules', jsonb_build_object('en', 'Standard venue bag rules apply; congress materials are distributed at the registration desk.', 'sv', 'Anläggningens vanliga väskregler gäller; kongressmaterial delas ut i receptionen.'),
      'access_notes', jsonb_build_object('en', 'Access is restricted to registered delegates, exhibitors, and accredited media. Sessions marked as closed require additional access codes.', 'sv', 'Tillträde är begränsat till registrerade delegater, utställare och ackrediterad press. Sessioner märkta som stängda kräver ytterligare åtkomstkoder.')
    ),
    jsonb_build_array(
      jsonb_build_object('en', 'Clinical radiation oncology', 'sv', 'Klinisk strålonkologi'),
      jsonb_build_object('en', 'Medical physics', 'sv', 'Medicinsk fysik'),
      jsonb_build_object('en', 'Radiobiology', 'sv', 'Strålningsbiologi'),
      jsonb_build_object('en', 'Brachytherapy', 'sv', 'Brakyterapi'),
      jsonb_build_object('en', 'Imaging and treatment planning', 'sv', 'Bildgivning och behandlingsplanering'),
      jsonb_build_object('en', 'Technology and innovation', 'sv', 'Teknik och innovation')
    )
  ),
  (
    'eha-2026', 'stockholmsmassan', jsonb_build_object('en', 'EHA2026 Congress', 'sv', 'EHA2026-kongressen'), jsonb_build_object('en', 'European Hematology Association Annual Congress', 'sv', 'Europeiska hematologföreningens årliga kongress'),
    'Congress', 'Health & Medicine', 'professional', 'registration',
    date '2026-06-11', date '2026-06-14',
    jsonb_build_object('en', 'The European Hematology Association annual congress brings clinicians and researchers together for plenaries, symposia, abstract presentations, and an industry exhibition.', 'sv', 'Europeiska hematologföreningens årliga kongress samlar kliniker och forskare för plenarsessioner, symposier, abstraktpresentationer och en branschutställning.'),
    jsonb_build_object(
      'primary_color', '#8a1f57', 'accent_color', '#f5b233', 'logo', null,
      'hero_image', 'assets/images/events/eha-2026.jpg',
      'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')
    ),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'EHA2026 delegates enter through the East Foyer. Congress badges are required for all sessions.', 'sv', 'Delegater på EHA2026 går in genom östra foajén. Kongressbrickor krävs för alla sessioner.'),
      'bag_rules', jsonb_build_object('en', 'Standard venue bag rules apply. Poster tubes and rollable cases are accommodated at the cloakroom.', 'sv', 'Anläggningens vanliga väskregler gäller. Posterrör och rullbara väskor kan lämnas i garderoben.'),
      'access_notes', jsonb_build_object('en', 'On-demand session recordings are available to registered delegates on the EHA congress platform after the congress.', 'sv', 'Inspelningar av sessioner finns tillgängliga på begäran för registrerade delegater på EHA:s kongressplattform efter kongressen.')
    ),
    null
  )
on conflict (id) do update set
  venue_id = excluded.venue_id,
  name = excluded.name,
  subtitle = excluded.subtitle,
  type = excluded.type,
  category = excluded.category,
  audience_rule = excluded.audience_rule,
  ticket_model = excluded.ticket_model,
  start_date = excluded.start_date,
  end_date = excluded.end_date,
  summary = excluded.summary,
  branding = excluded.branding,
  overrides = excluded.overrides,
  questionnaire_subjects = excluded.questionnaire_subjects;

-- Additional upcoming events from the Stockholmsmassan public calendar
-- (https://stockholmsmassan.se/en/calendar/, scraped 2026-04-18 per
-- issue #9). Event names, dates, types, and categories come from that
-- public listing. Subtitles, summaries, branding colors, and `overrides`
-- copy are simulated prototype content. These events do not carry
-- per-event news, articles, program items, or exhibitors; they exist so
-- the calendar view shows the full upcoming schedule rather than a
-- small subset.
insert into public.events (
  id, venue_id, name, subtitle, type, category, audience_rule, ticket_model,
  start_date, end_date, summary, branding, overrides
) values
  (
    'yrkes-sm-2026', 'stockholmsmassan', jsonb_build_object('en', 'Yrkes-SM 2026', 'sv', 'Yrkes-SM 2026'),
    jsonb_build_object('en', 'Swedish national championship for vocational skills', 'sv', 'Svenskt mästerskap i yrkesskicklighet'),
    'Event', 'Education and training', 'public', 'none',
    date '2026-05-04', date '2026-05-06',
    jsonb_build_object('en', 'Yrkes-SM is the Swedish national championship for vocational skills. The 2026 edition is hosted at Stockholmsmassan for the first time, with young professionals competing across trades and visitors exploring career paths.', 'sv', 'Yrkes-SM är det svenska mästerskapet i yrkesskicklighet. 2026 års upplaga arrangeras för första gången på Stockholmsmässan, där unga yrkesutövare tävlar i olika yrken och besökare utforskar karriärvägar.'),
    jsonb_build_object('primary_color', '#00549a', 'accent_color', '#ffc72c', 'logo', null, 'hero_image', 'assets/images/events/yrkes-sm-2026.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Visitors enter through the main foyer, where the organizer operates information and registration desks.', 'sv', 'Simulerad. Besökare går in genom huvudfoajén, där arrangören har informations- och registreringsdiskar.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Admission is free for visitors. Competitor and jury access is managed by the organizer.', 'sv', 'Simulerad. Inträdet är fritt för besökare. Tillträde för tävlande och jury sköts av arrangören.')
    )
  ),
  (
    'ung-foretagsamhet-2026', 'stockholmsmassan', jsonb_build_object('en', 'Ung Foretagsamhet 2026', 'sv', 'Ung Foretagsamhet 2026'),
    jsonb_build_object('en', 'Annual meeting for young entrepreneurs, schools, and policymakers', 'sv', 'Årlig samling för unga entreprenörer, skolor och beslutsfattare'),
    'Event', 'Education and training', 'public', 'registration',
    date '2026-05-26', date '2026-05-27',
    jsonb_build_object('en', 'Ung Foretagsamhet brings together young entrepreneurs, schools, and policymakers to celebrate student-run companies and exchange ideas across Sweden.', 'sv', 'Ung Företagsamhet samlar unga entreprenörer, skolor och beslutsfattare för att uppmärksamma elevdrivna företag och utbyta idéer från hela Sverige.'),
    jsonb_build_object('primary_color', '#f26522', 'accent_color', '#003a5d', 'logo', null, 'hero_image', 'assets/images/events/ung-foretagsamhet-2026.webp', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Participants and school groups enter via the East Foyer following event signage.', 'sv', 'Simulerad. Deltagare och skolgrupper går in via östra foajén enligt evenemangets skyltning.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Admission is managed through organizer registration for school groups and UF members.', 'sv', 'Simulerad. Inträde hanteras via arrangörens registrering för skolgrupper och UF-medlemmar.')
    )
  ),
  (
    'samhallsbyggararenan-2026', 'stockholmsmassan', jsonb_build_object('en', 'Samhallsbyggararenan 2026', 'sv', 'Samhallsbyggararenan 2026'),
    jsonb_build_object('en', 'Community builders meeting on Swedish urban development', 'sv', 'Samhällsbyggarmöte om svensk stadsutveckling'),
    'Event', 'Other', 'professional', 'registration',
    date '2026-06-23', date '2026-06-25',
    jsonb_build_object('en', 'Samhallsbyggararenan brings together public and private actors in Swedish urban development to discuss housing, infrastructure, and climate-adaptation challenges.', 'sv', 'Samhällsbyggararenan samlar offentliga och privata aktörer inom svensk stadsutveckling för att diskutera bostäder, infrastruktur och klimatanpassning.'),
    jsonb_build_object('primary_color', '#004e42', 'accent_color', '#c2d57e', 'logo', null, 'hero_image', 'assets/images/events/samhallsbyggararenan-2026.webp', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Delegates enter via the North Foyer. Badge pickup opens one hour before the first session each day.', 'sv', 'Simulerad. Delegater går in via norra foajén. Utlämning av kongressbrickor öppnar en timme före dagens första session.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is limited to registered delegates.', 'sv', 'Simulerad. Tillträde är begränsat till registrerade delegater.')
    )
  ),
  (
    'formex-aug-2026', 'stockholmsmassan', jsonb_build_object('en', 'Formex August 2026', 'sv', 'Formex augusti 2026'),
    jsonb_build_object('en', 'Nordic interior design trade fair, autumn edition', 'sv', 'Nordisk inredningsmässa, höstupplaga'),
    'Trade fair', 'Interior design', 'professional', 'registration',
    date '2026-08-25', date '2026-08-27',
    jsonb_build_object('en', 'Formex is the leading Nordic trade fair for interior design, gift items, and lifestyle brands. The August edition focuses on the autumn-winter season.', 'sv', 'Formex är den ledande nordiska mässan för inredning, present­artiklar och livsstilsvarumärken. Augustiupplagan fokuserar på höst- och vintersäsongen.'),
    jsonb_build_object('primary_color', '#2b2c2d', 'accent_color', '#d4af37', 'logo', null, 'hero_image', 'assets/images/events/formex-aug-2026.webp', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Trade visitors enter through the main foyer. Trade badges are required for access.', 'sv', 'Simulerad. Fackbesökare går in genom huvudfoajén. Fackbricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Work bags are allowed; oversize items should be checked at the cloakroom.', 'sv', 'Simulerad. Arbetsväskor är tillåtna; skrymmande föremål ska lämnas i garderoben.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  ),
  (
    'european-dog-show-2026', 'stockholmsmassan', jsonb_build_object('en', 'European Dog Show and Swedish Winner Show 2026', 'sv', 'European Dog Show och Swedish Winner Show 2026'),
    jsonb_build_object('en', 'International canine exhibition and Swedish Winner show', 'sv', 'Internationell hundutställning och Svenska Vinnaren-utställning'),
    'Public fair', 'Entertainment', 'public', 'public_ticket',
    date '2026-09-04', date '2026-09-06',
    jsonb_build_object('en', 'A multi-day international dog show drawing tens of thousands of dog enthusiasts and their dogs, with breed competitions, handling, and family-friendly programming.', 'sv', 'En flera dagar lång internationell hundutställning som lockar tiotusentals hundentusiaster och deras hundar, med rasbedömningar, handling och familjevänligt program.'),
    jsonb_build_object('primary_color', '#5c2a2a', 'accent_color', '#d3c29c', 'logo', null, 'hero_image', 'assets/images/events/european-dog-show-2026.webp', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Dog-show participants use the dedicated South Entrance for dogs and handlers. Visitors enter through the Main Foyer.', 'sv', 'Simulerad. Hundutställningens deltagare använder den särskilda södra entrén för hundar och förare. Besökare går in genom huvudfoajén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Pet carriers are allowed in the show halls. Oversize luggage should be checked at the cloakroom.', 'sv', 'Simulerad. Djurburar är tillåtna i utställningshallarna. Skrymmande bagage ska lämnas i garderoben.'),
      'access_notes', jsonb_build_object('en', 'Simulated. A visitor ticket grants access to the show halls; handler and participant access is managed by the organizer.', 'sv', 'Simulerad. En besöksbiljett ger tillträde till utställningshallarna; tillträde för förare och deltagare sköts av arrangören.')
    )
  ),
  (
    'european-congress-of-pathology-2026', 'stockholmsmassan', jsonb_build_object('en', '38th European Congress of Pathology 2026', 'sv', '38:e europeiska patologikongressen 2026'),
    jsonb_build_object('en', 'European Society of Pathology annual congress', 'sv', 'Europeiska patologföreningens årliga kongress'),
    'Congress', 'Health & Medicine', 'professional', 'registration',
    date '2026-09-12', date '2026-09-16',
    jsonb_build_object('en', 'The European Congress of Pathology is the leading European gathering for pathologists, bringing together clinicians and researchers for a multi-track scientific program and industry exhibition.', 'sv', 'Europeiska patologikongressen är den ledande europeiska samlingen för patologer och samlar kliniker och forskare kring ett vetenskapligt program med flera spår samt en branschutställning.'),
    jsonb_build_object('primary_color', '#1c4d8f', 'accent_color', '#9d2235', 'logo', null, 'hero_image', 'assets/images/events/european-congress-of-pathology-2026.png', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Delegates enter via the East Foyer. Congress badges and photo ID are required at the door.', 'sv', 'Simulerad. Delegater går in via östra foajén. Kongressbricka och fotolegitimation krävs vid entrén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply; poster tubes are accommodated at the cloakroom.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller; posterrör kan lämnas i garderoben.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to registered delegates, exhibitors, and accredited media.', 'sv', 'Simulerad. Tillträde är begränsat till registrerade delegater, utställare och ackrediterad press.')
    )
  ),
  (
    'sweden-water-expo-2026', 'stockholmsmassan', jsonb_build_object('en', 'Sweden Water Expo 2026', 'sv', 'Sweden Water Expo 2026'),
    jsonb_build_object('en', 'Water infrastructure and sustainability trade fair', 'sv', 'Mässa för vatteninfrastruktur och hållbarhet'),
    'Trade fair', 'Industry', 'professional', 'registration',
    date '2026-09-16', date '2026-09-17',
    jsonb_build_object('en', 'Sweden Water Expo gathers the water, wastewater, and stormwater sector around infrastructure, sustainability, and digital solutions for the Swedish market.', 'sv', 'Sweden Water Expo samlar branschen för vatten, avlopp och dagvatten kring infrastruktur, hållbarhet och digitala lösningar på den svenska marknaden.'),
    jsonb_build_object('primary_color', '#006eb6', 'accent_color', '#5fc4ef', 'logo', null, 'hero_image', 'assets/images/events/sweden-water-expo-2026.webp', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Visitors enter through the main foyer. Trade badges are required for access.', 'sv', 'Simulerad. Besökare går in genom huvudfoajén. Fackbricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  ),
  (
    'llb-expo-2026', 'stockholmsmassan', jsonb_build_object('en', 'LLB Expo 2026', 'sv', 'LLB Expo 2026'),
    jsonb_build_object('en', 'Logistics and material handling trade fair', 'sv', 'Mässa för logistik och materialhantering'),
    'Trade fair', 'Industry', 'professional', 'registration',
    date '2026-10-06', date '2026-10-08',
    jsonb_build_object('en', 'LLB Expo is an industry gathering for logistics, warehousing, and material handling with exhibitor demonstrations, networking, and seminars.', 'sv', 'LLB Expo är en branschsamling för logistik, lagerhållning och materialhantering med utställardemonstrationer, mingel och seminarier.'),
    jsonb_build_object('primary_color', '#f58220', 'accent_color', '#0a4a80', 'logo', null, 'hero_image', 'assets/images/events/llb-expo-2026.webp', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Visitors enter through the main foyer. Trade badges are required for access.', 'sv', 'Simulerad. Besökare går in genom huvudfoajén. Fackbricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  ),
  (
    'hem-villamassan-2026', 'stockholmsmassan', jsonb_build_object('en', 'Hem & Villamassan 2026', 'sv', 'Hem & Villamassan 2026'),
    jsonb_build_object('en', 'Consumer fair for home renovation and villa ownership', 'sv', 'Konsumentmässa för renovering och villaägande'),
    'Public fair', 'Leisure and consumer', 'public', 'public_ticket',
    date '2026-10-09', date '2026-10-11',
    jsonb_build_object('en', 'Hem & Villamassan is a consumer fair covering home renovation, villa maintenance, and interior inspiration, combining exhibitors, lectures, and practical demonstrations.', 'sv', 'Hem & Villamässan är en konsumentmässa som täcker bostadsrenovering, villaunderhåll och inredningsinspiration, med utställare, föreläsningar och praktiska demonstrationer.'),
    jsonb_build_object('primary_color', '#6bae3e', 'accent_color', '#44494e', 'logo', null, 'hero_image', 'assets/images/events/hem-villamassan-2026.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Visitors enter through the main foyer.', 'sv', 'Simulerad. Besökare går in genom huvudfoajén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Work bags and small backpacks are allowed. Oversize items should be checked at the cloakroom.', 'sv', 'Simulerad. Arbetsväskor och små ryggsäckar är tillåtna. Skrymmande föremål ska lämnas i garderoben.'),
      'access_notes', jsonb_build_object('en', 'Simulated. A visitor ticket grants access to all halls in the fair.', 'sv', 'Simulerad. En besöksbiljett ger tillträde till alla mässans hallar.')
    )
  ),
  (
    'tradgardsmassan-host-2026', 'stockholmsmassan', jsonb_build_object('en', 'Tradgardsmassan Host 2026', 'sv', 'Trädgårdsmässan Höst 2026'),
    jsonb_build_object('en', 'Autumn edition of the Swedish gardening fair', 'sv', 'Höstupplaga av den svenska trädgårdsmässan'),
    'Public fair', 'Leisure and consumer', 'public', 'public_ticket',
    date '2026-10-09', date '2026-10-11',
    jsonb_build_object('en', 'Tradgardsmassan Host is the autumn edition of the Swedish gardening fair, with exhibitors, talks, and demonstrations covering year-round gardening themes.', 'sv', 'Trädgårdsmässan Höst är höstupplagan av den svenska trädgårdsmässan, med utställare, föredrag och demonstrationer kring trädgårdsteman året om.'),
    jsonb_build_object('primary_color', '#b35b1c', 'accent_color', '#7e9b2c', 'logo', null, 'hero_image', 'assets/images/events/tradgardsmassan-host-2026.png', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Visitors enter through the main foyer.', 'sv', 'Simulerad. Besökare går in genom huvudfoajén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Gardening equipment and plants bought on site are allowed on the fair floor.', 'sv', 'Simulerad. Trädgårdsutrustning och växter som köps på plats är tillåtna på mässgolvet.'),
      'access_notes', jsonb_build_object('en', 'Simulated. A visitor ticket grants access to all halls in the fair.', 'sv', 'Simulerad. En besöksbiljett ger tillträde till alla mässans hallar.')
    )
  ),
  (
    'ecarexpo-2026', 'stockholmsmassan', jsonb_build_object('en', 'eCarExpo 2026', 'sv', 'eCarExpo 2026'),
    jsonb_build_object('en', 'Nordic electric car and charging trade fair', 'sv', 'Nordisk mässa för elbilar och laddning'),
    'Trade fair', 'Industry', 'public', 'public_ticket',
    date '2026-10-09', date '2026-10-11',
    jsonb_build_object('en', 'eCarExpo is the leading Nordic event for electric cars and charging, combining consumer demonstrations and industry exhibitions across car brands, charging operators, and accessories.', 'sv', 'eCarExpo är det ledande nordiska eventet för elbilar och laddning och kombinerar konsumentdemonstrationer och branschutställningar med bilmärken, laddoperatörer och tillbehör.'),
    jsonb_build_object('primary_color', '#00a651', 'accent_color', '#1b365d', 'logo', null, 'hero_image', 'assets/images/events/ecarexpo-2026.webp', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Visitors enter through the main foyer. Test-drive check-in is handled at a dedicated desk in the foyer.', 'sv', 'Simulerad. Besökare går in genom huvudfoajén. Incheckning för provkörning sker vid en särskild disk i foajén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. A visitor ticket grants access to all halls; trade-only sessions are badge-controlled.', 'sv', 'Simulerad. En besöksbiljett ger tillträde till alla hallar; rena fackbesökarsessioner är brickkontrollerade.')
    )
  ),
  (
    'underbara-children-2026', 'stockholmsmassan', jsonb_build_object('en', 'UnderBARA CHILDREN 2026', 'sv', 'UnderBARA CHILDREN 2026'),
    jsonb_build_object('en', 'Family entertainment fair for kids and families', 'sv', 'Familjemässa med underhållning för barn och familjer'),
    'Public fair', 'Entertainment', 'public', 'public_ticket',
    date '2026-10-16', date '2026-10-18',
    jsonb_build_object('en', 'UnderBARA CHILDREN is a large family-and-kids fair with entertainment, activities, exhibitors, and shows for Swedish families.', 'sv', 'UnderBARA CHILDREN är en stor familje- och barnmässa med underhållning, aktiviteter, utställare och föreställningar för svenska familjer.'),
    jsonb_build_object('primary_color', '#e6007e', 'accent_color', '#ffe600', 'logo', null, 'hero_image', 'assets/images/events/underbara-children-2026.webp', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Families enter through the main foyer. Strollers are welcome on the fair floor.', 'sv', 'Simulerad. Familjer går in genom huvudfoajén. Barnvagnar är välkomna på mässgolvet.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply. Strollers are allowed.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller. Barnvagnar är tillåtna.'),
      'access_notes', jsonb_build_object('en', 'Simulated. A visitor ticket grants access to all halls; some activities have on-site queuing.', 'sv', 'Simulerad. En besöksbiljett ger tillträde till alla hallar; vissa aktiviteter har köhantering på plats.')
    )
  ),
  (
    'skydd-2026', 'stockholmsmassan', jsonb_build_object('en', 'Skydd 2026', 'sv', 'Skydd 2026'),
    jsonb_build_object('en', 'Nordic security, fire-safety, and protection trade fair', 'sv', 'Nordisk mässa för säkerhet, brandskydd och skyddstjänster'),
    'Trade fair', 'Industry', 'professional', 'registration',
    date '2026-10-20', date '2026-10-22',
    jsonb_build_object('en', 'Skydd is the Nordic meeting place for security, fire-safety, and civil-protection professionals, with exhibitors, demonstrations, and a conference program.', 'sv', 'Skydd är den nordiska mötesplatsen för yrkesverksamma inom säkerhet, brandskydd och civil beredskap, med utställare, demonstrationer och ett konferensprogram.'),
    jsonb_build_object('primary_color', '#c41e3a', 'accent_color', '#1a2e44', 'logo', null, 'hero_image', 'assets/images/events/skydd-2026.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Trade visitors enter via the East Foyer. Badges are required for access.', 'sv', 'Simulerad. Fackbesökare går in via östra foajén. Bricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  ),
  (
    'totalforsvarsmassan-2026', 'stockholmsmassan', jsonb_build_object('en', 'Totalforsvarsmassan 2026', 'sv', 'Totalforsvarsmassan 2026'),
    jsonb_build_object('en', 'Swedish total-defense industry fair, co-located with Skydd', 'sv', 'Svensk totalförsvarsmässa, samlokaliserad med Skydd'),
    'Trade fair', 'Industry', 'professional', 'registration',
    date '2026-10-20', date '2026-10-22',
    jsonb_build_object('en', 'Totalforsvarsmassan is the Swedish total-defense industry fair and runs alongside Skydd, covering civil protection, defense, and emergency preparedness.', 'sv', 'Totalförsvarsmässan är den svenska totalförsvarsmässan och arrangeras tillsammans med Skydd. Den täcker civil beredskap, försvar och krisberedskap.'),
    jsonb_build_object('primary_color', '#4e5c32', 'accent_color', '#b39956', 'logo', null, 'hero_image', 'assets/images/events/totalforsvarsmassan-2026.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Trade visitors enter via the East Foyer. Badges are required for access.', 'sv', 'Simulerad. Fackbesökare går in via östra foajén. Bricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  ),
  (
    'persontrafik-2026', 'stockholmsmassan', jsonb_build_object('en', 'Persontrafik 2026', 'sv', 'Persontrafik 2026'),
    jsonb_build_object('en', 'European meeting place for public transport', 'sv', 'Europeisk mötesplats för kollektivtrafik'),
    'Trade fair', 'Industry', 'professional', 'registration',
    date '2026-10-20', date '2026-10-22',
    jsonb_build_object('en', 'Persontrafik is one of Europes most important meeting places for public transport, with exhibitors, a conference program, and networking for operators, authorities, and suppliers.', 'sv', 'Persontrafik är en av Europas viktigaste mötesplatser för kollektivtrafik, med utställare, ett konferensprogram och mingel för operatörer, myndigheter och leverantörer.'),
    jsonb_build_object('primary_color', '#0073cf', 'accent_color', '#ffd100', 'logo', null, 'hero_image', 'assets/images/events/persontrafik-2026.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Delegates and trade visitors enter via the West Foyer.', 'sv', 'Simulerad. Delegater och fackbesökare går in via västra foajén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to registered trade visitors and delegates.', 'sv', 'Simulerad. Tillträde är begränsat till registrerade fackbesökare och delegater.')
    )
  ),
  (
    'larkraft-2026', 'stockholmsmassan', jsonb_build_object('en', 'Larkraft 2026', 'sv', 'Larkraft 2026'),
    jsonb_build_object('en', 'Teacher professional-development conference', 'sv', 'Konferens för lärares kompetensutveckling'),
    'Conference', 'Education and training', 'professional', 'registration',
    date '2026-10-27', date '2026-10-27',
    jsonb_build_object('en', 'Larkraft is a one-day professional-development conference for teachers and school leaders in Sweden, focused on classroom practice and educational policy.', 'sv', 'Lärkraft är en endagskonferens för kompetensutveckling för lärare och skolledare i Sverige, med fokus på klassrumsarbete och utbildningspolitik.'),
    jsonb_build_object('primary_color', '#4a5d7e', 'accent_color', '#e8a33d', 'logo', null, 'hero_image', 'assets/images/events/larkraft-2026.webp', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Delegates enter through the main foyer.', 'sv', 'Simulerad. Delegater går in genom huvudfoajén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to registered delegates.', 'sv', 'Simulerad. Tillträde är begränsat till registrerade delegater.')
    )
  ),
  (
    'comic-con-stockholm-winter-2026', 'stockholmsmassan', jsonb_build_object('en', 'Comic Con Stockholm Winter 2026', 'sv', 'Comic Con Stockholm Vinter 2026'),
    jsonb_build_object('en', 'Sweden''s largest popular culture meeting place', 'sv', 'Sveriges största mötesplats för populärkultur'),
    'Event', 'Entertainment', 'public', 'public_ticket',
    date '2026-10-30', date '2026-11-01',
    jsonb_build_object('en', 'Comic Con Stockholm Winter gathers fans of popular culture, gaming, anime, and comics for signings, panels, cosplay events, and an exhibitor floor.', 'sv', 'Comic Con Stockholm Vinter samlar fans av populärkultur, spel, anime och serier för signeringar, paneler, cosplay-arrangemang och en utställargolv.'),
    jsonb_build_object('primary_color', '#231f20', 'accent_color', '#f8b614', 'logo', null, 'hero_image', 'assets/images/events/comic-con-stockholm-winter-2026.webp', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Visitors enter through the main foyer. Cosplay check-in and prop check are handled near the entrance.', 'sv', 'Simulerad. Besökare går in genom huvudfoajén. Cosplayincheckning och propkontroll sker nära entrén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Prop weapons are subject to the organizers prop policy; sharp or real weapons are not allowed.', 'sv', 'Simulerad. Propvapen omfattas av arrangörens proppolicy; vassa eller riktiga vapen är inte tillåtna.'),
      'access_notes', jsonb_build_object('en', 'Simulated. A visitor ticket grants access to all halls; some panels and signings have separate queues or additional tickets.', 'sv', 'Simulerad. En besöksbiljett ger tillträde till alla hallar; vissa paneler och signeringar har egna köer eller kräver extra biljetter.')
    )
  ),
  (
    'allt-for-halsan-2026', 'stockholmsmassan', jsonb_build_object('en', 'Allt for Halsan 2026', 'sv', 'Allt for Halsan 2026'),
    jsonb_build_object('en', 'Consumer fair for health and wellness', 'sv', 'Konsumentmässa för hälsa och välmående'),
    'Public fair', 'Health & Medicine', 'public', 'public_ticket',
    date '2026-11-06', date '2026-11-08',
    jsonb_build_object('en', 'Allt for Halsan is a consumer fair for health, wellness, and lifestyle, with exhibitors, product demonstrations, lectures, and activities.', 'sv', 'Allt för Hälsan är en konsumentmässa för hälsa, välmående och livsstil, med utställare, produktdemonstrationer, föreläsningar och aktiviteter.'),
    jsonb_build_object('primary_color', '#7db249', 'accent_color', '#f58220', 'logo', null, 'hero_image', 'assets/images/events/allt-for-halsan-2026.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Visitors enter through the main foyer.', 'sv', 'Simulerad. Besökare går in genom huvudfoajén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. A visitor ticket grants access to all halls in the fair.', 'sv', 'Simulerad. En besöksbiljett ger tillträde till alla mässans hallar.')
    )
  ),
  (
    'sthlm-food-wine-2026', 'stockholmsmassan', jsonb_build_object('en', 'Sthlm Food & Wine 2026', 'sv', 'Sthlm Food & Wine 2026'),
    jsonb_build_object('en', 'Culinary consumer event with tastings and demonstrations', 'sv', 'Kulinariskt konsumentevent med provsmakningar och demonstrationer'),
    'Event', 'Food & drink', 'public', 'public_ticket',
    date '2026-11-06', date '2026-11-08',
    jsonb_build_object('en', 'Sthlm Food & Wine is a culinary event combining exhibitors, tastings, cooking demonstrations, and wine pairings.', 'sv', 'Sthlm Food & Wine är ett kulinariskt event som kombinerar utställare, provsmakningar, matlagningsdemonstrationer och vinparningar.'),
    jsonb_build_object('primary_color', '#8b1a1a', 'accent_color', '#c9a227', 'logo', null, 'hero_image', 'assets/images/events/sthlm-food-wine-2026.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Visitors enter through the main foyer.', 'sv', 'Simulerad. Besökare går in genom huvudfoajén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Open-container and tasting rules follow organizer policy.', 'sv', 'Simulerad. Regler för öppna förpackningar och provsmakningar följer arrangörens policy.'),
      'access_notes', jsonb_build_object('en', 'Simulated. A visitor ticket grants access to all halls; some tastings require additional tokens or tickets.', 'sv', 'Simulerad. En besöksbiljett ger tillträde till alla hallar; vissa provsmakningar kräver extra polletter eller biljetter.')
    )
  ),
  (
    'socionomdagarna-2026', 'stockholmsmassan', jsonb_build_object('en', 'Socionomdagarna 2026', 'sv', 'Socionomdagarna 2026'),
    jsonb_build_object('en', 'Professional development conference for Swedish social workers', 'sv', 'Kompetensutvecklingskonferens för svenska socionomer'),
    'Conference', 'Education and training', 'professional', 'registration',
    date '2026-11-10', date '2026-11-11',
    jsonb_build_object('en', 'Socionomdagarna is a professional development conference for Swedish social workers, in its 22nd edition, with keynotes, seminars, and an exhibition.', 'sv', 'Socionomdagarna är en kompetensutvecklingskonferens för svenska socionomer som arrangeras för 22:a gången, med huvudtalare, seminarier och en utställning.'),
    jsonb_build_object('primary_color', '#1d4e89', 'accent_color', '#e87a45', 'logo', null, 'hero_image', 'assets/images/events/socionomdagarna-2026.webp', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Delegates enter via the North Foyer.', 'sv', 'Simulerad. Delegater går in via norra foajén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to registered delegates.', 'sv', 'Simulerad. Tillträde är begränsat till registrerade delegater.')
    )
  ),
  (
    'battery-innovations-days-2026', 'stockholmsmassan', jsonb_build_object('en', 'Battery Innovations Days 2026', 'sv', 'Battery Innovations Days 2026'),
    jsonb_build_object('en', 'European conference on battery research and innovation', 'sv', 'Europeisk konferens om batteriforskning och innovation'),
    'Congress', 'Industry', 'professional', 'registration',
    date '2026-11-11', date '2026-11-12',
    jsonb_build_object('en', 'Battery Innovations Days is a European conference covering battery research, materials, manufacturing, and innovation, with scientific and industry tracks.', 'sv', 'Battery Innovations Days är en europeisk konferens om batteriforskning, material, tillverkning och innovation, med både vetenskapliga och industrirelaterade spår.'),
    jsonb_build_object('primary_color', '#00a398', 'accent_color', '#262626', 'logo', null, 'hero_image', 'assets/images/events/battery-innovations-days-2026.webp', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Delegates enter via the West Foyer.', 'sv', 'Simulerad. Delegater går in via västra foajén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to registered delegates.', 'sv', 'Simulerad. Tillträde är begränsat till registrerade delegater.')
    )
  ),
  (
    'gymnasiemassan-2026', 'stockholmsmassan', jsonb_build_object('en', 'Gymnasiemassan 2026', 'sv', 'Gymnasiemassan 2026'),
    jsonb_build_object('en', 'Upper secondary school selection fair', 'sv', 'Gymnasievalsmässa'),
    'Public fair', 'Education and training', 'public', 'public_ticket',
    date '2026-11-17', date '2026-11-19',
    jsonb_build_object('en', 'Gymnasiemassan is the Swedish upper-secondary school selection fair, where students and families meet schools, programs, and study counsellors.', 'sv', 'Gymnasiemässan är den svenska gymnasievalsmässan, där elever och familjer möter skolor, program och studie- och yrkesvägledare.'),
    jsonb_build_object('primary_color', '#e30613', 'accent_color', '#004b87', 'logo', null, 'hero_image', 'assets/images/events/gymnasiemassan-2026.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Students and families enter through the main foyer. School groups have a dedicated check-in.', 'sv', 'Simulerad. Elever och familjer går in genom huvudfoajén. Skolgrupper har en särskild incheckning.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Admission for visitors is managed per the organizer policy; school groups book in advance.', 'sv', 'Simulerad. Inträde för besökare hanteras enligt arrangörens policy; skolgrupper bokar i förväg.')
    )
  ),
  (
    'formex-jan-2027', 'stockholmsmassan', jsonb_build_object('en', 'Formex January 2027', 'sv', 'Formex januari 2027'),
    jsonb_build_object('en', 'Nordic interior design trade fair, spring edition', 'sv', 'Nordisk inredningsmässa, vårupplaga'),
    'Trade fair', 'Interior design', 'professional', 'registration',
    date '2027-01-19', date '2027-01-21',
    jsonb_build_object('en', 'Formex is the leading Nordic trade fair for interior design, gift items, and lifestyle brands. The January edition focuses on the spring-summer season.', 'sv', 'Formex är den ledande nordiska mässan för inredning, presentartiklar och livsstilsvarumärken. Januariupplagan fokuserar på vår- och sommarsäsongen.'),
    jsonb_build_object('primary_color', '#2b2c2d', 'accent_color', '#d4af37', 'logo', null, 'hero_image', 'assets/images/events/formex-jan-2027.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Trade visitors enter through the main foyer. Trade badges are required for access.', 'sv', 'Simulerad. Fackbesökare går in genom huvudfoajén. Fackbricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Work bags are allowed; oversize items should be checked at the cloakroom.', 'sv', 'Simulerad. Arbetsväskor är tillåtna; skrymmande föremål ska lämnas i garderoben.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  ),
  (
    'stockholm-design-week-2027', 'stockholmsmassan', jsonb_build_object('en', 'Stockholm Design Week 2027', 'sv', 'Stockholm Design Week 2027'),
    jsonb_build_object('en', 'City-wide design week with venue events at Stockholmsmassan', 'sv', 'Stadsövergripande designvecka med arrangemang på Stockholmsmässan'),
    'Event', 'Interior design', 'public', 'none',
    date '2027-02-08', date '2027-02-14',
    jsonb_build_object('en', 'Stockholm Design Week is a city-wide design program with showrooms, exhibitions, and events across Stockholm, anchored by activity at Stockholmsmassan during the Stockholm Furniture Fair week.', 'sv', 'Stockholm Design Week är ett stadsövergripande designprogram med showrooms, utställningar och evenemang runt om i Stockholm, med tyngdpunkt på aktiviteter på Stockholmsmässan under veckan för Stockholm Furniture Fair.'),
    jsonb_build_object('primary_color', '#111111', 'accent_color', '#e4d9c5', 'logo', null, 'hero_image', 'assets/images/events/stockholm-design-week-2027.png', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Venue events at Stockholmsmassan share the main foyer entrance with the Stockholm Furniture Fair.', 'sv', 'Simulerad. Arrangemang på Stockholmsmässan delar entrén i huvudfoajén med Stockholm Furniture Fair.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Most city-wide programming is open; venue sessions inside Stockholmsmassan follow the Stockholm Furniture Fair access rules.', 'sv', 'Simulerad. Större delen av det stadsövergripande programmet är öppet; sessioner inne på Stockholmsmässan följer Stockholm Furniture Fairs tillträdesregler.')
    )
  ),
  (
    'stockholm-furniture-fair-2027', 'stockholmsmassan', jsonb_build_object('en', 'Stockholm Furniture Fair 2027', 'sv', 'Stockholm Furniture Fair 2027'),
    jsonb_build_object('en', 'Leading platform for Scandinavian design', 'sv', 'Ledande plattform för skandinavisk design'),
    'Trade fair', 'Interior design', 'professional', 'registration',
    date '2027-02-09', date '2027-02-12',
    jsonb_build_object('en', 'Stockholm Furniture Fair is the leading platform for Scandinavian design, with exhibitors, Greenhouse emerging-designer spaces, and a curated program. The 2027 edition is the next biennial edition.', 'sv', 'Stockholm Furniture Fair är den ledande plattformen för skandinavisk design, med utställare, Greenhouse-ytor för nya designers och ett kurerat program. 2027 års upplaga är nästa biennala upplaga.'),
    jsonb_build_object('primary_color', '#1a1a1a', 'accent_color', '#bfb8a5', 'logo', null, 'hero_image', 'assets/images/events/stockholm-furniture-fair-2027.png', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Trade visitors enter through the main foyer. Trade badges are required for access.', 'sv', 'Simulerad. Fackbesökare går in genom huvudfoajén. Fackbricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors and accredited media registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare och ackrediterad press som registrerats via arrangören.')
    )
  ),
  (
    'sportfiskemassan-2027', 'stockholmsmassan', jsonb_build_object('en', 'Sportfiskemassan 2027', 'sv', 'Sportfiskemassan 2027'),
    jsonb_build_object('en', 'Swedish sport fishing consumer expo', 'sv', 'Svensk konsumentmässa för sportfiske'),
    'Public fair', 'Leisure and consumer', 'public', 'public_ticket',
    date '2027-03-19', date '2027-03-21',
    jsonb_build_object('en', 'Sportfiskemassan is the Swedish sport-fishing consumer expo with exhibitors, demonstrations, and an expanded program for the 2027 edition.', 'sv', 'Sportfiskemässan är den svenska sportfiskemässan för konsumenter med utställare, demonstrationer och ett utökat program för 2027 års upplaga.'),
    jsonb_build_object('primary_color', '#1b5e96', 'accent_color', '#86bc40', 'logo', null, 'hero_image', 'assets/images/events/sportfiskemassan-2027.webp', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Visitors enter through the main foyer.', 'sv', 'Simulerad. Besökare går in genom huvudfoajén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Fishing rods and related equipment are allowed on the fair floor.', 'sv', 'Simulerad. Fiskespön och tillhörande utrustning är tillåtna på mässgolvet.'),
      'access_notes', jsonb_build_object('en', 'Simulated. A visitor ticket grants access to all halls.', 'sv', 'Simulerad. En besöksbiljett ger tillträde till alla hallar.')
    )
  ),
  (
    'escmid-global-2027', 'stockholmsmassan', jsonb_build_object('en', 'ESCMID Global 2027', 'sv', 'ESCMID Global 2027'),
    jsonb_build_object('en', 'European congress on infectious diseases and clinical microbiology', 'sv', 'Europeisk kongress om infektionssjukdomar och klinisk mikrobiologi'),
    'Congress', 'Health & Medicine', 'professional', 'registration',
    date '2027-04-09', date '2027-04-13',
    jsonb_build_object('en', 'ESCMID Global is the leading European congress on infectious diseases and clinical microbiology, with a multi-track scientific program and large industry exhibition.', 'sv', 'ESCMID Global är den ledande europeiska kongressen om infektionssjukdomar och klinisk mikrobiologi, med ett vetenskapligt program i flera spår och en stor branschutställning.'),
    jsonb_build_object('primary_color', '#004a94', 'accent_color', '#c8102e', 'logo', null, 'hero_image', 'assets/images/events/escmid-global-2027.png', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Delegates enter via the East Foyer. Badges and photo ID are required at the door.', 'sv', 'Simulerad. Delegater går in via östra foajén. Bricka och fotolegitimation krävs vid entrén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply; poster tubes are accommodated at the cloakroom.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller; posterrör kan lämnas i garderoben.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to registered delegates, exhibitors, and accredited media.', 'sv', 'Simulerad. Tillträde är begränsat till registrerade delegater, utställare och ackrediterad press.')
    )
  ),
  (
    'cired-2027', 'stockholmsmassan', jsonb_build_object('en', 'CIRED 2027', 'sv', 'CIRED 2027'),
    jsonb_build_object('en', 'International conference and exhibition on electricity distribution', 'sv', 'Internationell konferens och utställning om eldistribution'),
    'Congress', 'Industry', 'professional', 'registration',
    date '2027-06-14', date '2027-06-17',
    jsonb_build_object('en', 'CIRED is the leading forum for the global electricity distribution community, with technical sessions, poster presentations, and a large industry exhibition.', 'sv', 'CIRED är det ledande forumet för den globala eldistributionsbranschen, med tekniska sessioner, posterpresentationer och en stor branschutställning.'),
    jsonb_build_object('primary_color', '#002147', 'accent_color', '#e6a22a', 'logo', null, 'hero_image', 'assets/images/events/cired-2027.png', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Delegates enter via the North Foyer. Badges are required at the door.', 'sv', 'Simulerad. Delegater går in via norra foajén. Bricka krävs vid entrén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to registered delegates and exhibitors.', 'sv', 'Simulerad. Tillträde är begränsat till registrerade delegater och utställare.')
    )
  ),
  (
    'formex-aug-2027', 'stockholmsmassan', jsonb_build_object('en', 'Formex August 2027', 'sv', 'Formex augusti 2027'),
    jsonb_build_object('en', 'Nordic interior design trade fair, autumn edition', 'sv', 'Nordisk inredningsmässa, höstupplaga'),
    'Trade fair', 'Interior design', 'professional', 'registration',
    date '2027-08-24', date '2027-08-26',
    jsonb_build_object('en', 'Formex is the leading Nordic trade fair for interior design, gift items, and lifestyle brands. The August edition focuses on the autumn-winter season.', 'sv', 'Formex är den ledande nordiska mässan för inredning, present­artiklar och livsstilsvarumärken. Augustiupplagan fokuserar på höst- och vintersäsongen.'),
    jsonb_build_object('primary_color', '#2b2c2d', 'accent_color', '#d4af37', 'logo', null, 'hero_image', 'assets/images/events/formex-aug-2027.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Trade visitors enter through the main foyer. Trade badges are required for access.', 'sv', 'Simulerad. Fackbesökare går in genom huvudfoajén. Fackbricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Work bags are allowed; oversize items should be checked at the cloakroom.', 'sv', 'Simulerad. Arbetsväskor är tillåtna; skrymmande föremål ska lämnas i garderoben.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  ),
  (
    'totalforsvarsmassan-2027', 'stockholmsmassan', jsonb_build_object('en', 'Totalforsvarsmassan 2027', 'sv', 'Totalforsvarsmassan 2027'),
    jsonb_build_object('en', 'Swedish total-defense industry fair', 'sv', 'Svensk totalförsvarsmässa'),
    'Trade fair', 'Industry', 'professional', 'registration',
    date '2027-10-26', date '2027-10-28',
    jsonb_build_object('en', 'Totalforsvarsmassan is the Swedish total-defense industry fair, covering civil protection, defense, and emergency preparedness.', 'sv', 'Totalförsvarsmässan är den svenska totalförsvarsmässan och täcker civil beredskap, försvar och krisberedskap.'),
    jsonb_build_object('primary_color', '#4e5c32', 'accent_color', '#b39956', 'logo', null, 'hero_image', 'assets/images/events/totalforsvarsmassan-2027.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Trade visitors enter via the East Foyer. Badges are required for access.', 'sv', 'Simulerad. Fackbesökare går in via östra foajén. Bricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  ),
  (
    'gymnasiemassan-2027', 'stockholmsmassan', jsonb_build_object('en', 'Gymnasiemassan 2027', 'sv', 'Gymnasiemassan 2027'),
    jsonb_build_object('en', 'Upper secondary school selection fair', 'sv', 'Gymnasievalsmässa'),
    'Public fair', 'Education and training', 'public', 'public_ticket',
    date '2027-11-23', date '2027-11-25',
    jsonb_build_object('en', 'Gymnasiemassan is the Swedish upper-secondary school selection fair, where students and families meet schools, programs, and study counsellors.', 'sv', 'Gymnasiemässan är den svenska gymnasievalsmässan, där elever och familjer möter skolor, program och studie- och yrkesvägledare.'),
    jsonb_build_object('primary_color', '#e30613', 'accent_color', '#004b87', 'logo', null, 'hero_image', 'assets/images/events/gymnasiemassan-2027.png', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Students and families enter through the main foyer.', 'sv', 'Simulerad. Elever och familjer går in genom huvudfoajén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Admission for visitors is managed per the organizer policy; school groups book in advance.', 'sv', 'Simulerad. Inträde för besökare hanteras enligt arrangörens policy; skolgrupper bokar i förväg.')
    )
  ),
  (
    'formex-jan-2028', 'stockholmsmassan', jsonb_build_object('en', 'Formex January 2028', 'sv', 'Formex januari 2028'),
    jsonb_build_object('en', 'Nordic interior design trade fair, spring edition', 'sv', 'Nordisk inredningsmässa, vårupplaga'),
    'Trade fair', 'Interior design', 'professional', 'registration',
    date '2028-01-18', date '2028-01-20',
    jsonb_build_object('en', 'Formex is the leading Nordic trade fair for interior design, gift items, and lifestyle brands.', 'sv', 'Formex är den ledande nordiska mässan för inredning, presentartiklar och livsstilsvarumärken.'),
    jsonb_build_object('primary_color', '#2b2c2d', 'accent_color', '#d4af37', 'logo', null, 'hero_image', 'assets/images/events/formex-jan-2028.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Trade visitors enter through the main foyer. Trade badges are required for access.', 'sv', 'Simulerad. Fackbesökare går in genom huvudfoajén. Fackbricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Work bags are allowed.', 'sv', 'Simulerad. Arbetsväskor är tillåtna.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  ),
  (
    'nordbygg-2028', 'stockholmsmassan', jsonb_build_object('en', 'Nordbygg 2028', 'sv', 'Nordbygg 2028'),
    jsonb_build_object('en', 'Nordic construction trade fair', 'sv', 'Nordisk byggmässa'),
    'Trade fair', 'Construction and real estate', 'public', 'public_ticket',
    date '2028-04-04', date '2028-04-07',
    jsonb_build_object('en', 'Nordbygg returns to Stockholmsmassan as the leading Nordic meeting place for the construction and real-estate industry.', 'sv', 'Nordbygg återvänder till Stockholmsmässan som den ledande nordiska mötesplatsen för bygg- och fastighetsbranschen.'),
    jsonb_build_object('primary_color', '#0b3d91', 'accent_color', '#f4b400', 'logo', null, 'hero_image', 'assets/images/events/nordbygg-2028.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan', 'sv', 'Stockholmsmässan')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Enter through the main foyer at Stockholmsmassan. Nordbygg signage guides visitors to registration.', 'sv', 'Simulerad. Gå in genom huvudfoajén på Stockholmsmässan. Nordbyggs skyltning vägleder besökare till registreringen.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Work bags and smaller backpacks are allowed on the fair floor.', 'sv', 'Simulerad. Arbetsväskor och mindre ryggsäckar är tillåtna på mässgolvet.'),
      'access_notes', jsonb_build_object('en', 'Simulated. A visitor ticket grants access to all exhibition halls and seminar rooms.', 'sv', 'Simulerad. En besöksbiljett ger tillträde till alla utställningshallar och seminarierum.')
    )
  ),
  (
    'formex-aug-2028', 'stockholmsmassan', jsonb_build_object('en', 'Formex August 2028', 'sv', 'Formex augusti 2028'),
    jsonb_build_object('en', 'Nordic interior design trade fair, autumn edition', 'sv', 'Nordisk inredningsmässa, höstupplaga'),
    'Trade fair', 'Interior design', 'professional', 'registration',
    date '2028-08-29', date '2028-08-31',
    jsonb_build_object('en', 'Formex is the leading Nordic trade fair for interior design, gift items, and lifestyle brands.', 'sv', 'Formex är den ledande nordiska mässan för inredning, presentartiklar och livsstilsvarumärken.'),
    jsonb_build_object('primary_color', '#2b2c2d', 'accent_color', '#d4af37', 'logo', null, 'hero_image', 'assets/images/events/formex-aug-2027.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan (reused from earlier edition)', 'sv', 'Stockholmsmässan (återanvänd från tidigare upplaga)')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Trade visitors enter through the main foyer. Trade badges are required for access.', 'sv', 'Simulerad. Fackbesökare går in genom huvudfoajén. Fackbricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Work bags are allowed.', 'sv', 'Simulerad. Arbetsväskor är tillåtna.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  ),
  (
    'skydd-2028', 'stockholmsmassan', jsonb_build_object('en', 'Skydd 2028', 'sv', 'Skydd 2028'),
    jsonb_build_object('en', 'Nordic security, fire-safety, and protection trade fair', 'sv', 'Nordisk mässa för säkerhet, brandskydd och skyddstjänster'),
    'Trade fair', 'Industry', 'professional', 'registration',
    date '2028-10-24', date '2028-10-26',
    jsonb_build_object('en', 'Skydd is the Nordic meeting place for security, fire-safety, and civil-protection professionals.', 'sv', 'Skydd är den nordiska mötesplatsen för yrkesverksamma inom säkerhet, brandskydd och civil beredskap.'),
    jsonb_build_object('primary_color', '#c41e3a', 'accent_color', '#1a2e44', 'logo', null, 'hero_image', 'assets/images/events/skydd-2026.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan (reused from earlier edition)', 'sv', 'Stockholmsmässan (återanvänd från tidigare upplaga)')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Trade visitors enter via the East Foyer. Badges are required for access.', 'sv', 'Simulerad. Fackbesökare går in via östra foajén. Bricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  ),
  (
    'gymnasiemassan-2028', 'stockholmsmassan', jsonb_build_object('en', 'Gymnasiemassan 2028', 'sv', 'Gymnasiemassan 2028'),
    jsonb_build_object('en', 'Upper secondary school selection fair', 'sv', 'Gymnasievalsmässa'),
    'Public fair', 'Education and training', 'public', 'public_ticket',
    date '2028-11-21', date '2028-11-23',
    jsonb_build_object('en', 'Gymnasiemassan is the Swedish upper-secondary school selection fair.', 'sv', 'Gymnasiemässan är den svenska gymnasievalsmässan.'),
    jsonb_build_object('primary_color', '#e30613', 'accent_color', '#004b87', 'logo', null, 'hero_image', 'assets/images/events/gymnasiemassan-2026.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan (reused from earlier edition)', 'sv', 'Stockholmsmässan (återanvänd från tidigare upplaga)')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Students and families enter through the main foyer.', 'sv', 'Simulerad. Elever och familjer går in genom huvudfoajén.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Admission for visitors is managed per the organizer policy; school groups book in advance.', 'sv', 'Simulerad. Inträde för besökare hanteras enligt arrangörens policy; skolgrupper bokar i förväg.')
    )
  ),
  (
    'skydd-2030', 'stockholmsmassan', jsonb_build_object('en', 'Skydd 2030', 'sv', 'Skydd 2030'),
    jsonb_build_object('en', 'Nordic security, fire-safety, and protection trade fair', 'sv', 'Nordisk mässa för säkerhet, brandskydd och skyddstjänster'),
    'Trade fair', 'Industry', 'professional', 'registration',
    date '2030-10-22', date '2030-10-24',
    jsonb_build_object('en', 'Skydd is the Nordic meeting place for security, fire-safety, and civil-protection professionals.', 'sv', 'Skydd är den nordiska mötesplatsen för yrkesverksamma inom säkerhet, brandskydd och civil beredskap.'),
    jsonb_build_object('primary_color', '#c41e3a', 'accent_color', '#1a2e44', 'logo', null, 'hero_image', 'assets/images/events/skydd-2026.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan (reused from earlier edition)', 'sv', 'Stockholmsmässan (återanvänd från tidigare upplaga)')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Trade visitors enter via the East Foyer. Badges are required for access.', 'sv', 'Simulerad. Fackbesökare går in via östra foajén. Bricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  ),
  (
    'totalforsvarsmassan-2030', 'stockholmsmassan', jsonb_build_object('en', 'Totalforsvarsmassan 2030', 'sv', 'Totalforsvarsmassan 2030'),
    jsonb_build_object('en', 'Swedish total-defense industry fair', 'sv', 'Svensk totalförsvarsmässa'),
    'Trade fair', 'Industry', 'professional', 'registration',
    date '2030-10-22', date '2030-10-24',
    jsonb_build_object('en', 'Totalforsvarsmassan is the Swedish total-defense industry fair, covering civil protection, defense, and emergency preparedness.', 'sv', 'Totalförsvarsmässan är den svenska totalförsvarsmässan och täcker civil beredskap, försvar och krisberedskap.'),
    jsonb_build_object('primary_color', '#4e5c32', 'accent_color', '#b39956', 'logo', null, 'hero_image', 'assets/images/events/totalforsvarsmassan-2026.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan (reused from earlier edition)', 'sv', 'Stockholmsmässan (återanvänd från tidigare upplaga)')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Trade visitors enter via the East Foyer. Badges are required for access.', 'sv', 'Simulerad. Fackbesökare går in via östra foajén. Bricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  ),
  (
    'skydd-2032', 'stockholmsmassan', jsonb_build_object('en', 'Skydd 2032', 'sv', 'Skydd 2032'),
    jsonb_build_object('en', 'Nordic security, fire-safety, and protection trade fair', 'sv', 'Nordisk mässa för säkerhet, brandskydd och skyddstjänster'),
    'Trade fair', 'Industry', 'professional', 'registration',
    date '2032-10-19', date '2032-10-21',
    jsonb_build_object('en', 'Skydd is the Nordic meeting place for security, fire-safety, and civil-protection professionals.', 'sv', 'Skydd är den nordiska mötesplatsen för yrkesverksamma inom säkerhet, brandskydd och civil beredskap.'),
    jsonb_build_object('primary_color', '#c41e3a', 'accent_color', '#1a2e44', 'logo', null, 'hero_image', 'assets/images/events/skydd-2026.jpg', 'hero_image_credit', jsonb_build_object('en', 'Stockholmsmassan (reused from earlier edition)', 'sv', 'Stockholmsmässan (återanvänd från tidigare upplaga)')),
    jsonb_build_object(
      'entrance', jsonb_build_object('en', 'Simulated. Trade visitors enter via the East Foyer. Badges are required for access.', 'sv', 'Simulerad. Fackbesökare går in via östra foajén. Bricka krävs för tillträde.'),
      'bag_rules', jsonb_build_object('en', 'Simulated. Standard venue bag rules apply.', 'sv', 'Simulerad. Anläggningens vanliga väskregler gäller.'),
      'access_notes', jsonb_build_object('en', 'Simulated. Access is restricted to trade visitors registered through the organizer.', 'sv', 'Simulerad. Tillträde är begränsat till fackbesökare som registrerats via arrangören.')
    )
  )
on conflict (id) do update set
  venue_id = excluded.venue_id,
  name = excluded.name,
  subtitle = excluded.subtitle,
  type = excluded.type,
  category = excluded.category,
  audience_rule = excluded.audience_rule,
  ticket_model = excluded.ticket_model,
  start_date = excluded.start_date,
  end_date = excluded.end_date,
  summary = excluded.summary,
  branding = excluded.branding,
  overrides = excluded.overrides;

insert into public.news_items (id, event_id, published_at, title, body, hero_image) values
  ('nordbygg-2026-news-exhibitors-crossed', 'nordbygg-2026', timestamptz '2026-03-02T09:00:00Z',
   jsonb_build_object('en', 'Nordbygg 2026 exhibitor registrations cross 700', 'sv', 'Antalet anmälda utställare till Nordbygg 2026 passerar 700'),
   jsonb_build_object('en', 'Simulated. Nordbygg reports that more than 700 exhibitors have confirmed attendance, spanning sustainable materials, prefabrication, building services, and digital tools for the construction industry.', 'sv', 'Simulerad. Nordbygg meddelar att över 700 utställare har bekräftat deltagande, med inriktning på hållbara material, prefabricering, byggtjänster och digitala verktyg för byggbranschen.'),
   'assets/images/events/nordbygg-2026.jpg'),
  ('nordbygg-2026-news-sustainability-stage', 'nordbygg-2026', timestamptz '2026-03-18T09:00:00Z',
   jsonb_build_object('en', 'Sustainability stage program finalized', 'sv', 'Programmet på Hållbarhetsscenen är klart'),
   jsonb_build_object('en', 'Simulated. The Sustainability Stage program for Nordbygg 2026 covers circular construction, low-carbon concrete, and energy retrofits. All sessions are open to fair visitors without extra registration.', 'sv', 'Simulerad. Programmet på Hållbarhetsscenen under Nordbygg 2026 omfattar cirkulärt byggande, klimatförbättrad betong och energirenoveringar. Alla pass är öppna för mässans besökare utan extra anmälan.'),
   'assets/images/events/nordbygg-2026.jpg'),
  ('nordbygg-2026-news-safety-workshop', 'nordbygg-2026', timestamptz '2026-04-01T09:00:00Z',
   jsonb_build_object('en', 'Site-safety workshops added to day three', 'sv', 'Workshops om arbetsplatssäkerhet läggs till dag tre'),
   jsonb_build_object('en', 'Simulated. Day three of the fair adds hands-on workshops on site-safety equipment, PPE, and fall-protection. Capacity is limited and managed at the workshop entrance.', 'sv', 'Simulerad. Mässans tredje dag kompletteras med praktiska workshops om säkerhetsutrustning, personlig skyddsutrustning och fallskydd. Antalet platser är begränsat och hanteras vid workshopens entré.'),
   'assets/images/events/nordbygg-2026.jpg'),
  ('nordbygg-2026-news-ticket-pickup', 'nordbygg-2026', timestamptz '2026-04-14T09:00:00Z',
   jsonb_build_object('en', 'Ticket pickup and visitor tips for opening day', 'sv', 'Biljetthämtning och besökstips inför öppningsdagen'),
   jsonb_build_object('en', 'Simulated. Visitors are encouraged to pre-register and use mobile tickets to skip the queues at opening. Coffee will be available in the main foyer from 8:00.', 'sv', 'Simulerad. Besökare uppmanas att föranmäla sig och använda mobila biljetter för att slippa köerna vid öppning. Kaffe serveras i huvudfoajén från klockan 8:00.'),
   'assets/images/events/nordbygg-2026.jpg'),
  ('estro-2026-news-late-breaking', 'estro-2026', timestamptz '2026-04-05T09:00:00Z',
   jsonb_build_object('en', 'Late-breaking abstract window closes', 'sv', 'Inlämningstiden för sena abstracts har stängt'),
   jsonb_build_object('en', 'Simulated. The late-breaking abstract submission window for ESTRO 2026 has closed. Accepted late-breakers will be added to the searchable program next week.', 'sv', 'Simulerad. Inlämningsfönstret för sena abstracts till ESTRO 2026 har stängt. Godkända sena bidrag läggs till i det sökbara programmet nästa vecka.'),
   'assets/images/events/estro-2026.webp'),
  ('estro-2026-news-industry-symposia', 'estro-2026', timestamptz '2026-04-20T09:00:00Z',
   jsonb_build_object('en', 'Industry symposia and hands-on demos announced', 'sv', 'Industrisymposier och praktiska demonstrationer presenteras'),
   jsonb_build_object('en', 'Simulated. Industry symposia and hands-on demos for ESTRO 2026 have been published in the congress program. Delegates can filter their personal agenda to include or exclude industry content.', 'sv', 'Simulerad. Industrisymposier och praktiska demonstrationer för ESTRO 2026 har publicerats i kongressprogrammet. Delegater kan filtrera sin personliga agenda för att inkludera eller utesluta industriinnehåll.'),
   'assets/images/events/estro-2026.webp'),
  ('eha-2026-news-platform-open', 'eha-2026', timestamptz '2026-05-05T09:00:00Z',
   jsonb_build_object('en', 'EHA2026 congress platform opens to registered delegates', 'sv', 'EHA2026:s kongressplattform öppnar för anmälda delegater'),
   jsonb_build_object('en', 'Simulated. The EHA2026 congress platform is now available to registered delegates, with networking, profile setup, and the full searchable program.', 'sv', 'Simulerad. Kongressplattformen för EHA2026 är nu tillgänglig för anmälda delegater, med nätverksfunktioner, profilskapande och hela det sökbara programmet.'),
   'assets/images/events/eha-2026.jpg')
on conflict (id) do update set
  title = excluded.title,
  body = excluded.body,
  published_at = excluded.published_at,
  hero_image = excluded.hero_image;

insert into public.articles (id, event_id, title, body, hero_image) values
  ('nordbygg-2026-article-why-attend', 'nordbygg-2026',
   jsonb_build_object('en', 'Why Nordbygg 2026 is the Nordic construction meeting point', 'sv', 'Därför är Nordbygg 2026 Nordens mötesplats för byggbranschen'),
   jsonb_build_object('en', 'Simulated. Nordbygg collects the Nordic construction and real-estate industry under one roof at Stockholmsmassan: manufacturers, consultants, architects, developers, and public-sector procurement teams. The fair combines an exhibitor floor, a seminar program, and dedicated stages for sustainability and digital tools. Visitors use the fair to benchmark products, meet suppliers in person, and get an overview of emerging regulation.', 'sv', 'Simulerad. Nordbygg samlar den nordiska bygg- och fastighetsbranschen under ett tak på Stockholmsmässan: tillverkare, konsulter, arkitekter, byggherrar och offentliga upphandlare. Mässan kombinerar utställargolv, seminarieprogram och egna scener för hållbarhet och digitala verktyg. Besökare använder mässan för att jämföra produkter, möta leverantörer på plats och få en överblick över nya regelverk.'),
   'assets/images/events/nordbygg-2026.jpg'),
  ('nordbygg-2026-article-what-to-see', 'nordbygg-2026',
   jsonb_build_object('en', 'What to see on a one-day visit', 'sv', 'Vad du bör se under ett endagsbesök'),
   jsonb_build_object('en', 'Simulated. If you only have one day at Nordbygg 2026, focus on the Sustainability Stage in the morning, spend midday on the exhibitor floor around the prefabrication and building-services areas, and close the day with a site-safety workshop or a digital-tools demo. The event-first app view lets you save a short list of exhibitors to visit on the floor.', 'sv', 'Simulerad. Om du bara har en dag på Nordbygg 2026, lägg förmiddagen på Hållbarhetsscenen, tillbringa middagstid på utställargolvet kring områdena prefabricering och byggtjänster, och avsluta dagen med en workshop om arbetsplatssäkerhet eller en demonstration av digitala verktyg. Evenemangsvyn i appen låter dig spara en kort lista över utställare att besöka på mässgolvet.'),
   'assets/images/events/nordbygg-2026.jpg'),
  ('estro-2026-article-program-highlights', 'estro-2026',
   jsonb_build_object('en', 'ESTRO 2026 program highlights', 'sv', 'Höjdpunkter ur ESTRO 2026:s program'),
   jsonb_build_object('en', 'Simulated. The ESTRO 2026 program covers clinical radiation oncology, medical physics, radiobiology, brachytherapy, and technology and innovation tracks. Plenary sessions open and close each day, with parallel tracks and poster sessions filling the rest of the schedule. Delegates are encouraged to build a personal agenda before the congress opens.', 'sv', 'Simulerad. ESTRO 2026:s program omfattar klinisk strålterapi, medicinsk fysik, strålningsbiologi, brakyterapi samt spår om teknik och innovation. Plenarsessioner inleder och avslutar varje dag, medan parallella spår och postersessioner fyller resten av schemat. Delegater uppmuntras att bygga en personlig agenda innan kongressen öppnar.'),
   'assets/images/events/estro-2026.webp')
on conflict (id) do update set
  title = excluded.title,
  body = excluded.body,
  hero_image = excluded.hero_image;

insert into public.speakers (id, name, bio, affiliation, avatar) values
  ('estro-2026-speaker-lindqvist', 'Dr. Eva Lindqvist',
   jsonb_build_object('en', 'Simulated speaker profile. Radiation oncologist focused on adaptive radiotherapy.', 'sv', 'Simulerad talarprofil. Onkolog inriktad på adaptiv strålterapi.'),
   jsonb_build_object('en', 'Karolinska University Hospital', 'sv', 'Karolinska Universitetssjukhuset'),
   'assets/images/speakers/estro-2026-lindqvist.svg'),
  ('estro-2026-speaker-morales', 'Dr. Luis Morales',
   jsonb_build_object('en', 'Simulated speaker profile. Clinical researcher in head-and-neck radiation oncology.', 'sv', 'Simulerad talarprofil. Klinisk forskare inom strålterapi för huvud-halscancer.'),
   jsonb_build_object('en', 'Hospital Clinic de Barcelona', 'sv', 'Hospital Clinic de Barcelona'),
   'assets/images/speakers/estro-2026-morales.svg'),
  ('estro-2026-speaker-bergstrom', 'Dr. Anna Bergstrom',
   jsonb_build_object('en', 'Simulated speaker profile. Medical physicist focused on dose calculation and QA.', 'sv', 'Simulerad talarprofil. Sjukhusfysiker inriktad på dosberäkning och kvalitetssäkring.'),
   jsonb_build_object('en', 'Uppsala University Hospital', 'sv', 'Akademiska sjukhuset i Uppsala'),
   'assets/images/speakers/estro-2026-bergstrom.svg')
on conflict (id) do update set
  name = excluded.name,
  bio = excluded.bio,
  affiliation = excluded.affiliation,
  avatar = excluded.avatar;

insert into public.program_items (
  id, event_id, day, start_time, end_time, title, description, location, track, speaker_ids
) values
  ('nordbygg-2026-program-opening', 'nordbygg-2026', date '2026-04-21', time '09:00', time '09:30',
   jsonb_build_object('en', 'Opening and industry welcome', 'sv', 'Invigning och välkomsthälsning från branschen'),
   jsonb_build_object('en', 'Simulated. Official opening of Nordbygg 2026 with remarks from industry and venue representatives.', 'sv', 'Simulerad. Officiell invigning av Nordbygg 2026 med inledningsord från branschens och anläggningens företrädare.'),
   jsonb_build_object('en', 'Main Stage, A-Hall', 'sv', 'Huvudscenen, hall A'), 'Keynote', '{}'),
  ('nordbygg-2026-program-low-carbon-concrete', 'nordbygg-2026', date '2026-04-21', time '10:00', time '11:00',
   jsonb_build_object('en', 'Low-carbon concrete in practice', 'sv', 'Klimatförbättrad betong i praktiken'),
   jsonb_build_object('en', 'Simulated. Practitioner panel on low-carbon concrete mixes and procurement practices in Nordic construction projects.', 'sv', 'Simulerad. Panel med yrkesverksamma om klimatförbättrade betongrecept och upphandlingspraxis i nordiska byggprojekt.'),
   jsonb_build_object('en', 'Sustainability Stage, B-Hall', 'sv', 'Hållbarhetsscenen, hall B'), 'Sustainability', '{}'),
  ('nordbygg-2026-program-circular-construction', 'nordbygg-2026', date '2026-04-21', time '13:00', time '14:00',
   jsonb_build_object('en', 'Circular construction from design to demolition', 'sv', 'Cirkulärt byggande från projektering till rivning'),
   jsonb_build_object('en', 'Simulated. Case studies from Nordic developers on circular construction, material reuse, and end-of-life planning.', 'sv', 'Simulerad. Fallstudier från nordiska byggherrar om cirkulärt byggande, materialåterbruk och planering för byggnadens slutskede.'),
   jsonb_build_object('en', 'Sustainability Stage, B-Hall', 'sv', 'Hållbarhetsscenen, hall B'), 'Sustainability', '{}'),
  ('nordbygg-2026-program-prefab', 'nordbygg-2026', date '2026-04-22', time '10:00', time '11:00',
   jsonb_build_object('en', 'Prefabrication and industrialized building', 'sv', 'Prefabricering och industriellt byggande'),
   jsonb_build_object('en', 'Simulated. Current state of prefabricated construction systems in the Nordic market and what large public projects are adopting.', 'sv', 'Simulerad. Nuläget för prefabricerade byggsystem på den nordiska marknaden och vilka lösningar stora offentliga projekt väljer.'),
   jsonb_build_object('en', 'Main Stage, A-Hall', 'sv', 'Huvudscenen, hall A'), 'Industry', '{}'),
  ('nordbygg-2026-program-digital-tools', 'nordbygg-2026', date '2026-04-22', time '11:30', time '12:30',
   jsonb_build_object('en', 'Digital tools on site', 'sv', 'Digitala verktyg på byggarbetsplatsen'),
   jsonb_build_object('en', 'Simulated. Live demos of site-management, BIM, and field-reporting tools relevant to Nordic contractors and consultants.', 'sv', 'Simulerad. Liveexempel på verktyg för platsstyrning, BIM och fältrapportering, relevanta för nordiska entreprenörer och konsulter.'),
   jsonb_build_object('en', 'Digital Stage, C-Hall', 'sv', 'Digitala scenen, hall C'), 'Digital', '{}'),
  ('nordbygg-2026-program-procurement', 'nordbygg-2026', date '2026-04-22', time '14:00', time '15:00',
   jsonb_build_object('en', 'Sustainable procurement in the public sector', 'sv', 'Hållbar upphandling i offentlig sektor'),
   jsonb_build_object('en', 'Simulated. How Nordic municipalities and public-sector developers are integrating climate, circularity, and social criteria into procurement.', 'sv', 'Simulerad. Hur nordiska kommuner och offentliga byggherrar integrerar klimat-, cirkularitets- och sociala krav i upphandlingar.'),
   jsonb_build_object('en', 'Sustainability Stage, B-Hall', 'sv', 'Hållbarhetsscenen, hall B'), 'Sustainability', '{}'),
  ('nordbygg-2026-program-safety-workshop', 'nordbygg-2026', date '2026-04-23', time '10:00', time '11:30',
   jsonb_build_object('en', 'Hands-on site safety workshop', 'sv', 'Praktisk workshop om arbetsplatssäkerhet'),
   jsonb_build_object('en', 'Simulated. Hands-on workshop on PPE, fall-protection, and incident response on construction sites. Capacity is limited and managed at the workshop entrance.', 'sv', 'Simulerad. Praktisk workshop om personlig skyddsutrustning, fallskydd och tillbudshantering på byggarbetsplatser. Antalet platser är begränsat och hanteras vid workshopens entré.'),
   jsonb_build_object('en', 'Workshop Room 3, C-Hall', 'sv', 'Workshopsal 3, hall C'), 'Safety', '{}'),
  ('nordbygg-2026-program-energy-retrofits', 'nordbygg-2026', date '2026-04-23', time '13:00', time '14:00',
   jsonb_build_object('en', 'Energy retrofits at scale', 'sv', 'Energirenoveringar i stor skala'),
   jsonb_build_object('en', 'Simulated. Case studies from Nordic property owners on large-scale energy retrofits, financing, and tenant communication.', 'sv', 'Simulerad. Fallstudier från nordiska fastighetsägare om storskaliga energirenoveringar, finansiering och hyresgästkommunikation.'),
   jsonb_build_object('en', 'Main Stage, A-Hall', 'sv', 'Huvudscenen, hall A'), 'Industry', '{}'),
  ('nordbygg-2026-program-networking', 'nordbygg-2026', date '2026-04-23', time '16:00', time '18:00',
   jsonb_build_object('en', 'Industry networking reception', 'sv', 'Branschmingel'),
   jsonb_build_object('en', 'Simulated. Evening networking reception for exhibitors and registered industry visitors in the main foyer.', 'sv', 'Simulerad. Kvällsmingel för utställare och anmälda fackbesökare i huvudfoajén.'),
   jsonb_build_object('en', 'Main Foyer', 'sv', 'Huvudfoajén'), 'Networking', '{}'),
  ('nordbygg-2026-program-closing-panel', 'nordbygg-2026', date '2026-04-24', time '13:00', time '14:00',
   jsonb_build_object('en', 'Closing panel and 2027 outlook', 'sv', 'Avslutande panelsamtal och utblick mot 2027'),
   jsonb_build_object('en', 'Simulated. Closing panel reflecting on the 2026 edition and previewing the Nordic construction outlook for 2027.', 'sv', 'Simulerad. Avslutande panelsamtal som blickar tillbaka på 2026 års upplaga och ger en förhandstitt på utsikterna för nordiskt byggande 2027.'),
   jsonb_build_object('en', 'Main Stage, A-Hall', 'sv', 'Huvudscenen, hall A'), 'Keynote', '{}'),

  ('estro-2026-program-opening-plenary', 'estro-2026', date '2026-05-15', time '09:00', time '10:00',
   jsonb_build_object('en', 'Opening plenary', 'sv', 'Inledande plenarsession'),
   jsonb_build_object('en', 'Simulated. Opening plenary of ESTRO 2026 with state-of-the-art lectures across radiation oncology.', 'sv', 'Simulerad. Inledande plenarsession för ESTRO 2026 med state-of-the-art-föreläsningar inom strålterapi.'),
   jsonb_build_object('en', 'Auditorium North', 'sv', 'Norra auditoriet'), 'Plenary', '{estro-2026-speaker-lindqvist}'),
  ('estro-2026-program-clinical-track', 'estro-2026', date '2026-05-15', time '11:00', time '12:30',
   jsonb_build_object('en', 'Clinical track: adaptive radiotherapy', 'sv', 'Kliniskt spår: adaptiv strålterapi'),
   jsonb_build_object('en', 'Simulated. Parallel clinical session on adaptive radiotherapy workflows and outcomes.', 'sv', 'Simulerad. Parallell klinisk session om arbetsflöden och behandlingsresultat inom adaptiv strålterapi.'),
   jsonb_build_object('en', 'Room 210', 'sv', 'Sal 210'), 'Clinical', '{estro-2026-speaker-morales}'),
  ('estro-2026-program-physics-track', 'estro-2026', date '2026-05-16', time '09:00', time '10:30',
   jsonb_build_object('en', 'Physics track: dose calculation and QA', 'sv', 'Fysikspår: dosberäkning och kvalitetssäkring'),
   jsonb_build_object('en', 'Simulated. Parallel physics session on dose calculation advances and treatment quality assurance.', 'sv', 'Simulerad. Parallell fysiksession om framsteg inom dosberäkning och kvalitetssäkring av behandlingar.'),
   jsonb_build_object('en', 'Room 220', 'sv', 'Sal 220'), 'Physics', '{estro-2026-speaker-bergstrom}'),
  ('estro-2026-program-radiobiology-track', 'estro-2026', date '2026-05-16', time '13:00', time '14:30',
   jsonb_build_object('en', 'Radiobiology track: combination therapies', 'sv', 'Strålningsbiologispår: kombinationsbehandlingar'),
   jsonb_build_object('en', 'Simulated. Parallel radiobiology session on combining radiation with systemic therapies.', 'sv', 'Simulerad. Parallell session inom strålningsbiologi om att kombinera strålbehandling med systemiska terapier.'),
   jsonb_build_object('en', 'Room 230', 'sv', 'Sal 230'), 'Radiobiology', '{}'),
  ('estro-2026-program-poster-session', 'estro-2026', date '2026-05-17', time '12:30', time '14:00',
   jsonb_build_object('en', 'Poster session A', 'sv', 'Postersession A'),
   jsonb_build_object('en', 'Simulated. First poster session with authors present at their posters on the exhibition floor.', 'sv', 'Simulerad. Första postersessionen där författarna finns på plats vid sina posters på utställningsgolvet.'),
   jsonb_build_object('en', 'Exhibition Hall', 'sv', 'Utställningshallen'), 'Posters', '{}'),
  ('estro-2026-program-industry-symposium', 'estro-2026', date '2026-05-18', time '12:45', time '13:45',
   jsonb_build_object('en', 'Industry symposium: imaging advances', 'sv', 'Industrisymposium: framsteg inom medicinsk bildgivning'),
   jsonb_build_object('en', 'Simulated. Sponsored industry symposium on imaging advances in radiation oncology.', 'sv', 'Simulerad. Sponsrat industrisymposium om framsteg inom medicinsk bildgivning i strålterapi.'),
   jsonb_build_object('en', 'Auditorium East', 'sv', 'Östra auditoriet'), 'Industry', '{}'),
  ('estro-2026-program-closing', 'estro-2026', date '2026-05-19', time '15:00', time '16:00',
   jsonb_build_object('en', 'Closing ceremony', 'sv', 'Avslutningsceremoni'),
   jsonb_build_object('en', 'Simulated. Closing ceremony and awards for ESTRO 2026.', 'sv', 'Simulerad. Avslutningsceremoni och prisutdelning för ESTRO 2026.'),
   jsonb_build_object('en', 'Auditorium North', 'sv', 'Norra auditoriet'), 'Plenary', '{}'),

  ('eha-2026-program-opening-plenary', 'eha-2026', date '2026-06-11', time '09:00', time '10:00',
   jsonb_build_object('en', 'Opening plenary', 'sv', 'Inledande plenarsession'),
   jsonb_build_object('en', 'Simulated. Opening plenary of the EHA2026 congress with keynote lectures on hematology research.', 'sv', 'Simulerad. Inledande plenarsession för EHA2026-kongressen med keynote-föreläsningar om hematologisk forskning.'),
   jsonb_build_object('en', 'Auditorium North', 'sv', 'Norra auditoriet'), 'Plenary', '{}'),
  ('eha-2026-program-symposium', 'eha-2026', date '2026-06-12', time '11:00', time '12:30',
   jsonb_build_object('en', 'Symposium: lymphoid malignancies', 'sv', 'Symposium: lymfoida maligniteter'),
   jsonb_build_object('en', 'Simulated. Multi-presenter symposium on advances in lymphoid malignancy treatment.', 'sv', 'Simulerad. Symposium med flera talare om framsteg inom behandling av lymfoida maligniteter.'),
   jsonb_build_object('en', 'Room 310', 'sv', 'Sal 310'), 'Clinical', '{}'),
  ('eha-2026-program-late-breaker', 'eha-2026', date '2026-06-13', time '14:00', time '15:30',
   jsonb_build_object('en', 'Late-breaking abstracts', 'sv', 'Sena abstracts'),
   jsonb_build_object('en', 'Simulated. Late-breaking abstract session with oral presentations selected for high impact.', 'sv', 'Simulerad. Session för sena abstracts med muntliga presentationer utvalda för hög genomslagskraft.'),
   jsonb_build_object('en', 'Auditorium North', 'sv', 'Norra auditoriet'), 'Late-breaking', '{}'),
  ('eha-2026-program-poster-walks', 'eha-2026', date '2026-06-13', time '12:30', time '14:00',
   jsonb_build_object('en', 'Poster walks', 'sv', 'Guidade postervandringar'),
   jsonb_build_object('en', 'Simulated. Guided poster walks through selected abstracts, with authors present.', 'sv', 'Simulerad. Guidade postervandringar genom utvalda abstracts, med författarna på plats.'),
   jsonb_build_object('en', 'Exhibition Hall', 'sv', 'Utställningshallen'), 'Posters', '{}'),
  ('eha-2026-program-closing', 'eha-2026', date '2026-06-14', time '15:30', time '16:30',
   jsonb_build_object('en', 'Closing ceremony', 'sv', 'Avslutningsceremoni'),
   jsonb_build_object('en', 'Simulated. Closing ceremony with awards and 2027 preview.', 'sv', 'Simulerad. Avslutningsceremoni med prisutdelning och förhandstitt mot 2027.'),
   jsonb_build_object('en', 'Auditorium North', 'sv', 'Norra auditoriet'), 'Plenary', '{}')
on conflict (id) do update set
  day = excluded.day,
  start_time = excluded.start_time,
  end_time = excluded.end_time,
  title = excluded.title,
  description = excluded.description,
  location = excluded.location,
  track = excluded.track,
  speaker_ids = excluded.speaker_ids;

-- Reset seeded Nordbygg exhibitors before re-inserting the scraped
-- catalog. Keeps the seed idempotent across schema reloads.
delete from public.exhibitors
  where event_id = 'nordbygg-2026';

-- Exhibitor descriptions are stored as jsonb { en, sv }. Most rows
-- were scraped in Swedish; some were authored in English. Sub-task
-- agent/tasks/translate-seeded-content-dual-language-04*.md fills in
-- the missing language slot per row. Shared terminology mapping used
-- across the 04N sub-tasks:
--   "supplier of …"               <-> "leverantör av …"
--   "manufacturer of …"           <-> "tillverkare av …"
--   "distributes …"               <-> "distribuerar …"
--   "develops and manufactures …" <-> "utvecklar och tillverkar …"
insert into public.exhibitors (id, event_id, name, booth, description, website, logo) values
  ('nordbygg-2026-exhibitor-136827', 'nordbygg-2026', '4evergreen', 'A12:11', jsonb_build_object('en', 'Vi skapar Cirkulärt vatten för direkt återanvändning och energiåtervinning. Ta tillvara på ditt spillvatten minska din vattenförbrukning med 30% och återvinn upp till 80% av energin i ditt spillvatten. 4evergreen ReLoop gör det möjligt.

Säkert och beprövat med 1000-tals installationer', 'sv', 'Vi skapar Cirkulärt vatten för direkt återanvändning och energiåtervinning. Ta tillvara på ditt spillvatten minska din vattenförbrukning med 30% och återvinn upp till 80% av energin i ditt spillvatten. 4evergreen ReLoop gör det möjligt.

Säkert och beprövat med 1000-tals installationer'), 'https://www.framtidensreningsverk.se', 'assets/images/exhibitors/nordbygg-2026-4evergreen.jpg'),
  ('nordbygg-2026-exhibitor-139384', 'nordbygg-2026', '4PLUS', 'C04:41', jsonb_build_object('en', 'We are a professional factory that produces acoustic panels made out of solid wood.

The acoustic panels made from aspen (Populus) are ideal for fitting on walls and ceilings, rendering northerly elegance and a sense of lightness to residential and public premises.

In development process B-s1,d0 fire-safe acoustic panels with CE-certified  for public spaces.

The aspen wood, used in our products, is originated from the Baltics and has been widely recognized for its light wood shade and low heat conduction ability. Acoustic panel slats are made using finger joint solution and solid wood slats which accordingly improves material stability and ensures responsible use of every wood log.

Experience is our main asset. For 30 years we have learned and understood Aspen wood’s best characteristics and, therefore, have been able to bring out its best value, creating functional and aesthetic solutions for interior and sauna design.', 'sv', 'We are a professional factory that produces acoustic panels made out of solid wood.

The acoustic panels made from aspen (Populus) are ideal for fitting on walls and ceilings, rendering northerly elegance and a sense of lightness to residential and public premises.

In development process B-s1,d0 fire-safe acoustic panels with CE-certified  for public spaces.

The aspen wood, used in our products, is originated from the Baltics and has been widely recognized for its light wood shade and low heat conduction ability. Acoustic panel slats are made using finger joint solution and solid wood slats which accordingly improves material stability and ensures responsible use of every wood log.

Experience is our main asset. For 30 years we have learned and understood Aspen wood’s best characteristics and, therefore, have been able to bring out its best value, creating functional and aesthetic solutions for interior and sauna design.'), 'https://www.4plus.lv', 'assets/images/exhibitors/nordbygg-2026-4plus.jpg'),
  ('nordbygg-2026-exhibitor-139791', 'nordbygg-2026', '5D Konsulterna', 'A22:11', jsonb_build_object('en', '5D Konsulterna digitaliserar erat fastighetsbestånd eller byggprojekt. 5D använder senaste metoderna för tids- och kostnadseffektiv insamling av data med hjälp av tex drönare och laserskanner.', 'sv', '5D Konsulterna digitaliserar erat fastighetsbestånd eller byggprojekt. 5D använder senaste metoderna för tids- och kostnadseffektiv insamling av data med hjälp av tex drönare och laserskanner.'), 'https://www.5dk.se', 'assets/images/exhibitors/nordbygg-2026-5d-konsulterna.jpg'),
  ('nordbygg-2026-exhibitor-138597', 'nordbygg-2026', 'Aalberts hfc B.V.', 'A04:22', jsonb_build_object('en', 'Come and discover our innovative technology in stand A11:38.

For nearly 50 years, Aalberts hydronic flow control – Flamco has been at the forefront of engineering, working with its customers to create tailored solutions for their needs. We develop, produce and sell high-quality components for use in HVAC systems, increasing comfort in residential, commercial and industrial buildings.

Flamco and Comap operate under the Aalberts hydronic flow control umbrella brand and provide innovative and efficient solutions "from source to emitter". Flamco specialises in plant-room technology, including our most sustainable expansion vessels and revolutionary deaerators. Comap offers distribution and emitter technology, such as our multi-skin connection systems and smart thermostats.

We maximise system performance and reduce energy consumption through efficient hydronic design, all over the world.', 'sv', 'Kom och upptäck vår innovativa teknologi i monter A11:38.

I nästan 50 år har Aalberts hydronic flow control - Flamco legat i framkant av ingenjörsteknik och arbetat med sina kunder för att skapa skräddarsydda lösningar för deras behov. Vi utvecklar, producerar och säljer högkvalitativa komponenter för användning i VVS-systemet, vilket ökar komforten i bostäder, kommersiella och industribyggnader.

Flamco och Comap verkar under Aalberts hydronic flow control övergripande varumärke och tillhandahåller innovativa och effektiva lösningar "from source to emitter". Flamco är specialiserat på pannrumsteknik, inklusive våra mest hållbara expansionskärl och revolutionerande avgasare. Comap erbjuder distributions- och emitterteknik, såsom våra multiskin-anslutningssystem och smarta termostater.

Vi maximerar systemets prestanda och minskar energiförbrukningen genom effektiv hydronisk design, över hela världen.'), 'https://flamcogroup.com/se', 'assets/images/exhibitors/nordbygg-2026-aalberts-hfc-b-v.jpg'),
  ('nordbygg-2026-exhibitor-134668', 'nordbygg-2026', 'Aalberts Integrated Piping Systems B.V.', 'A04:22', jsonb_build_object('en', 'Aalberts integrated piping systems develops and manufactures fittings, pipes and valves in various metals for the distribution and control of liquids and gases. Our technology enables our customers to work quickly and reliably in a simple and effective way. The tailored systems are suitable for use in residential, industrial and commercial buildings, among other applications.', 'sv', 'Aalberts integrated piping systems utvecklar och tillverkar kopplingar, rör och ventiler i i olika metaller för distribution och kontroll av vätskor och gaser. Vår teknik gör det möjligt för våra kunder att arbeta snabbt och tillförlitligt på ett enkelt och effektivt vis. De skräddarsydda systemen är lämpliga för användning inom bland annat bostads-, industri- och kommersiella byggnader.'), 'https://www.aalberts-ips.se', 'assets/images/exhibitors/nordbygg-2026-aalberts-integrated-piping-systems-b-v.jpg'),
  ('nordbygg-2026-exhibitor-138461', 'nordbygg-2026', 'AB Dalatimmer', 'C14:72', jsonb_build_object('en', 'Log homes with a unique design, focused on high quality and durability

We are experts in log homes and supply everything from frames to turn-key houses. We work all over Sweden and the surrounding region.', 'sv', 'Timmerhus med unik design, hög kvalitet och hållbarhet i fokus

Vi är experter på timmerhus och levererar allt från stommar till nyckelfärdiga hus. Vi arbetar över hela Sverige med omnejd.'), 'https://www.dalatimmer.se', 'assets/images/exhibitors/nordbygg-2026-ab-dalatimmer.jpg'),
  ('nordbygg-2026-exhibitor-135228', 'nordbygg-2026', 'AB Fromax', 'A07:35', jsonb_build_object('en', 'We offer a range of tools for cutting and bending the most common types of pipe — for example steel, cast iron and copper, with or without insulation, and in a wide range of dimensions. The tools are distributed by leading retailers in the industry. We know that professional users place high demands on their equipment, and our tools are designed to meet the needs of HVAC installers in terms of both quality and precision. It is important to us to maintain a broad range within our product areas, and our goal is that whatever type of pipe a particular job requires, our customers will always be able to find the right FROMAX tool.', 'sv', 'Vi erbjuder en rad olika verktyg för kapning och bockning av de vanligaste typerna av rör exempelvis stål, gjutjärn och koppar med eller utan isolering och i en mängd olika dimensioner. Verktygen distribueras av de ledande återförsäljarna i branschen. Vi vet att professionella användare ställer höga krav på sin utrustning och våra verktyg är konstruerade för att tillmötesgå VVS-installatörers behov, både med avseende på kvalitet och precision. För oss är det viktigt att ha ett brett sortiment inom våra produktområden och vår målsättning är att oavsett vilken typ av rör som krävs för ett visst jobb, så skall våra kunder alltid kunna hitta rätt FROMAX verktyg..'), 'https://www.fromax.com', 'assets/images/exhibitors/nordbygg-2026-ab-fromax.jpg'),
  ('nordbygg-2026-exhibitor-139309', 'nordbygg-2026', 'AB Svensk Värme', 'A07:19', jsonb_build_object('en', 'Svensk Värme is a technology and expertise company with a broad range of products and services within energy solutions for both real estate and industry.

We deliver high-quality products and service offerings for optimisation and energy savings in process industries as well as heating and cooling systems.', 'sv', 'Svensk Värme är ett teknik- och kompetensföretag med ett brett sortiment av produkter och tjänster inom energilösningar för både fastighet och industri.

Vi levererar högkvalitativa produkter och servicetjänster för optimering & energibesparing inom processindustrier samt värme- och kylsystem.'), 'https://www.svenskvarme.com', 'assets/images/exhibitors/nordbygg-2026-ab-svensk-varme.jpg'),
  ('nordbygg-2026-exhibitor-138990', 'nordbygg-2026', 'Abatec Wooden Pools', 'C12:63', null, 'https://abatec-pools.com/en', null),
  ('nordbygg-2026-exhibitor-137214', 'nordbygg-2026', 'ABC Klinkergruppe', 'C06:61', null, 'https://abc-klinker.de', 'assets/images/exhibitors/nordbygg-2026-abc-klinkergruppe.jpg'),
  ('nordbygg-2026-exhibitor-133959', 'nordbygg-2026', 'Abelko Innovation', 'A13:12', jsonb_build_object('en', 'Abelko is a long-term partner in automation, measurement technology and energy efficiency. We develop our own products and also build systems on behalf of our customers — and we have been doing so for more than 50 years!
Our products and solutions are everywhere in your everyday life. They may not be visible, but they make a difference!
They regulate the temperature in the apartment where you live, control the street lighting you pass on your way to work, and ensure that the cradle works properly at the blood donation centre when you make a contribution to humanity. Operating in the background may not make us famous, but we know — and that drives us to constantly develop better and more efficient solutions and products. Together with our local roots, with the entire chain from development to production in Luleå, this makes us a sustainable partner.

World-class support
We dare say we are unique in our commitment and dedication to providing our customers with the best service and support on the market. We always strive to exceed the customer''s expectations through short response times and a world-class customer experience.', 'sv', 'Abelko är en långsiktig partner inom automation, mätteknik och energieffektivisering. Vi utvecklar egna produkter samt utvecklar system på uppdrag av våra kunder - det har vi gjort i över 50 år!
Våra produkter och lösningar finns överallt i din vardag. De kanske inte syns, men de gör skillnad!
De reglerar temperaturen i lägenheten där du bor, styr gatubelysningen som du passerar på väg till jobbet och ser till att vaggan fungerar rätt hos blodgivningen när du gör en insats för mänskligheten. Att verka i det dolda kanske inte gör oss kända, men vi vet – och det driver oss att ständigt utveckla bättre och effektivare lösningar och produkter. Det tillsammans med vår lokala förankring, med hela kedjan från utveckling till produktion i Luleå, gör oss till en hållbar samarbetspartner.

Support i världsklass
Vi vågar påstå att vi är unika med vårt engagemang och vilja när det gäller att erbjuda våra kunder den bästa servicen och supporten på marknaden. Vi vill alltid överträffa kundens förväntningar genom kort responstid och leverera en kundupplevelse i världsklass.'), 'https://www.abelko.se', 'assets/images/exhibitors/nordbygg-2026-abelko-innovation.jpg'),
  ('nordbygg-2026-exhibitor-136785', 'nordbygg-2026', 'ABUS Kransystem / JJ Gruppen / Carlhag', 'B09:20', jsonb_build_object('en', 'ABUS Sverige Gruppen, together with JJ GRUPPEN and CARLHAG, is one of Sweden''s leading suppliers of standardised lifting equipment. Sales and service are handled by independent dealers, where we have around 160 people across roughly 35 locations from Kiruna in the north to Malmö/Kristianstad in the south, of whom about 100 are service technicians. In 2025, the entire ABUS Sverige Gruppen jointly turned over just under SEK 700 million.

 ABUS does all its manufacturing in Germany, at ABUS Kransysteme GmbH. Besides Sweden, ABUS has active sales in just over 55 countries around the world and sporadic sales in another 30 or so countries. Karlstad is home to the head office, training facility and central spare-parts warehouse with around 600 items, where we keep, among other things, around 50 chain hoists between 100 kg and 2 tonnes as well as HB rails for fast delivery of complete systems or rebuilds.', 'sv', 'ABUS Sverige Gruppen, tillsammans med JJ GRUPPEN och CARLHAG, är en av Sveriges ledande leverantörer av standardiserade lyftanordningar. Försäljning och service hanteras av fristående återförsäljare där vi är ca 160 personer fördelat på ca 35 orter från Kiruna i norr till Malmö/Kristianstad i söder, av dessa är ca 100 st servicetekniker. 2025 omsatte hela ABUS Sverige Gruppen gemensamt strax under 700 MSEK.

 ABUS har all sin tillverkning i Tyskland, hos ABUS Kransysteme GmbH. Förutom Sverige så har ABUS aktiv försäljning i drygt 55 länder runtom i världen, sporadisk försäljning i ytterligare dryga 30 länder. I Karlstad återfinns huvudkontor med utbildningsenhet och centralt reservdelslager med ca 600 artiklar där vi bland annat har 50-talet kättingtelfrar mellan 100kg och 2ton samt HB-skenor för snabb leverans av kompletta system alt. ombyggnationer.'), 'https://www.abus-kransystem.se', 'assets/images/exhibitors/nordbygg-2026-abus-kransystem-jj-gruppen-carlhag.jpg'),
  ('nordbygg-2026-exhibitor-139101', 'nordbygg-2026', 'AccuraSee', 'AG:54', jsonb_build_object('en', 'AccuraSee is a BI and analytics platform that pulls data from several different sources to handle invoicing, reporting and financial analysis — fully automatically, around the clock — to show you what you actually make money on.', 'sv', 'AccuraSee är en BI&analys-plattform som hämtar data från flera olika källor för att hantera fakturering, rapportering och ekonomisk analys - helt automatiskt, dygnet runt - för att visa vad du tjänar pengar på.'), 'https://www.accurasee.se', 'assets/images/exhibitors/nordbygg-2026-accurasee.jpg'),
  ('nordbygg-2026-exhibitor-134364', 'nordbygg-2026', 'ACEVE', 'C02:01', jsonb_build_object('en', 'Next One Technology AB has now been renamed Aceve Sverige AB.
In March 2025, Next One Technology AB, together with HVD Group, became Aceve.

This means that Next One Technology AB, with its products Next Project, Accurator, Dox and Next Planning, is now part of a larger group with several companies in construction, installation and property services across Europe.

It also means we have gained more colleagues with extensive knowledge and experience – and together we can keep developing even better solutions for the industry.', 'sv', 'Next One Technology AB heter numera Aceve Sverige AB.
I mars 2025 blev Next One Technology AB tillsammans med HVD Group, Aceve.

Det innebär att Next One Technology AB med produkterna Next Project, Accurator, Dox och Next Planning nu är en del av en större grupp med flera bolag inom bygg, installation och fastighetsservice i Europa.

Det betyder att vi har fått fler kollegor med mycket kunskap och erfarenhet – och tillsammans kan vi fortsätta utveckla ännu bättre lösningar för branschen.'), 'https://next-tech.com/', 'assets/images/exhibitors/nordbygg-2026-aceve.jpg'),
  ('nordbygg-2026-exhibitor-139401', 'nordbygg-2026', 'ACEVE.', 'C01:01', jsonb_build_object('en', 'Aceve brings together Sweden''s leading business systems for the construction and installation industry – Next, Hantverksdata, Rekyl, Accurator, Dox and KlarPris.
Together we have over 50 years of experience and a passion for developing solutions that strengthen profitability and simplify everyday work for our customers.', 'sv', 'Aceve samlar Sveriges ledande affärssystem för bygg- och installationsbranschen – Next, Hantverksdata, Rekyl, Accurator, Dox och KlarPris.
Tillsammans har vi över 50 års erfarenhet och brinner för att utveckla lösningar som stärker lönsamheten och förenklar vardagen för våra kunder.'), 'https://next-tech.com/', 'assets/images/exhibitors/nordbygg-2026-aceve-2.jpg'),
  ('nordbygg-2026-exhibitor-137251', 'nordbygg-2026', 'Ackurat Industriplast AB', 'C08:20', jsonb_build_object('en', 'We develop and manufacture components for a range of different industries. With a broad and well-developed standard product range, we can quickly meet our customers'' needs.

In addition to our standard products, we offer customised solutions within the range — for example alternative material choices, special colours or other adaptations that strengthen function, design and brand.

When requirements go beyond standard, we take it all the way. We develop and produce tooling for fully bespoke solutions, from concept and design to finished part. In that way we ensure optimal function, quality and efficient production – tailored to each customer''s specific requirements.', 'sv', 'Vi utvecklar och tillverkar komponenter för en rad olika industrier. Med ett brett och väl genomarbetat standardsortiment kan vi snabbt möta våra kunders behov.

Utöver våra standardprodukter erbjuder vi kundanpassade lösningar inom ramen för sortimentet – exempelvis alternativa materialval, specialfärger eller andra anpassningar som stärker funktion, design och varumärke.

När behovet går bortom standard tar vi det hela vägen. Vi utvecklar och producerar verktyg för helt kundunika lösningar, från idé och konstruktion till färdig detalj. På så sätt säkerställer vi optimal funktion, kvalitet och effektiv produktion – anpassad efter varje kunds specifika krav.'), 'https://www.ackurat.se', 'assets/images/exhibitors/nordbygg-2026-ackurat-industriplast-ab.jpg'),
  ('nordbygg-2026-exhibitor-136478', 'nordbygg-2026', 'ACP AB', 'A18:20', null, 'https://www.acp.se', null),
  ('nordbygg-2026-exhibitor-134550', 'nordbygg-2026', 'ACSS Sanitet och Inredning AB', 'A09:04', jsonb_build_object('en', 'ACSS Sanitet – For public environments!
We sell sanitary fittings and systems with a focus on quality and function for public environments such as sports halls, swimming pools and gyms. Our modern and smart electronic system is also a very good fit for psychiatric and correctional care. What our products have in common is that they are self-closing and very durable.', 'sv', 'ACSS Sanitet - För publik miljö!
Vi säljer sanitetsarmaturer och system med fokus på kvalitet och funktion för publika miljöer som sport-, simhallar och gym. Vårt moderna och smarta elektroniska system passar också väldigt bra för psykiatri- och kriminalvården. Gemensamt för våra produkter är att det är självstängande och mycket tåliga.'), 'https://www.acss-sanitet.se', 'assets/images/exhibitors/nordbygg-2026-acss-sanitet-och-inredning-ab.jpg'),
  ('nordbygg-2026-exhibitor-134767', 'nordbygg-2026', 'Acticon AB', 'A13:14', null, 'https://www.acticon.se', 'assets/images/exhibitors/nordbygg-2026-acticon-ab.jpg'),
  ('nordbygg-2026-exhibitor-139281', 'nordbygg-2026', 'ADT', 'A22:28', jsonb_build_object('en', 'Flexoduct markets flexible ventilation ducting and fans for homes, industry and residential buildings.

Prana manufactures and markets the Mini-FTX

Elicent makes ventilation solutions for residential buildings, bathrooms, basements, air and heat movers, heating products and hygiene appliances.

Dynair manufactures industrial fans, smoke-extraction fans and ATEX fans', 'sv', 'Flexoduct marknadsför flexibla ventilationskanaler samt fläktar för hem, industri och bostäder.

Prana tillverkar och marknadsför Mini-FTX

Elicent gör ventilationslösningar för bostäder, badrum, källare, luft och värmeflyttare, värmeprodukter samt hygien apparater.

Dynair tillverkar industri fläktar, rökgasfläktar samt ATEX fläktar'), 'https://www.flexoduct.se', 'assets/images/exhibitors/nordbygg-2026-adt.jpg'),
  ('nordbygg-2026-exhibitor-140015', 'nordbygg-2026', 'AEGIR TECHNOLOGY', 'A13:36', jsonb_build_object('en', 'Did you know that biofilm is the biggest cause of inefficiency, corrosion and operational problems in waterborne systems?

Aegir Technology has the solution. Using our technology we create nanobubbles directly in the system that break down biofilm, break down deposits and optimise performance – completely without chemicals.

The result? Lower energy costs, fewer operational disruptions and a longer service life for the entire installation.

Aegir Impulse = smarter water treatment for tomorrow''s properties.', 'sv', 'Visste du att biofilm är den största orsaken till ineffektivitet, korrosion och driftproblem i vattenburna system?

Aegir Technology har lösningen. Med vår teknik skapar vi nanobubblor direkt i systemet som bryter ned biofilm, bryter ned beläggningar och optimerar prestandan – helt utan kemikalier.

Resultatet? Lägre energikostnader, färre driftstörningar och längre livslängd på hela anläggningen.

Aegir Impulse = smartare vattenbehandling för framtidens fastigheter.'), 'https://www.aegirtechnology.com', 'assets/images/exhibitors/nordbygg-2026-aegir-technology.jpg'),
  ('nordbygg-2026-exhibitor-138985', 'nordbygg-2026', 'Aeroseal Sweden AB', 'A20:36', null, 'https://www.aerosealsweden.se', null),
  ('nordbygg-2026-exhibitor-139442', 'nordbygg-2026', 'Agrob Buchtal Solar Ceramics GmbH', 'C02:51', jsonb_build_object('en', 'Decades of experience guarantee high-quality solutions for demanding pool environments. Innovative Hytect technology enables easy cleaning, offers antibacterial properties and actively reduces airborne pollutants. Safety is enhanced by graduated slip resistance, certified by the GRIP label. A wide range of colours, formats and bespoke options offers maximum design freedom. Special pool coping systems meet a wide range of functional requirements and are complemented by perfectly matched accessories, resulting in complete solutions from a single source. The result is an efficient, durable solution for pools of all types and sizes – with outstanding durability even in salt water and sulphurous thermal environments. The architect service, available on request, supports the project from concept to implementation, reducing complexity and saving valuable planning time.', 'sv', 'Decennier av erfarenhet garanterar högkvalitativa lösningar för krävande poolmiljöer. Innovativ Hytect-teknologi möjliggör enkel rengöring, erbjuder antibakteriella egenskaper och minskar aktivt luftburna föroreningar. Säkerheten förstärks av graderat halkmotstånd, certifierat enligt GRIP-märkningen. Ett brett utbud av färger, format och anpassade alternativ ger maximal designfrihet. Speciella system för poolkanter möter ett brett spektrum av funktionskrav och kompletteras med perfekt matchande tillbehör, vilket resulterar i kompletta lösningar från en och samma leverantör. Resultatet är en effektiv och hållbar lösning för pooler av alla typer och storlekar – med enastående hållbarhet även i saltvatten och svavelhaltiga termalmiljöer. Arkitekttjänsten, som erbjuds på begäran, stödjer projektet från koncept till genomförande, minskar komplexiteten och sparar värdefull projekteringstid.'), 'https://agrob-buchtal.de/en', 'assets/images/exhibitors/nordbygg-2026-agrob-buchtal-solar-ceramics-gmbh.jpg'),
  ('nordbygg-2026-exhibitor-139540', 'nordbygg-2026', 'Ahlsell Sverige AB', 'AG:03', jsonb_build_object('en', 'Ahlsell is there where people live, work and lead their lives. We drive the development of society together with the professionals who manufacture, install, build, repair and maintain.

With a broad range of products and services, our specialist knowledge and our world-class logistics, we make life easier for the pros.', 'sv', 'Ahlsell finns där människor bor, arbetar och lever sina liv. Vi driver utvecklingen av samhället tillsammans med proffs som tillverkar, installerar, bygger, reparerar och underhåller.

Med ett brett sortiment av produkter och tjänster, vår specialistkunskap och med logistik i världsklass gör vi det enklare att vara proffs.'), 'https://www.ahlsell.se', 'assets/images/exhibitors/nordbygg-2026-ahlsell-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-134817', 'nordbygg-2026', 'Aircoil AB', 'A18:18', jsonb_build_object('en', 'At Aircoil we have the Nordics'' broadest range of coils, dry coolers, fan coil units and other heat-exchange products to match your needs. As your own expert in cooling, heating and ventilation, we are with you all the way, in warm and cool.', 'sv', 'Vi på Aircoil har Nordens bredaste utbud av batterier, kylmedelkylare, fläktkonvektorer och andra värmeväxlande produkter för att matcha dina behov. Som din egen expert på kyla, värme och ventilation är vi med dig hela vägen, in warm and cool.'), 'https://www.aircoil.se', 'assets/images/exhibitors/nordbygg-2026-aircoil-ab.jpg'),
  ('nordbygg-2026-exhibitor-134819', 'nordbygg-2026', 'Airfi Oy', 'A14:19', jsonb_build_object('en', 'Airfi is a Finnish technology company specialising in the design and manufacture of modern, energy-efficient and intelligent ventilation units, as well as innovative kitchen hoods that actively control indoor ventilation.

Airfi''s solutions are developed for both residential and commercial buildings, where user comfort, high indoor air quality and measurable energy savings are critical. The systems use advanced AI-based algorithms that automatically optimise operation based on the building''s actual real-time conditions. Airfi''s patented, self-learning AFPS frost protection system enables efficient heat recovery without the need for pre-heaters, even in demanding Nordic climates. Airfi''s systems offer both mobile control and control via the kitchen hood for smooth and convenient use.

The company has been awarded the Key Flag, which highlights Finnish design and manufacturing.', 'sv', 'Airfi är ett finskt teknologiföretag som specialiserar sig på design och tillverkning av moderna, energieffektiva och intelligenta ventilationsaggregat samt innovativa kökskåpor som aktivt styr inomhusventilationen.

Airfis lösningar är utvecklade för både bostads- och kommersiella byggnader, där användarkomfort, hög inomhusluftkvalitet och mätbara energibesparingar är avgörande. Systemen använder avancerade AI-baserade algoritmer som automatiskt optimerar driften utifrån byggnadens verkliga förhållanden i realtid. Airfis patenterade, självlärande AFPS-frostskyddssystem möjliggör effektiv värmeåtervinning utan behov av förvärmare, även i krävande nordiska klimat. Airfis system erbjuder både mobilstyrning och styrning via kökskåpan för en smidig och bekväm användning.

Företaget har tilldelats Nyckelflaggan, som framhäver finsk design och tillverkning.'), 'https://airfi.fi/en/', 'assets/images/exhibitors/nordbygg-2026-airfi-oy.jpg'),
  ('nordbygg-2026-exhibitor-139335', 'nordbygg-2026', 'Airios', 'AG:86', jsonb_build_object('en', 'We are THE OEM controller specialists and develop and produce (custom-made) electronics and software for ventilation and heating systems.
Key words: Modularity, RF, wired bus, BLE, WiFi, Installer app, basic and extended boards, configurable.
Brands we will feature
Airios, IVY', 'sv', 'Vi är OEM-styrspecialisterna och utvecklar och tillverkar (kundanpassad) elektronik och programvara för ventilations- och värmesystem.
Nyckelord: Modularitet, RF, trådbunden buss, BLE, WiFi, installatörsapp, bas- och utökade kort, konfigurerbara.
Varumärken vi visar upp
Airios, IVY'), 'https://www.airios.eu', 'assets/images/exhibitors/nordbygg-2026-airios.jpg'),
  ('nordbygg-2026-exhibitor-137338', 'nordbygg-2026', 'AJ Produkter AB', 'C02:30', jsonb_build_object('en', 'A complete supplier for better workplaces

AJ Produkter designs work environments where people thrive. With a focus on innovation, in-house designed products and three of our own factories, we create smart workplace solutions for our times. And with operations in 20 countries, we contribute every year to improving the work environment in more than half a million workplaces across Europe.

The range consists of furniture, equipment and interior solutions that make going to work more enjoyable. In total, nearly 15,000 products for offices, schools, warehouses, industry and changing rooms – all easily accessible via e-commerce, catalogue, customised projects or a phone call to one of our salespeople.

Everything you need for warehouse and workshop

At AJ Produkter we have a very large selection of everything you might need for any industrial workplace, from warehouses and distribution centres to workshops, garages and manufacturing facilities. Whether you need tool kits, a workbench, a trolley, a lift table or waste containers. Maybe you need a machine skate with a 6,000 kg capacity or a complete fit-out for warehouse and industry. We want you to – and you can – find everything you need with us. Below you will find a bit more about parts of our range!

Warehouse fittings

In our range of warehouse fittings you will find options for businesses of all sizes, from small storage rooms to really large warehouse buildings. Our Ultimate pallet racking, for example, is a space-efficient system for efficient solutions, world class. The series includes classic pallet racking but also practical and easy cable-drum hangers for easy access in a small footprint. We also believe shelving systems should be easy to extend, so we have add-on sections to bolt onto existing warehouse shelves.

Workshop fittings

We have all the fit-out you need for an efficient workshop. Tailor your workshop or production to your needs with hard-wearing, high-quality workshop fittings from AJ Produkter. We have a large selection of metal cabinets, tool trolleys & unexpectedly much more. Don''t hesitate to contact our customer service if you have any questions or thoughts.

Cabinet storage

Whether you need tool cabinets for general storage of things you use every day, a lockable storage cabinet or a complete machine cabinet equipped with absolutely everything you need, you will find a wide selection with us. Storage should be efficient and flexible so that staff don''t have to spend unnecessary time searching shelves and drawers. Many of AJ Produkter''s cabinets also have electronic code locks, which makes keys completely unnecessary – one less thing to keep track of!

Environment and recycling

In industry it is very important that you and your staff have a safe and clean workplace, especially if you work with chemicals and substances that can be hazardous. A solid wet-and-dry vacuum cleaner is something every industrial workplace should have, but depending on your needs we provide a wide range of further practical products. Absorbent kits, spill trays and chemical cabinets are some of them! You can read more about our range by clicking on the various categories and product specifications, or contact us and we''ll be happy to help!

Project sales

We also like working closely with our customers to create the best possible interior solution together. For example, through our project sales, where we lead interior projects and support our customers all the way – from vision to reality. Our project salespeople are happy to visit you on site and help with measuring, layout and smart, ergonomic and space-saving solutions for your business. We supply a wide range of guards and accessories to tailor and optimise your warehouse for your needs.', 'sv', 'En helhetsleverantör för bättre arbetsplatser

AJ Produkter utformar arbetsmiljöer där människor mår bra. Med fokus på innovation, egendesignade produkter och tre egna fabriker skapar vi smarta lösningar för arbetsplatsen i tiden. Och med verksamhet i 20 länder, bidrar vi årligen till att förbättra arbetsmiljön på mer än en halv miljon arbetsplatser Europa runt.

Sortimentet består av möbler, utrustning och inredningslösningar som gör det roligare att gå till jobbet. Totalt närmare 15 000 produkter för kontor, skola, lager, industri och omklädningsrum – allt lättillgängligt via e-handel, katalog, kundanpassade projekt eller ett samtal till någon av våra säljare.

Allt du behöver för lager och verkstad

På AJ Produkter har vi ett väldigt stort utbud av allt du kan tänkas behöva till alla industriella arbetsplatser, från lager och distributionscenter till verkstad, garage och tillverkningsanläggning. Vare sig du är ute efter verktygssatser, arbetsbänk, vagn, lyftbord eller avfallsbehållare. Kanske behöver du en maskinskridsko med kapacitet på 6000 kg eller en hel inredning för lager och industri. Vi vill att du ska, och du kan, hitta allt du behöver hos oss. Nedan hittar du lite mer om delar av vårt sortiment!

Lagerinredning

I vårt utbud av lagerinredning finner du alternativ för alla storlekar av verksamheter, från små lagerrum till riktigt stora lagerbyggnader. Vårt Ultimate pallställ är exempelvis ett platseffektivt system för effektiva lösningar, i världsklass. I serien har vi klassiska pallställ men också praktisk och smidig kabeltrumsupphängning för lätt åtkomst på liten yta. Vi tycker också att det ska vara lätt att bygga ut hyllsystem så vi har påbyggnadssektioner att addera till existerande lagerhyllor.

Verkstadsinredning

Vi har all inredning som behövs för en effektiv verkstad. Anpassa verkstaden eller produktionen efter dina behov med stryktålig och kvalitativ verkstadsinredning från AJ Produkter. Vi har ett stort utbud av plåtskåp, verktygsvagnar & oväntat mycket mer. Tveka inte att kontakta vår kundservice om du har några frågor eller funderingar.

Skåpförvaring

Vare sig du behöver verktygsskåp för allmän förvaring för saker du använder varje dag, ett låsbart förvaringsskåp eller komplett maskinskåp utrustat med precis allting du behöver, då har du ett brett utbud hos oss. Förvaring ska vara effektivt och flexibelt så inte personal behöver lägga onödig tid på att leta igenom hyllor och lådor i onödan. Många av AJ Produkter skåp har dessutom fått elektroniska kodlås vilket gör att nycklar blir helt onödiga – en sak mindre att hålla reda på!

Miljö och återvinning

Inom industri är det väldigt viktigt att du och personal har en säker och ren arbetsplats, särskilt om ni arbetar med kemikalier och anfall som kan vara farligt. En rejäl våt- och torrdammsugare bör varje industriell arbetsplats ha, men beroende på behov tillhandahåller vi ett brett sortiment av fler praktiska produkter. Absorbentpaket, spillbassäng och kemikalieskåp är några! Du kan läsa mer om vårt utbud genom att klicka på de olika kategorierna och produkters specifikation, eller kontakta oss så hjälper vi dig gärna!

Projektförsäljning

Dessutom jobbar vi gärna nära kunderna för att i samverkan skapa bästa möjliga inredningslösning. Bland annat genom vår projektförsäljning där vi leder inredningsprojekt och stöttar kunderna hela vägen – från vision till verklighet. Våra projektsäljare besöker gärna er på plats och hjälper till med mätning, utformning och smarta, ergonomiska och platsbesparande lösningar för er verksamhet. Vi tillhandahåller en mängd olika skydd och tillbehör för att skräddarsy och optimera ert lager efter era behov.'), 'https://www.ajprodukter.se', 'assets/images/exhibitors/nordbygg-2026-aj-produkter-ab.jpg'),
  ('nordbygg-2026-exhibitor-137980', 'nordbygg-2026', 'Ajab Smide AB', 'C15:51', jsonb_build_object('en', 'Welcome to C15:51 and meet us from Ajab!

Here you can explore solutions for tailored, energy-efficient gates as well as our ground anchor.

Since our start nearly 40 years ago, we have specialised in various forms of folding gates, doors, gates and stairs for industry, agriculture and private customers.

Swedish, innovative and sustainable – at the stand you will meet, in addition to us, some of the other companies that are part of the Weland Group. A warm welcome!', 'sv', 'Välkommen till C15:51 och möt oss från Ajab!

Här kan du utforska lösningar för kundanpassade och energieffektiva portar samt vårt jordankare.

Vi har sedan starten för snart 40 år sedan, specialiserat oss på olika former av vikportar, dörrar, grindar och trappor till industri, lantbruk och privatpersoner.

Svenskt, innovativt och hållbart – i montern möter du, förutom oss, även några av de andra företagen som ingår i Welandkoncernen. Varmt välkommen!'), 'https://www.ajabs.se', 'assets/images/exhibitors/nordbygg-2026-ajab-smide-ab.jpg'),
  ('nordbygg-2026-exhibitor-139509', 'nordbygg-2026', 'Aktive Rev.Ops', 'BG:07', jsonb_build_object('en', 'We help Built environment related software and expert companies to grow their business in the Nordics. Software and service buyers we help to identify and test solutions that are suitable for their needs. We bridge the gap between selling and buying.', 'sv', 'Vi hjälper mjukvaru- och expertföretag inom den byggda miljön att växa sin verksamhet i Norden. Köpare av programvara och tjänster hjälper vi att identifiera och testa lösningar som passar deras behov. Vi överbryggar gapet mellan säljare och köpare.'), 'https://www.aktive.fi', 'assets/images/exhibitors/nordbygg-2026-aktive-rev-ops.jpg'),
  ('nordbygg-2026-exhibitor-137905', 'nordbygg-2026', 'Alab Aluman AB', 'C11:33', jsonb_build_object('en', 'We will present and demonstrate our in-house manufactured, project-tailored solutions in aluminium.
Our own profile system with doors and windows for those who build walls in panels. Our trim-forming products significantly reduce your installation time.
On top of that, we are exhibiting our balcony glazings with frameless folding glass doors and an integrated railing. Alab is a member of the Balkongföreningen.
Made in Norrland for more than 50 years!
Good to see you!', 'sv', 'Vi kommer presentera och demonstrera våra egentillverkade projektanpassade lösningar i aluminium.
Vårt eget profilsystem med dörrar och fönster till dig som bygger väggar i paneler. Våra foderbildande produkter förkortar avsevärt er monteringstid.
Ytterligare så ställer vi ut våra balkonginglasningar med ramfria vikbara glasluckor med integrerat räcke. Alab är medlem i Balkongföreningen.
Made in Norrland sedan mer än 50 år!
Väl mött hörrni!'), 'https://www.alab.com', 'assets/images/exhibitors/nordbygg-2026-alab-aluman-ab.jpg'),
  ('nordbygg-2026-exhibitor-138441', 'nordbygg-2026', 'AllToa AB', 'EÖ:36', jsonb_build_object('en', 'Toilets for public outdoor environments

Work entirely without water, sewer, electricity, composting bedding or chemicals,

Only sun and wind required', 'sv', 'Toaletter i offentlig utemiljö

Fungerar helt utan vatten, avlopp, el, kompostströ eller kemikalier,

Endast sol och vind krävs'), 'https://www.alltoa.se', 'assets/images/exhibitors/nordbygg-2026-alltoa-ab.jpg'),
  ('nordbygg-2026-exhibitor-136315', 'nordbygg-2026', 'Altech', 'A12:10', jsonb_build_object('en', 'ALTECH – CAREFULLY SELECTED PRODUCTS FOR A SUSTAINABLE HVAC INSTALLATION

Altech offers one of Sweden''s broadest product ranges for technical installations. We have products for installation needs in HVAC, industry, refrigeration and property. Our range covers products for installations for tap water, heating, gas and drainage. Functions with many critical steps where quality is decisive.

We offer our customers and other actors in the construction process an efficient and reliable workflow. When you work with us, you have direct access to comprehensive product information, and the range is also available via design tools such as Magicad and BIMobjects.

Aside from on the web, our range is available in around eighty stores across the country and for immediate delivery from the central warehouse direct to the worksite.', 'sv', 'ALTECH – NOGA UTVALDA PRODUKTER FÖR EN HÅLLBAR VVS-INSTALLATION

Altech erbjuder ett av Sveriges bredaste produktsortiment för tekniska installationer. Här finns produkter för installationsbehov inom vvs, industri, kyla och fastighet. Vårt sortiment omfattar produkter inom installationer för tappvatten, värme, gas och avlopp. Funktioner som har många kritiska moment där kvaliteten är avgörande.

Vi erbjuder våra kunder och övriga aktörer i byggprocessen en effektiv och trygg arbetsprocess. När du arbetar med oss har du direkt tillgång till heltäckande produktinformation, och sortimentet finns även åtkomligt via projekteringsverktyg såsom Magicad och BIMobjects.

Förutom på webben finns vårt sortiment i ett åttiotal butiker över hela landet samt för omgående leverans från centrallagret direkt till arbetsplatsen.'), 'https://altech.se/', 'assets/images/exhibitors/nordbygg-2026-altech.jpg'),
  ('nordbygg-2026-exhibitor-136314', 'nordbygg-2026', 'Alterna Badrum', 'A08:12', jsonb_build_object('en', 'Alterna is one of Europe''s leading brands, with a complete bathroom range. Developed to meet the demands of both everyday life and projects.

With a focus on sustainability, function and long service life, we offer products and solutions adapted for tomorrow''s bathrooms. As the wave of pipe-system replacements accelerates in Sweden, we see a clear need for smart, standardised and reliable solutions.

At Nordbygg we will show how Alterna, with Aqua as the foundation, can contribute to more sustainable pipe replacements – with fewer changes, longer service life and easier installation.

Welcome to our stand to discuss how, together, we can take the next step in the project market', 'sv', 'Alterna är ett av Europas ledande varumärken, med ett komplett badrumssortiment.  Utvecklat för att möta kraven i både vardag och projekt.

Med fokus på hållbarhet, funktion och lång livslängd erbjuder vi produkter och lösningar som är anpassade för framtidens badrum. I takt med den ökande stambytesvågen i Sverige ser vi ett tydligt behov av smarta, standardiserade och trygga lösningar.

På Nordbygg visar vi hur Alterna, med Aqua som grund, kan bidra till mer hållbara stambyten – med färre byten, längre livslängd och enklare installation.

Välkommen till vår monter för att diskutera hur vi tillsammans kan ta nästa steg i projektmarknaden'), 'https://www.alternabadrum.se', 'assets/images/exhibitors/nordbygg-2026-alterna-badrum.jpg'),
  ('nordbygg-2026-exhibitor-139629', 'nordbygg-2026', 'Altrad', 'B11:21', null, 'https://www.altradhireandsales.com/en-se', 'assets/images/exhibitors/nordbygg-2026-altrad.jpg'),
  ('nordbygg-2026-exhibitor-134028', 'nordbygg-2026', 'Aluflam Group', 'C08:33', jsonb_build_object('en', 'Aluflam Group is an international company specializing in advanced aluminium solutions for demanding architectural and industrial applications. With headquarters in Denmark and activities in more than 10 countries worldwide, the group combines Scandinavian engineering with global manufacturing and project experience.
The company operates across three core business segments:
Construction
The Construction segment focuses on high-performance aluminium systems for the building industry. Aluflam develops and supplies fire-rated and non-fire-rated glazing systems, including facades, doors, windows, and partition solutions. These systems are used in commercial buildings, infrastructure, and architectural projects where safety, aesthetics, and durability are essential.
Marine & Offshore
Within the Marine & Offshore sector, Aluflam delivers specialized aluminium solutions designed to meet strict maritime and offshore requirements. The systems are engineered for fire safety, strength, and corrosion resistance, making them suitable for cruise ships, ferries, naval vessels, offshore platforms, and energy installations.
Extrusion
The Extrusion segment provides custom aluminium extrusion profiles for a wide range of industries. With advanced production capabilities and close collaboration with customers, Aluflam develops tailored profile solutions that support both the group’s internal systems and external industrial partners.
With approximately 300 employees worldwide, Aluflam Group combines engineering expertise, international manufacturing, and project-driven innovation to deliver reliable aluminium solutions for construction, maritime, and industrial applications.', 'sv', 'Aluflam Group är ett internationellt företag som är specialiserat på avancerade aluminiumlösningar för krävande arkitektoniska och industriella tillämpningar. Med huvudkontor i Danmark och verksamhet i mer än tio länder över hela världen kombinerar koncernen skandinavisk ingenjörskonst med global tillverkning och projekterfarenhet.
Företaget verkar inom tre kärnaffärsområden:
Bygg
Byggsegmentet fokuserar på högpresterande aluminiumsystem för byggindustrin. Aluflam utvecklar och levererar brandklassade och icke brandklassade glassystem, inklusive fasader, dörrar, fönster och partilösningar. Systemen används i kommersiella byggnader, infrastruktur och arkitektoniska projekt där säkerhet, estetik och hållbarhet är avgörande.
Marin & Offshore
Inom segmentet Marin & Offshore levererar Aluflam specialiserade aluminiumlösningar utformade för att möta strikta krav inom sjöfart och offshore. Systemen är konstruerade för brandsäkerhet, hållfasthet och korrosionsbeständighet, vilket gör dem lämpliga för kryssningsfartyg, färjor, marinfartyg, offshoreplattformar och energianläggningar.
Extrudering
Extruderingssegmentet tillhandahåller kundanpassade aluminiumextruderprofiler för ett brett urval av branscher. Med avancerad produktionskapacitet och nära samarbete med kunderna utvecklar Aluflam skräddarsydda profillösningar som stödjer både koncernens interna system och externa industripartners.
Med cirka 300 medarbetare världen över kombinerar Aluflam Group ingenjörsexpertis, internationell tillverkning och projektdriven innovation för att leverera tillförlitliga aluminiumlösningar för bygg, sjöfart och industri.'), 'https://aluflam.com', 'assets/images/exhibitors/nordbygg-2026-aluflam-group.jpg'),
  ('nordbygg-2026-exhibitor-139754', 'nordbygg-2026', 'Alumeco Sverige AB', 'C15:23', jsonb_build_object('en', 'Alumeco offers an exciting spectrum of roof and facade materials. Choose between different versions of sheet metal in aluminium or copper, as well as aluminium composite panels from Stacbond. Stacbond gets you to think outside the given frames and see new opportunities in the appearance and function of the facade. For Alumeco no project is too big or too small – we are always ready to assist you with our expertise. We give every project our undivided attention and we welcome partnerships with you as an architect, designer, developer or facade contractor.', 'sv', 'Alumeco erbjuder ett spännande spektrum av tak- och fasadmaterial. Välj mellan olika varianter av plåt i aluminium eller koppar samt aluminiumkompositskivor från Stacbond. Stacbond får dig att tänka utanför givna ramar och se nya möjligheter i fasadens utseende och funktion. För Alumeco är inget projekt för stort eller för litet – vi står alltid redo att bistå dig med vår kunskap. Vi ger varje projekt vår odelade uppmärksamhet och vi välkomnar samarbeten med dig som är arkitekt, formgivare, byggherre eller fasadentreprenör.'), 'https://www.alumeco.se', 'assets/images/exhibitors/nordbygg-2026-alumeco-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-133971', 'nordbygg-2026', 'Aluscand AB', 'C12:41', null, 'https://www.aluscand.se', 'assets/images/exhibitors/nordbygg-2026-aluscand-ab.jpg'),
  ('nordbygg-2026-exhibitor-137627', 'nordbygg-2026', 'Alutrade AB', 'C17:22', jsonb_build_object('en', 'Alutrade is a complete supplier of aluminium profiles to Swedish industry. We are based in Växjö and today have 40 employees. Whether for special profiles or standard profiles, we have the experience and know-how to provide our customers with the optimal solution. We have over 40 years of experience with everything related to aluminium profiles.

We stock customer-specific profiles for call-off and handle machining and logistics to the desired extent. We want to work closely with our customers and be there for the entire journey with our specialist expertise. Our strength lies in our ability to deliver further-processed special profiles on competitive terms, regardless of volume and complexity.

From being a pure trader, Alutrade today is a complete partner with the ambition, capability and competence to contribute throughout the process from product idea to finished component.

We work wholeheartedly by our core values – commitment, strong customer focus, respect, honesty and competence.

Our vision is to become "the Nordics'' best complete supplier of aluminium".', 'sv', 'Alutrade är en komplett leverantör av aluminiumprofiler till svensk industri. Vi finns i Växjö och är idag 40 medarbetare. Oavsett om det gäller specialprofiler eller standardprofiler så har vi den erfarenhet och det kunnande som ger våra kunder en optimal lösning. Vi har över 40 års erfarenhet av allt som rör aluminiumprofiler.

Vi lagerhåller kundspecifika profiler för avrop och ombesörjer bearbetning och logistik i önskad omfattning. Vi vill arbeta nära våra kunder och finnas med genom hela resan med med vårt specialistkunnande. Vår styrka ligger i vår förmåga att leverera vidareförädlade specialprofiler till konkurrenskraftiga villkor, helt oberoende av volym och svårighetsgrad.

Från att ha varit en renodlad trader är Alutrade idag en komplett samarbetspartner med ambition, förmåga och kompetens att bidra i hela processen från produktidé till färdig komponent.

Vi arbetar helhjärtat efter våra grundvärderingar – engagemang, stort kundfokus, respekt och ärlighet samt kompetens.

Vår vision är att bli "Nordens bästa kompletta leverantör av aluminium".'), 'https://www.alutrade.se', 'assets/images/exhibitors/nordbygg-2026-alutrade-ab.jpg'),
  ('nordbygg-2026-exhibitor-139389', 'nordbygg-2026', 'AM ENERGY', 'C04:41', null, 'https://www.ecoterrace.eu', 'assets/images/exhibitors/nordbygg-2026-am-energy.jpg'),
  ('nordbygg-2026-exhibitor-137088', 'nordbygg-2026', 'Ambiductor AB', 'A11:28', jsonb_build_object('en', 'A supplier of energy meters, water meters and sensors within Internet-of-Things. Makes meter data collection easy through the AmbiSolution software platform.', 'sv', 'En leverantör av energimätare, vattenmätare samt sensorer inom Internet-of-Things. Gör mätinsamling enkel genom mjukvaruplattformen AmbiSolution.'), 'https://www.ambiductor.se', 'assets/images/exhibitors/nordbygg-2026-ambiductor-ab.jpg'),
  ('nordbygg-2026-exhibitor-134546', 'nordbygg-2026', 'Amiga AB', 'B11:20', jsonb_build_object('en', 'AMIGA – Passion. Innovation. Sustainability. POWER YOU.

Our goal is to contribute to a more efficient, safe and circular construction and industrial sector where projects keep on schedule, on budget and on quality.
Our way of thinking holistically and sustainably, combined with 25 years of experience, makes us a powerful change-maker. With knowledge and products, we deliver complete solutions that simplify life for our customers and give them the power to succeed.

Our four business areas show how we make a difference in practice

AMIGA REuse – Circular solutions for temporary power.
Save Energy – Lighting and controls that save energy and money.
AMIGA Control – Wireless metering and monitoring.
AMIGA REcharge – Charging solutions for an electrified future.

We give you the power to change.', 'sv', 'AMIGA – Passion. Innovation. Hållbarhet. POWER YOU.

Vårt mål är att bidra till en mer effektiv, trygg och cirkulär bygg- och industribransch där projekten håller tidplan, budget och kvalitet.
Vårt sätt att tänka helhet och hållbarhet, i kombination med 25 års erfarenhet, gör oss till en kraftfull förändrare. Med kunskap och produkter levererar vi helhetslösningar som förenklar för våra kunder och ger dem kraften att lyckas.

Våra fyra affärsområden visar hur vi gör skillnad i praktiken

AMIGA REuse – Cirkulära lösningar för tillfällig el.
Save Energy – Belysning och styrning som sparar energi och pengar.
AMIGA Control – Trådlös mätning och övervakning.
AMIGA REcharge – Laddlösningar för en elektrifierad framtid.

Vi ger dig kraften att förändra.'), 'https://www.amigaab.se', 'assets/images/exhibitors/nordbygg-2026-amiga-ab.jpg'),
  ('nordbygg-2026-exhibitor-134784', 'nordbygg-2026', 'Anolytech', 'A06:22', jsonb_build_object('en', 'Anolytech offers a revolutionary solution with AnoDes – a sustainable alternative produced directly on site using only water, salt and electricity. AnoDes provides continuous disinfection, eliminates bacteria and prevents biofilm growth, ensuring bacteria-free water around the clock. Fully compliant with EU standards and with minimal maintenance, Anolytech provides a reliable and effective solution to safeguard the water quality in your operation.', 'sv', 'Anolytech erbjuder en revolutionerande lösning med AnoDes – ett hållbart alternativ som produceras direkt på plats med enbart vatten, salt och el. AnoDes ger kontinuerlig desinfektion, eliminerar bakterier och förhindrar biofilmstillväxt, vilket säkerställer bakteriefritt vatten dygnet runt. Fullt kompatibel med EU-standarder och med minimalt underhåll, ger Anolytech en tillförlitlig och effektiv lösning för att trygga vattenkvaliteten i din verksamhet.'), 'https://www.anolytech.se', 'assets/images/exhibitors/nordbygg-2026-anolytech.jpg'),
  ('nordbygg-2026-exhibitor-139741', 'nordbygg-2026', 'Appfarm', 'AG:53', jsonb_build_object('en', 'Most operations-heavy companies run their critical processes in spreadsheets, through manual routines or in standard systems that don''t quite fit. With Appfarm, you can build exactly the applications your company needs, from field data collection and resource planning to logistics flows and customer portals. Roll out solutions with a high degree of security and scalability – without having to handle the operations and maintenance burden yourselves.', 'sv', 'De flesta verksamhetstunga bolag driver sina kritiska processer i kalkylark, via manuella rutiner eller i standardsystem som inte riktigt passar. Med Appfarm kan ni bygga exakt de applikationer företaget behöver, från datainsamling på fältet och resursplanering till logistikflöden och kundportaler. Rulla ut lösningar med hög grad av säkerhet och skalbarhet – helt utan att själva sitta med drift- och förvaltningsansvaret.'), 'https://appfarm.io', 'assets/images/exhibitors/nordbygg-2026-appfarm.jpg'),
  ('nordbygg-2026-exhibitor-134927', 'nordbygg-2026', 'Aqua Expert AB', 'A10:23', null, 'https://www.aquaexpert.se', null),
  ('nordbygg-2026-exhibitor-139056', 'nordbygg-2026', 'AQUARENT', 'A06:21', jsonb_build_object('en', 'Since 1996, Aquarent has designed and built water treatment plants for the production of clean drinking, household and process water. To safeguard the quality and function of our products, all our development and a large part of our production take place in Sweden. We work hard to continuously develop more efficient filters that consume less water and salt and that are also free of chemicals.', 'sv', 'Aquarent har sedan 1996 konstruerat och byggt vattenreningsanläggningar för framställning av rent dricks-, hushålls- och processvatten. För att säkerställa kvaliteten och funktionen hos våra produkter så sker all vår utveckling och en stor del av vår produktion i Sverige. Vi arbetar hårt för att kontinuerligt ta fram effektivare filter som förbrukar mindre vatten och salt och dessutom är fria från kemikalier.'), 'https://www.aquarent.se', 'assets/images/exhibitors/nordbygg-2026-aquarent.jpg'),
  ('nordbygg-2026-exhibitor-139488', 'nordbygg-2026', 'Arbesko AB', 'B08:20', null, 'https://www.arbesko.se', 'assets/images/exhibitors/nordbygg-2026-arbesko-ab.jpg'),
  ('nordbygg-2026-exhibitor-139709', 'nordbygg-2026', 'Archer Knox AB', 'A20:11', null, 'https://www.archerknox.se', 'assets/images/exhibitors/nordbygg-2026-archer-knox-ab.jpg'),
  ('nordbygg-2026-exhibitor-139219', 'nordbygg-2026', 'Areco', 'C17:51', jsonb_build_object('en', 'Areco Direct is a leading wholesaler in building sheet metal, ventilation and waterproofing membranes, and part of the Areco group. We offer a broad range of building products from our own factories in Malmö and other well-known brands. Our customers include sheet metal workshops, roofers and ventilation contractors. Through our sister company Areco Industry we also offer trading steel and reinforcement. Our focus is on high availability, a broad range and rapid service.', 'sv', 'Areco Direct är en ledande grossist inom byggplåt, ventilation och tätskikt och en del av Areco-koncernen. Vi erbjuder ett brett sortiment av byggprodukter från egna fabriker i Malmö och andra välkända varumärken. Våra kunder inkluderar plåtslagerier, takläggare och ventilationsfirmor. Genom systerbolaget Areco Industry erbjuder vi även handelsstål och armering. Vårt fokus ligger på hög tillgänglighet, brett sortiment och snabb service.'), 'https://www.areco.se', 'assets/images/exhibitors/nordbygg-2026-areco.jpg'),
  ('nordbygg-2026-exhibitor-136756', 'nordbygg-2026', 'ARKITECH ADVANCED CONSTRUCTION TECHNOLOGIES', 'C18:22', jsonb_build_object('en', 'Arkitech Advanced Construction Technologies is a leading supplier of Light Gauge Steel (LGS) technology for the construction and manufacturing industry. Their technology package includes engineering solutions such as LGS framers, design software and on-site training. Since 2012, Arkitech has focused on high-quality, cost-effective and time-efficient solutions.

With over 15 years of experience, they ensure precise and reliable manufacturing processes. Arkitech''s LGS systems offer cost benefits, minimal material waste and accelerate construction timelines, increasing profitability.

Arkitech''s technology is used globally for various applications, including residential, commercial buildings, modular and multi-storey houses as well as prefabricated modules and temporary units. They provide comprehensive, reliable and accurate LGS framers along with the necessary software.', 'sv', 'Arkitech Advanced Construction Technologies är en ledande leverantör av Light Gauge Steel (LGS)-teknologi för bygg- och tillverkningsindustrin. Deras teknologipaket omfattar ingenjörslösningar som LGS-framers, designmjukvara och utbildning på plats. Sedan 2012 har Arkitech fokuserat på högkvalitativa, kostnadseffektiva och tidseffektiva lösningar.

Med över 15 års erfarenhet säkerställer de precisa och tillförlitliga tillverkningsprocesser. Arkitechs LGS-system erbjuder kostnadsfördelar, minimalt materialsvinn och påskyndar byggtiderna, vilket ökar lönsamheten.

Arkitechs teknologi används globalt för olika tillämpningar, inklusive bostäder, kommersiella byggnader, modulära och flervåningshus samt prefabricerade moduler och temporära enheter. De tillhandahåller heltäckande, tillförlitliga och precisa LGS-framers tillsammans med den nödvändiga mjukvaran.'), 'https://www.arkitech.com.tr', 'assets/images/exhibitors/nordbygg-2026-arkitech-advanced-construction-technologies.jpg'),
  ('nordbygg-2026-exhibitor-139279', 'nordbygg-2026', 'ARLANS AB', 'C17:11', jsonb_build_object('en', 'Arlans & POATS
Premium Stainless Steel Sinks
Handcrafted quality • European supply • Best price-performance', 'sv', 'Arlans & POATS
Diskhoar i premium-rostfritt stål
Hantverksmässig kvalitet • Europeisk leverans • Bästa pris/prestanda'), 'https://poats.eu', 'assets/images/exhibitors/nordbygg-2026-arlans-ab.jpg'),
  ('nordbygg-2026-exhibitor-139144', 'nordbygg-2026', 'Armat', 'C17:51', null, 'https://www.arcelormittal.se', null),
  ('nordbygg-2026-exhibitor-136976', 'nordbygg-2026', 'Armatec AB', 'A05:18', jsonb_build_object('en', 'Your partner for the technical challenges of the future.

You have a technical challenge. We have plenty of knowledge and products. Our concepts show how and where we can add value. Every technical solution is tailored to your needs.', 'sv', 'Din partner i framtidens tekniska utmaningar.

Du har en teknisk utmaning. Vi har mängder av kunskap och produkter. Våra koncept visar hur och var vi kan tillföra nytta. Varje teknisk lösning är anpassad efter dina behov.'), 'https://www.armatec.com/sv', 'assets/images/exhibitors/nordbygg-2026-armatec-ab.jpg'),
  ('nordbygg-2026-exhibitor-134829', 'nordbygg-2026', 'Arom-dekor Kemi AB', 'A12:23', null, 'https://www.aromdekor.se', 'assets/images/exhibitors/nordbygg-2026-arom-dekor-kemi-ab.jpg'),
  ('nordbygg-2026-exhibitor-138840', 'nordbygg-2026', 'Arqdesign Byggprodukter', 'C10:30', jsonb_build_object('en', 'Arqdesign are specialists in innovative balcony railings as well as balcony glazings for the Scandinavian market.
All of our manufacturing takes place in Tranås, in the province of Småland, close to our suppliers,
which is a major advantage both for you and for the environment.', 'sv', 'Arqdesign är specialister på innovativa balkongräcken samt balkonginglasningar för den skandinaviska marknaden.
All vår tillverkning sker i småländska Tranås, i närheten av våra leverantörer,
vilket är en stor fördel både för er och miljön.'), 'https://www.arqdesign.se', 'assets/images/exhibitors/nordbygg-2026-arqdesign-byggprodukter.jpg'),
  ('nordbygg-2026-exhibitor-139935', 'nordbygg-2026', 'Arras OÜ', 'C03:51', jsonb_build_object('en', 'Arras OÜ is a privately owned Estonian manufacturer of building fittings and fixing solutions for timber structures, with over 25 years of experience in the industry. We are a reliable and long-term partner for customers across the EU, with a particularly strong presence in the Nordic markets.

Our range includes angle brackets, joist hangers, post bases and other products for timber construction, developed for reliable performance and easy installation. By combining strong production capabilities with a customer-focused approach, we deliver consistent quality, dependable supply and smooth cooperation.

Sustainability is an important part of our operations, and a significant share of our manufacturing energy comes from solar power.', 'sv', 'Arras OÜ är en privatägd estnisk tillverkare av byggbeslag och infästningslösningar för träkonstruktioner, med över 25 års erfarenhet i branschen. Vi är en pålitlig och långsiktig partner för kunder över hela EU, med särskilt stark närvaro i de nordiska marknaderna.

Vårt sortiment omfattar vinkelbeslag, balkskor, stolpskor och andra produkter för träkonstruktion, utvecklade för pålitlig prestanda och enkel installation. Genom att kombinera stark produktionskompetens med ett kundfokuserat arbetssätt levererar vi jämn kvalitet, god leveranssäkerhet och smidigt samarbete.

Hållbarhet är en viktig del av vår verksamhet, och en betydande del av vår tillverkningsenergi kommer från solenergi.'), 'https://www.arrascf.eu', 'assets/images/exhibitors/nordbygg-2026-arras-ou.jpg'),
  ('nordbygg-2026-exhibitor-138251', 'nordbygg-2026', 'Arton:1 Projekt AB', 'C11:41E', jsonb_build_object('en', 'We manufacture and supply complete solutions in steel, glass and fittings.
Arton:1 may be the youngest steel-partition manufacturer in Sweden, but we are proud of our many years of combined competence and experience in fire- and burglary-rated steel partitions with the right protection and function.
We are specialists in the door, glass and fittings in approved combination, while at the same time being solution-oriented in finding ways to meet the customer''s needs – all within the framework of the regulations, of course.', 'sv', 'Vi tillverkar och levererar helhetslösningar med stål, glas och beslag.
Arton:1 må vara det yngsta stålpartitillverkande företaget i Sverige, men vi är stolta över vår mångåriga samlade kompetens och erfarenhet av brand- och inbrottsklassade stålparter med rätt skydd och funktion.
Vi är specialister på dörr, glas och beslag i godkänd kombination samtidigt som vi är lösningsorienterade med att hitta vägar för att möta kundens behov - allt inom ramen för regelverken förstås.'), 'https://www.arton1.se', 'assets/images/exhibitors/nordbygg-2026-arton-1-projekt-ab.jpg'),
  ('nordbygg-2026-exhibitor-139920', 'nordbygg-2026', 'Aru Grupp AS', 'C03:51', null, 'https://www.stair24.com/et', null),
  ('nordbygg-2026-exhibitor-139317', 'nordbygg-2026', 'Asgard Sweden', 'B06:54', jsonb_build_object('en', 'Our storage units, rigorously tested by qualified personnel, quickly became the preferred choice for those looking for security, quality and design.

The model we are exhibiting at Nordbygg is a robust and easy-to-handle unit adapted for construction sites where tools need to be stored, locked and charged safely. The cabinet is mobile, fits in construction lifts and can easily be moved between different projects and floors – which saves time and increases efficiency on site.', 'sv', 'Våra förråd, rigoröst testade av behörig personal, blev snabbt det föredragna valet för dem som sökte säkerhet, kvalitét och design.

Vår modell vi ställer ut på Nordbygg är ett robust och smidigt förråd anpassat för byggarbetsplatser där verktyg behöver förvaras, låsas och laddas säkert. Skåpet är mobilt, passar i bygghissar och kan enkelt tas med mellan olika projekt och våningsplan – vilket sparar tid och ökar effektiviteten på bygget.'), 'https://www.asgardsweden.com', 'assets/images/exhibitors/nordbygg-2026-asgard-sweden.jpg'),
  ('nordbygg-2026-exhibitor-134451', 'nordbygg-2026', 'Aston Sweden AB', 'C17:60', jsonb_build_object('en', 'Swedish manufacturer of professional fasteners

ASTON Sweden is a Swedish manufacturer of high-quality fasteners with production in Karlskoga. We combine technical expertise, in-house manufacturing and efficient logistics to deliver the right product – at the right time.

We work closely with our customers and take responsibility all the way from concept to finished delivery. Whether the need is for standard products or customer-tailored solutions, we make sure to deliver with a high level of service and short lead times.

In-house production and full control

In our factories, we are specialised in:

-Cold forming

-Washer assembly

-Powder coating

-Automated packing

We produce fasteners in stainless steel and aluminium directly from wire in our factory in Karlskoga. For larger volumes of coated screws, we work with our Danish parent company, one of Europe''s leading actors in the field.

At the same time, we offer flexible service coating in Karlskoga for smaller series and specially adapted projects.

Our promise:

-High delivery reliability

-Flexible solutions

-Technical know-how

-Reduced inventory costs for our customers

We solve our customers'' challenges – and deliver more than just fasteners.', 'sv', 'Svensk tillverkare av professionella fästelement

ASTON Sweden är en svensk tillverkare av högkvalitativa fästelement med produktion i Karlskoga. Vi kombinerar teknisk kompetens, egen tillverkning och effektiv logistik för att leverera rätt produkt – i rätt tid.

Vi arbetar nära våra kunder och tar ansvar hela vägen från idé till färdig leverans. Oavsett om behovet är standardprodukter eller kundanpassade lösningar ser vi till att leverera med hög servicegrad och korta ledtider.

Egen produktion och full kontroll

I våra fabriker är vi specialiserade inom:

-Kallformning

-Brickmontering

-Pulverlackering

-Automatiserad packning

Vi producerar fästelement i rostfritt och aluminium direkt från tråd i vår fabrik i Karlskoga. För större volymer av lackerad skruv samarbetar vi med vårt danska moderbolag, en av Europas ledande aktörer inom området.

Samtidigt erbjuder vi flexibel service-lackering i Karlskoga för mindre serier och specialanpassade projekt.

Vårt löfte:

-Hög leveranssäkerhet

-Flexibla lösningar

-Tekniskt kunnande

-Minskade lagerkostnader för våra kunder

Vi löser kundernas utmaningar – och levererar mer än bara fästelement.'), 'https://www.astonsweden.com', 'assets/images/exhibitors/nordbygg-2026-aston-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-139721', 'nordbygg-2026', 'ATMOCE', 'A22:14', jsonb_build_object('en', 'ATMOCE was founded in 2024 and is headquartered in Germany. The company is a global energy technology business with the ambition of creating a better world through renewable energy.

Our mission is to enable homeowners and businesses to produce enough renewable energy to achieve energy independence. Through continuous innovation we want to drive the development of tomorrow''s energy systems and at the same time share knowledge and energy to contribute to stronger and more sustainable communities.

We develop advanced AC-based solar energy systems, carefully engineered for both residential and commercial applications. Our technical competence is developed in three global innovation centres in Germany, China and the USA, where international research and development collaboration forms the foundation of our product philosophy R.E.S.S.S.S – a holistic approach combining Reliability, Efficiency, Safety, Scalability, Smart, and Scenario-based design

Today, ATMOCE technology is represented in over 35 countries, where together with our partners we are building a global energy ecosystem driving the transition towards a sustainable and carbon-free future.', 'sv', 'ATMOCE grundades 2024 och har sitt huvudkontor i Tyskland. Företaget är ett globalt energiteknikbolag med ambitionen att skapa en bättre värld genom förnybar energi.

Vår mission är att göra det möjligt för villaägare och företag att producera tillräckligt med förnybar energi för att uppnå energisjälvständighet. Genom kontinuerlig innovation vill vi driva utvecklingen av framtidens energisystem och samtidigt dela kunskap och energi för att bidra till starkare och mer hållbara samhällen.

Vi utvecklar avancerade AC-baserade solenergisystem, noggrant konstruerade för både bostäder och kommersiella tillämpningar. Vår tekniska kompetens utvecklas i tre globala innovationscenter i Tyskland, Kina och USA, där internationellt samarbete inom forskning och utveckling ligger till grund för vår produktfilosofi R.E.S.S.S.S – en helhet som kombinerar Reliability, Efficiency, Safety, Scalability, Smart, och Scenario-baserad design

Idag finns ATMOCE:s teknik representerad i över 35 länder, där vi tillsammans med våra partners bygger ett globalt energiekosystem som driver på omställningen mot en hållbar och koldioxidfri framtid.'), 'https://www.atmoce.com', 'assets/images/exhibitors/nordbygg-2026-atmoce.jpg'),
  ('nordbygg-2026-exhibitor-137564', 'nordbygg-2026', 'Axjo Kabel Aktiebolag', 'A10:04', null, 'https://www.axjokabel.se', null),
  ('nordbygg-2026-exhibitor-139166', 'nordbygg-2026', 'AXOLIFT', 'BG:22', null, 'https://www.axolift.com', 'assets/images/exhibitors/nordbygg-2026-axolift.jpg'),
  ('nordbygg-2026-exhibitor-137096', 'nordbygg-2026', 'AXS Nordic AB', 'C11:51', jsonb_build_object('en', 'Slim glass portal, sliding & folding walls, shower & sauna fittings, plus tools

At AXS we help you with personal solutions to suit your business. Have a look at our broad range of quality brands meeting the latest requirements on the market – and contact us and tell us about your needs.', 'sv', 'Slimmad glasportal, skjut- & vikväggar, dusch & bastubeslag samt verktyg

Vi på AXS hjälper vi dig med personliga lösningar som passar din verksamhet. Kolla gärna in vårt breda sortiment av kvalitetsvarumärken med marknadens senaste krav – och kontakta oss och berätta om dina behov.'), 'https://www.axsnordic.com', 'assets/images/exhibitors/nordbygg-2026-axs-nordic-ab.jpg'),
  ('nordbygg-2026-exhibitor-139451', 'nordbygg-2026', 'Aztec International', 'B09:50', null, 'https://www.aztec-international.eu', 'assets/images/exhibitors/nordbygg-2026-aztec-international.jpg'),
  ('nordbygg-2026-exhibitor-133963', 'nordbygg-2026', 'Badex AB', 'A08:02', null, 'https://www.badex.se', 'assets/images/exhibitors/nordbygg-2026-badex-ab.jpg'),
  ('nordbygg-2026-exhibitor-139150', 'nordbygg-2026', 'BAPI', 'A20:13', null, 'https://www.bapihvac.com', null),
  ('nordbygg-2026-exhibitor-138256', 'nordbygg-2026', 'bARK Production AB', 'C11:41G', jsonb_build_object('en', 'bARK Timber Facade System is an innovative facade system produced from FSC-certified Swedish glulam manufactured in Hultsfred.

The system is designed to offer a low-CO2 alternative to steel and aluminium in all types of facades, where we combine the natural advantages of wood with modern CNC technology.

The result is an aesthetically appealing, sustainable system with one of the best EPDs on the market. The system is registered in Byggvarubedömningen and certified to applicable European standards.

Through advanced CNC milling, the facade solution is tailored to the architectural expression while technical challenges are handled. An ingenious design separates the system''s drainage from the load-bearing glulam. Moisture simulation with WUFI ensures that the construction is designed to withstand the demands of the Nordic climate.

Stick, Grand windows, Partition and Module are at the heart of the bARK Timber Facade System.', 'sv', 'bARK Timber Facade System är ett innovativt fasadsystem producerat av FSC-certifierat svenskt limträ som tillverkas i Hultsfred.

Systemet är framtaget för att erbjuda ett CO2-snålt alternativ till stål och aluminium i alla typer av fasader där vi kombinerar träets naturliga fördelar med modern CNC-teknik.

Resultatet är ett estetiskt tilltalande, hållbart system med marknadens bästa EPD. Systemet är registrerat i Byggvarubedömningen och certifierat enligt gällande europeiska standarder.

Genom avancerad CNC-fräsning skräddarsys fasadlösningen till det arkitektoniska uttrycket samtidigt som tekniska utmaningar hanteras. En sinnrik design separerar systemets dränage-system från det bärande limträet. Fuktsimulering med WUFI säkerställer att konstruktionen är utformad för att tåla det nordiska klimatets påfrestningar.

Stick, Grand windows, Partition och Module är hjärtat i bARK Timber Facade System.'), 'https://www.barkproduktion.se', 'assets/images/exhibitors/nordbygg-2026-bark-production-ab.jpg'),
  ('nordbygg-2026-exhibitor-139404', 'nordbygg-2026', 'Basta', 'EH:15', jsonb_build_object('en', 'Conscious product choices – the BASTA system helps you choose sustainable products through scientifically based criteria for phasing out hazardous substances.', 'sv', 'Medvetna produktval - BASTA-systemet hjälper dig att välja hållbara produkter genom vetenskapligt baserade kriterier för att fasa ut farliga ämnen.'), 'https://www.bastaonline.se/', 'assets/images/exhibitors/nordbygg-2026-basta.jpg'),
  ('nordbygg-2026-exhibitor-135780', 'nordbygg-2026', 'BASTEC AB', 'A13:10', jsonb_build_object('en', 'Bastec is an innovative company with more than 35 years of experience as a developer of Swedish products and services for building automation. We work closely with resellers and partners across the country who carry out installations and projects with Bastec systems for end customers. We also handle our own control contracts in our local area, which gives us a unique breadth and valuable insight into the real needs of today''s property industry.

Our efficient control system BAS3 (which replaces our older BAS2 system), together with our complementary products and dedicated support staff, is highly appreciated. Our clear goal is for Bastec''s control and regulation systems to deliver the greatest possible energy savings at the lowest total cost over time.

Bastec is part of the Swegon Group, a wholly owned business area within the listed Investment AB Latour.', 'sv', 'Bastec är ett innovativt företag med drygt 35 års erfarenhet som utvecklare av svenska produkter och tjänster inom fastighetsautomation. Vi har ett nära samarbete med återförsäljare och partners över hela landet, som genomför entreprenader och projekt med Bastec-system till slutkunder. Vi utför även egna styrentreprenader i närområdet, vilket ger oss en unik bredd och värdefulla insikter om de verkliga behoven i dagens fastighetsbransch.

Vårt effektiva styrsystem BAS3 (som ersätter vårt äldre system BAS2) tillsammans med våra kompletterande produkter och dedikerade supportpersonal är högt uppskattat. Vårt givna mål är att Bastecs system för styr och regler ska ge största möjliga energibesparing till lägst totalkostnad över tid.

Bastec ingår i Swegon Group, ett helägt affärsområde inom börsnoterade Investment AB Latour.'), 'https://www.bastec.se', 'assets/images/exhibitors/nordbygg-2026-bastec-ab.jpg'),
  ('nordbygg-2026-exhibitor-137116', 'nordbygg-2026', 'Bauroc', 'C11:61', null, 'https://bauroc.se', null),
  ('nordbygg-2026-exhibitor-139354', 'nordbygg-2026', 'Bavarian Pavilion', 'C02:51', jsonb_build_object('en', 'Bavaria officially participates with a joint companies stand and an information center offering a professional brokerage service to help establish contacts with Bavarian companies and comprehensive information on Bavaria as a business and high-tech location.

Participating Companies:
Agrob Buchtal GmbH – www.agrob-buchtal.de
Eagle kreativ Deutschland GmbH – www.expert-markig.de
Florian Eichinger GmbH – www.eichinger.de
Genossenschafts-Werke für Solnhofener Platten GmbH - www.genowe.de
Passiv Energie GmbH - www.passiv-energie.gmbh
RAICO Bautechnik GmbH - www.raico.de
Wolf Bavaria - www.wolf-bavaria.com', 'sv', 'Bayern deltar officiellt med en gemensam företagsmonter och ett informationscenter som erbjuder en professionell förmedlingstjänst för att hjälpa till att knyta kontakter med bayerska företag, samt utförlig information om Bayern som affärs- och högteknologiplats.

Deltagande företag:
Agrob Buchtal GmbH – www.agrob-buchtal.de
Eagle kreativ Deutschland GmbH – www.expert-markig.de
Florian Eichinger GmbH – www.eichinger.de
Genossenschafts-Werke für Solnhofener Platten GmbH - www.genowe.de
Passiv Energie GmbH - www.passiv-energie.gmbh
RAICO Bautechnik GmbH - www.raico.de
Wolf Bavaria - www.wolf-bavaria.com'), 'https://www.bayern-international.de', null),
  ('nordbygg-2026-exhibitor-137907', 'nordbygg-2026', 'BCE - Betongplinten', 'C08:53', null, 'https://betongplinten.se', null),
  ('nordbygg-2026-exhibitor-134963', 'nordbygg-2026', 'Beckhoff Automation AB', 'A16:10', jsonb_build_object('en', 'Beckhoff makes open automation systems possible, built on PC-based control. Our product range covers the main areas of Industrial PC, I/O and fieldbus components, drive technology, automation software and cabinet-less automation. Across all areas, product lines are available both as individual components and as parts of a complete, integrated control system. Our New Automation Technology stands for universal and industry-independent control and automation solutions used worldwide – from CNC-controlled machine tools to intelligent building management.', 'sv', 'Beckhoff möjliggör öppna automationssystem byggd på PC-baserad styrning. Vårt produktspektrum omfattar huvudområden Industri-PC, I/O- och fältbusskomponenter, drivsystem, automatiseringsprogramvara och manöverskåpsfri automatisering. För alla områden finns produktlinjer tillgängliga, som både som enskilda komponenter och i samverkan som ett helt, samkört styrsystem. Vår New Automation Technology står för universella och branschoberoende styrnings- och automatiseringslösningar som används över hela världen – från CNC-styrda verktygsmaskiner till intelligenta fastighetsstyrningar.'), 'https://www.beckhoff.se', 'assets/images/exhibitors/nordbygg-2026-beckhoff-automation-ab.jpg'),
  ('nordbygg-2026-exhibitor-134815', 'nordbygg-2026', 'Belano Maskin AB', 'C18:51', jsonb_build_object('en', 'Belano Maskin AB was founded in 1957 with the aim of offering machines of high quality. Over the years the company has built up solid experience and today offers a very broad range of sheet-metal working machines and tools.

The business is aimed primarily at sheet-metal workshops in construction and ventilation as well as at the sheet-metal processing industry, but Belano also has products and solutions for mechanical workshops and forging shops.

The company offers both new and used machines; used machines are carefully inspected and often refurbished to near-new condition, with a warranty. In addition to sales, the offer also includes service, repairs and training for customers, to ensure security and long-term customer relationships.', 'sv', 'Belano Maskin AB grundades 1957 med målet att erbjuda maskiner av hög kvalitet. Genom åren har företaget byggt upp gedigen erfarenhet och kan idag erbjuda ett mycket brett sortiment inom plåtbearbetningsmaskiner och verktyg.

Verksamheten riktar sig främst till plåtslagerier inom bygg och ventilation samt till den plåtbearbetande industrin, men Belano har även produkter och lösningar för mekaniska verkstäder och smidesverkstäder.

Företaget erbjuder både nya och begagnade maskiner, där begagnade maskiner genomgåtts noggrant och ofta renoverats till nära nyskick, med garanti. Utöver försäljning ingår även service, reparationer och utbildningar för kunder, för att säkerställa trygghet och långsiktighet i kundrelationerna.'), 'https://www.belano.se', 'assets/images/exhibitors/nordbygg-2026-belano-maskin-ab.jpg'),
  ('nordbygg-2026-exhibitor-134821', 'nordbygg-2026', 'Belimo AB', 'A16:22', jsonb_build_object('en', 'Belimo, headquartered in Switzerland, is a world-leading manufacturer of field devices for the control of heating, ventilation and air-handling systems. The company''s core business is the development, production and sale of sensors, control valves and actuators. The company was founded in 1975 and listed on the Swiss Exchange (SIX) in 1995. Today it employs around 2,400 people in over 80 countries.', 'sv', 'Belimo, med huvudkontor i Schweiz, är världsledande tillverkare av fältenheter för styrning av värme-, ventilations- och luftbehandlingssystem. Företagets kärnverksamhet utgörs av utveckling, produktion och försäljning av givare, reglerventiler och ställdon. Företaget grundades 1975 och listades på börsen Swiss Exchange (SIX) 1995. Idag sysselsätter företaget ca 2400 personer i över 80 länder.'), 'https://www.belimo.se', 'assets/images/exhibitors/nordbygg-2026-belimo-ab.jpg'),
  ('nordbygg-2026-exhibitor-140006', 'nordbygg-2026', 'Beltton AB', 'C09:62', null, 'https://www.beltton.se', 'assets/images/exhibitors/nordbygg-2026-beltton-ab.jpg'),
  ('nordbygg-2026-exhibitor-137768', 'nordbygg-2026', 'BENGglas B.V.', 'C10:31', jsonb_build_object('en', 'BENGglas offers the world’s best insulating glass (U=0.35) and helps build a more sustainable future—pane by pane.

- Insulates up to three times better than high performance double glazing and up to twice as well as triple glazing
- Uses 30% less material than HR+++ (triple glazing)
- Fits seamlessly into existing window frames
- Ultra-lightweight, making heavy and expensive hardware unnecessary
- Expected lifespan of up to 50 years
- Tested by IFT Rosenheim (2025)

If adopted worldwide, the energy savings would be enormous—so great that meeting climate targets would suddenly become realistic, simply by choosing the right glass.

BENGglas and BENGsolar are part of BENGproducts B.V.', 'sv', 'BENGglas erbjuder världens bästa isolerglas (U=0,35) och hjälper till att bygga en mer hållbar framtid – ruta för ruta.

- Isolerar upp till tre gånger bättre än högpresterande tvåglas och upp till dubbelt så bra som treglas
- Använder 30 % mindre material än HR+++ (treglas)
- Passar sömlöst i befintliga fönsterkarmar
- Ultralätt, vilket gör tunga och dyra beslag onödiga
- Förväntad livslängd på upp till 50 år
- Testat av IFT Rosenheim (2025)

Om tekniken infördes över hela världen skulle energibesparingarna bli enorma – så stora att klimatmålen plötsligt skulle bli realistiska att nå, helt enkelt genom att välja rätt glas.

BENGglas och BENGsolar är en del av BENGproducts B.V.'), 'https://www.bengglas.nl/en', 'assets/images/exhibitors/nordbygg-2026-bengglas-b-v.jpg'),
  ('nordbygg-2026-exhibitor-137877', 'nordbygg-2026', 'Besco GmbH', 'A11:12', null, 'https://www.bescofittings.de', 'assets/images/exhibitors/nordbygg-2026-besco-gmbh.jpg'),
  ('nordbygg-2026-exhibitor-139958', 'nordbygg-2026', 'BESSEY Tool', 'B06:50', jsonb_build_object('en', 'Bessey is a leading manufacturer of high-quality clamps for industry and joinery. Their range of clamps includes parallel clamps as well as aluminium, steel and magnesium clamps in several sizes. Bessey clamps are made from high-quality material to last a long time and withstand wear.

Bessey Tools is one of the most respected manufacturers of clamping tools in the industry, and with their high-quality and reliable products you can be sure that you are getting the best tool for the job.', 'sv', 'Bessey är en ledande tillverkare av högkvalitativa skruvtvingar för industri och snickerier. Deras sortiment av skruvtvingar inkluderar parallella skruvtvingar, aluminium-, stål- och magnesiumskruvtvingar i flera storlekar. Bessey skruvtvingar är tillverkade av högkvalitativt material för att hålla länge och motstå slitage.

Bessey Tools är en av de mest respekterade tillverkarna av spännverktyg i branschen, och med deras högkvalitativa och pålitliga produkter kan du vara säker på att du får det bästa verktyget för ditt arbete.'), 'https://bessey.de/sv-se', 'assets/images/exhibitors/nordbygg-2026-bessey-tool.jpg'),
  ('nordbygg-2026-exhibitor-137343', 'nordbygg-2026', 'Betongvärlden', 'C10:73', null, 'https://betongvarlden.se', null),
  ('nordbygg-2026-exhibitor-133958', 'nordbygg-2026', 'Beulco Armatur AB', 'A06:11', jsonb_build_object('en', 'Beulco Armatur are specialists in plumbing and HVAC solutions. We have a genuine interest in and commitment to our customers'' need for products that solve problems and improve efficiency. The combination of a broad standard product range and prefabricated plumbing solutions is our greatest strength.

Product, Meter and Prefab
We strengthen our market position by clarifying our three areas of specialisation: Product, Meter and Prefab. Today we work ever more closely with installers. Together we develop complete plumbing units that are tailored and delivered ready to install at the construction site. Prefabricating different product solutions streamlines the installation work, which in turn leads to better overall economics. In other words, the majority of the plumbing work takes place at our state-of-the-art production facility instead of out on the building site.

Efficient organisation
To meet customers'' need for technical support and rapid deliveries, we have built up an efficient organisation that has the capacity and knowledge to take care of both large and small customers. Our sales offices are strategically located in order to provide the best possible service to our customer groups, which include wholesalers, developers, property owners, consultants and installers.

Our logistics solutions are tailored to each customer''s unique requirements, whether it concerns standard products or prefabricated units to be delivered "just-in-time" to the construction site.', 'sv', 'Beulco Armatur är specialister på VVS-lösningar. Vi har ett genuint intresse och engagemang för våra kunders behov av olika produkter som löser problem och effektiviserar. Det är kombinationen av ett brett basutbud av standardprodukter och prefabricerade VVS-lösningar som är vår största styrka.

Produkt, Mätare och Prefab
Vi stärker vår position på marknaden genom att förtydliga våra tre specialområden: Produkt, Mätare och Prefab. Idag jobbar vi allt närmare installatörsledet. Tillsammans utvecklar vi kompletta VVS-enheter som skräddarsys och levereras installationsklara till byggarbetsplatsen. Prefabricering av olika produktlösningar effektiviserar installationsarbetet, vilket i sin tur leder till bättre totalekonomi. Med andra ord sker större delen av VVS-arbetet i vår toppmoderna produktionsanläggning istället för ute på bygget.

Effektiv organisation
För att möta kundernas behov av tekniskt stöd och snabba leveranser har vi utvecklat en effektiv organisation som har kapacitet och kunskap att ta hand om såväl stora som små kunder. Våra säljkontor är strategiskt placerade för att kunna ge bästa möjliga service till våra kundgrupper som består av grossister, byggherrar, fastighetsägare, konsulter och installatörer.

Våra logistiklösningar är kundanpassade efter varje kunds unika krav, vare sig det handlar om standardprodukter eller prefabricerade enheter som ska levereras ”just-in-time” till byggarbetsplatsen.'), 'https://www.beulcoarmatur.se', 'assets/images/exhibitors/nordbygg-2026-beulco-armatur-ab.jpg'),
  ('nordbygg-2026-exhibitor-134910', 'nordbygg-2026', 'BEVEGO Byggplåt & Ventilation AB', 'C17:41 (+1)', jsonb_build_object('en', 'Bevego offers a carefully selected range from market-leading suppliers, complemented by our own manufacturing. With fast and flexible deliveries across Sweden, a local presence and high expertise, we help sheet-metal workers, ventilation installers, insulation contractors and industry succeed in their work.', 'sv', 'Bevego erbjuder ett noga utvalt sortiment från marknadsledande leverantörer, kompletterat med egen tillverkning. Med snabb och flexibel leverans i hela Sverige, lokal närvaro och hög expertis hjälper vi plåtslagare, ventilationsmontörer, isoleringsentreprenörer och industri att lyckas i sitt arbete.'), 'https://www.bevego.se', 'assets/images/exhibitors/nordbygg-2026-bevego-byggplat-ventilation-ab.jpg'),
  ('nordbygg-2026-exhibitor-139583', 'nordbygg-2026', 'Bigup', 'BG:14', jsonb_build_object('en', 'Why screw up when you can BIGUP?

Why juggle email threads, apps and Excel sheets the size of football pitches when the whole project can hang together?

BigUp is the platform that brings everything in your construction project together – finances, the worksite, documents and follow-up – in a single system. Everyone works with the same information in real time, which reduces mistakes, saves time and gives full control.

The result?
Fewer screw ups. Better flow. Projects that actually hold up.', 'sv', 'Why screw up when you can BIGUP?

Varför jonglera mejltrådar, appar och Excelark stora som fotbollsplaner när hela projektet kan hänga ihop?

BigUp är plattformen som samlar allt i byggprojektet – ekonomi, arbetsplats, dokument och uppföljning – i ett och samma system. Alla jobbar med samma information i realtid, vilket minskar misstag, sparar tid och ger full kontroll.

Resultatet?
Färre screw ups. Bättre flyt. Projekt som faktiskt håller.'), 'https://www.bigup.se', 'assets/images/exhibitors/nordbygg-2026-bigup.jpg'),
  ('nordbygg-2026-exhibitor-139310', 'nordbygg-2026', 'Bil & glasdesign Sverige AB', 'AG:130', jsonb_build_object('en', 'We work with everything that can be stuck onto buildings and cars.

Bil & glasdesign Sverige AB is a family business where great emphasis is placed on quality and customer satisfaction. We have graphic design, production and installation under one roof, which makes us very flexible and keeps decision-making short.

We have two main areas of business: one is car decals and vehicle wrapping. The other is the installation of solar film and other protective film for buildings.

With more than 30 years in the industry, we keep developing our skills and broadening our offering to always be your best choice.', 'sv', 'Vi arbetar med allt som går att klistra på hus och bilar.

Bil & glasdesign Sverige AB är ett familjeföretag där stor vikt läggs vid kvalitet och kundnöjdhet. Vi har grafisk design, produktion och montering under ett tak, detta gör oss väldigt flexibla och beslutsvägarna är korta.

Vi har två stora verksamhetsområden, det ena är bildekor och foliering av bilar. Det andra är montering av solfilm och annan skyddsfilm till fastigheter.

Med över 30 år i branschen fortsätter vi att vidareutbilda oss och skapa bredd för att alltid vara ditt bästa alternativ.'), 'https://www.bilglasdesign.se', 'assets/images/exhibitors/nordbygg-2026-bil-glasdesign-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-134848', 'nordbygg-2026', 'BIM.com', 'C02:11', jsonb_build_object('en', 'Bim.com serves as a central hub for reliable product information, connecting manufacturers with property owners, architects and contractors. Our platform includes, among other things:

- bimobject.com: A global marketing platform for digital building products.
- Prodikt: A tool for project and sustainability work.
- Design App: Brings life-cycle data directly into the workflow and integrates bimobject.com into Autodesk Revit.
- EandoX: A platform for managing environmental data and producing Environmental Product Declarations (EPDs).

Additional services: We also offer services such as creating BIM objects, performing Life Cycle Assessments (LCAs), producing Environmental Product Declarations (EPDs) and solutions for data sharing between stakeholders and across different systems.', 'sv', 'Bim.com fungerar som en central knutpunkt för tillförlitlig produktinformation och kopplar samman tillverkare med fastighetsägare, arkitekter och entreprenörer. Vår plattform omfattar bland annat:

- bimobject.com: En global marknadsföringsplattform med digitala byggprodukter.
- Prodikt: Ett verktyg för projekt- och hållbarhetsarbete.
- Design App: Ger livscykeldata direkt in i arbetsflödet och integrerar bimobject.com i Autodesk Revit.
- EandoX: En plattform för att hantera miljödata och ta fram Environmental Product Declarations (EPD:er).

Tilläggstjänster: Vi erbjuder även tjänster som att skapa BIM-objekt, genomföra Life Cycle Assessments (LCA:er), ta fram Environmental Product Declarations (EPD:er) samt lösningar för datadelning mellan intressenter och över olika system.'), 'https://www.bim.com', 'assets/images/exhibitors/nordbygg-2026-bim-com.jpg'),
  ('nordbygg-2026-exhibitor-139449', 'nordbygg-2026', 'BIMobject', 'C02:11', jsonb_build_object('en', 'BIMobject is a global platform that connects architects, engineers and contractors with the products they build with. By turning real-world products into digital BIM objects (Building Information Modelling), the platform brings manufacturers'' data directly into the design process – making construction smarter, faster and more sustainable.', 'sv', 'BIMobject är en global plattform där arkitekter, ingenjörer och entreprenörer kopplas samman med de produkter de bygger med. Genom att omvandla verkliga produkter till digitala BIM-objekt (Byggnadsinformationsmodellering) för plattformen tillverkarnas data direkt in i designprocessen – vilket gör byggandet smartare, snabbare och mer hållbart.'), 'https://www.bimobject.com', 'assets/images/exhibitors/nordbygg-2026-bimobject.jpg'),
  ('nordbygg-2026-exhibitor-138504', 'nordbygg-2026', 'BKMA', 'C04:10', jsonb_build_object('en', 'BKMA is the construction industry''s certified management system for quality, environment and work environment. It is based on ISO 9001, 14001 and 45001 but adapted to the working methods and requirements of the construction sector. The certification is audited annually by an independent certification body.', 'sv', 'BKMA är byggbranschens certifierade verksamhetsledningssystem för kvalitet, miljö och arbetsmiljö. Det bygger på ISO 9001, 14001 och 45001, men är anpassat till byggbranschens arbetssätt och krav. Certifieringen granskas årligen av ett oberoende certifieringsorgan.'), 'https://www.bkma.se', 'assets/images/exhibitors/nordbygg-2026-bkma.jpg'),
  ('nordbygg-2026-exhibitor-135413', 'nordbygg-2026', 'BLINKEN', 'B05:01', jsonb_build_object('en', 'Blinken offers a broad range of innovative quality products – everything from rotating lasers, pipe-laying lasers and cross-/line lasers to, among other things, moisture meters, GNSS equipment, UAV drones and machine control.', 'sv', 'Blinken erbjuder ett brett sortiment av innovativa kvalitetsprodukter – allt från rotationslaser, rörläggningslaser och kryss-/linjelaser till bland annat fuktmätare, GNSS-utrustning, UAV-drönare och maskinkontroll.'), 'https://www.blinken.eu', 'assets/images/exhibitors/nordbygg-2026-blinken.jpg'),
  ('nordbygg-2026-exhibitor-137915', 'nordbygg-2026', 'Blixbo Cementvarufabrik', 'C08:61', null, 'https://www.blixbocement.se', 'assets/images/exhibitors/nordbygg-2026-blixbo-cementvarufabrik.jpg'),
  ('nordbygg-2026-exhibitor-138839', 'nordbygg-2026', 'Bluebeam', 'C01:03', jsonb_build_object('en', 'Bluebeam is the leading supplier of digital productivity and collaboration solutions for the industries that design and build our world. Since 2002 the company has developed tools for smart markups, real-time collaboration and cloud-based document management that streamline and improve workflows.
The solutions are used by more than four million professionals in over 160 countries. Bluebeam is headquartered in Pasadena, California, and is part of the Nemetschek Group.', 'sv', 'Bluebeam är den ledande leverantören av digitala produktivitets- och samarbetslösningar för de branscher som designar och bygger vår värld. Sedan 2002 har företaget utvecklat verktyg för smarta markeringar, realtidssamarbete och molnbaserad dokumenthantering som effektiviserar och förbättrar arbetsflöden.
Lösningarna används av över fyra miljoner yrkesverksamma i mer än 160 länder. Bluebeam har huvudkontor i Pasadena, Kalifornien, och ingår i Nemetschek Group.'), 'https://www.bluebeam.com', 'assets/images/exhibitors/nordbygg-2026-bluebeam.jpg'),
  ('nordbygg-2026-exhibitor-134964', 'nordbygg-2026', 'Blücher Sweden AB', 'A04:23', jsonb_build_object('en', 'BLÜCHER is an internationally leading company in the development and manufacture of stainless steel drainage systems, known for its high quality, innovation and sustainability.

With roots in Denmark, BLÜCHER has built up a strong global reputation by delivering reliable solutions for commercial, industrial and marine environments.

Our product portfolio ranges from floor drains and channels to advanced piping systems, all designed to meet high demands on hygiene, durability and functionality. BLÜCHER works continuously on product development and uses modern technology to ensure efficient and environmentally friendly solutions.

One of BLÜCHER''s foremost strengths is our focus on quality in every detail. By using stainless steel as the main material, we offer products with a long service life, minimal maintenance and high resistance to corrosion. This makes our solutions particularly suited to demanding environments such as the food industry, healthcare and laboratories.

Sustainability is a central part of the business. BLÜCHER strives to reduce its environmental impact through energy-efficient production, recyclable materials and smart design that contributes to resource efficiency for our customers.

With a strong customer focus and a global network of partners and distributors, BLÜCHER is a reliable player that delivers solutions tailored to each customer''s specific needs. Our combination of technical expertise, high quality and innovative thinking makes us an obvious choice within modern drainage systems.', 'sv', 'BLÜCHER är ett internationellt ledande företag inom utveckling och tillverkning av rostfria avloppssystem, känt för sin höga kvalitet, innovation och hållbarhet.

Med rötter i Danmark har BLÜCHER byggt upp ett starkt globalt rykte genom att leverera pålitliga lösningar för både kommersiella, industriella och marina miljöer.

Vår produktportfölj omfattar allt från golvbrunnar och rännor till avancerade rörsystem, samtliga designade för att möta högt ställda krav på hygien, hållbarhet och funktionalitet. BLÜCHER arbetar kontinuerligt med produktutveckling och använder modern teknik för att säkerställa effektiva och miljövänliga lösningar.

En av BLÜCHERs främsta styrkor är vårt fokus på kvalitet i varje detalj. Genom att använda rostfritt stål som huvudmaterial erbjuder vi produkter med lång livslängd, minimalt underhåll och hög motståndskraft mot korrosion. Detta gör våra lösningar särskilt lämpade för krävande miljöer såsom livsmedelsindustri, sjukvård och laboratorier.

Hållbarhet är en central del av verksamheten. BLÜCHER strävar efter att minska sin miljöpåverkan genom energieffektiv produktion, återvinningsbara material och smart design som bidrar till resurseffektivitet hos kunderna.

Med ett starkt kundfokus och ett globalt nätverk av partners och distributörer är BLÜCHER en pålitlig aktör som levererar lösningar anpassade efter varje kunds specifika behov. Vår kombination av teknisk expertis, hög kvalitet och innovativt tänkande gör oss till ett självklart val inom moderna avloppssystem.'), 'https://www.blucher.se', 'assets/images/exhibitors/nordbygg-2026-blucher-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-135336', 'nordbygg-2026', 'BML Produktion', 'A03:04', null, 'https://www.bmlproduktion.com', null),
  ('nordbygg-2026-exhibitor-139779', 'nordbygg-2026', 'Bohlin & Nilsson AB', 'B04:50', jsonb_build_object('en', 'The electrical industry''s tool supplier since 1948
Bohlin & Nilsson focuses on the sale of tools, machines and supplies, primarily to the electrical industry but also to other tradespeople, industrial customers and similar buyers.', 'sv', 'Elbranschens verktygsleverantör sedan 1948
Bohlin & Nilssons inriktning är försäljning av verktyg, maskiner och förnödenheter till i huvudsak elbranschen, men också till övriga hantverkare, industrier m.fl.'), 'https://www.bohlin-nilsson.se', 'assets/images/exhibitors/nordbygg-2026-bohlin-nilsson-ab.jpg'),
  ('nordbygg-2026-exhibitor-134748', 'nordbygg-2026', 'Borga Plåt AB', 'C18:33', null, 'https://www.borga.se/byggtillbehor/', 'assets/images/exhibitors/nordbygg-2026-borga-plat-ab.jpg'),
  ('nordbygg-2026-exhibitor-136238', 'nordbygg-2026', 'Borghamns Stenförädling AB', 'C04:71', jsonb_build_object('en', 'Swedish limestone and marble are among the most beautiful and at the same time hardest building stones in the world. Borghamns Stenförädling AB quarries limestone on the eastern shore of Lake Vättern and Kolmården marble in the original marble quarries north of Bråviken. The raw material is several hundred million years old and demands respectful handling, as well as skilled stone-cutting craftsmanship in the finishing.', 'sv', 'Svensk kalksten och marmor tillhör den absolut vackraste och samtidigt hårdaste byggnadsstenen i världen. Borghamns Stenförädling AB bryter kalksten vid Vätterns östra strand och Kolmårdsmarmor i de ursprungliga marmorbrotten norr om Bråviken. Råvaran är flera hundra miljoner år gammal och kräver respektfull hantering och likaså förädling i form av kvalificerade stenhuggeriarbeten.'), 'https://www.borghamns-stenforadling.se', 'assets/images/exhibitors/nordbygg-2026-borghamns-stenforadling-ab.jpg'),
  ('nordbygg-2026-exhibitor-137914', 'nordbygg-2026', 'Bosch Power Tools', 'B03:10', jsonb_build_object('en', 'With a focus on innovation, sustainability and ease of use, Bosch develops solutions that increase productivity and precision in everyday work – whether it concerns construction, installation or renovation. At Nordbygg, Bosch presents its latest professional launches, smart battery systems and digital services that help professionals work faster, more safely and more efficiently. Visit the stand and experience tool technology at the forefront.', 'sv', 'Med fokus på innovation, hållbarhet och användarvänlighet utvecklar Bosch lösningar som ökar produktivitet och precision i det dagliga arbetet – oavsett om det gäller bygg, installation eller renovering. På Nordbygg presenterar Bosch sina senaste professionella nyheter, smarta batterisystem och digitala tjänster som hjälper proffs att arbeta snabbare, säkrare och mer effektivt. Besök montern och upplev verktygsteknik i framkant.'), 'https://www.bosch-professional.com/se/sv/', 'assets/images/exhibitors/nordbygg-2026-bosch-power-tools.jpg'),
  ('nordbygg-2026-exhibitor-136400', 'nordbygg-2026', 'Bostik AB', 'C02:33', jsonb_build_object('en', 'Bostik and LIP are two strong brands in adhesives, sealants and building products – together within the Arkema Group, a global innovator in sustainable materials.
Bostik offers a complete range for professional and sustainable bonding and sealing solutions, with production in Helsingborg and a strong global presence.
LIP is the Scandinavian specialist brand for wet-room systems and advanced specialty applications, with production in Denmark and leading expertise in the Nordics.
Together we create a competitive whole that simplifies projects, strengthens results and gives customers confidence at every step.
Innovation, sustainability and technical support are at the heart of our shared offer – for better building solutions, today and tomorrow.', 'sv', 'Bostik och LIP är två starka varumärken inom lim, tätning och byggprodukter – tillsammans i Arkema-koncernen, en global innovatör inom hållbara material.
Bostik erbjuder ett komplett sortiment för professionella och hållbara limnings- och tätningslösningar, med produktion i Helsingborg och stark global närvaro.
LIP är det skandinaviska specialistvarumärket för våtrumssystem och avancerade specialapplikationer, med produktion i Danmark och ledande expertis i Norden.
Tillsammans skapar vi en konkurrenskraftig helhet som förenklar projekt, stärker resultat och ger kunderna trygghet i varje led.
Innovation, hållbarhet och teknisk support är kärnan i vårt gemensamma erbjudande – för bättre bygglösningar, idag och imorgon.'), 'https://www.bostik.se', 'assets/images/exhibitors/nordbygg-2026-bostik-ab.jpg'),
  ('nordbygg-2026-exhibitor-139613', 'nordbygg-2026', 'Boverket', 'AG:17', null, 'https://www.boverket.se', 'assets/images/exhibitors/nordbygg-2026-boverket.jpg'),
  ('nordbygg-2026-exhibitor-136780', 'nordbygg-2026', 'BOX Container Sweden AB', 'B09:30', jsonb_build_object('en', 'BOXIT offers modern containers in several sizes and models – perfect for safe storage of tools, materials and machines directly on the construction site. With our own trucks and fixed delivery prices, we deliver containers all across Sweden. Rent easily for as long as you need.

Our range includes:

- Storage containers
- Insulated containers with electricity and lighting
- Open-side containers
- Office containers
- Refrigerated and freezer containers
- Custom container solutions', 'sv', 'BOXIT erbjuder moderna containrar i flera storlekar och modeller – perfekta för säker förvaring av verktyg, material och maskiner direkt på byggarbetsplatsen. Med egna lastbilar och fasta leveranspriser levererar vi containrar över hela Sverige. Hyr enkelt så länge ni behöver.

Vi erbjuder bland annat:

- Förvaringscontainrar
- Isolerade containrar med el och belysning
- Open Side-containrar
- Kontorscontainrar
- Kyl- och fryscontainrar
- Specialanpassade containerlösningar'), 'https://www.boxit.se', 'assets/images/exhibitors/nordbygg-2026-box-container-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-140103', 'nordbygg-2026', 'Brainial', 'C03:41', jsonb_build_object('en', 'Brainial is a European AI-based software company that helps organisations manage complex tender processes with higher quality, lower risk and less manual work. Brainial''s platform supports the entire tender life cycle, including procurement identification, document analysis, bid/no-bid decisions, collaboration, knowledge reuse and bid creation.

Unlike generic AI tools, Brainial uses procurement-specific AI trained to understand extensive and complex documentation. The platform delivers explainable results with direct links to source documents, ensuring accuracy and traceability.

Brainial is used by companies in construction, infrastructure, transport, IT and professional services across Europe to improve efficiency, reduce compliance risk and increase win rates in complex public and private procurements. The platform is cloud-based within the EU and built to meet high enterprise requirements for security and data protection.', 'sv', 'Brainial är ett europeiskt AI-baserat mjukvaruföretag som hjälper organisationer att hantera komplexa anbudsprocesser med högre kvalitet, lägre risk och mindre manuellt arbete. Brainials plattform stödjer hela anbudslivscykeln, inklusive identifiering av upphandlingar, dokumentanalys, bid/no-bid-beslut, samarbete, återanvändning av kunskap samt framtagning av anbud.

Till skillnad från generiska AI-verktyg använder Brainial upphandlingsspecifik AI som är tränad för att förstå omfattande och komplex dokumentation. Plattformen ger förklarbara resultat med direkta länkar till källdokument, vilket säkerställer noggrannhet och spårbarhet.

Brainial används av företag inom bygg, infrastruktur, transport, IT och professionella tjänster i hela Europa för att förbättra effektiviteten, minska regelefterlevnadsrisker och öka vinstfrekvensen i komplexa offentliga och privata upphandlingar. Plattformen är molnbaserad inom EU och utvecklad för att uppfylla höga krav på säkerhet och dataskydd för företag.'), 'https://brainial.com', 'assets/images/exhibitors/nordbygg-2026-brainial.jpg'),
  ('nordbygg-2026-exhibitor-139625', 'nordbygg-2026', 'Brava Vattenrening AB', 'AG:31', null, 'https://www.brava.se', null),
  ('nordbygg-2026-exhibitor-136473', 'nordbygg-2026', 'Bredhälla Aluminiumförädling AB', 'C18:10', null, 'https://www,bredhalla.se', null),
  ('nordbygg-2026-exhibitor-139524', 'nordbygg-2026', 'Brickley Rental AB', 'BG:26 (+1)', jsonb_build_object('en', 'By combining security with digital intelligence, we offer solutions that keep what is valuable in and thieves out. Our smart systems make sure everything works as it should, without you having to keep track of every little detail. Simple, smooth and trouble-free.', 'sv', 'Genom att kombinera säkerhet med digital intelligens erbjuder vi lösningar som håller det värdefulla inne och tjuvarna ute. Våra smarta system ser till att allt funkar som det ska, utan att du behöver hålla koll på minsta detalj. Enkelt, smidigt och problemfritt.'), 'https://brickley.se/', 'assets/images/exhibitors/nordbygg-2026-brickley-rental-ab.jpg'),
  ('nordbygg-2026-exhibitor-138081', 'nordbygg-2026', 'Brukspecialisten Sverige AB', 'EH:13 (+1)', jsonb_build_object('en', 'We have shifted course and want to lead the circular transition in masonry and rendered construction.

We want to take care of what has already been built by preserving, renovating and reusing, and we offer circular materials in the form of reused brick and unfired clay.

The construction of the future must start from what is already built – with a large share of preservation, renovation and reuse – and then add new virgin building materials with low climate and environmental impact, a long service life and a design ready for future reuse already at the drawing board.

Welcome to a new circular masonry and rendered construction!', 'sv', 'Vi har ställt om och vill leda den cirkulära omställningen inom murat och putsat byggande.

Vi vill ta hand om det redan byggda genom att: Bevara, renovera och återbruka och vi erbjuder cirkulära material inom återbrukat tegel och obränd lera

Framtidens byggande behöver utgå från det redan byggda med stor del bevarande, renovering och återbruk för att sedan addera nya jungfruliga byggmaterial med låg klimat- och miljöpåverkan, lång livslängd och en design redo för framtida återbruk redan på ritbordet.

Välkommen till ett nytt cirkulärt murat och putsat byggande!'), 'https://www.brukspecialisten.se', 'assets/images/exhibitors/nordbygg-2026-brukspecialisten-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-134362', 'nordbygg-2026', 'BSH Home Appliances AB', 'C05:21', null, 'https://www.bshg.com', 'assets/images/exhibitors/nordbygg-2026-bsh-home-appliances-ab.jpg'),
  ('nordbygg-2026-exhibitor-138503', 'nordbygg-2026', 'BUC', 'B04:41', null, 'https://www.byggforetagen.se', null),
  ('nordbygg-2026-exhibitor-134628', 'nordbygg-2026', 'BUFAB Sweden AB', 'C16:33', null, 'https://www.bufab.com', null),
  ('nordbygg-2026-exhibitor-139508', 'nordbygg-2026', 'Buildbite', 'BG:20', null, 'https://buildbite.com', null),
  ('nordbygg-2026-exhibitor-139403', 'nordbygg-2026', 'Builder AS', 'BG:15', jsonb_build_object('en', 'Resource sharing system to rent workers between contractors - internal, partnerships, external.
Resource allocation and demand planning for contractors to schedule their workers and forecast future needs.', 'sv', 'Resursdelningssystem för att hyra ut arbetskraft mellan entreprenörer – internt, i partnerskap och externt.
Resursplanering och behovsprognoser för entreprenörer som ska schemalägga sina medarbetare och förutse framtida behov.'), 'https://www.builder.as', 'assets/images/exhibitors/nordbygg-2026-builder-as.jpg'),
  ('nordbygg-2026-exhibitor-135776', 'nordbygg-2026', 'Burlington / Brittania Bad AB', 'A07:15', jsonb_build_object('en', 'Brittania Bad is a complete collection of various English brands in classic Victorian style. England has been the leading country in bathroom design since the turn of the previous century, and the bathroom collection has therefore been put together to suit the Swedish market. Our products make it possible to create an old-fashioned bathroom in elegant English style.', 'sv', 'Brittania Bad är en komplett kollektion av olika engelska varumärken med klassisk viktoriansk stil. England har varit det ledande landet inom badrumsdesign sedan förra sekelskiftet och badrumskollektionen är därför sammansatt för att tillgodose den svenska marknaden. Våra produkter möjliggör skapandet av ett gammaldags badrum i elegant engelsk stil.'), 'https://www.brittaniabad.se', 'assets/images/exhibitors/nordbygg-2026-burlington-brittania-bad-ab.jpg'),
  ('nordbygg-2026-exhibitor-138683', 'nordbygg-2026', 'BWT Vattenteknik AB', 'A05:11', jsonb_build_object('en', 'BWT is Europe''s leading company in water treatment. With more than 90 years of experience, we offer tailored solutions for purifying, filtering and softening water – from municipal water supply and industrial processes to clean drinking water in the home.

Our technology – such as reverse osmosis, UV treatment, filter media and ion-exchange systems – is used in buildings, industry, hospitals, hotels, restaurants and private homes. By reducing limescale, energy use and wear, we help our customers protect their installations and save resources.', 'sv', 'BWT är Europas ledande företag inom vattenbehandling. Med över 90 års erfarenhet erbjuder vi skräddarsydda lösningar för att rena, filtrera och mjukgöra vatten - från kommunal vattenförsörjning och industriprocesser till rent dricksvatten i hemmet.

Vår teknik - som omvänd osmos, UV-rening, filtermedia och jonbytessystem - används i fastigheter, industrier, sjukhus, hotell, restauranger och privata bostäder. Genom att minska kalk, energiförbrukning och slitage hjälper vi våra kunder att skydda sina installationer och spara resurser.'), 'https://www.bwtwater.se', 'assets/images/exhibitors/nordbygg-2026-bwt-vattenteknik-ab.jpg'),
  ('nordbygg-2026-exhibitor-138813', 'nordbygg-2026', 'Bygg & teknik, Tidningen', 'C04:01', jsonb_build_object('en', 'Bygg & teknik is a building-engineering journal aimed at the specifying tier of the construction industry. Each issue has a theme such as Roof and Facade, Acoustics and Sound Insulation, Fire Protection, Concrete, Timber Construction Technology, or Geotechnics and Foundations.

Sweden''s oldest construction magazine - Founded in 1909', 'sv', 'Bygg & teknik är en byggnadsteknisk tidskrift som vänder sig till föreskrivande led i byggbranschen. Varje nummer har ett tema som Tak och Fasad, Akustik och ljudisolering, Brandskydd, Betong, Träbyggnadsteknik samt Geoteknik och grundläggning.

Sveriges äldsta Byggtidning - Grundad 1909'), 'https://www.byggteknikforlaget.se', 'assets/images/exhibitors/nordbygg-2026-bygg-teknik-tidningen.jpg'),
  ('nordbygg-2026-exhibitor-137820', 'nordbygg-2026', 'Byggbranschens säkerhetspark', 'B04:41', jsonb_build_object('en', 'Byggbranschens utbildningscenter is the training arm of Byggföretagen (the Swedish Construction Federation). We offer industry-focused training that strengthens skills in building and civil engineering, for both site workers and salaried staff. You can take courses in the classroom, at a distance, or at Byggbranschens säkerhetspark, the construction industry''s safety park.

At Byggbranschens säkerhetspark you encounter a simulated construction site of 15,000 m². Here we work through scenarios that reflect real risks, such as excavations, working at height, vibrations, dust and noise. You discuss risks, roles and responsibilities in the construction process. The result is better conditions for safe working methods, fewer incidents and a more sustainable working life.

We help you pin down your competence needs and choose the right next step based on your role, your projects and current requirements.', 'sv', 'Byggbranschens utbildningscenter är Byggföretagens utbildningsverksamhet. Vi erbjuder branschnära utbildningar som stärker kompetensen i bygg och anläggning, för både yrkesarbetare och tjänstemän. Du kan gå utbildning i klassrum, på distans eller i Byggbranschens säkerhetspark.

I Byggbranschens säkerhetspark möter du en simulerad byggarbetsplats på 15 000 kvm. Här går vi igenom scenarier som speglar verkliga risker, till exempel schakter, arbete på höjd, vibrationer, damm och buller. Du får diskutera risker, roller och ansvar i byggprocessen. Det ger bättre förutsättningar för säkra arbetssätt, färre tillbud och ett mer hållbart arbetsliv.

Vi hjälper dig att ringa in kompetensbehovet och välja rätt nästa steg utifrån din roll, dina projekt och aktuella krav.'), 'https://www.buc.se', 'assets/images/exhibitors/nordbygg-2026-byggbranschens-sakerhetspark.jpg'),
  ('nordbygg-2026-exhibitor-136739', 'nordbygg-2026', 'Byggföretagen', 'C04:10', null, 'https://www.byggforetagen.se', null),
  ('nordbygg-2026-exhibitor-138415', 'nordbygg-2026', 'Byggkeramikrådet AB', 'AG:12', jsonb_build_object('en', 'Byggkeramikrådet (BKR), the Swedish Tile Council, was founded in 1989 by Plattsättningsentreprenörerna (PER) and Kakelföreningen (KAF) to bring contractors and suppliers in tile and ceramic-tile work – byggkeramik – together in a single organisation.

Today BKR is a leading authority on the use of ceramic materials in both wet rooms and other environments. Our industry rules for wet rooms (BBV) are an established norm for professional execution of ceramic construction in wet rooms. The industry rules are updated every five years, and now in 2026 we have just launched BBV 26:1. For that reason we are exhibiting together with Säker Vatten in a joint stand, where we invite you to come and discuss the industry rules with us.

Register for a free ticket here: https://nordbygg.se/for-besokare/infor-ditt-besok/biljetter/

In addition to BBV, Byggkeramikrådet produces guidelines and technical recommendations for various specialist areas where ceramics are used. An important part of our work is also training and authorisation: we train tile-laying contractors and inform stakeholders across the construction industry – from insurance companies and inspectors to estate agents.

Through our technical committee and joint industry working groups, we drive the development of construction and application techniques as well as new testing methods.

Our goal is to ensure a high-quality and sustainable use of one of the world''s oldest building materials – as natural, durable and beautiful in the future as it has been for thousands of years.', 'sv', 'Byggkeramikrådet (BKR) bildades 1989 av Plattsättningsentreprenörerna (PER) och Kakelföreningen (KAF) för att samla entreprenörer och leverantörer inom kakel och klinker – byggkeramik – i en gemensam organisation.

Idag är BKR en ledande auktoritet när det gäller användning av keramiska material i både våtrum och andra miljöer. Våra Branschregler för våtrum (BBV) är etablerad norm för fackmässigt utförande av keramiska konstruktioner i våtrum. Branschreglerna uppdateras vart femte år och nu 2026 har vi precis lanserat BBV 26:1. Av den anledningen ställer vi ut tillsammans med Säker Vatten, i en gemensam monter, där vi bjuder in till att prata branschregler med oss!

Registrera dig för fribiljett här: https://nordbygg.se/for-besokare/infor-ditt-besok/biljetter/

Utöver BBV tar Byggkeramikrådet fram riktlinjer och tekniska rekommendationer för olika specialområden där keramik används. En viktig del av verksamheten är också utbildning och behörighet, där vi utbildar plattsättningsentreprenörer samt informerar aktörer i hela byggbranschen – från försäkringsbolag och besiktningsmän till fastighetsmäklare.

Genom vår tekniska kommitté och branschgemensamma arbetsgrupper driver vi utvecklingen av konstruktions- och applikationsteknik samt nya provningsmetoder.

Vårt mål är att säkerställa en kvalitativ och hållbar användning av ett av världens äldsta byggmaterial – lika naturligt, hållbart och vackert i framtiden som det varit under tusentals år.'), 'https://www.bkr.se', 'assets/images/exhibitors/nordbygg-2026-byggkeramikradet-ab.jpg'),
  ('nordbygg-2026-exhibitor-138071', 'nordbygg-2026', 'Bygglovsexperten', 'AG:56', null, 'https://www.bygglovsexperten.se', null),
  ('nordbygg-2026-exhibitor-139406', 'nordbygg-2026', 'Byggsektorns Miljöberäkningsplattform', 'EH:15', jsonb_build_object('en', 'Training, personal advice and a leading calculation platform for climate declarations.', 'sv', 'Utbildning, personlig rådgivning och en ledande beräkningsplattform för klimatdeklarationer.'), 'https://bm.se/', 'assets/images/exhibitors/nordbygg-2026-byggsektorns-miljoberakningsplattform.jpg'),
  ('nordbygg-2026-exhibitor-133991', 'nordbygg-2026', 'Byggström', 'B08:21', jsonb_build_object('en', 'Malmbergs is a leading electrical wholesaler in the Nordic market for installers,
industrial, construction and rental companies as well as resellers.

Bygg-Ström® is the brand we use for professional users on construction sites and rental businesses that need safe, usable products to carry out work in temporary power.

"Bygg-Ström tailors practical, competitive and functional products for the temporary-power sector."', 'sv', 'Malmbergs är ett ledande handelshus i el på den nordiska marknaden för installatörer,
industri-, bygg- och uthyrningsföretag samt återförsäljare.

Bygg-Ström® är varumärket där vi vänder oss till professionella användare på byggen samt uthyrning som behöver säkra och användbara produkter för att kunna utföra arbete inom tillfällig el.

”Bygg-Ström anpassar praktiska, prisvärda och funktionella produkter för branschen inom tillfällig el”.'), 'https://www.malmbergs.com', 'assets/images/exhibitors/nordbygg-2026-byggstrom.jpg'),
  ('nordbygg-2026-exhibitor-138682', 'nordbygg-2026', 'Byggvarubedömningen', 'C05:04', null, 'https://www.byggvarubedomningen.se', 'assets/images/exhibitors/nordbygg-2026-byggvarubedomningen.jpg'),
  ('nordbygg-2026-exhibitor-136806', 'nordbygg-2026', 'C03:41', 'C07:51', jsonb_build_object('en', 'Hasopor – sustainable solutions for construction, homes and outdoor environments

Hasopor presents innovative solutions with foam glass — a lightweight, strong and environmentally friendly material made from 100% recycled glass. The material combines low weight with high load-bearing capacity along with insulating, drainage and capillary-breaking properties, making it ideal for modern construction projects.

For houses and gardens, Hasopor is used for foundations, insulation of foundation walls, drainage, and the construction of footpaths and driveways. The solutions contribute to energy efficiency, reduced ground pressure, and long-term durability.

Discover smarter building — with a focus on function, climate and the future.', 'sv', 'Hasopor – hållbara lösningar för bygg, hus och utemiljö

Hasopor presenterar innovativa lösningar med skumglas – ett lätt, starkt och miljövänligt material tillverkat av 100 % återvunnet glas. Materialet kombinerar låg vikt med hög bärighet samt isolerande, dränerande och kapillärbrytande egenskaper, vilket gör det idealiskt för moderna byggprojekt.

Inom hus och trädgård används Hasopor bland annat för grundläggning, isolering av grundmurar, dränering och uppbyggnad av gångvägar och uppfarter. Lösningarna bidrar till energieffektivitet, minskat marktryck och lång hållbarhet.

Upptäck smartare byggande – med fokus på funktion, klimat och framtid.'), 'https://www.hasopor.se', 'assets/images/exhibitors/nordbygg-2026-c03-41.jpg'),
  ('nordbygg-2026-exhibitor-139781', 'nordbygg-2026', 'C2 Elements ApS', 'EÖ:06', null, 'https://www.c2elements.dk/kontakt', 'assets/images/exhibitors/nordbygg-2026-c2-elements-aps.jpg'),
  ('nordbygg-2026-exhibitor-138817', 'nordbygg-2026', 'CABSEAL Sweden', 'A15:25', jsonb_build_object('en', 'CABSEAL manufactures and produces customer-specific products in a range of soft plastic and rubber-based materials, with a focus on gaskets, seals and insulation.', 'sv', 'CABSEAL tillverkar och producerar kundspecifika produkter i diverse mjuka plast och gummibaserade material, med inriktning mot packningar, tätningar & isolering.'), 'https://www.cabseal.se', 'assets/images/exhibitors/nordbygg-2026-cabseal-sweden.jpg'),
  ('nordbygg-2026-exhibitor-134605', 'nordbygg-2026', 'Calectro AB', 'A15:13', jsonb_build_object('en', 'News at this year''s Nordbygg fair!

Welcome to our stand and discover our new product range for demand-controlled ventilation — developed to meet the needs of installers, consultants and purchasing managers.
The range consists of two controllers (CRC) and two transmitters (CRT), all focused on energy efficiency, easy installation and long service life.

We are also presenting new models of our latest smoke detector for ventilation systems, Uniguard 8. It is now available in versions with Modbus communication combined with either a display or a Bluetooth connection. In both models you can quickly and easily read the smoke detector''s level of contamination — directly on the display or via an app on your smartphone. Incredibly convenient!

See you in stand A15:13!', 'sv', 'Nyheter på årets Nordbygg-mässa!

Välkommen till vår monter och upptäck vår nya produktserie för behovsstyrd ventilation – utvecklad för att möta kraven från installatörer, konsulter och inköpsansvariga.
Serien består av två regulatorer (CRC) och två transmittrar (CRT), alla med fokus på energieffektivitet, enkel installation och lång livslängd.

Vi presenterar även nya modeller av vår senaste rökdetektor för ventilationssystem, Uniguard 8. Den finns nu i versioner med Modbus-kommunikation i kombination med antingen display eller blåtandsuppkoppling. I båda modellerna kan du snabbt och enkelt läsa av rökdetektorns försmutsningsgrad – direkt i displayen eller via en app i din smartphone. Otroligt smidigt!

Vi ses i monter A15:13!'), 'https://www.calectro.se', 'assets/images/exhibitors/nordbygg-2026-calectro-ab.jpg'),
  ('nordbygg-2026-exhibitor-138854', 'nordbygg-2026', 'CALEFFI HYDRONIC SOLUTIONS', 'A11:25', null, 'https://www.caleffi.com/en-int', 'assets/images/exhibitors/nordbygg-2026-caleffi-hydronic-solutions.jpg'),
  ('nordbygg-2026-exhibitor-138565', 'nordbygg-2026', 'CAMELEO GROUP', 'C05:72', null, 'https://www.cameleo.pl', 'assets/images/exhibitors/nordbygg-2026-cameleo-group.jpg'),
  ('nordbygg-2026-exhibitor-135981', 'nordbygg-2026', 'Camfil Svenska AB', 'A19:15', jsonb_build_object('en', 'We help people breathe cleaner air — since 1963
Come and visit us and talk to our experts about how we can create a healthy and productive indoor environment for you. With the right filtration solutions you get good indoor air quality, whether you work in an office, school, warehouse or factory. You also save energy, and therefore money.

Among other things, we will be showing our latest product innovations!

Compete and win
Our AIRhockey competition runs throughout the fair and gives you the chance to win great prizes.

Want to know more about us? Visit camfil.se.

You can also follow us on social media:
Facebook - www.Facebook.com/CamfilSverige
LinkedIn - www.linkedin.com/company/camfilsverige
YouTube - www.youtube.com/@CamfilSvenska', 'sv', 'Vi hjälper människor andas renare luft - sedan 1963
Kom förbi oss och prata med våra experter om hur vi kan skapa en hälsosam och produktiv innemiljö för just er. Med rätt filtreringslösningar kan du få en god luftkvalitet inomhus, oavsett om du jobbar på kontor, skola, lager eller i fabrik. Du sparar dessutom energi och därmed pengar.

Bland annat kommer vi att visa våra senaste produktinnovationer!

Tävla och vinn
I vår AIRhockey tävling som pågår under mässans alla dagar har du chansen att vinna fina priser.

Vill du veta mer om oss? Välkommen till camfil.se.

Du kan även följa oss på Sociala medier:
Facebook - www.Facebook.com/CamfilSverige
LinkedIn - www.linkedin.com/company/camfilsverige
YouTube - www.youtube.com/@CamfilSvenska'), 'https://www.camfil.se', 'assets/images/exhibitors/nordbygg-2026-camfil-svenska-ab.jpg'),
  ('nordbygg-2026-exhibitor-134509', 'nordbygg-2026', 'Carhartt Workwear', 'B01:10', null, 'https://www.feiber.se', null),
  ('nordbygg-2026-exhibitor-137417', 'nordbygg-2026', 'Carlmarks (LIROS Skandinavia AB)', 'B04:40', null, 'https://www.lirosropes.se', 'assets/images/exhibitors/nordbygg-2026-carlmarks-liros-skandinavia-ab.jpg'),
  ('nordbygg-2026-exhibitor-138411', 'nordbygg-2026', 'Carlo Casagrande & Co Oy', 'C06:34', jsonb_build_object('en', 'The story of Carlo Casagrande & Co began in 1959.

At that time, Carlo Casagrande founded an import company in Finland, primarily importing lighting and electrotechnical components. Casagrande''s father was Italian and his mother German, so internationalism was a natural part of the company''s everyday life from the very start.

CC & Co has grown steadily and established itself in Finland as a leading partner in the furniture industry, with the broadest range of furniture, kitchen and interior components in the sector. Over the years the company has been polished into a unique diamond — where European innovation and design meet the internationally recognised Finnish precision.

CC & Co is today a fourth-generation family business, but the core values remain the same: CC & Co is an international, responsible, forward-thinking and inspiring partner that delivers on its promises — and offers a little more.

That is how you achieve results, summarised in our slogan:

"Changing spaces into special places."', 'sv', 'Historien om Carlo Casagrande & Co började år 1959.

Vid den tiden grundade Carlo Casagrande ett importföretag i Finland, som främst importerade belysning och elektrotekniska komponenter. Casagrandes far var italienare och hans mor tysk, så internationalitet blev redan från början en naturlig del av företagets vardag.

CC & Co har vuxit stadigt och i Finland etablerat sig som en ledande partner inom möbelbranschen, med det bredaste sortimentet av möbel-, köks- och inredningskomponenter i branschen. Under årens gång har företaget slipat sig till en unik diamant – där europeisk innovation och design möter den internationellt uppskattade finska precisionen.

CC & Co är idag ett familjeföretag i fjärde generationen, men de grundläggande värderingarna är desamma: CC & Co är en internationell, ansvarsfull, nytänkande och inspirerande partner som håller vad det lovar – och erbjuder lite mer.

Det är så man når resultat, som finns sammanfattade i vår slogan:

"Changing spaces into special places."'), 'https://www.carlocasagrande.fi', 'assets/images/exhibitors/nordbygg-2026-carlo-casagrande-co-oy.jpg'),
  ('nordbygg-2026-exhibitor-138818', 'nordbygg-2026', 'Carlo Gavazzi AB', 'A14:11', null, 'https://www.carlogavazzi.se', 'assets/images/exhibitors/nordbygg-2026-carlo-gavazzi-ab.jpg'),
  ('nordbygg-2026-exhibitor-137904', 'nordbygg-2026', 'Carpings/Bra Gross/VSP', 'A04:17', null, 'https://www.carpings.se', 'assets/images/exhibitors/nordbygg-2026-carpings-bra-gross-vsp.jpg'),
  ('nordbygg-2026-exhibitor-135753', 'nordbygg-2026', 'Carrier AB', 'A20:22', jsonb_build_object('en', 'About Carrier
Carrier is a global leader in intelligent climate and energy solutions focused on providing differentiated, digitally enabled lifecycle solutions to our customers.
Through our performance-driven culture, we focus on creating long-term shareowner value by investing strategically to strengthen our position in homes, buildings and across the cold chain to drive profitable growth.
Innovative solutions for a sustainable future.

Sustainability at the core
As the world recognizes the increasing urgency of climate change, and secular trends continue to increase the demand for HVAC and refrigeration products, Carrier is committed to aggressive actions that minimize our environmental impact and help address the most critical challenge our planet has ever faced.
Through our road map to net zero, we are driving reductions in greenhouse gas emissions across our value chain by 2050.

A complete portfolio for all markets
Carrier is at the forefront of delivering cutting-edge HVAC, refrigeration and building automation solutions.
Our commitment to sustainability and innovation ensures that we meet the diverse needs of residential, commercial and industrial customers worldwide.
Together with Viessmann, we offer a complete and complementary portfolio built around strong, leading brands in each segment.

Carrier – Leading brand in Commercial
Carrier’s commercial solutions are designed to optimize building performance and profitability.
Our portfolio includes state-of-the-art chillers, building automation systems and innovative design tools that empower businesses to create smarter, more efficient spaces. Every solution is backed by decades of expertise and a relentless focus on sustainability, helping reduce environmental impact while supporting long-term performance.

Viessmann – Leading brand in Residential
We are Viessmann Climate Solutions. Founded in 1917 as a heating technology manufacturer, and now part of Carrier, today we are one of the world''s leading providers of efficient and systemic climate (heating, water and air quality) and renewable energy solutions for the residential and commercial sector.
Our integrated solution offering seamlessly connects products and systems via digital platforms and services to a holistic climate and energy solution, thus creating a safe and reliable feel-good climate for our users. All activities are driven by our company purpose, "We create living spaces for generations to come". This is the responsibility that we take on every day together with our (trade) partners.

One partner. One vision. One complete solution.
Together, these complementary portfolios enable the transition toward more sustainable, efficient and intelligent buildings, covering residential, commercial and industrial applications through a single, coherent offering.', 'sv', 'Om Carrier
Carrier är en global ledare inom intelligenta klimat- och energilösningar med fokus på att leverera differentierade, digitalt anpassade lösningar för hela livscykeln till våra kunder.
Genom vår prestationsdrivna kultur fokuserar vi på att skapa långsiktigt aktieägarvärde genom strategiska investeringar som stärker vår position inom bostäder, byggnader och längs hela kylkedjan för att driva lönsam tillväxt.
Innovativa lösningar för en hållbar framtid.

Hållbarhet i centrum
När världen inser den allt större brådskan med klimatförändringarna, och långsiktiga trender fortsätter att öka efterfrågan på VVS- och kylprodukter, åtar sig Carrier att vidta kraftfulla åtgärder för att minimera vår miljöpåverkan och bidra till att möta den mest kritiska utmaning vår planet någonsin har stått inför.
Genom vår färdplan mot nettonoll driver vi minskningar av växthusgasutsläpp i hela vår värdekedja till 2050.

En komplett portfölj för alla marknader
Carrier ligger i framkant när det gäller att leverera spjutspetslösningar inom VVS, kyla och fastighetsautomation.
Vårt åtagande för hållbarhet och innovation säkerställer att vi möter de skiftande behoven hos bostads-, kommersiella och industriella kunder över hela världen.
Tillsammans med Viessmann erbjuder vi en komplett och kompletterande portfölj uppbyggd kring starka, ledande varumärken i varje segment.

Carrier – Ledande varumärke inom kommersiella lösningar
Carriers kommersiella lösningar är utformade för att optimera fastigheters prestanda och lönsamhet.
Vår portfölj omfattar toppmoderna kylmaskiner, fastighetsautomationssystem och innovativa designverktyg som ger företag möjlighet att skapa smartare och mer effektiva utrymmen. Varje lösning bygger på decennier av expertis och ett obevekligt fokus på hållbarhet, vilket bidrar till minskad miljöpåverkan samtidigt som den långsiktiga prestandan stöds.

Viessmann – Ledande varumärke inom bostäder
Vi är Viessmann Climate Solutions. Grundat 1917 som tillverkare av värmeteknik, och nu en del av Carrier, är vi i dag en av världens ledande leverantörer av effektiva och systemiska klimat- (värme, vatten och luftkvalitet) samt förnybara energilösningar för bostads- och kommersiell sektor.
Vårt integrerade lösningserbjudande kopplar sömlöst samman produkter och system via digitala plattformar och tjänster till en helhetslösning för klimat och energi, och skapar därmed ett tryggt och pålitligt välmåendeklimat för våra användare. All vår verksamhet drivs av vårt företagssyfte: "Vi skapar livsmiljöer för kommande generationer". Det är det ansvar vi tar varje dag tillsammans med våra (bransch-)partners.

En partner. En vision. En komplett lösning.
Tillsammans möjliggör dessa kompletterande portföljer omställningen mot mer hållbara, effektiva och intelligenta byggnader, och täcker bostads-, kommersiella och industriella tillämpningar genom ett enda sammanhållet erbjudande.'), 'https://www.carrier.com/commercial/sv/se', 'assets/images/exhibitors/nordbygg-2026-carrier-ab.jpg'),
  ('nordbygg-2026-exhibitor-138197', 'nordbygg-2026', 'CatchShift', 'B08:10', jsonb_build_object('en', 'For over a decade, we have been active in the vacuum lifter market. At Catchshift, we combine experience with modernity, developing devices that define the future of construction. We offering groundbreaking solutions in the transport and installation of concrete and paving elements.

The Catchshift brand is headquartered in Wolsztyn, Poland.

Catchshift vacuum lifters are designed with maximum safety and efficiency in mind. We utilize advanced technologies. Our vacuum lifters are designed and manufactured from start to finish in Poland. New machine designs are based on feedback gathered from customer interviews. We focus on quality feedback from the companies we collaborate with and our clients.', 'sv', 'I över ett decennium har vi varit aktiva på marknaden för vakuumlyftare. På Catchshift kombinerar vi erfarenhet med modernitet och utvecklar maskiner som definierar framtidens byggande. Vi erbjuder banbrytande lösningar för transport och montage av betong- och beläggningselement.

Varumärket Catchshift har sitt huvudkontor i Wolsztyn, Polen.

Catchshifts vakuumlyftare är konstruerade med maximal säkerhet och effektivitet i åtanke. Vi använder avancerad teknik. Våra vakuumlyftare konstrueras och tillverkas från början till slut i Polen. Nya maskinkonstruktioner bygger på återkoppling som samlats in genom kundintervjuer. Vi fokuserar på kvalitativ återkoppling från de företag vi samarbetar med och från våra kunder.'), 'https://www.catchshift.com', 'assets/images/exhibitors/nordbygg-2026-catchshift.jpg'),
  ('nordbygg-2026-exhibitor-134686', 'nordbygg-2026', 'Cederroth First Aid', 'B03:41', null, 'https://www.cederroth.com', 'assets/images/exhibitors/nordbygg-2026-cederroth-first-aid.jpg'),
  ('nordbygg-2026-exhibitor-136418', 'nordbygg-2026', 'Cellglas Sweden AB', 'C06:50', jsonb_build_object('en', 'Cellglas Sweden works to replace fire- and environmentally hazardous insulation and building materials. Thanks to the remarkable material properties of foam glass, we can simultaneously reduce or completely remove steel and concrete in foundations, among other things.
Our foam glass is made from recycled glass. It has the lowest CO2 equivalent in the industry and can be reused for many generations to come.', 'sv', 'Cellglas Sweden arbetar för att ersätta brand- och miljöfarliga isolerings- och byggmaterial. På grund av cellglasets fantastiska materialegenskaper kan vi samtidigt minska eller helt ta bort stål och betong i bl.a. grunder.
Vårt cellglas är gjort av återvunnet glas. Det har lägsta CO2-ekv i branschen och kan återbrukas i många generationer framåt.'), 'https://cellglas.com', 'assets/images/exhibitors/nordbygg-2026-cellglas-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-139407', 'nordbygg-2026', 'Centrum för Cirkulärt Byggande', 'EH:15', jsonb_build_object('en', 'CCBuild is a platform for actors who want to contribute to a more sustainable and resource-efficient construction sector. In our network, nearly 200 organisations work together to strengthen the market for circular products and services and to establish circular ways of working.', 'sv', 'CCBuild är en plattform för aktörer som vill bidra till ett mer hållbart och resurseffektivt byggande. I vårt nätverk samverkar nära 200 organisationer för att stärka marknaden för cirkulära produkter och tjänster samt etablera cirkulära arbetssätt.'), 'https://ccbuild.se/', 'assets/images/exhibitors/nordbygg-2026-centrum-for-cirkulart-byggande.jpg'),
  ('nordbygg-2026-exhibitor-138254', 'nordbygg-2026', 'Certo Software', 'C11:41D', jsonb_build_object('en', 'Certo Software is a cloud-based software for manufacturers and installers of windows, doors and facade products. With Certo, companies can manage the entire project chain in a single system — from quotation to production, installation and service.

The software helps companies meet standards and documentation requirements for construction products and streamlines daily work. In Certo you can easily create and manage documents such as CE marking, declarations of performance (DoP), in-house controls, installation reports and service visits.

Certo integrates with the construction software commonly used in the industry, such as LogiKal (Forterro), SchüCal and PursoCal. The program also includes a database with several common profile systems and their performance values, which makes documentation faster and easier to create.

Certo supports profile systems including: Aluprof, Forster, Jansen, Purso, Rehau, Reynaers, Sapa, Schüco, Stålprofil, VEKA and Wicona.', 'sv', 'Certo Software är en molnbaserad programvara för tillverkare och installatörer av fönster, dörrar och fasadprodukter. Med Certo kan företag hantera hela projektkedjan i ett och samma system – från offert till produktion, montage och service.

Programvaran hjälper företag att uppfylla standard- och dokumentationskrav för byggprodukter och effektiviserar det dagliga arbetet. I Certo kan man enkelt skapa och hantera dokument såsom CE-märkning, prestandadeklarationer (DoP), egenkontroller, installationsprotokoll och servicebesök.

Certo har integrationer med vanligt förekommande konstruktionsprogram i branschen, såsom LogiKal (Forterro), SchüCal och PursoCal. Programmet innehåller även en databas med flera vanliga profilsystem och deras prestandavärden, vilket gör dokumentationen snabbare och enklare att skapa.

Certo stöder bland annat följande profilsystem: Aluprof, Forster, Jansen, Purso, Rehau, Reynaers, Sapa, Schüco, Stålprofil, VEKA och Wicona.'), 'https://www.certo-software.com', 'assets/images/exhibitors/nordbygg-2026-certo-software.jpg'),
  ('nordbygg-2026-exhibitor-133974', 'nordbygg-2026', 'Cetetherm', 'A04:19', jsonb_build_object('en', 'Cetetherm, part of NIBE Group, develops innovative energy solutions for heating and cooling. Solutions that are smart, connected and designed to lower costs. With more than 70 years of experience and roots in Swedish engineering, Cetetherm makes choosing an energy solution safe and easy.

We offer energy-efficient, smart and connected products and solutions with minimal environmental impact.

Hybrid energy — two energy sources, one future.
We also offer solutions that are compatible with other energy sources such as heat pumps, where we combine renewable energy for optimal flexibility and efficiency.

Welcome to talk with us about lower energy losses, digital control and maximum efficiency.

Cetetherm is heating a new generation.', 'sv', 'Cetetherm som ingår i NIBE Group, utvecklar innovativa energilösningar för värme och kyla. Lösningar som är smarta, uppkopplade och utformade för att sänka kostnader. Med över 70 års erfarenhet och rötterna i svensk ingenjörskonst gör Cetetherm valet av energilösning tryggt och enkelt.

Vi erbjuder energieffektiva, smarta och uppkopplade produkter och lösningar med minimal miljöpåverkan.

Hybridenergi - två energikällor, en framtid.
Vi erbjuder även lösningar som är kompatibla med andra energikällor som exempelvis värmepumpar där vi förenar förnybar energi för optimal flexibilitet och effektivitet.

Välkommen att prata mindre energiförluster, digital kontroll och maximal effektivitet med oss.

Cetetherm värmer en ny generation.'), 'https://www.cetetherm.com/sv', 'assets/images/exhibitors/nordbygg-2026-cetetherm.jpg'),
  ('nordbygg-2026-exhibitor-137938', 'nordbygg-2026', 'CEWOOD', 'C12:53', jsonb_build_object('en', 'CEWOOD is one of the world''s leading manufacturers of wood wool boards and the only producer of its kind in the Baltics.
We combine more than 60 years of experience with modern production technology to deliver high-quality, sustainable and reliable solutions for construction and interior projects.
CEWOOD boards are made from natural raw materials — wood wool, cement and water. They offer:
•	very good sound absorption and acoustic comfort;
•	high fire safety;
•	long service life and dimensional stability;
•	a healthy indoor climate;
•	great design freedom.

Our products are used in schools, offices, public spaces and residential projects across international markets.
CEWOOD focuses on sustainable production, efficient solutions and long-term partnerships with architects, designers and building actors.', 'sv', 'CEWOOD är en av världens ledande tillverkare av träullsplattor och den enda producenten i sitt slag i Baltikum.
Vi kombinerar över 60 års erfarenhet med modern produktionsteknik för att erbjuda högkvalitativa, hållbara och pålitliga lösningar för bygg- och inredningsprojekt.
CEWOOD-plattor tillverkas av naturliga råvaror – träull, cement och vatten. De erbjuder:
•	mycket god ljudabsorption och akustisk komfort;
•	hög brandsäkerhet;m
•	lång livslängd och formstabilitet;
•	ett hälsosamt inomhusklimat;
•	stor designfrihet.

Våra produkter används i skolor, kontor, offentliga miljöer och bostadsprojekt på internationella marknader.
CEWOOD fokuserar på hållbar produktion, effektiva lösningar och långsiktiga samarbeten med arkitekter, designers och byggaktörer.'), 'https://www.cewood.com', 'assets/images/exhibitors/nordbygg-2026-cewood.jpg'),
  ('nordbygg-2026-exhibitor-133975', 'nordbygg-2026', 'CH Ståldörrar AB', 'C16:41', jsonb_build_object('en', 'CH Ståldörrar specialises in steel security doors and fire doors. Our doors have been developed together with employees who have very long experience in the industry. Our manufacturing line in Eskilstuna is one of the most modern in the world.', 'sv', 'CH Ståldörrar är specialiserade på säkerhetsdörrar och branddörrar av stål. Våra dörrar är framtagna tillsammans med medarbetare som har mycket lång erfarenhet i branschen. Vår tillverkningslina i Eskilstuna är en av de mest moderna i världen.'), 'https://www.chstaldorrar.se', 'assets/images/exhibitors/nordbygg-2026-ch-staldorrar-ab.jpg'),
  ('nordbygg-2026-exhibitor-137264', 'nordbygg-2026', 'Chiller Sverige AB', 'A13:21', jsonb_build_object('en', 'Chiller is a leading expert in the cooling, heating and air-handling industry. We design and manufacture solutions tailored to customer-specific needs and assist the customer from planning through to implementation. Chiller develops and manufactures all its products in its own factories in Finland and provides maintenance for them throughout their entire lifecycle.', 'sv', 'Chiller är ledande experter inom kyl-, värme- och luftbehandlingsbranschen. Vi designar och tillverkar lösningar efter kundspecifika behov och assisterar kunden från planering till implementering. Chiller utvecklar och tillverkar samtliga produkter i egna fabriker i Finland och utför underhåll på dem under hela livscykeln.'), 'https://www.chiller.eu', 'assets/images/exhibitors/nordbygg-2026-chiller-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-137908', 'nordbygg-2026', 'Christian Berner', 'C09:52', jsonb_build_object('en', 'At Christian Berner we work with vibration isolation where the demands are at their highest and the margins at their smallest. Whether it concerns buildings for people, infrastructure in continuous operation, or industrial environments with sensitive and heavy equipment, our solutions are based on the same principle: control vibrations where they arise and prevent them from spreading further.

With experience from house foundations, slabs and acoustic solutions to railway systems, marine applications and industrial installations, we help you with overall responsibility — from technical analysis and dimensioning to the right solution for each application. The result is robust function, long service life and environments that work in practice.', 'sv', 'Vi på Christian Berner arbetar med vibrationsisolering där kraven är som högst och marginalerna som minst. Oavsett om det gäller byggnader för människor, infrastruktur i ständig drift eller industriella miljöer med känslig och tung utrustning, utgår våra lösningar från samma princip: att kontrollera vibrationer där de uppstår och förhindra att de sprids vidare.

Med erfarenhet från husgrunder, bjälklag, akustiklösningar till järnvägssystem, marina applikationer och industriella installationer hjälper vi er med ett helhetsansvar - från teknisk analys och dimensionering till rätt lösning för varje applikation. Resultatet är robust funktion, lång livslängd och miljöer som fungerar i praktiken.'), 'https://christianberner.se', 'assets/images/exhibitors/nordbygg-2026-christian-berner.jpg'),
  ('nordbygg-2026-exhibitor-133943', 'nordbygg-2026', 'CIDAN Machinery Sweden AB', 'C18:41', jsonb_build_object('en', 'CIDAN Machinery Group is your one-stop partner in sheet-metal processing, offering a global presence that ensures access to the market''s broadest range of innovative products, software solutions and comprehensive service programs.

Our range includes everything from smart software to folding machines, machine guillotines and slitting lines, giving you the tools required to take your business to the next level. With over 117 years of experience in the industry, we help you optimise your production with precision and innovation.', 'sv', 'CIDAN Machinery Group är din one-stop-partner inom plåtbearbetning, och erbjuder en global närvaro som säkerställer tillgång till marknadens bredaste utbud av innovativa produkter, mjukvarulösningar och omfattande serviceprogram.

Vårt sortiment inkluderar allt från smart programvara till kantvikmaskiner, maskingradsaxar och klippsträckor, vilket ger dig de verktyg som krävs för att ta din verksamhet till nästa nivå. Med över 117 års erfarenhet i branschen, hjälper vi dig att optimera din produktion med precision och innovation.'), 'https://se.cidanmachinery.com/', 'assets/images/exhibitors/nordbygg-2026-cidan-machinery-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-137659', 'nordbygg-2026', 'Clean Burn Trading AB', 'Ute:56 (+1)', jsonb_build_object('en', 'We believe choosing the green option should be easy. That is why we make sure our solutions are not only environmentally friendly. Equally important is that you as a customer should feel confident that you are getting top-quality products at a reasonable price.
We are passionate about creating a better environment. Literally. Our heating systems are designed to minimise carbon dioxide emissions and particulates, and thereby have a minimal negative environmental impact.', 'sv', 'Vi tycker att det ska vara enkelt att välja det gröna alternativet. Därför ser vi till att våra lösningar inte bara är miljövänliga. Lika viktigt är att du som kund ska känna dig trygg i att du får högklassig kvalitet till ett rimligt pris.
Vi brinner för att skapa en bättre miljö. Bokstavligen. Våra värmesystem är utformade för att minimera koldioxidutsläpp och partiklar, och därmed ha en minimal negativ miljöpåverkan.'), 'https://Cleanburn.se', null),
  ('nordbygg-2026-exhibitor-140190', 'nordbygg-2026', 'Clean Water', 'AG:29', jsonb_build_object('en', 'Clean Water delivers reliable and modern solutions in water treatment, with particular expertise in well treatment and the desalination of seawater.
We work closely with pipe installers, wholesalers, associations, companies and municipalities, and offer proven systems that ensure clean and safe water in both small and larger installations.
One of our strengths is our expertise in interpreting water analyses. By analysing water values we can recommend the most cost-effective and technically correct solution for each project. This makes installations easier and reduces the risk of incorrect dimensioning or unnecessarily expensive systems.
We also act as technical support for our partners. We help with advice, dimensioning and product selection, and are available throughout the process — from quotation and design to installation and follow-up support.
Our goal is to be a reliable partner for installers and suppliers, with solutions that are easy to install, reliable in operation and sustainable over the long term.', 'sv', 'Clean Water levererar driftsäkra och moderna lösningar inom vattenrening, med särskild kompetens inom brunnsrening och avsaltning av havsvatten.
Vi samarbetar nära rörinstallatörer, grossister, föreningar, företag och kommuner och erbjuder beprövade system som säkerställer rent och säkert vatten i både små och större installationer.
En av våra styrkor är vår kompetens inom tolkning av vattenanalyser. Genom att analysera vattenvärden kan vi rekommendera den mest kostnadseffektiva och tekniskt rätta lösningen för varje projekt. Det gör installationerna enklare och minskar risken för fel dimensionering eller onödigt dyra system.
Vi fungerar också som tekniskt stöd för våra samarbetspartners. Vi hjälper till med rådgivning, dimensionering och produktval, och finns tillgängliga under hela processen – från offert och projektering till installation och efterföljande support.
Vårt mål är att vara en pålitlig partner för installatörer och leverantörer, med lösningar som är enkla att installera, driftsäkra och långsiktigt hållbara.'), 'https://Cleanwater.se', 'assets/images/exhibitors/nordbygg-2026-clean-water.jpg'),
  ('nordbygg-2026-exhibitor-139312', 'nordbygg-2026', 'ClimaPri', 'A14:36 (+1)', jsonb_build_object('en', 'ClimaPri is a Finnish company providing smart IoT solutions for buildings, enabling property owners, managers, and residents to monitor, manage, and optimize energy use, safety, and indoor conditions through one unified platform.', 'sv', 'ClimaPri är ett finskt företag som tillhandahåller smarta IoT-lösningar för fastigheter och gör det möjligt för fastighetsägare, förvaltare och boende att övervaka, hantera och optimera energianvändning, säkerhet och inomhusförhållanden via en enda samlad plattform.'), 'https://www.climapri.com', 'assets/images/exhibitors/nordbygg-2026-climapri.jpg'),
  ('nordbygg-2026-exhibitor-138939', 'nordbygg-2026', 'CLIMATEC', 'A09:30', jsonb_build_object('en', 'We deliver solutions in heating, cooling, ventilation and noise protection. Our HVAC products include air curtains, fan heaters, heat-recovery units and duct fans. Within Noise we deliver modular noise screens, sound hoods, enclosures, silencers, ventilation grilles and more.
Within HVAC, our focus is on commercial and industrial premises. We help you achieve the best function from an economic, climate and energy perspective. Within Noise Protection we design the right solution to create a good sound environment for noisy operations, both indoors and outdoors.', 'sv', 'Vi levererar lösningar inom värme, kyla, ventilation och bullerskydd. Våra produkter inom VVS består av ridåvärmare, fläktluftvärmare, värmeåtervinningsaggregat och kanalfläktar. Inom Buller så levererar vi modulära bullerskärmar, ljudhuvar, inbyggnader, ljuddämpare ventilationsgaller m.m.
Inom VVS är vårt fokus kommersiella och industrilokaler. Vi hjälper er med bästa funktion ur ett ekonomiskt, klimat- och energimässigt perspektiv. Inom Bullerskydd designar vi rätt lösning för att skapa god ljudmiljö vid bullrande verksamhet, både inomhus och utomhus.'), 'https://www.climatec.se', 'assets/images/exhibitors/nordbygg-2026-climatec.jpg'),
  ('nordbygg-2026-exhibitor-139385', 'nordbygg-2026', 'CMB Housing Factory', 'C04:41', jsonb_build_object('en', 'Prefab and modular building solutions for residential, public and commercial projects.

CMB is a reliable manufacturing partner for construction companies, property developers and investors.', 'sv', 'Prefab- och modulära bygglösningar för bostads-, offentliga och kommersiella projekt.

CMB är en pålitlig tillverkningspartner för byggföretag, fastighetsutvecklare och investerare.'), 'https://cmbprefab.com/en/home/', 'assets/images/exhibitors/nordbygg-2026-cmb-housing-factory.jpg'),
  ('nordbygg-2026-exhibitor-135323', 'nordbygg-2026', 'CMC Sweden AB', 'B04:10', null, 'https://www.cmcsweden.se', null),
  ('nordbygg-2026-exhibitor-138140', 'nordbygg-2026', 'CODI', 'C07:72', jsonb_build_object('en', 'We are a manufacturer of door entry phones and the systems connected to them (hardware and software).

Our innovative door entry phone solution increases both social and personal security.

Our technological crown jewels are:

GSM-based systems, self-disinfecting screens and data analytics — these technologies can change the future.

And you can change it together with us.', 'sv', 'Vi är en tillverkare av porttelefoner och system som är kopplade till dem (hårdvara och mjukvara).

Vår innovativa lösning för porttelefoner ökar både den sociala och personliga säkerheten.

Våra teknologiska kronjuveler är:

GSM-baserade system, självdessinfekterande skärmar samt dataanalys – dessa teknologier kan förändra framtiden.

Och du kan förändra den tillsammans med oss.'), 'https://www.codi.pl', 'assets/images/exhibitors/nordbygg-2026-codi.jpg'),
  ('nordbygg-2026-exhibitor-136559', 'nordbygg-2026', 'Colia Scandinavia AB', 'A16:30', null, 'https://www.colia.se', null),
  ('nordbygg-2026-exhibitor-138987', 'nordbygg-2026', 'Comfort', 'A08:10', jsonb_build_object('en', 'Comfort is one of Sweden''s largest installation actors within plumbing, electrical and ventilation. With a focus on energy efficiency, we develop and install technical solutions in electrical, heating, sanitation, piping and ventilation for offices, department stores, hospitals and industrial facilities.', 'sv', 'Comfort är en av Sveriges största installationsaktörer inom VS, el och ventilation. Med fokus på energieffektivitet utvecklar och installerar vi tekniska lösningar inom el, värme, sanitet, rör och ventilation för kontor, varuhus, sjukhus och industrianläggningar.'), 'https://comfort.se', 'assets/images/exhibitors/nordbygg-2026-comfort.jpg'),
  ('nordbygg-2026-exhibitor-134692', 'nordbygg-2026', 'Comfort Control AB', 'A16:33', null, 'https://www.comfort-control.se', null),
  ('nordbygg-2026-exhibitor-133966', 'nordbygg-2026', 'Comfortzone AB', 'A15:22', null, 'https://www.comfortzone.se', null),
  ('nordbygg-2026-exhibitor-139617', 'nordbygg-2026', 'Conaxity', 'BG:14', jsonb_build_object('en', 'Take control of your worksite.

Conaxity turns equipment into a shared, digital service.
No keys. No guesswork. No idle equipment.

Book, unlock, use and end the rental directly from your phone — while the platform tracks usage, ensures rules are followed and automates billing.

Reduce the fleet. Increase utilisation. Eliminate chaos.', 'sv', 'Ta kontroll över din arbetsplats.

Conaxity gör utrustning till en delad, digital tjänst.
Inga nycklar. Ingen gissning. Ingen stillastående utrustning.

Boka, lås upp, använd och avsluta hyra direkt från mobilen – samtidigt som plattformen spårar användning, säkerställer regler och automatiserar debitering.

Minska flottan. Öka nyttjandegraden. Eliminera kaos.'), 'https://conaxity.com/', 'assets/images/exhibitors/nordbygg-2026-conaxity.jpg'),
  ('nordbygg-2026-exhibitor-136628', 'nordbygg-2026', 'Condair AB', 'A17:20', jsonb_build_object('en', 'Condair AB – Experts in humidity control
Condair AB delivers professional solutions for controlling air humidity in commercial buildings and industrial environments. With long experience, we help our customers create stable, efficient and healthy indoor climates through advanced technology for humidification, dehumidification and adiabatic cooling.
The right humidity is crucial for protecting people, processes and materials. Our solutions are used in many different areas — from offices, hospitals and data centres to production, museums, archives and other environments where a stable indoor climate is essential.
Condair AB is part of the global Condair Group, headquartered in Switzerland. The group has more than 1,000 employees globally and operates five production facilities, delivering humidity-control solutions to customers worldwide.
In the Nordics we work in close, integrated cooperation between our local organisations. This gives us strong sales, service and administrative teams that together can offer high competence, fast service and solutions tailored to customer needs.
Our specialists work closely with consultants, contractors, property owners and industrial customers to develop solutions that ensure optimal air humidity, improved energy efficiency and long-term operational reliability.
By combining global expertise with a strong local presence, Condair delivers solutions that create better indoor climates, protect valuable assets and support efficient operations.', 'sv', 'Condair AB – Experter på fuktkontroll
Condair AB levererar professionella lösningar för styrning av luftfuktighet i kommersiella byggnader och industriella miljöer. Med lång erfarenhet hjälper vi våra kunder att skapa stabila, effektiva och hälsosamma inomhusklimat genom avancerad teknik för befuktning, avfuktning och adiabatisk kylning.
Rätt luftfuktighet är avgörande för att skydda människor, processer och material. Våra lösningar används inom många olika områden – från kontor, sjukhus och datacenter till produktion, museer, arkiv och andra miljöer där ett stabilt inomhusklimat är avgörande.
Condair AB är en del av den globala Condair Group, med huvudkontor i Schweiz. Koncernen har över 1000 medarbetare globalt och driver fem produktionsanläggningar, som levererar lösningar för fuktkontroll till kunder över hela världen.
I Norden arbetar vi i ett nära och integrerat samarbete mellan våra lokala organisationer. Det ger oss starka sälj-, service- och administrativa team som tillsammans kan erbjuda hög kompetens, snabb service och lösningar anpassade efter kundernas behov.
Våra specialister samarbetar nära med konsulter, entreprenörer, fastighetsägare och industrikunder för att utveckla lösningar som säkerställer optimal luftfuktighet, förbättrad energieffektivitet och långsiktig driftsäkerhet.
Genom att kombinera global expertis med stark lokal närvaro levererar Condair lösningar som skapar bättre inomhusklimat, skyddar värdefulla tillgångar och stödjer effektiv verksamhet.'), 'https://www.condair.se', 'assets/images/exhibitors/nordbygg-2026-condair-ab.jpg'),
  ('nordbygg-2026-exhibitor-138088', 'nordbygg-2026', 'Construction, Office of the Marshal of the Swietokrzyskie Voivodeship', 'C13:33', jsonb_build_object('en', 'See our co-exhiitors:
 Zaklad Kamieniarski Przywala Stones - natural stone, marble, bathroom, kitchen
 HOLZEXPORT sp. z o.o. - floors, wood
 KGA Sp. z o.o. - automation, climate chambers
 WJAP Sp. z o.o. - electricity
 R&M Alufasady Sp. z o.o - doors&windows, facades
 MP Aluminium sp. z o.o. - doors&windows, facades

The Office of the Marshal of the Swietokrzyskie Voivodeship in Poland is a regional government authotity. Our Unit, the Division for Economic Cooperation and European Projects,  deals with promotion of our regional businesses on international markets. This time we would like to introduce our home companies in the construction business and we have brought 6 companies with us, our co-exhibitors.
I would like to invite you to our stand for a B2B.', 'sv', 'Se våra medutställare:
 Zaklad Kamieniarski Przywala Stones – natursten, marmor, badrum, kök
 HOLZEXPORT sp. z o.o. – golv, trä
 KGA Sp. z o.o. – automation, klimatkammare
 WJAP Sp. z o.o. – el
 R&M Alufasady Sp. z o.o – dörrar och fönster, fasader
 MP Aluminium sp. z o.o. – dörrar och fönster, fasader

Marskalkens kontor för regionen Świętokrzyskie i Polen är en regional myndighet. Vår enhet, avdelningen för ekonomiskt samarbete och europeiska projekt, arbetar med att marknadsföra våra regionala företag på internationella marknader. Den här gången vill vi presentera våra inhemska företag inom byggbranschen, och vi har sex företag med oss, våra medutställare.
Jag vill bjuda in er till vår monter för B2B-möten.'), 'https://www.swietokrzyskie.pro/en', 'assets/images/exhibitors/nordbygg-2026-construction-office-of-the-marshal-of-the-swieto.jpg'),
  ('nordbygg-2026-exhibitor-137433', 'nordbygg-2026', 'Containerpoolen AB', 'B09:42', jsonb_build_object('en', 'Your complete container supplier

With more than 30 years in the industry, Containerpoolen offers what we do best — a complete container for your specific purpose. We rent out and sell containers tailored to our customers'' needs.

Since 1980, we at Containerpoolen have provided Sweden with high-quality containers.
Complete solutions. Four staffed depots in Sweden.
Nyvång, Oxie, Jönköping and Nykvarn.

We operate an extensive network for delivery and dispatch of containers covering our long country. It includes major cities such as Stockholm, Västerås, Norrköping, Jönköping, Gothenburg, Växjö, Karlskrona, Visby, Helsingborg and Malmö.

Wherever your project is located, you can rely on our expertise and experience to ensure smooth and efficient container logistics.', 'sv', 'Din kompletta containerleverantör

Med över 30 år i branschen kan Containerpoolen erbjuda det vi kan bäst; en komplett container för just ert ändamål! Vi hyr ut och säljer containrar anpassade efter våra kunders behov.

Vi på Containerpoolen har sedan 1980 försett Sverige med högkvalitativa containrar.
Kompletta lösningar. Fyra bemannade depåer i Sverige.
Nyvång, Oxie, Jönköping och Nykvarn.

Vi driver ett omfattande nätverk för leverans och expediering av containrar som täcker vårt avlånga land. Det inkluderar större städer som Stockholm, Västerås, Norrköping, Jönköping, Göteborg, Växjö, Karlskrona, Visby, Helsingborg och Malmö.

Oavsett var ditt projekt befinner sig kan du lita på vår expertis och erfarenhet när det gäller att säkerställa smidig och effektiv containerlogistik.'), 'https://containerpoolen.se', 'assets/images/exhibitors/nordbygg-2026-containerpoolen-ab.jpg'),
  ('nordbygg-2026-exhibitor-134706', 'nordbygg-2026', 'Corroventa Avfuktning AB', 'A20:27', jsonb_build_object('en', 'Corroventa is a market-leading specialist in innovative solutions for dehumidification in connection with water damage and construction drying. We also offer effective solutions for managing moisture, odour and radon for a safe and healthy living environment.

We develop, manufacture and sell products of the highest quality. By supporting professional actors in restoration, moisture control and damage services as well as industries, rental companies and the construction sector, Corroventa contributes to efficient, reliable and sustainable drying processes.

In emergencies and floods, Corroventa''s customers have access to one of the largest rental fleets in Europe. Corroventa was founded in 1985 and to this day all manufacturing takes place at our own factory in Bankeryd, Småland. Corroventa has 76 employees, a turnover of approximately SEK 320 million, and sales offices and equipment depots in several European countries.

Corroventa is part of Volati.', 'sv', 'Corroventa är marknadsledande specialister på innovativa lösningar inom avfuktning vid vattenskador och byggavfuktning. Vi erbjuder även effektiva lösningar för hantering av fukt, lukt och radon för en trygg och sund boendemiljö.

Vi utvecklar, tillverkar och säljer produkter av högsta kvalitet. Genom att stötta professionella aktörer inom sanering, fuktkontroll och skadeservice samt industrier, uthyrningsföretag och byggsektorn bidrar Corroventa till effektiva, driftsäkra och hållbara torkprocesser.

Vid akuta situationer och översvämningar har Corroventas kunder tillgång till en av de största hyrparkerna i Europa. Corroventa grundades 1985 och än idag sker all tillverkning vid den egna fabriken i Bankeryd, Småland. Corroventa har 76 anställda, omsätter ca 320 mkr och har säljkontor samt maskindepåer i flera europeiska länder.

Corroventa är en del av Volati.'), 'https://www.corroventa.se', 'assets/images/exhibitors/nordbygg-2026-corroventa-avfuktning-ab.jpg'),
  ('nordbygg-2026-exhibitor-136428', 'nordbygg-2026', 'COT Sverige AB', 'B05:31', jsonb_build_object('en', 'COT Sverige''s business model is built on delivering rental machines as well as fasteners and consumables to construction companies in Stockholm and the Mälardalen region. In terms of turnover this is a small part of our customers'' everyday work, but if these areas are not delivered quickly, smoothly and securely it can lead to significant financial loss. We therefore deliver with our own vehicles and our own staff. We also place great emphasis on developing our customer portal, where customers can easily manage their orders, returns and projects, and of course view their prices. COT Sverige''s motto includes: "It just has to work."', 'sv', 'COT Sveriges affärsmodell bygger på att leverera hyresmaskiner samt infästning & förbrukningsvaror till byggföretag i Stockholm & Mälardalen. Det är en liten del av våra kunders vardag rent omsättningsmässigt men om dessa områden inte levereras på ett snabbt, smidigt och säkert sätt kan det leda till stor ekonomisk förlust. Vi levererar därför med egna bilar och egen personal. Vi lägger även stor vikt på utvecklingen av vår kundportal där kunderna enkelt kan administrera sina beställningar, returer, projekt samt givetvis se sina priser. COT Sveriges motto lyder bland annat: "Det ska bara funka".'), 'https://cotsverige.se', 'assets/images/exhibitors/nordbygg-2026-cot-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-135346', 'nordbygg-2026', 'Cramo AB', 'UTE:49 (+1)', jsonb_build_object('en', 'Cramo was founded in 1953 and is one of Sweden''s largest and Europe''s second largest companies in the rental of machines, equipment and rental-related services. Cramo AB is part of the Cramo Northern Europe business area together with Norway, Finland, Estonia and Lithuania, and is one of the leading rental companies in Sweden with more than 90 depots and around 850 employees across the country. The business covers everything from short-term rental of individual machines to total commitments in larger projects, full-service commitments under multi-year contracts, and outsourcing solutions.

Since 2019, Cramo AB has been part of the Dutch machine-rental group Boels Rental.', 'sv', 'Cramo grundades 1953 och är en av Sveriges största och Europas näst största företag inom uthyrning av maskiner, utrustning och hyresrelaterade tjänster. Cramo AB ingår i affärsområdet Cramo Norra Europa tillsammans med Norge, Finland, Estland, Litauen och är ett av de ledande uthyrningsföretagen i Sverige med över 90 depåer och ca 850 anställda över hela landet. Verksamheten omfattar såväl korttidsuthyrning av enstaka maskiner som totalåtaganden i större projekt, fullserviceåtaganden på flerårsavtal och outsourcinglösningar.

Cramo AB är sedan 2019 en del i den nederländska maskinuthyrningskoncernen Boels Rental.'), 'https://www.cramo.se', 'assets/images/exhibitors/nordbygg-2026-cramo-ab.jpg'),
  ('nordbygg-2026-exhibitor-133964', 'nordbygg-2026', 'CTC AB', 'A05:24', jsonb_build_object('en', 'With more than 100 years of experience and innovation, we work purposefully toward a sustainable and fossil-free society. We design and manufacture reliable and energy-efficient heat pumps for homes, industry and offices. Our broad range consists of geothermal heat pumps, air-to-water heat pumps, indoor modules and accumulator tanks.

With our headquarters in Ljungby, Småland, we have for more than a century developed sustainable, future-proof and user-friendly solutions that provide comfort and flexibility — while contributing to the green transition.

CTC — care that warms.', 'sv', 'Med över 100 års erfarenhet och innovation arbetar vi målmedvetet för ett hållbart och fossilfritt samhälle. Vi designar och tillverkar pålitliga och energieffektiva värmepumpar för hem, industri och kontor. Vårt breda sortiment består av bergvärmepumpar, luft/vattenvärmepumpar, inomhusmoduler och ackumulatortankar.

Med huvudkontoret i småländska Ljungby har vi i över ett sekel utvecklat hållbara, framtidssäkra och användarvänliga lösningar som ger komfort och flexibilitet – samtidigt som de bidrar till den gröna omställningen.

CTC - omtanke som värmer.'), 'https://www.ctc.se', 'assets/images/exhibitors/nordbygg-2026-ctc-ab.jpg'),
  ('nordbygg-2026-exhibitor-138148', 'nordbygg-2026', 'Culina Products AB', 'A10:11', jsonb_build_object('en', 'We are a group of specialist companies that together offer thoughtful, sustainable and efficient solutions for professional environments where quality, function and service life are decisive.
What unites our companies is stainless steel, high technical expertise, and products designed for tough environments.

UVtech | Effective air purification using UV technology
UVtech develops and manufactures air-purification units that effectively eliminate odours in commercial kitchens, waste rooms, hotels, basements and other exposed spaces, among other places. Through proven UV technology, odour molecules are broken down in a safe and energy-efficient way, which improves both the indoor environment and the working environment without chemicals and without masking the problem.

Molins Rostfria | Floor drains for demanding operations
Molins Rostfria presents, among other things, a broad range of stainless-steel floor drains, developed for industrial and professional use. With the right material choice and well-considered design, long service life, easy cleaning and reliable function over time are ensured. The products are designed for environments where wear resistance, hygiene and operational reliability are decisive, for example:
- Car washes and wash halls
- Commercial kitchens and restaurants
- Food production
- Campsites
- Agriculture and other wet environments

Nordic Tech | Timeless design for kitchens
Nordic Tech presents a selection of kitchen mixers, sinks, washing benches and worktops — all in stainless steel. The products combine Scandinavian design with robust function and are designed for environments where hygiene, durability and aesthetics go hand in hand.

Together, our companies represent broad expertise in stainless solutions — from air and water to work surfaces and drainage. By bringing several specialist areas together within the same group, we can offer complete solutions that meet the demands of modern construction and installation projects.

We look forward to showing how our products can contribute to more sustainable, functional and future-proof environments.
Since 2021, Culina is part of Idun Industrier.

Welcome to Culina Products at Nordbygg!', 'sv', 'Vi är en koncern med specialistbolag som tillsammans erbjuder genomtänkta, hållbara och effektiva lösningar för professionella miljöer där kvalitet, funktion och livslängd är avgörande.
Det som förenar våra bolag är rostfritt stål, hög teknisk kompetens och produkter anpassade för tuffa miljöer.

UVtech | Effektiv luftrening med UV-teknik
UVtech utvecklar och tillverkar luftreningsaggregat som effektivt eliminerar odörer i bland annat storkök, soprum, hotell, källare och andra utsatta utrymmen. Genom beprövad UV-teknik bryts luktmolekyler ner på ett säkert och energieffektivt sätt, vilket förbättrar både inomhusmiljö och arbetsmiljö utan kemikalier och utan att maskera problemet.

Molins Rostfria | Golvbrunnar för krävande verksamheter
Molins Rostfria presenterar bl.a. ett brett sortiment av golvbrunnar i rostfritt stål, utvecklade för industriell och professionell användning. Med rätt materialval och genomtänkt konstruktion säkerställs lång livslängd, enkel rengöring och trygg funktion över tid. Produkterna är konstruerade för miljöer där slitstyrka, hygien och driftsäkerhet är avgörande exempelvis:
- Biltvättar och tvätthallar
- Storkök och restauranger
- Livsmedelsproduktion
- Campingplatser
- Lantbruk och andra våta miljöer

Nordic Tech | Tidlös design för kök
Nordic Tech visar upp ett urval av köksblandare, diskhoar, tvättbänkar och bänkskivor allt i rostfritt stål. Produkterna kombinerar skandinavisk design med robust funktion och är framtagna för miljöer där hygien, hållbarhet och estetik går hand i hand.

Tillsammans representerar våra bolag en bred kompetens inom rostfria lösningar från luft och vatten till arbetsytor och avvattning. Genom att samla flera specialistområden inom samma koncern kan vi erbjuda helhetslösningar som möter kraven i moderna bygg- och installationsprojekt.

Vi ser fram emot att visa hur våra produkter kan bidra till mer hållbara, funktionella och framtidssäkra miljöer.
Culina är sedan 2021 en del utav Idun Industrier.

Välkommen till Culina Products på Nordbygg!'), 'https://www.culinaproducts.se', 'assets/images/exhibitors/nordbygg-2026-culina-products-ab.jpg'),
  ('nordbygg-2026-exhibitor-139775', 'nordbygg-2026', 'Curant Klimat AB', 'A13:14', null, 'https://www.curant.se', null),
  ('nordbygg-2026-exhibitor-138067', 'nordbygg-2026', 'CW Lundberg Industri AB', 'C18:31', jsonb_build_object('en', 'Complete supplier of roof safety

CW Lundberg offers a broad range of roof safety products and mounting systems for solar panels, developed for Nordic conditions. Our innovative products are safe, low in weight and easy to install. Through modern manufacturing methods and processes, we create sustainability at every stage.

Swedish-made — Our quality stamp
All manufacturing takes place in Sweden. With sustainable material choices and a 40-year warranty it is a safe investment for both installers and property owners. Swedish production is a central part of CW Lundberg''s identity and quality work.', 'sv', 'Helhetsleverantör av säkerhet på tak

CW Lundberg erbjuder ett brett sortiment av taksäkerhetsprodukter och infästningssystem för solpaneler utvecklande för nordiska förhållanden. Våra innovativa produkter är säkra, har låg vikt och är montagevänliga. Genom moderna tillverkningsmetoder och processer skapar vi hållbarhet i alla led.

Svensktillverkat – Vår kvalitetsstämpel
All tillverkning sker i Sverige. Med hållbara materialval och 40 års garanti är det en säker investering för både installatörer och fastighetsägare. Svensk produktion är en central del av CW Lundbergs identitet och kvalitetsarbete.'), 'https://www.cwlundberg.com', 'assets/images/exhibitors/nordbygg-2026-cw-lundberg-industri-ab.jpg'),
  ('nordbygg-2026-exhibitor-133969', 'nordbygg-2026', 'Cylinda Bygg och Fastighet', 'C06:31', jsonb_build_object('en', 'Since 1958, Cylinda has been at the side of the Swedes. With our roots in Västergötland, we manufacture energy-smart, user-friendly and reliable household appliances that stand up to all of life''s challenges. Always with the goal of making everyday life a little easier. And more enjoyable.', 'sv', 'Sedan 1958 har Cylinda funnits vid svenskarnas sida. Med rötterna i Västergötland tillverkar vi energismarta, användarvänliga och pålitliga vitvaror som står pall för livets alla utmaningar. Alltid med målet att göra vardagen lite enklare. Och roligare.'), 'https://www.cylinda.se', 'assets/images/exhibitors/nordbygg-2026-cylinda-bygg-och-fastighet.jpg'),
  ('nordbygg-2026-exhibitor-139105', 'nordbygg-2026', 'Dafo', 'C03:30', jsonb_build_object('en', 'We offer the market''s broadest range of services and products for a safer everyday life, for every kind of operation. Welcome to Dafo!', 'sv', 'Vi erbjuder marknadens bredaste sortiment av tjänster och produkter för en säker vardag, för alla typer av verksamheter. Välkommen till Dafo!'), 'https://www.dafo.se', 'assets/images/exhibitors/nordbygg-2026-dafo.jpg'),
  ('nordbygg-2026-exhibitor-137076', 'nordbygg-2026', 'Dala-Profil AB', 'C17:51', jsonb_build_object('en', 'QUALITY AND DURABILITY IN BUILDING SHEET METAL

Dala-Profil is a leading manufacturer and supplier of roof and wall profiles, with a focus on quality, durability and fast delivery. We offer a broad range of profiled sheet, flat sheet, roof drainage, roof safety and fastening systems — all tailored for the construction and sheet-metal trades.

As a GreenCoat® partner with SSAB, we use top-quality Swedish steel, which lets us offer functional warranties of up to 50 years.

Our production facility in Borlänge covers 13,000 sqm, and our efficient logistics with crane-equipped delivery trucks ensure fast and reliable shipments.

Your flexible and dependable sheet-metal supplier!', 'sv', 'KVALITET OCH HÅLLBARHET INOM BYGGPLÅT

Dala-Profil är en ledande tillverkare och leverantör av tak- och väggprofiler med fokus på kvalitet, hållbarhet och snabb leverans. Vi erbjuder ett brett sortiment av profilerad plåt, slätplåt, takavvattning, taksäkerhet och infästningssystem – allt anpassat för bygg och plåtslageri.

Som GreenCoat® partner med SSAB använder vi svenskt stål av högsta kvalitet, vilket gör det möjligt att erbjuda funktionsgarantier upp till 50 år.

Vår produktionsanläggning i Borlänge omfattar 13 000 kvm och vår effektiva logistik med kranförsedda turbilar säkerställer snabba och tillförlitliga leveranser.

Din flexibla och pålitliga plåtleverantör!'), 'https://www.dala-profil.se', 'assets/images/exhibitors/nordbygg-2026-dala-profil-ab.jpg'),
  ('nordbygg-2026-exhibitor-134398', 'nordbygg-2026', 'Daloc AB', 'C12:31', jsonb_build_object('en', 'In a construction project, the door is often critical. That is why we manufacture every one of our doors with a clear purpose. To stop fires, deadly smoke gases and disturbed sleep in hotels, for example. To protect against gunfire and explosions. To save lives.
But this business of doors is not as simple as it looks. So we are happy to help you with whatever you need to make your projects succeed. You can lean confidently on our knowledge wherever you are in the process. That way you avoid unnecessary costs and unpleasant surprises.', 'sv', 'I ett byggprojekt har dörren ofta en avgörande betydelse. Det är därför vi tillverkar alla våra dörrar med ett tydligt syfte. Att hejda eldsvådor, dödliga brandgaser och störa skön sömn i hotell till exempel. Att skydda mot skott och explosioner. Att rädda liv.
Men det här med dörrar är inte så enkelt som det ser ut. Så vi hjälper dig gärna med det du behöver för att lyckas med dina projekt. Du kan tryggt luta dig mot vår kunskap var du än befinner dig i processen. På så sätt slipper du onödiga kostnader och otrevliga överraskningar.'), 'https://www.daloc.se', 'assets/images/exhibitors/nordbygg-2026-daloc-ab.jpg'),
  ('nordbygg-2026-exhibitor-134363', 'nordbygg-2026', 'Dana Lim AB', 'C05:20', jsonb_build_object('en', 'CHOICE OF PROFESSIONALS

THE FIRST CHOICE OF BUILDING PROFESSIONALS SINCE 1929

We are Scandinavia''s leading manufacturer of adhesives, sealants and fillers. We develop and manufacture quality solutions with a focus on customer needs.

With us, the path from idea to action is always short, which is why we continuously adapt our extensive product range and services to the market.', 'sv', 'CHOICE OF PROFESSIONALS

BYGGPROFFSENS FÖRSTAHANDSVAL SEDAN 1929

Vi är Skandinaviens ledande tillverkare av lim, fogmassa och spackel. Vi utvecklar och tillverkar kvalitetslösningar med fokus på kundens behov.

Hos oss är vägen från tanke till handling alltid kort, därför anpassar vi kontinuerligt vårt omfattande produktsortiment och våra tjänster till marknaden.'), 'https://www.danalim.se', 'assets/images/exhibitors/nordbygg-2026-dana-lim-ab.jpg'),
  ('nordbygg-2026-exhibitor-133962', 'nordbygg-2026', 'Danfoss', 'A09:10', jsonb_build_object('en', 'Imagine seeing what tomorrow''s energy-efficient solutions look like once they are lifted out of drawings and specifications and given new life as art. At Nordbygg 2026, Danfoss is presenting an installation where engineering meets artistic vision — and together they create a new way of understanding sustainability. It is an unexpected, inspiring and visually striking experience that is set to become a natural talking point at the fair. Come and visit us.', 'sv', 'Tänk dig att få se hur framtidens energieffektiva lösningar ser ut när de lyfts ur ritningar och specifikationer och får nytt liv som konst. På Nordbygg 2026 visar Danfoss en installation där ingenjörskonst möter konstnärlig vision – och tillsammans skapar ett nytt sätt att förstå hållbarhet. Det är en oväntad, inspirerande och visuellt stark upplevelse som kommer att bli en naturlig samtalspunkt på mässan. Kom och besök oss.'), 'https://www.danfoss.com/sv-se/campaigns/dhs/danfoss-nordbygg-2026', 'assets/images/exhibitors/nordbygg-2026-danfoss.jpg'),
  ('nordbygg-2026-exhibitor-137197', 'nordbygg-2026', 'DBM Nordic AB', 'A18:12', jsonb_build_object('en', 'DBM Nordic is the Nordic arm of DBM — a European manufacturer of heat exchangers with more than 40 years of experience. We design and produce heat exchangers for HVAC, ventilation, industrial processes, marine applications, energy recovery and data centres.

As the Nordic sales and engineering office, we put you in direct contact with the manufacturer of your heat exchangers, with no intermediaries. That means faster communication, shorter lead times and attractive prices.

Our engineers design every coil in-house, with a focus on energy efficiency, performance and reliability. Whether you need heating, cooling or recovery, we help you find the right heat exchanger — efficient, reliable and optimised for your specific project.', 'sv', 'DBM Nordic är den nordiska delen av DBM – en europeisk tillverkare av värmeväxlare med över 40 års erfarenhet. Vi designar och producerar värmeväxlare för HVAC, ventilation, industriella processer, marina applikationer, energiåtervinning och datahallar.

Som nordiskt sälj- och teknikkontor sätter vi dig direktkontakt med tillverkaren av dina värmeväxlare, utan mellanhänder. Det innebär snabbare kommunikation, kortare ledtider och attraktiva priser.

Våra ingenjörer designar varje batteri in-house med fokus på energieffektivitet, prestanda och tillförlitlighet. Oavsett om du behöver värme, kyla eller återvinning hjälper vi dig att hitta rätt värmeväxlare — effektiv, tillförlitlig och optimerad för just ditt projekt.'), 'https://www.dbmnordic.se', 'assets/images/exhibitors/nordbygg-2026-dbm-nordic-ab.jpg'),
  ('nordbygg-2026-exhibitor-133970', 'nordbygg-2026', 'Debe Flow Group AB', 'A05:10', null, 'https://www.debe.se', null),
  ('nordbygg-2026-exhibitor-137952', 'nordbygg-2026', 'DEC International', 'A19:23', jsonb_build_object('en', 'Want to see the latest in smart ventilation duct systems?

We at Ravensberg Consulting AB want to share two big pieces of news from the Nordic ventilation industry,
namely Ubbink''s unique duct system Air Excellent and DEC International''s rectangular duct system QuadroDec.

DEC & UBBINK are among the foremost innovators in the ventilation industry when it comes to
ventilation duct systems, and all of this is brought together in a single stand.
Both systems offer fantastic innovation with several advantages — the final pieces of the puzzle that create modern
ventilation in every angle and corner.

Ubbink develops and manufactures duct systems for sustainable ventilation solutions and roof accessories, which help improve the indoor climate in new and existing residential and commercial buildings, and the health of the people who live and work in them.

Ravensberg Consulting AB is DEC & Ubbink''s partner in the Nordic region. They offer complete ventilation solutions and always work directly with the manufacturer.

You can read more about the products on the manufacturers'' websites below:

www.ubbink.com
www.decinternational.com', 'sv', 'Vill du se det senaste inom smarta ventilationskanalsystem?

Vi på Ravensberg Consulting AB vill dela med oss av två stora nyheter inom den Nordiska ventilationsbranschen,
nämligen Ubbink''s unika kanalsystem Air Excellent samt DEC internationals rektangulära kanalsystem QuadroDec.

DEC & UBBINK är bland de främsta innovatörerna inom ventilationsbranschen när det kommer till
ventilationskanalsystem och allt detta samlat i en monter.
Båda systemen bjuder på fantastisk innovation med flera fördelar, de sista pusselbitarna som skapar en modern
ventilation i alla vinklar och vrår.

Ubbink utvecklar och tillverkar kanalsystem för hållbara ventilationslösningar och taktillbehör, som hjälper till att förbättra inomhusklimatet i nya och befintliga bostäder och kommersiella byggnader samt hälsan för de människor som bor och arbetar där.

Ravensberg Consulting AB är DEC & Ubbinks partner i Norden. Dem erbjuder kompletta lösningar på ventilation och arbetar alltid direkt med tillverkaren.

Ni kan läsa mer om produkterna via tillverkarnas hemsidor nedtill:

www.ubbink.com
www.decinternational.com'), 'https://www.ravensberg.se', 'assets/images/exhibitors/nordbygg-2026-dec-international.jpg'),
  ('nordbygg-2026-exhibitor-139874', 'nordbygg-2026', 'Dekker Nordic AB', 'C18:20', null, 'https://www.dekkernordic.se', null),
  ('nordbygg-2026-exhibitor-134464', 'nordbygg-2026', 'Demex AB', 'B07:41', jsonb_build_object('en', 'Demex offers complete solutions in perimeter protection and security products. Through a broad product range, reliable delivery performance and personal service, we create profitability for our customers.
We are a leading company in Northern Europe, supplying 65% of the fencing market in Sweden with materials.', 'sv', 'Demex erbjuder helhetslösningar inom områdesskydd samt säkerhetsprodukter. Genom ett brett produktsortiment, hög leveranssäkerhet och personlig service skapar vi lönsamhet för våra kunder.
Vi är ett ledande företag i Nordeuropa som förser 65% av stängselmarknaden i Sverige med material.'), 'https://www.demex.se', 'assets/images/exhibitors/nordbygg-2026-demex-ab.jpg'),
  ('nordbygg-2026-exhibitor-134911', 'nordbygg-2026', 'Derome', 'C15:41', null, 'https://www.derome.se', 'assets/images/exhibitors/nordbygg-2026-derome.jpg'),
  ('nordbygg-2026-exhibitor-140097', 'nordbygg-2026', 'Desah - Noardling', 'C03:41', jsonb_build_object('en', 'Desah designs, constructs, implements and operates biological decentralised wastewater treatment systems for domestic wastewater, all of which are modular and flexible. We have the following decentralized wastewater treatment solutions:

-         Source separated wastewater treatment
-         Containerised, mobile wastewater treatment
-         Black water treatment
-         Operation and maintenance

Our solutions are applicable for the following markets: (new) neighbourhoods, holiday parks, hotels, office buildings, remote settlements, temporary situations like refugee camps or as additional capacity for your wastewater treatment plant.

With our systems we treat the water in such a way that you can safely discharge it or reuse it for different purposes like toilet flushing or as irrigation water. It results in drinking water savings and the recovery and reuse of water, energy and nutrients. Energy and heat can be recovered to supply the neighbourhood and the treatment system. Sludge and struvite can be recovered and reused for agricultural purposes.', 'sv', 'Desah designar, bygger, levererar och driver biologiska decentraliserade reningsverk för hushållsspillvatten — alla modulära och flexibla. Vi erbjuder följande decentraliserade lösningar för avloppsrening:

-         Källseparerad avloppsrening
-         Containerbaserad, mobil avloppsrening
-         Svartvattenrening
-         Drift och underhåll

Våra lösningar är tillämpliga på följande marknader: (nya) bostadsområden, semesteranläggningar, hotell, kontorsbyggnader, avlägset belägna bosättningar, tillfälliga situationer som flyktingläger, eller som extra kapacitet för ert avloppsreningsverk.

Med våra system renar vi vattnet på ett sådant sätt att det säkert kan släppas ut eller återanvändas för olika ändamål, till exempel för toalettspolning eller som bevattningsvatten. Det leder till besparingar av dricksvatten och till återvinning och återanvändning av vatten, energi och näringsämnen. Energi och värme kan återvinnas för att försörja bostadsområdet och reningssystemet. Slam och struvit kan återvinnas och återanvändas för jordbruksändamål.'), 'https://desah.nl/en', 'assets/images/exhibitors/nordbygg-2026-desah-noardling.jpg'),
  ('nordbygg-2026-exhibitor-138640', 'nordbygg-2026', 'Design4Bath', 'A07:08', jsonb_build_object('en', 'Design4Bath is a privately held company founded in 2009 by Michael Thorell.
The company''s business idea is to create added value in the form of innovative products, solutions and design for your bathroom on the Nordic market.
One of our core areas is drill-free mounting and the added value created by avoiding holes when installing all kinds of products — bathroom accessories, shower sets, shower walls, mixers and more — through bonding. Within the product range we offer adhesives, mounting pads and bathroom accessories that are installed without unnecessary holes through the waterproofing membrane.
Our main target groups are consumers, professionals and OEMs.', 'sv', 'Design4Bath är ett privat bolag som grundades 2009 av Michael Thorell.
Företagets affärsidé är att skapa ett mervärde i form av innovativa produkter, lösningar och design för ditt badrum på den Nordiska marknaden.
Ett av kärnområdena är borrfritt montage och det mervärde som skapas genom att undvika håltagningar för att montera allehanda produkter såsom badrumstillbehör, duschset, duschväggar, blandare m.m. genom limning. I produktprogrammet erbjuder vi lim, limbrickor och badrumstillbehör som monteras utan onödiga håltagningar genom tätskikt.
Våra huvudsakliga målgrupper är konsument, proffs och OEM.'), 'https://www.design4bath.se', 'assets/images/exhibitors/nordbygg-2026-design4bath.jpg'),
  ('nordbygg-2026-exhibitor-133976', 'nordbygg-2026', 'Designlight Scandinavian AB', 'B10:21', jsonb_build_object('en', 'Designlight Scandinavian is a company with its head office and central warehouse located in Moheda, in the heart of Småland. We specialise in supplying high-quality lighting at competitive prices to electricians, property companies and industrial customers.

Broad range
Our broad range covers various types of lighting solutions that meet the highest quality standards in the Nordic region, both in terms of light quality and ease of installation. We always strive to offer reliable and efficient products that meet our customers'' needs and expectations.

Tailored solutions
In addition to offering standard products, we are proud to provide tailored solutions for various manufacturers in the kitchen, retail and hotel industries. We understand the importance of having lighting that fits specific environments perfectly, and we help our customers design and produce custom lighting solutions that elevate their products and spaces.

Experience
Our team of experienced and dedicated colleagues is always ready to give professional advice and support to our customers. We strive to build long-term relationships and deliver outstanding customer service.

Reliability
We at Designlight are proud to be a reliable partner for electricians, property companies and industrial customers. We are confident that our quality lighting and tailored solutions can help create attractive and functional environments.', 'sv', 'Designlight Scandinavian är ett företag med huvudkontor och centrallager beläget i Moheda, mitt i Småland. Vi är specialiserade på att leverera högkvalitativ belysning till konkurrenskraftiga priser till elektriker, fastighetsbolag och industriella kunder.

Brett sortiment
Vårt breda sortiment omfattar olika typer av belysningslösningar som möter de högsta kvalitetsstandarderna i Norden både när det gäller ljudkvalité och montagevänlighet. Vi strävar alltid efter att erbjuda pålitliga och effektiva produkter som möter våra kunders behov och förväntningar.

Skräddarsydda slösningar
Utöver att erbjuda standardprodukter är vi stolta över att kunna erbjuda skräddarsydda lösningar för olika tillverkare inom köks, butiks- och hotellindustrin. Vi förstår vikten av att ha en belysning som passar perfekt till specifika miljöer och hjälper våra kunder att utforma och producera kundanpassade belysningslösningar som förhöjer deras produkter och utrymmen.

Erfarenhet
Vårt team av erfarna och dedikerade medarbetare är alltid redo att ge professionell rådgivning och support till våra kunder. Vi strävar efter att bygga långsiktiga relationer och leverera enastående kundservice.

Pålitlighet
Vi på Designlight är stolta över att vara en pålitlig partner för elektriker, fastighetsbolag och industriella kunder. Vi är övertygade om att vår kvalitetsbelysning och anpassade lösningar kan bidra till att skapa attraktiva och funktionella miljöer.'), 'https://www.designlight.nu', 'assets/images/exhibitors/nordbygg-2026-designlight-scandinavian-ab.jpg'),
  ('nordbygg-2026-exhibitor-134327', 'nordbygg-2026', 'Dewalt', 'B01:21', jsonb_build_object('en', 'DEWALT — 100 years of building the future

For more than 100 years, the DEWALT name has stood for quality, endurance and professionalism, earning the respect and loyalty of the people and companies who work with us. Since 1922 we have been a driving force in innovation, performance and safety — and we are more committed than ever to developing and refining professional solutions for the worksite. Our tools, accessories and services are designed to give professionals superior end-to-end solutions, backed by a century of hard-won experience, on every project and across every industry around the world.

It has been 100 years of ambition, success and hard work — and this is only the beginning. When we put the DEWALT name on something, it is a promise that the job will be done right, even under the toughest conditions. That is the mark we have left over 100 years of helping the world''s builders create the modern world.

We are DEWALT — and we are GUARANTEED TOUGH.', 'sv', 'DEWALT - 100 år av att bygga framtiden

I över 100 år har namnet DEWALT stått för kvalitet, uthållighet och professionalism, och vunnit respekt och lojalitet bland de människor och företag som arbetar med oss. Sedan 1922 har vi varit drivande inom innovation, prestanda och säkerhet – och vi är mer engagerade än någonsin i att utveckla och optimera professionella lösningar för arbetsplatsen. Våra verktyg, tillbehör och tjänster är utformade för att ge proffs överlägsna helhetslösningar, med stöd av ett sekel av hårt förvärvad erfarenhet, på varje projekt och inom varje bransch världen över.

Det har varit 100 år av ambition, framgång och hårt arbete – och detta är bara början. När vi sätter DEWALT-namnet på något är det ett löfte om att jobbet blir rätt gjort, även under de tuffaste förhållandena. Det är avtrycket vi har lämnat under 100 år av att hjälpa världens byggare att skapa den moderna världen.

Vi är DEWALT – och vi är GUARANTEED TOUGH.'), 'https://www.dewalt.se', 'assets/images/exhibitors/nordbygg-2026-dewalt.jpg'),
  ('nordbygg-2026-exhibitor-134664', 'nordbygg-2026', 'DIVELLO', 'A04:04', jsonb_build_object('en', 'OPTIMISE YOUR WATER AND HEATING SYSTEMS™

DIVELLO offers products that optimise existing sanitary and heating installations (shower, mixer, WC and radiator). Our products are independent of fitting and radiator brands, and are manufactured by world-leading original producers. The concept is unique: our universal products improve and extend the service life of existing sanitary and heating installations regardless of brand.

In a short time, DIVELLO has become the leading player in Scandinavia in our business area. The main reasons are our independence, our high-quality products and close collaboration with market-leading partners in production, distribution and installation.', 'sv', 'OPTIMERA DINA VATTEN- OCH VÄRMESYSTEM™

DIVELLO erbjuder produkter för att optimera existerande sanitets- och värmeinstallationer (dusch, blandare, WC och radiator). Våra produkter är armatur- och radiatoroberoende och tillverkas av världsledande originalproducenter. Konceptet är unikt då våra universella produkter förbättrar samt förlänger livslängden på existerande sanitets- och värmeinstallationer oberoende av fabrikat.

DIVELLO har på kort tid blivit den ledande aktören i Skandinavien inom vårt affärsområde. De främsta anledningarna är vårt oberoende, högkvalitativa produkter och nära samarbeten med marknadsledande partners inom produktion, distribution och installation.'), 'https://www.divello.com', 'assets/images/exhibitors/nordbygg-2026-divello.jpg'),
  ('nordbygg-2026-exhibitor-139582', 'nordbygg-2026', 'DMH- Den Moderna Hantverkaren', 'EH:19', null, 'https://www.dmh.nu', 'assets/images/exhibitors/nordbygg-2026-dmh-den-moderna-hantverkaren.jpg'),
  ('nordbygg-2026-exhibitor-138756', 'nordbygg-2026', 'Dofab AB', 'C12:30', jsonb_build_object('en', 'A door is more than a door. A window is more than a window. It is a brighter morning, a safer day and a warmer evening. Quality is beautiful. For generations. That is how we think.

DOFAB AB is a family-run company that offers tailor-made windows, doors and gates to your measurements and wishes. We are experts in slightly too tall, slightly too short, odd dimensions and round shapes. We go the extra mile in everything we do — for you, for your home and for the future.

Our team together has many years of experience in manufacturing, project management and architecture. That means you, as a customer, can feel confident in our broad expertise — and also draw on it to bring your dreams or specific wishes to life.', 'sv', 'En dörr är mer än en dörr. Ett fönster är mer än ett fönster. Det är en ljusare morgon, säkrare dag och varmare kväll. Kvalitet är vackert. I generationer. Så tänker vi.

DOFAB AB är ett familjärt företag som erbjuder skräddarsydda fönster, dörrar och portar efter dina mått och önskemål. Vi är experter på lite för högt, lite för lågt, udda mått och runda former. Vi går ett steg extra i allt vi gör - för dig, för ditt hus och för framtiden.

Vårt team har tillsammans många års erfarenhet av tillverkning, projektledning och arkitektur. Detta innebär att du som kund kan känna stor trygghet i vår breda kompetens, men även använda den för att förverkliga dina drömmar eller specifika önskemål.'), 'https://www.dofab.se', 'assets/images/exhibitors/nordbygg-2026-dofab-ab.jpg'),
  ('nordbygg-2026-exhibitor-133977', 'nordbygg-2026', 'Doka Sverige AB', 'B05:11', jsonb_build_object('en', 'Doka is a world-leading supplier of innovative formwork solutions and services for every type of cast-in-place concrete structure. With more than 9,000 employees and 180 sales and logistics facilities in over 58 countries, Doka has an effective network for distribution, advisory services, customer service and technical support.

No matter how large and complex your project is, we are close to you and make sure that deliveries arrive quickly and smoothly. Doka is part of the Umdasch Group.

Doka — We make it work.', 'sv', 'Doka är en världsledande leverantör av innovativa formlösningar och tjänster för alla typer av platsgjutna betongkonstruktioner. Med mer än 9000 anställda, 180 försäljnings- och logistikanläggningar i över 58 länder har Doka ett effektivt nätverk för distribution, rådgivning, kundservice och teknisk support.

Oavsett hur stort och komplicerat ditt projekt är så finns vi nära dig och ser till att leveranser tillhandahålls snabbt och smidigt. Doka är ett företag i Umdasch Group.

Doka – We make it work.'), 'https://www.doka.se', 'assets/images/exhibitors/nordbygg-2026-doka-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-137212', 'nordbygg-2026', 'DOLLE NORDIC AB', 'C14:32', jsonb_build_object('en', 'DOLLE is the world''s largest manufacturer of loft ladders and a market-leading supplier of access solutions for the construction industry. The product range covers everything from loft ladders and roof hatches to staircases, attic stairs and railing systems — all developed with a strong focus on quality, functionality and easy installation.', 'sv', 'DOLLE är världens största tillverkare av vindstrappor och en marknadsledande leverantör av åtkomstlösningar för byggbranschen. Produktutbudet omfattar allt från vindstrappor och takluckor till trappor, lofttrappor och räckessystem - alla utvecklade med stort fokus på kvalitet, funktionalitet och enkel installation.'), 'https://www.dolle.se', 'assets/images/exhibitors/nordbygg-2026-dolle-nordic-ab.jpg'),
  ('nordbygg-2026-exhibitor-139953', 'nordbygg-2026', 'DOMAX Sp. z o.o.', 'C03:61', jsonb_build_object('en', 'Company Description
Founded in 1994 as a family-run business, Domax initially focused on the manufacturing and distribution of wood connectors in Poland. Over the years, through a strong commitment to high-quality products, a broad and continuously expanding product range, and the expertise of our dedicated team, the company has evolved from a small family enterprise into a market leader across Central and Eastern Europe.

Company Offer
DOMAX provides a comprehensive and competitive portfolio of several thousand products across key categories, including wood connectors, hardened screws, hinges, latches, garden fittings, shelving systems, and garage hooks. We support our partners with proven tools, effective strategies, and flexible solutions tailored to their needs. Thanks to advanced machinery and modern technologies, we consistently deliver high product quality and reliable service. The CE marking on our products confirms full compliance with applicable EU directives and standards.', 'sv', 'Företagsbeskrivning
Domax grundades 1994 som ett familjeföretag och fokuserade inledningsvis på tillverkning och distribution av träförbindare i Polen. Genom åren har företaget, tack vare ett starkt engagemang för högkvalitativa produkter, ett brett och ständigt växande produktsortiment och expertisen hos vårt engagerade team, utvecklats från ett litet familjeföretag till en marknadsledare i Central- och Östeuropa.

Företagets erbjudande
DOMAX tillhandahåller en heltäckande och konkurrenskraftig portfölj med flera tusen produkter inom centrala kategorier — bland annat träförbindare, härdade skruvar, gångjärn, haspar, trädgårdsbeslag, hyllsystem och garagekrokar. Vi stöttar våra partner med beprövade verktyg, effektiva strategier och flexibla lösningar anpassade efter deras behov. Tack vare avancerade maskiner och modern teknik levererar vi konsekvent hög produktkvalitet och pålitlig service. CE-märkningen på våra produkter bekräftar full överensstämmelse med gällande EU-direktiv och standarder.'), 'https://www.domax.com', 'assets/images/exhibitors/nordbygg-2026-domax-sp-z-o-o.jpg'),
  ('nordbygg-2026-exhibitor-138958', 'nordbygg-2026', 'DOORDEC', 'C17:20', jsonb_build_object('en', 'Doordec OÜ is an Estonian manufacturer of high-quality steel and fire-rated doors, specialising in custom solutions for residential, commercial and industrial buildings. With more than 15 years of experience, we combine modern production technology with flexible engineering expertise to deliver durable, certified and project-specific door systems for the Nordic and European markets.

Our product range covers fire-rated doors (EI15–EI120), security doors, RC-rated products, insulated profile doors, glazed steel doors and tailor-made solutions for architects and contractors. We focus on fast lead times, reliable logistics and close collaboration throughout the project — from technical design to final delivery.

At Nordbygg, we look forward to presenting our latest innovations and discussing how Doordec can support your projects with secure, robust and aesthetically adaptable steel-door solutions.', 'sv', 'Doordec OÜ är en estnisk tillverkare av högkvalitativa stål- och brandklassade dörrar, specialiserad på kundanpassade lösningar för bostads-, kommersiella och industriella byggnader. Med mer än 15 års erfarenhet kombinerar vi modern produktionsteknik med flexibel ingenjörskompetens för att leverera hållbara, certifierade och projektspecifika dörrsystem till de nordiska och europeiska marknaderna.

Vårt produktsortiment omfattar brandklassade dörrar (EI15–EI120), säkerhetsdörrar, RC-klassade produkter, isolerade profildörrar, glasade ståldörrar samt skräddarsydda lösningar för arkitekter och entreprenörer. Vi fokuserar på snabba leveranstider, pålitlig logistik och nära samarbete genom hela projektet – från teknisk design till slutlig leverans.

På Nordbygg ser vi fram emot att presentera våra senaste innovationer och diskutera hur Doordec kan stötta era projekt med säkra, robusta och estetiskt anpassningsbara ståldörrslösningar.'), 'https://www.doordec.ee', 'assets/images/exhibitors/nordbygg-2026-doordec.jpg'),
  ('nordbygg-2026-exhibitor-138748', 'nordbygg-2026', 'Dores Wooden Homes', 'C13:50', jsonb_build_object('en', 'For 20 years, we''ve manufactured timber homes with care and conviction, firmly believing in the enduring beauty and sustainability of wood. Today, with our extensive knowledge in wood construction and over 1,200 completed projects worldwide, we handle wide range of builds, from holiday homes and residential dwellings to large-scale glulam structures for commercial and public buildings. Our expertise extends accross different sectors, including recreational properties, village developments, and commercial establishments.

Our products:
·Glulam beams and structural components;
·Prefabricated timber frame panels;
·Glulam log house construction kits;
·Timber frame construction kits;
·Prefabricated ready-to-live tiny homes.

Our services:
·Engineering and architecture;
·On-site assembly / chief assembly.', 'sv', 'I 20 år har vi tillverkat trähus med omsorg och övertygelse, i en stark tro på träets bestående skönhet och hållbarhet. Idag, med vår omfattande kunskap inom träbyggnad och över 1 200 färdigställda projekt världen över, hanterar vi ett brett spann av byggen — från fritidshus och bostäder till storskaliga limträkonstruktioner för kommersiella och offentliga byggnader. Vår expertis sträcker sig över olika sektorer, däribland fritidshusprojekt, byutvecklingar och kommersiella anläggningar.

Våra produkter:
·Limträbalkar och bärande komponenter;
·Prefabricerade element för regelstomme i trä;
·Byggsatser för limträtimrade hus;
·Byggsatser för trästomme;
·Prefabricerade inflyttningsklara minihus.

Våra tjänster:
·Konstruktion och arkitektur;
·Montering på plats / huvudmontage.'), 'https://www.dores.house', 'assets/images/exhibitors/nordbygg-2026-dores-wooden-homes.jpg'),
  ('nordbygg-2026-exhibitor-135291', 'nordbygg-2026', 'dormakaba Sverige AB', 'C11:30', null, 'https://www.dormakaba.se', 'assets/images/exhibitors/nordbygg-2026-dormakaba-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-139664', 'nordbygg-2026', 'Drabest Sp. z o.o.', 'AG:100', null, 'https://drabest.pl', 'assets/images/exhibitors/nordbygg-2026-drabest-sp-z-o-o.jpg'),
  ('nordbygg-2026-exhibitor-138509', 'nordbygg-2026', 'DRUTEX SA', 'C14:61', null, 'https://www.drutex.eu', null),
  ('nordbygg-2026-exhibitor-137626', 'nordbygg-2026', 'Dry-Top AB', 'C08:13', null, 'https://dry-top.se', null),
  ('nordbygg-2026-exhibitor-139194', 'nordbygg-2026', 'Dryft AB', 'BG:23', jsonb_build_object('en', 'Dryft is a tradesperson company that takes on lots of different types of projects in people''s homes. We are now looking for more partners across more trades!

Dryft works today with selected tradesperson companies in Stockholm, Gothenburg, Malmö and Uppsala. We are now looking for more skilled companies that want to grow with us and take part in the assignments delivered under the Dryft brand.

As a partner company, you get fixed-price projects booked directly into your or your employees'' calendars, with very clear briefs that make your day-to-day easier. Dryft Partnerships help you balance and optimise your and your company''s workload.

It costs nothing and you don''t tie yourself down to anything. We are simply looking for partners — and perhaps that''s you?', 'sv', 'Dryft är ett hantverksföretag, som utför massor av olika typer av projekt hemma hos människor. Vi söker nu fler samarbetspartners inom fler yrkeskompetenser!

Dryft samarbetar idag med utvalda hantverksföretag i Stockholm, Göteborg, Malmö och Uppsala. Nu söker vi fler duktiga företag som vill växa tillsammans med oss och ta del av de uppdrag som utförs under Dryfts varumärke.

Som partnerbolag får du fastprisade projekt, bokade direkt in i din eller dina anställdas kalender, med väldigt tydliga underag som underlättar din vardag. Dryft Partnerskap hjälper dig att balansera och optimera din och företagets beläggning.

Det kostar ingenting och du binder inte upp dig på någonting. Vi söker helt enkelt samarbetspartners, och kanske är det du?'), 'https://dryft.se', null),
  ('nordbygg-2026-exhibitor-138332', 'nordbygg-2026', 'Drynex Technologies AB', 'C17:10', null, 'https://www.drynex.se', null),
  ('nordbygg-2026-exhibitor-138570', 'nordbygg-2026', 'Duka Ventilation', 'A24:28', jsonb_build_object('en', 'DUKA Ventilation is a leading supplier of system solutions for residential ventilation. We have been producing ventilation products since 1968 and have continuously expanded our range to match the needs of the market. We work together with external experts and advisors to ensure that all products are tested and validated, so that everything fits together as a system solution.', 'sv', 'DUKA Ventilation är en ledande leverantör av systemlösningar för bostadsventilation. Vi har producerat ventilationsprodukter sedan 1968 och har löpande utökat vårt sortiment så att det motsvarar marknadens behov. Vi arbetar tillsammans med externa experter och rådgivare för att säkerställa att alla produkter är testade och utprovade, så att allt passar ihop som en systemlösning.'), 'https://www.dukaventilation.dk', 'assets/images/exhibitors/nordbygg-2026-duka-ventilation.jpg'),
  ('nordbygg-2026-exhibitor-138846', 'nordbygg-2026', 'Dunlop Protective Footwear', 'B07:51', jsonb_build_object('en', 'Dunlop Protective Footwear is the world-leading manufacturer of safety boots, with 130+ years as an innovator in the boot industry in terms of both comfort and safety. Stop by and we will explain what a boot is today — you will be surprised!
Welcome', 'sv', 'Dunlop Protective Footwear är världsledande tillverkare av skyddstövlar med +130år som innovatör i stövelbranschen när det gäller både komfort och säkerhet. Kom förbi så förklarar vi vad en stövel är idag, ni kommer bli förvånade!
Välkomna'), 'https://www.dunlopboots.com', 'assets/images/exhibitors/nordbygg-2026-dunlop-protective-footwear.jpg'),
  ('nordbygg-2026-exhibitor-140057', 'nordbygg-2026', 'Duravit', 'A05:16', jsonb_build_object('en', 'Duravit stands for passion in the bathroom.

We create bathroom solutions where the power of our distinctive design, quality and functionality shapes
our customers'' wellbeing every day.
As a complete bathroom manufacturer,
Duravit offers everything required to create a perfectly coordinated bathroom.

	Headquartered in Hornberg, Germany. Established 1817.

	Active in more than 130 countries, with 11
	production facilities and around 7,000 employees.

	Revenue 2024: more than €631 million.', 'sv', 'Duravit står för passion i badrummet.

Vi skapar badrumslösningar där kraften i vår unika design, kvalitet och funktionalitet påverkar
våra kunders välbefinnande varje dag.
Som en komplett badrumstillverkare erbjuder
Duravit allt som krävs för att skapa ett perfekt koordinerat badrum.

	Huvudkontor i Hornberg, Tyskland. Etablerat 1817.

	Verksamhet i >130 länder med 11
	produktionsanläggningar och ca. 7000 anställda.

	Omsättning 2024: >€ 631 Miljoner.'), 'https://www.duravit.se', 'assets/images/exhibitors/nordbygg-2026-duravit.jpg'),
  ('nordbygg-2026-exhibitor-138573', 'nordbygg-2026', 'DURI SVENSKA AKTIEBOLAG', 'C16:30', null, 'https://www.duri.se', 'assets/images/exhibitors/nordbygg-2026-duri-svenska-aktiebolag.jpg'),
  ('nordbygg-2026-exhibitor-138832', 'nordbygg-2026', 'Duschbyggarna AB', 'A10:13', null, 'https://www.duschbyggarna.se', 'assets/images/exhibitors/nordbygg-2026-duschbyggarna-ab.jpg'),
  ('nordbygg-2026-exhibitor-133965', 'nordbygg-2026', 'Dustcontrol AB', 'B06:31', null, 'https://www.dustcontrol.se', 'assets/images/exhibitors/nordbygg-2026-dustcontrol-ab.jpg'),
  ('nordbygg-2026-exhibitor-137942', 'nordbygg-2026', 'DynaMaker', 'AG:43', jsonb_build_object('en', 'Make it easy for your customers to configure products, directly on your website!

With DynaMaker you can build and publish visual product configurators on your website or e-commerce store. Visualise the product during configuration and automatically generate PDF drawings, BIM files and manufacturing documents for every unique configuration.
Ready-made integrations to systems including Monitor ERP are included.

Come and talk to us about your needs — we will guide you.

DynaMaker is developed by SkyMaker AB, with offices in Linköping.', 'sv', 'Gör det enkelt för dina kunder att konfigurera produkter, direkt på din hemsida!

Med DynaMaker kan du bygga och publicera visuella produktkonfiguratorer till din hemsida eller e-handel. Visualisera produkten under konfigurering och skapa PDF-ritningar, BIM-filer och tillverkningsunderlag automatiskt för varje unik konfigurering.
Färdiga integrationer till bland annat Monitor ERP ingår.

Kom och prata med oss om dina behov så guidar vi dig.

DynaMaker utvecklas av SkyMaker AB med kontor i Linköping.'), 'https://dynamaker.com', 'assets/images/exhibitors/nordbygg-2026-dynamaker.jpg'),
  ('nordbygg-2026-exhibitor-136560', 'nordbygg-2026', 'E.M.S. Teknik AB', 'A10:06', jsonb_build_object('en', 'We are a Scandinavian pump wholesaler that serves professional installers with high demands on safety and quality. Our pumps and accessories have been developed to our own specifications, in cooperation with reputable and reliable manufacturers. Every product we sell is quality-assured, tested and meets the strict EU standards required. Material choices and function are carefully considered to ensure a long service life and high performance.
We make sure the pump size we recommend matches the customer''s needs and gives the best possible conditions for energy efficiency and durability. All of our products are kept in stock, including the necessary accessories, which means we can quickly meet requests around capacity and performance.
As a Scandinavian pump wholesaler, we serve HVAC installers, plumbers, contractors and corporate customers. In addition to our operations in Åhus, Sweden, we are also established in Lohja and Tønsberg.', 'sv', 'Vi är en skandinavisk pumpgrossist som vänder oss till yrkesverksamma installatörer med höga krav på säkerhet och kvalitet. Våra pumpar och tillbehör har utvecklats efter våra egna specifikationer i samarbete med välrenommerade och tillförlitliga tillverkare. Samtliga produkter som säljs av oss är kvalitetssäkrade, testade och uppfyller de höga EU-standarder som krävs. Materialval och funktion är noggrant genomtänkta för att säkerställa lång hållbarhet och hög prestanda.
Vi säkerställer att vald pumpstorlek motsvarar kundens behov och ger optimala förutsättningar för energieffektivitet och livslängd. Alla våra produkter finns på lager, inklusive nödvändiga tillbehör, vilket innebär att vi snabbt kan tillgodose önskemål om verkningsgrad och kapacitet.
Som skandinavisk pumpgrossist riktar vi oss till HVAC-installatörer, rörläggare, entreprenörer och företagskunder. Förutom vår verksamhet i Åhus, Sverige, är vi även etablerade i Lohja och Tønsberg.'), 'https://www.emspump.se', 'assets/images/exhibitors/nordbygg-2026-e-m-s-teknik-ab.jpg'),
  ('nordbygg-2026-exhibitor-138185', 'nordbygg-2026', 'EAB AB', 'C18:32', jsonb_build_object('en', 'Built to last. For you. For us. For future generations.

EAB is a family-owned company in Smålandsstenar, where engineering, production and development all happen under the same roof. Since we were founded in 1957 we have grown steadily — just like our solutions — and today EAB is represented all over the world.

We develop and deliver durable solutions where quality, function and a long service life are decisive. With sturdy materials, a high degree of customer adaptation and reliable engineering, we create solutions that last for generations. Modestly, we call it Småland-style durability.', 'sv', 'Det håller. För dig. För oss. För framtida generationer.

EAB är ett familjeägt företag i Smålandsstenar, där konstruktion, produktion och utveckling sker under samma tak. Sedan starten 1957 har vi vuxit stadigt, precis som våra lösningar och idag finns EAB representerat över hela världen.

Vi utvecklar och levererar hållbara lösningar där kvalitet, funktion och lång livslängd är avgörande. Med rejäla material, hög kundanpassning och pålitlig konstruktion skapar vi lösningar som håller i generationer. Lite anspråkslöst kallar vi det småländsk hållbarhet.'), 'https://www.eab.se', 'assets/images/exhibitors/nordbygg-2026-eab-ab.jpg'),
  ('nordbygg-2026-exhibitor-139444', 'nordbygg-2026', 'Eagle kreativ Deutschland GmbH', 'C02:51', null, 'https://eaglekreativ.de', null),
  ('nordbygg-2026-exhibitor-139450', 'nordbygg-2026', 'EandoX', 'C02:11', jsonb_build_object('en', 'EandoX is environmental-performance software that helps brands and manufacturers take control of their sustainability data and meet environmental requirements — everything from LCA and EPD to CSRD.', 'sv', 'EandoX är en mjukvara för miljöprestanda som hjälper varumärken och tillverkare att ta kontroll över sin hållbarhetsdata och uppfylla miljökrav – allt från LCA och EPD till CSRD.'), 'https://www.eandox.com/', 'assets/images/exhibitors/nordbygg-2026-eandox.jpg'),
  ('nordbygg-2026-exhibitor-137372', 'nordbygg-2026', 'ebm-papst AB', 'A20:18', jsonb_build_object('en', 'Your partner for smart and sustainable ventilation

In our stand you will find many of the market''s most innovative solutions for air, cooling and heating technology. We help you build energy-efficient and future-proof systems — whether you work with OEM solutions or with energy upgrades of existing buildings.

Ventilation – Retrofit:
We support ventilation installers, technicians, property owners and housing co-operatives that want to upgrade existing systems for better comfort and lower energy use.

> Discover Ventilationslyftet — our concept that makes it easy to choose the right energy-efficiency solution and that supports you through the entire process.

For OEM manufacturers:
We offer customised fan and motor solutions with intelligent systems for optimal operation and control — tailored to your applications.

Who are we?

ebm-papst is a family-owned company headquartered in Germany and a world leader in fans and motors. Since 1963 we have set the standard for engineering, aerodynamics and digitalisation.

We have been in Sweden since 1973 with our head office, production and warehouse in Järfälla and local offices in Gothenburg, Häljarp, Linköping and Sundsvall.

Visit us at Nordbygg and discover how we can help you meet the future demands on energy efficiency and sustainability!', 'sv', 'Din partner för smart och hållbar ventilation

I vår monter hittar du många av marknadens mest innovativa lösningar för luft-, kyla- och värmeteknik. Vi hjälper dig att skapa energieffektiva och framtidssäkra system – oavsett om du arbetar med OEM-lösningar eller med energieffektivisering av befintliga byggnader.

Ventilation – Retrofit:
Vi stöttar ventilationsinstallatörer, tekniker, fastighetsägare och bostadsrättsföreningar som vill uppgradera befintliga system för bättre komfort och lägre energiförbrukning.

> Upptäck Ventilationslyftet – vårt koncept som gör det enkelt att välja rätt lösning för energieffektivisering och ger stöd genom hela processen.

För OEM-tillverkare:
Vi erbjuder kundanpassade fläkt- och motorlösningar med intelligenta system för optimal drift och styrning – skräddarsytt för dina applikationer.

Vilka är vi?

ebm-papst är ett familjeägt företag med huvudkontor i Tyskland och världsledande inom fläktar och motorer. Sedan 1963 har vi satt standarden för teknik, aerodynamik och digitalisering.

I Sverige har vi funnits sedan 1973 med huvudkontor, produktion och lager i Järfälla samt lokala kontor i Göteborg, Häljarp, Linköping och Sundsvall.

Besök oss på Nordbygg och upptäck hur vi kan hjälpa dig att möta framtidens krav på energieffektivitet och hållbarhet!'), 'https://www.ebmpapst.se', 'assets/images/exhibitors/nordbygg-2026-ebm-papst-ab.jpg'),
  ('nordbygg-2026-exhibitor-139405', 'nordbygg-2026', 'eBVD', 'EH:15', jsonb_build_object('en', 'Through a digital service, the eBVD system provides a tool where you, as a manufacturer of construction products and building materials, can easily register and manage your digital environmental information.', 'sv', 'Genom en digital tjänst tillhandahåller eBVD-systemet ett verktyg där du som tillverkare av byggprodukter och byggmaterial enkelt kan registrera och hantera din digitala miljöinformation.'), null, 'assets/images/exhibitors/nordbygg-2026-ebvd.jpg'),
  ('nordbygg-2026-exhibitor-137482', 'nordbygg-2026', 'Ecoclime Group AB', 'A06:29', jsonb_build_object('en', 'Ecoclime Group is a group of companies that offers leading products and services within circular thermal energy, including ventilation, geothermal heating and recovery of thermal energy from waste water and sewage, in buildings and industrial processes. The group''s solutions deliver energy efficiency that typically increases the customer''s net operating income by more than 5 percent return on investment.

The company''s solutions help property owners future-proof their properties by making them more energy-smart. This is achieved through a reduced need for purchased thermal energy and lower power demand, based on optimised energy use and improved comfort for tenants — primarily through the recirculation of recovered energy and lower energy and power demand. The company also helps industrial processes recirculate and reuse energy, for example in water and wastewater plants.

Ecoclime Group runs and develops leading companies in the industry and operates across the entire value chain, from innovation and production of products through to installation, operation and service.', 'sv', 'Ecoclime Group är en koncern som erbjuder ledande produkter och tjänster inom cirkulär värmeenergi, innefattande ventilation, bergvärme samt återvinning av värmeenergi i spillvatten och avloppsvatten, i fastigheter och industriella processer. Koncernens lösningar bidrar till energieffektivisering som normalt ökar kundens drift- och räntenetto med mer än 5 procent i avkastning på investeringen.

Bolagets lösningar hjälper fastighetsägare att framtidssäkra sina fastigheter genom att göra dem mer energismarta. Detta sker genom minskat behov av köpt värmeenergi och lägre effektbehov, baserat på optimerad energianvändning och förbättrad komfort för hyresgäster, främst genom recirkulering av återvunnen energi samt minskade energi- och effektbehov. Bolaget hjälper även industriella processer att recirkulera och återbruka energi, exempelvis i VA-verk.

Ecoclime Group driver och utvecklar ledande bolag i branschen och verkar i hela värdekedjan, från innovation och tillverkning av produkter, till installation, drift- och servicetjänster.'), 'https://www.ecoclime.se', 'assets/images/exhibitors/nordbygg-2026-ecoclime-group-ab.jpg'),
  ('nordbygg-2026-exhibitor-139512', 'nordbygg-2026', 'EcoCocon', 'C07:50', jsonb_build_object('en', 'EcoCocon is redefining how we build — by transforming straw into a high-performance, industrially scalable building system.

Our prefabricated wood-and-straw panels integrate load-bearing structure, insulation and airtightness into a single solution — and make walls with a negative climate impact possible, manufactured from 89% straw and 10% wood.

What began as a niche innovation has evolved into an industrialised system, with more than 500 completed projects in 25 countries. Certified to Cradle to Cradle® (Silver) and Passive House standards, EcoCocon offers a fire-safe (REI 120), vapour-open and cost-effective alternative to conventional building systems.

With the launch of our automated factory in Voderady, we are taking the next step in industrial construction with bio-based materials — with the goal of making them an obvious part of tomorrow''s building standard.', 'sv', 'EcoCocon omdefinierar hur vi bygger — genom att omvandla halm till ett högpresterande, industriellt skalbart byggsystem.

Våra prefabricerade trä-halmpaneler integrerar bärande konstruktion, isolering och lufttäthet i en och samma lösning — och möjliggör väggar med negativ klimatpåverkan, tillverkade av 89 % halm och 10 % trä.

Det som började som en nischinnovation har utvecklats till ett industrialiserat system, med över 500 genomförda projekt i 25 länder. Certifierat enligt Cradle to Cradle® (Silver) och Passive House erbjuder EcoCocon ett brandsäkert (REI 120), diffusionsöppet och kostnadseffektivt alternativ till konventionella byggsystem.

Med lanseringen av vår automatiserade fabrik i Voderady tar vi nästa steg i industriellt byggande med biobaserade material — med målet att göra dem till en självklar del av framtidens byggstandard.'), 'https://www.ecococon.eu', 'assets/images/exhibitors/nordbygg-2026-ecococon.jpg'),
  ('nordbygg-2026-exhibitor-138242', 'nordbygg-2026', 'Ecoforest Geotermia SL', 'A16:25', jsonb_build_object('en', 'Ecoforest was founded in 1959 by Jose Carlos Alonso. His vision was to develop innovative products that were both economical and environmentally friendly, with the aim of making the world a better place.

Today, more than 50 years later, Ecoforest is the technology leader in the heating sector, with solutions based exclusively on clean and natural energy.

Ecoforest is a European manufacturer of water-to-water and air-to-water heat pumps with inverter technology, using the natural refrigerant R290. Outputs of 1 to 600 kW are managed efficiently by Ecoforest''s in-house software.', 'sv', 'Ecoforest grundades 1959 av Jose Carlos Alonso. Hans vision var att utveckla innovativa produkter som var både ekonomiska och miljövänliga, med målet att göra världen till en bättre plats.

Idag, mer än 50 år senare, är Ecoforest den tekniska ledaren inom uppvärmningssektorn, med lösningar som baseras uteslutande på ren och naturlig energi.

Ecoforest är en europeisk tillverkare av vatten-till-vatten- och luft-till-vatten-värmepumpar med inverterteknik och som använder det naturliga köldmediet R290. Effekten på 1 till 600 kW hanteras effektivt av Ecoforests egenutvecklade programvara.'), 'https://www.ecoforest.com/en', 'assets/images/exhibitors/nordbygg-2026-ecoforest-geotermia-sl.jpg'),
  ('nordbygg-2026-exhibitor-134689', 'nordbygg-2026', 'EcoGuard AB', 'A19:11', jsonb_build_object('en', 'In 2004 we started out by installing 4,500 wireless electricity and temperature sensors at Lindesbergsbostäder. We have long been known for our wireless temperature measurement with 20-year battery life and excellent range through the walls and ceilings of a building. It is a product that property owners across the country have discovered the value of. Today we handle metering data collection regardless of technology, communication method and brand within a property. We have the tools to collect the information, but also the knowledge of how to use it to become a more efficient property owner. Curves is our software for individual metering, regardless of metering technology.

Because our solutions are open and easy to implement in both newly built and existing properties, we are an attractive supplier and can therefore grow steadily in a growing market. Today we have offices in Örebro, Stockholm, Gothenburg, Malmö and Norrköping. We are now the largest player in individual metering, both by revenue and by number of employees. We are proud to be present in properties all over Sweden.', 'sv', '2004 började vi med att installera 4.500 trådlösa el- och temperaturgivare hos Lindesbergsbostäder. Vi är sedan länge kända för vår trådlösa temperaturmätning med 20 års batterilivslängd och en fantastisk räckvidd genom väggar och tak inne i hus. Det är en produkt som fastighetsägare över hela landet har upptäckt nyttan av. Idag hanterar vi mätinsamling oavsett teknik, kommunikationssätt och fabrikat i en fastighet. Vi har verktygen för insamling av information, men också kunskapen om hur man använder den för att bli en effektivare fastighetsägare. Curves är vår programvara för individuell mätning, oavsett mätteknik.

Eftersom våra lösningar är öppna och enkla att implementera i både nyproducerade, som befintliga fastigheter så är vi en attraktiv leverantör och kan därmed växa stadigt på en ökande marknad. Idag har vi kontor i Örebro, Stockholm, Göteborg, Malmö och Norrköping. Vi är idag störst inom individuell mätning vad gäller omsättning och personalstyrka. Vi är stolta över att vi finns i fastigheter över hela Sverige.'), 'https://www.ecoguard.se', 'assets/images/exhibitors/nordbygg-2026-ecoguard-ab.jpg'),
  ('nordbygg-2026-exhibitor-135333', 'nordbygg-2026', 'edding', 'BG:11', null, 'https://www.p-klitgaard.se', null),
  ('nordbygg-2026-exhibitor-139961', 'nordbygg-2026', 'Edplit', 'A10:12', null, 'https://edplit.com', null),
  ('nordbygg-2026-exhibitor-137897', 'nordbygg-2026', 'Edsby Porten', 'C07:33G', jsonb_build_object('en', 'Made-to-measure garage doors from Edsbyn. Hinged doors, up-and-over doors and storeroom doors in your own design. Swedish production, preferably in quality timber from Hälsingland.', 'sv', 'Måttbeställda Garageportar från Edsbyn. Slagportar, Vipportar och Förrådsdörrar i din egen design. Svensk produktion och gärna i kvalitetsvirke från Hälsingland.'), 'https://www.edsbyporten.se', 'assets/images/exhibitors/nordbygg-2026-edsby-porten.jpg'),
  ('nordbygg-2026-exhibitor-139215', 'nordbygg-2026', 'Einhell Nordic A/S', 'B11:11', jsonb_build_object('en', 'Einhell Germany AG has its head office in Landau an der Isar, just outside Munich. For more than 50 years, the Einhell brand has stood for smart solutions for DIYers and tradespeople — for the home, the garden and leisure.

From cordless drivers to mitre and chop saws, Einhell develops and sells innovative products in more than 90 countries through over 41 subsidiaries.

Since Josef Thannhuber founded the company in 1964, it has grown into an international business with more than 1,600 employees worldwide.

We are the ones who keep going when others have stopped.

But Einhell stands for much more:

* simple solutions
* quality
* genuine service at the best price-performance ratio
* functional products and innovations
* boundless possibilities', 'sv', 'Einhell Germany AG’s har sitt huvudkontor i Landau an der Isar utanför München. I över 50 år har varumärket Einhell stått för smarta lösningar för hemmafixare och hantverkare – för hus, trädgård och fritid.

Från skruvdragare till kap- och gersågar utvecklar och säljer Einhell innovativa produkter i mer än 90 länder genom över 41 dotterbolag.

Sedan Josef Thannhuber startade företaget 1964 har det vuxit till en internationell verksamhet med mer än 1 600 medarbetare världen över.

Vi är de som fortsätter framåt när andra har stannat upp.

Men Einhell står för mycket mer:

* enkla lösningar
* kvalitet
* verklig service till bästa pris-prestanda-förhållande
* funktionella produkter och innovationer
* gränslösa möjligheter'), 'https://www.einhell.se', 'assets/images/exhibitors/nordbygg-2026-einhell-nordic-a-s.jpg'),
  ('nordbygg-2026-exhibitor-134769', 'nordbygg-2026', 'EKB Produkter AB', 'A20:34', jsonb_build_object('en', 'WELCOME TO EKB FLÄKTAR in stand A20:34
We have every type of FAN. Whether you are an installer, a consultant or a machine builder, we have something for you.
Our goal is always to be able to offer fan solutions of the highest quality at competitive prices.', 'sv', 'VÄLKOMMEN TILL EKB FLÄKTAR i monter A20:34
Vi har alla typer av FLÄKTAR. Oavsett om du är installatör, konsult eller maskintillverkare så har vi något för dig.
Vårt mål är att alltid kunna erbjuda fläktlösningar av högsta kvalitet till konkurrenskraftiga priser.'), 'https://www.ekbflaktar.se', 'assets/images/exhibitors/nordbygg-2026-ekb-produkter-ab.jpg'),
  ('nordbygg-2026-exhibitor-134695', 'nordbygg-2026', 'Ekolution', 'C06:51', jsonb_build_object('en', 'Ekolution produces insulation made from industrial hemp grown in Skåne, with the factory located in Staffanstorp. Hemp-fibre insulation combines good thermal insulation, sound damping and a healthy work environment for tradespeople. The insulation has the lowest climate impact of any insulation on the market today and contributes to sustainable construction.', 'sv', 'Ekolution producerar isolering av industrihampa som odlas i Skåne och fabriken finns i Staffanstorp. Hampafiberisolering kombinerar god värmeisolering, ljuddämpning och bidrar till en god arbetsmiljö för hantverkare. Isoleringen har den lägsta klimatpåverkan för isolering som finns på marknaden idag och bidrar till ett hållbart byggande.'), 'https://www.ekolution.se', 'assets/images/exhibitors/nordbygg-2026-ekolution.jpg'),
  ('nordbygg-2026-exhibitor-137859', 'nordbygg-2026', 'EKOVILLA', 'C08:50', jsonb_build_object('en', 'We are part of the listed group EcoUp Oyj, which is active in recycling and the manufacture of green building materials. The best-known brand in the group is EKOVILLA, which started back in 1979. We manufacture bio-based, climate-neutral cellulose insulation made from recycled material from the wood and paper industries and recycled paper. Production takes place in 6 of our own factories, and we own our own installer network in Sweden and Finland. We are the largest manufacturer and installer of loose-fill insulation in the Nordic region. More than 85% of all newly built single-family homes in Finland are insulated with EKOVILLA cellulose insulation.

Choose a reliable and knowledgeable supplier of climate-neutral insulation and energy-efficient building systems. Choose EKOVILLA (Isoleringslandslaget), the Swedish national team in loose-fill insulation!', 'sv', 'Vi är en del av den börsnoterade koncernen EcoUp Oyj som är verksamma inom återvinning och tillverkning av gröna byggmaterial. Det mest kända varumärket i koncernen är EKOVILLA som startade redan 1979. Vi tillverkar biobaserad, klimatneutral Cellulosaisolering baserad på återvunnet material från trä- och pappersindustrin samt returpapper. Tillverkningen sker i 6 egna fabriker och vi äger vårt eget installatörsnätverk i Sverige och Finland. Vi är Nordens största tillverkare och installatör av lösullsisolering. Mer än 85 % av alla nybyggda småhus i Finland isoleras med EKOVILLA Cellulosaisolering.

Välj en trygg och kunnig leverantör av klimatneutral isolering och energieffektiva byggsystem. Välj EKOVILLA (Isoleringslandslaget), Svenska Landslaget i Lösullsisolering!'), 'https://www.ekovilla.se', 'assets/images/exhibitors/nordbygg-2026-ekovilla.jpg'),
  ('nordbygg-2026-exhibitor-137339', 'nordbygg-2026', 'El-Björn AB', 'B09:21', jsonb_build_object('en', 'El-Björn has supplied people and temporary worksites with the right power, light and climate since 1954, and we keep moving forward. Sustainable, resource-efficient energy in the right form, where you need it and when you need it.

We work long-term, persistently and hard so that you know you always get the best, and that our products live up to their promises. Our roots in Småland and our long experience are the foundation as we develop tomorrow''s solutions together with you.', 'sv', 'El-Björn har försett människor och tillfälliga arbetsplatser med rätt kraft, ljus och klimat sedan 1954 och vi fortsätter framåt. Hållbar och resurssnål energi i rätt form, där du behöver och när du behöver den.

Vi arbetar långsiktigt, uthålligt och hårt för att ni skall veta att ni alltid får det bästa och att våra produkter håller vad de lovar. Vårt småländska ursprung och vår långa erfarenhet är grunden när vi utvecklar framtidens lösningar tillsammans med er.'), 'https://www.elbjorn.com', 'assets/images/exhibitors/nordbygg-2026-el-bjorn-ab.jpg'),
  ('nordbygg-2026-exhibitor-135354', 'nordbygg-2026', 'Eld & Vatten', 'C05:31', null, 'https://www.eldochvatten.se', null),
  ('nordbygg-2026-exhibitor-134789', 'nordbygg-2026', 'Elecosoft Consultec AB', 'C03:10', jsonb_build_object('en', 'Leading supplier of software for the construction industry, with a focus on simplifying and streamlining the day-to-day work of customers. Keeping pace with the rapid digitalisation of the industry, we offer flexible and innovative solutions that create value. Development is driven in close cooperation with customers through support, training and consultancy services.', 'sv', 'Ledande leverantör av programvaror för byggbranschen med fokus på att förenkla och effektivisera kunders vardag. I takt med branschens snabba digitalisering erbjuds flexibla och innovativa lösningar som skapar värde. Utvecklingen drivs i nära samarbete med kunder genom support, utbildningar och konsulttjänster.'), 'https://eleco.com/se/', 'assets/images/exhibitors/nordbygg-2026-elecosoft-consultec-ab.jpg'),
  ('nordbygg-2026-exhibitor-135348', 'nordbygg-2026', 'Electrolux Centrala Bygg', 'C04:31', null, 'https://www.centralabygg.com', null),
  ('nordbygg-2026-exhibitor-136055', 'nordbygg-2026', 'Electrolux Professional', 'C03:21', jsonb_build_object('en', 'Electrolux Professional Group is one of the leading global suppliers of laundry for professional users. We are the market leader and have the most energy-efficient washers and dryers in professional laundry. Our strength also lies in being a complete supplier — providing our customers not only with washers and dryers, but also with project planning support, dosing systems, detergents, booking systems, service contracts, and finance and rental of products. With us, you get a full solution and products that make a real difference over their entire lifetime.

Our innovative products and worldwide service network make our customers'' day-to-day work easier, more profitable and genuinely sustainable, every day.', 'sv', 'Electrolux Professional Group är en av de ledande globala leverantörerna av tvätt för professionella användare. Vi är marknadsledande och har de mest energisnåla tvätt-och torkmaskinerna inom professionell tvätt. Vår styrka ligger också i att vi är en helhetsleverntör som förser våra kunder, inte bara med tvätt-och torkprodukter, utan även med projekteringshjälp, doseringssystem, tvättmedel, bokningssystem, serviceavtal samt finansiering och hyra av produkter. Hos hos får du en helhetslösning och produkter som ger stor skillnad över hela livstiden.

Våra innovativa produkter och världsomspännande servicenätverk gör det dagliga arbetet för våra kunder enklare, mer lönsamt och verkligt hållbart varje dag.'), 'https://www.electroluxprofessional.com/se', 'assets/images/exhibitors/nordbygg-2026-electrolux-professional.jpg'),
  ('nordbygg-2026-exhibitor-140056', 'nordbygg-2026', 'Elementric', 'A10:33', jsonb_build_object('en', 'Industry rule 2026:1, which came into force on 1 January 2026, requires the installation of a certified water alarm in the sink cabinet and behind the dishwasher in new construction or when an existing kitchen is renovated by a plumber. Elementric produces the only certified, type-approved digital water alarm in Sweden. It is designed for central monitoring and alarms feeding into, for example, a BMS or our mobile app.', 'sv', 'Branschregeln 2026:1 som trädde i kraft 1 januari 2026 kräver installation av certifierat vattenlarm i diskbänkskåp och bakom diskmaskin vid nyproduktion eller vid VVS renovering av befintligt kök. Elementric producerar den enda certifierade, typgodkända digitala vattenlarmet i Sverige.  Apassad för central övervakning och larm in i tex ett BMS eller i vår mobila app.'), 'https://www.elementric.se', 'assets/images/exhibitors/nordbygg-2026-elementric.jpg'),
  ('nordbygg-2026-exhibitor-138649', 'nordbygg-2026', 'Elon Group AB/Elon Business - Construction & Property', 'C06:30', jsonb_build_object('en', 'We deliver to those who build and manage properties

We deliver white goods and kitchens to everyone who designs, builds and manages properties. Elon Business Construction & Property is with you throughout the process. From the project planning stage, through the entire warranty period and onwards.', 'sv', 'Vi levererar till er som bygger och förvaltar

Vi levererar vitvaror och kök till alla er som ritar, bygger och förvaltar fastigheter. Elon Business Construction & Property finns med under hela processen. Från projekteringen, under hela garantitiden och framåt.'), 'https://www.elongroup.se', null),
  ('nordbygg-2026-exhibitor-139627', 'nordbygg-2026', 'ELSYS', 'A14:12', jsonb_build_object('en', 'ELSYS offers wireless sensors for smart buildings, cities and industries, where the solutions contribute to a better indoor climate, increased energy efficiency and more dynamic workplaces, alongside many other use cases.
The head office is in northern Sweden and the products are manufactured within the EU. With long battery life and sensors that can be tailored to your business needs, ELSYS offers a broad range of high-quality sensors covering both indoor and outdoor sensors across technologies such as LoRaWAN, NB-IoT and wMBus.
With a dedicated team and as a proud member of the Bemsiq group, owned by Investment AB Latour, ELSYS is at the forefront of the market and contributes its expertise around the world.', 'sv', 'ELSYS erbjuder trådlösa sensorer för smarta byggnader, städer och industrier, där lösningarna bidrar till bättre inomhusklimat, ökad energieffektivitet och mer dynamiska arbetsplatser, samt många andra användningsområden.
Huvudkontoret finns i norra Sverige och produkterna är tillverkade inom EU. Med en lång batteritid och sensorer som kan anpassas efter din verksamhets behov har ELSYS ett brett sortiment av högkvalitativa sensorer som innefattar både inomhus och utomhussensorer inom teknologier så som LoRaWAN, Nb-iot och Wmbus.
Med ett dedikerat team och som stolt del av Bemsiq-koncernen med Investment AB Latour som ägare ligger ELSYS i framkant på marknaden och bidrar med sin expertis världen över.'), 'https://www.elsys.se/en', 'assets/images/exhibitors/nordbygg-2026-elsys.jpg'),
  ('nordbygg-2026-exhibitor-139612', 'nordbygg-2026', 'Eltrode AB', 'A13:23', jsonb_build_object('en', 'Eltrode is a supplier of mobile heat pumps.', 'sv', 'Eltrode är en leverantör av mobila värmepumpar.'), 'https://Eltrode.se', 'assets/images/exhibitors/nordbygg-2026-eltrode-ab.jpg'),
  ('nordbygg-2026-exhibitor-134728', 'nordbygg-2026', 'Elvaco AB', 'A14:12', jsonb_build_object('en', 'Elvaco offers open, end-to-end solutions for energy metering that help our customers grow their business in a sustainable way. We are specialised in communication solutions and infrastructure — everything from meters and sensors to cloud-based systems and services. Our products and services are used for energy efficiency, billing and statistics by thousands of companies around the world in the district-heating, water, property, electricity and gas industries.', 'sv', 'Elvaco erbjuder öppna helhetslösningar för energimätning som hjälper våra kunder att utveckla sin verksamhet på ett hållbart sätt. Vi är specialiserade inom kommunikationslösningar och infrastruktur, allt från mätare och sensorer till molnbaserade system och tjänster. Våra produkter och tjänster används för energieffektivisering, fakturering och statistik av tusentals företag runt om i världen inom fjärrvärme-, vatten-, fastighets- el- och gasbranschen.'), 'https://www.elvaco.se', 'assets/images/exhibitors/nordbygg-2026-elvaco-ab.jpg'),
  ('nordbygg-2026-exhibitor-139825', 'nordbygg-2026', 'Emlid', 'AG:97', jsonb_build_object('en', 'Emlid develops high-precision GNSS receivers and software that make professional-grade positioning accessible to everyone—from surveyors to civil engineers and field teams.

Paired with the Emlid Flow app and Emlid Flow 360 cloud service, Emlid Reach receivers deliver centimeter-accurate results, speed up the entire field-to-office workflow, and integrate seamlessly with CAD software. All without unnecessary complexity.

Founded in 2014, Emlid has grown into a global brand trusted by professionals worldwide. With offices in Lisbon, Portugal, and Budapest, Hungary, Emlid ships Reach receivers worldwide through its online store and network of official dealers.', 'sv', 'Emlid utvecklar högprecisa GNSS-mottagare och programvara som gör professionell positionering tillgänglig för alla – från lantmätare till anläggningsingenjörer och fältteam.

Tillsammans med appen Emlid Flow och molntjänsten Emlid Flow 360 levererar Emlid Reach-mottagarna resultat med centimeterprecision, snabbar upp hela arbetsflödet från fält till kontor och integrerar sömlöst med CAD-program. Allt utan onödig komplexitet.

Emlid grundades 2014 och har vuxit till ett globalt varumärke som proffs världen över förlitar sig på. Med kontor i Lissabon i Portugal och Budapest i Ungern levererar Emlid Reach-mottagare över hela världen via sin webbutik och sitt nätverk av officiella återförsäljare.'), 'https://emlid.com', 'assets/images/exhibitors/nordbygg-2026-emlid.jpg'),
  ('nordbygg-2026-exhibitor-140099', 'nordbygg-2026', 'Emoss Mobile Systems B.V.', 'C03:41', jsonb_build_object('en', 'Emoss Mobile Systems is a leading Dutch manufacturer of fully electric and hybrid drive solutions for on and offroad applications. With over 20 years of experience and 1.000+ vehicles on the road, we design and build complete e-mobility systems, including battery electric drivetrains, retrofit solutions, and tailormade integrations for OEMs and end users. Our proven technologies and engineering expertise enable customers worldwide to transition to efficient, zero emission transportation.

Serving markets across construction, transport, logistics, municipal services, and specialty vehicles, Emoss delivers reliable systems built for demanding real-world operations. At Nordbygg, we showcase how our electric, hybrid, and retrofit platforms help European industries accelerate sustainability, improve performance, and reduce operational costs.', 'sv', 'Emoss Mobile Systems är en ledande nederländsk tillverkare av helelektriska och hybrida drivlinor för applikationer både on- och offroad. Med över 20 års erfarenhet och fler än 1 000 fordon i drift designar och bygger vi kompletta system för e-mobility, inklusive batterielektriska drivlinor, retrofit-lösningar och skräddarsydda integrationer för OEM-tillverkare och slutanvändare. Vår beprövade teknik och ingenjörskunskap gör det möjligt för kunder världen över att gå över till effektiva och utsläppsfria transporter.

Emoss betjänar marknader inom bygg, transport, logistik, kommunala tjänster och specialfordon, och levererar tillförlitliga system byggda för krävande verkliga förhållanden. På Nordbygg visar vi hur våra elektriska, hybrida och retrofit-baserade plattformar hjälper europeiska industrier att accelerera sin hållbarhetsresa, förbättra prestanda och sänka driftskostnaderna.'), 'https://www.emoss.nl', 'assets/images/exhibitors/nordbygg-2026-emoss-mobile-systems-b-v.jpg'),
  ('nordbygg-2026-exhibitor-135904', 'nordbygg-2026', 'EMTF/Energi & Miljö', 'AG:06 (+1)', null, 'https://www.emtf.se', null),
  ('nordbygg-2026-exhibitor-137089', 'nordbygg-2026', 'Enduce AB - en ny standard för golvbrunnar', 'A05:04', null, 'https://www.enduce.se', null),
  ('nordbygg-2026-exhibitor-137303', 'nordbygg-2026', 'Energiverket Stockholm AB', 'A10:02', null, 'https://www.energiverket.se', null),
  ('nordbygg-2026-exhibitor-138196', 'nordbygg-2026', 'Enervent Zehnder Oy', 'A20:23', jsonb_build_object('en', 'Enervent Zehnder is a Finnish company with a passion for indoor climate. We have developed, manufactured and marketed energy-efficient solutions for a better indoor climate since 1983.

Enervent Zehnder has been part of the Zehnder Group since 2018. Zehnder is a leading global supplier of complete solutions for a healthy indoor climate. At Zehnder we strive to improve quality of life by providing the best indoor climate solutions. Our mission is to offer a healthy indoor climate with solutions of the highest quality. Living spaces are kept at a comfortable temperature by our radiators and heating and cooling ceilings, while our ventilation solutions make sure you can breathe fresh, clean air 24/7.', 'sv', 'Enervent Zehnder är ett finskt företag med passion för inomhusklimat. Vi har utvecklat, tillverkat och marknadsfört energieffektiva lösningar för bättre inomhusklimat sedan 1983.

Enervent Zehnder har varit en del av Zehnder-koncernen sedan 2018. Zehnder är en ledande global leverantör av kompletta lösningar för ett hälsosamt inomhusklimat. På Zehnder strävar vi efter att förbättra livskvaliteten genom att tillhandahålla de bästa inomhusklimatlösningarna. Vårt uppdrag är att erbjuda ett hälsosamt inomhusklimat med lösningar av högsta kvalitet. Bostadsutrymmen hålls vid en behaglig temperatur av våra radiatorer och värme- och kyltak, medan våra ventilationslösningar ser till att du kan andas frisk, ren luft 24/7.'), 'https://www.enervent.com / www.zehndergroup.com', 'assets/images/exhibitors/nordbygg-2026-enervent-zehnder-oy.jpg'),
  ('nordbygg-2026-exhibitor-139319', 'nordbygg-2026', 'Ennergus Innovation', 'AG:69', jsonb_build_object('en', 'ENNERIO cloud-based SaaS platform connects every building automation system and data source into one intelligent, adaptive cloud ecosystem.
OUR STRENGHTS
Why choose Ennerio?
+15 years of experience
Deep building engineering knowledge for digital solutions driven by real need.
Efficient Energy Savings
Up to 15% annual energy savings through continuous optimization.
Performance & Efficiency
Data-driven decisions with full ESG and KPI visibility.
Real Time Risk Reduction
Early detection of faults and predictive maintenance.
Flexibility & Control
Centralized real-time control across multiple sites.
WE - IN NUMBERS
Impact you can feel
Intelligent Cloud Platform for Smart Building Energy & System Control, 18-36 months
Return of investment (ROI)
24/7 support
Remote Monitoring & Control
Up to 15% Annual Energy Savings
340 tones Annual CO2 Savings
ENNERIO enables centralized, remote control of all connected building systems through a secure cloud interface.
Key Outcomes:
Fewer on-site interventions
Faster response times
Portfolio-wide operational consistency
ENNERIO provides continuous, real-time visibility into energy consumption across buildings, zones, and systems.
By continuously analyzing system behavior, ENNERIO detects anomalies and early warning signs of faults.
Key Outcomes:
Early fault detection
Reduced emergency maintenance
Lower long-term maintenance costs.
ENNERIO transforms complex operational data into clear, decision-ready ESG insights.
Key Outcomes:
Clear ESG performance visibility
Simplified reporting
Measurable CO2 reduction.
Whether managing one building or a distributed portfolio, the platform provides consistent visibility, benchmarking, and control across all assets.
Key Outcomes:
Cross-site benchmarking
Standardized operations
Solar and other renewable sources integration and monitoring
Optimized electricity usage according Nordpool data
Strategic, data-driven decisions.
Data Security:
TIER III datacenter
Our code checked by OWASP framework
GDPR and NIS2 policies
One Platform. Total Control
Energy Monitoring & Optimization
ENNERIO provides continuous, real-time visibility into energy consumption across buildings, zones, and systems.
Key Outcomes:
Up to 15% annual energy savings
Reduced peak loads
Transparent energy performance tracking
Remote System Control
ENNERIO enables centralized, remote control of all connected building systems through a secure cloud interface.
Key Outcomes:
Fewer on-site interventions
Faster response times
Portfolio-wide operational consistency
Predictive Maintenance
By continuously analyzing system behavior, ENNERIO detects anomalies and early warning signs of faults.
Key Outcomes:
Early fault detection
Reduced emergency maintenance
Lower long-term maintenance costs
ESG & Sustainability Reporting
ENNERIO transforms complex operational data into clear, decision-ready ESG insights.
Key Outcomes:
Clear ESG performance visibility
Simplified reporting
Measurable CO2 reduction
Portfolio-Wide Performance Management
Whether managing one building or a distributed portfolio, the platform provides consistent visibility, benchmarking, and control across all assets.
Key Outcomes
Cross-site benchmarking
Standardized operations
Strategic, data-driven decisions
Data Security
TIER III datacenter
Our code checked by OWASP framework
GDPR and NIS2 policies
No Coding Required
No programming knowledge is required
UX is tailored to your needs
Our software is fully customizable.', 'sv', 'ENNERIOs molnbaserade SaaS-plattform kopplar samman varje system för fastighetsautomation och varje datakälla till ett intelligent, adaptivt molnekosystem.
VÅRA STYRKOR
Varför välja Ennerio?
+15 års erfarenhet
Djup byggnadsteknisk kunskap för digitala lösningar som drivs av verkliga behov.
Effektiva energibesparingar
Upp till 15 % årliga energibesparingar genom kontinuerlig optimering.
Prestanda och effektivitet
Datadrivna beslut med full insyn i ESG och KPI:er.
Riskreduktion i realtid
Tidig upptäckt av fel och förebyggande underhåll.
Flexibilitet och kontroll
Centraliserad realtidsstyrning över flera fastigheter.
VI – I SIFFROR
Effekt du kan känna
Intelligent molnplattform för smart energi- och systemstyrning i fastigheter, 18–36 månader
Återbetalningstid (ROI)
Support dygnet runt
Fjärrövervakning och fjärrstyrning
Upp till 15 % årliga energibesparingar
340 ton årliga CO2-besparingar
ENNERIO möjliggör centraliserad fjärrstyrning av alla anslutna fastighetssystem via ett säkert molngränssnitt.
Viktiga resultat:
Färre besök på plats
Snabbare svarstider
Enhetlig drift över hela portföljen
ENNERIO ger kontinuerlig insyn i energiförbrukningen i realtid över fastigheter, zoner och system.
Genom att kontinuerligt analysera systemens beteende upptäcker ENNERIO avvikelser och tidiga varningstecken på fel.
Viktiga resultat:
Tidig feldetektion
Minskat akut underhåll
Lägre underhållskostnader på lång sikt.
ENNERIO omvandlar komplex driftsdata till tydliga, beslutsklara ESG-insikter.
Viktiga resultat:
Tydlig insyn i ESG-prestanda
Förenklad rapportering
Mätbar CO2-minskning.
Oavsett om du förvaltar en enskild fastighet eller en distribuerad portfölj ger plattformen konsekvent insyn, benchmarking och kontroll över alla tillgångar.
Viktiga resultat:
Benchmarking mellan fastigheter
Standardiserad drift
Integration och övervakning av sol och andra förnybara källor
Optimerad elanvändning enligt data från Nord Pool
Strategiska, datadrivna beslut.
Datasäkerhet:
TIER III-datacenter
Vår kod granskas enligt OWASP-ramverket
GDPR- och NIS2-policyer
En plattform. Full kontroll
Energiövervakning och optimering
ENNERIO ger kontinuerlig insyn i energiförbrukningen i realtid över fastigheter, zoner och system.
Viktiga resultat:
Upp till 15 % årliga energibesparingar
Minskade effekttoppar
Transparent uppföljning av energiprestanda
Fjärrstyrning av system
ENNERIO möjliggör centraliserad fjärrstyrning av alla anslutna fastighetssystem via ett säkert molngränssnitt.
Viktiga resultat:
Färre besök på plats
Snabbare svarstider
Enhetlig drift över hela portföljen
Förebyggande underhåll
Genom att kontinuerligt analysera systemens beteende upptäcker ENNERIO avvikelser och tidiga varningstecken på fel.
Viktiga resultat:
Tidig feldetektion
Minskat akut underhåll
Lägre underhållskostnader på lång sikt
ESG- och hållbarhetsrapportering
ENNERIO omvandlar komplex driftsdata till tydliga, beslutsklara ESG-insikter.
Viktiga resultat:
Tydlig insyn i ESG-prestanda
Förenklad rapportering
Mätbar CO2-minskning
Prestandahantering över hela portföljen
Oavsett om du förvaltar en enskild fastighet eller en distribuerad portfölj ger plattformen konsekvent insyn, benchmarking och kontroll över alla tillgångar.
Viktiga resultat
Benchmarking mellan fastigheter
Standardiserad drift
Strategiska, datadrivna beslut
Datasäkerhet
TIER III-datacenter
Vår kod granskas enligt OWASP-ramverket
GDPR- och NIS2-policyer
Ingen kodning krävs
Ingen programmeringskunskap krävs
Användarupplevelsen anpassas efter dina behov
Vår programvara är fullt anpassningsbar.'), 'https://ennerio.com', 'assets/images/exhibitors/nordbygg-2026-ennergus-innovation.jpg'),
  ('nordbygg-2026-exhibitor-135570', 'nordbygg-2026', 'Enrad AB', 'A18:23', jsonb_build_object('en', 'Enrad manufactures the chillers and heat pumps of the future.
Our mission is to offer and develop environmentally friendly chillers and heat pumps that use the natural refrigerant propane, and to spread knowledge about natural refrigerants and energy efficiency. Buying chillers and heat pumps that harm the climate, and that will not be legal in a few years, is neither financially sound nor good for our planet. We need to shape a new and sustainable industry standard, in which the climate is always an obvious part of the conversation when new cooling and heat-pump installations are being put in.

We fight for a better climate, together with our customers, by offering sustainable and energy-efficient solutions.', 'sv', 'Enrad tillverkar framtidens kylaggregat och värmepumpar.
Vårt uppdrag är att erbjuda och utveckla miljövänliga kylaggregat och värmepumpar som använder det naturliga köldmediet propan, samt sprida kunskap om naturliga köldmedier och energieffektivitet. Att köpa kylaggregat och värmepumpar som är skadliga för klimatet och som inte kommer vara lagliga om några år är varken ekonomiskt eller bra för vår planet. Vi behöver forma en ny och hållbar branschstandard där klimatet alltid är en självklar del av diskussionerna när man installerar nya kyl och värmepumpsanläggningar.

Vi kämpar tillsammans med våra kunder för ett bättre klimat genom att erbjuda hållbara och energieffektiva lösningar.'), 'https://www.enrad.se', 'assets/images/exhibitors/nordbygg-2026-enrad-ab.jpg'),
  ('nordbygg-2026-exhibitor-133972', 'nordbygg-2026', 'Entral AB', 'B05:10', jsonb_build_object('en', 'Since 2015, Entral has helped companies create safe, secure and sustainable workplaces and public environments.
By combining smart access control, attendance monitoring and digital services such as Bolagskontroll and en3 connect, we give you full control.

We know that security never stands still. That is why Entral has developed solutions that meet the needs of both you and the market — today and tomorrow. Make sure you work with reputable companies and always have the right person in the right place across your projects.

Entral is more than a supplier. We are a long-term partner in modern security.', 'sv', 'Sedan 2015 har Entral hjälpt företag att skapa trygga, säkra och hållbara arbetsplatser samt offentliga miljöer.
Genom att kombinera smarta passersystem, närvarokontroll och digitala tjänster som Bolagskontroll och en3 connect ger vi dig full kontroll.

Vi vet att säkerhet inte står still. Därför har Entral utvecklat lösningar som möter både dina och marknadens behov – idag och imorgon. Säkerställ att du samarbetar med seriösa företag och alltid har rätt person på rätt plats i dina projekt.

Entral är mer än en leverantör. Vi är en långsiktig partner inom modern säkerhet.'), 'https://entral.se', 'assets/images/exhibitors/nordbygg-2026-entral-ab.jpg'),
  ('nordbygg-2026-exhibitor-139362', 'nordbygg-2026', 'EntRent AB', 'BG:13', null, 'https://www.entrent.se', 'assets/images/exhibitors/nordbygg-2026-entrent-ab.jpg'),
  ('nordbygg-2026-exhibitor-139408', 'nordbygg-2026', 'EPD - The international EPD system', 'EH:15', jsonb_build_object('en', 'The International EPD System is a global programme for environmental product declarations. Environmental product declarations (EPDs) provide transparent, verified and comparable information about the environmental impact of products and services from a life-cycle perspective.', 'sv', 'International EPD System är ett globalt program för miljövarudeklarationer. Miljövarudeklarationer (EPD:er) presenterar transparent, verifierad och jämförbar information om produkters och tjänsters miljöpåverkan ur ett livscykelperspektiv.'), 'https://www.ivl.se', 'assets/images/exhibitors/nordbygg-2026-epd-the-international-epd-system.jpg'),
  ('nordbygg-2026-exhibitor-137708', 'nordbygg-2026', 'EPSCEMENT', 'C11:60', jsonb_build_object('en', 'We at EPSCEMENT AB work from a simple idea: to make construction lighter, smarter and more efficient.

By combining concrete with insulating EPS beads we have developed a material that weighs less, insulates better and is faster to work with than traditional alternatives.

But we are more than a material. We work with a complete system, in which EPS-cement, reinforcement such as Tensobar and accessories work together to create efficient and durable structures.

We are a Swedish company with our roots in innovation, and we were the first in Sweden with EPS-cement. Today we are the market leader in our segment.

We deliver not only products but complete solutions, from material and accessories to pumping directly out on the construction site. The goal is to simplify the process, save time and create better conditions in every project.

In short: the feel of concrete without the weight, and a smarter way to build.', 'sv', 'Vi på EPSCEMENT AB jobbar med en enkel idé. Att göra byggandet lättare, smartare och mer effektivt.

Genom att kombinera betong med isolerande EPS-kulor har vi tagit fram ett material som väger mindre, isolerar bättre och går snabbare att jobba med än traditionella lösningar.

Men vi är mer än ett material. Vi jobbar med ett helt system där EPS-cement, armering som Tensobar och tillbehör samverkar för att skapa effektiva och hållbara konstruktioner.

Vi är ett svenskt bolag med rötter i innovation och var först i Sverige med EPS-cement. Idag är vi marknadsledande inom vårt segment.

Vi levererar inte bara produkter utan hela lösningar, från material och tillbehör till pumpning direkt ute på byggarbetsplatsen. Målet är att förenkla processen, spara tid och skapa bättre förutsättningar i varje projekt.

Kort sagt, betongkänsla utan vikten och ett smartare sätt att bygga.'), 'https://www.epscement.com', 'assets/images/exhibitors/nordbygg-2026-epscement.jpg'),
  ('nordbygg-2026-exhibitor-134383', 'nordbygg-2026', 'Ergofast AB', 'B02:31', jsonb_build_object('en', 'We have fastening solutions and tools for efficient construction — the market''s best products and brands for true professionals. With our combined expertise as fastening specialists, we work actively to develop better, safer and more innovative solutions to new and old fastening problems. We do this on our own initiative in our R&D department, or together with our Premium Partners.', 'sv', 'Vi har infästningslösningar och verktyg för effektivt byggande, marknadens bästa produkter och varumärken för de verkliga proffsen. Med vår samlade kompetens som infästningsspecialister arbetar vi aktivt för att utveckla bättre, säkrare och mer innovativa lösningar på nya och gamla infästningsproblem. Vi gör det på eget initiativ i vår egen R&D eller utvecklar lösningar tillsammans med våra Premium Partners.'), 'https://www.ergofast.se', 'assets/images/exhibitors/nordbygg-2026-ergofast-ab.jpg'),
  ('nordbygg-2026-exhibitor-138134', 'nordbygg-2026', 'Ergosafe AB', 'C10:50', null, 'https://www.ergosafe.se', 'assets/images/exhibitors/nordbygg-2026-ergosafe-ab.jpg'),
  ('nordbygg-2026-exhibitor-134569', 'nordbygg-2026', 'ESBE AB', 'A04:16', jsonb_build_object('en', 'Most people probably do not give it a thought, but when you turn the tap and drink a glass of water, when you stand under the warm jets of the shower or perhaps when you pad barefoot across the heated floor — odds are that one of ESBE''s products is at work in the background.



ESBE is one of Europe''s leading manufacturers of hydronic solutions. Our valves and actuators are developed and engineered at our head office in Reftele, Sweden, to meet three demanding goals: they should use less energy, deliver more comfort and increase safety in heating, cooling and tap-water systems. Even though our products usually live a discreet existence, we put great emphasis on design, function, reliability and environmental responsibility.', 'sv', 'De flesta tänker förmodligen inte på det men när man vrider på kranen och dricker ett glas vatten, när man ställer sig under duschens varma strålar eller kanske när man tassar barfota över det uppvärmda golvet – då arbetar förmodligen en av ESBEs produkter i bakgrunden.



ESBE är en av Europas ledande tillverkare av hydroniska lösningar. Våra ventiler och ställdon utvecklas och konstrueras på huvudkontoret i svenska Reftele för att klara tre högt satta mål; de ska använda mindre energi, ge mer komfort och öka säkerheten i system för uppvärmning, kylning och tappvatten. Trots att produkterna oftast lever en undanskymd tillvaro lägger vi stor vikt vid design, funktion, pålitlighet och miljöhänsyn.'), 'https://www.esbe.eu', 'assets/images/exhibitors/nordbygg-2026-esbe-ab.jpg'),
  ('nordbygg-2026-exhibitor-140088', 'nordbygg-2026', 'ETC Byggentreprenad AB', 'C07:50', jsonb_build_object('en', 'Sustainable solutions for tomorrow''s construction
ETC Byggentreprenad has been the main contractor on every apartment block built by ETC Bygg: two apartment blocks in Växjö, three in Västerås and a high-rise in Malmö.

The buildings are climate-positive. Thanks to bio-based materials, more carbon dioxide is stored in the building than is emitted during the construction process.

In our eco-house factory in Hultsfred we manufacture finished element walls and infill walls in wood and straw (from EcoCocon), built to the customer''s specifications.

At present we work with larger projects, not individual single-family homes.

We also take on full main-contractor responsibility for larger building projects.

Our staff have expert knowledge of the materials wood and straw. In 2024 ETC Bygg was nominated for the Växjö Wood Architecture Prize and the Nordic Council Environment Prize 2024.

In 2024, ETC Bygg and the architects Kaminsky Arkitektur and Hans Eek were awarded the prestigious international UIA Award 2030 for sustainability for ETC Bygg''s apartment block in Västerås — chosen from a field of 125 projects from 40 countries. The prize was presented by the International Union of Architects, in cooperation with the UN, in Cairo.', 'sv', 'Hållbara lösningar för framtidens byggande
ETC Byggentreprenad har haft totalentreprenad på alla hyreshus byggda av ETC Bygg: Två hyreshus i Växjö, tre hyreshus i Västerås och ett höghus i Malmö.

Husen är klimatpositiva. Tack vare biobaserade material lagras mer koldioxid in i huset än vad som orsakas under byggprocessen.

Vi tillverkar färdiga element- och utfackningsväggar i trä och halm (från EcoCocon), i vår ekohusfabrik i Hultsfred, enligt kundens önskemål.

Vi arbetar i dagsläget med större projekt, inte enstaka villor.

Vi åtar oss även totalentreprenad för byggande av större projekt.

Vår personal har expertkunskap på materialen trä och halm.2024 nominerades ETC Bygg till Växjö Träbyggnadspris och Nordiska rådets miljöpris 2024.

2024 tilldelades ETC Bygg och arkitekterna Kaminsky Arkitektur och Hans Eek det prestigefyllda internationella hållparhetspriset UIA Award 2030 för ETC Byggs hyreshus i Västerås – i konkurrens med 125 projekt från 40 länder. Priset delades ut av International Union of Architects, i samarbete med FN i Kairo.'), 'https://etcbygg.se', 'assets/images/exhibitors/nordbygg-2026-etc-byggentreprenad-ab.jpg'),
  ('nordbygg-2026-exhibitor-139919', 'nordbygg-2026', 'Eumar Santehnika OÜ', 'C03:51', null, 'https://eumardesign.com', null),
  ('nordbygg-2026-exhibitor-139060', 'nordbygg-2026', 'European Fire Technology AB', 'C08:70', jsonb_build_object('en', 'Probably the world''s best fire-protection paint, FIRECOAT
Highest fire class: FM-Global. BAL40: B,s1d0
A single coat
50-year service life
Can be painted onto any substrate
Works with virtually all water-based top-coat paints
Can be sprayed, brushed or rolled
Can be painted on shingle and roofing-felt roofs
With FIRCOAT Membrane you can easily build fire-rated walls in cold attics, with the highest fire classification
With EFT ATTIC you can easily protect cold attics with a transparent agent
All products are non-toxic and environmentally friendly, BASTA-registered.', 'sv', 'Förmodligen världens bästa brandskyddsfärg FIRECOAT
högsta brandklass: FM-Global. BAL40: B,s1d0
Endast en strykning
50 års livslängd
Målas på alla underlag
I princip alla vattenbaserade Top Coats färger
Kan sprutas penslas eller rollas
Kan målas på shingeltak och papptak
MED FIRCOAT Membrane bygger man enkelt brandavskiljande väggar på kallvindar, högsta brandklassning
Med EFT ATTIC skyddar man kallvindar enkelt med transparent medel
Samtliga produkter giftfria och miljövänliga BASTA reg.'), 'https://www.eurofiretech.com', null),
  ('nordbygg-2026-exhibitor-134998', 'nordbygg-2026', 'EUROPLAST', 'A23:20', null, 'https://europlast.lv/en', 'assets/images/exhibitors/nordbygg-2026-europlast.jpg'),
  ('nordbygg-2026-exhibitor-139182', 'nordbygg-2026', 'EUROVENT CERTIFICATION', 'A21:11', jsonb_build_object('en', 'Eurovent Certita Certification is recognised globally as a trusted partner for third-party performance certification of products for heating, ventilation, air conditioning and refrigeration (HVAC-R).
Our strict and rigorous certification process drives innovation and improves energy efficiency, pushing manufacturers to keep innovating and reduce the carbon footprint of their products. This voluntary certification builds trust among stakeholders in the construction industry and reduces investment risk associated with HVAC-R solutions. It guarantees the reliability, efficiency and sustainability of certified products on the market.
At Eurovent Certita Certification we provide a comprehensive product database designed to meet the diverse needs of HVAC professionals, including installers, consultants, architects, technical design offices and project managers. You can easily access this valuable resource through our website at www.eurovent-certification.com.', 'sv', 'Eurovent Certita Certification är globalt erkänd som en pålitlig partner för tredjepartscertifiering av prestanda hos produkter för uppvärmning, ventilation, luftkonditionering och kylning (HVAC-R).
Vår strikta och rigorösa certifieringsprocess främjar innovation och förbättrar energieffektiviteten, vilket driver tillverkare att kontinuerligt förnya sig och minska koldioxidavtrycket från sina produkter. Denna frivilliga certifiering skapar förtroende bland intressenterna i byggbranschen och minskar investeringsriskerna i samband med HVAC-R-lösningar. Den garanterar tillförlitligheten, effektiviteten och hållbarheten hos certifierade produkter på marknaden.
På Eurovent Certita Certification tillhandahåller vi en omfattande produktdatabas som är utformad för att möta de olika behoven hos HVAC-proffs, inklusive installatörer, konsulter, arkitekter, tekniska studiekontor och projektledare. Du kan enkelt komma åt denna värdefulla resurs via vår webbplats på www.eurovent-certification.com.'), 'https://www.eurovent-certification.com/fr', 'assets/images/exhibitors/nordbygg-2026-eurovent-certification.jpg'),
  ('nordbygg-2026-exhibitor-135048', 'nordbygg-2026', 'Eveco Handel AB', 'A06:24', jsonb_build_object('en', 'Eveco is a supplier of smart products and systems for cooling, heating and air comfort. The main focus is commercial premises. Eveco offers its customers tailored solutions for the best possible indoor climate, and contributes its expertise throughout the entire process. The company was founded in 1979 and has many years of experience in the industry. Our offices and warehouse are in Mölndal, just outside Gothenburg. Since 2023, Eveco has been part of the Gothenburg-based industrial group Ernströmgruppen. Together they invest for the long term.

Eveco''s sustainable and competitively priced products are available through wholesalers across Sweden. The customers are primarily found in the HVAC, ventilation and electrical industries. There, Eveco is a well-established partner. Many of our suppliers are among the largest in Europe, which guarantees solid performance and quality.

The broad range covers fan coil units, fan heaters, air curtains, radiant heaters, floor convectors and shunt groups. All products come with matching control technology.

Meet Eveco in stand A06:24 — they are on site throughout Nordbygg. Get to know the products and hear the team tell you more. Welcome!', 'sv', 'Eveco är leverantör av smarta produkter och system för kyla, värme och luftkomfort. Den främsta inriktningen är kommersiella lokaler. Eveco erbjuder sina kunder anpassade lösningar för bästa möjliga inomhusklimat, samt bidrar med kompetens genom hela processen. Företaget startades 1979 och har idag en lång erfarenhet inom branschen. Kontor och lager ligger i Mölndal, precis utanför Göteborg. Sedan 2023 är Eveco en del i den Göteborgsbaserade industrikoncernen Ernströmgruppen. Tillsammans satsar de långsiktigt framåt.

Evecos hållbara och prisvärda produkter finns hos grossister över hela Sverige. Kunderna finns främst inom VVS, ventilations- och elbranschen. Där är Eveco en väletablerad samarbetspartner. Många av deras leverantörer är bland de största i Europa, vilket garanterar god prestanda och kvalitet.

I det breda sortimentet finns fläktkonvektorer, fläktluftvärmare, luftridåer, strålvärmare, golvkonvektorer och shuntgrupper. Till alla produkter finns tillhörande reglerteknik.

Träffa Eveco i monter A06:24, där finns de på plats under hela Nordbygg-mässan. Lär känna produkterna och hör representanterna berätta mer. Välkommen!'), 'https://www.eveco.se', 'assets/images/exhibitors/nordbygg-2026-eveco-handel-ab.jpg'),
  ('nordbygg-2026-exhibitor-140152', 'nordbygg-2026', 'EVIA', 'C06:51', null, 'https://www.evia.se', null),
  ('nordbygg-2026-exhibitor-139394', 'nordbygg-2026', 'EWES Sound Fastener/Hiil/EcoCocon/ETC', 'C07:50', jsonb_build_object('en', 'EWES Sound Fastener (SF) is a Swedish patented invention. Håkan Werner and Raimo Issal, the team behind Akoustos AB, developed and designed the sound-reducing wood screw.

In simple terms, you can swap your plasterboard screws for SF screws and so cut the perceived noise level by close to half. Without having to add more building materials or extra work. In fact, walls insulated with SF screws can be thinner than ordinary walls, so in addition to reducing unwanted noise you save material and gain valuable living space.

Sound Fastener has been thoroughly tested

The ability to absorb sound has been tested at the Sound Research Laboratories in the United Kingdom, the Technical University of Denmark and at RISE Research Institutes of Sweden AB. Mechanical tests of strength and stiffness have been carried out at Lund University, Sweden.

» Sound Fastener''s proven effect: 9 dB (which corresponds to close to a perceived halving of the noise level)', 'sv', 'EWES Sound Fastener (SF) är en svensk, patenterad uppfinning. Håkan Werner och Raimo Issal, teamet bakom Akoustos AB, har utvecklat och designat den ljudreducerande träskruven.

Enkelt förklarat kan du byta ut gipsskruvarna mot SF-skruvar och på så sätt nära halvera den upplevda ljudnivån. Utan att du behöver addera mer byggmaterial eller extra arbete. Faktum är att väggar isolerade med SF-skruvar kan vara tunnare än vanliga väggar, så förutom att du reducerar oönskade ljud, så sparar du material och ökar värdefull boyta.

Sound Fastener är noga testad

Förmågan att absorbera ljud har testats vid The Sound Research Laboratories i Storbritannien, vid Tekniska Universitetet i Danmark och vid RISE Research Institutes of Sweden AB. Mekaniska tester av hållfasthet och styvhet har testats vid Lunds universitet, Sverige.

» Sound Fasteners bevisade effekt: 9 dB (vilket motsvarar nära en upplevd halvering av ljudnivån)'), 'https://www.ewes.se', 'assets/images/exhibitors/nordbygg-2026-ewes-sound-fastener-hiil-ecococon-etc.jpg'),
  ('nordbygg-2026-exhibitor-139753', 'nordbygg-2026', 'Ewona Finland Oy', 'C08:63', jsonb_build_object('en', 'Our products help you create a clean
indoor climate where you are heard well.

Ewona® Oy is a Finnish company that works with acoustic solutions. We spend most
of our lives indoors, so completely dust-free and allergy-free acoustic and insulation solutions are a
point of honour for us.

We create spaces that stand the test of time, sound and life, and that increase well-being, vitality
and productivity. We produce solutions that amplify beneficial sounds, such as speech or
music, and dampen harmful sounds, such as noise. Our products, which are made from up to 85% recycled
material, create the indoor climate of the future. A commitment to sustainability, product safety
and comfort guides everything we do.

Recycled and safe

We take responsibility for our environment. We use environmentally friendly, additive-free and reused materials in the
manufacture of our products. All of our polyester-fibre products meet the allergy label and the
M1 emissions and cleanliness classification. The raw material in the finished product is, at best,
up to 85% recycled fibre. With ever-increasing demands on indoor air quality, we are the
only fully allergy-free manufacturer of acoustic solutions on the market. We are proud to meet today''s
standards — we are committed to making our products dust-free and allergy-safe.

A broad range of products

In addition to acoustic and sound-insulation solutions, our product range also covers thermal
insulation, filter mats and furniture padding.
Our products focus on allergy safety, recycling and recyclability — and, of course,
functionality. We use environmentally friendly, additive-free and recycled materials in the manufacture of
our products, all of which meet the requirements for the allergy label and are M1-classified for emissions and
cleanliness. The products are designed and manufactured in Finland.', 'sv', 'Våra produkter hjälper dig att skapa ett rent
inomhusklimat där du hörs bra.

Ewona® Oy är ett finskt företag som arbetar med akustiska lösningar. Vi tillbringar större
delen av våra liv inomhus, så helt dammfria och allergifria akustik- och isoleringslösningar är en
hederssak för oss.

Vi skapar utrymmen som står emot tidens tand, ljud och liv och som ökar välbefinnandet, vitali
teten och produktiviteten. Vi producerar lösningar som förstärker fördelaktiga ljud, som tal eller
musik, och dämpar skadliga ljud, som buller. Våra produkter, som tillverkas av upp till 85 % åter
vunnet material, skapar framtidens inomhusklimat. Engagemang för hållbarhet, produktsäkerhet
och bekvämlighet styr allt vi gör.

Återvunnet och säkert

Vi tar ansvar för vår miljö. Vi använder miljövänliga, tillsatsfria och återanvända material i till
verkningen av våra produkter. Alla våra polyesterfiberprodukter uppfyller allergimärkningen och
M1-emissions- och renhetsklassificeringen. Råmaterialet som används i slutprodukten är i bästa
fall upp till 85 % återvunnen fiber. Med ständigt ökande krav på inomhusluftens kvalitet är vi den
enda helt allergifria tillverkaren av akustiklösningar på marknaden. Vi uppfyller stolt den dagens
standarder – vi har förbundit oss att göra våra produkter dammfria och allergisäkra.

Brett sortiment av produkter

Förutom lösningar för akustik- och ljudisolering omfattar vårt produktsortiment även värmeisole
ring, filtermattor och möbelvadderingar.
Våra produkter fokuserar på allergisäkerhet, återvinning och återvinningsbarhet – och naturligtvis
funktionalitet. Vi använder miljövänliga, tillsatsfria och återvunna material vid tillverkningen av
våra produkter, som alla uppfyller kraven för allergimärkning och M1-klassade för utsläpp och
renhet. Produkterna är designade och tillverkade i Finland.'), 'https://ewona.fi/sv/', 'assets/images/exhibitors/nordbygg-2026-ewona-finland-oy.jpg'),
  ('nordbygg-2026-exhibitor-137322', 'nordbygg-2026', 'Expodul Uterum', 'C11:63', jsonb_build_object('en', 'Expodul Uterum has more than 50 years of experience in the design and in-house manufacture of conservatories, verandas and glass facades, and has the broadest product range on the market. We have been in business since 1975, and our vision is to create made-to-measure conservatories that bring quality of life and a closer connection with nature.', 'sv', 'Expodul Uterum har över 50 års erfarenhet av konstruktion och egen tillverkning av uterum, verandor och glaspartier och har det bredaste sortimentet på marknaden. Vi har varit verksamma sedan år 1975 och vår vision är att skapa måttanpassade uterum för livskvalité, i kontakt med naturen.'), 'https://www.expoduluterum.se', 'assets/images/exhibitors/nordbygg-2026-expodul-uterum.jpg'),
  ('nordbygg-2026-exhibitor-136062', 'nordbygg-2026', 'Exsitec AB', 'C01:10', jsonb_build_object('en', 'Exsitec digitalises construction, service and contracting companies with systems that get the job done. As the Nordic region''s fastest-growing IT consultancy, we deliver solutions that make a real difference — from the office to the field.

www.exsitec.se/nordbygg-2026
https://www.exsitec.se/bransch/bygg', 'sv', 'Exsitec digitaliserar bygg-, service- och entreprenadföretag med system som gör jobbet. Som Nordens snabbast växande IT-konsultbolag levererar vi lösningar som skapar verklig skillnad – från kontoret till fältet.

www.exsitec.se/nordbygg-2026
https://www.exsitec.se/bransch/bygg'), 'https://www.exsitec.se', 'assets/images/exhibitors/nordbygg-2026-exsitec-ab.jpg'),
  ('nordbygg-2026-exhibitor-133967', 'nordbygg-2026', 'Ezze AB', 'A05:02', null, 'https://www.ezze.se', null),
  ('nordbygg-2026-exhibitor-134751', 'nordbygg-2026', 'F Engel K/S', 'B04:11', null, 'https://www.f-engel.com', null),
  ('nordbygg-2026-exhibitor-133960', 'nordbygg-2026', 'Faluplast', 'A04:14', jsonb_build_object('en', 'Faluplast är en ledande tillverkare av VVS-produkter i plast, med fokus på innovation, kvalitet och hållbarhet. Vi konstruerar, tillverkar och levererar smarta lösningar som underlättar och effektiviserar rörinstallatörens arbete. Våra produkter kombinerar hög funktionalitet, stilren design och hållbarhet – alltid med installatören i fokus.

Vi är stolta över att ha full kontroll på hela processen, från idé och produktutveckling till tillverkning och leverans. Med vår produktion i Falun säkerställer vi hög kvalitet, snabba leveranser och en stark miljöprofil.', 'sv', 'Faluplast är en ledande tillverkare av VVS-produkter i plast, med fokus på innovation, kvalitet och hållbarhet. Vi konstruerar, tillverkar och levererar smarta lösningar som underlättar och effektiviserar rörinstallatörens arbete. Våra produkter kombinerar hög funktionalitet, stilren design och hållbarhet – alltid med installatören i fokus.

Vi är stolta över att ha full kontroll på hela processen, från idé och produktutveckling till tillverkning och leverans. Med vår produktion i Falun säkerställer vi hög kvalitet, snabba leveranser och en stark miljöprofil.'), 'https://www.faluplast.se', 'assets/images/exhibitors/nordbygg-2026-faluplast.jpg'),
  ('nordbygg-2026-exhibitor-138848', 'nordbygg-2026', 'Fasadgruppen Norden AB', 'C15:54', jsonb_build_object('en', 'Våra tjänster

Vi erbjuder smarta, vackra och energieffektiva tjänster på fastighetens utsida, såsom fasader, fönster, balkonger och tak, till kunder som kräver kvalitet, kompetens och erfarenhet.

Vårt arbetsområde är hela Norden och vi är verksamma via lokala dotterbolag med expertkunskap inom respektive kategori.', 'sv', 'Våra tjänster

Vi erbjuder smarta, vackra och energieffektiva tjänster på fastighetens utsida, såsom fasader, fönster, balkonger och tak, till kunder som kräver kvalitet, kompetens och erfarenhet.

Vårt arbetsområde är hela Norden och vi är verksamma via lokala dotterbolag med expertkunskap inom respektive kategori.'), 'https://www.fasadgruppen.se', 'assets/images/exhibitors/nordbygg-2026-fasadgruppen-norden-ab.jpg'),
  ('nordbygg-2026-exhibitor-139054', 'nordbygg-2026', 'Fastdev', 'AG:57', jsonb_build_object('en', 'Fastdev is a Stockholm-based software development and IT consulting company helping organizations accelerate digital transformation. We specialize in custom software development, scalable digital platforms, and dedicated development teams. By combining strong technical expertise with a collaborative approach, Fastdev delivers reliable, user-focused solutions that help businesses innovate faster, streamline operations, and bring new digital products to market.', 'sv', 'Fastdev is a Stockholm-based software development and IT consulting company helping organizations accelerate digital transformation. We specialize in custom software development, scalable digital platforms, and dedicated development teams. By combining strong technical expertise with a collaborative approach, Fastdev delivers reliable, user-focused solutions that help businesses innovate faster, streamline operations, and bring new digital products to market.'), 'https://www.fastdev.com', 'assets/images/exhibitors/nordbygg-2026-fastdev.jpg'),
  ('nordbygg-2026-exhibitor-139606', 'nordbygg-2026', 'Fein', 'B01:31 (+1)', jsonb_build_object('en', 'FEIN är ett tyskt premiumvarumärke med över 150 års erfarenhet av att utveckla robusta elverktyg för proffs. Vi uppfann den första elektriska handborrmaskinen redan 1895 – ett genombrott som lade grunden för dagens moderna elverktyg.

FEIN är också skaparen av det oscillerande multiverktyget, ursprungligen utvecklat 1967 och idag känt bland hantverkare världen över som Multimaster – ett mångsidigt verktyg för allt från sågning och slipning till precisionsarbeten i trånga utrymmen.

Vi erbjuder lösningar för bygg, renovering, metallbearbetning och montage – verktyg du kan lita på varje dag.', 'sv', 'FEIN är ett tyskt premiumvarumärke med över 150 års erfarenhet av att utveckla robusta elverktyg för proffs. Vi uppfann den första elektriska handborrmaskinen redan 1895 – ett genombrott som lade grunden för dagens moderna elverktyg.

FEIN är också skaparen av det oscillerande multiverktyget, ursprungligen utvecklat 1967 och idag känt bland hantverkare världen över som Multimaster – ett mångsidigt verktyg för allt från sågning och slipning till precisionsarbeten i trånga utrymmen.

Vi erbjuder lösningar för bygg, renovering, metallbearbetning och montage – verktyg du kan lita på varje dag.'), 'https://www.fein.se', 'assets/images/exhibitors/nordbygg-2026-fein.jpg'),
  ('nordbygg-2026-exhibitor-136787', 'nordbygg-2026', 'Fellowmind', 'C01:11', jsonb_build_object('en', 'Fellowmind is a European leader in digital transformation. By combining deep industry knowledge, technology expertise, and personal guidance we enable our customers to digitize what makes sense and use human skills where it matters most. We offer service for the entire business platform – from ERP, cloud infrastructure, data analytics, to CRM, intranet, and Digital Employee Experience and infuse AI in all our solutions. With the continuous release of new Microsoft AI Solutions, we can further accelerate on this promise.', 'sv', 'Fellowmind is a European leader in digital transformation. By combining deep industry knowledge, technology expertise, and personal guidance we enable our customers to digitize what makes sense and use human skills where it matters most. We offer service for the entire business platform – from ERP, cloud infrastructure, data analytics, to CRM, intranet, and Digital Employee Experience and infuse AI in all our solutions. With the continuous release of new Microsoft AI Solutions, we can further accelerate on this promise.'), 'https://www.fellowmind.com/sv-se', 'assets/images/exhibitors/nordbygg-2026-fellowmind.jpg'),
  ('nordbygg-2026-exhibitor-139930', 'nordbygg-2026', 'Ferroloq OÜ', 'C03:51', jsonb_build_object('en', 'We know how projects really work.

At Ferroloq, we manufacture steel profile doors — but more importantly, we support the people behind the projects.

Our main partners are façade companies and installation teams who deal with real-life challenges every day:

- last-minute changes
- tight deadlines
- details that don’t quite match on site

We try to be the kind of partner we would want ourselves:

- reliable in quality — so you don’t have to double-check everything;
- flexible in approach — because no project goes exactly as planned;
- strong in engineering — so problems get solved, not passed on;

Most of our work is in Scandinavia, where expectations are high — and we’ve learned to match that with clear communication and accountability.

In the end, it’s simple:
if your job is easier because of us, we’ve done our job right.', 'sv', 'We know how projects really work.

At Ferroloq, we manufacture steel profile doors — but more importantly, we support the people behind the projects.

Our main partners are façade companies and installation teams who deal with real-life challenges every day:

- last-minute changes
- tight deadlines
- details that don’t quite match on site

We try to be the kind of partner we would want ourselves:

- reliable in quality — so you don’t have to double-check everything;
- flexible in approach — because no project goes exactly as planned;
- strong in engineering — so problems get solved, not passed on;

Most of our work is in Scandinavia, where expectations are high — and we’ve learned to match that with clear communication and accountability.

In the end, it’s simple:
if your job is easier because of us, we’ve done our job right.'), 'https://www.linkedin.com/company/ferroloq/?originalSubdomain=ee', 'assets/images/exhibitors/nordbygg-2026-ferroloq-ou.jpg'),
  ('nordbygg-2026-exhibitor-139782', 'nordbygg-2026', 'Ferumeta', 'C19:41', null, 'https://www.ferumeta.lt', null),
  ('nordbygg-2026-exhibitor-133968', 'nordbygg-2026', 'Fibo AB', 'C07:21', jsonb_build_object('en', 'I över 70 år har Fibo utvecklat väggsystem för våtrum och andra miljöer med höga krav. Företaget grundades 1952 i Lyngdal i Norge, där produktionen till en början var inriktad på skeppsbyggnad. Med tiden utvecklades detta till det Fibo är känt för i dag: ett komplett väggsystem som ger 100 % vattentäta väggar, tål tuff användning, är enkla att rengöra och kräver minimalt underhåll.

Redan från start har fokus legat på hållbarhet, funktion och enkel installation. Det som började som enkla paneler är i dag ett komplett väggsystem som används i allt från privata bostäder till skolor, sjukhus och andra kommersiella byggnader.

Med över en miljon installationer i Skandinavien, Europa, Nordamerika och Australien har Fibo byggt upp en gedigen erfarenhet av hur väggsystem fungerar i praktiken.

Alla Fibos väggskivor tillverkas i Lyngdal, Norge. Här utvecklas och förbättras lösningarna kontinuerligt. Med produktion i egen fabrik har vi full kontroll över material, processer och kvalitet. Samtidigt arbetar vi systematiskt för att minska avfall och miljöpåverkan.', 'sv', 'I över 70 år har Fibo utvecklat väggsystem för våtrum och andra miljöer med höga krav. Företaget grundades 1952 i Lyngdal i Norge, där produktionen till en början var inriktad på skeppsbyggnad. Med tiden utvecklades detta till det Fibo är känt för i dag: ett komplett väggsystem som ger 100 % vattentäta väggar, tål tuff användning, är enkla att rengöra och kräver minimalt underhåll.

Redan från start har fokus legat på hållbarhet, funktion och enkel installation. Det som började som enkla paneler är i dag ett komplett väggsystem som används i allt från privata bostäder till skolor, sjukhus och andra kommersiella byggnader.

Med över en miljon installationer i Skandinavien, Europa, Nordamerika och Australien har Fibo byggt upp en gedigen erfarenhet av hur väggsystem fungerar i praktiken.

Alla Fibos väggskivor tillverkas i Lyngdal, Norge. Här utvecklas och förbättras lösningarna kontinuerligt. Med produktion i egen fabrik har vi full kontroll över material, processer och kvalitet. Samtidigt arbetar vi systematiskt för att minska avfall och miljöpåverkan.'), 'https://www.fibo.se', 'assets/images/exhibitors/nordbygg-2026-fibo-ab.jpg'),
  ('nordbygg-2026-exhibitor-137352', 'nordbygg-2026', 'Fidelix / Larmia / Lansen', 'A16:12', null, 'https://www.fidelix.se', 'assets/images/exhibitors/nordbygg-2026-fidelix-larmia-lansen.jpg'),
  ('nordbygg-2026-exhibitor-136975', 'nordbygg-2026', 'Fieldly AB', 'C01:20', jsonb_build_object('en', 'Fieldly är ett affärssystem för byggbranschen som hjälper dig få koll på hela projektet, från första jobbet till fakturan är betald.

Vi har byggt Fieldly för verkligheten ute på bygget. Det ska vara enkelt att planera, rapportera tid och material, följa upp ekonomi och ha allt samlat på ett ställe - utan krångel. Resultatet? Bättre överblick, smidigare arbetsdagar och färre saker som faller mellan stolarna.

Kort sagt: mindre administration, mer gjort och du missar inga timmar eller kostnader. Kom förbi vår monter så visar vi hur det funkar i praktiken.', 'sv', 'Fieldly är ett affärssystem för byggbranschen som hjälper dig få koll på hela projektet, från första jobbet till fakturan är betald.

Vi har byggt Fieldly för verkligheten ute på bygget. Det ska vara enkelt att planera, rapportera tid och material, följa upp ekonomi och ha allt samlat på ett ställe - utan krångel. Resultatet? Bättre överblick, smidigare arbetsdagar och färre saker som faller mellan stolarna.

Kort sagt: mindre administration, mer gjort och du missar inga timmar eller kostnader. Kom förbi vår monter så visar vi hur det funkar i praktiken.'), 'https://www.fieldly.com', 'assets/images/exhibitors/nordbygg-2026-fieldly-ab.jpg'),
  ('nordbygg-2026-exhibitor-134478', 'nordbygg-2026', 'FILA Nordic AB', 'B01:51', null, 'https://www.fila.it/se/en', null),
  ('nordbygg-2026-exhibitor-138220', 'nordbygg-2026', 'Filterteknik Sverige AB', 'A21:26', jsonb_build_object('en', 'Filterteknik tar nästa steg – in på ventilationsmarknaden

Efter många år som Nordens största oberoende filterleverantör breddar vi nu vårt erbjudande och går in på ventilationsmarknaden.
Med ett större sortiment och mer kompletta lösningar fortsätter vi förenkla våra kunders vardag genom kunskap, kvalitet och effektiva lösningar – alltid med samma trygghet och värme som kännetecknar Filterteknik.

Kom och besök oss i monter A21:26', 'sv', 'Filterteknik tar nästa steg – in på ventilationsmarknaden

Efter många år som Nordens största oberoende filterleverantör breddar vi nu vårt erbjudande och går in på ventilationsmarknaden.
Med ett större sortiment och mer kompletta lösningar fortsätter vi förenkla våra kunders vardag genom kunskap, kvalitet och effektiva lösningar – alltid med samma trygghet och värme som kännetecknar Filterteknik.

Kom och besök oss i monter A21:26'), 'https://filterteknik.se', 'assets/images/exhibitors/nordbygg-2026-filterteknik-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-134551', 'nordbygg-2026', 'Filtrena AB', 'A07:02', null, 'https://www.filtrena.se', null),
  ('nordbygg-2026-exhibitor-134002', 'nordbygg-2026', 'Finfo', 'C01:02', jsonb_build_object('en', 'Finfo är Sveriges främsta leverantör av produkt- och artikelinformation för byggsektorn, specialiserad på att skapa och leverera data som driver effektivare och mer hållbara byggprojekt. Vårt mål är att förenkla och förbättra informationsflödet mellan leverantörer, grossister och entreprenörer genom att erbjuda strukturerad, kvalitetssäkrad och realtidsuppdaterad produktinformation. Detta möjliggör smidigare processer och starkare samarbeten i hela byggkedjan.

Med Finfos lösningar får företag tillgång till pålitlig och standardiserad information som uppfyller byggbranschens krav och underlättar för företag att göra informerade produktval och säkerställa korrekta materialanvändningar. Vår plattform stödjer företagets behov av att effektivisera inköp, logistik och kundkommunikation, vilket sparar både tid och resurser och leder till högre kvalitet i varje led.', 'sv', 'Finfo är Sveriges främsta leverantör av produkt- och artikelinformation för byggsektorn, specialiserad på att skapa och leverera data som driver effektivare och mer hållbara byggprojekt. Vårt mål är att förenkla och förbättra informationsflödet mellan leverantörer, grossister och entreprenörer genom att erbjuda strukturerad, kvalitetssäkrad och realtidsuppdaterad produktinformation. Detta möjliggör smidigare processer och starkare samarbeten i hela byggkedjan.

Med Finfos lösningar får företag tillgång till pålitlig och standardiserad information som uppfyller byggbranschens krav och underlättar för företag att göra informerade produktval och säkerställa korrekta materialanvändningar. Vår plattform stödjer företagets behov av att effektivisera inköp, logistik och kundkommunikation, vilket sparar både tid och resurser och leder till högre kvalitet i varje led.'), 'https://www.finfo.se', 'assets/images/exhibitors/nordbygg-2026-finfo.jpg'),
  ('nordbygg-2026-exhibitor-138847', 'nordbygg-2026', 'FireSeal AB', 'B10:30', jsonb_build_object('en', 'Företaget grundades för drygt 40 år sedan för att utföra ett uppdrag från den svenska staten – att brandtäta de svenska kärnkraftverken. Med avstamp i denna pionjärinsats har FireSeal under åren utvecklat en framgångsrik verksamhet inom två sektorer: marin- och offshoresektorn i Asien och USA, samt byggsektorn i främst Sverige och Norge, där FireSeal är marknadsledande inom mjuka brandtätningslösningar.', 'sv', 'Företaget grundades för drygt 40 år sedan för att utföra ett uppdrag från den svenska staten – att brandtäta de svenska kärnkraftverken. Med avstamp i denna pionjärinsats har FireSeal under åren utvecklat en framgångsrik verksamhet inom två sektorer: marin- och offshoresektorn i Asien och USA, samt byggsektorn i främst Sverige och Norge, där FireSeal är marknadsledande inom mjuka brandtätningslösningar.'), 'https://www.fireseal.se', 'assets/images/exhibitors/nordbygg-2026-fireseal-ab.jpg'),
  ('nordbygg-2026-exhibitor-136108', 'nordbygg-2026', 'fischer Sverige AB', 'B02:40', null, 'https://www.fischersverige.se', 'assets/images/exhibitors/nordbygg-2026-fischer-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-139429', 'nordbygg-2026', 'FJORDD | AQUASTONE', 'A11:15', jsonb_build_object('en', 'AQUASTONE® is a brand founded by enthusiasts of creating unique things. Our products were created by experts in the bathroom industry.
We are a manufacturer of bathtubs, washbasins and shower trays.
We produce them from the AQUASTONE® stone composite that we have developed. They are created according to customer specifications or based on a design prepared by our specialists. We operate in the B2B sector, offering partners to make models under our own brand. Our innovative approach means support not only at the design or production stage, but also comprehensive assistance in launching the private label on the market.

MISSION

Our mission is to support business partners in gaining competitive edge.

VISION

We provide innovative bathroom products of the highest quality and exceptional design,
ensuring they turn your business into a successful venture.

VALUES

In our operations, we place emphasis on reliability, integrity and timeliness. We strongly
believe that these values make the foundation of a long-lasting business relationship.', 'sv', 'AQUASTONE® is a brand founded by enthusiasts of creating unique things. Our products were created by experts in the bathroom industry.
We are a manufacturer of bathtubs, washbasins and shower trays.
We produce them from the AQUASTONE® stone composite that we have developed. They are created according to customer specifications or based on a design prepared by our specialists. We operate in the B2B sector, offering partners to make models under our own brand. Our innovative approach means support not only at the design or production stage, but also comprehensive assistance in launching the private label on the market.

MISSION

Our mission is to support business partners in gaining competitive edge.

VISION

We provide innovative bathroom products of the highest quality and exceptional design,
ensuring they turn your business into a successful venture.

VALUES

In our operations, we place emphasis on reliability, integrity and timeliness. We strongly
believe that these values make the foundation of a long-lasting business relationship.'), 'https://www.aquastone.eu', 'assets/images/exhibitors/nordbygg-2026-fjordd-aquastone.jpg'),
  ('nordbygg-2026-exhibitor-138592', 'nordbygg-2026', 'FLA Material AB', 'C09:22', null, 'https://flamaterial.com', 'assets/images/exhibitors/nordbygg-2026-fla-material-ab.jpg'),
  ('nordbygg-2026-exhibitor-134440', 'nordbygg-2026', 'Flex Scandinavia AB', 'B02:11', jsonb_build_object('en', 'Flex Scandinavia AB är distributör av maskiner och tillbehör på den svenska hantverkar- och park & trädgårdsmarknaden från våra varumärken FLEX Power Tools och EGO Power+. Vi är sedan 240601 en del av CHERVON Group och vår kundbas domineras av återförsäljare inom måleri, industri, bygg, bilrekond, park & trädgård samt uthyrningsbolag i Sverige
Vårt huvudkontor, serviceverkstad och lager ligger i Karlstad.
Vi har sedan slutet av 1940-talet varit generalagent i Sverige för FLEX Power Tools®, ett varumärke mest känt som innovatören av vinkelslipen på 50-talet samt den långhalsade slipmaskinen Giraffen® som sattes på marknaden i slutet av 90-talet.
Sedan 2014 har vi även i portföljen urstarka 56-volts batterimaskiner för professionell park- och trädgårdsskötsel från EGO Power+®.
Som tillbehör till FLEX-maskinerna har vi vårt eget varumärke FLEXXTRA® för att ge återförsäljare och slutkunder bästa möjliga sammanlagda kundvärde för sin maskin. Vi väljer högsta möjliga kvalitet på våra tillbehör och omfånget riktar sig mot användare inom slipning, polering, kapning & fog fräsning, håltagning och borrning samt blandning av bruk.

Vår kundbas domineras av återförsäljare inom Automotve, bil/båtrekond, måleri, industri, bygg, park&trädgård samt uthyrningsbolag i Sverige.

Är du som återförsäljare intresserad av att jobba med oss, tveka inte att kontakta oss.

Vi är certifierade enligt ISO9001 & ISO14001 och har största fokus på att du som kund skall bli helnöjd.

www.flex-tools.se

wwww.egopowerplus.se

www.flexscandinavia.se', 'sv', 'Flex Scandinavia AB är distributör av maskiner och tillbehör på den svenska hantverkar- och park & trädgårdsmarknaden från våra varumärken FLEX Power Tools och EGO Power+. Vi är sedan 240601 en del av CHERVON Group och vår kundbas domineras av återförsäljare inom måleri, industri, bygg, bilrekond, park & trädgård samt uthyrningsbolag i Sverige
Vårt huvudkontor, serviceverkstad och lager ligger i Karlstad.
Vi har sedan slutet av 1940-talet varit generalagent i Sverige för FLEX Power Tools®, ett varumärke mest känt som innovatören av vinkelslipen på 50-talet samt den långhalsade slipmaskinen Giraffen® som sattes på marknaden i slutet av 90-talet.
Sedan 2014 har vi även i portföljen urstarka 56-volts batterimaskiner för professionell park- och trädgårdsskötsel från EGO Power+®.
Som tillbehör till FLEX-maskinerna har vi vårt eget varumärke FLEXXTRA® för att ge återförsäljare och slutkunder bästa möjliga sammanlagda kundvärde för sin maskin. Vi väljer högsta möjliga kvalitet på våra tillbehör och omfånget riktar sig mot användare inom slipning, polering, kapning & fog fräsning, håltagning och borrning samt blandning av bruk.

Vår kundbas domineras av återförsäljare inom Automotve, bil/båtrekond, måleri, industri, bygg, park&trädgård samt uthyrningsbolag i Sverige.

Är du som återförsäljare intresserad av att jobba med oss, tveka inte att kontakta oss.

Vi är certifierade enligt ISO9001 & ISO14001 och har största fokus på att du som kund skall bli helnöjd.

www.flex-tools.se

wwww.egopowerplus.se

www.flexscandinavia.se'), 'https://www.flexscandinavia.se', 'assets/images/exhibitors/nordbygg-2026-flex-scandinavia-ab.jpg'),
  ('nordbygg-2026-exhibitor-138296', 'nordbygg-2026', 'Flexiheater', 'B10:01', null, 'https://www.aselemek.com', null),
  ('nordbygg-2026-exhibitor-138763', 'nordbygg-2026', 'Flexit Kuben AB', 'A18:30', null, 'https://www.kubenventilation.se', null),
  ('nordbygg-2026-exhibitor-134757', 'nordbygg-2026', 'Flexit Sverige AB', 'A15:18', jsonb_build_object('en', 'Flexit är en av Nordens ledande leverantörer av inomhusklimatlösningar.
Vår kompetens och våra lösningar är speciellt utvecklade för att förbättra inomhusklimatet i bostäder, i ett krävande nordiskt klimat.

Välkomna till vår monter A15:18 för att se våra produkter för ett bättre inneklimat.

Vi visar vår nya rotorteknologi med skyhög prestanda; patenterade Stage Wheel som ger upp till 10 procentenheter bättre värmeåtervinning i ventilationsaggregat för bostäder och fler kommande nyheter.', 'sv', 'Flexit är en av Nordens ledande leverantörer av inomhusklimatlösningar.
Vår kompetens och våra lösningar är speciellt utvecklade för att förbättra inomhusklimatet i bostäder, i ett krävande nordiskt klimat.

Välkomna till vår monter A15:18 för att se våra produkter för ett bättre inneklimat.

Vi visar vår nya rotorteknologi med skyhög prestanda; patenterade Stage Wheel som ger upp till 10 procentenheter bättre värmeåtervinning i ventilationsaggregat för bostäder och fler kommande nyheter.'), 'https://www.flexit.se', 'assets/images/exhibitors/nordbygg-2026-flexit-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-138611', 'nordbygg-2026', 'Flobar AB', 'A09:33', jsonb_build_object('en', 'Flobar - Skyddar fastigheter och samhällen mot översvämningar

Vi är skandinavisk distributör av världsledande produkter för översvämningsskydd och miljösäkerhet. Vårt fokus ligger på att skydda fastigheter, infrastruktur och miljön från skador orsakade av vatten oavsett om det handlar om stigande havsnivåer, kraftiga regn eller kontaminerat släckvatten.

- Översvämningsbarriärer och mobila skyddssystem

- Lösningar för industri, kommun och privat sektor

- Skydd mot utsläpp av släckvatten vid brand

- Förvaringsskåp för tex kemikalier, batterier mm.

Vi kombinerar kvalitativa produkter med lokal expertis och erbjuder helhetslösningar, från rådgivning och försäljning till support och logistik i hela Skandinavien.

Klimatförändringar ökar riskerna – vi hjälper dig att vara förberedd.

Kontakta oss för att diskutera hur vi kan skydda din fastighet eller verksamhet.

                            info@flobar.se / www.flobar.se', 'sv', 'Flobar - Skyddar fastigheter och samhällen mot översvämningar

Vi är skandinavisk distributör av världsledande produkter för översvämningsskydd och miljösäkerhet. Vårt fokus ligger på att skydda fastigheter, infrastruktur och miljön från skador orsakade av vatten oavsett om det handlar om stigande havsnivåer, kraftiga regn eller kontaminerat släckvatten.

- Översvämningsbarriärer och mobila skyddssystem

- Lösningar för industri, kommun och privat sektor

- Skydd mot utsläpp av släckvatten vid brand

- Förvaringsskåp för tex kemikalier, batterier mm.

Vi kombinerar kvalitativa produkter med lokal expertis och erbjuder helhetslösningar, från rådgivning och försäljning till support och logistik i hela Skandinavien.

Klimatförändringar ökar riskerna – vi hjälper dig att vara förberedd.

Kontakta oss för att diskutera hur vi kan skydda din fastighet eller verksamhet.

                            info@flobar.se / www.flobar.se'), 'https://flobar.se', 'assets/images/exhibitors/nordbygg-2026-flobar-ab.jpg'),
  ('nordbygg-2026-exhibitor-137981', 'nordbygg-2026', 'Floby Durk AB', 'C15:51', jsonb_build_object('en', 'Välkommen till C15:51 och möt oss från Floby Durk!

Här visar vi vår raka trappa med stora möjligheter till anpassning.

Floby Durk tillverkar olika sorters trappor, räcken, ramper och durk till allt från industrier och offentliga miljöer till kontor och bostäder.

Svenskt, innovativt och hållbart – i montern möter du, förutom oss, även några av de andra företagen som ingår i Welandkoncernen. Varmt välkommen!', 'sv', 'Välkommen till C15:51 och möt oss från Floby Durk!

Här visar vi vår raka trappa med stora möjligheter till anpassning.

Floby Durk tillverkar olika sorters trappor, räcken, ramper och durk till allt från industrier och offentliga miljöer till kontor och bostäder.

Svenskt, innovativt och hållbart – i montern möter du, förutom oss, även några av de andra företagen som ingår i Welandkoncernen. Varmt välkommen!'), 'https://flobydurk.se', 'assets/images/exhibitors/nordbygg-2026-floby-durk-ab.jpg'),
  ('nordbygg-2026-exhibitor-139459', 'nordbygg-2026', 'Florian Eichinger GmbH', 'C02:51', jsonb_build_object('en', 'Florian Eichinger GmbH is a family-run German manufacturer of robust construction and industrial equipment, producing concrete skips, muck skips, hoisting gear, containers and site accessories for global markets. With over 100 years of innovation, it leads in quality and reliability.', 'sv', 'Florian Eichinger GmbH is a family-run German manufacturer of robust construction and industrial equipment, producing concrete skips, muck skips, hoisting gear, containers and site accessories for global markets. With over 100 years of innovation, it leads in quality and reliability.'), 'https://eichinger.de/de', 'assets/images/exhibitors/nordbygg-2026-florian-eichinger-gmbh.jpg'),
  ('nordbygg-2026-exhibitor-139316', 'nordbygg-2026', 'Fluetec AB', 'A21:15', jsonb_build_object('en', 'Vi erbjuder en kostnadseffektiv och hållbar lösning för att täta ventilationskanaler utan rivning. Som exklusiv distributör av TKR-systemet i Sverige och med Fluetec som utförande specialist levererar vi biooljebaserad invändig tätning som återställer tryck, funktion och energieffektivitet i befintliga system.

Resultatet är godkänd OVK, sänkta driftkostnader och upp till 75 % lägre kostnad jämfört med kanalbyte.', 'sv', 'Vi erbjuder en kostnadseffektiv och hållbar lösning för att täta ventilationskanaler utan rivning. Som exklusiv distributör av TKR-systemet i Sverige och med Fluetec som utförande specialist levererar vi biooljebaserad invändig tätning som återställer tryck, funktion och energieffektivitet i befintliga system.

Resultatet är godkänd OVK, sänkta driftkostnader och upp till 75 % lägre kostnad jämfört med kanalbyte.'), 'https://btyb.se', 'assets/images/exhibitors/nordbygg-2026-fluetec-ab.jpg'),
  ('nordbygg-2026-exhibitor-140093', 'nordbygg-2026', 'FläktGroup', 'A17:22', jsonb_build_object('en', 'FläktGroup, som är en del av Samsung, är en ledare inom ventilation och inomhusklimat. Vi levererar innovativa och energieffektiva produkter och lösningar av högsta klass, samtidigt som vi minskar kundernas koldioxidavtryck. FläktGroups ledande varumärken har satt den tekniska standarden i över 100 år och uppfyller även de mest krävande kundbehoven. FläktGroup har globala verksamheter med produktionsanläggningar i Europa, Asien och USA.', 'sv', 'FläktGroup, som är en del av Samsung, är en ledare inom ventilation och inomhusklimat. Vi levererar innovativa och energieffektiva produkter och lösningar av högsta klass, samtidigt som vi minskar kundernas koldioxidavtryck. FläktGroups ledande varumärken har satt den tekniska standarden i över 100 år och uppfyller även de mest krävande kundbehoven. FläktGroup har globala verksamheter med produktionsanläggningar i Europa, Asien och USA.'), 'https://info.se@flaktgroup.com', 'assets/images/exhibitors/nordbygg-2026-flaktgroup.jpg'),
  ('nordbygg-2026-exhibitor-135977', 'nordbygg-2026', 'FM Mattsson Group AB', 'A03:10', jsonb_build_object('en', 'I en tid där hållbarhet, pålitlighet och närhet blir allt viktigare står FM Mattsson Group stadigt – med svensk förankring, lång erfarenhet och blicken riktad framåt. Med tekniska innovationer, design och smarta funktioner är vi din one stop shop för framtidens vattenlösningar.

Från stora sjukhus till exklusiva designhotell. Ja, alla som vill ha en riktigt snygg och hållbar kran eller dusch.

På Nordbygg presenterar vi det senaste från Mora Armatur, FM Mattsson och Damixa: produkter och tjänster som sparar vatten och energi, skapar sköna upplevelser och som håller över tid. I vår monter finns också våra experter på plats, redo att hjälpa dig att hitta rätt lösningar för just dina projekt.', 'sv', 'I en tid där hållbarhet, pålitlighet och närhet blir allt viktigare står FM Mattsson Group stadigt – med svensk förankring, lång erfarenhet och blicken riktad framåt. Med tekniska innovationer, design och smarta funktioner är vi din one stop shop för framtidens vattenlösningar.

Från stora sjukhus till exklusiva designhotell. Ja, alla som vill ha en riktigt snygg och hållbar kran eller dusch.

På Nordbygg presenterar vi det senaste från Mora Armatur, FM Mattsson och Damixa: produkter och tjänster som sparar vatten och energi, skapar sköna upplevelser och som håller över tid. I vår monter finns också våra experter på plats, redo att hjälpa dig att hitta rätt lösningar för just dina projekt.'), 'https://www.fmmattssongroup.com', 'assets/images/exhibitors/nordbygg-2026-fm-mattsson-group-ab.jpg'),
  ('nordbygg-2026-exhibitor-137909', 'nordbygg-2026', 'FOAMGLAS Nordic AB', 'C09:71', null, 'https://www.foamglas.se', 'assets/images/exhibitors/nordbygg-2026-foamglas-nordic-ab.jpg'),
  ('nordbygg-2026-exhibitor-137804', 'nordbygg-2026', 'Forenom Hotels & Apartments', 'AG:27', jsonb_build_object('en', 'Forenom är marknadsledande leverantör inom företagsboende och projektbostäder. Vi samarbetar med flera av de större projekten i Norden inom exempelvis Datacenter, Infrastrukturprojekt sam Bostadsbyggande. Vi hjälper er personal att sova gott och bo tryggt för att kunna prestera som bäst på arbetsplatsen eller projektet', 'sv', 'Forenom är marknadsledande leverantör inom företagsboende och projektbostäder. Vi samarbetar med flera av de större projekten i Norden inom exempelvis Datacenter, Infrastrukturprojekt sam Bostadsbyggande. Vi hjälper er personal att sova gott och bo tryggt för att kunna prestera som bäst på arbetsplatsen eller projektet'), 'https://www.forenom.com/sv', 'assets/images/exhibitors/nordbygg-2026-forenom-hotels-apartments.jpg'),
  ('nordbygg-2026-exhibitor-139200', 'nordbygg-2026', 'Forestia', 'C04:11', jsonb_build_object('en', 'Forestia är en tillverkare av spånskivor som levererar produkter till den skandinaviska och nordeuropeiska marknaden.

Forestia AS är en del av Byggma-koncernen och tillverkar totalt omkring 300.000 kubikmeter möbel-, interiör, bygg- och konstruktionsskivor varje år.

Ta del av de senaste nyheterna inom interiör- eller spånskivor i vår monter CO4:11 på Nordbygg.', 'sv', 'Forestia är en tillverkare av spånskivor som levererar produkter till den skandinaviska och nordeuropeiska marknaden.

Forestia AS är en del av Byggma-koncernen och tillverkar totalt omkring 300.000 kubikmeter möbel-, interiör, bygg- och konstruktionsskivor varje år.

Ta del av de senaste nyheterna inom interiör- eller spånskivor i vår monter CO4:11 på Nordbygg.'), 'https://www.forestia.se', 'assets/images/exhibitors/nordbygg-2026-forestia.jpg'),
  ('nordbygg-2026-exhibitor-139261', 'nordbygg-2026', 'Forsbergs Metallduk AB', 'C05:71', jsonb_build_object('en', 'Forsbergs Metallduk AB, grundades 1913 och är ett familjeföretag med sju anställda. Genom alla år av utveckling har vi vuxit till ett företag med medarbetare som har hög kompetens och stor erfarenhet när det gäller metallduk. Vi är kvalitets- och miljöcertifierade enligt ISO 9001:2008 och ISO 14001:2004.

Vi har specialiserat oss på att väva metallduk. Vår maskinpark består av 16 vävstolar i olika storlekar. Vävstolarna varierar från moderna datastyrda skyttelösa vävstolar, till vanliga skyttelmaskiner som väver med stadkant.', 'sv', 'Forsbergs Metallduk AB, grundades 1913 och är ett familjeföretag med sju anställda. Genom alla år av utveckling har vi vuxit till ett företag med medarbetare som har hög kompetens och stor erfarenhet när det gäller metallduk. Vi är kvalitets- och miljöcertifierade enligt ISO 9001:2008 och ISO 14001:2004.

Vi har specialiserat oss på att väva metallduk. Vår maskinpark består av 16 vävstolar i olika storlekar. Vävstolarna varierar från moderna datastyrda skyttelösa vävstolar, till vanliga skyttelmaskiner som väver med stadkant.'), 'https://www.forsbergsmetallduk.se / www.gnagarskydd.se', 'assets/images/exhibitors/nordbygg-2026-forsbergs-metallduk-ab.jpg'),
  ('nordbygg-2026-exhibitor-136246', 'nordbygg-2026', 'Forserum Safety Glass AB', 'C09:40', jsonb_build_object('en', 'Vi är en stor glasgrossist i Sverige som utvecklar och producerar produkter av förädlat planglas. Vi levererar glas till hela Norden. Forserum Safety Glass AB ligger i hjärtat av Småland med bra logistiska förbindelser, både genom vägtransport och järnväg. Detta gör att vi kan leverera skyddsglas lika snabbt och smidigt oavsett om det ska levereras till Ystad eller Haparanda. Som glasgrossist arbetar vi i hela spektrat av planglasförädling, från enstycksproduktion till långa serier. Skyddsglas, Säkerhetsglas, Brandglas och Isolerglas är några av de sorters skyddsglas vi arbetar med. Vi har skyddsglas som skyddar mot personskador, buller, beskjutning, tryckvågor, intrång och inbrott.', 'sv', 'Vi är en stor glasgrossist i Sverige som utvecklar och producerar produkter av förädlat planglas. Vi levererar glas till hela Norden. Forserum Safety Glass AB ligger i hjärtat av Småland med bra logistiska förbindelser, både genom vägtransport och järnväg. Detta gör att vi kan leverera skyddsglas lika snabbt och smidigt oavsett om det ska levereras till Ystad eller Haparanda. Som glasgrossist arbetar vi i hela spektrat av planglasförädling, från enstycksproduktion till långa serier. Skyddsglas, Säkerhetsglas, Brandglas och Isolerglas är några av de sorters skyddsglas vi arbetar med. Vi har skyddsglas som skyddar mot personskador, buller, beskjutning, tryckvågor, intrång och inbrott.'), 'https://www.fsglass.se', 'assets/images/exhibitors/nordbygg-2026-forserum-safety-glass-ab.jpg'),
  ('nordbygg-2026-exhibitor-137702', 'nordbygg-2026', 'Franke', 'A14:21', null, 'https://www.franke.se', 'assets/images/exhibitors/nordbygg-2026-franke.jpg'),
  ('nordbygg-2026-exhibitor-135507', 'nordbygg-2026', 'Frico AB', 'A12:13', jsonb_build_object('en', 'Sedan 1932 har Frico utvecklat och tillverkat högkvalitativa, energieffektiva produkter för ett bättre inomhusklimat. Som Europas ledande tillverkare av luftridåer, värmefläktar och värmestrålare skapar vi lösningar som stoppar energiförluster, minskar kostnader och förbättrar arbetsmiljön.

Våra produkter är utvecklade för offentliga byggnader, kommersiella lokaler, logistikcenter och industrimiljöer – även i de tuffaste förhållanden. Med snart hundra års erfarenhet arbetar Frico långsiktigt för en mer energieffektiv och grönare framtid.', 'sv', 'Sedan 1932 har Frico utvecklat och tillverkat högkvalitativa, energieffektiva produkter för ett bättre inomhusklimat. Som Europas ledande tillverkare av luftridåer, värmefläktar och värmestrålare skapar vi lösningar som stoppar energiförluster, minskar kostnader och förbättrar arbetsmiljön.

Våra produkter är utvecklade för offentliga byggnader, kommersiella lokaler, logistikcenter och industrimiljöer – även i de tuffaste förhållanden. Med snart hundra års erfarenhet arbetar Frico långsiktigt för en mer energieffektiv och grönare framtid.'), 'https://www.frico.net/en', 'assets/images/exhibitors/nordbygg-2026-frico-ab.jpg'),
  ('nordbygg-2026-exhibitor-139247', 'nordbygg-2026', 'FutureCalc', 'AG:48', null, 'https://futurecalc.ai', null),
  ('nordbygg-2026-exhibitor-137901', 'nordbygg-2026', 'Fönsterfabriken AB - Smarta fönster', 'C14:52', null, 'https://www.smartafonster.se', 'assets/images/exhibitors/nordbygg-2026-fonsterfabriken-ab-smarta-fonster.jpg'),
  ('nordbygg-2026-exhibitor-138445', 'nordbygg-2026', 'GAFT NORD AB', 'C15:56', jsonb_build_object('en', 'GAFT Nord AB är specialiserade på att skapa moderna och diskreta skyddsrumslösningar för både privatpersoner och företag.
Vi erbjuder helhetslösningar inom byggnation, modernisering och service av skyddsrum, panic rooms och andra skyddsanläggningar – alltid enligt MSB:s riktlinjer och internationella standarder.

Med lång erfarenhet inom bygg och säkerhet hanterar vi hela processen: från projektering och tillstånd till färdig installation.
Våra projekt kombinerar hållbara konstruktioner, avancerad teknik och fullständig diskretion – oavsett om det gäller ett nytt fristående skyddsrum, en anläggning under huset eller en integrerad lösning i befintlig byggnad.

På Nordbygg-mässan visar vi exempel på våra lösningar och berättar hur ett skyddsrum kan vara både en trygg och funktionell del av hemmet – exempelvis som vinkällare, hobbyrum, hemmabio eller relaxyta i fredstid.

Vi samarbetar med erfarna ingenjörer och partners i hela Europa, och erbjuder även service, inspektioner och anpassning av befintliga skyddsrum till dagens krav.
Besök oss på mässan och upptäck hur vi kan skapa lyx i trygghet – exklusiv säkerhet i ditt eget hem.', 'sv', 'GAFT Nord AB är specialiserade på att skapa moderna och diskreta skyddsrumslösningar för både privatpersoner och företag.
Vi erbjuder helhetslösningar inom byggnation, modernisering och service av skyddsrum, panic rooms och andra skyddsanläggningar – alltid enligt MSB:s riktlinjer och internationella standarder.

Med lång erfarenhet inom bygg och säkerhet hanterar vi hela processen: från projektering och tillstånd till färdig installation.
Våra projekt kombinerar hållbara konstruktioner, avancerad teknik och fullständig diskretion – oavsett om det gäller ett nytt fristående skyddsrum, en anläggning under huset eller en integrerad lösning i befintlig byggnad.

På Nordbygg-mässan visar vi exempel på våra lösningar och berättar hur ett skyddsrum kan vara både en trygg och funktionell del av hemmet – exempelvis som vinkällare, hobbyrum, hemmabio eller relaxyta i fredstid.

Vi samarbetar med erfarna ingenjörer och partners i hela Europa, och erbjuder även service, inspektioner och anpassning av befintliga skyddsrum till dagens krav.
Besök oss på mässan och upptäck hur vi kan skapa lyx i trygghet – exklusiv säkerhet i ditt eget hem.'), 'https://gaft.se', 'assets/images/exhibitors/nordbygg-2026-gaft-nord-ab.jpg'),
  ('nordbygg-2026-exhibitor-139100', 'nordbygg-2026', 'Garden Spot Int.', 'EÖ:25', jsonb_build_object('en', 'We are a Polish manufacturer of the Pixel Garden system for building vertical gardens, as well as turf grids - Garden Grid.', 'sv', 'We are a Polish manufacturer of the Pixel Garden system for building vertical gardens, as well as turf grids - Garden Grid.'), 'https://gardenspot.pl', 'assets/images/exhibitors/nordbygg-2026-garden-spot-int.jpg'),
  ('nordbygg-2026-exhibitor-137997', 'nordbygg-2026', 'Garoff Decor', 'C06:63', jsonb_build_object('en', 'Vi erbjuder exklusiva inredningsprodukter som mosaik av natursten och metall, köksbänkskivor och marmorväggpaneler som ger ditt hem en unik och härlig känsla. Vi har ocksä: Keramikplattor alla storlekar  , över 1300 modeller i butiken. Inomhus och utomhus.
Varmt Vällkomna till vår 3000m2 showroom i Vinsta/Stockholm', 'sv', 'Vi erbjuder exklusiva inredningsprodukter som mosaik av natursten och metall, köksbänkskivor och marmorväggpaneler som ger ditt hem en unik och härlig känsla. Vi har ocksä: Keramikplattor alla storlekar  , över 1300 modeller i butiken. Inomhus och utomhus.
Varmt Vällkomna till vår 3000m2 showroom i Vinsta/Stockholm'), 'https://www.garoff-decor.com', 'assets/images/exhibitors/nordbygg-2026-garoff-decor.jpg'),
  ('nordbygg-2026-exhibitor-136718', 'nordbygg-2026', 'Gatstensbolaget', 'C04:61G', jsonb_build_object('en', 'Tillverkning av natursten.

-Kantsten
-Smågatsten
-Storgatsten
-Murar', 'sv', 'Tillverkning av natursten.

-Kantsten
-Smågatsten
-Storgatsten
-Murar'), 'https://gatstensbolaget.se', 'assets/images/exhibitors/nordbygg-2026-gatstensbolaget.jpg'),
  ('nordbygg-2026-exhibitor-137872', 'nordbygg-2026', 'Gebwell Sverige AB', 'A11:22', jsonb_build_object('en', 'Gebwell är ett finländskt företag specialiserat på miljövänliga värme- och kylalösningar för fastigheter. Gebwell tillverkar fjärrvärmecentraler, värmepumpar och ackumulatortankar för fastigheter av alla storlekar. Produktionsanläggningarna finns i Finland och Polen. Gebwell Sverige AB marknadsför och säljer Gebwells produkter i Sverige.', 'sv', 'Gebwell är ett finländskt företag specialiserat på miljövänliga värme- och kylalösningar för fastigheter. Gebwell tillverkar fjärrvärmecentraler, värmepumpar och ackumulatortankar för fastigheter av alla storlekar. Produktionsanläggningarna finns i Finland och Polen. Gebwell Sverige AB marknadsför och säljer Gebwells produkter i Sverige.'), 'https://www.gebwell.se', 'assets/images/exhibitors/nordbygg-2026-gebwell-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-139445', 'nordbygg-2026', 'Genossenschafts-Werke für Solnhofener Platten GmbH', 'C02:51', null, 'https://genowe.de', null),
  ('nordbygg-2026-exhibitor-139895', 'nordbygg-2026', 'Geocon Mätteknik Stockholm AB', 'BG:21', null, 'https://www.geocon.se', 'assets/images/exhibitors/nordbygg-2026-geocon-matteknik-stockholm-ab.jpg'),
  ('nordbygg-2026-exhibitor-139084', 'nordbygg-2026', 'Geofix AB', 'B08:51', jsonb_build_object('en', 'Geofix AB – Lösningar för mätning, utsättning och verklighetsbaserad dokumentation

Geofix är en svensk specialistleverantör av professionella mät-, utsättnings- och digitala bygglösningar för bygg-, anläggnings- och mätbranschen. Vi arbetar nära entreprenörer, konsulter och projektorganisationer för att bidra till högre precision, effektivare arbetsflöden och bättre samverkan – från tidiga planeringsskeden till produktion och dokumentation.

På Nordbygg visar Geofix hur modern teknik kan stötta smartare och mer automatiserade arbetssätt på byggarbetsplatsen. Tillsammans med våra partners FARO, HP SitePrint och Rothbucher Systeme presenterar vi praktiska lösningar som redan idag används i skarpa projekt runt om i Sverige.

Våra fokusområden omfattar:

* Automatiserad utsättning och layout
* Verklighetsbaserad dokumentation och 3D-skanning
* Precision och kontroll i mätprocessen
* Digitala arbetsflöden som minskar fel, omarbete och manuellt arbete

HP SitePrint visar hur robotiserad utsättning kan förändra traditionell layout genom att skriva ut ritningar direkt på byggytan med hög noggrannhet och spårbarhet.

FARO presenterar avancerade lösningar för 3D-laserskanning som stödjer verifiering, relationshandlingar och digitala tvillingar – och ger bättre beslutsunderlag genom hela projektets livscykel.

Rothbucher Systeme visar precisionslösningar för infästning och mätkontroll som säkerställer stabila och tillförlitliga referenspunkter även i krävande miljöer.

Tillsammans vill vi visa hur innovation, samarbete och beprövad teknik kan bidra till mer effektiva, förutsägbara och välkoordinerade byggprojekt.

Välkommen att besöka oss på Nordbygg för live-demonstrationer, dialog kring verkliga projekt och inspiration kring hur dessa lösningar kan skapa värde i era projekt.', 'sv', 'Geofix AB – Lösningar för mätning, utsättning och verklighetsbaserad dokumentation

Geofix är en svensk specialistleverantör av professionella mät-, utsättnings- och digitala bygglösningar för bygg-, anläggnings- och mätbranschen. Vi arbetar nära entreprenörer, konsulter och projektorganisationer för att bidra till högre precision, effektivare arbetsflöden och bättre samverkan – från tidiga planeringsskeden till produktion och dokumentation.

På Nordbygg visar Geofix hur modern teknik kan stötta smartare och mer automatiserade arbetssätt på byggarbetsplatsen. Tillsammans med våra partners FARO, HP SitePrint och Rothbucher Systeme presenterar vi praktiska lösningar som redan idag används i skarpa projekt runt om i Sverige.

Våra fokusområden omfattar:

* Automatiserad utsättning och layout
* Verklighetsbaserad dokumentation och 3D-skanning
* Precision och kontroll i mätprocessen
* Digitala arbetsflöden som minskar fel, omarbete och manuellt arbete

HP SitePrint visar hur robotiserad utsättning kan förändra traditionell layout genom att skriva ut ritningar direkt på byggytan med hög noggrannhet och spårbarhet.

FARO presenterar avancerade lösningar för 3D-laserskanning som stödjer verifiering, relationshandlingar och digitala tvillingar – och ger bättre beslutsunderlag genom hela projektets livscykel.

Rothbucher Systeme visar precisionslösningar för infästning och mätkontroll som säkerställer stabila och tillförlitliga referenspunkter även i krävande miljöer.

Tillsammans vill vi visa hur innovation, samarbete och beprövad teknik kan bidra till mer effektiva, förutsägbara och välkoordinerade byggprojekt.

Välkommen att besöka oss på Nordbygg för live-demonstrationer, dialog kring verkliga projekt och inspiration kring hur dessa lösningar kan skapa värde i era projekt.'), 'https://www.geofix.se', 'assets/images/exhibitors/nordbygg-2026-geofix-ab.jpg'),
  ('nordbygg-2026-exhibitor-137746', 'nordbygg-2026', 'GF (Uponor)', 'A01:18', jsonb_build_object('en', 'När branschen samlas på Nordbygg 2026 i Stockholm den 21–24 april introducerar GF en rad nya innovationer i Sverige. Lösningar som visar hur byggnader kan bli mer energieffektiva, driftsäkra och hållbara över tid.

Byggsektorn står för en betydande del av energianvändningen i samhället, vilket gör effektiva systemlösningar till en central del av klimatomställningen. Samtidigt ställs högre krav på säker och hygienisk vattendistribution, inte minst i fastigheter där drift och underhåll behöver fungera utan avbrott.

Mot den bakgrunden utvecklas nu en ny generation lösningar som kombinerar energieffektivitet, driftsäkerhet och smartare systemintegration.

– Branschen efterfrågar lösningar som både förenklar installation och bidrar till lägre energianvändning över tid. Vår ambition är att leverera system som skapar verkligt värde i hela byggnadens livscykel, säger Robert Molund, vd för GF VVS i Sverige.

I vår vattenbar kan du ta en paus med plus i kanten. Så slå dig ner en stund, ta något i glaset och prata med oss om det vi kan bäst. Eller kom bara förbi för något svalkande.

Du är varmt välkommen till monter A01:18!', 'sv', 'När branschen samlas på Nordbygg 2026 i Stockholm den 21–24 april introducerar GF en rad nya innovationer i Sverige. Lösningar som visar hur byggnader kan bli mer energieffektiva, driftsäkra och hållbara över tid.

Byggsektorn står för en betydande del av energianvändningen i samhället, vilket gör effektiva systemlösningar till en central del av klimatomställningen. Samtidigt ställs högre krav på säker och hygienisk vattendistribution, inte minst i fastigheter där drift och underhåll behöver fungera utan avbrott.

Mot den bakgrunden utvecklas nu en ny generation lösningar som kombinerar energieffektivitet, driftsäkerhet och smartare systemintegration.

– Branschen efterfrågar lösningar som både förenklar installation och bidrar till lägre energianvändning över tid. Vår ambition är att leverera system som skapar verkligt värde i hela byggnadens livscykel, säger Robert Molund, vd för GF VVS i Sverige.

I vår vattenbar kan du ta en paus med plus i kanten. Så slå dig ner en stund, ta något i glaset och prata med oss om det vi kan bäst. Eller kom bara förbi för något svalkande.

Du är varmt välkommen till monter A01:18!'), 'https://www.uponor.com', 'assets/images/exhibitors/nordbygg-2026-gf-uponor.jpg'),
  ('nordbygg-2026-exhibitor-135934', 'nordbygg-2026', 'Glasbranschföreningen', 'C10:41 (+1)', jsonb_build_object('en', 'Glasbranschföreningen
– vi bjuder på kunskap och inspiration om möjligheterna med glas

När samhällsbyggnadsbranschen samlas på Nordbygg i april 2026 står glas i centrum. Glasbranschföreningen, bransch- och arbetsgivarorganisationen för Sveriges glas- och metallentreprenörer, bjuder in till inspirerande samtal, kostnadsfri rådgivning och prisutdelningar som lyfter framtidens glasarkitektur.

I föreningens monter C10:41 möter du experter, tar del av ett scenprogram med aktuella branschfrågor och får möjlighet att nätverka med kollegor från hela landet.

Detta händer i Glasbranschföreningens monter:
* Gratis glasrådgivning
Onsdag 22 april och torsdag 23 april erbjuder Glascentrums expert Fredrik Hall Johansson fri rådgivning – perfekt för dig som vill diskutera konkreta lösningar.

* Glasscenen – fyra temadagar
Ta del av föredrag om fönsterrenovering, skydd och säkerhet samt arkitektur. Under torsdagen fördjupar vi oss bland annat i gestaltningen av World of Volvo och Sjustjärnan samt möter vinnarna av Glaspriset och Glaspärlan.

* Hantverk live
Se skickliga yrkesproffs visa fönsterrenovering - ett komplext hantverk som omfattar många moment.

Höjdpunkter du inte vill missa:
23 april 09:30–11:00 – Föreningsmöte för medlemmar

23 april 12:30 – Arkitekturpriset i studenttävlingen Nya ögon på glas offentliggörs på Nordbygg Live-scenen

23 april 14:00 – Arkitekturpriserna Glaspriset och Glaspärlan delas ut på Nordbygg Live-scenen

23 april 15:30 – Mingel i montern för att fira vinnarna av glaspriserna

24 april – Kvinnlig nätverksfrukost följt av fortsatt nätverkande och lunch

Besök Glastorget i monter C11:41
På Glastorget träffar du de ledande aktörerna Arton:1 Projekt, Certo Software, Fasadglas, Orgadata, Ragn-Sells Recycling, Svenssons i Tenhult och Vidaflam.

Glas tar plats redan i entrén
I årets studenttävling Nya ögon på glas har framtidens arkitekter skapat Nordbygg Live – en uttrycksfull mötesplats byggd av återbrukat glas och återvunna aluminiumprofiler.
En bransch som ser ljust på framtiden
Trots ett utmanande omvärldsläge pekar mycket på en positiv utveckling för glas i Sverige. Nordbygg blir därför en viktig kraftsamling för att rusta branschen inför framtiden.

Hjärtligt välkommen att uppleva glasets möjligheter på Nordbygg 2026!', 'sv', 'Glasbranschföreningen
– vi bjuder på kunskap och inspiration om möjligheterna med glas

När samhällsbyggnadsbranschen samlas på Nordbygg i april 2026 står glas i centrum. Glasbranschföreningen, bransch- och arbetsgivarorganisationen för Sveriges glas- och metallentreprenörer, bjuder in till inspirerande samtal, kostnadsfri rådgivning och prisutdelningar som lyfter framtidens glasarkitektur.

I föreningens monter C10:41 möter du experter, tar del av ett scenprogram med aktuella branschfrågor och får möjlighet att nätverka med kollegor från hela landet.

Detta händer i Glasbranschföreningens monter:
* Gratis glasrådgivning
Onsdag 22 april och torsdag 23 april erbjuder Glascentrums expert Fredrik Hall Johansson fri rådgivning – perfekt för dig som vill diskutera konkreta lösningar.

* Glasscenen – fyra temadagar
Ta del av föredrag om fönsterrenovering, skydd och säkerhet samt arkitektur. Under torsdagen fördjupar vi oss bland annat i gestaltningen av World of Volvo och Sjustjärnan samt möter vinnarna av Glaspriset och Glaspärlan.

* Hantverk live
Se skickliga yrkesproffs visa fönsterrenovering - ett komplext hantverk som omfattar många moment.

Höjdpunkter du inte vill missa:
23 april 09:30–11:00 – Föreningsmöte för medlemmar

23 april 12:30 – Arkitekturpriset i studenttävlingen Nya ögon på glas offentliggörs på Nordbygg Live-scenen

23 april 14:00 – Arkitekturpriserna Glaspriset och Glaspärlan delas ut på Nordbygg Live-scenen

23 april 15:30 – Mingel i montern för att fira vinnarna av glaspriserna

24 april – Kvinnlig nätverksfrukost följt av fortsatt nätverkande och lunch

Besök Glastorget i monter C11:41
På Glastorget träffar du de ledande aktörerna Arton:1 Projekt, Certo Software, Fasadglas, Orgadata, Ragn-Sells Recycling, Svenssons i Tenhult och Vidaflam.

Glas tar plats redan i entrén
I årets studenttävling Nya ögon på glas har framtidens arkitekter skapat Nordbygg Live – en uttrycksfull mötesplats byggd av återbrukat glas och återvunna aluminiumprofiler.
En bransch som ser ljust på framtiden
Trots ett utmanande omvärldsläge pekar mycket på en positiv utveckling för glas i Sverige. Nordbygg blir därför en viktig kraftsamling för att rusta branschen inför framtiden.

Hjärtligt välkommen att uppleva glasets möjligheter på Nordbygg 2026!'), 'https://www.gbf.se', 'assets/images/exhibitors/nordbygg-2026-glasbranschforeningen.jpg'),
  ('nordbygg-2026-exhibitor-137716', 'nordbygg-2026', 'Glastorget', 'C11:41 (+1)', null, 'https://www.gbf.se', null),
  ('nordbygg-2026-exhibitor-139059', 'nordbygg-2026', 'Godik AB', 'EÖ:27', jsonb_build_object('en', 'KOMPLETTA LÖSNINGAR – ANPASSADE EFTER DINA BEHOV

Inget projekt är det andra likt – varje festival, evenemang eller arbetsplats har sina unika krav och utmaningar. Hos Godik har vi lösningarna.
Med över 30 års erfarenhet kombinerar vi modern utrustning, innovativa lösningar och en genuin förståelse för våra kunders behov, oavsett om du arrangerar ett stort festivalområde eller behöver praktisk utrustning till din byggarbetsplats, kan vi erbjuda:

- Hållbara och bekväma sanitära lösningar
- Mobil utrustning för olika användningsområden
- Specialutrustning för ökad tillgänglighet och inkludering
- Egen logistik som säkerställer leverans i tid
- Professionellt service-team som finns till hands när du behöver det

Med Godik får du allt från en och samma partner – trygghet och kvalitet för din framgång.', 'sv', 'KOMPLETTA LÖSNINGAR – ANPASSADE EFTER DINA BEHOV

Inget projekt är det andra likt – varje festival, evenemang eller arbetsplats har sina unika krav och utmaningar. Hos Godik har vi lösningarna.
Med över 30 års erfarenhet kombinerar vi modern utrustning, innovativa lösningar och en genuin förståelse för våra kunders behov, oavsett om du arrangerar ett stort festivalområde eller behöver praktisk utrustning till din byggarbetsplats, kan vi erbjuda:

- Hållbara och bekväma sanitära lösningar
- Mobil utrustning för olika användningsområden
- Specialutrustning för ökad tillgänglighet och inkludering
- Egen logistik som säkerställer leverans i tid
- Professionellt service-team som finns till hands när du behöver det

Med Godik får du allt från en och samma partner – trygghet och kvalitet för din framgång.'), 'https://www.godik.se', 'assets/images/exhibitors/nordbygg-2026-godik-ab.jpg'),
  ('nordbygg-2026-exhibitor-136156', 'nordbygg-2026', 'Golvabia', 'C06:21', jsonb_build_object('en', 'På Golvabia tror vi på ett hem med stilsäkra och medvetna val av material och form. Vi skapar därför ett produktsortiment som kännetecknas av skandinavisk design och svensk kvalité, som lämpar sig för såväl hem som offentlig miljö.

Vårt sortiment idag innefattar trägolv, textilgolv och kakel & klinker, vilket gör att vi har ett av marknadens bredaste sortiment. Du hittar oss alltid i närheten tack vare våra ca 500 återförsäljare runt om i Sverige.

Trägolven tillverkar vi i vår moderna fabrik i småländska Anderstorp. Här återfinns även vårt huvudkontor och lager.', 'sv', 'På Golvabia tror vi på ett hem med stilsäkra och medvetna val av material och form. Vi skapar därför ett produktsortiment som kännetecknas av skandinavisk design och svensk kvalité, som lämpar sig för såväl hem som offentlig miljö.

Vårt sortiment idag innefattar trägolv, textilgolv och kakel & klinker, vilket gör att vi har ett av marknadens bredaste sortiment. Du hittar oss alltid i närheten tack vare våra ca 500 återförsäljare runt om i Sverige.

Trägolven tillverkar vi i vår moderna fabrik i småländska Anderstorp. Här återfinns även vårt huvudkontor och lager.'), 'https://www.golvabia.se', 'assets/images/exhibitors/nordbygg-2026-golvabia.jpg'),
  ('nordbygg-2026-exhibitor-139436', 'nordbygg-2026', 'Gor-Stal sp. z o.o.', 'C11:69', null, 'https://www.gor-stal.pl', null),
  ('nordbygg-2026-exhibitor-134750', 'nordbygg-2026', 'Grabber / Arne Thuresson Byggmaterial AB', 'B02:41', jsonb_build_object('en', 'Ett svenskt familjeföretag grundat 1974

Arne Thuresson Byggmaterial AB är specialinriktade inom Skruv & infästning, Vägg och Grund. Med expertis och bred kompetens, skapar och levererar vi kvalitetssäkrade produkter och garanterar att rätt material och tryggaste konstruktionen erbjuds. Vi håller det vi lovar och vi investerar tid och engagemang när det kommer till relationen med våra kunder och anställda.

Viljekraften som gav bestående kvalitet.
Arne Thuresson levde alltid efter mottot att ingenting är omöjligt och det var just hans idésprudlande sinne och beslutsamhet som blev grunden till framgången av Arne Thuresson Byggmaterial, som han tillsammans med sina 5 barn, startade på 70-talet.

1974 fick Arne Thuresson ett samtal från grundaren av Grabber i USA, John Geyer. Ett samtal som skulle komma att ha stor betydelse inom skruvbranschen i Sverige. John Geyer kom till Stockholm och visade upp en gipsskruv med dubbelhuvud och sylvass spets som såg helt annorlunda ut än vad Arne tidigare sett på marknaden. Arne höll upp skruven och sa på knackig engelska. ”Om du lovar mig att alla skruvar håller samma kvalité som den här så lovar jag att sälja 25 miljoner skruv första året.”

Sagt och gjort. Arne sålde 40 miljoner skruv det första året och Arne Thuresson Byggmaterial blev därmed generalagent för Grabber® och i och med det kom det stora startskottet för kvalitetsskruven som sedan dess gjort succé i byggbranschen och för tusentals montörer dagligen Sverige över.', 'sv', 'Ett svenskt familjeföretag grundat 1974

Arne Thuresson Byggmaterial AB är specialinriktade inom Skruv & infästning, Vägg och Grund. Med expertis och bred kompetens, skapar och levererar vi kvalitetssäkrade produkter och garanterar att rätt material och tryggaste konstruktionen erbjuds. Vi håller det vi lovar och vi investerar tid och engagemang när det kommer till relationen med våra kunder och anställda.

Viljekraften som gav bestående kvalitet.
Arne Thuresson levde alltid efter mottot att ingenting är omöjligt och det var just hans idésprudlande sinne och beslutsamhet som blev grunden till framgången av Arne Thuresson Byggmaterial, som han tillsammans med sina 5 barn, startade på 70-talet.

1974 fick Arne Thuresson ett samtal från grundaren av Grabber i USA, John Geyer. Ett samtal som skulle komma att ha stor betydelse inom skruvbranschen i Sverige. John Geyer kom till Stockholm och visade upp en gipsskruv med dubbelhuvud och sylvass spets som såg helt annorlunda ut än vad Arne tidigare sett på marknaden. Arne höll upp skruven och sa på knackig engelska. ”Om du lovar mig att alla skruvar håller samma kvalité som den här så lovar jag att sälja 25 miljoner skruv första året.”

Sagt och gjort. Arne sålde 40 miljoner skruv det första året och Arne Thuresson Byggmaterial blev därmed generalagent för Grabber® och i och med det kom det stora startskottet för kvalitetsskruven som sedan dess gjort succé i byggbranschen och för tusentals montörer dagligen Sverige över.'), 'https://www.thuresson.se', 'assets/images/exhibitors/nordbygg-2026-grabber-arne-thuresson-byggmaterial-ab.jpg'),
  ('nordbygg-2026-exhibitor-133961', 'nordbygg-2026', 'Granab AB', 'C08:60', jsonb_build_object('en', 'Granab tillverkar golvregelsystem i stål och trä för bostäder, kontor, skolor, offentliga lokaler och sport- och gymgolv.
Ett höjdjusterbart system som löser de akustiska kraven på bjälklag i både betong och trä.
Monterat i mer än 6 000 000 m2 i snart hela Europa.', 'sv', 'Granab tillverkar golvregelsystem i stål och trä för bostäder, kontor, skolor, offentliga lokaler och sport- och gymgolv.
Ett höjdjusterbart system som löser de akustiska kraven på bjälklag i både betong och trä.
Monterat i mer än 6 000 000 m2 i snart hela Europa.'), 'https://www.granab.se', 'assets/images/exhibitors/nordbygg-2026-granab-ab.jpg'),
  ('nordbygg-2026-exhibitor-134608', 'nordbygg-2026', 'Granitor Electro AB', 'A13:13', jsonb_build_object('en', 'Granitor Electro AB är ett av nordens ledande elteknikföretag och ett av de snabbast växande och har idag över 2500 medarbetare. Vi erbjuder tjänster inom elektrisk installation, instrumentation och laddstationer för elfordon, säkerhetsinstallationer och fastighetsautomation. Vi är dessutom leverantörsoberoende. Sammantaget innebär det att vi kan skräddarsy lösningar utifrån specifika behov – lösningar som håller över tid och tål att utvecklas.

Strategin bygger på en stark lokal närvaro med lönsamma etableringar över hela Sverige och Norge. Verkar inom branscher som husbyggnation, infrastruktur, kärnkraft, stål, petrokemi och gruvdrift.', 'sv', 'Granitor Electro AB är ett av nordens ledande elteknikföretag och ett av de snabbast växande och har idag över 2500 medarbetare. Vi erbjuder tjänster inom elektrisk installation, instrumentation och laddstationer för elfordon, säkerhetsinstallationer och fastighetsautomation. Vi är dessutom leverantörsoberoende. Sammantaget innebär det att vi kan skräddarsy lösningar utifrån specifika behov – lösningar som håller över tid och tål att utvecklas.

Strategin bygger på en stark lokal närvaro med lönsamma etableringar över hela Sverige och Norge. Verkar inom branscher som husbyggnation, infrastruktur, kärnkraft, stål, petrokemi och gruvdrift.'), 'https://www.granitor.se/electro', 'assets/images/exhibitors/nordbygg-2026-granitor-electro-ab.jpg'),
  ('nordbygg-2026-exhibitor-139698', 'nordbygg-2026', 'Granlund Oy', 'BG:07', jsonb_build_object('en', 'Granlund Group är ett proptech och konsultföretag som specialiserar sig på fastighets- och byggsektorerna. Vi skapar en hållbar och smart framtid tillsammans med våra kunder och intressenter. Idag är vi över 1700 anställda med kontor i Sverige, Finland och Storbritannien.', 'sv', 'Granlund Group är ett proptech och konsultföretag som specialiserar sig på fastighets- och byggsektorerna. Vi skapar en hållbar och smart framtid tillsammans med våra kunder och intressenter. Idag är vi över 1700 anställda med kontor i Sverige, Finland och Storbritannien.'), 'https://www.granlund.fi', 'assets/images/exhibitors/nordbygg-2026-granlund-oy.jpg'),
  ('nordbygg-2026-exhibitor-136719', 'nordbygg-2026', 'Granum stenprodukter', 'C04:61B', null, 'https://granumstenprodukter.se', null),
  ('nordbygg-2026-exhibitor-139478', 'nordbygg-2026', 'Great Cosmo Petrochem Sdn Bhd', 'C05:69', null, 'https://www.greatcosmo.com', null),
  ('nordbygg-2026-exhibitor-139063', 'nordbygg-2026', 'Green Box Sverige', 'A11:14', jsonb_build_object('en', 'Green Box producerar dansk­tillverkade prefabricerade badrum med en innovativ lättviktskonstruktion och gjutet betonggolv. Våra lösningar är utvecklade för en effektiv byggprocess med fokus på resurseffektivitet, hög kvalitet och ett tillförlitligt genomförande – vilket skapar värde både för projektets ekonomi och för produktionen på byggarbetsplatsen.', 'sv', 'Green Box producerar dansk­tillverkade prefabricerade badrum med en innovativ lättviktskonstruktion och gjutet betonggolv. Våra lösningar är utvecklade för en effektiv byggprocess med fokus på resurseffektivitet, hög kvalitet och ett tillförlitligt genomförande – vilket skapar värde både för projektets ekonomi och för produktionen på byggarbetsplatsen.'), 'https://www.greenbox.dk', 'assets/images/exhibitors/nordbygg-2026-green-box-sverige.jpg'),
  ('nordbygg-2026-exhibitor-138004', 'nordbygg-2026', 'Greener Power Solutions', 'B07:11', jsonb_build_object('en', 'We are Greener. With the largest battery fleet
in Europe, we lead the way in the temporary
energy market. We provide mobile battery
solutions for anyone needing more energy
than the grid can supply. After all, everyone
will need to join the energy transition
eventually. Our aim is to make the transition
easy. Easily emission-free.', 'sv', 'We are Greener. With the largest battery fleet
in Europe, we lead the way in the temporary
energy market. We provide mobile battery
solutions for anyone needing more energy
than the grid can supply. After all, everyone
will need to join the energy transition
eventually. Our aim is to make the transition
easy. Easily emission-free.'), 'https://greenerpowersolutions.com', 'assets/images/exhibitors/nordbygg-2026-greener-power-solutions.jpg'),
  ('nordbygg-2026-exhibitor-139483', 'nordbygg-2026', 'Greenworks', 'EÖ:06', jsonb_build_object('en', 'Greenworks specialitet är biofiliska designprodukter, skräddarsydda, unika gröna lösningar och vertikala trädgårdar för både inomhus- och utomhusbruk.

Leafy Solutions är en del av Greenworks och erbjuder produkter och system som integrerar grönska i arkitektur utan att kompromissa med design eller funktion.

På Nordbygg 2026 lanserar Leafy Solutions ett nytt modulärt fasadsystem – det vill ni inte missa!', 'sv', 'Greenworks specialitet är biofiliska designprodukter, skräddarsydda, unika gröna lösningar och vertikala trädgårdar för både inomhus- och utomhusbruk.

Leafy Solutions är en del av Greenworks och erbjuder produkter och system som integrerar grönska i arkitektur utan att kompromissa med design eller funktion.

På Nordbygg 2026 lanserar Leafy Solutions ett nytt modulärt fasadsystem – det vill ni inte missa!'), 'https://www.greenworks.se', 'assets/images/exhibitors/nordbygg-2026-greenworks.jpg'),
  ('nordbygg-2026-exhibitor-137709', 'nordbygg-2026', 'GRIPP INREDNING AB', 'C07:33A', null, 'https://www.grippinredning.se', null),
  ('nordbygg-2026-exhibitor-139049', 'nordbygg-2026', 'GROHE', 'A01:201', jsonb_build_object('en', 'GROHE är ett ledande, globalt varumärke med kompletta lösningar för badrum och kök.

Sedan 2014 är GROHE en del av den starka varumärkesportföljen hos LIXIL, en tillverkare av banbrytande vatten- och bostadsprodukter. För att kunna erbjuda "Pure Freude an Wasser" bygger varje produkt på varumärkets värderingar: teknologi, kvalitet, design och hållbarhet.

Med vatten i centrum för verksamheten, tar GROHE sitt ansvar enligt LIXILs påverkansstrategi (LIXIL Impact Strategy) med en resursbesparande värdekedja: från koldioxidneutral produktion, eliminering av plast i produktförpackningar, hela vägen till vatten- och energibesparande teknologier som GROHE Everstream, en dusch som återanvänder vattnet.', 'sv', 'GROHE är ett ledande, globalt varumärke med kompletta lösningar för badrum och kök.

Sedan 2014 är GROHE en del av den starka varumärkesportföljen hos LIXIL, en tillverkare av banbrytande vatten- och bostadsprodukter. För att kunna erbjuda "Pure Freude an Wasser" bygger varje produkt på varumärkets värderingar: teknologi, kvalitet, design och hållbarhet.

Med vatten i centrum för verksamheten, tar GROHE sitt ansvar enligt LIXILs påverkansstrategi (LIXIL Impact Strategy) med en resursbesparande värdekedja: från koldioxidneutral produktion, eliminering av plast i produktförpackningar, hela vägen till vatten- och energibesparande teknologier som GROHE Everstream, en dusch som återanvänder vattnet.'), 'https://www.grohe.se', 'assets/images/exhibitors/nordbygg-2026-grohe.jpg'),
  ('nordbygg-2026-exhibitor-139140', 'nordbygg-2026', 'Grundéns Regnkläder AB', 'B08:43', jsonb_build_object('en', 'Det började för mer än 100 år sedan på Sveriges västkust, i det lilla fiskesamhället Grundsund, när Carl A. Grundén började tillverka vattentäta oljekläder för att skydda Nordsjöns fiskare från de krävande och hårda arbetsförhållandena.

Idag fortsätter vi att tillverka en betydande del av våra produkter i vår egen fabrik i Lissabon, Portugal, vilket gör det möjligt för oss att fokusera på konstruktion, hållbarhet och kvalitet. Denna fabrik är en avancerad ISO 9000-certifierad anläggning och ett produktutvecklingscenter för oss.', 'sv', 'Det började för mer än 100 år sedan på Sveriges västkust, i det lilla fiskesamhället Grundsund, när Carl A. Grundén började tillverka vattentäta oljekläder för att skydda Nordsjöns fiskare från de krävande och hårda arbetsförhållandena.

Idag fortsätter vi att tillverka en betydande del av våra produkter i vår egen fabrik i Lissabon, Portugal, vilket gör det möjligt för oss att fokusera på konstruktion, hållbarhet och kvalitet. Denna fabrik är en avancerad ISO 9000-certifierad anläggning och ett produktutvecklingscenter för oss.'), 'https://www.regnklader.se', 'assets/images/exhibitors/nordbygg-2026-grundens-regnklader-ab.jpg'),
  ('nordbygg-2026-exhibitor-137442', 'nordbygg-2026', 'Grundfos AB', 'A08:20', jsonb_build_object('en', 'Grundfos är en global ledare inom energieffektiva och driftsäkra pumplösningar för bostäder, kommersiella byggnader, industri, VA och jordbruk. Med huvudkontor i Danmark, över 20 000 anställda och mer än 15 miljoner pumpar producerade årligen, är vi en av världens största aktörer i branschen.

Sedan 1963 har Grundfos AB varit verksamma i Sverige med huvudkontor i Mölndal och rikstäckande närvaro. Vi erbjuder helhetslösningar – från produktval och dimensionering till service och support – med lokal expertis och snabb leverans från vårt centrallager i Danmark.

Vår serviceorganisation och våra auktoriserade partners säkerställer lång livslängd, hög effektivitet och trygg drift för varje pump vi levererar. Grundfos är också en drivande kraft bakom hållbara lösningar för vatten- och klimatutmaningar världen över.', 'sv', 'Grundfos är en global ledare inom energieffektiva och driftsäkra pumplösningar för bostäder, kommersiella byggnader, industri, VA och jordbruk. Med huvudkontor i Danmark, över 20 000 anställda och mer än 15 miljoner pumpar producerade årligen, är vi en av världens största aktörer i branschen.

Sedan 1963 har Grundfos AB varit verksamma i Sverige med huvudkontor i Mölndal och rikstäckande närvaro. Vi erbjuder helhetslösningar – från produktval och dimensionering till service och support – med lokal expertis och snabb leverans från vårt centrallager i Danmark.

Vår serviceorganisation och våra auktoriserade partners säkerställer lång livslängd, hög effektivitet och trygg drift för varje pump vi levererar. Grundfos är också en drivande kraft bakom hållbara lösningar för vatten- och klimatutmaningar världen över.'), 'https://www.grundfos.se', 'assets/images/exhibitors/nordbygg-2026-grundfos-ab.jpg'),
  ('nordbygg-2026-exhibitor-139454', 'nordbygg-2026', 'Gräscenter', 'C03:70', null, 'https://www.grascenter.se', null),
  ('nordbygg-2026-exhibitor-137850', 'nordbygg-2026', 'Gson Work', 'B07:50', null, 'https://www.gson.se', 'assets/images/exhibitors/nordbygg-2026-gson-work.jpg'),
  ('nordbygg-2026-exhibitor-138749', 'nordbygg-2026', 'GULATI BROTHERS', 'C11:11', null, 'https://www.gulatibros.com', 'assets/images/exhibitors/nordbygg-2026-gulati-brothers.jpg'),
  ('nordbygg-2026-exhibitor-136720', 'nordbygg-2026', 'Gullbergs MMVIII', 'C04:61E', null, 'https://gullbergs-sten.se', null),
  ('nordbygg-2026-exhibitor-135326', 'nordbygg-2026', 'Gustavsberg', 'A08:14', jsonb_build_object('en', 'Gustavsberg är ett ikoniskt designvarumärke som har bidragit till livskvalitet för generationer sedan 1825. Med filosofin funktion är skönhet som grund, utvecklar Gustavsberg badrumsprodukter med starkt fokus på människocentrerad design, innovation och hållbarhet. Från privata hem till offentliga miljöer som hotell, skolor och sjukhus – Gustavsbergs produkter används och uppskattas för sin kvalitet, hållbarhet och tidlösa estetik.
Vatette är ett ledande varumärke inom installationsprodukter för kompletta tappvattensystem. Känt för sina flexibla lösningar, byggt på traditionell teknik som tagits in i framtiden med nya innovationer.
Gustavsberg och Vatette ägs av Gustavsberg AB som är en del av Oras Group, en komplett badrumsleverantör med en stark position i Norden och en betydande närvaro i Centraleuropa.', 'sv', 'Gustavsberg är ett ikoniskt designvarumärke som har bidragit till livskvalitet för generationer sedan 1825. Med filosofin funktion är skönhet som grund, utvecklar Gustavsberg badrumsprodukter med starkt fokus på människocentrerad design, innovation och hållbarhet. Från privata hem till offentliga miljöer som hotell, skolor och sjukhus – Gustavsbergs produkter används och uppskattas för sin kvalitet, hållbarhet och tidlösa estetik.
Vatette är ett ledande varumärke inom installationsprodukter för kompletta tappvattensystem. Känt för sina flexibla lösningar, byggt på traditionell teknik som tagits in i framtiden med nya innovationer.
Gustavsberg och Vatette ägs av Gustavsberg AB som är en del av Oras Group, en komplett badrumsleverantör med en stark position i Norden och en betydande närvaro i Centraleuropa.'), 'https://gustavsberg.se', 'assets/images/exhibitors/nordbygg-2026-gustavsberg.jpg'),
  ('nordbygg-2026-exhibitor-134758', 'nordbygg-2026', 'Gustavsberg Rörsystem AB', 'A06:25', jsonb_build_object('en', 'Gustavsberg Rörsystem® — Lösningar som gör skillnad sedan 1947

Gustavsberg Rörsystem utvecklar och tillverkar avloppssystem och tryckrörssystem med fokus på kvalitet, hållbarhet och teknisk tillförlitlighet. Med lång erfarenhet, egen produktion och centrallager i Halmstad står vi för välutvecklade system, hög leveranssäkerhet och nära teknisk support till kunder och projektörer.

MA-SYSTEM® är ett komplett avloppssystem i gjutjärn där rör, rördelar och kopplingar är utvecklade, testade och certifierade tillsammans som ett helt system. Det är helheten som gör skillnad — och det är den som ger dokumenterad prestanda inom brandsäkerhet, ljudkomfort och hållbarhet.

Inom mark och infrastruktur har vi VRS-SYSTEM, ett robust tryckrörssystem för vatten- och avloppsnät med höga krav på hållbarhet och lång livslängd.

Utöver våra huvudsystem har vi ett brett sortiment inom övrigt gjutjärn, bland annat golvbrunnar, spygatter, lätta betäckningar och handpumpar.

På Nordbygg 2026 finns vi i monter A06:25. Där visar vi produkter, systemlösningar och dokumentation, och berättar mer om hur vi kan bidra med rätt lösning för både bygg och infrastruktur.', 'sv', 'Gustavsberg Rörsystem® — Lösningar som gör skillnad sedan 1947

Gustavsberg Rörsystem utvecklar och tillverkar avloppssystem och tryckrörssystem med fokus på kvalitet, hållbarhet och teknisk tillförlitlighet. Med lång erfarenhet, egen produktion och centrallager i Halmstad står vi för välutvecklade system, hög leveranssäkerhet och nära teknisk support till kunder och projektörer.

MA-SYSTEM® är ett komplett avloppssystem i gjutjärn där rör, rördelar och kopplingar är utvecklade, testade och certifierade tillsammans som ett helt system. Det är helheten som gör skillnad — och det är den som ger dokumenterad prestanda inom brandsäkerhet, ljudkomfort och hållbarhet.

Inom mark och infrastruktur har vi VRS-SYSTEM, ett robust tryckrörssystem för vatten- och avloppsnät med höga krav på hållbarhet och lång livslängd.

Utöver våra huvudsystem har vi ett brett sortiment inom övrigt gjutjärn, bland annat golvbrunnar, spygatter, lätta betäckningar och handpumpar.

På Nordbygg 2026 finns vi i monter A06:25. Där visar vi produkter, systemlösningar och dokumentation, och berättar mer om hur vi kan bidra med rätt lösning för både bygg och infrastruktur.'), 'https://www.gustavsberg-ror.se', 'assets/images/exhibitors/nordbygg-2026-gustavsberg-rorsystem-ab.jpg'),
  ('nordbygg-2026-exhibitor-139907', 'nordbygg-2026', 'Gyproc, Saint-Gobain Sweden AB', 'C13:51', jsonb_build_object('en', 'Gyproc bryr sig om att bygga bättre för människor och planeten genom att erbjuda lösningar för innerväggar, ytterväggar och undertak som levererar hållbarhet och funktion.

I en värld där förändring är det enda konstanta, där livet utvecklas och nya behov uppstår, tror Gyproc på kraften i våra lösningar som bygger rum för livet.

Som en global ledare inom gipsindustrin designer, tillverkar och distribuerar vi innovativa lösningar som möter mänskliga behov i utveckling.

Vi föreställer oss framtidens byggande och strävar efter att höja komforten för alla intressenter, för såväl arkitekter, installatörer som distributörer och boende. Som tillverkare är vårt uppdrag att utveckla och tillhandahålla högkvalitativa produkter och tjänster som erbjuder hållbarhet, funktion och support både till kunder och industrin. Det har alltid varit vårt fokus och vi står fast vid vårt åtagande att reducera vår miljöpåverkan eftersom vi tror på potentialen i våra lösningar att kunna anpassas och möta kraven för att bygga rum för livet, inte bara idag utan även imorgon.

Tillsammans med Dalapro, Isover och Weber ingår vi i Saint-Gobain Sweden AB som är en del av koncernen Saint-Gobain – med 360 års erfarenhet av material och byggnadslösningar med hög innovationsgrad.

Saint-Gobain är världsledande inom lätt och hållbart byggande och designar, tillverkar och distribuerar material och tjänster för byggmarknaden. Alla varumärken inom Saint-Gobain styrs av ett gemensamt syfte: "MAKING THE WORLD A BETTER HOME".', 'sv', 'Gyproc bryr sig om att bygga bättre för människor och planeten genom att erbjuda lösningar för innerväggar, ytterväggar och undertak som levererar hållbarhet och funktion.

I en värld där förändring är det enda konstanta, där livet utvecklas och nya behov uppstår, tror Gyproc på kraften i våra lösningar som bygger rum för livet.

Som en global ledare inom gipsindustrin designer, tillverkar och distribuerar vi innovativa lösningar som möter mänskliga behov i utveckling.

Vi föreställer oss framtidens byggande och strävar efter att höja komforten för alla intressenter, för såväl arkitekter, installatörer som distributörer och boende. Som tillverkare är vårt uppdrag att utveckla och tillhandahålla högkvalitativa produkter och tjänster som erbjuder hållbarhet, funktion och support både till kunder och industrin. Det har alltid varit vårt fokus och vi står fast vid vårt åtagande att reducera vår miljöpåverkan eftersom vi tror på potentialen i våra lösningar att kunna anpassas och möta kraven för att bygga rum för livet, inte bara idag utan även imorgon.

Tillsammans med Dalapro, Isover och Weber ingår vi i Saint-Gobain Sweden AB som är en del av koncernen Saint-Gobain – med 360 års erfarenhet av material och byggnadslösningar med hög innovationsgrad.

Saint-Gobain är världsledande inom lätt och hållbart byggande och designar, tillverkar och distribuerar material och tjänster för byggmarknaden. Alla varumärken inom Saint-Gobain styrs av ett gemensamt syfte: "MAKING THE WORLD A BETTER HOME".'), 'https://www.gyproc.se', 'assets/images/exhibitors/nordbygg-2026-gyproc-saint-gobain-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-134667', 'nordbygg-2026', 'Gårö Badrum', 'A07:08', null, 'https://www.gppab.se', 'assets/images/exhibitors/nordbygg-2026-garo-badrum.jpg'),
  ('nordbygg-2026-exhibitor-133973', 'nordbygg-2026', 'Göthes Industribeslag AB', 'C10:21', jsonb_build_object('en', 'Lås, beslag, dörrstyrning, säkerhet och teknik – allt under ett tak.

Med över 160 års erfarenhet, fler än 50 ledande varumärken och ett brett sortiment erbjuder Göthes Industribeslag smarta och heltäckande lösningar för dörr-, fönster- och fasadindustrin. Med teknisk support, hög tillgänglighet och effektiva logistiklösningar är vi en trygg partner för kunder i hela Sverige.', 'sv', 'Lås, beslag, dörrstyrning, säkerhet och teknik – allt under ett tak.

Med över 160 års erfarenhet, fler än 50 ledande varumärken och ett brett sortiment erbjuder Göthes Industribeslag smarta och heltäckande lösningar för dörr-, fönster- och fasadindustrin. Med teknisk support, hög tillgänglighet och effektiva logistiklösningar är vi en trygg partner för kunder i hela Sverige.'), 'https://www.gothes.se', 'assets/images/exhibitors/nordbygg-2026-gothes-industribeslag-ab.jpg'),
  ('nordbygg-2026-exhibitor-134622', 'nordbygg-2026', 'H. Östberg AB', 'A14:14', null, 'https://www.ostberg.com', 'assets/images/exhibitors/nordbygg-2026-h-ostberg-ab.jpg'),
  ('nordbygg-2026-exhibitor-134456', 'nordbygg-2026', 'Habo Gruppen AB', 'C03:31', jsonb_build_object('en', 'Habo är företaget från orten med samma namn. En gammal smidesverkstad som utvecklats till Nordens ledande företag på funktionella beslag. Med små detaljer kan du göra stor skillnad.', 'sv', 'Habo är företaget från orten med samma namn. En gammal smidesverkstad som utvecklats till Nordens ledande företag på funktionella beslag. Med små detaljer kan du göra stor skillnad.'), 'https://www.habo.com', 'assets/images/exhibitors/nordbygg-2026-habo-gruppen-ab.jpg'),
  ('nordbygg-2026-exhibitor-134573', 'nordbygg-2026', 'Hafa Brand Group', 'A05:12', null, 'https://www.hafabg.com', null),
  ('nordbygg-2026-exhibitor-136721', 'nordbygg-2026', 'Hallindens Granit', 'C04:61D', jsonb_build_object('en', 'Hallindens Granit är ett modernt stenföretag med lång historia. Vi säljer och levererar högkvalitativa naturstensblock samt bearbetade produkter för utomhus- och inomhusbruk, t ex plattor, markhällar, fasad, gatsten, kantsten, trappor, entréplan, murar, stolpar, golv, väggbeklädnad, bänk- och bordsskivor samt fönsterbänkar.

Vi har vår bas i Skarstad, Bohuslän, där vi har både stenbrott, huvudkontor och produktionsanläggning.

Vi driver totalt sju egna stenbrott: SKARSTAD Röd Bohus, BROBERG Röd Bohus, TOSSENE Grå Bohus, SILVER Grå Bohus, MOHEDA Svart Diabas, SVENSTORP Hallandia, TRANÅS Classic och Original.

Läs mer om våra stensorter och produkter på vår hemsida https://hallindensgranit.se/

Följ oss gärna i sociala medier:
https://www.linkedin.com/company/hallindens-granit-ab
https://www.instagram.com/hallindensgranit
https://www.facebook.com/hallindensgranit', 'sv', 'Hallindens Granit är ett modernt stenföretag med lång historia. Vi säljer och levererar högkvalitativa naturstensblock samt bearbetade produkter för utomhus- och inomhusbruk, t ex plattor, markhällar, fasad, gatsten, kantsten, trappor, entréplan, murar, stolpar, golv, väggbeklädnad, bänk- och bordsskivor samt fönsterbänkar.

Vi har vår bas i Skarstad, Bohuslän, där vi har både stenbrott, huvudkontor och produktionsanläggning.

Vi driver totalt sju egna stenbrott: SKARSTAD Röd Bohus, BROBERG Röd Bohus, TOSSENE Grå Bohus, SILVER Grå Bohus, MOHEDA Svart Diabas, SVENSTORP Hallandia, TRANÅS Classic och Original.

Läs mer om våra stensorter och produkter på vår hemsida https://hallindensgranit.se/

Följ oss gärna i sociala medier:
https://www.linkedin.com/company/hallindens-granit-ab
https://www.instagram.com/hallindensgranit
https://www.facebook.com/hallindensgranit'), 'https://hallindensgranit.se/', 'assets/images/exhibitors/nordbygg-2026-hallindens-granit.jpg'),
  ('nordbygg-2026-exhibitor-135005', 'nordbygg-2026', 'Hallströms Verkstäder AB', 'A21:18', null, 'https://www.hallstroms.se', 'assets/images/exhibitors/nordbygg-2026-hallstroms-verkstader-ab.jpg'),
  ('nordbygg-2026-exhibitor-136904', 'nordbygg-2026', 'Halton', 'A19:13', jsonb_build_object('en', 'Halton Group är ett familjeägt, globalt teknikföretag som är ledande inom inomhusklimatlösningar för krävande miljöer. På Halton är vårt uppdrag att främja människors välbefinnande i dessa miljöer.

Vi utformar, tillverkar och levererar lösningar för inomhusmiljön till:
- Kommersiella och offentliga byggnader
- Vårdinstitutioner och laboratorier
- Storkök och restauranger
- Miljöer inom energiproduktion och tung industri
- Fartyg.

Vi arbetar i nära samarbete med våra kunder och partners för att tillgodose deras särskilda behov och till och med överträffa förväntningarna. Vi skapar säkra, bekväma och produktiva inomhusmiljöer som är energieffektiva och följer hållbarhetsprinciper.', 'sv', 'Halton Group är ett familjeägt, globalt teknikföretag som är ledande inom inomhusklimatlösningar för krävande miljöer. På Halton är vårt uppdrag att främja människors välbefinnande i dessa miljöer.

Vi utformar, tillverkar och levererar lösningar för inomhusmiljön till:
- Kommersiella och offentliga byggnader
- Vårdinstitutioner och laboratorier
- Storkök och restauranger
- Miljöer inom energiproduktion och tung industri
- Fartyg.

Vi arbetar i nära samarbete med våra kunder och partners för att tillgodose deras särskilda behov och till och med överträffa förväntningarna. Vi skapar säkra, bekväma och produktiva inomhusmiljöer som är energieffektiva och följer hållbarhetsprinciper.'), 'https://www.halton.com/se', 'assets/images/exhibitors/nordbygg-2026-halton.jpg'),
  ('nordbygg-2026-exhibitor-138959', 'nordbygg-2026', 'Hamar Sp.J.', 'B02:51', null, 'https://hamarfasteners.com/', 'assets/images/exhibitors/nordbygg-2026-hamar-sp-j.jpg'),
  ('nordbygg-2026-exhibitor-137821', 'nordbygg-2026', 'HandyDay', 'C01:07', jsonb_build_object('en', 'HandyDay är en smart upphandlings- och affärsplattform för bygg- och fastighetsbranschen. Vi hjälper både inköpare och leverantörer att förenkla inköp, minska risker och hitta nya affärer.', 'sv', 'HandyDay är en smart upphandlings- och affärsplattform för bygg- och fastighetsbranschen. Vi hjälper både inköpare och leverantörer att förenkla inköp, minska risker och hitta nya affärer.'), 'https://handyday.com', 'assets/images/exhibitors/nordbygg-2026-handyday.jpg'),
  ('nordbygg-2026-exhibitor-139040', 'nordbygg-2026', 'Hansgrohe', 'A01:203', jsonb_build_object('en', 'Med sina varumärken AXOR och hansgrohe är Hansgrohe Group ledande inom innovation, design och kvalitet inom badrums- och köksindustrin. Verksamheten, som grundades 1901, ger vattnet form och funktion med sina kranar, duschar och duschsystem. I kombination med sanitets- och badrumsmöbler erbjuder företaget skräddarsydda designmöjligheter från ett ställe för holistiska badrumsupplevelser. Verksamhetens 125-åriga historia präglas av uppfinningar, till exempel den första handduschen med olika stråltyper, den första köksblandaren med utdragbar pip och den första duschstången. Med över 15.000 aktiva varumärkesskydd står dessa varumärken för kvalitetsprodukter med lång livslängd och ansvarstagande gentemot människor och miljö.', 'sv', 'Med sina varumärken AXOR och hansgrohe är Hansgrohe Group ledande inom innovation, design och kvalitet inom badrums- och köksindustrin. Verksamheten, som grundades 1901, ger vattnet form och funktion med sina kranar, duschar och duschsystem. I kombination med sanitets- och badrumsmöbler erbjuder företaget skräddarsydda designmöjligheter från ett ställe för holistiska badrumsupplevelser. Verksamhetens 125-åriga historia präglas av uppfinningar, till exempel den första handduschen med olika stråltyper, den första köksblandaren med utdragbar pip och den första duschstången. Med över 15.000 aktiva varumärkesskydd står dessa varumärken för kvalitetsprodukter med lång livslängd och ansvarstagande gentemot människor och miljö.'), 'https://www.hansgrohe.se', 'assets/images/exhibitors/nordbygg-2026-hansgrohe.jpg'),
  ('nordbygg-2026-exhibitor-138692', 'nordbygg-2026', 'Hantino', 'C09:13', jsonb_build_object('en', 'Vi förenklar köksmontering.', 'sv', 'Vi förenklar köksmontering.'), 'https://www.hantino.se', 'assets/images/exhibitors/nordbygg-2026-hantino.jpg'),
  ('nordbygg-2026-exhibitor-133995', 'nordbygg-2026', 'HeatUp Sverige AB', 'A07:18', jsonb_build_object('en', 'HeatUp Sverige AB är ett innovativt företag som specialiserar sig på energieffektiva värmelösningar för  företag. Med fokus på hållbarhet, kvalitet och modern teknik erbjuder vi produkter och tjänster som bidrar till minskad energiförbrukning och ökad komfort inom Golvvärme, Markvärme, Kulvert och Tappvatten - System

Genom att kombinera expertkunskap med kundanpassade lösningar strävar vi efter att vara en pålitlig partner inom uppvärmning och energisystem. Vår vision är att göra det enkelt och lönsamt att välja smartare och mer miljövänliga alternativ.

HeatUp Sverige AB – lokalt engagemang och personlig service, alltid med kunden först.', 'sv', 'HeatUp Sverige AB är ett innovativt företag som specialiserar sig på energieffektiva värmelösningar för  företag. Med fokus på hållbarhet, kvalitet och modern teknik erbjuder vi produkter och tjänster som bidrar till minskad energiförbrukning och ökad komfort inom Golvvärme, Markvärme, Kulvert och Tappvatten - System

Genom att kombinera expertkunskap med kundanpassade lösningar strävar vi efter att vara en pålitlig partner inom uppvärmning och energisystem. Vår vision är att göra det enkelt och lönsamt att välja smartare och mer miljövänliga alternativ.

HeatUp Sverige AB – lokalt engagemang och personlig service, alltid med kunden först.'), 'https://www.HeatUp.se', 'assets/images/exhibitors/nordbygg-2026-heatup-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-135717', 'nordbygg-2026', 'Heatwork AB', 'B09:13', jsonb_build_object('en', 'Om Heatwork
HeatWork tillverkar mobila kraftverk speciellt utformade för många olika användningsområden: tina upp frusen mark, härda betong, frostskydd, värma upp byggnader, tillhandahålla varmvatten till fjärrvärmesystem, beredskap och många fler.

HeatWorks kunder är främst maskinentreprenörer, fjärrvärmebolag, landskapsarkitekter, uthyrningsfirmor, kraftbolag, kommuner samt myndigheter och företag involverade i byggbranchen.', 'sv', 'Om Heatwork
HeatWork tillverkar mobila kraftverk speciellt utformade för många olika användningsområden: tina upp frusen mark, härda betong, frostskydd, värma upp byggnader, tillhandahålla varmvatten till fjärrvärmesystem, beredskap och många fler.

HeatWorks kunder är främst maskinentreprenörer, fjärrvärmebolag, landskapsarkitekter, uthyrningsfirmor, kraftbolag, kommuner samt myndigheter och företag involverade i byggbranchen.'), 'https://www.heatwork.com', 'assets/images/exhibitors/nordbygg-2026-heatwork-ab.jpg'),
  ('nordbygg-2026-exhibitor-133997', 'nordbygg-2026', 'Heco Nordiska AB', 'B05:21', jsonb_build_object('en', 'Sedan 1989 är Skruvspecialisten Heco en heltäckande leverantör av byggrelaterad infästning till Nordiska byggindustrin och detaljhandeln. Genom kompetens, brett sortiment och kundunika lösningar löser vi våra kunders behov av rätt infästningsprodukter. Några exempel är träskruv, gipsskruv, skivskruv, plåtskruv, borrskruv och farmarskruv. Bland produkterna finns även beslag och en mängd tillbehör.

I Hillerstorp, strax norr om Värnamo i Småland, är vi ett 60-tal personer som arbetar med inköp, försäljning, paketering i kartonger, askar och påsar samt lackering av olika typer av fästelement. Lackering utförs med stor noggrannhet och är idag en av våra främsta styrkor.

Förutom att hålla högsta klass som leverantörer är vi offensiva när det gäller produktutveckling. I vårt sortiment ingår även speciellt framtagna produkter som vi utvecklat i samarbete med våra kunder och våra globala leverantörer.

Inom bolaget finns varumärkena Heco & FAST Smart Fästteknik.

Sedan 2020 är vi en del av Volati (publ) och Salix Group. Läs gärna mer om oss på www.heco.se', 'sv', 'Sedan 1989 är Skruvspecialisten Heco en heltäckande leverantör av byggrelaterad infästning till Nordiska byggindustrin och detaljhandeln. Genom kompetens, brett sortiment och kundunika lösningar löser vi våra kunders behov av rätt infästningsprodukter. Några exempel är träskruv, gipsskruv, skivskruv, plåtskruv, borrskruv och farmarskruv. Bland produkterna finns även beslag och en mängd tillbehör.

I Hillerstorp, strax norr om Värnamo i Småland, är vi ett 60-tal personer som arbetar med inköp, försäljning, paketering i kartonger, askar och påsar samt lackering av olika typer av fästelement. Lackering utförs med stor noggrannhet och är idag en av våra främsta styrkor.

Förutom att hålla högsta klass som leverantörer är vi offensiva när det gäller produktutveckling. I vårt sortiment ingår även speciellt framtagna produkter som vi utvecklat i samarbete med våra kunder och våra globala leverantörer.

Inom bolaget finns varumärkena Heco & FAST Smart Fästteknik.

Sedan 2020 är vi en del av Volati (publ) och Salix Group. Läs gärna mer om oss på www.heco.se'), 'https://www.heco.se', 'assets/images/exhibitors/nordbygg-2026-heco-nordiska-ab.jpg'),
  ('nordbygg-2026-exhibitor-139193', 'nordbygg-2026', 'Heidelberg Materials Precast Contiga AB', 'C09:53', null, 'https://www.contiga.se', 'assets/images/exhibitors/nordbygg-2026-heidelberg-materials-precast-contiga-ab.jpg'),
  ('nordbygg-2026-exhibitor-139608', 'nordbygg-2026', 'Hellberg Safety', 'B01:31 (+1)', jsonb_build_object('en', 'Hellberg Safety har som mål att leverera det bästa inom hörselskydd, ögonskydd och ansiktsskydd. Som ett svenskt företag är design och kvalitet lika viktigt för oss som de många säkerhetsfunktionerna i vår produktutveckling.', 'sv', 'Hellberg Safety har som mål att leverera det bästa inom hörselskydd, ögonskydd och ansiktsskydd. Som ett svenskt företag är design och kvalitet lika viktigt för oss som de många säkerhetsfunktionerna i vår produktutveckling.'), 'https://www.hultaforsgroup.com', 'assets/images/exhibitors/nordbygg-2026-hellberg-safety.jpg'),
  ('nordbygg-2026-exhibitor-134001', 'nordbygg-2026', 'Hellbergs Door Company AB', 'C13:41', jsonb_build_object('en', 'Hellbergs Door Company är en svensk tillverkare av högpresterande ståldörrar. Med över 75 års erfarenhet designar och producerar vi klassade ståldörrar för säkerhet, brandskydd och krävande miljöer. Vi erbjuder produkter för fastigheter, industri, offentliga miljöer och infrastruktur i hela Norden. Genom att kombinera ingenjörskonst med tillförlitlighet levererar Hellbergs produkter byggda för att skydda det som är viktigast. På Hellbergs bygger vi ståldörrar för generationer.', 'sv', 'Hellbergs Door Company är en svensk tillverkare av högpresterande ståldörrar. Med över 75 års erfarenhet designar och producerar vi klassade ståldörrar för säkerhet, brandskydd och krävande miljöer. Vi erbjuder produkter för fastigheter, industri, offentliga miljöer och infrastruktur i hela Norden. Genom att kombinera ingenjörskonst med tillförlitlighet levererar Hellbergs produkter byggda för att skydda det som är viktigast. På Hellbergs bygger vi ståldörrar för generationer.'), 'https://www.hellbergs.se/sv', 'assets/images/exhibitors/nordbygg-2026-hellbergs-door-company-ab.jpg'),
  ('nordbygg-2026-exhibitor-134658', 'nordbygg-2026', 'Heno AB', 'A07:30', jsonb_build_object('en', 'Heno AB är experter på sanitetslösningar för publika och krävande miljöer, med över 60 års erfarenhet av driftsäkra system.
Vi utvecklar och optimerar varje lösning efter behov – med premiumprodukter från ledande globala leverantörer.
Våra system sparar vatten, ökar kontrollen och klarar höga krav på säkerhet och funktion.
Med hög servicegrad, snabba leveranser och stark lagerhållning är vi en pålitlig partner när det verkligen gäller.', 'sv', 'Heno AB är experter på sanitetslösningar för publika och krävande miljöer, med över 60 års erfarenhet av driftsäkra system.
Vi utvecklar och optimerar varje lösning efter behov – med premiumprodukter från ledande globala leverantörer.
Våra system sparar vatten, ökar kontrollen och klarar höga krav på säkerhet och funktion.
Med hög servicegrad, snabba leveranser och stark lagerhållning är vi en pålitlig partner när det verkligen gäller.'), 'https://www.heno.se', 'assets/images/exhibitors/nordbygg-2026-heno-ab.jpg'),
  ('nordbygg-2026-exhibitor-134382', 'nordbygg-2026', 'Herrljunga Terrazzo AB & Streetworks AB', 'C07:20', null, 'https://www.terrazzo.se', 'assets/images/exhibitors/nordbygg-2026-herrljunga-terrazzo-ab-streetworks-ab.jpg'),
  ('nordbygg-2026-exhibitor-136071', 'nordbygg-2026', 'Hestra PRO', 'B03:33', null, 'https://www.hestrapro.se', 'assets/images/exhibitors/nordbygg-2026-hestra-pro.jpg'),
  ('nordbygg-2026-exhibitor-139529', 'nordbygg-2026', 'HEWI Nordic', 'A08:18', jsonb_build_object('en', 'Since its foundation in 1929, HEWI has developed into a system provider for comprehensive solutions in the areas of building hardware, sanitary accessories, and accessible products. Over the past 95 years, the company has grown to become a leader in the field of accessibility and a recognised expert in system design. In line with Universal Design, the focus for HEWI is on people’s individual needs.', 'sv', 'Since its foundation in 1929, HEWI has developed into a system provider for comprehensive solutions in the areas of building hardware, sanitary accessories, and accessible products. Over the past 95 years, the company has grown to become a leader in the field of accessibility and a recognised expert in system design. In line with Universal Design, the focus for HEWI is on people’s individual needs.'), 'https://www.hewi.com', 'assets/images/exhibitors/nordbygg-2026-hewi-nordic.jpg'),
  ('nordbygg-2026-exhibitor-133999', 'nordbygg-2026', 'Heydi AB', 'C10:63', jsonb_build_object('en', 'Vi är stolta över att vara en norsk tillverkare av byggmaterial som levererar lösningar för både yrkesfolk och privatpersoner. Hos oss hittar du produkter som är utvecklade för att inspirera och ge varaktigt värde – oavsett om du arbetar med stora projekt eller skapar något unikt till hemmet.', 'sv', 'Vi är stolta över att vara en norsk tillverkare av byggmaterial som levererar lösningar för både yrkesfolk och privatpersoner. Hos oss hittar du produkter som är utvecklade för att inspirera och ge varaktigt värde – oavsett om du arbetar med stora projekt eller skapar något unikt till hemmet.'), 'https://www.heydi.se', 'assets/images/exhibitors/nordbygg-2026-heydi-ab.jpg'),
  ('nordbygg-2026-exhibitor-139510', 'nordbygg-2026', 'HiiL', 'C07:50', jsonb_build_object('en', 'På Hiil tillverkar vi hållbara nordiska träprodukter med ett tydligt fokus: bättre prestanda, lägre miljöpåverkan och ärliga materialval.

Vår kärnkompetens är förkolnat trä. Förkolningen skapar en naturligt skyddande yta som förbättrar väderbeständigheten och ger träet ett tidlöst, arkitektoniskt uttryck. Vi kombinerar traditionell nordisk kunskap med modern produktion för att leverera produkter som fungerar i verkliga utomhusmiljöer.

All tillverkning sker i Finland, nära vår råvara och nära våra viktigaste marknader. Denna lokala produktionsmodell ger oss hög kvalitetskontroll, korta leveranskedjor och pålitliga leveranser till Finland, Sverige och andra internationella marknader.

Hållbarhet är integrerad i vårt dagliga arbete:

vi maximerar råvarueffektiviteten och tar aktivt till vara sidoströmmar och överskottsmaterial av trä,
vi utvecklar produkter med lång livslängd och lågt underhållsbehov,
vi använder noggrant utvalda behandlingsoljor, inklusive svensk linolja,
och vi prioriterar biocidfria lösningar när det är möjligt.
För oss är ekologiskt ansvar inte ett marknadsföringsbudskap – det är ett praktiskt arbetssätt varje dag: smartare materialanvändning, renare kemi, lokal nordisk tillverkning och produkter som är byggda för att hålla länge.

Hiil betjänar arkitekter, byggföretag, återförsäljare och privatkunder som söker träprodukter med hög kvalitet, naturlig estetik, teknisk prestanda och ansvarsfull tillverkning.', 'sv', 'På Hiil tillverkar vi hållbara nordiska träprodukter med ett tydligt fokus: bättre prestanda, lägre miljöpåverkan och ärliga materialval.

Vår kärnkompetens är förkolnat trä. Förkolningen skapar en naturligt skyddande yta som förbättrar väderbeständigheten och ger träet ett tidlöst, arkitektoniskt uttryck. Vi kombinerar traditionell nordisk kunskap med modern produktion för att leverera produkter som fungerar i verkliga utomhusmiljöer.

All tillverkning sker i Finland, nära vår råvara och nära våra viktigaste marknader. Denna lokala produktionsmodell ger oss hög kvalitetskontroll, korta leveranskedjor och pålitliga leveranser till Finland, Sverige och andra internationella marknader.

Hållbarhet är integrerad i vårt dagliga arbete:

vi maximerar råvarueffektiviteten och tar aktivt till vara sidoströmmar och överskottsmaterial av trä,
vi utvecklar produkter med lång livslängd och lågt underhållsbehov,
vi använder noggrant utvalda behandlingsoljor, inklusive svensk linolja,
och vi prioriterar biocidfria lösningar när det är möjligt.
För oss är ekologiskt ansvar inte ett marknadsföringsbudskap – det är ett praktiskt arbetssätt varje dag: smartare materialanvändning, renare kemi, lokal nordisk tillverkning och produkter som är byggda för att hålla länge.

Hiil betjänar arkitekter, byggföretag, återförsäljare och privatkunder som söker träprodukter med hög kvalitet, naturlig estetik, teknisk prestanda och ansvarsfull tillverkning.'), 'https://hiil.fi/en/', 'assets/images/exhibitors/nordbygg-2026-hiil.jpg'),
  ('nordbygg-2026-exhibitor-140004', 'nordbygg-2026', 'Hikinoro Oy', 'C09:62', null, 'https://hikinoro.com', null),
  ('nordbygg-2026-exhibitor-135701', 'nordbygg-2026', 'HILTI', 'B02:21 (+1)', null, 'https://www.hilti.se', 'assets/images/exhibitors/nordbygg-2026-hilti.jpg'),
  ('nordbygg-2026-exhibitor-140100', 'nordbygg-2026', 'Hivolt Energy Systems', 'C03:41', jsonb_build_object('en', 'Hivolt’s all-in-one battery system with Volvo Penta battery packs makes sure everyone can power the construction site. From power tools to tower cranes and electric machines, our mobile battery system has all plugs available with a press on the button.', 'sv', 'Hivolt’s all-in-one battery system with Volvo Penta battery packs makes sure everyone can power the construction site. From power tools to tower cranes and electric machines, our mobile battery system has all plugs available with a press on the button.'), 'https://www.hivolt.nl', 'assets/images/exhibitors/nordbygg-2026-hivolt-energy-systems.jpg'),
  ('nordbygg-2026-exhibitor-136269', 'nordbygg-2026', 'Hogia', 'C02:31', jsonb_build_object('en', 'I över 45 år har Hogia utvecklat helhetslösningar inom ekonomi, lön och HR. Idag är alla Hogiasystem sammanhängande i en dynamisk miljö med smarta AI-baserade moduler. Det innebär att du kan skapa exakt det affärssystem som passar ditt företag.

Med Hogias ständiga fokus på att utveckla nya innovativa funktioner och lösningar är du redo att möta framtiden. Dessutom kan du vara trygg med att all information lagras och hanteras säkert – i molnet om du vill. Läs mer på hogia.se och hitta en lösning som passar just ditt företag.', 'sv', 'I över 45 år har Hogia utvecklat helhetslösningar inom ekonomi, lön och HR. Idag är alla Hogiasystem sammanhängande i en dynamisk miljö med smarta AI-baserade moduler. Det innebär att du kan skapa exakt det affärssystem som passar ditt företag.

Med Hogias ständiga fokus på att utveckla nya innovativa funktioner och lösningar är du redo att möta framtiden. Dessutom kan du vara trygg med att all information lagras och hanteras säkert – i molnet om du vill. Läs mer på hogia.se och hitta en lösning som passar just ditt företag.'), 'https://www.hogia.se', 'assets/images/exhibitors/nordbygg-2026-hogia.jpg'),
  ('nordbygg-2026-exhibitor-136398', 'nordbygg-2026', 'Hogstad Aluminium AB', 'C09:30', jsonb_build_object('en', 'I över 50 år har Hogstad Aluminium AB arbetat för god fastighetsekonomi och attraktiv boendemiljö – genom utveckling, tillverkning och montage av kvalitetsprodukter för balkonger. Vi är det äldsta företaget i balkongbranschen och vår erfarenhet kombinerat med långsiktigt tänkande borgar för tidsenliga lösningar med låga underhållskostnader både för nyproduktion och för renovering.', 'sv', 'I över 50 år har Hogstad Aluminium AB arbetat för god fastighetsekonomi och attraktiv boendemiljö – genom utveckling, tillverkning och montage av kvalitetsprodukter för balkonger. Vi är det äldsta företaget i balkongbranschen och vår erfarenhet kombinerat med långsiktigt tänkande borgar för tidsenliga lösningar med låga underhållskostnader både för nyproduktion och för renovering.'), 'https://www.hogstadaluminium.se', 'assets/images/exhibitors/nordbygg-2026-hogstad-aluminium-ab.jpg'),
  ('nordbygg-2026-exhibitor-137769', 'nordbygg-2026', 'Holm Trävaror / Kärnsund', 'C14:28', null, 'https://www.holmtravaror.se', 'assets/images/exhibitors/nordbygg-2026-holm-travaror-karnsund.jpg'),
  ('nordbygg-2026-exhibitor-140137', 'nordbygg-2026', 'HOLZEXPORT', 'C13:33', jsonb_build_object('en', 'Holzexport grundades 1992 som ett familjeföretag och har under sina drygt 30 år i branschen vuxit till ett av Polens största och snabbast växande företag inom tillverkning av två- och treskiktsgolv i trä.

Trä är vår passion, som vi har ägnat oss åt i många år. Vi levererar golv som uppfyller våra handelspartners högsta krav.', 'sv', 'Holzexport grundades 1992 som ett familjeföretag och har under sina drygt 30 år i branschen vuxit till ett av Polens största och snabbast växande företag inom tillverkning av två- och treskiktsgolv i trä.

Trä är vår passion, som vi har ägnat oss åt i många år. Vi levererar golv som uppfyller våra handelspartners högsta krav.'), 'https://www.holzexport.pl', 'assets/images/exhibitors/nordbygg-2026-holzexport.jpg'),
  ('nordbygg-2026-exhibitor-140019', 'nordbygg-2026', 'Hoovr File Navigator', 'AG:39', jsonb_build_object('en', 'Det snabbaste sättet att hitta dina dokument. Genom att låta muspekaren "hoovra" över skrivbordet så öppnas mappar och filer i fallande kolumner på skärmen utan extra klick. Ett fantastiskt produktivitetsverktyg som underlättar det dagliga arbetet då du slipper klicka runt och leta i mappar.', 'sv', 'Det snabbaste sättet att hitta dina dokument. Genom att låta muspekaren "hoovra" över skrivbordet så öppnas mappar och filer i fallande kolumner på skärmen utan extra klick. Ett fantastiskt produktivitetsverktyg som underlättar det dagliga arbetet då du slipper klicka runt och leta i mappar.'), 'https://www.hoovr.eu', 'assets/images/exhibitors/nordbygg-2026-hoovr-file-navigator.jpg'),
  ('nordbygg-2026-exhibitor-136403', 'nordbygg-2026', 'Horda Stans AB', 'A16:19', jsonb_build_object('en', '- Där innovation möter kvalitet

Vi strävar alltid efter att ligga steget före. Vår filosofi bygger på att aldrig stå still och för oss är stillestånd detsamma som tillbakagång. Denna framåtanda genomsyrar hela verksamheten och har hjälpt oss attrahera och behålla kompetent och engagerad personal, vår viktigaste resurs. Hos oss är utveckling och förändring inte bara en del av verksamheten – det är vårt DNA.

Som kund eller anställd på Horda Stans är du en del av ett företag där vi tillsammans skapar lösningar som verkligen gör skillnad. Vi är specialiserade på att utveckla och tillverka akustiklösningar, ljudabsorbenter, stomljudsdämpningar, kondensisoleringar, tätningar, packningar, laminerade produkter, möbelkomponenter och mycket mer, skräddarsytt efter dina behov.

Med djup materialkunskap, en flexibel produktion och ett team av lojala och erfarna medarbetare levererar vi kundunika lösningar till fordonsindustrin, verkstadsindustrin och möbelindustrin. Vår moderna maskinpark, med stansar, pressar, sågar, skärmaskiner och lamineringsutrustning, gör att vi kan möta de mest krävande produktionsbehoven med precision och kvalitet.', 'sv', '- Där innovation möter kvalitet

Vi strävar alltid efter att ligga steget före. Vår filosofi bygger på att aldrig stå still och för oss är stillestånd detsamma som tillbakagång. Denna framåtanda genomsyrar hela verksamheten och har hjälpt oss attrahera och behålla kompetent och engagerad personal, vår viktigaste resurs. Hos oss är utveckling och förändring inte bara en del av verksamheten – det är vårt DNA.

Som kund eller anställd på Horda Stans är du en del av ett företag där vi tillsammans skapar lösningar som verkligen gör skillnad. Vi är specialiserade på att utveckla och tillverka akustiklösningar, ljudabsorbenter, stomljudsdämpningar, kondensisoleringar, tätningar, packningar, laminerade produkter, möbelkomponenter och mycket mer, skräddarsytt efter dina behov.

Med djup materialkunskap, en flexibel produktion och ett team av lojala och erfarna medarbetare levererar vi kundunika lösningar till fordonsindustrin, verkstadsindustrin och möbelindustrin. Vår moderna maskinpark, med stansar, pressar, sågar, skärmaskiner och lamineringsutrustning, gör att vi kan möta de mest krävande produktionsbehoven med precision och kvalitet.'), 'https://www.hordastans.se', 'assets/images/exhibitors/nordbygg-2026-horda-stans-ab.jpg'),
  ('nordbygg-2026-exhibitor-138798', 'nordbygg-2026', 'HPJ Garden AB', 'EÖ:34', jsonb_build_object('en', 'En komplett leverantör för er som är verksamma inom trädgårdsanläggning, trädplantering och trädgårdsskötsel.', 'sv', 'En komplett leverantör för er som är verksamma inom trädgårdsanläggning, trädplantering och trädgårdsskötsel.'), 'https://www.hpjgarden.se', 'assets/images/exhibitors/nordbygg-2026-hpj-garden-ab.jpg'),
  ('nordbygg-2026-exhibitor-134820', 'nordbygg-2026', 'HUBER Technology Nordic AB', 'C14:24', jsonb_build_object('en', 'HUBER – Säker åtkomst
På Nordbygg visar vi vårt sortiment inom säker åtkomst – utvecklat för vatten- och avloppsanläggningar.
Vi erbjuder hållbara och säkra lösningar i rostfritt stål, med fokus på lång livslängd och minimalt underhåll. I vårt sortiment ingår bland annat manluckor, trycktäta dörrar, ventilationsgaller, säkerhetsstegar och ingångsstöd.
Alla produkter tillverkas i vår moderna fabrik med den senaste tekniken, där processerna är optimerade för just rostfritt stål. Det ger hög kvalitet och pålitlig funktion i många år.
Vi anpassar lösningar efter kundens behov och är certifierade enligt ISO 9001 och ISO 14001.
Välkommen att träffa oss och upptäcka säkra lösningar i rostfritt stål!', 'sv', 'HUBER – Säker åtkomst
På Nordbygg visar vi vårt sortiment inom säker åtkomst – utvecklat för vatten- och avloppsanläggningar.
Vi erbjuder hållbara och säkra lösningar i rostfritt stål, med fokus på lång livslängd och minimalt underhåll. I vårt sortiment ingår bland annat manluckor, trycktäta dörrar, ventilationsgaller, säkerhetsstegar och ingångsstöd.
Alla produkter tillverkas i vår moderna fabrik med den senaste tekniken, där processerna är optimerade för just rostfritt stål. Det ger hög kvalitet och pålitlig funktion i många år.
Vi anpassar lösningar efter kundens behov och är certifierade enligt ISO 9001 och ISO 14001.
Välkommen att träffa oss och upptäcka säkra lösningar i rostfritt stål!'), 'https://www.hubersverige.se', 'assets/images/exhibitors/nordbygg-2026-huber-technology-nordic-ab.jpg'),
  ('nordbygg-2026-exhibitor-137861', 'nordbygg-2026', 'Hubexo Sweden', 'C04:20', jsonb_build_object('en', 'Vi sammanför byggbranschen
Vi är världsledande på att leverera viktiga datadrivna insikter till yrkesverksamma inom byggbranschen.', 'sv', 'Vi sammanför byggbranschen
Vi är världsledande på att leverera viktiga datadrivna insikter till yrkesverksamma inom byggbranschen.'), 'https://www.byggfakta.se', 'assets/images/exhibitors/nordbygg-2026-hubexo-sweden.jpg'),
  ('nordbygg-2026-exhibitor-139554', 'nordbygg-2026', 'Hultafors', 'B01:31 (+1)', jsonb_build_object('en', 'Hultafors erbjuder ett brett sortiment av handverktyg utvecklade för professionella hantverkare. I över ett sekel har vi tagit fram lösningar i nära samarbete med dem som använder verktygen varje dag. Vi designar för bästa möjliga funktionalitet, kvalitet och precision så att våra användare kan fokusera på sin uppgift.', 'sv', 'Hultafors erbjuder ett brett sortiment av handverktyg utvecklade för professionella hantverkare. I över ett sekel har vi tagit fram lösningar i nära samarbete med dem som använder verktygen varje dag. Vi designar för bästa möjliga funktionalitet, kvalitet och precision så att våra användare kan fokusera på sin uppgift.'), 'https://www.hultafors.com', 'assets/images/exhibitors/nordbygg-2026-hultafors.jpg'),
  ('nordbygg-2026-exhibitor-138273', 'nordbygg-2026', 'Hultafors Group AB', 'B01:31 (+1)', null, 'https://www.hultaforsgroup.com', null),
  ('nordbygg-2026-exhibitor-134726', 'nordbygg-2026', 'Hunton Fiber AB', 'C06:41', jsonb_build_object('en', 'Hunton är en av Nordens ledande producenter av träfiberbaserade byggmaterial. Vi skyddar ditt hus mot kyla, vind och ljud.', 'sv', 'Hunton är en av Nordens ledande producenter av träfiberbaserade byggmaterial. Vi skyddar ditt hus mot kyla, vind och ljud.'), 'https://www.hunton.se', 'assets/images/exhibitors/nordbygg-2026-hunton-fiber-ab.jpg'),
  ('nordbygg-2026-exhibitor-139199', 'nordbygg-2026', 'Huntonit', 'C04:11', jsonb_build_object('en', 'Huntonit erbjuder träfiberpaneler, tillverkade i Norge av enbart trä och vatten helt utan tillsatt lim eller miljöfarliga ämnen. Våra färdigmålade tak- och vägglösningar rekommenderas av det norska Astma- och Allergiförbundet och ger ett snabbt och bra slutresultat.

Besök oss på Nordbygg i monter CO4:11 för att se hur vi kombinerar överlägsen inomhusmiljö med effektivt byggande och tidlös design.', 'sv', 'Huntonit erbjuder träfiberpaneler, tillverkade i Norge av enbart trä och vatten helt utan tillsatt lim eller miljöfarliga ämnen. Våra färdigmålade tak- och vägglösningar rekommenderas av det norska Astma- och Allergiförbundet och ger ett snabbt och bra slutresultat.

Besök oss på Nordbygg i monter CO4:11 för att se hur vi kombinerar överlägsen inomhusmiljö med effektivt byggande och tidlös design.'), 'https://www.huntonit.se', 'assets/images/exhibitors/nordbygg-2026-huntonit.jpg'),
  ('nordbygg-2026-exhibitor-135334', 'nordbygg-2026', 'Husqvarna Construction Products', 'EH:17 (+1)', jsonb_build_object('en', 'HUSQVARNA CONSTRUCTION.
EXPECT MORE.

Husqvarna Construction är en global ledare inom utrustning och diamantverktyg för bygg- och anläggningsbranschen. Som affärspartner kan du förvänta dig mer – mer support, fler smarta idéer och ett större fokus på arbetsmiljö och hållbarhet. Ju mer vi investerar, desto mer får du ut.

På Nordbygg visar vi ett brett urval ur hela vårt sortiment, inklusive flera nyheter. Här hittar du ytbearbetningsutrustning som slipar, fräsar, blästrar och strippers, tillsammans med våra nya framåtgående vibroplattor och betongvibratorer. Vi visar även kapmaskiner (batteri- och bensindrivna), vägg- och golvsågar samt borrmotorer och borrstativ – tillsammans med effektiva lösningar för dammhantering.

En av årets största nyheter är Autogrinder™, världens första autonoma golvslipmaskin, som du kan uppleva i vår entrémonter EH:17. Autogrinder™ 8 D är en självgående, planetarisk maskin som kombinerar avancerad navigation, sensorer och smarta algoritmer för att själv analysera underlaget, optimera arbetsflödet och leverera jämna, pålitliga resultat – samtidigt som du frigör tid till annat.

Varmt välkomna att besöka vår monter i entrén (EH:17) och i mässhallen (B07:03).', 'sv', 'HUSQVARNA CONSTRUCTION.
EXPECT MORE.

Husqvarna Construction är en global ledare inom utrustning och diamantverktyg för bygg- och anläggningsbranschen. Som affärspartner kan du förvänta dig mer – mer support, fler smarta idéer och ett större fokus på arbetsmiljö och hållbarhet. Ju mer vi investerar, desto mer får du ut.

På Nordbygg visar vi ett brett urval ur hela vårt sortiment, inklusive flera nyheter. Här hittar du ytbearbetningsutrustning som slipar, fräsar, blästrar och strippers, tillsammans med våra nya framåtgående vibroplattor och betongvibratorer. Vi visar även kapmaskiner (batteri- och bensindrivna), vägg- och golvsågar samt borrmotorer och borrstativ – tillsammans med effektiva lösningar för dammhantering.

En av årets största nyheter är Autogrinder™, världens första autonoma golvslipmaskin, som du kan uppleva i vår entrémonter EH:17. Autogrinder™ 8 D är en självgående, planetarisk maskin som kombinerar avancerad navigation, sensorer och smarta algoritmer för att själv analysera underlaget, optimera arbetsflödet och leverera jämna, pålitliga resultat – samtidigt som du frigör tid till annat.

Varmt välkomna att besöka vår monter i entrén (EH:17) och i mässhallen (B07:03).'), 'https://www.husqvarnaconstruction.com/se', 'assets/images/exhibitors/nordbygg-2026-husqvarna-construction-products.jpg'),
  ('nordbygg-2026-exhibitor-137628', 'nordbygg-2026', 'HUVUD Prefab', 'C10:72', jsonb_build_object('en', 'HUVUD Prefab, together with our engineering partner MALAGRIS, offers a complete wall solution for modern construction.

We combine:
– efficient prefab wall production (HUVUD)
– structural design and engineering (MALAGRIS)

This partnership allows us to deliver a fully integrated system – from design to ready-to-install wall elements.

Our solution is focused on:
– faster construction time
– reduced on-site labor
– consistent quality
– sustainable materials

We are currently expanding to the Swedish market and are looking for partners, developers, and contractors interested in smarter building solutions.', 'sv', 'HUVUD Prefab, together with our engineering partner MALAGRIS, offers a complete wall solution for modern construction.

We combine:
– efficient prefab wall production (HUVUD)
– structural design and engineering (MALAGRIS)

This partnership allows us to deliver a fully integrated system – from design to ready-to-install wall elements.

Our solution is focused on:
– faster construction time
– reduced on-site labor
– consistent quality
– sustainable materials

We are currently expanding to the Swedish market and are looking for partners, developers, and contractors interested in smarter building solutions.'), 'https://huvud.eu', 'assets/images/exhibitors/nordbygg-2026-huvud-prefab.jpg'),
  ('nordbygg-2026-exhibitor-134808', 'nordbygg-2026', 'Hydab Scandinavia AB', 'A20:17', jsonb_build_object('en', 'Hydab en heltäckande grossist av slangar, slangklämmor, kopplingar och gummiprodukter.
Vi anpassar våra produkter efter kundens behov.
Från vårt stora lager i Halmstad kan vi erbjuda ett brett sortiment av produkter för:

Ventilation: Slang, isolerstrumpor, ATLAS-spjällbox, ALFO-Foder, ljuddämpare, don, irisspjäll, klämmor
Hetluft och avgaser: Slang för temperaturer upp till 1100 grader
Svetsning: Utsug, svetsslangar
Skyddsslang: För slangar och kablar
Vitvaror & sanitet: Gasspisslang, in- och utloppsslang, torkskåpsslang
Vätsketransport: Vatten och andra vätskor
Dammsugning: Dammsugartillbehör och slang
Materialtransport: Av slitande material som spån, pellets och lösull
Tätning: Kundanpassade packningar (ex sanitet), profiler & lister (ex fönster och dörrar)
Gummitillbehör: Formsprutade, formgjutna och extruderade gummiprodukter.
Tryckluft: Slangar och kopplingar
Brand: Brandarmaturer, brandposter och brandslangar
Fästdon: Slangklämmor och kopplingar i galvat-, rostfritt- eller syrafastmaterial', 'sv', 'Hydab en heltäckande grossist av slangar, slangklämmor, kopplingar och gummiprodukter.
Vi anpassar våra produkter efter kundens behov.
Från vårt stora lager i Halmstad kan vi erbjuda ett brett sortiment av produkter för:

Ventilation: Slang, isolerstrumpor, ATLAS-spjällbox, ALFO-Foder, ljuddämpare, don, irisspjäll, klämmor
Hetluft och avgaser: Slang för temperaturer upp till 1100 grader
Svetsning: Utsug, svetsslangar
Skyddsslang: För slangar och kablar
Vitvaror & sanitet: Gasspisslang, in- och utloppsslang, torkskåpsslang
Vätsketransport: Vatten och andra vätskor
Dammsugning: Dammsugartillbehör och slang
Materialtransport: Av slitande material som spån, pellets och lösull
Tätning: Kundanpassade packningar (ex sanitet), profiler & lister (ex fönster och dörrar)
Gummitillbehör: Formsprutade, formgjutna och extruderade gummiprodukter.
Tryckluft: Slangar och kopplingar
Brand: Brandarmaturer, brandposter och brandslangar
Fästdon: Slangklämmor och kopplingar i galvat-, rostfritt- eller syrafastmaterial'), 'https://www.hydab.se', 'assets/images/exhibitors/nordbygg-2026-hydab-scandinavia-ab.jpg'),
  ('nordbygg-2026-exhibitor-137304', 'nordbygg-2026', 'Hydrun (tidigare HL Hydronics)', 'A05:19', jsonb_build_object('en', 'Hydrun® (previously HL Hydronics) supplies innovative and high quality products for heating and cooling systems (HVAC).
Focus areas:
Pressurisation
Degassing
Filtration', 'sv', 'Hydrun® (previously HL Hydronics) supplies innovative and high quality products for heating and cooling systems (HVAC).
Focus areas:
Pressurisation
Degassing
Filtration'), 'https://www.hydrun.se', 'assets/images/exhibitors/nordbygg-2026-hydrun-tidigare-hl-hydronics.jpg'),
  ('nordbygg-2026-exhibitor-140136', 'nordbygg-2026', 'Hållbart Byggande', 'C19:34', jsonb_build_object('en', 'En av Sveriges ledande medier inom bygg och fastighet - landets i särklass största mediekanal om hållbart och klimatsmart byggande. Räckvidd: ca 60 000 yrkespersoner i bygg- och fastighetssektor, ca 40 000 prenumeranter.', 'sv', 'En av Sveriges ledande medier inom bygg och fastighet - landets i särklass största mediekanal om hållbart och klimatsmart byggande. Räckvidd: ca 60 000 yrkespersoner i bygg- och fastighetssektor, ca 40 000 prenumeranter.'), 'https://hallbartbyggande.com', 'assets/images/exhibitors/nordbygg-2026-hallbart-byggande.jpg'),
  ('nordbygg-2026-exhibitor-133981', 'nordbygg-2026', 'Häfla Bruks AB', 'C19:32', jsonb_build_object('en', 'Idag är Häfla Bruks en ledande leverantör av stål-, plåt- och metallprodukter med egen modern tillverkning och varmförzinkning. Vårt breda sortiment omfattar allt från sträckmetall, gallerdurk, räcken, trappor och ramper till plåtbearbetnings- och laserskärningstjänster. Med gedigen erfarenhet borgar Häfla Bruks för hållbara kvalitetsprodukter och en specialistkompetens utöver det vanliga.

Välkommen till Häfla Bruks AB', 'sv', 'Idag är Häfla Bruks en ledande leverantör av stål-, plåt- och metallprodukter med egen modern tillverkning och varmförzinkning. Vårt breda sortiment omfattar allt från sträckmetall, gallerdurk, räcken, trappor och ramper till plåtbearbetnings- och laserskärningstjänster. Med gedigen erfarenhet borgar Häfla Bruks för hållbara kvalitetsprodukter och en specialistkompetens utöver det vanliga.

Välkommen till Häfla Bruks AB'), 'https://www.hafla.se', 'assets/images/exhibitors/nordbygg-2026-hafla-bruks-ab.jpg'),
  ('nordbygg-2026-exhibitor-133985', 'nordbygg-2026', 'HögforsGST', 'A10:10', jsonb_build_object('en', 'Vi har utvecklat värmesystem och hybridlösningar i över 20 år. I en värld med snabbt föränderliga behov av smartare energianvändning, är vi den partner du kan lita på. Vårt mål är att erbjuda våra kunder kloka och anpassningsbara system för att använda energi så smart som möjligt – både för vår miljö och din budget.', 'sv', 'Vi har utvecklat värmesystem och hybridlösningar i över 20 år. I en värld med snabbt föränderliga behov av smartare energianvändning, är vi den partner du kan lita på. Vårt mål är att erbjuda våra kunder kloka och anpassningsbara system för att använda energi så smart som möjligt – både för vår miljö och din budget.'), 'https://www.hogforsgst.com/sv', 'assets/images/exhibitors/nordbygg-2026-hogforsgst.jpg'),
  ('nordbygg-2026-exhibitor-134448', 'nordbygg-2026', 'Hörby Bruk', 'B08:31', jsonb_build_object('en', 'Hörby Bruk är ett välkänt varumärke och vi är sedan många år tillbaka marknadsledande på skottkärror i Sverige. Vi är också en ledande producent i Norden på lekredskap för den privata trädgården. Och flera av våra produkter har genom åren blivit välkända klassiker. En anledning till detta är att vi konsekvent kombinerar lång svensk hantverkstradition med modern teknik i vår produktion. Resultatet är en unik kvalitet och ergonomi som inte bara syns utan som också upplevs, år efter år, från generation till generation. Vi är mycket stolta över att föra svensk hantverkstradition vidare in i framtiden.', 'sv', 'Hörby Bruk är ett välkänt varumärke och vi är sedan många år tillbaka marknadsledande på skottkärror i Sverige. Vi är också en ledande producent i Norden på lekredskap för den privata trädgården. Och flera av våra produkter har genom åren blivit välkända klassiker. En anledning till detta är att vi konsekvent kombinerar lång svensk hantverkstradition med modern teknik i vår produktion. Resultatet är en unik kvalitet och ergonomi som inte bara syns utan som också upplevs, år efter år, från generation till generation. Vi är mycket stolta över att föra svensk hantverkstradition vidare in i framtiden.'), 'https://www.horbybruk.se', 'assets/images/exhibitors/nordbygg-2026-horby-bruk.jpg'),
  ('nordbygg-2026-exhibitor-134466', 'nordbygg-2026', 'iCell', 'C06:40', jsonb_build_object('en', 'Svenskproducerad isolering från naturens egna resurser

iCell förädlar återvunna pappers- och kartongfibrer till moderna, klimatsmarta isoleringsprodukter för diffusionsöppet byggande.

Genom innovativ teknik och energieffektiv produktion i Älvdalen skapar vi isolering med negativ klimatpåverkan, hög prestanda.
Våra isolerprodukter binder mer koldioxid än de kräver att tillverka – ett konkret bidrag till ett mer hållbart byggande. Med fokus på kvalitet, cirkularitet och lokal produktion erbjuder iCell ett tryggt, svenskt alternativ för framtidens isoleringslösningar.', 'sv', 'Svenskproducerad isolering från naturens egna resurser

iCell förädlar återvunna pappers- och kartongfibrer till moderna, klimatsmarta isoleringsprodukter för diffusionsöppet byggande.

Genom innovativ teknik och energieffektiv produktion i Älvdalen skapar vi isolering med negativ klimatpåverkan, hög prestanda.
Våra isolerprodukter binder mer koldioxid än de kräver att tillverka – ett konkret bidrag till ett mer hållbart byggande. Med fokus på kvalitet, cirkularitet och lokal produktion erbjuder iCell ett tryggt, svenskt alternativ för framtidens isoleringslösningar.'), 'https://www.icell.se', 'assets/images/exhibitors/nordbygg-2026-icell.jpg'),
  ('nordbygg-2026-exhibitor-134674', 'nordbygg-2026', 'iFenix affärssystem', 'C01:12', null, 'https://www.genesis.se', 'assets/images/exhibitors/nordbygg-2026-ifenix-affarssystem.jpg'),
  ('nordbygg-2026-exhibitor-133983', 'nordbygg-2026', 'IMI', 'A03:18', jsonb_build_object('en', 'IMI Climate Control, tidigare IMI Hydronic Engineering, är en ledande leverantör inom energioptimering
av framtidens klimatsmarta byggnader.', 'sv', 'IMI Climate Control, tidigare IMI Hydronic Engineering, är en ledande leverantör inom energioptimering
av framtidens klimatsmarta byggnader.'), 'https://climatecontrol.imiplc.com/sv-se', 'assets/images/exhibitors/nordbygg-2026-imi.jpg'),
  ('nordbygg-2026-exhibitor-138767', 'nordbygg-2026', 'INCHEM POLONIA', 'C03:71', jsonb_build_object('en', 'Inchem Polonia är en europeisk tillverkare av pigmentpastor och avancerad byggkemi.
Sedan 1988 har vi levererat miljömedvetna och högpresterande lösningar för professionell och industriell användning, betrodda på över 30 exportmarknader.

På Nordbygg presenterar vi våra huvudsakliga produktlinjer:

lösningar för betong och mikrocement

träskyddssystem

produkter för badrums- och ytrenovering

Vårt eget laboratorium möjliggör skräddarsydd färgformulering, vilket säkerställer stabila och repeterbara färgresultat, produktionsflexibilitet samt tillförlitligt tekniskt stöd för varje samarbetspartner.

Europeisk kvalitet. Nordisk pålitlighet.
Färg med samvete.', 'sv', 'Inchem Polonia är en europeisk tillverkare av pigmentpastor och avancerad byggkemi.
Sedan 1988 har vi levererat miljömedvetna och högpresterande lösningar för professionell och industriell användning, betrodda på över 30 exportmarknader.

På Nordbygg presenterar vi våra huvudsakliga produktlinjer:

lösningar för betong och mikrocement

träskyddssystem

produkter för badrums- och ytrenovering

Vårt eget laboratorium möjliggör skräddarsydd färgformulering, vilket säkerställer stabila och repeterbara färgresultat, produktionsflexibilitet samt tillförlitligt tekniskt stöd för varje samarbetspartner.

Europeisk kvalitet. Nordisk pålitlighet.
Färg med samvete.'), 'https://www.inchem.pl', 'assets/images/exhibitors/nordbygg-2026-inchem-polonia.jpg'),
  ('nordbygg-2026-exhibitor-135468', 'nordbygg-2026', 'Indol AB', 'A07:16', null, 'https://www.indol.se', null),
  ('nordbygg-2026-exhibitor-133996', 'nordbygg-2026', 'INR', 'A06:14', jsonb_build_object('en', 'På INR förenas vi i den gemensamma passionen för personliga lösningar i tidlös skandinavisk design för hemmets viktigaste rum. Tillsammans strävar vi efter att skapa lösningar som ska göra mer än att inreda rum – de ska också beröra dina sinnen genom att spegla just din personlighet och dina behov: A bathroom crafted with heart. Made to fit you.', 'sv', 'På INR förenas vi i den gemensamma passionen för personliga lösningar i tidlös skandinavisk design för hemmets viktigaste rum. Tillsammans strävar vi efter att skapa lösningar som ska göra mer än att inreda rum – de ska också beröra dina sinnen genom att spegla just din personlighet och dina behov: A bathroom crafted with heart. Made to fit you.'), 'https://inr.se', 'assets/images/exhibitors/nordbygg-2026-inr.jpg'),
  ('nordbygg-2026-exhibitor-136821', 'nordbygg-2026', 'Installatörsföretagen', 'A08:21', jsonb_build_object('en', 'Hos Installatörsföretagen samlas företag som gör världen mer hållbar genom sitt arbete. Det är våra drygt 4 500 medlemsföretag med sina 65 000 medarbetare som dagligen jobbar för att potentialen inom elektrifiering och energieffektivisering ska tas tillvara, för Sveriges bästa. Vi finns i deras vardag och jobbar för deras framtid. Vi företräder också branschen i debatten och tryggar morgondagens arbetskraft.

Tillsammans skapar vi förutsättningarna för ett modernt, klimatsmart och hållbart Sverige. Det är vi som gör det möjligt.', 'sv', 'Hos Installatörsföretagen samlas företag som gör världen mer hållbar genom sitt arbete. Det är våra drygt 4 500 medlemsföretag med sina 65 000 medarbetare som dagligen jobbar för att potentialen inom elektrifiering och energieffektivisering ska tas tillvara, för Sveriges bästa. Vi finns i deras vardag och jobbar för deras framtid. Vi företräder också branschen i debatten och tryggar morgondagens arbetskraft.

Tillsammans skapar vi förutsättningarna för ett modernt, klimatsmart och hållbart Sverige. Det är vi som gör det möjligt.'), 'https://www.in.se', 'assets/images/exhibitors/nordbygg-2026-installatorsforetagen.jpg'),
  ('nordbygg-2026-exhibitor-135335', 'nordbygg-2026', 'InventiAir', 'A21:14', jsonb_build_object('en', 'InventiAir startades ur en ambition att ge människor den bästa möjliga inomhusluften. All forskning, utveckling och produktion är baserad i Sverige och vår unika ventilationsteknik där du använder luften rätt kommer garanterat göra livet enklare för dig.

Vi utvecklar och tillverkar ventilationsprodukter som kyler, värmer och ventilerar alla typer av lokaler. Tekniken skapar renare luft, kräver mindre mängd energi samt är ett hållbart alternativ.', 'sv', 'InventiAir startades ur en ambition att ge människor den bästa möjliga inomhusluften. All forskning, utveckling och produktion är baserad i Sverige och vår unika ventilationsteknik där du använder luften rätt kommer garanterat göra livet enklare för dig.

Vi utvecklar och tillverkar ventilationsprodukter som kyler, värmer och ventilerar alla typer av lokaler. Tekniken skapar renare luft, kräver mindre mängd energi samt är ett hållbart alternativ.'), 'https://www.inventiair.se', 'assets/images/exhibitors/nordbygg-2026-inventiair.jpg'),
  ('nordbygg-2026-exhibitor-139154', 'nordbygg-2026', 'Invitrea by GSAB', 'C09:31', jsonb_build_object('en', 'GSAB tillverkar och levererar duschväggar, glasväggar, räcken och andra relaterade produkter till glasbranschen, byggbranschen, aktörer inom fastighetsutveckling samt till våra väl utvalda återförsäljare. Dessa produkter erbjuds inom produktkategorierna Room, Railing, Bath, Exterior och Interior.

Invitrea – Våra egna produkter:

Invitrea Room – Glasväggar och dörrar för interiöra miljöer
Invitrea Railing – Räcken för interiöra och exteriöra miljöer
Invitrea Bath – Bastu och duschväggar
Invitrea Exterior – Uterum & skärmtak
Invitrea Interior – Skjutdörrar för garderober

Elegant och exklusiv design, snabbmonterat och med möjlighet till kundanpassade mått – det är det vi vill uppnå med våra produkter från Invitrea.

Mer info om vår verksamhet på gsab.se och invitrea.com.', 'sv', 'GSAB tillverkar och levererar duschväggar, glasväggar, räcken och andra relaterade produkter till glasbranschen, byggbranschen, aktörer inom fastighetsutveckling samt till våra väl utvalda återförsäljare. Dessa produkter erbjuds inom produktkategorierna Room, Railing, Bath, Exterior och Interior.

Invitrea – Våra egna produkter:

Invitrea Room – Glasväggar och dörrar för interiöra miljöer
Invitrea Railing – Räcken för interiöra och exteriöra miljöer
Invitrea Bath – Bastu och duschväggar
Invitrea Exterior – Uterum & skärmtak
Invitrea Interior – Skjutdörrar för garderober

Elegant och exklusiv design, snabbmonterat och med möjlighet till kundanpassade mått – det är det vi vill uppnå med våra produkter från Invitrea.

Mer info om vår verksamhet på gsab.se och invitrea.com.'), 'https://gsab.se', null),
  ('nordbygg-2026-exhibitor-139699', 'nordbygg-2026', 'INWOCO', 'C06:50', jsonb_build_object('en', 'Inwocoväggen är en hybrid mellan regelväggen och KL-väggen och fungerar både som bärande vägg för trästommar och som utfackningsvägg för stål- och betongstommar. Själva modulerna anpassas efter projektets krav och tillverkas i vår fabrik, där de förses med tätskikt, luftspalt och installationsutrymme.

Stomsystem eller väggarna levereras väderskyddade och i sekvens direkt till byggarbetsplatsen, där de snabbt och enkelt monteras. Konstruktionen ger hög lastkapacitet, lågt U-värde och möjliggör återbruk, vilket säkerställer minimal miljöpåverkan, korta byggtider och hög kvalitet genom hela kedjan.', 'sv', 'Inwocoväggen är en hybrid mellan regelväggen och KL-väggen och fungerar både som bärande vägg för trästommar och som utfackningsvägg för stål- och betongstommar. Själva modulerna anpassas efter projektets krav och tillverkas i vår fabrik, där de förses med tätskikt, luftspalt och installationsutrymme.

Stomsystem eller väggarna levereras väderskyddade och i sekvens direkt till byggarbetsplatsen, där de snabbt och enkelt monteras. Konstruktionen ger hög lastkapacitet, lågt U-värde och möjliggör återbruk, vilket säkerställer minimal miljöpåverkan, korta byggtider och hög kvalitet genom hela kedjan.'), 'https://www.inwoco.se', 'assets/images/exhibitors/nordbygg-2026-inwoco.jpg'),
  ('nordbygg-2026-exhibitor-134459', 'nordbygg-2026', 'ISOCELL GmbH & Co KG', 'C02:60', jsonb_build_object('en', 'ISOCELL – utvecklar och marknadsför lösningar baserat på cellulosabaserad lösullsisolering och produkter för diffusionsöppet byggande.
Vi är också marknadsledande avseende installationslösningar av lösull med en bred portfölj av installationsmaskiner och hela system för automatisk installation av lösull för PREFAB-industrin.
Genom vår breda kompetens intar företaget en unik expertposition i Europa.

Med nästan 30 års erfarenhet erbjuder vi innovativa lösningar för nybyggnation, tillbyggnad och renovering. Produkterna i ISOCELL produktsortimentet är anpassade till varandra för att bilda effektiva klimatskydd där vind, hetta och kyla hålls utanför huset.', 'sv', 'ISOCELL – utvecklar och marknadsför lösningar baserat på cellulosabaserad lösullsisolering och produkter för diffusionsöppet byggande.
Vi är också marknadsledande avseende installationslösningar av lösull med en bred portfölj av installationsmaskiner och hela system för automatisk installation av lösull för PREFAB-industrin.
Genom vår breda kompetens intar företaget en unik expertposition i Europa.

Med nästan 30 års erfarenhet erbjuder vi innovativa lösningar för nybyggnation, tillbyggnad och renovering. Produkterna i ISOCELL produktsortimentet är anpassade till varandra för att bilda effektiva klimatskydd där vind, hetta och kyla hålls utanför huset.'), 'https://www.isocell.se', 'assets/images/exhibitors/nordbygg-2026-isocell-gmbh-co-kg.jpg'),
  ('nordbygg-2026-exhibitor-138446', 'nordbygg-2026', 'Isodrän AB', 'C05:61', null, 'https://www.isodran.com', null),
  ('nordbygg-2026-exhibitor-139875', 'nordbygg-2026', 'Isomester AS', 'AG:106', null, 'https://Isomester.no', null),
  ('nordbygg-2026-exhibitor-137117', 'nordbygg-2026', 'Isozero', 'C08:52', jsonb_build_object('en', 'Isozero arbetar med platsproducerad cellulär betong för lättfyllnad, isolering och nivellering i infrastruktur- och byggprojekt.
Våra lösningar minskar schakt, transporter och materialåtgång, vilket ger både tydliga miljövinster och ekonomiska besparingar, samtidigt som vi hanterar sättningar, låg bärighet och komplex geometri på ett effektivt sätt.
Sällan sparar man pengar just genom att välja det mer miljösmarta alternativet – men det är just där Isozero kommer in.', 'sv', 'Isozero arbetar med platsproducerad cellulär betong för lättfyllnad, isolering och nivellering i infrastruktur- och byggprojekt.
Våra lösningar minskar schakt, transporter och materialåtgång, vilket ger både tydliga miljövinster och ekonomiska besparingar, samtidigt som vi hanterar sättningar, låg bärighet och komplex geometri på ett effektivt sätt.
Sällan sparar man pengar just genom att välja det mer miljösmarta alternativet – men det är just där Isozero kommer in.'), 'https://isozero.se', 'assets/images/exhibitors/nordbygg-2026-isozero.jpg'),
  ('nordbygg-2026-exhibitor-139460', 'nordbygg-2026', 'iTOOLS', 'B04:30', jsonb_build_object('en', 'År 2004 kunde de första danska snickarna börja lägga trägolv stående med vår golvhammare. Idag är hantverkare i 45 länder effektivare och hälsosammare tack vare innovativa och intelligenta verktyg "Made in Odder".

Hösten 2023 köpte vi företaget ESKIMO. Företaget grundades 1926 och är en veritabel institution inom murningsbranschen. ESKIMO i Herning är den sista återstående fabriken i hela Skandinavien som producerar murverktyg.

Vår entusiasm och starka kundrelationer hemma och utomlands har gjort att tillverkare av verktyg, maskiner och personlig skyddsutrustning från bland annat Australien, Singapore, USA, Schweiz, Holland och Tyskland väljer iTOOLS som sin distributör i Danmark, Skandinavien och i vissa fall i hela Europa.

iTOOLS är den skandinaviska importören av
- FENTO knäskydd
- CleanSpace aktivt andningsskydd
- AIR+ engångsmask med ventilator
- PerfectPro jobbradio', 'sv', 'År 2004 kunde de första danska snickarna börja lägga trägolv stående med vår golvhammare. Idag är hantverkare i 45 länder effektivare och hälsosammare tack vare innovativa och intelligenta verktyg "Made in Odder".

Hösten 2023 köpte vi företaget ESKIMO. Företaget grundades 1926 och är en veritabel institution inom murningsbranschen. ESKIMO i Herning är den sista återstående fabriken i hela Skandinavien som producerar murverktyg.

Vår entusiasm och starka kundrelationer hemma och utomlands har gjort att tillverkare av verktyg, maskiner och personlig skyddsutrustning från bland annat Australien, Singapore, USA, Schweiz, Holland och Tyskland väljer iTOOLS som sin distributör i Danmark, Skandinavien och i vissa fall i hela Europa.

iTOOLS är den skandinaviska importören av
- FENTO knäskydd
- CleanSpace aktivt andningsskydd
- AIR+ engångsmask med ventilator
- PerfectPro jobbradio'), 'https://www.itools.dk', 'assets/images/exhibitors/nordbygg-2026-itools.jpg'),
  ('nordbygg-2026-exhibitor-134958', 'nordbygg-2026', 'IV Produkt AB', 'A15:14', null, 'https://www.ivprodukt.se', 'assets/images/exhibitors/nordbygg-2026-iv-produkt-ab.jpg'),
  ('nordbygg-2026-exhibitor-139158', 'nordbygg-2026', 'IVL', 'EH:15', null, 'https://www.ivl.se', null),
  ('nordbygg-2026-exhibitor-137860', 'nordbygg-2026', 'Jack Midhage AB', 'B09:41 (+1)', jsonb_build_object('en', 'JLM Group AB', 'sv', 'JLM Group AB'), 'https://jlmgroup.se', null),
  ('nordbygg-2026-exhibitor-133982', 'nordbygg-2026', 'Jafo AB / Unidrain Sverige', 'A03:26', jsonb_build_object('en', 'Jafo utvecklar och säljer VVS-Produkter i plast & rostfritt med golvbrunnar och golvrännor som huvudprodukter.

I mer än 50 år har Jafo utvecklat och tillverkat golvbrunnar och många andra produkter för vattenavledning i svenska hem. Vi var till exempel först med att gjuta plastbrunnar i ett stycke och lansera koniska klämringar som skruvas fast. Vi såg dessutom till att det blev standard att golvbrunnar som installeras i träbjälklag säkras med en monteringsplatta. Och kanske kommer fler att följa efter sedan vi börjat använda återvunnen plast i våra produkter.

Vi påstår inte att vi har uppfunnit hjulet. Vi gör det bara lite rundare efterhand. Allt för att du och Sveriges 15 000 andra rörläggare ska kunna göra ett jobb som håller vad du lovar. Ett vattentätt jobb, helt enkelt.

På den svenska marknaden ansvarar Jafo AB även för försäljningen av Unidrain.

Unidrains unika golvaloppssystem har på bara några år blivit byggbranschens mest populära. Idag finns Unidrain-installationer över hela världen, och Unidrain har blivit ett begrepp för moderna golvbrunn placerade mot väggen. Med den löpande utvecklingen inom både byggteknik och design är det Unidrains ambition att inte bara vara byggbranschens mest populära golvavloppssystem, utan att också vara branschens prioriterade leverantör inom badrumsområdet.

Unidrains produkter kan användas i alla typer av byggnader: Vid renovering och nybyggnation samt i privata och offentliga byggnader. Alla Unidrain-produkter är utvecklade av danska arkitekter i nära samarbete med experter på våtrumsteknik och har alla relevanta godkännanden både lokalt och internationellt.

Unidrains golvavlopp har fått flera internationellt erkända designpriser, till exempel "iF product design award" och "Den Danske Designpris" för serien HighLine. 2015 fick Claus Dyre "Villum Fondens Bygningskomponentpris" för att ha uppfunnit linjegolvavloppet.', 'sv', 'Jafo utvecklar och säljer VVS-Produkter i plast & rostfritt med golvbrunnar och golvrännor som huvudprodukter.

I mer än 50 år har Jafo utvecklat och tillverkat golvbrunnar och många andra produkter för vattenavledning i svenska hem. Vi var till exempel först med att gjuta plastbrunnar i ett stycke och lansera koniska klämringar som skruvas fast. Vi såg dessutom till att det blev standard att golvbrunnar som installeras i träbjälklag säkras med en monteringsplatta. Och kanske kommer fler att följa efter sedan vi börjat använda återvunnen plast i våra produkter.

Vi påstår inte att vi har uppfunnit hjulet. Vi gör det bara lite rundare efterhand. Allt för att du och Sveriges 15 000 andra rörläggare ska kunna göra ett jobb som håller vad du lovar. Ett vattentätt jobb, helt enkelt.

På den svenska marknaden ansvarar Jafo AB även för försäljningen av Unidrain.

Unidrains unika golvaloppssystem har på bara några år blivit byggbranschens mest populära. Idag finns Unidrain-installationer över hela världen, och Unidrain har blivit ett begrepp för moderna golvbrunn placerade mot väggen. Med den löpande utvecklingen inom både byggteknik och design är det Unidrains ambition att inte bara vara byggbranschens mest populära golvavloppssystem, utan att också vara branschens prioriterade leverantör inom badrumsområdet.

Unidrains produkter kan användas i alla typer av byggnader: Vid renovering och nybyggnation samt i privata och offentliga byggnader. Alla Unidrain-produkter är utvecklade av danska arkitekter i nära samarbete med experter på våtrumsteknik och har alla relevanta godkännanden både lokalt och internationellt.

Unidrains golvavlopp har fått flera internationellt erkända designpriser, till exempel "iF product design award" och "Den Danske Designpris" för serien HighLine. 2015 fick Claus Dyre "Villum Fondens Bygningskomponentpris" för att ha uppfunnit linjegolvavloppet.'), 'https://www.jafo.eu', 'assets/images/exhibitors/nordbygg-2026-jafo-ab-unidrain-sverige.jpg'),
  ('nordbygg-2026-exhibitor-137910', 'nordbygg-2026', 'James Hardie', 'C06:52', null, 'https://www.jameshardie.se', 'assets/images/exhibitors/nordbygg-2026-james-hardie.jpg'),
  ('nordbygg-2026-exhibitor-138670', 'nordbygg-2026', 'Jape Produkter AB', 'C07:70', null, 'https://www.jape.se', 'assets/images/exhibitors/nordbygg-2026-jape-produkter-ab.jpg'),
  ('nordbygg-2026-exhibitor-139476', 'nordbygg-2026', 'JBF Järn- Bygg- & Färgfackhandlarna', 'BG:06', jsonb_build_object('en', 'JBF är en oberoende branschtidning med över fyra decenniers erfarenhet av att bevaka utvecklingen inom järn-, bygg- och färghandeln. Vår ambition är att ge en nyanserad och trovärdig bild av en marknad som ständigt förändras – från lokala familjeföretag till rikstäckande kedjor.

Vi skildrar inte bara produkterna, utan också människorna, företagen och strategierna bakom handeln. Vår redaktion arbetar nära ett rådgivande råd med mångårig erfarenhet som företagare och branschaktörer, vilket ger oss djup kunskap och perspektiv.

Att vara oberoende är kärnan i vår journalistik. Vi är inte knutna till någon organisation eller intressegrupp, vilket ger oss frihet att ställa frågor, granska trender och lyfta fram olika röster.', 'sv', 'JBF är en oberoende branschtidning med över fyra decenniers erfarenhet av att bevaka utvecklingen inom järn-, bygg- och färghandeln. Vår ambition är att ge en nyanserad och trovärdig bild av en marknad som ständigt förändras – från lokala familjeföretag till rikstäckande kedjor.

Vi skildrar inte bara produkterna, utan också människorna, företagen och strategierna bakom handeln. Vår redaktion arbetar nära ett rådgivande råd med mångårig erfarenhet som företagare och branschaktörer, vilket ger oss djup kunskap och perspektiv.

Att vara oberoende är kärnan i vår journalistik. Vi är inte knutna till någon organisation eller intressegrupp, vilket ger oss frihet att ställa frågor, granska trender och lyfta fram olika röster.'), 'https://jarnbyggfarg.se/', 'assets/images/exhibitors/nordbygg-2026-jbf-jarn-bygg-fargfackhandlarna.jpg'),
  ('nordbygg-2026-exhibitor-139475', 'nordbygg-2026', 'JCH A/S', 'A05:33', null, 'https://www.jch.as', null),
  ('nordbygg-2026-exhibitor-134663', 'nordbygg-2026', 'Jeven AB', 'A16:18', jsonb_build_object('en', 'Bättre klimat i köket tack vare Jevens storköksventilation.
En ren, sund och energiklok arbetsmiljö är en självklar drivkraft i vår produktutveckling av storköksventilation. Att skapa ett bättre arbetsklimat för professionell kökspersonal främjar personalens välbefinnande, förbättrar lönsamheten och ökar byggnadens energieffektivitet.', 'sv', 'Bättre klimat i köket tack vare Jevens storköksventilation.
En ren, sund och energiklok arbetsmiljö är en självklar drivkraft i vår produktutveckling av storköksventilation. Att skapa ett bättre arbetsklimat för professionell kökspersonal främjar personalens välbefinnande, förbättrar lönsamheten och ökar byggnadens energieffektivitet.'), 'https://www.jeven.se', 'assets/images/exhibitors/nordbygg-2026-jeven-ab.jpg'),
  ('nordbygg-2026-exhibitor-139990', 'nordbygg-2026', 'JIRICOM AB', 'C02:41', jsonb_build_object('en', 'Jiricom erbjuder marknadens bästa körjournaler och spårsändare för alla som kör bil i tjänsten eller vill ha koll på sina dyra maskiner och verktyg. Sväng förbi montern och kika på Sveriges billigaste körjournal!', 'sv', 'Jiricom erbjuder marknadens bästa körjournaler och spårsändare för alla som kör bil i tjänsten eller vill ha koll på sina dyra maskiner och verktyg. Sväng förbi montern och kika på Sveriges billigaste körjournal!'), 'https://jiricom.se/sv', 'assets/images/exhibitors/nordbygg-2026-jiricom-ab.jpg'),
  ('nordbygg-2026-exhibitor-139386', 'nordbygg-2026', 'JM GRUPA', 'C04:41', null, 'https://www.jmgrupa.lv/en', 'assets/images/exhibitors/nordbygg-2026-jm-grupa.jpg'),
  ('nordbygg-2026-exhibitor-133989', 'nordbygg-2026', 'Joma AB', 'C13:53', jsonb_build_object('en', 'Joma utvecklar, tillverkar och marknadsför produkter för byggindustrin. Vårt sortiment omfattar byggbeslag och skalmursprodukter samt tråd som riktas och kapas enligt kundspecifika önskemål.

Försäljning av byggbeslag – såsom balkskor, vinkelbeslag, hålplattor och hålband – samt skalmursprodukter som murkramlor, murverksarmering och glidskikt sker via våra återförsäljare. Våra trådprodukter säljs till både grossister och tillverkare.', 'sv', 'Joma utvecklar, tillverkar och marknadsför produkter för byggindustrin. Vårt sortiment omfattar byggbeslag och skalmursprodukter samt tråd som riktas och kapas enligt kundspecifika önskemål.

Försäljning av byggbeslag – såsom balkskor, vinkelbeslag, hålplattor och hålband – samt skalmursprodukter som murkramlor, murverksarmering och glidskikt sker via våra återförsäljare. Våra trådprodukter säljs till både grossister och tillverkare.'), 'https://www.joma.se', 'assets/images/exhibitors/nordbygg-2026-joma-ab.jpg'),
  ('nordbygg-2026-exhibitor-139037', 'nordbygg-2026', 'Jukola Industries', 'C14:26', null, 'https://jukolaind.com', 'assets/images/exhibitors/nordbygg-2026-jukola-industries.jpg'),
  ('nordbygg-2026-exhibitor-139453', 'nordbygg-2026', 'JURES MEDIS', 'C14:70', null, 'https://www.juresmedis.lt/en', 'assets/images/exhibitors/nordbygg-2026-jures-medis.jpg'),
  ('nordbygg-2026-exhibitor-138658', 'nordbygg-2026', 'Järnet Smide Stockholm AB', 'C17:18', jsonb_build_object('en', 'Järnet Smide Stockholm AB är en välrenommerad, och kompetent leverantör av tjänster inom service och fastighetssmide. Redan från starten 1988 har vi haft fokus på att serva allmännyttan och fastighetsägare och har fortsatt så i över 30 år.
Målsättning och inriktning är nu som då att serva allmännyttan och privata fastighetsägare med arbeten och rådgivning inom plåt, smide, lås samt även tillverkning och montage av specialbyggda entrédörrar i stål, rostfritt samt trä och branddörrar enligt kundens önskemål. För att kunna leverera med högsta kvalitet och finish utvecklas och produceras det mesta av våra produkter i egen regi.', 'sv', 'Järnet Smide Stockholm AB är en välrenommerad, och kompetent leverantör av tjänster inom service och fastighetssmide. Redan från starten 1988 har vi haft fokus på att serva allmännyttan och fastighetsägare och har fortsatt så i över 30 år.
Målsättning och inriktning är nu som då att serva allmännyttan och privata fastighetsägare med arbeten och rådgivning inom plåt, smide, lås samt även tillverkning och montage av specialbyggda entrédörrar i stål, rostfritt samt trä och branddörrar enligt kundens önskemål. För att kunna leverera med högsta kvalitet och finish utvecklas och produceras det mesta av våra produkter i egen regi.'), 'https://jarnetsmide.se', 'assets/images/exhibitors/nordbygg-2026-jarnet-smide-stockholm-ab.jpg'),
  ('nordbygg-2026-exhibitor-139041', 'nordbygg-2026', 'Kakelspecialisten', 'A01:202', jsonb_build_object('en', 'Kakelspecialisten är ett av Sveriges ledande företag inom kakel och badrumsinredningar. Vi säljer och marknadsför allt inom kakel, klinker, granitkeramik, badrumsinredning, fäst & fogprodukter och andra kringprodukter till både privata och offentliga projekt . Hos oss hittar du marknadens i särklass bredaste projektsortiment.

På Nordbygg kommer vi visa det senast inom kakel och klinker till badrum, med särskilt fokus på hållbarhet. Vi kommer visa vårt sortiment med kakel och klinker som har en mycket stor andel återvunnet material bland annat engelska Alusids sortiment.', 'sv', 'Kakelspecialisten är ett av Sveriges ledande företag inom kakel och badrumsinredningar. Vi säljer och marknadsför allt inom kakel, klinker, granitkeramik, badrumsinredning, fäst & fogprodukter och andra kringprodukter till både privata och offentliga projekt . Hos oss hittar du marknadens i särklass bredaste projektsortiment.

På Nordbygg kommer vi visa det senast inom kakel och klinker till badrum, med särskilt fokus på hållbarhet. Vi kommer visa vårt sortiment med kakel och klinker som har en mycket stor andel återvunnet material bland annat engelska Alusids sortiment.'), 'https://www.kakelspecialisten.se', 'assets/images/exhibitors/nordbygg-2026-kakelspecialisten.jpg'),
  ('nordbygg-2026-exhibitor-139184', 'nordbygg-2026', 'Kalkylhjälp AB / Bluebeam', 'BG:01', jsonb_build_object('en', 'Smartare kalkylering. Bättre arbetsflöden.
En träffsäker kalkyl är grunden för ett smidigt och effektivt projekt. Vi har stor erfarenhet av alla typer av kalkyler inom bygg-, VVS- och elbranschen. Vill du lära dig mer om smart kalkylering erbjuder vi även utbildningar för flera programvaror.

Välkommen till oss! Vi är ett gäng erfarna och flexibla personer som gillar vårt jobb och vet hur man undviker fallgropar. Det lönar sig alltid med en riktig kalkyl, både ekonomiskt och tidsmässigt.', 'sv', 'Smartare kalkylering. Bättre arbetsflöden.
En träffsäker kalkyl är grunden för ett smidigt och effektivt projekt. Vi har stor erfarenhet av alla typer av kalkyler inom bygg-, VVS- och elbranschen. Vill du lära dig mer om smart kalkylering erbjuder vi även utbildningar för flera programvaror.

Välkommen till oss! Vi är ett gäng erfarna och flexibla personer som gillar vårt jobb och vet hur man undviker fallgropar. Det lönar sig alltid med en riktig kalkyl, både ekonomiskt och tidsmässigt.'), 'https://kalkylhjalp.se', 'assets/images/exhibitors/nordbygg-2026-kalkylhjalp-ab-bluebeam.jpg'),
  ('nordbygg-2026-exhibitor-138086', 'nordbygg-2026', 'KANDELA LIGHTING', 'AG:38', null, 'https://www.kandela.com.pl', null),
  ('nordbygg-2026-exhibitor-138488', 'nordbygg-2026', 'Karl H Ström AB', 'B04:42', null, 'https://www.khs.se', 'assets/images/exhibitors/nordbygg-2026-karl-h-strom-ab.jpg'),
  ('nordbygg-2026-exhibitor-134995', 'nordbygg-2026', 'KASK S.p.a.', 'B03:50', null, 'https://kask-safety.com', null),
  ('nordbygg-2026-exhibitor-139567', 'nordbygg-2026', 'KE Therm AB', 'A07:21', null, 'https://www.ketherm.se', 'assets/images/exhibitors/nordbygg-2026-ke-therm-ab.jpg'),
  ('nordbygg-2026-exhibitor-140138', 'nordbygg-2026', 'KGA', 'C13:33', null, 'https://www.kga.com.pl', 'assets/images/exhibitors/nordbygg-2026-kga.jpg'),
  ('nordbygg-2026-exhibitor-136561', 'nordbygg-2026', 'Kia Sweden AB', 'AG:114', null, 'https://www.kia.com', null),
  ('nordbygg-2026-exhibitor-137396', 'nordbygg-2026', 'Kiilax inspektionsluckor', 'C19:43', jsonb_build_object('en', '• Marknadens smidigaste inspektionsluckor med patenterade montagelösningar.
• Byggkilar i plywood och fukttrög spånskiva.
• Väderskydd för luftvärmepumpar
• Distansplattor i plywood
• Stödbensplattor', 'sv', '• Marknadens smidigaste inspektionsluckor med patenterade montagelösningar.
• Byggkilar i plywood och fukttrög spånskiva.
• Väderskydd för luftvärmepumpar
• Distansplattor i plywood
• Stödbensplattor'), 'https://www.kiilax.fi', 'assets/images/exhibitors/nordbygg-2026-kiilax-inspektionsluckor.jpg'),
  ('nordbygg-2026-exhibitor-134000', 'nordbygg-2026', 'Kiona', 'A20:10 (+1)', jsonb_build_object('en', 'Vi integrerar och ansluter alla tekniska system oavsett varumärke och antal år i drift, utan att det krävs intern programvara och servrar. Vi bevisar att det är möjligt att möta framtiden kostnadseffektivt genom en öppen, flexibel och oberoende proptech-plattform genom våra produkter Web Port, Edge, Energinet och IWMAC.

I år satsar vi på en större monter med fler möjligheter till att lära sig mer om Kionas produkter, där vi i år lägger extra fokus på vårt partnerprogram och våra nya certifieringskurser och produktnyheter. Oavsett om du är en långvarig partner eller bara nyfiken på vad vi gör, har vi mycket att visa dig.

Att ligga steget före inom vårt område innebär att hålla sig utbildad. Våra certifieringskurser är utformade för att ge dig den djupa tekniska förståelse du behöver för att leverera de bästa lösningarna till dina kunder. Från grundläggande installation till avancerad konfiguration, vi har en väg för en mängd olika partners och roller.', 'sv', 'Vi integrerar och ansluter alla tekniska system oavsett varumärke och antal år i drift, utan att det krävs intern programvara och servrar. Vi bevisar att det är möjligt att möta framtiden kostnadseffektivt genom en öppen, flexibel och oberoende proptech-plattform genom våra produkter Web Port, Edge, Energinet och IWMAC.

I år satsar vi på en större monter med fler möjligheter till att lära sig mer om Kionas produkter, där vi i år lägger extra fokus på vårt partnerprogram och våra nya certifieringskurser och produktnyheter. Oavsett om du är en långvarig partner eller bara nyfiken på vad vi gör, har vi mycket att visa dig.

Att ligga steget före inom vårt område innebär att hålla sig utbildad. Våra certifieringskurser är utformade för att ge dig den djupa tekniska förståelse du behöver för att leverera de bästa lösningarna till dina kunder. Från grundläggande installation till avancerad konfiguration, vi har en väg för en mängd olika partners och roller.'), 'https://www.kiona.com', 'assets/images/exhibitors/nordbygg-2026-kiona.jpg'),
  ('nordbygg-2026-exhibitor-138695', 'nordbygg-2026', 'Kiso A/S', 'C07:71', jsonb_build_object('en', 'KISO A/S – Tillförlitliga tätningslösningar för byggindustrin

KISO A/S är en dansk tillverkare och leverantör av högpresterande tätnings- och isoleringslösningar, med ett starkt fokus på bygg- och anläggningssektorn.

Med många års erfarenhet är vi specialiserade på butylbaserade tejper, gummiprofiler och kundanpassade tätningslösningar, utvecklade för att möta de höga krav som ställs inom modernt byggande – särskilt för fönster- och fasadtillverkare.

Våra lösningar används bland annat inom:

Fönster- och dörrproduktion

Fasader och klimatskal

HVAC- och isoleringssystem

Industriella OEM-applikationer

Varför välja KISO?

Godkända gummiprofiler registrerade i Byggvarubedömningen

ISO-certifierad produktion och kvalitetsstyrning

Dokumenterad prestanda i nordiskt klimat

Kund- och projektspecifika lösningar

Stark teknisk support och snabb respons

Miljöansvarstagande produkter – fria från skadliga lösningsmedel

Vi arbetar nära våra kunder genom hela processen – från teknisk rådgivning och tester till implementering i produktion – för att säkerställa hög kvalitet, enkel montering och lång livslängd.

Träffa KISO på Nordbygg
Låt oss visa hur våra tätningslösningar kan skapa mervärde i era byggprojekt.

KISO A/S – Din partner för säkra och hållbara tätningslösningar.', 'sv', 'KISO A/S – Tillförlitliga tätningslösningar för byggindustrin

KISO A/S är en dansk tillverkare och leverantör av högpresterande tätnings- och isoleringslösningar, med ett starkt fokus på bygg- och anläggningssektorn.

Med många års erfarenhet är vi specialiserade på butylbaserade tejper, gummiprofiler och kundanpassade tätningslösningar, utvecklade för att möta de höga krav som ställs inom modernt byggande – särskilt för fönster- och fasadtillverkare.

Våra lösningar används bland annat inom:

Fönster- och dörrproduktion

Fasader och klimatskal

HVAC- och isoleringssystem

Industriella OEM-applikationer

Varför välja KISO?

Godkända gummiprofiler registrerade i Byggvarubedömningen

ISO-certifierad produktion och kvalitetsstyrning

Dokumenterad prestanda i nordiskt klimat

Kund- och projektspecifika lösningar

Stark teknisk support och snabb respons

Miljöansvarstagande produkter – fria från skadliga lösningsmedel

Vi arbetar nära våra kunder genom hela processen – från teknisk rådgivning och tester till implementering i produktion – för att säkerställa hög kvalitet, enkel montering och lång livslängd.

Träffa KISO på Nordbygg
Låt oss visa hur våra tätningslösningar kan skapa mervärde i era byggprojekt.

KISO A/S – Din partner för säkra och hållbara tätningslösningar.'), 'https://www.kiso.dk', 'assets/images/exhibitors/nordbygg-2026-kiso-a-s.jpg'),
  ('nordbygg-2026-exhibitor-134708', 'nordbygg-2026', 'Kiwa Sweden AB', 'AG:26', jsonb_build_object('en', 'Vi är Kiwa, ett av världens största företag inom besiktning, provning och certifiering. Våra tjänster skapar förtroende för våra kunders produkter, tjänster, ledningssystem och medarbetare.', 'sv', 'Vi är Kiwa, ett av världens största företag inom besiktning, provning och certifiering. Våra tjänster skapar förtroende för våra kunders produkter, tjänster, ledningssystem och medarbetare.'), 'https://www.kiwa.se', 'assets/images/exhibitors/nordbygg-2026-kiwa-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-138678', 'nordbygg-2026', 'KiwiTOOLS', 'B06:50', jsonb_build_object('en', 'Vi säljer inte skit. Punkt.
Bara grejer som håller – Makita, Mafell, Wera, Knipex, Bessey, Stabila, Picard, Halder m.fl.

Rätt verktyg gör jobbet. Fel verktyg kostar dig tid, pengar och tålamod.
Vi väljer rätt – så du slipper chansa.

Snabba leveranser från Skellefteå, raka besked och noll bullshit.

Kom förbi montern på Nordbygg om du vill ha verktyg som levererar!', 'sv', 'Vi säljer inte skit. Punkt.
Bara grejer som håller – Makita, Mafell, Wera, Knipex, Bessey, Stabila, Picard, Halder m.fl.

Rätt verktyg gör jobbet. Fel verktyg kostar dig tid, pengar och tålamod.
Vi väljer rätt – så du slipper chansa.

Snabba leveranser från Skellefteå, raka besked och noll bullshit.

Kom förbi montern på Nordbygg om du vill ha verktyg som levererar!'), 'https://kiwitools.se', 'assets/images/exhibitors/nordbygg-2026-kiwitools.jpg'),
  ('nordbygg-2026-exhibitor-138016', 'nordbygg-2026', 'Klima Nor AB', 'A15:24', jsonb_build_object('en', 'Klima Nor AB är ett dotterbolag till Klima Nor A/S i Norge och etableras i Karlstad 2025, med verksamhet över hela Sverige via starka partners.

Klima Nor AB äger agenturen för det Österrikiska bolaget M-Tec Systems.

M-TEC kan se tillbaka på över 50 års erfarenhet som pionjär inom hållbara energilösningar. Det som började som ett banbrytande företag inom värmepumpsteknik är nu en ledande leverantör av integrerade energisystem i Europa.

Med innovativa produkter, heltäckande tjänster och ett starkt partner nätverk driver vi aktivt energiomställningen – för hushåll, företag och kommuner.M-TEC kan se tillbaka på över 50 års erfarenhet som pionjär inom hållbara energilösningar. Det som började som ett banbrytande företag inom värmepumpsteknik är nu en ledande leverantör av integrerade energisystem i Europa.

Med innovativa produkter, heltäckande tjänster och ett starkt partner nätverk driver vi aktivt energiomställningen – för hushåll, företag och kommuner.
Moderbolaget, Klima Nor A/S, är den ledande ventilations grossisten i Inlandsregionen. Med egen produktion av spiral rör och ett brett sortiment av ventilations delar, kompletterar vi vårt erbjudande med energilösningar inom solpaneler och värmepumpar. Hos oss finns även fäst material, teknisk utrustning, arbetskläder och verktyg – allt samlat på ett ställe.

Våra styrkor:

Ventilation – egen produktion av spiral rör och omfattande sortiment av ventilations delar

Energi – lösningar med solpaneler och värmepumpar

Tillbehör – fäst material, teknisk utrustning, arbetskläder och verktyg

Hållbara energilösningar

Tillsammans med våra samarbetspartners M-TEC och DualSun levererar vi framtidens energilösningar. Fokus ligger på högeffektiva system som samverkar för att täcka:

-Värmepumpar

-Energi styrning

-Varmvatten

-Solenergi

-Batteri-lagring

-PVT Värmepumpar

Klima Nor AB bygger på lång erfarenhet, teknisk kompetens och innovation. Vår vision är att bidra till en grönare framtid genom helhetslösningar som skapar effektivitet, trygghet och hållbarhet för våra kunder i hela Sverige.

www.klima-nor.se
www.mtec-systems.com

Edward Gawor VD/CEO Sverige', 'sv', 'Klima Nor AB är ett dotterbolag till Klima Nor A/S i Norge och etableras i Karlstad 2025, med verksamhet över hela Sverige via starka partners.

Klima Nor AB äger agenturen för det Österrikiska bolaget M-Tec Systems.

M-TEC kan se tillbaka på över 50 års erfarenhet som pionjär inom hållbara energilösningar. Det som började som ett banbrytande företag inom värmepumpsteknik är nu en ledande leverantör av integrerade energisystem i Europa.

Med innovativa produkter, heltäckande tjänster och ett starkt partner nätverk driver vi aktivt energiomställningen – för hushåll, företag och kommuner.M-TEC kan se tillbaka på över 50 års erfarenhet som pionjär inom hållbara energilösningar. Det som började som ett banbrytande företag inom värmepumpsteknik är nu en ledande leverantör av integrerade energisystem i Europa.

Med innovativa produkter, heltäckande tjänster och ett starkt partner nätverk driver vi aktivt energiomställningen – för hushåll, företag och kommuner.
Moderbolaget, Klima Nor A/S, är den ledande ventilations grossisten i Inlandsregionen. Med egen produktion av spiral rör och ett brett sortiment av ventilations delar, kompletterar vi vårt erbjudande med energilösningar inom solpaneler och värmepumpar. Hos oss finns även fäst material, teknisk utrustning, arbetskläder och verktyg – allt samlat på ett ställe.

Våra styrkor:

Ventilation – egen produktion av spiral rör och omfattande sortiment av ventilations delar

Energi – lösningar med solpaneler och värmepumpar

Tillbehör – fäst material, teknisk utrustning, arbetskläder och verktyg

Hållbara energilösningar

Tillsammans med våra samarbetspartners M-TEC och DualSun levererar vi framtidens energilösningar. Fokus ligger på högeffektiva system som samverkar för att täcka:

-Värmepumpar

-Energi styrning

-Varmvatten

-Solenergi

-Batteri-lagring

-PVT Värmepumpar

Klima Nor AB bygger på lång erfarenhet, teknisk kompetens och innovation. Vår vision är att bidra till en grönare framtid genom helhetslösningar som skapar effektivitet, trygghet och hållbarhet för våra kunder i hela Sverige.

www.klima-nor.se
www.mtec-systems.com

Edward Gawor VD/CEO Sverige'), 'https://www.klima-nor.se', 'assets/images/exhibitors/nordbygg-2026-klima-nor-ab.jpg'),
  ('nordbygg-2026-exhibitor-138638', 'nordbygg-2026', 'KlimaTherm AB', 'A19:26', null, 'https://www.klima-therm.com/se', null),
  ('nordbygg-2026-exhibitor-139208', 'nordbygg-2026', 'KlimaTherm AB 2', 'A19:32', null, 'https://www.klima-therm.com/se', null),
  ('nordbygg-2026-exhibitor-138158', 'nordbygg-2026', 'Klimatkoncept Sweden AB', 'A13:30', jsonb_build_object('en', 'Klimatkoncept - Din kvalitetsmedvetna partner inom HVAC

Vårt mål på Klimatkoncept är tydligt - att förse HVAC-branschen med högkvalitativa värme och kylprodukter samt installationsmaterial som garanterar en framgångsrik och pålitlig installation eller service varje gång.

Vi grundade vårt företag med en stark övertygelse om att marknaden förtjänade bättre installationsmaterial än det som tidigare fanns tillgängligt på marknaden. Med en passion för överlägsen kvalitet och en vilja att höja standarden, strävar vi efter att vara din pålitliga grossist inom HVAC-branschen.

Vårt sortiment inkluderar värmepumpar av alla sorter och allt nödvändigt installationsmaterial som behövs för att du som installatör ska lyckas med din verksamhet, från början till slut, och vi välkomnar dig att utförska vårt utbud av produkter.

Hos Klimatkoncept hittar du inte bara produkter, du hittar en samarbetspartner som delar dina kvalitetskrav och strävan efter enastående resultat, varje gång.

Utforska vårt sortiment och låt oss tillsammans forma en bättre framtid för HVAC-branschen med högkvalitativa produkter och material. Kontakta oss idag för att ta din verksamhet till nästa nivå med Klimatkoncept som din pålitliga partner.', 'sv', 'Klimatkoncept - Din kvalitetsmedvetna partner inom HVAC

Vårt mål på Klimatkoncept är tydligt - att förse HVAC-branschen med högkvalitativa värme och kylprodukter samt installationsmaterial som garanterar en framgångsrik och pålitlig installation eller service varje gång.

Vi grundade vårt företag med en stark övertygelse om att marknaden förtjänade bättre installationsmaterial än det som tidigare fanns tillgängligt på marknaden. Med en passion för överlägsen kvalitet och en vilja att höja standarden, strävar vi efter att vara din pålitliga grossist inom HVAC-branschen.

Vårt sortiment inkluderar värmepumpar av alla sorter och allt nödvändigt installationsmaterial som behövs för att du som installatör ska lyckas med din verksamhet, från början till slut, och vi välkomnar dig att utförska vårt utbud av produkter.

Hos Klimatkoncept hittar du inte bara produkter, du hittar en samarbetspartner som delar dina kvalitetskrav och strävan efter enastående resultat, varje gång.

Utforska vårt sortiment och låt oss tillsammans forma en bättre framtid för HVAC-branschen med högkvalitativa produkter och material. Kontakta oss idag för att ta din verksamhet till nästa nivå med Klimatkoncept som din pålitliga partner.'), 'https://www.klimatkoncept.se', 'assets/images/exhibitors/nordbygg-2026-klimatkoncept-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-138612', 'nordbygg-2026', 'KMP Pellet Heating AB', 'A06:30', null, 'https://www.kmp-ab.se', null),
  ('nordbygg-2026-exhibitor-136729', 'nordbygg-2026', 'KNIPEX WERK', 'B04:31', jsonb_build_object('en', 'KNIPEX Grundades 1882 av Carl Gustav Putsch och är sedan dess en världsledande tångtillverkare.
Med 1,900 anställda i Tyska Wuppertal och 65,000 m² produktionsyta tillverkar vi 14 miljoner tänger per år (± 70,000 tänger varje dag).
I 144 år har vi levererat högkvalitativa tänger för professionella användare som har förbättrat deras arbeten.
Innovationer som Aligator, Cobra, Cobolt, Tångnyckeln, X-cut och Ergostrip används idag i fler än 110 länder via världsomspännande distributionsnät.
För varje verktygsfunktion väljer vi stål av bästa kvalite och smider den med exakt rätt värme samt korrekta och precisa efterbehandlingar.
Vi konstruerar och bygger våra egna maskiner, producerar tängerna med hög precision följt av en nolltolerans kvalitékontroll, allt för att kunna garantera full tillförlitlighet.
Vi erbjuder 1,200 tång-modeller som är väldesignad, simulerad och testade innan de hamnar i dina händer.
Vi är KNIPEX!', 'sv', 'KNIPEX Grundades 1882 av Carl Gustav Putsch och är sedan dess en världsledande tångtillverkare.
Med 1,900 anställda i Tyska Wuppertal och 65,000 m² produktionsyta tillverkar vi 14 miljoner tänger per år (± 70,000 tänger varje dag).
I 144 år har vi levererat högkvalitativa tänger för professionella användare som har förbättrat deras arbeten.
Innovationer som Aligator, Cobra, Cobolt, Tångnyckeln, X-cut och Ergostrip används idag i fler än 110 länder via världsomspännande distributionsnät.
För varje verktygsfunktion väljer vi stål av bästa kvalite och smider den med exakt rätt värme samt korrekta och precisa efterbehandlingar.
Vi konstruerar och bygger våra egna maskiner, producerar tängerna med hög precision följt av en nolltolerans kvalitékontroll, allt för att kunna garantera full tillförlitlighet.
Vi erbjuder 1,200 tång-modeller som är väldesignad, simulerad och testade innan de hamnar i dina händer.
Vi är KNIPEX!'), 'https://www.knipex.se', 'assets/images/exhibitors/nordbygg-2026-knipex-werk.jpg'),
  ('nordbygg-2026-exhibitor-137900', 'nordbygg-2026', 'Knutwall Marking Systems AB', 'B04:50', jsonb_build_object('en', 'Knutwall erbjuder kundanpassade skyltar och märksystem till marknadens snabbaste leveranser.

Vi har två produktionsenheter i Sverige men levererar produkter över hela Skandinavien varje dag.

Designa dina skyltar & märksystem grafiskt online på vår hemsida www.knutwall.com och beställ före 16.00 så skickas dina produkter redan samma dag. Eller maila in din order till order@knutwall.com

Vi erbjuder kundanpassade produkter så som:

• Graverade skyltar i plast, rostfritt och aluminium
• Taktila skyltar / Blindskriftsskyltar
• Printade skyltar i plast och aluminium
• Paneler i plast, aluminium och rostfritt
• Klistermärken i olika material och utföranden
• Kabelmärkning i halogenfri plast
• Rostfri kabelmärkning
• Partmärkning i halogenfri plast
• Öppen partmärkning
• Plintmärkning
• Rörmärkning & rörmärkningsdekaler
• Ventilationsmärkning
• Hammarprodukter

Och mycket mera, välkommen till vår monter!', 'sv', 'Knutwall erbjuder kundanpassade skyltar och märksystem till marknadens snabbaste leveranser.

Vi har två produktionsenheter i Sverige men levererar produkter över hela Skandinavien varje dag.

Designa dina skyltar & märksystem grafiskt online på vår hemsida www.knutwall.com och beställ före 16.00 så skickas dina produkter redan samma dag. Eller maila in din order till order@knutwall.com

Vi erbjuder kundanpassade produkter så som:

• Graverade skyltar i plast, rostfritt och aluminium
• Taktila skyltar / Blindskriftsskyltar
• Printade skyltar i plast och aluminium
• Paneler i plast, aluminium och rostfritt
• Klistermärken i olika material och utföranden
• Kabelmärkning i halogenfri plast
• Rostfri kabelmärkning
• Partmärkning i halogenfri plast
• Öppen partmärkning
• Plintmärkning
• Rörmärkning & rörmärkningsdekaler
• Ventilationsmärkning
• Hammarprodukter

Och mycket mera, välkommen till vår monter!'), 'https://www.knutwall.com', 'assets/images/exhibitors/nordbygg-2026-knutwall-marking-systems-ab.jpg'),
  ('nordbygg-2026-exhibitor-139558', 'nordbygg-2026', 'Koki Sweden AB', 'B01:30', null, 'https://www.metabo.se', null),
  ('nordbygg-2026-exhibitor-138717', 'nordbygg-2026', 'Kolmeks Oy', 'A11:23', jsonb_build_object('en', 'Kolmeks is a leading Finnish pump manufacturer with 80 years of experience. We are adding new products to our selection of high-quality products.

We have been engineering and manufacturing pumps for 80 years, building a portfolio of industry-driven, reliable, and energy-efficient pumping equipment. Pump technology and application know-how are our core competencies.

In addition to our Finnish pump factory, Kolmeks operates production facilities in Estonia, China, and India focused on component contract manufacturing. We support our customers with high-quality, tailor-made pump and HVAC solutions, complemented by expert maintenance and after-sales services.

Kolmeks pumps are typically used in process industries, for example in pulp and paper, marine and offshore, power plants and district heating/cooling systems. Kolmeks In-line speed-controlled pumps with motor-integrated or wall mounted frequency converter are used in the heating and cooling systems of industrial and building technology.

We provide solutions to helping our customers succeed by offering efficient, reliable and sustainable products and services. We are proud of our world-class after sales services, including maintenance and commissioning.', 'sv', 'Kolmeks is a leading Finnish pump manufacturer with 80 years of experience. We are adding new products to our selection of high-quality products.

We have been engineering and manufacturing pumps for 80 years, building a portfolio of industry-driven, reliable, and energy-efficient pumping equipment. Pump technology and application know-how are our core competencies.

In addition to our Finnish pump factory, Kolmeks operates production facilities in Estonia, China, and India focused on component contract manufacturing. We support our customers with high-quality, tailor-made pump and HVAC solutions, complemented by expert maintenance and after-sales services.

Kolmeks pumps are typically used in process industries, for example in pulp and paper, marine and offshore, power plants and district heating/cooling systems. Kolmeks In-line speed-controlled pumps with motor-integrated or wall mounted frequency converter are used in the heating and cooling systems of industrial and building technology.

We provide solutions to helping our customers succeed by offering efficient, reliable and sustainable products and services. We are proud of our world-class after sales services, including maintenance and commissioning.'), 'https://kolmeks.com/en/frontpage', 'assets/images/exhibitors/nordbygg-2026-kolmeks-oy.jpg'),
  ('nordbygg-2026-exhibitor-135839', 'nordbygg-2026', 'Komfovent AB', 'A19:16', null, 'https://www.komfovent.se', null),
  ('nordbygg-2026-exhibitor-139412', 'nordbygg-2026', 'Konstraktor i Gävle AB', 'C08:22', jsonb_build_object('en', 'Konstraktor i Gävle AB
utvecklar smarta lösningar och innovationer för byggbranschen. Under Q1 2026 lanserades vår första produkt XPND - en ny standardlösning för montering av takanslutning.', 'sv', 'Konstraktor i Gävle AB
utvecklar smarta lösningar och innovationer för byggbranschen. Under Q1 2026 lanserades vår första produkt XPND - en ny standardlösning för montering av takanslutning.'), 'https://www.konstraktor.se', 'assets/images/exhibitors/nordbygg-2026-konstraktor-i-gavle-ab.jpg'),
  ('nordbygg-2026-exhibitor-139092', 'nordbygg-2026', 'KRUFF AB', 'A12:33', jsonb_build_object('en', 'Kruff AB levererar komponenter och reservdelar till företag inom kyla och värme. Vi samarbetar med tillverkare, installatörer och serviceföretag som bygger, underhåller och optimerar tekniska anläggningar i vardagen.

Med ett brett sortiment och hög tillgänglighet gör vi det enkelt att hitta rätt produkter, oavsett om det gäller aggregat, kompressorer eller styrningar till kyl- och frysrum samt värmerier. Vårt fokus är att erbjuda pålitliga lösningar som sparar tid och förenklar arbetet för våra kunder.', 'sv', 'Kruff AB levererar komponenter och reservdelar till företag inom kyla och värme. Vi samarbetar med tillverkare, installatörer och serviceföretag som bygger, underhåller och optimerar tekniska anläggningar i vardagen.

Med ett brett sortiment och hög tillgänglighet gör vi det enkelt att hitta rätt produkter, oavsett om det gäller aggregat, kompressorer eller styrningar till kyl- och frysrum samt värmerier. Vårt fokus är att erbjuda pålitliga lösningar som sparar tid och förenklar arbetet för våra kunder.'), 'https://www.kruff.se', 'assets/images/exhibitors/nordbygg-2026-kruff-ab.jpg'),
  ('nordbygg-2026-exhibitor-139623', 'nordbygg-2026', 'Kruge Sverige AB', 'A10:25', null, 'https://www.kruge.com', 'assets/images/exhibitors/nordbygg-2026-kruge-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-135227', 'nordbygg-2026', 'KSB Sverige AB', 'A04:18', jsonb_build_object('en', 'KSB Sverige AB är ett av Sveriges ledande företag inom flödesteknik med försäljning och service av pumpar och ventiler samt tillhörande automation och reglerutrustning för Industri, Energi, Processindustri samt VA och VVS. Vi är ett dotterföretag i den globala KSB-koncernen.
Våra produkter kännetecknas av hög kvalitet och effektivitet, god driftekonomi och servicevänlighet.
Vi finns alltid nära till hands med försäljning och service för den svenska marknaden. Vårt branschkunnande, lagerhållning, egen serviceorganisation tillsammans med utbyggt servicenät bidrar till en lång och säker drift.', 'sv', 'KSB Sverige AB är ett av Sveriges ledande företag inom flödesteknik med försäljning och service av pumpar och ventiler samt tillhörande automation och reglerutrustning för Industri, Energi, Processindustri samt VA och VVS. Vi är ett dotterföretag i den globala KSB-koncernen.
Våra produkter kännetecknas av hög kvalitet och effektivitet, god driftekonomi och servicevänlighet.
Vi finns alltid nära till hands med försäljning och service för den svenska marknaden. Vårt branschkunnande, lagerhållning, egen serviceorganisation tillsammans med utbyggt servicenät bidrar till en lång och säker drift.'), 'https://www.ksb.se', 'assets/images/exhibitors/nordbygg-2026-ksb-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-135160', 'nordbygg-2026', 'KTC Product AB', 'A14:03', null, 'https://www.ktc.se', null),
  ('nordbygg-2026-exhibitor-136723', 'nordbygg-2026', 'Kultursten Norden', 'C04:61K', null, 'https://kultursten.com', null),
  ('nordbygg-2026-exhibitor-136359', 'nordbygg-2026', 'Kylpanel i Nässjö AB', 'C12:61', null, 'https://www.kylpanel.se', 'assets/images/exhibitors/nordbygg-2026-kylpanel-i-nassjo-ab.jpg'),
  ('nordbygg-2026-exhibitor-137610', 'nordbygg-2026', 'KYOCERA Fastening Solutions Sweden AB', 'B03:30', jsonb_build_object('en', 'Vi är experter på infästningslösningar! Med över 40 års erfarenhet på den svenska marknaden erbjuder vi, under våra varumärken Senco, Tjep, Camo, Stinger och Expandet, marknadens bredaste sortiment av verktyg och infästning till trä och betong. För både professionella hantverkare, hemmafixare och automatiserade industrilösningar.', 'sv', 'Vi är experter på infästningslösningar! Med över 40 års erfarenhet på den svenska marknaden erbjuder vi, under våra varumärken Senco, Tjep, Camo, Stinger och Expandet, marknadens bredaste sortiment av verktyg och infästning till trä och betong. För både professionella hantverkare, hemmafixare och automatiserade industrilösningar.'), 'https://www.kyocera-fastening.com', 'assets/images/exhibitors/nordbygg-2026-kyocera-fastening-solutions-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-137982', 'nordbygg-2026', 'Kåbe-Mattan AB', 'C15:51', jsonb_build_object('en', 'Välkommen till C15:51 och möt oss från Kåbe-Mattan!

Kom hit och utforska våra entrémattor och galler i gummi, stål och aluminium.

Kåbe-Mattan är marknadsledande i Sverige. Vi erbjuder ett komplett program av entrémattor i och skrapgaller med tillbehör som passar alla tänkbara entréer.

Svenskt, innovativt och hållbart – i montern möter du, förutom oss, även några av de andra företagen som ingår i Welandkoncernen. Varmt välkommen!', 'sv', 'Välkommen till C15:51 och möt oss från Kåbe-Mattan!

Kom hit och utforska våra entrémattor och galler i gummi, stål och aluminium.

Kåbe-Mattan är marknadsledande i Sverige. Vi erbjuder ett komplett program av entrémattor i och skrapgaller med tillbehör som passar alla tänkbara entréer.

Svenskt, innovativt och hållbart – i montern möter du, förutom oss, även några av de andra företagen som ingår i Welandkoncernen. Varmt välkommen!'), 'https://www.kabe-mattan.se', 'assets/images/exhibitors/nordbygg-2026-kabe-mattan-ab.jpg'),
  ('nordbygg-2026-exhibitor-138580', 'nordbygg-2026', 'Kährs AB', 'C06:33', jsonb_build_object('en', 'Kährs – Skandinavisk design med ansvar och kvalitet
I Sverige har vi i århundraden lärt oss att skapa mycket av lite. Denna tradition av innovation och hållbarhet är en del av Kährs DNA. Vi förvandlar naturresurser till värde med omtanke, precision och ett tidlöst formspråk.

Vår designfilosofi
Skandinavisk design hos Kährs är mer än estetik – den förenar funktion, hållbarhet och modern minimalism. Våra golv är skapade för att hålla, med en känsla som är både välkomnande och tidlös.

Innovation med ansvar
För oss handlar innovation om att driva utvecklingen framåt på ett hållbart sätt. Från ansvarsfull materialanskaffning till cirkulära lösningar arbetar vi för att minska miljöpåverkan och samtidigt höja prestandan.

Kvalitet som standard
Sedan 1857 har kvalitet varit vår norm, inte ett löfte. Varje steg – från produktion till partnerskap – präglas av konsekvens och omsorg. Våra golv är byggda för att prestera och hålla över tid.

Vårt mål
Att inte bara möta förväntningar, utan att överträffa dem. Att ständigt omdefiniera vad ledarskap i branschen innebär.', 'sv', 'Kährs – Skandinavisk design med ansvar och kvalitet
I Sverige har vi i århundraden lärt oss att skapa mycket av lite. Denna tradition av innovation och hållbarhet är en del av Kährs DNA. Vi förvandlar naturresurser till värde med omtanke, precision och ett tidlöst formspråk.

Vår designfilosofi
Skandinavisk design hos Kährs är mer än estetik – den förenar funktion, hållbarhet och modern minimalism. Våra golv är skapade för att hålla, med en känsla som är både välkomnande och tidlös.

Innovation med ansvar
För oss handlar innovation om att driva utvecklingen framåt på ett hållbart sätt. Från ansvarsfull materialanskaffning till cirkulära lösningar arbetar vi för att minska miljöpåverkan och samtidigt höja prestandan.

Kvalitet som standard
Sedan 1857 har kvalitet varit vår norm, inte ett löfte. Varje steg – från produktion till partnerskap – präglas av konsekvens och omsorg. Våra golv är byggda för att prestera och hålla över tid.

Vårt mål
Att inte bara möta förväntningar, utan att överträffa dem. Att ständigt omdefiniera vad ledarskap i branschen innebär.'), 'https://www.kahrs.com/sv-se/', 'assets/images/exhibitors/nordbygg-2026-kahrs-ab.jpg'),
  ('nordbygg-2026-exhibitor-133990', 'nordbygg-2026', 'Laggo AB', 'B05:51', null, 'https://www.laggo.se', 'assets/images/exhibitors/nordbygg-2026-laggo-ab.jpg'),
  ('nordbygg-2026-exhibitor-137898', 'nordbygg-2026', 'Latvia', 'C04:41', null, 'https://www.liaa.gov.lv', 'assets/images/exhibitors/nordbygg-2026-latvia.jpg'),
  ('nordbygg-2026-exhibitor-134661', 'nordbygg-2026', 'LAUFEN', 'A08:13', null, 'https://www.laufen.se', 'assets/images/exhibitors/nordbygg-2026-laufen.jpg'),
  ('nordbygg-2026-exhibitor-139250', 'nordbygg-2026', 'Lavoro', 'B01:52', null, 'https://www.lavoroeurope.com', 'assets/images/exhibitors/nordbygg-2026-lavoro.jpg'),
  ('nordbygg-2026-exhibitor-134586', 'nordbygg-2026', 'Layher AB', 'B07:21', null, 'https://www.layher.se', null),
  ('nordbygg-2026-exhibitor-135276', 'nordbygg-2026', 'Lca.no', 'C01:06', jsonb_build_object('en', 'LCA.no AS is a provider of tools and services for environmental documentation and innovation. Our tools use research-based data and comply with international standards to ensure the best possible quality. This means that our tools have a high professional quality while making the development of environmental documentation and analyzes effective and resource-saving.', 'sv', 'LCA.no AS is a provider of tools and services for environmental documentation and innovation. Our tools use research-based data and comply with international standards to ensure the best possible quality. This means that our tools have a high professional quality while making the development of environmental documentation and analyzes effective and resource-saving.'), 'https://www.lca.no', 'assets/images/exhibitors/nordbygg-2026-lca-no.jpg'),
  ('nordbygg-2026-exhibitor-137849', 'nordbygg-2026', 'Lett Tak Systemer AS', 'C13:61', jsonb_build_object('en', 'Lett-Tak Systemer AS har sedan 1980 projekterat, producerat, levererat och monterat skräddarsydda och hållbara taklösningar för alla typer av byggnader i Norden. Taklösningarna föredras särskilt när det ställs höga krav på byggtid, miljö och tekniska egenskaper.', 'sv', 'Lett-Tak Systemer AS har sedan 1980 projekterat, producerat, levererat och monterat skräddarsydda och hållbara taklösningar för alla typer av byggnader i Norden. Taklösningarna föredras särskilt när det ställs höga krav på byggtid, miljö och tekniska egenskaper.'), 'https://lett-tak.no/sv', 'assets/images/exhibitors/nordbygg-2026-lett-tak-systemer-as.jpg'),
  ('nordbygg-2026-exhibitor-134530', 'nordbygg-2026', 'Liftroller', 'B08:40', jsonb_build_object('en', 'Effektiv materiallogistik – direkt in i byggnaden
Liftroller utvecklar smarta lösningar som förenklar och effektiviserar materialhanteringen på byggarbetsplatser. Våra system gör det möjligt att leverera material direkt från kran in genom fasaden – och transportera det hela vägen fram till montageplatsen, snabbt och säkert.
Resultatet? Mindre bäring, färre lyftmoment och en betydligt bättre arbetsmiljö.

Genom Liftroller Rental Sweden AB erbjuder vi flexibla uthyrningslösningar anpassade efter projektets behov. För kunder som vill bygga egen kapacitet erbjuder vi även direktköp av våra produkter.
Våra rådgivare har erfarenhet från komplexa byggprojekt och hjälper dig att hitta rätt setup – oavsett om det gäller nyproduktion eller rehab.

Du känner din byggarbetsplats. Vi optimerar logistiken.
Besök oss på mässan eller kontakta oss direkt:
+46 73 44 18 133
liftroller.se', 'sv', 'Effektiv materiallogistik – direkt in i byggnaden
Liftroller utvecklar smarta lösningar som förenklar och effektiviserar materialhanteringen på byggarbetsplatser. Våra system gör det möjligt att leverera material direkt från kran in genom fasaden – och transportera det hela vägen fram till montageplatsen, snabbt och säkert.
Resultatet? Mindre bäring, färre lyftmoment och en betydligt bättre arbetsmiljö.

Genom Liftroller Rental Sweden AB erbjuder vi flexibla uthyrningslösningar anpassade efter projektets behov. För kunder som vill bygga egen kapacitet erbjuder vi även direktköp av våra produkter.
Våra rådgivare har erfarenhet från komplexa byggprojekt och hjälper dig att hitta rätt setup – oavsett om det gäller nyproduktion eller rehab.

Du känner din byggarbetsplats. Vi optimerar logistiken.
Besök oss på mässan eller kontakta oss direkt:
+46 73 44 18 133
liftroller.se'), 'https://www.liftroller.se', 'assets/images/exhibitors/nordbygg-2026-liftroller.jpg'),
  ('nordbygg-2026-exhibitor-137599', 'nordbygg-2026', 'LIGHT BOY', 'B10:12', jsonb_build_object('en', 'LIGHT BOY EUROPE AB – Företagsprofil
På LIGHT BOY EUROPE AB tror vi att bra belysning gör mer än att bara lysa upp en plats – den skapar säkerhet, komfort och produktivitet.

Som den europeiska grenen av japanska LIGHT BOY CO., LTD., har vi med oss över 40 års erfarenhet av att utveckla mobila belysningslösningar som är enkla att använda, lätta att transportera och smidiga att arbeta med.

Från bländfria ballongljus till kompakta ljustorn som kan tas med överallt – våra system är skapade för att stötta byggarbetare, evenemangsarrangörer och räddningstjänst, oavsett var pålitligt ljus behövs.

Vi grundades i Sverige 2022 och vårt mål är att lysa upp hela Europa. Vi är alltid öppna för nya partnerskap – så om du letar efter belysning som presterar maximalt och samtidigt är användarvänlig, kom och prata med oss.', 'sv', 'LIGHT BOY EUROPE AB – Företagsprofil
På LIGHT BOY EUROPE AB tror vi att bra belysning gör mer än att bara lysa upp en plats – den skapar säkerhet, komfort och produktivitet.

Som den europeiska grenen av japanska LIGHT BOY CO., LTD., har vi med oss över 40 års erfarenhet av att utveckla mobila belysningslösningar som är enkla att använda, lätta att transportera och smidiga att arbeta med.

Från bländfria ballongljus till kompakta ljustorn som kan tas med överallt – våra system är skapade för att stötta byggarbetare, evenemangsarrangörer och räddningstjänst, oavsett var pålitligt ljus behövs.

Vi grundades i Sverige 2022 och vårt mål är att lysa upp hela Europa. Vi är alltid öppna för nya partnerskap – så om du letar efter belysning som presterar maximalt och samtidigt är användarvänlig, kom och prata med oss.'), 'https://www.light-boy.eu/', 'assets/images/exhibitors/nordbygg-2026-light-boy.jpg'),
  ('nordbygg-2026-exhibitor-137405', 'nordbygg-2026', 'Limestone Factories of Estonia: BRAND: REVAL STONE', 'C07:60', jsonb_build_object('en', 'Limestone Factories of Estonia OÜ, verksamt under varumärket Reval Stone, är en av Estlands mest erfarna producenter av natursten med industriella rötter som sträcker sig tillbaka till 1967.

Vi hanterar hela värdekedjan – från stenbrott till färdiga produkter – och levererar högkvalitativ estnisk kalksten och dolomit för fasader, golv, trappor, fönsterbänkar och kundanpassade arkitektoniska element. Våra egna stenbrott i Tallinn, Saaremaa och Märjamaa säkerställer jämn kvalitet, full spårbarhet och leveranssäkerhet.

Med över 55 års erfarenhet kombinerar vi traditionellt hantverk med modern produktionsteknik för att betjäna arkitekter, fastighetsutvecklare och entreprenörer i Baltikum, Skandinavien och övriga Europa. Sedan 2023 drivs vår produktion med 100 % förnybar energi, vilket stödjer hållbara byggmål.

Utvalda referensprojekt i Estland:
Konstmuseet KUMU, Tallinn – omfattande användning av Kaarma- och Orgita-dolomit i fasader samt Reval-kalksten i golv;
Tallinns universitets huvudbyggnad – fasad i Kaarma-dolomit;
Noblessner-kvarteret, Tallinn – slipade fasader i Kaarma- och Orgita-dolomit på flera bostadsbyggnader m.fl.

Referensprojekt i Lettland:
Estlands ambassad i Riga – arkitektoniskt projekt med estnisk naturdolomit som speglar minimalistisk nordisk design och kulturell identitet.

Referenser i Sverige:
Pineedgevilla samt många andra offentliga och privata byggnader.', 'sv', 'Limestone Factories of Estonia OÜ, verksamt under varumärket Reval Stone, är en av Estlands mest erfarna producenter av natursten med industriella rötter som sträcker sig tillbaka till 1967.

Vi hanterar hela värdekedjan – från stenbrott till färdiga produkter – och levererar högkvalitativ estnisk kalksten och dolomit för fasader, golv, trappor, fönsterbänkar och kundanpassade arkitektoniska element. Våra egna stenbrott i Tallinn, Saaremaa och Märjamaa säkerställer jämn kvalitet, full spårbarhet och leveranssäkerhet.

Med över 55 års erfarenhet kombinerar vi traditionellt hantverk med modern produktionsteknik för att betjäna arkitekter, fastighetsutvecklare och entreprenörer i Baltikum, Skandinavien och övriga Europa. Sedan 2023 drivs vår produktion med 100 % förnybar energi, vilket stödjer hållbara byggmål.

Utvalda referensprojekt i Estland:
Konstmuseet KUMU, Tallinn – omfattande användning av Kaarma- och Orgita-dolomit i fasader samt Reval-kalksten i golv;
Tallinns universitets huvudbyggnad – fasad i Kaarma-dolomit;
Noblessner-kvarteret, Tallinn – slipade fasader i Kaarma- och Orgita-dolomit på flera bostadsbyggnader m.fl.

Referensprojekt i Lettland:
Estlands ambassad i Riga – arkitektoniskt projekt med estnisk naturdolomit som speglar minimalistisk nordisk design och kulturell identitet.

Referenser i Sverige:
Pineedgevilla samt många andra offentliga och privata byggnader.'), 'https://www.revalstone.com', 'assets/images/exhibitors/nordbygg-2026-limestone-factories-of-estonia-brand-reval-stone.jpg'),
  ('nordbygg-2026-exhibitor-137070', 'nordbygg-2026', 'Lindab Sverige AB', 'C17:51', null, 'https://www.lindab.se', 'assets/images/exhibitors/nordbygg-2026-lindab-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-138397', 'nordbygg-2026', 'Lindinvent', 'A17:02', jsonb_build_object('en', 'Lindinvents systemlösning för styrning av ventilation, belysning och solavskärmning består av den mest energieffektiva teknologin och algoritmerna och har den lägsta dokumenterade livscykel- och installationskostnaden.

Tusentals fastigheter över hela Sverige har en systemlösning från Lindinvent som skapar en bättre arbetsmiljö för de som arbetar där samtidigt som stora mängder energi sparas. Vi har ett fokus i åtanke när vi utvecklar våra produkter; hållbarhet.', 'sv', 'Lindinvents systemlösning för styrning av ventilation, belysning och solavskärmning består av den mest energieffektiva teknologin och algoritmerna och har den lägsta dokumenterade livscykel- och installationskostnaden.

Tusentals fastigheter över hela Sverige har en systemlösning från Lindinvent som skapar en bättre arbetsmiljö för de som arbetar där samtidigt som stora mängder energi sparas. Vi har ett fokus i åtanke när vi utvecklar våra produkter; hållbarhet.'), 'https://www.lindinvent.se', 'assets/images/exhibitors/nordbygg-2026-lindinvent.jpg'),
  ('nordbygg-2026-exhibitor-137118', 'nordbygg-2026', 'Lindner Scandinavia', 'C10:32', null, 'https://www.linscan.se', null),
  ('nordbygg-2026-exhibitor-138007', 'nordbygg-2026', 'Linervent AB', 'A20:29', null, 'https://www.linervent.se', null),
  ('nordbygg-2026-exhibitor-137894', 'nordbygg-2026', 'Lingbo Kulturfönster', 'C07:33H', jsonb_build_object('en', 'Svensktillverkade fönster och dörrar med äkta spröjs och speglar. Kundanpassade produkter av kvalitetsträ för dig som respektfullt renoverar ett gammalt hus eller bygger nytt med det lilla extra.', 'sv', 'Svensktillverkade fönster och dörrar med äkta spröjs och speglar. Kundanpassade produkter av kvalitetsträ för dig som respektfullt renoverar ett gammalt hus eller bygger nytt med det lilla extra.'), 'https://www.lingbo.se', 'assets/images/exhibitors/nordbygg-2026-lingbo-kulturfonster.jpg'),
  ('nordbygg-2026-exhibitor-139302', 'nordbygg-2026', 'Litescreen Sweden AB', 'B08:42', null, 'https://www.litescreen.se', null),
  ('nordbygg-2026-exhibitor-140102', 'nordbygg-2026', 'LJ Solutions', 'C03:41', jsonb_build_object('en', 'LJ Solutions works with a passion for facades. With our upcyclable cladding we provide healthy and beautiful facades, where the indoor climate, the living environment and social sustainability come first.

Contact is paramount in their cooperation: We consider social sustainability enormously important towards our partners, clients and colleagues. But also towards our living environment. With our sustainable product range we steer on products that are reusable, upcyclable and efficiently assembled, without nitrogen and CO2 emissions. Our products are produced in Europe, to guarantee high quality products and to limit CO2?and transport.

Neolife® stands for natural wood composite cladding that barely contains any plastic. The natural substance lignine in wood is also the binder instead of plastics. And minerals are responsible for the fireresistantclass D, C or B. No a coating needed! This makes them maintenance-free and circular: the panels can be fully upcycled, up to three times!', 'sv', 'LJ Solutions works with a passion for facades. With our upcyclable cladding we provide healthy and beautiful facades, where the indoor climate, the living environment and social sustainability come first.

Contact is paramount in their cooperation: We consider social sustainability enormously important towards our partners, clients and colleagues. But also towards our living environment. With our sustainable product range we steer on products that are reusable, upcyclable and efficiently assembled, without nitrogen and CO2 emissions. Our products are produced in Europe, to guarantee high quality products and to limit CO2?and transport.

Neolife® stands for natural wood composite cladding that barely contains any plastic. The natural substance lignine in wood is also the binder instead of plastics. And minerals are responsible for the fireresistantclass D, C or B. No a coating needed! This makes them maintenance-free and circular: the panels can be fully upcycled, up to three times!'), 'https://ljsolutions.nl/', 'assets/images/exhibitors/nordbygg-2026-lj-solutions.jpg'),
  ('nordbygg-2026-exhibitor-133979', 'nordbygg-2026', 'LK Systems AB', 'A05:20', jsonb_build_object('en', 'Din leverantör inom VVS
LK Systems är ledande i Norden inom lösningar för värme- och tappvattensystem. Vi utvecklar system för vattenburen golvvärme, tappvatten och renovering. Våra system är enkla att installera och i vår prefabriceringsanläggning tillverkar vi även skräddarsydda system som ytterligare förenklar installationen. Från idé till färdig produkt, här får du de smartaste lösningarna, idag och i framtiden.', 'sv', 'Din leverantör inom VVS
LK Systems är ledande i Norden inom lösningar för värme- och tappvattensystem. Vi utvecklar system för vattenburen golvvärme, tappvatten och renovering. Våra system är enkla att installera och i vår prefabriceringsanläggning tillverkar vi även skräddarsydda system som ytterligare förenklar installationen. Från idé till färdig produkt, här får du de smartaste lösningarna, idag och i framtiden.'), 'https://www.lksystems.se', 'assets/images/exhibitors/nordbygg-2026-lk-systems-ab.jpg'),
  ('nordbygg-2026-exhibitor-134782', 'nordbygg-2026', 'Loggamera AB', 'A15:02', jsonb_build_object('en', 'Vi erbjuder tjänster in om IMD, individuell mätning och debitering och temperaturmätning. Våra kunder är fastighetsägare, bostadsrättsföreningar som vill samla in mätning av el, vatten, laddboxar och värme för debitering. Loggamera har direktintegration med de flesta fastighetssystem och förvaltare på marknaden.', 'sv', 'Vi erbjuder tjänster in om IMD, individuell mätning och debitering och temperaturmätning. Våra kunder är fastighetsägare, bostadsrättsföreningar som vill samla in mätning av el, vatten, laddboxar och värme för debitering. Loggamera har direktintegration med de flesta fastighetssystem och förvaltare på marknaden.'), 'https://www.loggamera.se', 'assets/images/exhibitors/nordbygg-2026-loggamera-ab.jpg'),
  ('nordbygg-2026-exhibitor-137788', 'nordbygg-2026', 'Loimaan Kivi', 'C05:63', jsonb_build_object('en', 'Under vår +100-åriga historia har Loimaan Kivi alltid varit en stark pionjär inom stenbearbetning i Finland och en ledande aktör inom natursten i Norden. Från berg till färdig produkt, nordisk natursten för trädgård och offentlig miljö.', 'sv', 'Under vår +100-åriga historia har Loimaan Kivi alltid varit en stark pionjär inom stenbearbetning i Finland och en ledande aktör inom natursten i Norden. Från berg till färdig produkt, nordisk natursten för trädgård och offentlig miljö.'), 'https://www.natursten.fi', 'assets/images/exhibitors/nordbygg-2026-loimaan-kivi.jpg'),
  ('nordbygg-2026-exhibitor-139314', 'nordbygg-2026', 'Lumenor AB', 'AG:78', jsonb_build_object('en', 'Mobil batteridriven arbetsbelysning.
Lysmaster upp till 5,3meter.', 'sv', 'Mobil batteridriven arbetsbelysning.
Lysmaster upp till 5,3meter.'), 'https://lumenor.se', null),
  ('nordbygg-2026-exhibitor-138222', 'nordbygg-2026', 'Maba Maskin Nordic AB', 'C09:19', jsonb_build_object('en', 'Maba Maskin Nordic AB är ett grossistföretag som utvecklar, importerar, lagerhåller och erbjuder
produkter till framför allt glasmästeribranschen, byggbranschen och planglasindustrin.
Företaget har funnits i sin nuvarande form sedan 2002 men grundades redan 1994.

Vi erbjuder allt från glasräcken, uterum och interiörväggar för glas till maskiner, handverktyg och
förbrukningsartiklar. Vi är stolta återförsäljare för bl.a. Habe fönsterkitt, fog och lim, Danalim fog
och lim, Saheco skjutdörrar, Rexal helglas och aluminiumräcken, Hegla bilstativ, SMT kompaktlager,
Quattrolifts glaslyftare, Kappel batterivakuumlyftare och Battellino slipmaskiner.', 'sv', 'Maba Maskin Nordic AB är ett grossistföretag som utvecklar, importerar, lagerhåller och erbjuder
produkter till framför allt glasmästeribranschen, byggbranschen och planglasindustrin.
Företaget har funnits i sin nuvarande form sedan 2002 men grundades redan 1994.

Vi erbjuder allt från glasräcken, uterum och interiörväggar för glas till maskiner, handverktyg och
förbrukningsartiklar. Vi är stolta återförsäljare för bl.a. Habe fönsterkitt, fog och lim, Danalim fog
och lim, Saheco skjutdörrar, Rexal helglas och aluminiumräcken, Hegla bilstativ, SMT kompaktlager,
Quattrolifts glaslyftare, Kappel batterivakuumlyftare och Battellino slipmaskiner.'), 'https://maba.se', 'assets/images/exhibitors/nordbygg-2026-maba-maskin-nordic-ab.jpg'),
  ('nordbygg-2026-exhibitor-133993', 'nordbygg-2026', 'Macro Design AB', 'A09:14', jsonb_build_object('en', 'Macro Design är en svensk badrumsleverantör med 40 års erfarenhet inom badrumsbranschen och har etablerat ett starkt och uppskattat varumärke för mellan- och premiumsegmentet.

Vi erbjuder ett av Nordens bredaste sortiment av duschlösningar med ett heltäckande urval av duschar, badrumsmöbler, tvättställ, kranar, belysning, toaletter och badkar.
Innovation, attraktiv design och funktionalitet är hörnstenarna i Macro Designs produktutveckling.

Vår ambition är att alltid ligga steget före och skapa produkter med det där lilla extra, utan att tappa fokus på användarvänlighet och kvalitet.

Vi föredrar att arbeta med klassiska material vid tillverkningen av våra produkter, såsom härdat glas, fuktbeständigt trä och massiv ek och ask.

Vårt åtagande ligger i att leverera tidlös och hållbar design av eleganta badrumsmöbler. Utvecklad av Macro Design för att tåla dagligt slitage och bibehålla sin höga kvalitet i många år framöver.

Här & nu. Alltid.', 'sv', 'Macro Design är en svensk badrumsleverantör med 40 års erfarenhet inom badrumsbranschen och har etablerat ett starkt och uppskattat varumärke för mellan- och premiumsegmentet.

Vi erbjuder ett av Nordens bredaste sortiment av duschlösningar med ett heltäckande urval av duschar, badrumsmöbler, tvättställ, kranar, belysning, toaletter och badkar.
Innovation, attraktiv design och funktionalitet är hörnstenarna i Macro Designs produktutveckling.

Vår ambition är att alltid ligga steget före och skapa produkter med det där lilla extra, utan att tappa fokus på användarvänlighet och kvalitet.

Vi föredrar att arbeta med klassiska material vid tillverkningen av våra produkter, såsom härdat glas, fuktbeständigt trä och massiv ek och ask.

Vårt åtagande ligger i att leverera tidlös och hållbar design av eleganta badrumsmöbler. Utvecklad av Macro Design för att tåla dagligt slitage och bibehålla sin höga kvalitet i många år framöver.

Här & nu. Alltid.'), 'https://www.macrodesign.se', 'assets/images/exhibitors/nordbygg-2026-macro-design-ab.jpg'),
  ('nordbygg-2026-exhibitor-138583', 'nordbygg-2026', 'Maczka Group', 'A06:26', null, 'https://venma.pl', null),
  ('nordbygg-2026-exhibitor-139634', 'nordbygg-2026', 'Made of Air Gmbh', 'C05:68', jsonb_build_object('en', 'Made of Air is a climate-focused materials company transforming transforms biocarbon into carbon negative materials aimed at the built environment.

Our technology functionalizes biocarbon into an industry-standard filler for composite materials. Creating compatibility between biocarbon and binders, our IP unlocks material pools as a global carbon sink. Commercial products currently focus on board applications such as facades, interior paneling and sheathing.', 'sv', 'Made of Air is a climate-focused materials company transforming transforms biocarbon into carbon negative materials aimed at the built environment.

Our technology functionalizes biocarbon into an industry-standard filler for composite materials. Creating compatibility between biocarbon and binders, our IP unlocks material pools as a global carbon sink. Commercial products currently focus on board applications such as facades, interior paneling and sheathing.'), 'https://www.madeofair.com', 'assets/images/exhibitors/nordbygg-2026-made-of-air-gmbh.jpg'),
  ('nordbygg-2026-exhibitor-139477', 'nordbygg-2026', 'Mafell AG', 'B06:52', jsonb_build_object('en', 'För att utveckla ett bättre verktyg för snickare och träarbetare tar vi på MAFELL ofta en ny infallsvinkel: Vi ändrar vårt perspektiv och tänker om verktyget helt och hållet på viktiga områden. På så sätt har vi alltid de framtida kraven från träbearbetningsbranschen i åtanke.

Detta sätt att tänka, i kombination med enastående material- och bearbetningskvalitet, resulterar i fantastiska lösningar gång på gång. Till exempel när det gäller funktionalitet och användarvänlighet. Vårt mål är att du inte längre ska behöva tänka på dina verktyg när du arbetar. Helt enkelt för att vi på MAFELL redan har gjort det. Vi har trots allt ett gemensamt mål: det perfekta jobbet. Eller kort sagt:

Creating excellence', 'sv', 'För att utveckla ett bättre verktyg för snickare och träarbetare tar vi på MAFELL ofta en ny infallsvinkel: Vi ändrar vårt perspektiv och tänker om verktyget helt och hållet på viktiga områden. På så sätt har vi alltid de framtida kraven från träbearbetningsbranschen i åtanke.

Detta sätt att tänka, i kombination med enastående material- och bearbetningskvalitet, resulterar i fantastiska lösningar gång på gång. Till exempel när det gäller funktionalitet och användarvänlighet. Vårt mål är att du inte längre ska behöva tänka på dina verktyg när du arbetar. Helt enkelt för att vi på MAFELL redan har gjort det. Vi har trots allt ett gemensamt mål: det perfekta jobbet. Eller kort sagt:

Creating excellence'), 'https://www.mafell.de', 'assets/images/exhibitors/nordbygg-2026-mafell-ag.jpg'),
  ('nordbygg-2026-exhibitor-139892', 'nordbygg-2026', 'Maisan AB', 'A14:13A', jsonb_build_object('en', 'maisan – montören pratar, maisan skriver.

Prata in jobbet. maisan skriver offerten, dokumenterar ÄTA och håller kontoret uppdaterat. I realtid, direkt från fältet. Inga dubbla noteringar. Inget efterarbete.

Med maisans affärsminne bär varje montör företagets samlade kunskap i fickan. Fråga efter materialpriser, kunddata eller tidigare projekt – och få svar direkt på plats.

Ingen månadsavgift. Gratis att starta. Du betalar bara för det du faktiskt använder.

---Exklusivt för NordBygg-besökare:
Live demo - testa direkt - tävlingar med fina priser.

Provsmaka innan vi ses? Testa utan registrering på www.maisan.se

Vi ses!', 'sv', 'maisan – montören pratar, maisan skriver.

Prata in jobbet. maisan skriver offerten, dokumenterar ÄTA och håller kontoret uppdaterat. I realtid, direkt från fältet. Inga dubbla noteringar. Inget efterarbete.

Med maisans affärsminne bär varje montör företagets samlade kunskap i fickan. Fråga efter materialpriser, kunddata eller tidigare projekt – och få svar direkt på plats.

Ingen månadsavgift. Gratis att starta. Du betalar bara för det du faktiskt använder.

---Exklusivt för NordBygg-besökare:
Live demo - testa direkt - tävlingar med fina priser.

Provsmaka innan vi ses? Testa utan registrering på www.maisan.se

Vi ses!'), 'https://www.maisan.se', 'assets/images/exhibitors/nordbygg-2026-maisan-ab.jpg'),
  ('nordbygg-2026-exhibitor-137983', 'nordbygg-2026', 'Maku Stål AB', 'C15:51', jsonb_build_object('en', 'Välkommen till C15:51 och möt oss från Maku!

Kom till montern och upptäck våra hållbara lösningar för fackverk.

Vi är en av Sveriges ledande tillverkare av fackverksbalkar. Vi har producerat fackverk i över 60 år och samlat på oss mycket kunskap och lång erfarenhet.

Svenskt, innovativt och hållbart – i montern möter du, förutom oss, även några av de andra företagen som ingår i Welandkoncernen. Varmt välkommen!', 'sv', 'Välkommen till C15:51 och möt oss från Maku!

Kom till montern och upptäck våra hållbara lösningar för fackverk.

Vi är en av Sveriges ledande tillverkare av fackverksbalkar. Vi har producerat fackverk i över 60 år och samlat på oss mycket kunskap och lång erfarenhet.

Svenskt, innovativt och hållbart – i montern möter du, förutom oss, även några av de andra företagen som ingår i Welandkoncernen. Varmt välkommen!'), 'https://www.maku.se', 'assets/images/exhibitors/nordbygg-2026-maku-stal-ab.jpg'),
  ('nordbygg-2026-exhibitor-139928', 'nordbygg-2026', 'Malmerk Klaasium OÜ', 'C03:51', null, 'https://malmerkklaasium.ee/sv', null),
  ('nordbygg-2026-exhibitor-134780', 'nordbygg-2026', 'Malthe Winje Automation AB', 'A19:12', jsonb_build_object('en', 'Malthe Winje marknadsför och säljer automations-, installations- och VA-lösningar på den svenska marknaden.
Vi har valt våra produkter och leverantörer med omsorg både vad gäller kvalitet och pris för att göra dig som kund/partner konkurrenskraftig på en marknad med höga kundkrav.
Hos oss hittar du produkter och lösningar från leverantörer för både Automation och Installation som passar den svenska marknaden.', 'sv', 'Malthe Winje marknadsför och säljer automations-, installations- och VA-lösningar på den svenska marknaden.
Vi har valt våra produkter och leverantörer med omsorg både vad gäller kvalitet och pris för att göra dig som kund/partner konkurrenskraftig på en marknad med höga kundkrav.
Hos oss hittar du produkter och lösningar från leverantörer för både Automation och Installation som passar den svenska marknaden.'), 'https://www.mwa.se', 'assets/images/exhibitors/nordbygg-2026-malthe-winje-automation-ab.jpg'),
  ('nordbygg-2026-exhibitor-137955', 'nordbygg-2026', 'MANN+HUMMEL VOKES AIR AB', 'A20:26', jsonb_build_object('en', 'MANN+HUMMEL VOKES AIR AB är en del av MANN+HUMMEL-koncernen och är en ledande filtreringsexpert. MANN+HUMMEL-koncernen, med huvudkontor i tyska Ludwigsburg, genererade 2024 en försäljning på ca 4,5 miljarder euro med 21 000 anställda på 80 olika platser över hela världen.

Vår verksamhet i Sverige utgår från huvudkontoret i Svenljunga där vi har produktion, lager, produktutveckling och en försäljningsavdelning som kompletterar vår landsomfattande försäljningsorganisation.

Med koncernens luftfiltreringsutbud erbjuds innovativa filtreringslösningar för ren luft som skyddar människor, maskiner och miljö för en mängd olika tillämpningar: luftfiltrering för fastigheter, sjukvård, datamiljöer, processindustri, elektronikproduktion och life science applikationer.

Vi kombinerar världsledande filtreringskompetens, teknisk innovation och ett stort engagemang för ren luft – oavsett om det är för att förbättra kvaliteten och effektiviteten i en process eller luften där du bor, arbetar, utbildar dig eller vårdas.

Våra luftfilter är designade och producerade med ett specifikt syfte – att ge dig ren luft på det mest effektiva sättet, till den lägsta möjliga kostnaden och med en minimal påverkan på miljön.

Läs mer på https://airfiltration.mann-hummel.com/se-se.html', 'sv', 'MANN+HUMMEL VOKES AIR AB är en del av MANN+HUMMEL-koncernen och är en ledande filtreringsexpert. MANN+HUMMEL-koncernen, med huvudkontor i tyska Ludwigsburg, genererade 2024 en försäljning på ca 4,5 miljarder euro med 21 000 anställda på 80 olika platser över hela världen.

Vår verksamhet i Sverige utgår från huvudkontoret i Svenljunga där vi har produktion, lager, produktutveckling och en försäljningsavdelning som kompletterar vår landsomfattande försäljningsorganisation.

Med koncernens luftfiltreringsutbud erbjuds innovativa filtreringslösningar för ren luft som skyddar människor, maskiner och miljö för en mängd olika tillämpningar: luftfiltrering för fastigheter, sjukvård, datamiljöer, processindustri, elektronikproduktion och life science applikationer.

Vi kombinerar världsledande filtreringskompetens, teknisk innovation och ett stort engagemang för ren luft – oavsett om det är för att förbättra kvaliteten och effektiviteten i en process eller luften där du bor, arbetar, utbildar dig eller vårdas.

Våra luftfilter är designade och producerade med ett specifikt syfte – att ge dig ren luft på det mest effektiva sättet, till den lägsta möjliga kostnaden och med en minimal påverkan på miljön.

Läs mer på https://airfiltration.mann-hummel.com/se-se.html'), 'https://www.airfiltration.mann-hummel.com/se', 'assets/images/exhibitors/nordbygg-2026-mann-hummel-vokes-air-ab.jpg'),
  ('nordbygg-2026-exhibitor-138989', 'nordbygg-2026', 'Mapei AB', 'C08:41', jsonb_build_object('en', 'Mapei är en av världens ledande tillverkare av kemiska produkter för byggindustrin.

I Sverige kanske främst kända för sin breda portfölj av produkter för plattsättning men levererar också lösningar till en mängd andra områden som t ex tunneldrivning, klimatförbättrad betong, golvbeläggning, vattentätning, härdplaster, kolfiberförstärkning, betongrenovering, pooler och mycket mer.

Mapei erbjuder specifika produkter och system för att möta samtliga behov inom byggbranschen, allt med målet att främja en kultur av hållbarhet inom byggsektorn.', 'sv', 'Mapei är en av världens ledande tillverkare av kemiska produkter för byggindustrin.

I Sverige kanske främst kända för sin breda portfölj av produkter för plattsättning men levererar också lösningar till en mängd andra områden som t ex tunneldrivning, klimatförbättrad betong, golvbeläggning, vattentätning, härdplaster, kolfiberförstärkning, betongrenovering, pooler och mycket mer.

Mapei erbjuder specifika produkter och system för att möta samtliga behov inom byggbranschen, allt med målet att främja en kultur av hållbarhet inom byggsektorn.'), 'https://www.mapei.se', 'assets/images/exhibitors/nordbygg-2026-mapei-ab.jpg'),
  ('nordbygg-2026-exhibitor-133998', 'nordbygg-2026', 'Mareld Pro Lighting', 'B01:01', jsonb_build_object('en', 'We create brighter and safer working conditions.

Oavsett om du snickrar, målar, monterar, reparerar, gjuter eller gräver så vill du att din prestation ska vara så nära perfekt som möjligt. Just därför är alla våra produkter skapade med ett enda syfte: Att du ska kunna göra ditt allra bästa i skarpt läge – när ljuset tänds. Vår historia började med en insikt om att dagens mobila arbetsbelysning ofta är undermålig och kan göra stor skada. Men om behovet av bättre arbetsbelysning var gnistan, så var vår drivkraft att bidra till en bättre prestation bränslet.', 'sv', 'We create brighter and safer working conditions.

Oavsett om du snickrar, målar, monterar, reparerar, gjuter eller gräver så vill du att din prestation ska vara så nära perfekt som möjligt. Just därför är alla våra produkter skapade med ett enda syfte: Att du ska kunna göra ditt allra bästa i skarpt läge – när ljuset tänds. Vår historia började med en insikt om att dagens mobila arbetsbelysning ofta är undermålig och kan göra stor skada. Men om behovet av bättre arbetsbelysning var gnistan, så var vår drivkraft att bidra till en bättre prestation bränslet.'), 'https://mareldprolighting.com', 'assets/images/exhibitors/nordbygg-2026-mareld-pro-lighting.jpg'),
  ('nordbygg-2026-exhibitor-140096', 'nordbygg-2026', 'Martinez Tool Company ', 'B01:31', jsonb_build_object('en', 'MTC by Martinez is a division of Martinez Tool Co., born from the same passion for craftsmanship and innovation that built our legendary brand. Designed by the creators of Martinez’s iconic tools, MTC is built for carpenters who demand the legacy, durability, and performance that Martinez is known for, while offering a broader range of options for today’s professionals.', 'sv', 'MTC by Martinez is a division of Martinez Tool Co., born from the same passion for craftsmanship and innovation that built our legendary brand. Designed by the creators of Martinez’s iconic tools, MTC is built for carpenters who demand the legacy, durability, and performance that Martinez is known for, while offering a broader range of options for today’s professionals.'), 'https://mtctool.com', 'assets/images/exhibitors/nordbygg-2026-martinez-tool-company.jpg'),
  ('nordbygg-2026-exhibitor-138629', 'nordbygg-2026', 'Martval OÜ', 'C16:21', null, 'https://www.martval.com', null),
  ('nordbygg-2026-exhibitor-135514', 'nordbygg-2026', 'Mascot Workwear', 'B03:21', jsonb_build_object('en', 'TESTED TO WORK

Du kommer garanterat att kunna hitta några fina arbetskläder, skyddsskor eller andra plagg i MASCOT:s breda produktsortiment. MASCOT har i många år levererat skyddskläder, skor och vanliga arbetskläder till alla branscher och företag.

Vårt sortiment vänder sig till hantverkare och arbetande inom service, transport och industri. Med rätt arbetskläder från MASCOT kommer du att kunna känna dig tryggare på arbetsplatsen. Kvalitet är det viktigaste för MASCOT, och därför använder vi bra tygkvaliteter. Gå på upptäcktsfärd i vårt stora sortiment av arbetskläder, skyddskläder, skyddsskor och tillbehör. MASCOT erbjuder de allra bästa produkterna med fokus på komfort, passform, kvalitet och design.

Vi tillverkar alla våra produkter utifrån vår slogan Tested to Work. Du hittar inga arbetsbyxor, arbetsjackor, skyddsskor eller annat som inte har provats ut till fullo. Vi använder oss av laboratorietester, användartester, kvalitetskontroll och mycket annat när vi väljer metervaror till skyddskläder och arbetskläder. Du kommer omedelbart att märka att MASCOT:s arbetskläder, skyddskläder och skyddsskor är Tested to Work.', 'sv', 'TESTED TO WORK

Du kommer garanterat att kunna hitta några fina arbetskläder, skyddsskor eller andra plagg i MASCOT:s breda produktsortiment. MASCOT har i många år levererat skyddskläder, skor och vanliga arbetskläder till alla branscher och företag.

Vårt sortiment vänder sig till hantverkare och arbetande inom service, transport och industri. Med rätt arbetskläder från MASCOT kommer du att kunna känna dig tryggare på arbetsplatsen. Kvalitet är det viktigaste för MASCOT, och därför använder vi bra tygkvaliteter. Gå på upptäcktsfärd i vårt stora sortiment av arbetskläder, skyddskläder, skyddsskor och tillbehör. MASCOT erbjuder de allra bästa produkterna med fokus på komfort, passform, kvalitet och design.

Vi tillverkar alla våra produkter utifrån vår slogan Tested to Work. Du hittar inga arbetsbyxor, arbetsjackor, skyddsskor eller annat som inte har provats ut till fullo. Vi använder oss av laboratorietester, användartester, kvalitetskontroll och mycket annat när vi väljer metervaror till skyddskläder och arbetskläder. Du kommer omedelbart att märka att MASCOT:s arbetskläder, skyddskläder och skyddsskor är Tested to Work.'), 'https://www.mascot.se', 'assets/images/exhibitors/nordbygg-2026-mascot-workwear.jpg'),
  ('nordbygg-2026-exhibitor-139198', 'nordbygg-2026', 'Masonite Beams', 'C04:11', jsonb_build_object('en', 'Vi optimerar framtidens byggande med våra högpresterande byggsystem baserat på lättbalkar i trä. Genom en unik I-profil minskar vi materialåtgången utan att minska spännvidden.

Uppnå en hög energieffektivitet, lågt klimatavtryck och effektivare montage med Masonite Beams. Hos oss utforskar du olika lösningar som passar både husfabriker, entreprenörer och byggprojekt upp till 8 våningar.

Besök oss på Nordbygg i monter CO4:11 och se hur vi bygger smartare, lättare och mer hållbart.', 'sv', 'Vi optimerar framtidens byggande med våra högpresterande byggsystem baserat på lättbalkar i trä. Genom en unik I-profil minskar vi materialåtgången utan att minska spännvidden.

Uppnå en hög energieffektivitet, lågt klimatavtryck och effektivare montage med Masonite Beams. Hos oss utforskar du olika lösningar som passar både husfabriker, entreprenörer och byggprojekt upp till 8 våningar.

Besök oss på Nordbygg i monter CO4:11 och se hur vi bygger smartare, lättare och mer hållbart.'), 'https://www.masonitebeams.se', 'assets/images/exhibitors/nordbygg-2026-masonite-beams.jpg'),
  ('nordbygg-2026-exhibitor-133942', 'nordbygg-2026', 'Masonite Beams AB', 'C04:11', jsonb_build_object('en', 'Byggma ASA är en av Nordens ledande leverantörer av byggmateriallösningar. Koncernen består av välkända varumärken som Forestia, Huntonit, Smartpanel, Masonite Beams, Uldal och Aneta Lighting. Genom en bred portfölj av innovativa produkter – från högeffektiva lättbalkar och hållbara spånskivor till färdigbehandlade väggsystem – erbjuder Byggma lösningar som sparar tid och minskar miljöpåverkan.

Se produktutbudet och lär känna oss bättre genom att träffa oss i monter CO4:11 på Nordbygg.', 'sv', 'Byggma ASA är en av Nordens ledande leverantörer av byggmateriallösningar. Koncernen består av välkända varumärken som Forestia, Huntonit, Smartpanel, Masonite Beams, Uldal och Aneta Lighting. Genom en bred portfölj av innovativa produkter – från högeffektiva lättbalkar och hållbara spånskivor till färdigbehandlade väggsystem – erbjuder Byggma lösningar som sparar tid och minskar miljöpåverkan.

Se produktutbudet och lär känna oss bättre genom att träffa oss i monter CO4:11 på Nordbygg.'), 'https://www.byggmagroup.se', 'assets/images/exhibitors/nordbygg-2026-masonite-beams-ab.jpg'),
  ('nordbygg-2026-exhibitor-138768', 'nordbygg-2026', 'Maxi Door AB', 'C17:18', jsonb_build_object('en', 'MaxiDoor tillverkar Ståldo¨rrar, sta°lpartier och Aluminiumpartiert i Fro¨vi och Göteborg. Vi tar fram helhetslo¨sningar  och arbetar i na¨ra samarbete med va°ra leveranto¨rer och uppdragsgivare. Allt ifra°n nykonstruktion och formgivning till kundanpassade totallo¨sningar och service gentemot kunder o¨ver hela Sverige.

Va°r verksamhet började redan 1950, da° grundaren Go¨ran Olofsson tillsammans med tva° kompanjoner startade det som sedan skulle bli Fro¨vi Branddo¨rrar. Pa° 1980-talet bytte vi namn till MaxiDoor, och under va°ra 75 a°r i branschen har vi vuxit och utvecklats till en stark och kvalitetsmedveten akto¨r pa° marknaden. Vi ser oss som problemlo¨sare inom sa¨kerhetsomra°det och a¨r idag na¨rmare 85 medarbetare. Bland va°ra kunder finns akto¨rer inom den offentliga sektorn, da¨r vi levererar standardprodukter som do¨rrar och partier till bl.a. skolor sjukhus och fängelser. Vi tar ocksa° fram specialtillverkade sa¨kerhetslo¨sningar fo¨r olika myndigheter och privata kunder.

Sedan 2018 är Pomona-gruppen, ett familjeägt utvecklings- och investmentbolag, huvudägare till MaxiDoor.', 'sv', 'MaxiDoor tillverkar Ståldo¨rrar, sta°lpartier och Aluminiumpartiert i Fro¨vi och Göteborg. Vi tar fram helhetslo¨sningar  och arbetar i na¨ra samarbete med va°ra leveranto¨rer och uppdragsgivare. Allt ifra°n nykonstruktion och formgivning till kundanpassade totallo¨sningar och service gentemot kunder o¨ver hela Sverige.

Va°r verksamhet började redan 1950, da° grundaren Go¨ran Olofsson tillsammans med tva° kompanjoner startade det som sedan skulle bli Fro¨vi Branddo¨rrar. Pa° 1980-talet bytte vi namn till MaxiDoor, och under va°ra 75 a°r i branschen har vi vuxit och utvecklats till en stark och kvalitetsmedveten akto¨r pa° marknaden. Vi ser oss som problemlo¨sare inom sa¨kerhetsomra°det och a¨r idag na¨rmare 85 medarbetare. Bland va°ra kunder finns akto¨rer inom den offentliga sektorn, da¨r vi levererar standardprodukter som do¨rrar och partier till bl.a. skolor sjukhus och fängelser. Vi tar ocksa° fram specialtillverkade sa¨kerhetslo¨sningar fo¨r olika myndigheter och privata kunder.

Sedan 2018 är Pomona-gruppen, ett familjeägt utvecklings- och investmentbolag, huvudägare till MaxiDoor.'), 'https://maxidoor.se', 'assets/images/exhibitors/nordbygg-2026-maxi-door-ab.jpg'),
  ('nordbygg-2026-exhibitor-139655', 'nordbygg-2026', 'Maxkompetens - Rekrytering inom Bygg', 'BG:03', jsonb_build_object('en', 'Vi rekryterar byggingenjörer, specialister, chefer och yrkesarbetare inom bygg, anläggning och infrastruktur.', 'sv', 'Vi rekryterar byggingenjörer, specialister, chefer och yrkesarbetare inom bygg, anläggning och infrastruktur.'), 'https://maxkompetens.se', 'assets/images/exhibitors/nordbygg-2026-maxkompetens-rekrytering-inom-bygg.jpg'),
  ('nordbygg-2026-exhibitor-138977', 'nordbygg-2026', 'MCS Hyrsystem', 'BG:02', jsonb_build_object('en', 'Med mer än fyra decennier av expertis är MCS ett växande globalt företag med en stark kundbas i både Skandinavien och på den internationella marknaden. Lösningarna bidrar till att rental- och byggföretag kan arbeta effektivare, maximera utnyttjandet av utrustning och stärka sin lönsamhet. Kundkretsen spänner över allt från mindre verksamheter till stora internationella koncerner – från de som vuxit ur sina tidigare system och söker modernare verktyg, till företag som satsar på flexibla lösningar som kan växa i takt med affären.
Kunderna återfinns inom både intern och extern uthyrning samt försäljning av bland annat maskiner, verktyg, tillfälliga byggnader och moduler, VVS-utrustning, AV- och eventutrustning, ställningar, fallskydd, lyftutrustning, containrar, trafikanordningar, mätinstrument, WC- och duschmoduler och mycket mer.
Systemet hanterar hela arbetsflödet från offert till fakturering och är utrustat med smarta mobila lösningar som gör arbetet smidigt både på kontoret och ute på fältet. Integrerade kopplingar till ledande ekonomisystem ger enkel och effektiv bokföring.

En inbyggd onlineportal erbjuder uthyrningsföretagens kunder självbetjäning dygnet runt – med möjlighet att själva boka, förlänga eller avsluta hyror, ladda ner dokument och följa orderstatus i realtid. Smarta funktioner för in- och utcheckning säkerställer snabb hantering och hög precision i uthyrningsprocessen, medan specialiserade verktyg för mängdartiklar förenklar uthyrning av exempelvis ställningar, byggmaterial och tillbehör.

En helintegrerad CRM-lösning ger uthyrare kraftfulla verktyg för att hantera kundrelationer, följa upp leads och skapa riktade erbjudanden. Genom att samla kundinformation, kommunikationshistorik och analysdata på ett ställe stärks kundupplevelsen och lojaliteten över tid. Detta möjliggör proaktiv service, snabbare respons och en mer personlig kunddialog.

Från proaktivt underhåll och dynamisk prissättning till optimerad lagerhantering och stärkta kundrelationer – ger MCS uthyrningsföretag allt de behöver för att arbeta smartare, mer lönsamt och med högre kundnöjdhet.

Med introduktionen av nya AI-drivna funktioner tas nästa steg in i en mer automatiserad och datadriven uthyrningsverksamhet. Framtidens uthyrning är redan här.', 'sv', 'Med mer än fyra decennier av expertis är MCS ett växande globalt företag med en stark kundbas i både Skandinavien och på den internationella marknaden. Lösningarna bidrar till att rental- och byggföretag kan arbeta effektivare, maximera utnyttjandet av utrustning och stärka sin lönsamhet. Kundkretsen spänner över allt från mindre verksamheter till stora internationella koncerner – från de som vuxit ur sina tidigare system och söker modernare verktyg, till företag som satsar på flexibla lösningar som kan växa i takt med affären.
Kunderna återfinns inom både intern och extern uthyrning samt försäljning av bland annat maskiner, verktyg, tillfälliga byggnader och moduler, VVS-utrustning, AV- och eventutrustning, ställningar, fallskydd, lyftutrustning, containrar, trafikanordningar, mätinstrument, WC- och duschmoduler och mycket mer.
Systemet hanterar hela arbetsflödet från offert till fakturering och är utrustat med smarta mobila lösningar som gör arbetet smidigt både på kontoret och ute på fältet. Integrerade kopplingar till ledande ekonomisystem ger enkel och effektiv bokföring.

En inbyggd onlineportal erbjuder uthyrningsföretagens kunder självbetjäning dygnet runt – med möjlighet att själva boka, förlänga eller avsluta hyror, ladda ner dokument och följa orderstatus i realtid. Smarta funktioner för in- och utcheckning säkerställer snabb hantering och hög precision i uthyrningsprocessen, medan specialiserade verktyg för mängdartiklar förenklar uthyrning av exempelvis ställningar, byggmaterial och tillbehör.

En helintegrerad CRM-lösning ger uthyrare kraftfulla verktyg för att hantera kundrelationer, följa upp leads och skapa riktade erbjudanden. Genom att samla kundinformation, kommunikationshistorik och analysdata på ett ställe stärks kundupplevelsen och lojaliteten över tid. Detta möjliggör proaktiv service, snabbare respons och en mer personlig kunddialog.

Från proaktivt underhåll och dynamisk prissättning till optimerad lagerhantering och stärkta kundrelationer – ger MCS uthyrningsföretag allt de behöver för att arbeta smartare, mer lönsamt och med högre kundnöjdhet.

Med introduktionen av nya AI-drivna funktioner tas nästa steg in i en mer automatiserad och datadriven uthyrningsverksamhet. Framtidens uthyrning är redan här.'), 'https://www.mcsrentalsoftware.com', 'assets/images/exhibitors/nordbygg-2026-mcs-hyrsystem.jpg'),
  ('nordbygg-2026-exhibitor-139455', 'nordbygg-2026', 'Mekina AB', 'BG:18', jsonb_build_object('en', 'VI REPARERAR DINA VERKTYG
I vår verkstad reparerar, servar och kalibrerar vi majoriteten av fabrikaten på marknaden, så som Milwaukee, Dewalt, Hikoki, Makita, Paslode och många fler. Vi utför även slipning av klingor, knivar och kedjor, samt kalibrering av lasrar och momentnycklar.
Vi är garantiverkstad för över 20 märken och använder oss av originaldelar och godkänd verkstadsutrustning.', 'sv', 'VI REPARERAR DINA VERKTYG
I vår verkstad reparerar, servar och kalibrerar vi majoriteten av fabrikaten på marknaden, så som Milwaukee, Dewalt, Hikoki, Makita, Paslode och många fler. Vi utför även slipning av klingor, knivar och kedjor, samt kalibrering av lasrar och momentnycklar.
Vi är garantiverkstad för över 20 märken och använder oss av originaldelar och godkänd verkstadsutrustning.'), 'https://mekina.se', 'assets/images/exhibitors/nordbygg-2026-mekina-ab.jpg'),
  ('nordbygg-2026-exhibitor-139823', 'nordbygg-2026', 'Menerga', 'A16:14', jsonb_build_object('en', 'Vi skapar ett bra klimat
Sedan 1980 har vi varit ledande inom luftbehandlingsteknik och tagit fram avancerade HVAC-lösningar. Vår resa började med ett unikt koncept: Minimal EnergiAnvändning.', 'sv', 'Vi skapar ett bra klimat
Sedan 1980 har vi varit ledande inom luftbehandlingsteknik och tagit fram avancerade HVAC-lösningar. Vår resa började med ett unikt koncept: Minimal EnergiAnvändning.'), 'https://www.menerga.com/sv', 'assets/images/exhibitors/nordbygg-2026-menerga.jpg'),
  ('nordbygg-2026-exhibitor-134729', 'nordbygg-2026', 'MESTO Spritzenfabrik Ernst Stockburger GmbH', 'B11:31', jsonb_build_object('en', 'MESTO – Tysk spruttillverkare sedan 1919

Familjeföretaget MESTO leder världsmarknaden för sprutor till byggbranschen. Våra högkvalitativa modeller applicerar perfekt formsprutor, yt-härdare och andra byggkemikalier. Upptäck effektiva manuella och batteridrivna sprutor för moderna byggplatser.

100 år av passion och innovation från Freiberg am Neckar – skräddarsydda lösningar för dig.', 'sv', 'MESTO – Tysk spruttillverkare sedan 1919

Familjeföretaget MESTO leder världsmarknaden för sprutor till byggbranschen. Våra högkvalitativa modeller applicerar perfekt formsprutor, yt-härdare och andra byggkemikalier. Upptäck effektiva manuella och batteridrivna sprutor för moderna byggplatser.

100 år av passion och innovation från Freiberg am Neckar – skräddarsydda lösningar för dig.'), 'https://www.mesto.de', 'assets/images/exhibitors/nordbygg-2026-mesto-spritzenfabrik-ernst-stockburger-gmbh.jpg'),
  ('nordbygg-2026-exhibitor-133988', 'nordbygg-2026', 'Metalcolour Sverige AB', 'C17:61', jsonb_build_object('en', 'For 50 years Metalcolour has been providing the highest quality of film laminated metals to the marine, train and construction industries.

The DOBEL® product range could not be better suited to the design and manufacture of exclusive and durable interiors.
Metalcolour and DOBEL® are well known and trusted brands. Flexibility, Innovation and High Quality are our core values and our service approach and delivery performance are highly appreciated among our partners.
We have over 50 years of experience working with laminated metals and the evolution into exterior doors has been both natural and logical. Our products can be found all over the world resisting the elements and offering the highest standards of reliability.', 'sv', 'For 50 years Metalcolour has been providing the highest quality of film laminated metals to the marine, train and construction industries.

The DOBEL® product range could not be better suited to the design and manufacture of exclusive and durable interiors.
Metalcolour and DOBEL® are well known and trusted brands. Flexibility, Innovation and High Quality are our core values and our service approach and delivery performance are highly appreciated among our partners.
We have over 50 years of experience working with laminated metals and the evolution into exterior doors has been both natural and logical. Our products can be found all over the world resisting the elements and offering the highest standards of reliability.'), 'https://www.metalcolour.com', 'assets/images/exhibitors/nordbygg-2026-metalcolour-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-134999', 'nordbygg-2026', 'Metro Therm AB', 'A03:30', jsonb_build_object('en', 'Nu kopplar vi upp fastighetscentralen.

Med Online-konceptet blir våra beprövade Superb fjärrvärmecentraler uppkopplade – med möjlighet till övervakning och fjärrsupport.

I montern visar vi:
Superb S Online, Superb M Online, Superb XL Online, golvstående centralen Mila samt varmvattenberedarna Cabinet 110 R och Connected Black 300 R.

Välkommen till vår monter!', 'sv', 'Nu kopplar vi upp fastighetscentralen.

Med Online-konceptet blir våra beprövade Superb fjärrvärmecentraler uppkopplade – med möjlighet till övervakning och fjärrsupport.

I montern visar vi:
Superb S Online, Superb M Online, Superb XL Online, golvstående centralen Mila samt varmvattenberedarna Cabinet 110 R och Connected Black 300 R.

Välkommen till vår monter!'), 'https://www.metrotherm.se', 'assets/images/exhibitors/nordbygg-2026-metro-therm-ab.jpg'),
  ('nordbygg-2026-exhibitor-139716', 'nordbygg-2026', 'Metroc Oy', 'BG:07', jsonb_build_object('en', 'Metroc erbjuder AI-baserad mjukvara för företag inom bygg, fastighet och investeringar. Med data om kommande renoveringar och investeringar i bostadsrättsföreningar hjälper vi våra kunder att hitta rätt affärsmöjligheter i rätt tid.', 'sv', 'Metroc erbjuder AI-baserad mjukvara för företag inom bygg, fastighet och investeringar. Med data om kommande renoveringar och investeringar i bostadsrättsföreningar hjälper vi våra kunder att hitta rätt affärsmöjligheter i rätt tid.'), 'https://metroc.ai/sv', 'assets/images/exhibitors/nordbygg-2026-metroc-oy.jpg'),
  ('nordbygg-2026-exhibitor-137544', 'nordbygg-2026', 'Metsä Wood', 'C13:23', jsonb_build_object('en', 'Metsä Wood erbjuder de bästa träprodukterna för bygg-, industri- och distributionskundernas behov. Vårt mål är att vara våra kunders bästa partner. Med vår hjälp kan du uttnyttja de nästan oändliga möjligheterna med trä. Vi använder världens bästa förnybara råmaterial, alltid spårbart till hållbart skötta skogar i norr. Våra viktigaste produkter är Kerto® LVL och björk- och granplywood.', 'sv', 'Metsä Wood erbjuder de bästa träprodukterna för bygg-, industri- och distributionskundernas behov. Vårt mål är att vara våra kunders bästa partner. Med vår hjälp kan du uttnyttja de nästan oändliga möjligheterna med trä. Vi använder världens bästa förnybara råmaterial, alltid spårbart till hållbart skötta skogar i norr. Våra viktigaste produkter är Kerto® LVL och björk- och granplywood.'), 'https://www.metsagroup.com/metsawood/', 'assets/images/exhibitors/nordbygg-2026-metsa-wood.jpg'),
  ('nordbygg-2026-exhibitor-137351', 'nordbygg-2026', 'Micatrone', 'A18:10', null, 'https://www.micatrone.se', null),
  ('nordbygg-2026-exhibitor-139850', 'nordbygg-2026', 'Midsummer AB', 'A21:17', jsonb_build_object('en', 'Midsummer är den enda tillverkaren av solpaneler i EU. Företaget har sedan 2004 utvecklad en egen unik solpanel som levererar världens renaste el med endast 6 grCO2/kvm. Våra lätta solpaneler på endast 3 kg/kvm installeras utan penetrering av tätskiktet. Ypperligt när nu EU skall förbereda för solenergi genom EPBD direktivet.', 'sv', 'Midsummer är den enda tillverkaren av solpaneler i EU. Företaget har sedan 2004 utvecklad en egen unik solpanel som levererar världens renaste el med endast 6 grCO2/kvm. Våra lätta solpaneler på endast 3 kg/kvm installeras utan penetrering av tätskiktet. Ypperligt när nu EU skall förbereda för solenergi genom EPBD direktivet.'), 'https://www.midsummer.se', 'assets/images/exhibitors/nordbygg-2026-midsummer-ab.jpg'),
  ('nordbygg-2026-exhibitor-139071', 'nordbygg-2026', 'Mill Panel BV', 'C13:21', null, 'https://www.millpanel.com', 'assets/images/exhibitors/nordbygg-2026-mill-panel-bv.jpg'),
  ('nordbygg-2026-exhibitor-135275', 'nordbygg-2026', 'Milwaukee', 'B01:11', null, 'https://www.milwaukeetool.se', 'assets/images/exhibitors/nordbygg-2026-milwaukee.jpg'),
  ('nordbygg-2026-exhibitor-136524', 'nordbygg-2026', 'Mirka', 'B03:40', jsonb_build_object('en', 'Mirka Ltd är ett globalt, familjeägt företag. Vi är dedikerade till slutet och strävar alltid efter att förnya och upptäcka innovativa lösningar inom ytbehandlingsteknologi. Med årtionden av erfarenhet är vi världsledande inom ytbehandlingsteknik och erbjuder innovativa lösningar för ytbehandling och precisionsslipning.

Välkommen till vår monter B03:40 för att prova på att slipa med våra senaste slipmaterial, slipmaskiner och tillbehör. Besök vår webb för mer info: https://www.mirka.com/sv-se/produkter/nordbygg-2026/', 'sv', 'Mirka Ltd är ett globalt, familjeägt företag. Vi är dedikerade till slutet och strävar alltid efter att förnya och upptäcka innovativa lösningar inom ytbehandlingsteknologi. Med årtionden av erfarenhet är vi världsledande inom ytbehandlingsteknik och erbjuder innovativa lösningar för ytbehandling och precisionsslipning.

Välkommen till vår monter B03:40 för att prova på att slipa med våra senaste slipmaterial, slipmaskiner och tillbehör. Besök vår webb för mer info: https://www.mirka.com/sv-se/produkter/nordbygg-2026/'), 'https://www.mirka.se', 'assets/images/exhibitors/nordbygg-2026-mirka.jpg'),
  ('nordbygg-2026-exhibitor-136566', 'nordbygg-2026', 'MiTek', 'C03:20', jsonb_build_object('en', 'MiTek erbjuder system för dimensionering, kalkylering och produktion av takkonstruktioner, väggelement och golvsystem till husfabrikanter och takstolsindustrin.', 'sv', 'MiTek erbjuder system för dimensionering, kalkylering och produktion av takkonstruktioner, väggelement och golvsystem till husfabrikanter och takstolsindustrin.'), 'https://www.mitekab.se', 'assets/images/exhibitors/nordbygg-2026-mitek.jpg'),
  ('nordbygg-2026-exhibitor-134003', 'nordbygg-2026', 'MIVO Technology AB', 'A15:11', jsonb_build_object('en', 'Vi utvecklar, marknadsför och säljer smarta produkter för energimätning och insamling av mätdata i fastigheter. Våra produkter och lösningar kan användas för IMD, automation och energiuppföljning.

Med vår expertis inom energimätning, inbyggda system och datainsamling hjälper vi fastighetsägare med öppna och användarvänliga produkter. Vårt mål är att vara den ledande leverantören inom mätning och mätvärdesinsamling, och vi vill bidra till energieffektivare fastigheter genom innovativa produkter och digitalisering.', 'sv', 'Vi utvecklar, marknadsför och säljer smarta produkter för energimätning och insamling av mätdata i fastigheter. Våra produkter och lösningar kan användas för IMD, automation och energiuppföljning.

Med vår expertis inom energimätning, inbyggda system och datainsamling hjälper vi fastighetsägare med öppna och användarvänliga produkter. Vårt mål är att vara den ledande leverantören inom mätning och mätvärdesinsamling, och vi vill bidra till energieffektivare fastigheter genom innovativa produkter och digitalisering.'), 'https://Mivo.se', 'assets/images/exhibitors/nordbygg-2026-mivo-technology-ab.jpg'),
  ('nordbygg-2026-exhibitor-139805', 'nordbygg-2026', 'ML DESIGN POLAND Sp.zoo', null, null, 'https://www.mldesign.pl', null),
  ('nordbygg-2026-exhibitor-135229', 'nordbygg-2026', 'MLVI Merikarvian LVI-Tuote Oy', 'A06:33', null, 'https://www.mlvi.fi', null),
  ('nordbygg-2026-exhibitor-137059', 'nordbygg-2026', 'Moasure', 'B09:10', jsonb_build_object('en', 'Moasure är världens första och enda rörelsebaserade mätverktyg, som revolutionerar arbetsflödet för yrkesverksamma över hela världen. Enheten använder högpresterande rörelsesensorer för att registrera X-, Y- och Z-data medan den rör sig, och mäter samtidigt samt ritar upp komplexa och oregelbundna projekt.

Moasure beräknar automatiskt omkrets, yta, höjd, lutning och volym, och samlar in viktig mätdata utan behov av GPS, Wi-Fi eller mobilsignal.

Den Bluetooth-anslutna appen omvandlar mätningarna till dynamiska 2D- och 3D-visualiseringar i realtid direkt på din smartphone-skärm, där du kan visa, redigera och spara mätningar samt exportera dem som PDF/CSV eller direkt till CAD-program utan extra kostnad.

Spara timmar av arbetstid och vinn fler jobb med Moasure.', 'sv', 'Moasure är världens första och enda rörelsebaserade mätverktyg, som revolutionerar arbetsflödet för yrkesverksamma över hela världen. Enheten använder högpresterande rörelsesensorer för att registrera X-, Y- och Z-data medan den rör sig, och mäter samtidigt samt ritar upp komplexa och oregelbundna projekt.

Moasure beräknar automatiskt omkrets, yta, höjd, lutning och volym, och samlar in viktig mätdata utan behov av GPS, Wi-Fi eller mobilsignal.

Den Bluetooth-anslutna appen omvandlar mätningarna till dynamiska 2D- och 3D-visualiseringar i realtid direkt på din smartphone-skärm, där du kan visa, redigera och spara mätningar samt exportera dem som PDF/CSV eller direkt till CAD-program utan extra kostnad.

Spara timmar av arbetstid och vinn fler jobb med Moasure.'), 'https://moasure.se', 'assets/images/exhibitors/nordbygg-2026-moasure.jpg'),
  ('nordbygg-2026-exhibitor-139315', 'nordbygg-2026', 'MOBLRN - digitala produktutbildningar', 'BG:17', jsonb_build_object('en', 'Moblrn är plattformen för digitala produktutbildningar som används av Sveriges ledande återförsäljare och leverantörer inom byggmaterialhandeln.

Exempel på kunder och partners är: Beijer Bygg, Optimera, Mestergruppen, Derome, Bosch, Essve, Plannja, Saint Gobain, Nilfisk, Milwaukee och Festool.

Med Moblrns koncept för digitala produktutbildningar kan utbildning snabbt och effektivt distribueras, engagemang kan följas upp och rätt kunskap kan säkerställas.

Läs mer här: https://www.moblrn.com/produktutbildning', 'sv', 'Moblrn är plattformen för digitala produktutbildningar som används av Sveriges ledande återförsäljare och leverantörer inom byggmaterialhandeln.

Exempel på kunder och partners är: Beijer Bygg, Optimera, Mestergruppen, Derome, Bosch, Essve, Plannja, Saint Gobain, Nilfisk, Milwaukee och Festool.

Med Moblrns koncept för digitala produktutbildningar kan utbildning snabbt och effektivt distribueras, engagemang kan följas upp och rätt kunskap kan säkerställas.

Läs mer här: https://www.moblrn.com/produktutbildning'), 'https://www.moblrn.com', 'assets/images/exhibitors/nordbygg-2026-moblrn-digitala-produktutbildningar.jpg'),
  ('nordbygg-2026-exhibitor-139181', 'nordbygg-2026', 'Modul-System HH AB', 'AG:110', jsonb_build_object('en', 'Kompletta lösningar för servicefordon. Hos Modul-System hittar du bilinredning, arbetsbelysning och digitala verktyg för en effektiv fordonsflotta.', 'sv', 'Kompletta lösningar för servicefordon. Hos Modul-System hittar du bilinredning, arbetsbelysning och digitala verktyg för en effektiv fordonsflotta.'), 'https://www.modul-system.com', 'assets/images/exhibitors/nordbygg-2026-modul-system-hh-ab.jpg'),
  ('nordbygg-2026-exhibitor-138396', 'nordbygg-2026', 'Modus Sverige AB', 'C06:51', jsonb_build_object('en', 'Modus är marknadsledande inom hållbara rumslösningar för kommersiella fastigheter. Med över 70 års erfarenhet skapar vi flexibla och framtidssäkra kontorsmiljöer där människor trivs och företag kan växa.

Genom våra återbrukbara rumslösningar och vårt återbrukserbjudande Modus re:make, där återbrukat material integreras i nya projekt, hjälper vi fastighetsägare att sänka sitt klimatavtryck - utan att kompromissa med funktion, kvalitet eller estetik.', 'sv', 'Modus är marknadsledande inom hållbara rumslösningar för kommersiella fastigheter. Med över 70 års erfarenhet skapar vi flexibla och framtidssäkra kontorsmiljöer där människor trivs och företag kan växa.

Genom våra återbrukbara rumslösningar och vårt återbrukserbjudande Modus re:make, där återbrukat material integreras i nya projekt, hjälper vi fastighetsägare att sänka sitt klimatavtryck - utan att kompromissa med funktion, kvalitet eller estetik.'), 'https://www.modussverige.se', 'assets/images/exhibitors/nordbygg-2026-modus-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-137700', 'nordbygg-2026', 'MonZon', 'B06:32', null, 'https://www.monzon.se', null),
  ('nordbygg-2026-exhibitor-138956', 'nordbygg-2026', 'Morgana', 'C09:33', null, 'https://www.morgana.se', null),
  ('nordbygg-2026-exhibitor-138941', 'nordbygg-2026', 'Mowida AB - Fastighetssystem', 'AG:67', jsonb_build_object('en', 'Mowida är ett modernt fastighetssystem som förenklar och effektiviserar fastighetsförvaltning. Plattformen är utvecklad för både fastighetsägare, ekonomer och förvaltare. Systemet samlar ekonomi, drift och kommunikation i samma system – lätt att använda, säkert och anpassat för dagens digitala arbetssätt. Marknadens högst rankade integration mot ekonomisystemet Fortnox.', 'sv', 'Mowida är ett modernt fastighetssystem som förenklar och effektiviserar fastighetsförvaltning. Plattformen är utvecklad för både fastighetsägare, ekonomer och förvaltare. Systemet samlar ekonomi, drift och kommunikation i samma system – lätt att använda, säkert och anpassat för dagens digitala arbetssätt. Marknadens högst rankade integration mot ekonomisystemet Fortnox.'), null, 'assets/images/exhibitors/nordbygg-2026-mowida-ab-fastighetssystem.jpg'),
  ('nordbygg-2026-exhibitor-140141', 'nordbygg-2026', 'MP ALUMINIUM', 'C13:33', null, 'https://www.mpaluminium.p', 'assets/images/exhibitors/nordbygg-2026-mp-aluminium.jpg'),
  ('nordbygg-2026-exhibitor-139574', 'nordbygg-2026', 'Ms2 Protect AB', 'B03:12', null, 'https://ms2protect.se', 'assets/images/exhibitors/nordbygg-2026-ms2-protect-ab.jpg'),
  ('nordbygg-2026-exhibitor-136364', 'nordbygg-2026', 'Munters Europe AB', 'A19:20', jsonb_build_object('en', 'Munters är en global ledare inom energieffektiva och hållbara klimatlösningar. Vi erbjuder innovativa lösningar till kunder i många olika industrier och verksamheter där kontroll av luftfuktighet, temperatur och energieffektivitet inomhus är verksamhetskritiska.

Med vår mångåriga erfarenhet från klimatkontroll i olika branscher hjälper vi verksamheter att minska risken för kondens, mögel, korrosion och frost. Vi tar fram den optimala klimatlösningen för varje applikation. Vi erbjuder allt från enklare avfuktare till helhetslösningar, alltid anpassade efter varje kunds unika behov, och vi har lokala servicetekniker på plats i hela Sverige.

Välkommen att träffa våra experter på Nordbygg!

Läs mer på www.munters.com.', 'sv', 'Munters är en global ledare inom energieffektiva och hållbara klimatlösningar. Vi erbjuder innovativa lösningar till kunder i många olika industrier och verksamheter där kontroll av luftfuktighet, temperatur och energieffektivitet inomhus är verksamhetskritiska.

Med vår mångåriga erfarenhet från klimatkontroll i olika branscher hjälper vi verksamheter att minska risken för kondens, mögel, korrosion och frost. Vi tar fram den optimala klimatlösningen för varje applikation. Vi erbjuder allt från enklare avfuktare till helhetslösningar, alltid anpassade efter varje kunds unika behov, och vi har lokala servicetekniker på plats i hela Sverige.

Välkommen att träffa våra experter på Nordbygg!

Läs mer på www.munters.com.'), 'https://www.munters.com', 'assets/images/exhibitors/nordbygg-2026-munters-europe-ab.jpg'),
  ('nordbygg-2026-exhibitor-134846', 'nordbygg-2026', 'Muovitech Sweden AB', 'A14:23', jsonb_build_object('en', 'MuoviTechs fokus är att spara på jordens naturresurser genom att utveckla unika energi- och miljöfördelar, med minimal materialförbrukning och maximal återvinningsbarhet.
Vi sparar pengar och miljö åt våra slutkunder.

MuoviTech är världsledande inom innovativa produkter och system för geoenergi, med egna anläggningar i Sverige, Finland, Polen, Nederländerna, England och Norge. Partner och kunder i ungefär 50 länder.', 'sv', 'MuoviTechs fokus är att spara på jordens naturresurser genom att utveckla unika energi- och miljöfördelar, med minimal materialförbrukning och maximal återvinningsbarhet.
Vi sparar pengar och miljö åt våra slutkunder.

MuoviTech är världsledande inom innovativa produkter och system för geoenergi, med egna anläggningar i Sverige, Finland, Polen, Nederländerna, England och Norge. Partner och kunder i ungefär 50 länder.'), 'https://www.muovitech.com/se', 'assets/images/exhibitors/nordbygg-2026-muovitech-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-139507', 'nordbygg-2026', 'Mur & Putsföretagen', 'C10:52', jsonb_build_object('en', 'Mur & Putsföretagen verkar för hållbara och estetiskt tilltalande stadsmiljöer.

Genom funktionella byggnader i det offentliga rummet främjar vi långsiktigt hållbara fasader av tegel och puts – beständiga material med låg miljöpåverkan och lång livslängd.', 'sv', 'Mur & Putsföretagen verkar för hållbara och estetiskt tilltalande stadsmiljöer.

Genom funktionella byggnader i det offentliga rummet främjar vi långsiktigt hållbara fasader av tegel och puts – beständiga material med låg miljöpåverkan och lång livslängd.'), 'https://murochputsforetagen.org', 'assets/images/exhibitors/nordbygg-2026-mur-putsforetagen.jpg'),
  ('nordbygg-2026-exhibitor-137185', 'nordbygg-2026', 'Naturfönster', 'C13:31', jsonb_build_object('en', 'Naturfönster - Love the Future!

Riktiga Träfönster och massiva Trädörrar. Allmogefönster, Ytterdörrar, Fönsterdörrar, Specialfönster, Vikpartier och Skjutpartier. Naturfönster tillverkar också specialfönster i högsta kvalitet. Furu är standard men vi har även andra träslag som Ekfönster, Mahogny och Lärk.

Vi är specialiserade på tillverkning av fönster och dörrar i gammal stil, men vi har även komplett sortiment av moderna fönster i Trä/aluminium och helaluminium.', 'sv', 'Naturfönster - Love the Future!

Riktiga Träfönster och massiva Trädörrar. Allmogefönster, Ytterdörrar, Fönsterdörrar, Specialfönster, Vikpartier och Skjutpartier. Naturfönster tillverkar också specialfönster i högsta kvalitet. Furu är standard men vi har även andra träslag som Ekfönster, Mahogny och Lärk.

Vi är specialiserade på tillverkning av fönster och dörrar i gammal stil, men vi har även komplett sortiment av moderna fönster i Trä/aluminium och helaluminium.'), 'https://www.naturfonster.se', 'assets/images/exhibitors/nordbygg-2026-naturfonster.jpg'),
  ('nordbygg-2026-exhibitor-133980', 'nordbygg-2026', 'NEXT', 'C02:01', jsonb_build_object('en', 'Next One Technology AB heter numera Aceve Sverige AB.
I mars 2025 blev Next One Technology AB tillsammans med HVD Group, Aceve.

Det innebär att Next One Technology AB med produkterna Next Project, Accurator, Dox och Next Planning nu är en del av en större grupp med flera bolag inom bygg, installation och fastighetsservice i Europa.

Det betyder att vi har fått fler kollegor med mycket kunskap och erfarenhet – och tillsammans kan vi fortsätta utveckla ännu bättre lösningar för branschen.', 'sv', 'Next One Technology AB heter numera Aceve Sverige AB.
I mars 2025 blev Next One Technology AB tillsammans med HVD Group, Aceve.

Det innebär att Next One Technology AB med produkterna Next Project, Accurator, Dox och Next Planning nu är en del av en större grupp med flera bolag inom bygg, installation och fastighetsservice i Europa.

Det betyder att vi har fått fler kollegor med mycket kunskap och erfarenhet – och tillsammans kan vi fortsätta utveckla ännu bättre lösningar för branschen.'), 'https://www.aceve.com/', 'assets/images/exhibitors/nordbygg-2026-next.jpg'),
  ('nordbygg-2026-exhibitor-138774', 'nordbygg-2026', 'NGL Sweden', 'A12:18', null, 'https://www.nglsweden.se', 'assets/images/exhibitors/nordbygg-2026-ngl-sweden.jpg'),
  ('nordbygg-2026-exhibitor-136185', 'nordbygg-2026', 'NIBE Energy Systems', 'A01:10', jsonb_build_object('en', 'Sedan 1952 har NIBE utvecklat lösningar för hållbar och intelligent inomhuskomfort. Med småländsk ingenjörstradition, lång erfarenhet och naturens energi som grund skapar vi system för värme, kyla, ventilation och varmvatten – utvecklade för låg energianvändning och hög komfort i hem och fastigheter. Våra system är byggda för att fungera långsiktigt – i vardagen, i olika klimat och i en tid där varje byggnad behöver vara en del av klimatomställningen.', 'sv', 'Sedan 1952 har NIBE utvecklat lösningar för hållbar och intelligent inomhuskomfort. Med småländsk ingenjörstradition, lång erfarenhet och naturens energi som grund skapar vi system för värme, kyla, ventilation och varmvatten – utvecklade för låg energianvändning och hög komfort i hem och fastigheter. Våra system är byggda för att fungera långsiktigt – i vardagen, i olika klimat och i en tid där varje byggnad behöver vara en del av klimatomställningen.'), 'https://www.nibe.se', 'assets/images/exhibitors/nordbygg-2026-nibe-energy-systems.jpg'),
  ('nordbygg-2026-exhibitor-134591', 'nordbygg-2026', 'Nicotra Gebhardt / Regal Rexnord', 'A21:20', jsonb_build_object('en', 'Nicotra Gebhardt AB är en del av den globala koncernen Regal Rexnord´s division Power Efficiency Systems som är verksamma inom HVAC-branschen och representerar varumärkena Nicotra Gebhardt, Elco & Fasco. Vi har funnits i Sverige i 35 år och har kontor på fem olika orter. Vi är en ledande aktör inom branschen som både utvecklar, tillverkar, säljer och fläktar för större fastigheter och industrier.', 'sv', 'Nicotra Gebhardt AB är en del av den globala koncernen Regal Rexnord´s division Power Efficiency Systems som är verksamma inom HVAC-branschen och representerar varumärkena Nicotra Gebhardt, Elco & Fasco. Vi har funnits i Sverige i 35 år och har kontor på fem olika orter. Vi är en ledande aktör inom branschen som både utvecklar, tillverkar, säljer och fläktar för större fastigheter och industrier.'), 'https://www.nicotra-gebhardt.se', null),
  ('nordbygg-2026-exhibitor-139605', 'nordbygg-2026', 'Nika Inglasning AB', 'C10:71', null, 'https://nika.se', null),
  ('nordbygg-2026-exhibitor-139069', 'nordbygg-2026', 'Nils Ahlgren AB', 'B10:50', jsonb_build_object('en', 'Leverantör till stora och små bygghandlare
Vi levererar infästningsprodukter såsom skruv, spik, bult, plugg, byggbeslag, infästningar, järntråd, hinkar, kärror, verktyg med mera till några av Sveriges största bygghandelskedjor, men även till mindre företag. Vi ser till att ditt företag får de bästa produkterna och tjänsterna för ändamålet – såväl vad gäller områdesskydd som vårt sortiment av skruv, spik, infästningar och andra produkter. Nils Ahlgren AB är certifierad leverantör i enlighet med både BASTA och Vilma.

Heltäckande lösningar för områdesskydd
Nils Ahlgren AB har heltäckande lösningar för områdesskydd och lång erfarenhet i stängselbranschen. Vi kan leverera allt från temporära byggstängsel till gedigna industristängsel med bommar och grindar som ger en hög säkerhet och skapar en trygg arbetsplats. Hos oss får du alltid personlig och kunnig hjälp av våra säljare.', 'sv', 'Leverantör till stora och små bygghandlare
Vi levererar infästningsprodukter såsom skruv, spik, bult, plugg, byggbeslag, infästningar, järntråd, hinkar, kärror, verktyg med mera till några av Sveriges största bygghandelskedjor, men även till mindre företag. Vi ser till att ditt företag får de bästa produkterna och tjänsterna för ändamålet – såväl vad gäller områdesskydd som vårt sortiment av skruv, spik, infästningar och andra produkter. Nils Ahlgren AB är certifierad leverantör i enlighet med både BASTA och Vilma.

Heltäckande lösningar för områdesskydd
Nils Ahlgren AB har heltäckande lösningar för områdesskydd och lång erfarenhet i stängselbranschen. Vi kan leverera allt från temporära byggstängsel till gedigna industristängsel med bommar och grindar som ger en hög säkerhet och skapar en trygg arbetsplats. Hos oss får du alltid personlig och kunnig hjälp av våra säljare.'), 'https://www.nilsahlgren.se', 'assets/images/exhibitors/nordbygg-2026-nils-ahlgren-ab.jpg'),
  ('nordbygg-2026-exhibitor-137075', 'nordbygg-2026', 'Ningbo Magarden Leisure Co. Ltd', 'C13:62', null, 'https://www.magardens.com', null),
  ('nordbygg-2026-exhibitor-139284', 'nordbygg-2026', 'Nivell System AB', 'C05:61', null, 'https://www.nivellsystem.se', null),
  ('nordbygg-2026-exhibitor-139355', 'nordbygg-2026', 'NL Pavilion – Netherlands Embassy', 'C03:41', jsonb_build_object('en', 'The Netherlands is internationally recognised as a frontrunner in sustainable construction and integrated urban development. At the Netherlands Pavilion, Dutch companies present concrete, market-ready solutions that help cities, developers and infrastructure partners accelerate the transition to a climate-resilient built environment.

Visitors will discover practical technologies and collaboration opportunities that enable faster, more sustainable and more efficient construction. The showcased solutions range from digital construction and circular building systems to clean mobility, energy storage and smart water management.

Get to know all the companies active in the pavilion!

Brainial: https://invitepeople.com/events/eb6de9171b/companies/82011

Desah - Noardling: https://invitepeople.com/events/eb6de9171b/companies/82004

Emoss Mobile Systems: https://invitepeople.com/events/eb6de9171b/companies/82007

Hivolt Energy Systems: https://invitepeople.com/events/eb6de9171b/companies/82008

LJ Solutions: https://invitepeople.com/events/eb6de9171b/companies/82010

Pretty Plastic: https://invitepeople.com/events/eb6de9171b/companies/82018

Watermeln: https://invitepeople.com/events/eb6de9171b/companies/82012

Solarix: https://invitepeople.com/events/eb6de9171b/companies/82015

Zavhy 3D concrete printing: https://invitepeople.com/events/eb6de9171b/companies/82009

Interested in exploring opportunities in one of Europe’s most dynamic business hubs? Get in touch with Invest in Holland at the NL pavilion - a governmental network dedicated to helping international companies establish and grow sustainable, innovative business in the Netherlands. Contact nordics@nfia.com or visit https://investinholland.com/ to learn more.', 'sv', 'The Netherlands is internationally recognised as a frontrunner in sustainable construction and integrated urban development. At the Netherlands Pavilion, Dutch companies present concrete, market-ready solutions that help cities, developers and infrastructure partners accelerate the transition to a climate-resilient built environment.

Visitors will discover practical technologies and collaboration opportunities that enable faster, more sustainable and more efficient construction. The showcased solutions range from digital construction and circular building systems to clean mobility, energy storage and smart water management.

Get to know all the companies active in the pavilion!

Brainial: https://invitepeople.com/events/eb6de9171b/companies/82011

Desah - Noardling: https://invitepeople.com/events/eb6de9171b/companies/82004

Emoss Mobile Systems: https://invitepeople.com/events/eb6de9171b/companies/82007

Hivolt Energy Systems: https://invitepeople.com/events/eb6de9171b/companies/82008

LJ Solutions: https://invitepeople.com/events/eb6de9171b/companies/82010

Pretty Plastic: https://invitepeople.com/events/eb6de9171b/companies/82018

Watermeln: https://invitepeople.com/events/eb6de9171b/companies/82012

Solarix: https://invitepeople.com/events/eb6de9171b/companies/82015

Zavhy 3D concrete printing: https://invitepeople.com/events/eb6de9171b/companies/82009

Interested in exploring opportunities in one of Europe’s most dynamic business hubs? Get in touch with Invest in Holland at the NL pavilion - a governmental network dedicated to helping international companies establish and grow sustainable, innovative business in the Netherlands. Contact nordics@nfia.com or visit https://investinholland.com/ to learn more.'), 'https://www.netherlandsandyou.nl/web/sweden/about-us', 'assets/images/exhibitors/nordbygg-2026-nl-pavilion-netherlands-embassy.jpg'),
  ('nordbygg-2026-exhibitor-134005', 'nordbygg-2026', 'NORD METAL', 'C10:61', jsonb_build_object('en', '”Nord metal“ UAB är ett erfaret företag med omfattande expertis, specialiserat på tillverkning av kapade och bockade armeringsjärn och prefabricerade armeringskorgar av stål. Företaget hanterar framgångsrikt B2B-projekt i Litauen såväl som på utländska marknader.', 'sv', '”Nord metal“ UAB är ett erfaret företag med omfattande expertis, specialiserat på tillverkning av kapade och bockade armeringsjärn och prefabricerade armeringskorgar av stål. Företaget hanterar framgångsrikt B2B-projekt i Litauen såväl som på utländska marknader.'), 'https://www.nordmetal.eu', 'assets/images/exhibitors/nordbygg-2026-nord-metal.jpg'),
  ('nordbygg-2026-exhibitor-138160', 'nordbygg-2026', 'Nordic Kitchen Group', 'C09:20', jsonb_build_object('en', 'Nordic Kitchen Group (NKG) är en av de ledande aktörerna i Norden för design och tillverkning av skräddarsydda kökslösningar. Koncernen med sina fem varumärken har en fördelaktig position på marknaden, med tillverkning och försäljning av kök till både företag och privatpersoner.', 'sv', 'Nordic Kitchen Group (NKG) är en av de ledande aktörerna i Norden för design och tillverkning av skräddarsydda kökslösningar. Koncernen med sina fem varumärken har en fördelaktig position på marknaden, med tillverkning och försäljning av kök till både företag och privatpersoner.'), 'https://www.nordickitchen.se', 'assets/images/exhibitors/nordbygg-2026-nordic-kitchen-group.jpg'),
  ('nordbygg-2026-exhibitor-134497', 'nordbygg-2026', 'Nordic Pump AB', 'B10:22', jsonb_build_object('en', 'Svensktillverkade brukspumpar och blandare för byggindustrin.
Våra maskiner är genuint hantverk från Dalarna, Sverige och vi sätter en stor stolthet i att leverera egenproducerade, ergonomiska och effektiva kvalitetsprodukter med hållbarhet och användarvänlighet i fokus.
Nordic Pump - Blandarpumpar, bruksblandare och brukspumpar - made in Hedemora.', 'sv', 'Svensktillverkade brukspumpar och blandare för byggindustrin.
Våra maskiner är genuint hantverk från Dalarna, Sverige och vi sätter en stor stolthet i att leverera egenproducerade, ergonomiska och effektiva kvalitetsprodukter med hållbarhet och användarvänlighet i fokus.
Nordic Pump - Blandarpumpar, bruksblandare och brukspumpar - made in Hedemora.'), 'https://www.nordicpump.se', 'assets/images/exhibitors/nordbygg-2026-nordic-pump-ab.jpg'),
  ('nordbygg-2026-exhibitor-133987', 'nordbygg-2026', 'Nordic Waterproofing', 'C04:51', null, 'https://www.nordicwaterproofing.com', 'assets/images/exhibitors/nordbygg-2026-nordic-waterproofing.jpg'),
  ('nordbygg-2026-exhibitor-140047', 'nordbygg-2026', 'Nordisk Innovation', 'A10:27', jsonb_build_object('en', 'Giftfri skydd mot råttor i avlopp

Vi stoppar råttor från att ta sig in i byggnader via avloppssystemet.

+300 000 installationer. Tillverkad i Danmark. VA-godkänd.', 'sv', 'Giftfri skydd mot råttor i avlopp

Vi stoppar råttor från att ta sig in i byggnader via avloppssystemet.

+300 000 installationer. Tillverkad i Danmark. VA-godkänd.'), 'https://nordiskinnovation.com/sv-se', 'assets/images/exhibitors/nordbygg-2026-nordisk-innovation.jpg'),
  ('nordbygg-2026-exhibitor-137186', 'nordbygg-2026', 'Nordiska Fönster i Ängelholm AB', 'C15:33', jsonb_build_object('en', 'Vi erbjuder ett brett sortiment av fönster, altandörrar, skjut- och vikdörrar, ytterdörrar, takfönster och mer. Alltid med hög kvalitet och möjlighet till specialanpassning utefter dina behov.

Vi har gjort det enkelt att hitta rätt lösning för både budget och behov. Vi gör vägen till din husdröm enkel, trygg och inspirerande, utan att kompromissa på kvalitet eller design.

Sedan 2010 har vi gått vår egen väg - för att du ska kunna välja din.', 'sv', 'Vi erbjuder ett brett sortiment av fönster, altandörrar, skjut- och vikdörrar, ytterdörrar, takfönster och mer. Alltid med hög kvalitet och möjlighet till specialanpassning utefter dina behov.

Vi har gjort det enkelt att hitta rätt lösning för både budget och behov. Vi gör vägen till din husdröm enkel, trygg och inspirerande, utan att kompromissa på kvalitet eller design.

Sedan 2010 har vi gått vår egen väg - för att du ska kunna välja din.'), 'https://www.nordiskafonster.se', 'assets/images/exhibitors/nordbygg-2026-nordiska-fonster-i-angelholm-ab.jpg'),
  ('nordbygg-2026-exhibitor-134734', 'nordbygg-2026', 'Nordskiffer AB', 'C04:70', jsonb_build_object('en', 'Nordskiffer grundades 2005 med idén att lyfta fram takskiffer som ett hållbart fasadmaterial. Med egenutvecklade system, lång erfarenhet och gedigen kunskap är vi idag Nordens ledande specialister på skiffer för fasad.

Ända sedan starten har vi arbetat efter en tydlig idé: att ge skiffer en ny roll i samtida arkitektur – som ett modernt, hållbart och vackert material. Vi såg potentialen i ett av världens mest hållbara byggmaterial och ville göra det mer tillgängligt.

Vi började som agentur för kvalitetsskiffer och byggde snabbt upp djup kunskap om material, leverantörer och montage. Men vi nöjde oss inte där. Tidigt insåg vi att ett material med så stor potential förtjänade smartare system – därför tog vi fram egna lösningar för att förenkla och förbättra användningen av skiffer på fasad. Det blev grunden till våra NordClad-system som idag används i hela Skandinavien.

Genom åren har vi varit aktiva i utvecklingen av branschstandarder och testmetoder, bland annat som remissinstans till RISE, ByggAMA och Stenindustriförbundet. 2017 tog vår resa en ny vändning när vi blev en del av St Eriks – Sveriges ledande koncern för betong och natursten. Det gav oss möjlighet att växa, utveckla sortimentet och erbjuda våra kunder ännu bättre helhetslösningar.

Idag är vi Nordens ledande specialister på skiffer för fasad, men vi fortsätter att drivas av samma tanke som från början: att lyfta fram ett tidlöst naturmaterial – och göra det till en självklar del av framtidens byggande.', 'sv', 'Nordskiffer grundades 2005 med idén att lyfta fram takskiffer som ett hållbart fasadmaterial. Med egenutvecklade system, lång erfarenhet och gedigen kunskap är vi idag Nordens ledande specialister på skiffer för fasad.

Ända sedan starten har vi arbetat efter en tydlig idé: att ge skiffer en ny roll i samtida arkitektur – som ett modernt, hållbart och vackert material. Vi såg potentialen i ett av världens mest hållbara byggmaterial och ville göra det mer tillgängligt.

Vi började som agentur för kvalitetsskiffer och byggde snabbt upp djup kunskap om material, leverantörer och montage. Men vi nöjde oss inte där. Tidigt insåg vi att ett material med så stor potential förtjänade smartare system – därför tog vi fram egna lösningar för att förenkla och förbättra användningen av skiffer på fasad. Det blev grunden till våra NordClad-system som idag används i hela Skandinavien.

Genom åren har vi varit aktiva i utvecklingen av branschstandarder och testmetoder, bland annat som remissinstans till RISE, ByggAMA och Stenindustriförbundet. 2017 tog vår resa en ny vändning när vi blev en del av St Eriks – Sveriges ledande koncern för betong och natursten. Det gav oss möjlighet att växa, utveckla sortimentet och erbjuda våra kunder ännu bättre helhetslösningar.

Idag är vi Nordens ledande specialister på skiffer för fasad, men vi fortsätter att drivas av samma tanke som från början: att lyfta fram ett tidlöst naturmaterial – och göra det till en självklar del av framtidens byggande.'), 'https://www.nordskiffer.com', 'assets/images/exhibitors/nordbygg-2026-nordskiffer-ab.jpg'),
  ('nordbygg-2026-exhibitor-134831', 'nordbygg-2026', 'Nordtec Instrument AB', 'A13:20', jsonb_build_object('en', 'Vi har funnits sedan 1976 och erbjuder världsledande mätlösningar samt ackrediterad labb- och fältkalibrering till proffsanvändare inom inneklimat, ventilation, kyla, värme, betong och bygg.', 'sv', 'Vi har funnits sedan 1976 och erbjuder världsledande mätlösningar samt ackrediterad labb- och fältkalibrering till proffsanvändare inom inneklimat, ventilation, kyla, värme, betong och bygg.'), 'https://www.nordtec.se', 'assets/images/exhibitors/nordbygg-2026-nordtec-instrument-ab.jpg'),
  ('nordbygg-2026-exhibitor-140106', 'nordbygg-2026', 'Nordtech Energy Oy', 'A13:38', jsonb_build_object('en', 'Världsledande teknik inom värmeväxling och gröna energilösningar

NordTech Energy är en ledande leverantör av värmeväxlingsteknik och gröna energilösningar för industriella och kommersiella applikationer. Med över 20 års erfarenhet i branschen förstår vi de tekniska, operativa och tillförlitlighetskrav som ställs på moderna energi- och processystem.

Vi stöttar våra kunder genom hela utrustningens livscykel — från systemval och konstruktion till leverans, service och långsiktig optimering. Vårt fokus är att leverera driftsäkra, effektiva och kostnadseffektiva lösningar som maximerar tillgänglighet och prestanda samtidigt som de stödjer hållbara energimål.

Kompletta lösningar för värme och kyla inom:

HVAC och fjärrvärmesystem
Datacenter och kylapplikationer
Förnybar energi och kraftverk
Industriella processer för värme och kyla
Kemisk och petrokemisk industri
Energiåtervinning och spillvärmeutnyttjande

Vårt produktsortiment omfattar:

Lödda värmeväxlare
Plattvärmeväxlare (packningsförsedda)
Platt- och mantelvärmeväxlare
Halvsvetsade värmeväxlare
Rörvärmeväxlare (shell and tube)
Spiralvärmeväxlare
Adiabatiska kondensorer och luftkylare
Luftridåer och luftvärmare
Turboblåsare och kompressorer

Snabb leverans av reservdelar och pålitlig leveranskedja

För att minimera stillestånd och säkerställa oavbruten produktion lagerhåller NordTech Energy ett omfattande sortiment av vanligt förekommande reservdelar, vilket möjliggör leverans inom 24 timmar för kritiska komponenter.

Vi har starka partnerskap med både OEM-tillverkare och högkvalitativa eftermarknadsleverantörer, vilket gör att vi kan erbjuda ett brett och konkurrenskraftigt produktsortiment anpassat efter varje kunds tekniska och operativa behov.

Din partner för effektiv värmeenergi

NordTech Energy — tekniska lösningar för effektiv och hållbar värmeenergi.', 'sv', 'Världsledande teknik inom värmeväxling och gröna energilösningar

NordTech Energy är en ledande leverantör av värmeväxlingsteknik och gröna energilösningar för industriella och kommersiella applikationer. Med över 20 års erfarenhet i branschen förstår vi de tekniska, operativa och tillförlitlighetskrav som ställs på moderna energi- och processystem.

Vi stöttar våra kunder genom hela utrustningens livscykel — från systemval och konstruktion till leverans, service och långsiktig optimering. Vårt fokus är att leverera driftsäkra, effektiva och kostnadseffektiva lösningar som maximerar tillgänglighet och prestanda samtidigt som de stödjer hållbara energimål.

Kompletta lösningar för värme och kyla inom:

HVAC och fjärrvärmesystem
Datacenter och kylapplikationer
Förnybar energi och kraftverk
Industriella processer för värme och kyla
Kemisk och petrokemisk industri
Energiåtervinning och spillvärmeutnyttjande

Vårt produktsortiment omfattar:

Lödda värmeväxlare
Plattvärmeväxlare (packningsförsedda)
Platt- och mantelvärmeväxlare
Halvsvetsade värmeväxlare
Rörvärmeväxlare (shell and tube)
Spiralvärmeväxlare
Adiabatiska kondensorer och luftkylare
Luftridåer och luftvärmare
Turboblåsare och kompressorer

Snabb leverans av reservdelar och pålitlig leveranskedja

För att minimera stillestånd och säkerställa oavbruten produktion lagerhåller NordTech Energy ett omfattande sortiment av vanligt förekommande reservdelar, vilket möjliggör leverans inom 24 timmar för kritiska komponenter.

Vi har starka partnerskap med både OEM-tillverkare och högkvalitativa eftermarknadsleverantörer, vilket gör att vi kan erbjuda ett brett och konkurrenskraftigt produktsortiment anpassat efter varje kunds tekniska och operativa behov.

Din partner för effektiv värmeenergi

NordTech Energy — tekniska lösningar för effektiv och hållbar värmeenergi.'), 'https://www.nordtechenergy.com', 'assets/images/exhibitors/nordbygg-2026-nordtech-energy-oy.jpg'),
  ('nordbygg-2026-exhibitor-139270', 'nordbygg-2026', 'Northmill Bank', 'AG:44', jsonb_build_object('en', 'Northmill Bank är en nordisk digital utmanarbank med visionen att förbättra människors finansiella liv genom att kombinera teknisk innovation med en personlig kundupplevelse. Med en fullständig svensk banklicens erbjuder banken finansiella tjänster för både privatpersoner och företag. Northmill blev den EU-baserade bank som tilldelades flest utmärkelser i Banking Tech Awards 2025 och har två gånger rankats som ett av Europas snabbast växande företag av Financial Times. Under fjärde kvartalet 2024 blev Northmill den första svenska banken att genomföra en betalning via Riksbankens nya infrastruktur för realtidsöverföringar mellan konton, RIX-INST.', 'sv', 'Northmill Bank är en nordisk digital utmanarbank med visionen att förbättra människors finansiella liv genom att kombinera teknisk innovation med en personlig kundupplevelse. Med en fullständig svensk banklicens erbjuder banken finansiella tjänster för både privatpersoner och företag. Northmill blev den EU-baserade bank som tilldelades flest utmärkelser i Banking Tech Awards 2025 och har två gånger rankats som ett av Europas snabbast växande företag av Financial Times. Under fjärde kvartalet 2024 blev Northmill den första svenska banken att genomföra en betalning via Riksbankens nya infrastruktur för realtidsöverföringar mellan konton, RIX-INST.'), 'https://www.northmill.com/se', 'assets/images/exhibitors/nordbygg-2026-northmill-bank.jpg'),
  ('nordbygg-2026-exhibitor-139376', 'nordbygg-2026', 'Novatronik Sp. z o.o.', 'A22:17', null, 'https://www.novatronik.com', 'assets/images/exhibitors/nordbygg-2026-novatronik-sp-z-o-o.jpg'),
  ('nordbygg-2026-exhibitor-134523', 'nordbygg-2026', 'Nässjö Takstolsfabrik AB', 'C14:30', null, 'https://www.takstolsfabriken.se', 'assets/images/exhibitors/nordbygg-2026-nassjo-takstolsfabrik-ab.jpg'),
  ('nordbygg-2026-exhibitor-139411', 'nordbygg-2026', 'OLIVE badrum', 'A09:12', null, 'https://www.olivebadrum.se', 'assets/images/exhibitors/nordbygg-2026-olive-badrum.jpg'),
  ('nordbygg-2026-exhibitor-138317', 'nordbygg-2026', 'OMKON YAPI SAN. VE TIC. A.S.', 'C14:60', null, 'https://www.omkon.com.tr', 'assets/images/exhibitors/nordbygg-2026-omkon-yapi-san-ve-tic-a-s.jpg'),
  ('nordbygg-2026-exhibitor-138212', 'nordbygg-2026', 'One Click LCA', 'C02:23', null, 'https://oneclicklca.com', 'assets/images/exhibitors/nordbygg-2026-one-click-lca.jpg'),
  ('nordbygg-2026-exhibitor-139740', 'nordbygg-2026', 'Onlevel Nordic Aps', 'C11:70', jsonb_build_object('en', 'Sluta anpassa dig till systemet – välj ett som anpassar sig till dig.
Våra glasräskessystem är utvecklade för verkliga arbetsförhållanden: enkla att installera, flexibla på plats och utan kompromisser i kvalitet och design.
För yrkesproffs. Använda världen över', 'sv', 'Sluta anpassa dig till systemet – välj ett som anpassar sig till dig.
Våra glasräskessystem är utvecklade för verkliga arbetsförhållanden: enkla att installera, flexibla på plats och utan kompromisser i kvalitet och design.
För yrkesproffs. Använda världen över'), 'https://www.onlevel.com', 'assets/images/exhibitors/nordbygg-2026-onlevel-nordic-aps.jpg'),
  ('nordbygg-2026-exhibitor-139149', 'nordbygg-2026', 'OnTheGo Living', 'AG:28', jsonb_build_object('en', 'Vi är specialiserade på Meta-annonsering för byggbranschen.

Vi hjälper byggföretag att skapa ett stabilt inflöde av egna offertförfrågningar genom träffsäker annonsering.

Ni slipper konkurrera om samma jobb på prisjaktssajter – kunderna kontaktar er direkt.

Personlig service. Tätt samarbete.
En partner som är tillgänglig och engagerad i er tillväxt.', 'sv', 'Vi är specialiserade på Meta-annonsering för byggbranschen.

Vi hjälper byggföretag att skapa ett stabilt inflöde av egna offertförfrågningar genom träffsäker annonsering.

Ni slipper konkurrera om samma jobb på prisjaktssajter – kunderna kontaktar er direkt.

Personlig service. Tätt samarbete.
En partner som är tillgänglig och engagerad i er tillväxt.'), 'https://Vmarketing.se', 'assets/images/exhibitors/nordbygg-2026-onthego-living.jpg'),
  ('nordbygg-2026-exhibitor-138253', 'nordbygg-2026', 'ORGADATA Scandinavia AB', 'C11:41C', null, 'https://www.orgadata.com', 'assets/images/exhibitors/nordbygg-2026-orgadata-scandinavia-ab.jpg'),
  ('nordbygg-2026-exhibitor-136724', 'nordbygg-2026', 'Orsa Stenhuggeri', 'C04:61F', jsonb_build_object('en', 'Orsa stenhuggeri bryter Orsa sandsten i Dalaskogen. Orsa sandsten är en ljusrosa porös stensort som är smidig att forma och används till största del till byggnadsdelar som fasader och ordnament men även till olika inredningar. Kom och kolla in vår mångsidiga sten och hör om vår långa historia!', 'sv', 'Orsa stenhuggeri bryter Orsa sandsten i Dalaskogen. Orsa sandsten är en ljusrosa porös stensort som är smidig att forma och används till största del till byggnadsdelar som fasader och ordnament men även till olika inredningar. Kom och kolla in vår mångsidiga sten och hör om vår långa historia!'), 'https://www.orsasten.se', 'assets/images/exhibitors/nordbygg-2026-orsa-stenhuggeri.jpg'),
  ('nordbygg-2026-exhibitor-134853', 'nordbygg-2026', 'OSO Hotwater AB', 'A10:19', null, 'https://osohotwater.se', null),
  ('nordbygg-2026-exhibitor-133986', 'nordbygg-2026', 'Ouman AB', 'A19:10', null, 'https://www.ouman.se', 'assets/images/exhibitors/nordbygg-2026-ouman-ab.jpg'),
  ('nordbygg-2026-exhibitor-139590', 'nordbygg-2026', 'OVA System / Wanas', 'A22:22', null, 'https://www.ova-system.pl', null),
  ('nordbygg-2026-exhibitor-137252', 'nordbygg-2026', 'Pabliq - en produkt från Antirio AB', 'BG:05', null, 'https://Www.Pabliq.se', null),
  ('nordbygg-2026-exhibitor-139923', 'nordbygg-2026', 'Pal-Klaas AS', 'C03:51', null, 'https://pal-klaas.ee/en', 'assets/images/exhibitors/nordbygg-2026-pal-klaas-as.jpg'),
  ('nordbygg-2026-exhibitor-137350', 'nordbygg-2026', 'Panasonic Heating & Cooling Solutions', 'A14:22', jsonb_build_object('en', 'Panasonic har lång erfarenhet av att producera värmepumpar och klimatsystem anpassade för det nordiska klimatet. Vi erbjuder ett stort urval av nyckelfärdiga värme- och ventilationssystem för både hushåll, medelstora anläggningar och stora byggnader.

Vår industriella kapacitet samt våra miljöåtaganden har öppnat för ny forskning och teknikutveckling.

Under de senaste 30 åren har vi levererat över 500 000 enheter runt om i Norden, vilket gör oss till en av de ledande aktörerna på marknaden.', 'sv', 'Panasonic har lång erfarenhet av att producera värmepumpar och klimatsystem anpassade för det nordiska klimatet. Vi erbjuder ett stort urval av nyckelfärdiga värme- och ventilationssystem för både hushåll, medelstora anläggningar och stora byggnader.

Vår industriella kapacitet samt våra miljöåtaganden har öppnat för ny forskning och teknikutveckling.

Under de senaste 30 åren har vi levererat över 500 000 enheter runt om i Norden, vilket gör oss till en av de ledande aktörerna på marknaden.'), 'https://www.aircon.panasonic.eu/', 'assets/images/exhibitors/nordbygg-2026-panasonic-heating-cooling-solutions.jpg'),
  ('nordbygg-2026-exhibitor-137857', 'nordbygg-2026', 'Panel och List AB', 'C07:31', null, 'https://www.panelochlist.se', null),
  ('nordbygg-2026-exhibitor-139446', 'nordbygg-2026', 'Passiv Energie GmbH', 'C02:51', null, 'https://passiv-energie.gmbh', 'assets/images/exhibitors/nordbygg-2026-passiv-energie-gmbh.jpg'),
  ('nordbygg-2026-exhibitor-138757', 'nordbygg-2026', 'PAVIMENTI - STEEL GRATINGS AND STAIR TREADS', 'C19:51', null, 'https://pavimenti.com.pl', 'assets/images/exhibitors/nordbygg-2026-pavimenti-steel-gratings-and-stair-treads.jpg'),
  ('nordbygg-2026-exhibitor-138002', 'nordbygg-2026', 'PBH Produkter AB', 'A12:19', jsonb_build_object('en', 'PBH produkter utvecklar och säljer produkter inom luftvärme och ventilation för villor.', 'sv', 'PBH produkter utvecklar och säljer produkter inom luftvärme och ventilation för villor.'), 'https://www.pbh.se', 'assets/images/exhibitors/nordbygg-2026-pbh-produkter-ab.jpg'),
  ('nordbygg-2026-exhibitor-136920', 'nordbygg-2026', 'PECOL SA', 'B04:33', null, 'https://WWW.PECOL.PT', 'assets/images/exhibitors/nordbygg-2026-pecol-sa.jpg'),
  ('nordbygg-2026-exhibitor-139926', 'nordbygg-2026', 'Peetri Puit OÜ (ARCWOOD)', 'C03:51', null, 'https://arcwood.ee', 'assets/images/exhibitors/nordbygg-2026-peetri-puit-ou-arcwood.jpg'),
  ('nordbygg-2026-exhibitor-138219', 'nordbygg-2026', 'Pelly Group', 'C08:40', null, 'https://www.pellygroup.se', null),
  ('nordbygg-2026-exhibitor-135142', 'nordbygg-2026', 'PERI', 'B07:31', jsonb_build_object('en', 'Vi är med och bygger Sverige!
Form - Ställning - Konstruktion

Med skräddarsydda lösningar och teknisk expertis är vi partnern för form och ställningssystem för alla byggnationer av bostäder, offentliga byggnader, industribyggnader, infrastruktur, ställningsprojekt och mycket mer. Från idé och konstruktionsritning, till effektivt materialanvändande och färdigt resultat - Vi är med er hela vägen i ert projekt!

Välkommen till oss på PERI!', 'sv', 'Vi är med och bygger Sverige!
Form - Ställning - Konstruktion

Med skräddarsydda lösningar och teknisk expertis är vi partnern för form och ställningssystem för alla byggnationer av bostäder, offentliga byggnader, industribyggnader, infrastruktur, ställningsprojekt och mycket mer. Från idé och konstruktionsritning, till effektivt materialanvändande och färdigt resultat - Vi är med er hela vägen i ert projekt!

Välkommen till oss på PERI!'), 'https://www.peri.se', 'assets/images/exhibitors/nordbygg-2026-peri.jpg'),
  ('nordbygg-2026-exhibitor-134950', 'nordbygg-2026', 'Perssons Träteknik', 'C13:20', null, 'https://www.perssonstrateknik.se', 'assets/images/exhibitors/nordbygg-2026-perssons-trateknik.jpg'),
  ('nordbygg-2026-exhibitor-138992', 'nordbygg-2026', 'PETE-produkter', 'A22:21', null, 'https://www.pete.fi', 'assets/images/exhibitors/nordbygg-2026-pete-produkter.jpg'),
  ('nordbygg-2026-exhibitor-138056', 'nordbygg-2026', 'Photomate', 'A12:16', jsonb_build_object('en', 'Vi är Photomate – specialister på smarta energilösningar för en hållbar framtid.

Sedan starten har vi hjälpt företag och privatpersoner att ta steget mot energieffektivitet genom innovativa produkter och högkvalitativ service. Vår produktportfölj omfattar bland annat solcellsväxelriktare, batterisystem, växelströms- och likströmsladdare för elfordon, ett energihanteringssystem (EMS) och tjänster med fokus på analys av energiförbrukning.

Nu tar vi nästa steg – vi är härmed stolta tillverkare och utvecklare av våra egna värmepumpar!
Vår nya ERApro-serie kombinerar avancerad teknik, nordisk anpassning och lång livslängd.
Med 10 års garanti på kompressorn och 5 år på hela värmepumpen erbjuder vi trygghet och prestanda i toppklass.
Upplev framtidens värmepumpar – utvecklade för nordiska förhållanden, med fokus på kvalitet, innovation och hållbarhet.

Photomate – din partner för smart energi.', 'sv', 'Vi är Photomate – specialister på smarta energilösningar för en hållbar framtid.

Sedan starten har vi hjälpt företag och privatpersoner att ta steget mot energieffektivitet genom innovativa produkter och högkvalitativ service. Vår produktportfölj omfattar bland annat solcellsväxelriktare, batterisystem, växelströms- och likströmsladdare för elfordon, ett energihanteringssystem (EMS) och tjänster med fokus på analys av energiförbrukning.

Nu tar vi nästa steg – vi är härmed stolta tillverkare och utvecklare av våra egna värmepumpar!
Vår nya ERApro-serie kombinerar avancerad teknik, nordisk anpassning och lång livslängd.
Med 10 års garanti på kompressorn och 5 år på hela värmepumpen erbjuder vi trygghet och prestanda i toppklass.
Upplev framtidens värmepumpar – utvecklade för nordiska förhållanden, med fokus på kvalitet, innovation och hållbarhet.

Photomate – din partner för smart energi.'), 'https://www.photomate.se', 'assets/images/exhibitors/nordbygg-2026-photomate.jpg'),
  ('nordbygg-2026-exhibitor-136791', 'nordbygg-2026', 'Pica-Marker GmbH', 'B02:02', null, 'https://www.pica-marker.com', null),
  ('nordbygg-2026-exhibitor-139697', 'nordbygg-2026', 'Pictue Oy', 'BG:07', jsonb_build_object('en', 'Pictue är världens enklaste och snabbaste verktyg för fotografering, som gör det möjligt att få med hela teamet i fotodokumentationen. Besök vår monter för att se en demo och uppleva det med egna ögon.

Med Pictue hanterar du reklamationer på sekunder och håller dina kunder informerade – samtidigt som dina installatörer förblir nöjda.', 'sv', 'Pictue är världens enklaste och snabbaste verktyg för fotografering, som gör det möjligt att få med hela teamet i fotodokumentationen. Besök vår monter för att se en demo och uppleva det med egna ögon.

Med Pictue hanterar du reklamationer på sekunder och håller dina kunder informerade – samtidigt som dina installatörer förblir nöjda.'), 'https://pictue.com', 'assets/images/exhibitors/nordbygg-2026-pictue-oy.jpg'),
  ('nordbygg-2026-exhibitor-138495', 'nordbygg-2026', 'PiiGAB', 'A20:15', jsonb_build_object('en', 'PiiGAB är en One Stop Shop for metering. Vi erbjuder produkter och tjänster för mätdatainsamling i fastigheter. Exempel på produkter är gateways, sensorer och mätare för fastighetsautomation. Med vår management-portal PiiGAB Connect får fastighetsägaren full kontroll över sitt bestånd av gateways och mätare. Allt med fokus på enkelhet och säkerhet.', 'sv', 'PiiGAB är en One Stop Shop for metering. Vi erbjuder produkter och tjänster för mätdatainsamling i fastigheter. Exempel på produkter är gateways, sensorer och mätare för fastighetsautomation. Med vår management-portal PiiGAB Connect får fastighetsägaren full kontroll över sitt bestånd av gateways och mätare. Allt med fokus på enkelhet och säkerhet.'), 'https://www.piigab.se', 'assets/images/exhibitors/nordbygg-2026-piigab.jpg'),
  ('nordbygg-2026-exhibitor-134631', 'nordbygg-2026', 'Piltorps Varmluft AB', 'B06:01', null, 'https://www.piltorps.se', null),
  ('nordbygg-2026-exhibitor-138801', 'nordbygg-2026', 'Pipemodul', 'A11:36', jsonb_build_object('en', 'Pipe-Modul har specialiserat sig på industriell produktion och utveckling av installationsmoduler för fastighetsteknik. Företaget har utvecklat ett öppningsbart Pipemodul®-modulsystem för att underlätta och försnabba stambyten samt rör- och kabeldragningar i fastigheter. Pipemodul-systemet passar även till nyproduktion.

Pipe-Modul är marknadsledande inom tillverkning av öppningsbara installationsmoduler. Vi ansvarar själv för produktutveckling och tillverkning och kan ta fram det som kunden behöver. Vi är aktiva i projekteringsfasen och hjälper projektledare eller totalentreprenör för att få fram den bästa lösningen. Vi samarbetar aktivt med våra kunder och partners från den första kontakten ända till färdigställt projekt. Våra moduler har använts i närmare 4000 stambyten.', 'sv', 'Pipe-Modul har specialiserat sig på industriell produktion och utveckling av installationsmoduler för fastighetsteknik. Företaget har utvecklat ett öppningsbart Pipemodul®-modulsystem för att underlätta och försnabba stambyten samt rör- och kabeldragningar i fastigheter. Pipemodul-systemet passar även till nyproduktion.

Pipe-Modul är marknadsledande inom tillverkning av öppningsbara installationsmoduler. Vi ansvarar själv för produktutveckling och tillverkning och kan ta fram det som kunden behöver. Vi är aktiva i projekteringsfasen och hjälper projektledare eller totalentreprenör för att få fram den bästa lösningen. Vi samarbetar aktivt med våra kunder och partners från den första kontakten ända till färdigställt projekt. Våra moduler har använts i närmare 4000 stambyten.'), 'https://www.pipemodul.com', 'assets/images/exhibitors/nordbygg-2026-pipemodul.jpg'),
  ('nordbygg-2026-exhibitor-138632', 'nordbygg-2026', 'Pixlmedia', 'AG:28', null, 'https://pixlmedia.se/sv', null),
  ('nordbygg-2026-exhibitor-137069', 'nordbygg-2026', 'Plannja AB', 'C17:51', jsonb_build_object('en', 'Plannja är Nordens ledande varumärke inom tak- och fasadlösningar i byggplåt.

Vi utvecklar och tillverkar tak- och fasadprofiler, takavvattning, entrétak samt ett brett sortiment av tillbehör för moderna byggnader. Produkterna tillverkas i stål och aluminium och finns i ett stort urval av kulörer och ytbeläggningar som kombinerar hållbarhet, funktion och design.

Med lång erfarenhet och stark närvaro på den nordiska marknaden erbjuder Plannja lösningar för allt från småhus till större byggprojekt.

Plannja står för kvalitet, innovation och hållbara byggplåtprodukter – utvecklade för nordiskt klimat.', 'sv', 'Plannja är Nordens ledande varumärke inom tak- och fasadlösningar i byggplåt.

Vi utvecklar och tillverkar tak- och fasadprofiler, takavvattning, entrétak samt ett brett sortiment av tillbehör för moderna byggnader. Produkterna tillverkas i stål och aluminium och finns i ett stort urval av kulörer och ytbeläggningar som kombinerar hållbarhet, funktion och design.

Med lång erfarenhet och stark närvaro på den nordiska marknaden erbjuder Plannja lösningar för allt från småhus till större byggprojekt.

Plannja står för kvalitet, innovation och hållbara byggplåtprodukter – utvecklade för nordiskt klimat.'), 'https://www.plannja.se', 'assets/images/exhibitors/nordbygg-2026-plannja-ab.jpg'),
  ('nordbygg-2026-exhibitor-139068', 'nordbygg-2026', 'Play Systems Sp. z o.o.', 'EÖ:20', jsonb_build_object('en', 'We are specialists in the comprehensive construction of playgrounds, recreation and sports areas. Our main aim is to build playground of your child''s dream.', 'sv', 'We are specialists in the comprehensive construction of playgrounds, recreation and sports areas. Our main aim is to build playground of your child''s dream.'), 'https://playsystems.eu', 'assets/images/exhibitors/nordbygg-2026-play-systems-sp-z-o-o.jpg'),
  ('nordbygg-2026-exhibitor-139093', 'nordbygg-2026', 'PLUM', 'A10:35', jsonb_build_object('en', 'Plum HVAC
We are a manufacturer of electronics for intelligent energy management in HVAC systems. We produce controllers for heat pumps, boilers, ventilation, and floor heating. We provide fully customized OEM solutions, tailored to the needs of manufacturers and distributors.', 'sv', 'Plum HVAC
We are a manufacturer of electronics for intelligent energy management in HVAC systems. We produce controllers for heat pumps, boilers, ventilation, and floor heating. We provide fully customized OEM solutions, tailored to the needs of manufacturers and distributors.'), 'https://www.plum.pl', 'assets/images/exhibitors/nordbygg-2026-plum.jpg'),
  ('nordbygg-2026-exhibitor-138964', 'nordbygg-2026', 'Plum Safety ApS', 'B06:42', jsonb_build_object('en', 'Med en lång tradition som sträcker sig tillbaka till 1860 och mer än 50 års erfarenhet inom säkerhetsbranschen är vi idag specialiserade på första hjälpen-lösningar som bidrar till att göra arbetsplatser säkrare. Plum Safetys produktsortiment omfattar sår- och ögonskjölj, plåster, brännskadegel, bandage, dekontamineringslösningar samt andra praktiska första hjälpen-produkter, utformade för snabb och effektiv behandling av mindre skador i en rad olika arbetsmiljöer.', 'sv', 'Med en lång tradition som sträcker sig tillbaka till 1860 och mer än 50 års erfarenhet inom säkerhetsbranschen är vi idag specialiserade på första hjälpen-lösningar som bidrar till att göra arbetsplatser säkrare. Plum Safetys produktsortiment omfattar sår- och ögonskjölj, plåster, brännskadegel, bandage, dekontamineringslösningar samt andra praktiska första hjälpen-produkter, utformade för snabb och effektiv behandling av mindre skador i en rad olika arbetsmiljöer.'), 'https://plum.eu', 'assets/images/exhibitors/nordbygg-2026-plum-safety-aps.jpg'),
  ('nordbygg-2026-exhibitor-137120', 'nordbygg-2026', 'Plåt & Ventföretagen', 'C17:51 (+1)', jsonb_build_object('en', 'Plåt & Ventföretagen är bransch- och arbetsgivarorganisationen för plåtslageri, ventilation och stål- & lättbyggnad. Vi representerar cirka 1 000 medlemsföretag runt om i Sverige.', 'sv', 'Plåt & Ventföretagen är bransch- och arbetsgivarorganisationen för plåtslageri, ventilation och stål- & lättbyggnad. Vi representerar cirka 1 000 medlemsföretag runt om i Sverige.'), 'https://www.pvforetagen.se', 'assets/images/exhibitors/nordbygg-2026-plat-ventforetagen.jpg'),
  ('nordbygg-2026-exhibitor-140092', 'nordbygg-2026', 'Plåtfabriken.se', 'AG:72', jsonb_build_object('en', 'Via oss kan du som privatperson eller företagare köpa måttanpassade fönsterbleck, tröskelplåtar, ståndskivor, vindskivor och andra plåtbeslag utan att anlita plåtslagare. Du behöver bara välja dina plåtbeslag du behöver, du kan anpassa profil/bredd, längd och material/färger direkt i vår nätbutik och sedan se priset online utan att behöva skicka någon offert eller prisförfrågan. Lägg dina plåtbeslag i varukorgen och se totalpris inkl fraktkostnad.', 'sv', 'Via oss kan du som privatperson eller företagare köpa måttanpassade fönsterbleck, tröskelplåtar, ståndskivor, vindskivor och andra plåtbeslag utan att anlita plåtslagare. Du behöver bara välja dina plåtbeslag du behöver, du kan anpassa profil/bredd, längd och material/färger direkt i vår nätbutik och sedan se priset online utan att behöva skicka någon offert eller prisförfrågan. Lägg dina plåtbeslag i varukorgen och se totalpris inkl fraktkostnad.'), 'https://plåtfabriken.se', 'assets/images/exhibitors/nordbygg-2026-platfabriken-se.jpg'),
  ('nordbygg-2026-exhibitor-138758', 'nordbygg-2026', 'PMI byggutbildningar', 'BG:10', jsonb_build_object('en', 'Utbilda framtidens byggproffs! Vi erbjuder praktiska och certifierade kurser inom hela byggsektorn – från säkerhet och ställning till ledarskap och hållbart byggande. Höj kompetensen, minska riskerna och stärk ditt team med kunskap som bygger framgång.', 'sv', 'Utbilda framtidens byggproffs! Vi erbjuder praktiska och certifierade kurser inom hela byggsektorn – från säkerhet och ställning till ledarskap och hållbart byggande. Höj kompetensen, minska riskerna och stärk ditt team med kunskap som bygger framgång.'), 'https://Pmikonsulter.se', 'assets/images/exhibitors/nordbygg-2026-pmi-byggutbildningar.jpg'),
  ('nordbygg-2026-exhibitor-137074', 'nordbygg-2026', 'Pointex AB', 'B11:10', jsonb_build_object('en', 'Sveriges bredaste sortiment inom bärbar belysning & arbetsplatsbelysning. Hos oss finner du produkter och varumärken för alla behov och verksamhetsinriktningar.', 'sv', 'Sveriges bredaste sortiment inom bärbar belysning & arbetsplatsbelysning. Hos oss finner du produkter och varumärken för alla behov och verksamhetsinriktningar.'), 'https://www.pointex.se', 'assets/images/exhibitors/nordbygg-2026-pointex-ab.jpg'),
  ('nordbygg-2026-exhibitor-134659', 'nordbygg-2026', 'Polaria AB', 'A09:16', null, 'https://www.polaria.se', 'assets/images/exhibitors/nordbygg-2026-polaria-ab.jpg'),
  ('nordbygg-2026-exhibitor-137851', 'nordbygg-2026', 'POLFLAM Sp. z o.o.', 'C08:31', null, 'https://www.polflam.com', 'assets/images/exhibitors/nordbygg-2026-polflam-sp-z-o-o.jpg'),
  ('nordbygg-2026-exhibitor-139642', 'nordbygg-2026', 'Polish Agency for Enterprise Development', 'C03:61', jsonb_build_object('en', 'Syftet med myndighetens verksamhet är att genomföra program för ekonomisk utveckling som stödjer innovations- och forskningsverksamhet hos små och medelstora företag (SMF), regional utveckling, exporttillväxt, utveckling av mänskliga resurser samt användning av ny teknik i näringsverksamhet.

Polska Agencja Rozwoju Przedsiebiorczosci (PARP) är engagerad i genomförandet av nationella och internationella projekt som finansieras med medel från strukturfonderna, statsbudgeten samt Europeiska kommissionens fleråriga program. PARP deltar aktivt i utformningen och det effektiva genomförandet av statens politik inom entreprenörskap, innovation och arbetskraftens anpassningsförmåga, med målet att bli en nyckelinstitution med ansvar för att skapa en miljö som stödjer företagare. I enlighet med principen ”Think Small First” – ”SMF i första hand” genomförs alla myndighetens åtgärder med särskilt beaktande av SMF-sektorns behov.

PARP:s uppdrag
Av passion för ekonomin, med ansvar för SMF.

PARP:s vision
Vi utvecklar det polska företagandet genom innovation och genom att upptäcka nya utvecklingsinriktningar. Vi förbättrar kontinuerligt vårt arbetssätt genom att testa och införa innovativa metoder. Inom detta område samarbetar vi med företagare och institutioner som verkar inom innovations­ekosystemet i Polen och internationellt.', 'sv', 'Syftet med myndighetens verksamhet är att genomföra program för ekonomisk utveckling som stödjer innovations- och forskningsverksamhet hos små och medelstora företag (SMF), regional utveckling, exporttillväxt, utveckling av mänskliga resurser samt användning av ny teknik i näringsverksamhet.

Polska Agencja Rozwoju Przedsiebiorczosci (PARP) är engagerad i genomförandet av nationella och internationella projekt som finansieras med medel från strukturfonderna, statsbudgeten samt Europeiska kommissionens fleråriga program. PARP deltar aktivt i utformningen och det effektiva genomförandet av statens politik inom entreprenörskap, innovation och arbetskraftens anpassningsförmåga, med målet att bli en nyckelinstitution med ansvar för att skapa en miljö som stödjer företagare. I enlighet med principen ”Think Small First” – ”SMF i första hand” genomförs alla myndighetens åtgärder med särskilt beaktande av SMF-sektorns behov.

PARP:s uppdrag
Av passion för ekonomin, med ansvar för SMF.

PARP:s vision
Vi utvecklar det polska företagandet genom innovation och genom att upptäcka nya utvecklingsinriktningar. Vi förbättrar kontinuerligt vårt arbetssätt genom att testa och införa innovativa metoder. Inom detta område samarbetar vi med företagare och institutioner som verkar inom innovations­ekosystemet i Polen och internationellt.'), 'https://www.parp.gov.pl', 'assets/images/exhibitors/nordbygg-2026-polish-agency-for-enterprise-development.jpg'),
  ('nordbygg-2026-exhibitor-137044', 'nordbygg-2026', 'Portwest Ltd', 'B03:20', jsonb_build_object('en', 'Portwest is a global manufacturer and innovator of workwear, safety wear and PPE. Established in 1904, Portwest today has a global distribution network and customer service staff in over 130 countries. The company is a family-owned business and continues to be managed by the 3rd generation of the Hughes Family and since 2015 the 4th generation of the family have joined the business. Innovative production and design by an in-house team of experts lies at the heart of the Portwest advantage.', 'sv', 'Portwest is a global manufacturer and innovator of workwear, safety wear and PPE. Established in 1904, Portwest today has a global distribution network and customer service staff in over 130 countries. The company is a family-owned business and continues to be managed by the 3rd generation of the Hughes Family and since 2015 the 4th generation of the family have joined the business. Innovative production and design by an in-house team of experts lies at the heart of the Portwest advantage.'), 'https://www.portwest.com', null),
  ('nordbygg-2026-exhibitor-136543', 'nordbygg-2026', 'Posirol', 'C17:30', jsonb_build_object('en', 'Posirol Oy är en europeisk tillverkare baserad i Finland, specialiserad på produktion av hålband, montageband och andra fästband för bygg- och installationsändamål. Vi är en etablerad B2B-leverantör som levererar högkvalitativa produkter till företag inom byggbranschen – med särskilt fokus på undertaksinstallationer, kabeldragning, rörmontage och andra typer av upphängningslösningar.
Med våra CE-märkta hålband i galvaniserat stål, rostfritt stål (A2/AISI 304, A4/AISI 316) samt aluminium, erbjuder vi marknaden ett av Europas bredaste sortiment av perforerade fästband med olika hålmönster och ytbehandlingar. Våra band finns även som plastbelagda hålband i flera färger – perfekt för visuella och korrosionskänsliga miljöer.
*  Användningsområden för våra hålband och montageband:
Upphängning av undertak och bärverk
Fästning och stöd av rör, kabel, ventilation, belysning, kabelstegar, stängsel m.m.
Reparationer, förankring och fixering av objekt oavsett form
Idealisk för både inomhus- och utomhusbruk, samt tillfälliga eller permanenta installationer
Våra produkter används ofta som:
Installationsband, dragband, vinddragband, profilband, patentband, bandjärn, galvband, popnitsband, eller helt enkelt som universella monteringsband.
*  Flexibel produktion – från standard till kundanpassat
Vi erbjuder hålband i standardlängder om 3 m, 10 m och 25 m, men kan även tillverka kundspecifika längder och förpackningslösningar. Vår helautomatiserade produktionslinje säkerställer hög kapacitet, snabb leverans och jämn kvalitet.
All tillverkning sker i vår moderna fabrik i Finland. Våra leveranser till svenska kunder tar endast 2–3 dagar, direkt till ert lager.
*  Varför välja Posirol som leverantör av hålband och fästband?
*  Brett sortiment av hålband, montageband och installationsband
CE-märkta produkter testade i Sverige (RISE)
- Hög leveranssäkerhet & korta ledtider
- Egen produktion inom EU – inga mellanhänder
- Möjlighet till private label / egen varumärkning
- Plastbelagda och rostfria alternativ
- Miljövänlig förpackning & modern automatiserad produktion
- Låga priser – utan att tumma på kvalitet
*  Beställ hålband enkelt – leverans direkt till ert lager
Med Posirol Oy får ni en kunnig och pålitlig partner för alla typer av monteringsband och fästlösningar inom bygg och elinstallation. Vi kombinerar produktkvalitet, flexibilitet och god kundservice – och ser till att ni alltid får rätt produkt, i rätt tid.
*  Exempel på sökord kopplade till våra produkter:
Hålband plast | Rostfria montageband | Patentband för undertak | Plastbelagda fästband | CE-märkta hålband | Monteringsband rostfritt | Galvband för bygg | Vinddragband stål | Fästa kabel med hålband | Installationsband för rör', 'sv', 'Posirol Oy är en europeisk tillverkare baserad i Finland, specialiserad på produktion av hålband, montageband och andra fästband för bygg- och installationsändamål. Vi är en etablerad B2B-leverantör som levererar högkvalitativa produkter till företag inom byggbranschen – med särskilt fokus på undertaksinstallationer, kabeldragning, rörmontage och andra typer av upphängningslösningar.
Med våra CE-märkta hålband i galvaniserat stål, rostfritt stål (A2/AISI 304, A4/AISI 316) samt aluminium, erbjuder vi marknaden ett av Europas bredaste sortiment av perforerade fästband med olika hålmönster och ytbehandlingar. Våra band finns även som plastbelagda hålband i flera färger – perfekt för visuella och korrosionskänsliga miljöer.
*  Användningsområden för våra hålband och montageband:
Upphängning av undertak och bärverk
Fästning och stöd av rör, kabel, ventilation, belysning, kabelstegar, stängsel m.m.
Reparationer, förankring och fixering av objekt oavsett form
Idealisk för både inomhus- och utomhusbruk, samt tillfälliga eller permanenta installationer
Våra produkter används ofta som:
Installationsband, dragband, vinddragband, profilband, patentband, bandjärn, galvband, popnitsband, eller helt enkelt som universella monteringsband.
*  Flexibel produktion – från standard till kundanpassat
Vi erbjuder hålband i standardlängder om 3 m, 10 m och 25 m, men kan även tillverka kundspecifika längder och förpackningslösningar. Vår helautomatiserade produktionslinje säkerställer hög kapacitet, snabb leverans och jämn kvalitet.
All tillverkning sker i vår moderna fabrik i Finland. Våra leveranser till svenska kunder tar endast 2–3 dagar, direkt till ert lager.
*  Varför välja Posirol som leverantör av hålband och fästband?
*  Brett sortiment av hålband, montageband och installationsband
CE-märkta produkter testade i Sverige (RISE)
- Hög leveranssäkerhet & korta ledtider
- Egen produktion inom EU – inga mellanhänder
- Möjlighet till private label / egen varumärkning
- Plastbelagda och rostfria alternativ
- Miljövänlig förpackning & modern automatiserad produktion
- Låga priser – utan att tumma på kvalitet
*  Beställ hålband enkelt – leverans direkt till ert lager
Med Posirol Oy får ni en kunnig och pålitlig partner för alla typer av monteringsband och fästlösningar inom bygg och elinstallation. Vi kombinerar produktkvalitet, flexibilitet och god kundservice – och ser till att ni alltid får rätt produkt, i rätt tid.
*  Exempel på sökord kopplade till våra produkter:
Hålband plast | Rostfria montageband | Patentband för undertak | Plastbelagda fästband | CE-märkta hålband | Monteringsband rostfritt | Galvband för bygg | Vinddragband stål | Fästa kabel med hålband | Installationsband för rör'), 'https://www.posirol.com', 'assets/images/exhibitors/nordbygg-2026-posirol.jpg'),
  ('nordbygg-2026-exhibitor-139595', 'nordbygg-2026', 'PP-Tuote', 'AG:45', jsonb_build_object('en', 'För PP-Tuote Oy är metallbearbetning inte bara ett jobb – det är en passion som syns i varje produkt vi tillverkar. I mer än två decennier har vi förverkligat ambitiösa idéer och tillverkat hållbara, praktiska produkter för hem och företag – både inomhus och utomhus.

Vi erbjuder ett brett sortiment av metallprodukter, såsom golvbrunnslock, sopkärl, stegar och mycket mer – allt utformat för att underlätta vardagen och förhöja utseendet på ditt hem. För oss är ingen idé för djärv: varje idé får en chans.

Kom och besök oss så kan vi diskutera dina behov och hur vi bäst kan tillgodose dem.', 'sv', 'För PP-Tuote Oy är metallbearbetning inte bara ett jobb – det är en passion som syns i varje produkt vi tillverkar. I mer än två decennier har vi förverkligat ambitiösa idéer och tillverkat hållbara, praktiska produkter för hem och företag – både inomhus och utomhus.

Vi erbjuder ett brett sortiment av metallprodukter, såsom golvbrunnslock, sopkärl, stegar och mycket mer – allt utformat för att underlätta vardagen och förhöja utseendet på ditt hem. För oss är ingen idé för djärv: varje idé får en chans.

Kom och besök oss så kan vi diskutera dina behov och hur vi bäst kan tillgodose dem.'), 'https://pp-tuote.fi', 'assets/images/exhibitors/nordbygg-2026-pp-tuote.jpg'),
  ('nordbygg-2026-exhibitor-137109', 'nordbygg-2026', 'PREFA Sverige AB', 'C17:51', jsonb_build_object('en', 'PREFA erbjuder sedan 80 år innovativa tak-, fasad- och takavvattningssystem i aluminium med hantverkskvalitet. Även översvämningsskydd av hög prestanda och solcellssystem finns i vår breda produktkatalog.

Som en stark partner ger vi support till byggentreprenörer, arkitekter, projekterare samt plåtslagare och takläggare.
Vi är stolta över våra många unika nybyggnads- och renoveringsprojekt med produkter, som inte bara är starka när det gäller design, utan även tål extrema förhållanden.', 'sv', 'PREFA erbjuder sedan 80 år innovativa tak-, fasad- och takavvattningssystem i aluminium med hantverkskvalitet. Även översvämningsskydd av hög prestanda och solcellssystem finns i vår breda produktkatalog.

Som en stark partner ger vi support till byggentreprenörer, arkitekter, projekterare samt plåtslagare och takläggare.
Vi är stolta över våra många unika nybyggnads- och renoveringsprojekt med produkter, som inte bara är starka när det gäller design, utan även tål extrema förhållanden.'), 'https://www.prefa.se', 'assets/images/exhibitors/nordbygg-2026-prefa-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-134006', 'nordbygg-2026', 'Prema AB', 'A05:08', jsonb_build_object('en', 'Kom för kaffet, stanna för energin!

Är du i behov av hållbara och energieffektiva shuntlösningar för att spara pengar, uppfylla miljöklassningar, effektivisera dina VVS-system och skapa ett bättre inomhusklimat?

VÄLKOMMEN TILL PREMA OCH MONTER A05:08!

Här får du en förhandstitt på nya Premablock® inox – marknadens tuffaste shuntgrupp i syrafast rostfritt stål, med C3 eller C4-klassning beroende på dina behov.

Vi visar också upp:

• EPD-certifierade kombishuntgruppen SRBX-62VK i utförande Premablock® green II

• Frikyleshuntgruppen PRUX-43FK i utförande Premablock® green I

• Fjärruppkopplade SRU-2 Connected™ i utförande Premablock® smart

I montern har du möjlighet att över en kopp precisionsbryggd espresso ställa frågor om allt från hur shuntgrupper fungerar till hur du kan dimensionera enklare med hjälp av PREMA:s dimensionseringsprogram ShuntLogik®.

Dessutom skickar vi med dig info om Shuntakademin® där du kan lära dig ännu mer på egen hand.

SEMINARIUM TILLSAMMANS MED ENEFF

Förhandsboka en plats på seminariet ”Hållbar energieffektivisering – från strategi till praktik” med PREMA:s shuntexpert Thomas Winge och energieffektiviseringsföreningen Eneffs Generalsekreterare Lotta Bångens.

Seminariet kommer bland annat avhandla sådant som energieffektivisering i samhället och hur marknaden kan komma att förändras med nya EU-direktiv samtidigt som du får mer handfasta tips och råd kring olika shuntgruppslösningar och hur de kan hjälpa dig spara energi i värme- och kylsystem.

Förboka din seminarieplats på:
https://prema.se/seminarium-nordbygg-2026/', 'sv', 'Kom för kaffet, stanna för energin!

Är du i behov av hållbara och energieffektiva shuntlösningar för att spara pengar, uppfylla miljöklassningar, effektivisera dina VVS-system och skapa ett bättre inomhusklimat?

VÄLKOMMEN TILL PREMA OCH MONTER A05:08!

Här får du en förhandstitt på nya Premablock® inox – marknadens tuffaste shuntgrupp i syrafast rostfritt stål, med C3 eller C4-klassning beroende på dina behov.

Vi visar också upp:

• EPD-certifierade kombishuntgruppen SRBX-62VK i utförande Premablock® green II

• Frikyleshuntgruppen PRUX-43FK i utförande Premablock® green I

• Fjärruppkopplade SRU-2 Connected™ i utförande Premablock® smart

I montern har du möjlighet att över en kopp precisionsbryggd espresso ställa frågor om allt från hur shuntgrupper fungerar till hur du kan dimensionera enklare med hjälp av PREMA:s dimensionseringsprogram ShuntLogik®.

Dessutom skickar vi med dig info om Shuntakademin® där du kan lära dig ännu mer på egen hand.

SEMINARIUM TILLSAMMANS MED ENEFF

Förhandsboka en plats på seminariet ”Hållbar energieffektivisering – från strategi till praktik” med PREMA:s shuntexpert Thomas Winge och energieffektiviseringsföreningen Eneffs Generalsekreterare Lotta Bångens.

Seminariet kommer bland annat avhandla sådant som energieffektivisering i samhället och hur marknaden kan komma att förändras med nya EU-direktiv samtidigt som du får mer handfasta tips och råd kring olika shuntgruppslösningar och hur de kan hjälpa dig spara energi i värme- och kylsystem.

Förboka din seminarieplats på:
https://prema.se/seminarium-nordbygg-2026/'), 'https://www.prema.se', 'assets/images/exhibitors/nordbygg-2026-prema-ab.jpg'),
  ('nordbygg-2026-exhibitor-140107', 'nordbygg-2026', 'Pretty Plastic', 'C03:41', jsonb_build_object('en', 'Pretty Plastic designar och producerar cirkulära fasad- och takmaterial tillverkade av 100 % återvunnen PVC, baserad på byggavfall såsom fönsterkarmar, stuprör och hängrännor.

Vårt sortiment består av tre plattformat, tillgängliga i fyra färger: grå, grön, ockra och terrakotta. Plattorna är lätta, hållbara och utvecklade för effektiv installation. De är demonterbara och kräver lite underhåll, vilket gör dem lämpliga för både nyproduktion och renovering, inklusive prefabricering och modulärt byggande.

Pretty Plastic-plattor är certifierade enligt internationella standarder och används i bostads-, offentliga och kommersiella projekt över hela Europa. Materialet kombinerar jämn kvalitet med ett tydligt estetiskt uttryck och erbjuder arkitekter ett fullt cirkulärt alternativ utan att kompromissa med design.', 'sv', 'Pretty Plastic designar och producerar cirkulära fasad- och takmaterial tillverkade av 100 % återvunnen PVC, baserad på byggavfall såsom fönsterkarmar, stuprör och hängrännor.

Vårt sortiment består av tre plattformat, tillgängliga i fyra färger: grå, grön, ockra och terrakotta. Plattorna är lätta, hållbara och utvecklade för effektiv installation. De är demonterbara och kräver lite underhåll, vilket gör dem lämpliga för både nyproduktion och renovering, inklusive prefabricering och modulärt byggande.

Pretty Plastic-plattor är certifierade enligt internationella standarder och används i bostads-, offentliga och kommersiella projekt över hela Europa. Materialet kombinerar jämn kvalitet med ett tydligt estetiskt uttryck och erbjuder arkitekter ett fullt cirkulärt alternativ utan att kompromissa med design.'), 'https://www.prettyplastic.nl', 'assets/images/exhibitors/nordbygg-2026-pretty-plastic.jpg'),
  ('nordbygg-2026-exhibitor-137536', 'nordbygg-2026', 'Primaverde B.V.', 'B08:41', null, 'https://www.primaverde.nl', 'assets/images/exhibitors/nordbygg-2026-primaverde-b-v.jpg'),
  ('nordbygg-2026-exhibitor-138439', 'nordbygg-2026', 'Primostar', 'C09:60', jsonb_build_object('en', 'Primostar Group AB är specialiserat på vattentätning av underjordiska betongkonstruktioner med över 25 års dokumenterad erfarenhet inom Primostar Group.

Vi erbjuder integrerade White Tank-vattentätningssystem som säkerställer långvarig hållbarhet, minskar materialanvändningen med upp till 8× och inkluderar ett patenterat Controlled Crack Waterstop System.

Med verksamhet i Baltikum och Norden tillhandahåller vi klimatoptimerade lösningar med livscykelbaserade CO2-utsläpp som är upp till 95–97 % lägre.

På Nordbygg presenterar vi tillförlitliga och hållbara vattentätningslösningar för modern underjordisk byggnation.', 'sv', 'Primostar Group AB är specialiserat på vattentätning av underjordiska betongkonstruktioner med över 25 års dokumenterad erfarenhet inom Primostar Group.

Vi erbjuder integrerade White Tank-vattentätningssystem som säkerställer långvarig hållbarhet, minskar materialanvändningen med upp till 8× och inkluderar ett patenterat Controlled Crack Waterstop System.

Med verksamhet i Baltikum och Norden tillhandahåller vi klimatoptimerade lösningar med livscykelbaserade CO2-utsläpp som är upp till 95–97 % lägre.

På Nordbygg presenterar vi tillförlitliga och hållbara vattentätningslösningar för modern underjordisk byggnation.'), 'https://www.primostar.eu', 'assets/images/exhibitors/nordbygg-2026-primostar.jpg'),
  ('nordbygg-2026-exhibitor-140030', 'nordbygg-2026', 'Primus-Silva Sweden AB', 'BG:27', null, 'https://Silvasweden.com', 'assets/images/exhibitors/nordbygg-2026-primus-silva-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-136184', 'nordbygg-2026', 'ProcessBefuktning AB', 'A19:22', null, 'https://www.processbefuktning.se', null),
  ('nordbygg-2026-exhibitor-136676', 'nordbygg-2026', 'Proco Services AB', 'A10:30', jsonb_build_object('en', 'Med Proco Services teknik för anborrning och blockering av trycksatta rörsystem kan underhållsarbeten av VVS-system ske utan besvärande störningar för kunder eller system.

Via inbyggda ventiler i våra blockeringsverktyg kan flödet enkelt ledas förbi underhållsområdet och på så sätt kan ett underhåll utföras helt avbrottsfritt utan negativ inverkan på miljön.

Med hjälp av vår teknik kan reparationer av till exempel undercentraler i fastigheter ske utan bortfall av värme för de boende, eller underhåll av vatten- och gasledningar i sjukhusmiljö utan att verksamheten påverkas.', 'sv', 'Med Proco Services teknik för anborrning och blockering av trycksatta rörsystem kan underhållsarbeten av VVS-system ske utan besvärande störningar för kunder eller system.

Via inbyggda ventiler i våra blockeringsverktyg kan flödet enkelt ledas förbi underhållsområdet och på så sätt kan ett underhåll utföras helt avbrottsfritt utan negativ inverkan på miljön.

Med hjälp av vår teknik kan reparationer av till exempel undercentraler i fastigheter ske utan bortfall av värme för de boende, eller underhåll av vatten- och gasledningar i sjukhusmiljö utan att verksamheten påverkas.'), 'https://www.proco.se', 'assets/images/exhibitors/nordbygg-2026-proco-services-ab.jpg'),
  ('nordbygg-2026-exhibitor-139562', 'nordbygg-2026', 'Prodikt', 'C02:11', jsonb_build_object('en', 'Prodikt (prodikt.com) är en digital plattform som kopplar samman hållbar produktdata med verkliga byggprojekt. Den tillhandahåller verifierad information om material, cirkularitet och klimatpåverkan – vilket hjälper byggaktörer att uppfylla lagkrav och fatta välgrundade beslut, samtidigt som tillverkare kan dela korrekt data direkt där besluten tas.', 'sv', 'Prodikt (prodikt.com) är en digital plattform som kopplar samman hållbar produktdata med verkliga byggprojekt. Den tillhandahåller verifierad information om material, cirkularitet och klimatpåverkan – vilket hjälper byggaktörer att uppfylla lagkrav och fatta välgrundade beslut, samtidigt som tillverkare kan dela korrekt data direkt där besluten tas.'), 'https://www.prodikt.com', 'assets/images/exhibitors/nordbygg-2026-prodikt.jpg'),
  ('nordbygg-2026-exhibitor-134768', 'nordbygg-2026', 'Produal Sverige AB', 'A14:10', jsonb_build_object('en', 'Produal utvecklar och tillverkar användarvänliga produkter för byggnadsautomation.', 'sv', 'Produal utvecklar och tillverkar användarvänliga produkter för byggnadsautomation.'), 'https://www.produal.se', 'assets/images/exhibitors/nordbygg-2026-produal-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-138766', 'nordbygg-2026', 'Produktion & Försäljning  Janne Olsson PRETECH  fönsterparaply.se', 'C13:70', null, 'https://www.fönsterparaply.se', null),
  ('nordbygg-2026-exhibitor-138328', 'nordbygg-2026', 'proffsprodukter', 'AG:102', jsonb_build_object('en', 'Grossist för proffs & kräsna hemmafixare

Vi erbjuder noga utvalda proffsprodukter till Nordens absolut lägsta priser. Vi har tillsammans med proffs och kräsna hemmafixare tagit fram ett sortiment som vi anser vara det bästa på marknden. Genom att fokusera på stora volymer och en enkel och effektiv handel gör vi det enkelt att vara kund. Du får premiumprodukter till dom absolut lägsta priserna. Självklart har vi både kvalitets och prisgaranti. Det är det vi kallar konkurrenskraft.', 'sv', 'Grossist för proffs & kräsna hemmafixare

Vi erbjuder noga utvalda proffsprodukter till Nordens absolut lägsta priser. Vi har tillsammans med proffs och kräsna hemmafixare tagit fram ett sortiment som vi anser vara det bästa på marknden. Genom att fokusera på stora volymer och en enkel och effektiv handel gör vi det enkelt att vara kund. Du får premiumprodukter till dom absolut lägsta priserna. Självklart har vi både kvalitets och prisgaranti. Det är det vi kallar konkurrenskraft.'), 'https://www.proffsproduktershop.se', 'assets/images/exhibitors/nordbygg-2026-proffsprodukter.jpg'),
  ('nordbygg-2026-exhibitor-134455', 'nordbygg-2026', 'Projob Workwear AB', 'B01:41', jsonb_build_object('en', 'Söker du högkvalitativa arbetskläder som kombinerar stil och funktionalitet? Då är PROJOB arbetskläder det självklara valet. Vårt sortiment av arbetskläder är utformat för att möta de krav som krävande arbetsmiljöer ställer och hjälper dig att prestera på topp i alla situationer.

Med Projob arbetskläder får du inte bara kläder som är bekväma att bära under hela arbetsdagen, utan också plagg som är konstruerade med tanke på hållbarhet och slitstyrka. Vi förstår vikten av att ha arbetskläder som kan hålla jämna steg med ditt arbete och som är redo för tuffa utmaningar.

Våra arbetskläder omfattar allt från arbetsbyxor och jackor till t-shirts och accessoarer. Oavsett om du arbetar inom bygg, industri eller service har vi ett brett utbud av kläder som passar dina specifika behov och krav.

Vi är stolta över att erbjuda arbetskläder som inte bara är praktiska och slitstarka, utan också moderna och stilrena. Våra arbetskläder är designade med tanke på dagens krav på både funktionalitet och estetik, vilket gör dem till det självklara valet för dig som vill ha kläder som håller högsta standard.

Upptäck Projob arbetskläder och förbättra din arbetsdag med kläder som är byggda för prestation och kvalitet. Utforska vårt sortiment och hitta de perfekta arbetskläderna för din verksamhet. Välkommen till en värld av arbetskläder som gör skillnad!', 'sv', 'Söker du högkvalitativa arbetskläder som kombinerar stil och funktionalitet? Då är PROJOB arbetskläder det självklara valet. Vårt sortiment av arbetskläder är utformat för att möta de krav som krävande arbetsmiljöer ställer och hjälper dig att prestera på topp i alla situationer.

Med Projob arbetskläder får du inte bara kläder som är bekväma att bära under hela arbetsdagen, utan också plagg som är konstruerade med tanke på hållbarhet och slitstyrka. Vi förstår vikten av att ha arbetskläder som kan hålla jämna steg med ditt arbete och som är redo för tuffa utmaningar.

Våra arbetskläder omfattar allt från arbetsbyxor och jackor till t-shirts och accessoarer. Oavsett om du arbetar inom bygg, industri eller service har vi ett brett utbud av kläder som passar dina specifika behov och krav.

Vi är stolta över att erbjuda arbetskläder som inte bara är praktiska och slitstarka, utan också moderna och stilrena. Våra arbetskläder är designade med tanke på dagens krav på både funktionalitet och estetik, vilket gör dem till det självklara valet för dig som vill ha kläder som håller högsta standard.

Upptäck Projob arbetskläder och förbättra din arbetsdag med kläder som är byggda för prestation och kvalitet. Utforska vårt sortiment och hitta de perfekta arbetskläderna för din verksamhet. Välkommen till en värld av arbetskläder som gör skillnad!'), 'https://www.projob.se', null),
  ('nordbygg-2026-exhibitor-138123', 'nordbygg-2026', 'Protega AB', 'C05:33', null, 'https://www.protega.se', null),
  ('nordbygg-2026-exhibitor-139922', 'nordbygg-2026', 'Puidukoda OÜ', 'C03:51', jsonb_build_object('en', 'Puidukoda was founded in 1997 in Southern Estonia. Our main activity is the production and marketing of quality value-added softwood planing materials such as Nordic spruce and Nordic pine.

Puidukoja has modern and flexible fully automated production lines (from sorting to sawing, planing and thermofoiling) with a production capacity exceeding 225,000 m³ per year.

In addition, we offer several post-processing options such as: painting, cabling, end-matching and impregnation.

We use only the highest-quality Nordic coniferous wood as our base raw material, that are ecological sourced mainly from Scandinavian countries.

The company employs more than 130 people in two factories – Karksi and Näpi.

Since 2013, Puidukoda has been part of the Rose Group, a family run French timber company that was founded in 1949 in north-western France.

Puidukoda is also a subsidiary of the Protac company. Protac focuses on the production, impregnation, finishing and marketing of planed material throughout France.', 'sv', 'Puidukoda was founded in 1997 in Southern Estonia. Our main activity is the production and marketing of quality value-added softwood planing materials such as Nordic spruce and Nordic pine.

Puidukoja has modern and flexible fully automated production lines (from sorting to sawing, planing and thermofoiling) with a production capacity exceeding 225,000 m³ per year.

In addition, we offer several post-processing options such as: painting, cabling, end-matching and impregnation.

We use only the highest-quality Nordic coniferous wood as our base raw material, that are ecological sourced mainly from Scandinavian countries.

The company employs more than 130 people in two factories – Karksi and Näpi.

Since 2013, Puidukoda has been part of the Rose Group, a family run French timber company that was founded in 1949 in north-western France.

Puidukoda is also a subsidiary of the Protac company. Protac focuses on the production, impregnation, finishing and marketing of planed material throughout France.'), 'https://www.puidukoda.eu/en', 'assets/images/exhibitors/nordbygg-2026-puidukoda-ou.jpg'),
  ('nordbygg-2026-exhibitor-134014', 'nordbygg-2026', 'Purso Building System', 'C11:21', jsonb_build_object('en', 'Purso tillhandahåller byggsystem i återvunnet aluminium för fasader, dörrar, fönster, glastak och lameller. Våra högkvalitativa byggsystem är ett hållbart, miljövänligt och kostnadseffektivt val. Våra byggsystemsprodukter är utvecklade i Finland och speciellt lämpade för krävande nordeuropeiska förhållanden. Vi erbjuder mångsidiga designlösningar i återvunnet aluminium.', 'sv', 'Purso tillhandahåller byggsystem i återvunnet aluminium för fasader, dörrar, fönster, glastak och lameller. Våra högkvalitativa byggsystem är ett hållbart, miljövänligt och kostnadseffektivt val. Våra byggsystemsprodukter är utvecklade i Finland och speciellt lämpade för krävande nordeuropeiska förhållanden. Vi erbjuder mångsidiga designlösningar i återvunnet aluminium.'), 'https://www.purso.se', 'assets/images/exhibitors/nordbygg-2026-purso-building-system.jpg'),
  ('nordbygg-2026-exhibitor-134650', 'nordbygg-2026', 'Purus AB', 'A03:14', jsonb_build_object('en', 'Purus är en av Skandinaviens ledande tillverkare av VVS-produkter för badrum, kök och andra krävande miljöer som hanterar vatten. Våra huvudsakliga produktsegment är golvbrunnar, golvrännor, inomhusavlopp, rostfri inredning och rostfri sanitet.

Vår starka ställning på den nordiska marknaden började i skånska Sjöbo för drygt 80 år sedan. Slitstarka och funktionella produkter och tillbehör för tuffa inomhusmiljöer är vår konstform – den kallar vi "The Art of the Water Cycle".

Vår ständiga ambition är att fortsätta ta vårt arv av innovation, funktion och design med in i framtiden och väljer därför att visa följande urval av produkter på årets Nordbygg:

– Purus PRO Line – senaste generationens väggnära golvbrunnar med inbyggd monteringsplatta för stabil konstruktion i alla bjälklag, enklare montering och högre flödeskapacitet. Snabb och självklar "plug & play"-montering minskar tid för mätning och beräkning.

– Våra skräddarsydda rostfria bänkskivor och rostfria inredning höjer varje kök hos såväl privata som kommersiella fastighetsägare. Se våra nya rostfria fronter med Anti-fingerprint-yta i montern.

– Våra högkvalitativa rostfria golvrännor i syrafast rostfritt stål, Made in Smålandsstenar, tillverkas efter varje aktuellt projekts behov och kan konfigureras på vår hemsida via Rännguiden. Nu med en mängd nyheter i MagiCad för dig som är konstruktör.

– Purus gummikopplingar – används för att sammanfoga och täta övergångar mellan olika material och rördimensioner. Erbjuds i en rad varianter, samtliga trycktestade för 0,6 bar och med slangklämmor i syrafast stål.

Väl mött i vår monter!', 'sv', 'Purus är en av Skandinaviens ledande tillverkare av VVS-produkter för badrum, kök och andra krävande miljöer som hanterar vatten. Våra huvudsakliga produktsegment är golvbrunnar, golvrännor, inomhusavlopp, rostfri inredning och rostfri sanitet.

Vår starka ställning på den nordiska marknaden började i skånska Sjöbo för drygt 80 år sedan. Slitstarka och funktionella produkter och tillbehör för tuffa inomhusmiljöer är vår konstform – den kallar vi "The Art of the Water Cycle".

Vår ständiga ambition är att fortsätta ta vårt arv av innovation, funktion och design med in i framtiden och väljer därför att visa följande urval av produkter på årets Nordbygg:

– Purus PRO Line – senaste generationens väggnära golvbrunnar med inbyggd monteringsplatta för stabil konstruktion i alla bjälklag, enklare montering och högre flödeskapacitet. Snabb och självklar "plug & play"-montering minskar tid för mätning och beräkning.

– Våra skräddarsydda rostfria bänkskivor och rostfria inredning höjer varje kök hos såväl privata som kommersiella fastighetsägare. Se våra nya rostfria fronter med Anti-fingerprint-yta i montern.

– Våra högkvalitativa rostfria golvrännor i syrafast rostfritt stål, Made in Smålandsstenar, tillverkas efter varje aktuellt projekts behov och kan konfigureras på vår hemsida via Rännguiden. Nu med en mängd nyheter i MagiCad för dig som är konstruktör.

– Purus gummikopplingar – används för att sammanfoga och täta övergångar mellan olika material och rördimensioner. Erbjuds i en rad varianter, samtliga trycktestade för 0,6 bar och med slangklämmor i syrafast stål.

Väl mött i vår monter!'), 'https://www.purus.se', 'assets/images/exhibitors/nordbygg-2026-purus-ab.jpg'),
  ('nordbygg-2026-exhibitor-134651', 'nordbygg-2026', 'Qvantum Energi AB', 'A13:18', jsonb_build_object('en', 'Sedan 1993 har Qvantum utvecklat och producerat högkvalitativa värmepumpar ochenergisystem. Företagets team av ledande experter står bakom nästa generations lösningar för uppvärmning och kylning. Qvantum erbjuder värmepumpar och en unik mjukvarusvit som underlättar för tekniska konsulter, installatörer, projektutvecklare och energibolag att minska koldioxidutsläppen i urbana områden.

Med huvudkontor i Åstorp i Sverige har Qvantum dotterbolag i Tyskland, Nederländerna, Polen, Frankrike, Österrike, Ungern och Storbritannien. År 2023 förvärvade företaget enstorskalig tillverkningsanläggning från Electrolux. Idag har Qvantum cirka 350 anställda i åtta länder.

Qvantum - Changing the way cities are heated', 'sv', 'Sedan 1993 har Qvantum utvecklat och producerat högkvalitativa värmepumpar ochenergisystem. Företagets team av ledande experter står bakom nästa generations lösningar för uppvärmning och kylning. Qvantum erbjuder värmepumpar och en unik mjukvarusvit som underlättar för tekniska konsulter, installatörer, projektutvecklare och energibolag att minska koldioxidutsläppen i urbana områden.

Med huvudkontor i Åstorp i Sverige har Qvantum dotterbolag i Tyskland, Nederländerna, Polen, Frankrike, Österrike, Ungern och Storbritannien. År 2023 förvärvade företaget enstorskalig tillverkningsanläggning från Electrolux. Idag har Qvantum cirka 350 anställda i åtta länder.

Qvantum - Changing the way cities are heated'), 'https://qvantum.se', 'assets/images/exhibitors/nordbygg-2026-qvantum-energi-ab.jpg'),
  ('nordbygg-2026-exhibitor-137911', 'nordbygg-2026', 'R Ehn AB', 'C19:35', jsonb_build_object('en', 'Vi säljer färg till plåttak och fasader', 'sv', 'Vi säljer färg till plåttak och fasader'), 'https://www.ehnab.se', null),
  ('nordbygg-2026-exhibitor-138663', 'nordbygg-2026', 'R-FIX AB', 'C11:62', jsonb_build_object('en', 'Vi på R-FIX tillverkar infästningssystem för arkitektoniskt glas. Vi kombinerar standardprodukter, kundanpassad projektering och tillverkning – för att låta dig förverkliga dina arkitektoniskt utmanande glasprojekt snabbare, tryggare och med större flexibilitet.', 'sv', 'Vi på R-FIX tillverkar infästningssystem för arkitektoniskt glas. Vi kombinerar standardprodukter, kundanpassad projektering och tillverkning – för att låta dig förverkliga dina arkitektoniskt utmanande glasprojekt snabbare, tryggare och med större flexibilitet.'), 'https://rfix.eu/sv', 'assets/images/exhibitors/nordbygg-2026-r-fix-ab.jpg'),
  ('nordbygg-2026-exhibitor-140140', 'nordbygg-2026', 'R&M ALUFASADY', 'C13:33', null, 'https://www.rim.com.pl', 'assets/images/exhibitors/nordbygg-2026-r-m-alufasady.jpg'),
  ('nordbygg-2026-exhibitor-138261', 'nordbygg-2026', 'Ragn-Sells', 'C11:41A', null, 'https://www.ragnsells.se', null),
  ('nordbygg-2026-exhibitor-139447', 'nordbygg-2026', 'RAICO Bautechnik GmbH', 'C02:51', null, 'https://www.raico.de', null),
  ('nordbygg-2026-exhibitor-137847', 'nordbygg-2026', 'Rakennuskemia', 'C07:63', jsonb_build_object('en', 'Vi utvecklar, säljer och marknadsför bygg-, renoverings- och hemvårdsprodukter i Finland och internationellt. Våra egna varumärken är WTF®, QUICKLOADER®, WOODCARE.GUIDE, RK, Maxx Gear, PAINT.GUIDE och Timpuri. Utöver dessa representerar vi flera internationellt kända varumärken som Tytan, Bison och Mellerud.', 'sv', 'Vi utvecklar, säljer och marknadsför bygg-, renoverings- och hemvårdsprodukter i Finland och internationellt. Våra egna varumärken är WTF®, QUICKLOADER®, WOODCARE.GUIDE, RK, Maxx Gear, PAINT.GUIDE och Timpuri. Utöver dessa representerar vi flera internationellt kända varumärken som Tytan, Bison och Mellerud.'), 'https://www.rakennuskemia.com', 'assets/images/exhibitors/nordbygg-2026-rakennuskemia.jpg'),
  ('nordbygg-2026-exhibitor-137320', 'nordbygg-2026', 'Rangefabriken AB', 'C18:30', null, 'https://www.rangefabriken.se', 'assets/images/exhibitors/nordbygg-2026-rangefabriken-ab.jpg'),
  ('nordbygg-2026-exhibitor-139647', 'nordbygg-2026', 'Rapid Säkerhet', 'BG:25', jsonb_build_object('en', 'Vi startade vår verksamhet 1985 och sedan 2002 ägs vi av Gabrielssons Invest AB. Med lång erfarenhet i branschen har vi byggt upp en stabil och pålitlig organisation med hög kompetens och stark lokal förankring.
Vi äger och driver vår egen larmcentral och utför våra uppdrag med cirka 600 engagerade medarbetare – totalt omkring 900 personer på lönelistan varje månad. I vårt team finns väktare, ordningsvakter, trygghetsvärdar, hundförare och andra säkerhetsspecialister som varje dag arbetar för att skapa trygghet.
Vi hjälper företag att vara trygga och säkra genom moderna larm- och kameralösningar. Kring vår larmcentral erbjuder vi dessutom ett brett och komplett tjänsteutbud anpassat efter kundens behov.
Genom vårt Rapid Totalkoncept levererar vi helhetslösningar inom larm och kamera – från installation till övervakning och åtgärd.
Vi utför även traditionella bevakningstjänster såsom rondering, stationär bevakning och receptionstjänster. Som en del av vår larmcentral erbjuder vi dessutom professionell telefonpassning – en perfekt lösning för verksamheter som vill vara tillgängliga för sina kunder dygnet runt. Vår larmcentral samt bevaknignsdel är givevis certifierad SBSC med ISO 9001 och ISO 14001.', 'sv', 'Vi startade vår verksamhet 1985 och sedan 2002 ägs vi av Gabrielssons Invest AB. Med lång erfarenhet i branschen har vi byggt upp en stabil och pålitlig organisation med hög kompetens och stark lokal förankring.
Vi äger och driver vår egen larmcentral och utför våra uppdrag med cirka 600 engagerade medarbetare – totalt omkring 900 personer på lönelistan varje månad. I vårt team finns väktare, ordningsvakter, trygghetsvärdar, hundförare och andra säkerhetsspecialister som varje dag arbetar för att skapa trygghet.
Vi hjälper företag att vara trygga och säkra genom moderna larm- och kameralösningar. Kring vår larmcentral erbjuder vi dessutom ett brett och komplett tjänsteutbud anpassat efter kundens behov.
Genom vårt Rapid Totalkoncept levererar vi helhetslösningar inom larm och kamera – från installation till övervakning och åtgärd.
Vi utför även traditionella bevakningstjänster såsom rondering, stationär bevakning och receptionstjänster. Som en del av vår larmcentral erbjuder vi dessutom professionell telefonpassning – en perfekt lösning för verksamheter som vill vara tillgängliga för sina kunder dygnet runt. Vår larmcentral samt bevaknignsdel är givevis certifierad SBSC med ISO 9001 och ISO 14001.'), 'https://rapidsakerhet.se', 'assets/images/exhibitors/nordbygg-2026-rapid-sakerhet.jpg'),
  ('nordbygg-2026-exhibitor-138001', 'nordbygg-2026', 'Ravendo A/S', 'B09:43', null, 'https://www.ravendo.com', null),
  ('nordbygg-2026-exhibitor-137225', 'nordbygg-2026', 'Rawlplug', 'B01:53', null, 'https://www.rawlplug.com', null),
  ('nordbygg-2026-exhibitor-134946', 'nordbygg-2026', 'REC Indovent AB', 'A21:22', jsonb_build_object('en', 'Sedan starten 1954 har vi utvecklat, producerat och sålt produkter inom ventilationsteknik och solcellslösningar. Vi sammanför vår breda kunskap och tekniska kompetens för att ständigt utmana oss och branschen för att skapa lösningar för framtidens byggnader.

Vi tummar aldrig på kvaliteten och att tänka hållbart är en självklarhet för oss eftersom det funnits med oss sedan starten.

I 70 år har vi varit en pålitlig partner till företag inom bygg- och fastighetsbranschen, exempelvis fastighetsägare, byggbolag, ventilationsentreprenörer, konsulter, återförsäljare eller arkitekter som alla har det gemensamma målet att fokusera på klimatsmarta lösningar, lågenergi eller ett bra inomhusklimat.

Få bättre inomhusmiljö med våra ventilationssystem
Vi är stolta över att våra produkter tillverkas i egen fabrik eller i samarbete med framför allt europeiska underleverantörer, ofta med våra egna verktyg och eget varumärke. Allt vi gör genomsyras av riktigt hög kvalité och vi erbjuder typgodkända produkter som är testade och väl dokumenterade.

Oavsett om du behöver ventilationslösningar, ventilationsaggregat, solenergilösningar för fastigheter, skorstenslösningar eller solelsystem för byggprojekt kan du vara säker på att vi på REC Indovent gör vårt yttersta för att hitta en klimatsmart lösning. Så tveka inte att ta en kontakt med vår personal i montern.

Varmt välkommen till oss på REC!', 'sv', 'Sedan starten 1954 har vi utvecklat, producerat och sålt produkter inom ventilationsteknik och solcellslösningar. Vi sammanför vår breda kunskap och tekniska kompetens för att ständigt utmana oss och branschen för att skapa lösningar för framtidens byggnader.

Vi tummar aldrig på kvaliteten och att tänka hållbart är en självklarhet för oss eftersom det funnits med oss sedan starten.

I 70 år har vi varit en pålitlig partner till företag inom bygg- och fastighetsbranschen, exempelvis fastighetsägare, byggbolag, ventilationsentreprenörer, konsulter, återförsäljare eller arkitekter som alla har det gemensamma målet att fokusera på klimatsmarta lösningar, lågenergi eller ett bra inomhusklimat.

Få bättre inomhusmiljö med våra ventilationssystem
Vi är stolta över att våra produkter tillverkas i egen fabrik eller i samarbete med framför allt europeiska underleverantörer, ofta med våra egna verktyg och eget varumärke. Allt vi gör genomsyras av riktigt hög kvalité och vi erbjuder typgodkända produkter som är testade och väl dokumenterade.

Oavsett om du behöver ventilationslösningar, ventilationsaggregat, solenergilösningar för fastigheter, skorstenslösningar eller solelsystem för byggprojekt kan du vara säker på att vi på REC Indovent gör vårt yttersta för att hitta en klimatsmart lösning. Så tveka inte att ta en kontakt med vår personal i montern.

Varmt välkommen till oss på REC!'), 'https://www.rec-indovent.se', 'assets/images/exhibitors/nordbygg-2026-rec-indovent-ab.jpg'),
  ('nordbygg-2026-exhibitor-139514', 'nordbygg-2026', 'Recoma AB', 'C06:51', null, 'https://www.recoma.se', 'assets/images/exhibitors/nordbygg-2026-recoma-ab.jpg'),
  ('nordbygg-2026-exhibitor-140098', 'nordbygg-2026', 'Recoup', 'C03:41', jsonb_build_object('en', 'Every shower sends liters of warm water, and all the energy to heat it, away as waste. That energy doesn’t have to be lost. With a Waste Water Heat Recovery System for Showers we can capture that heat before it disappears, silently, passively, without electronics or moving parts. Turning wasted warmth into valuable heat again. Our products are built with durable materials, innovative design and offer reliable performance for multiple years.', 'sv', 'Every shower sends liters of warm water, and all the energy to heat it, away as waste. That energy doesn’t have to be lost. With a Waste Water Heat Recovery System for Showers we can capture that heat before it disappears, silently, passively, without electronics or moving parts. Turning wasted warmth into valuable heat again. Our products are built with durable materials, innovative design and offer reliable performance for multiple years.'), 'https://www.counter-flow.se', 'assets/images/exhibitors/nordbygg-2026-recoup.jpg'),
  ('nordbygg-2026-exhibitor-138090', 'nordbygg-2026', 'Redi-Rock by Aster Brands', 'C10:70', null, 'https://redi-rock.com', 'assets/images/exhibitors/nordbygg-2026-redi-rock-by-aster-brands.jpg'),
  ('nordbygg-2026-exhibitor-138721', 'nordbygg-2026', 'Reduzer', 'BG:08', jsonb_build_object('en', 'En LCA-plattform för byggbranschen. Reduzers vision är att göra det möjligt för beslutsfattare i varje projekt att fatta kostnadseffektiva och miljövänliga beslut – från tidigt skede till färdigställt projekt.', 'sv', 'En LCA-plattform för byggbranschen. Reduzers vision är att göra det möjligt för beslutsfattare i varje projekt att fatta kostnadseffektiva och miljövänliga beslut – från tidigt skede till färdigställt projekt.'), 'https://reduzer.com', 'assets/images/exhibitors/nordbygg-2026-reduzer.jpg'),
  ('nordbygg-2026-exhibitor-137126', 'nordbygg-2026', 'Regin Group', 'A17:10', jsonb_build_object('en', 'Regin, DEOS och Industrietechnik står alla inför ett gemensamt uppdrag - att skapa energibesparande lösningar för framtidens hållbara fastigheter.

Inom Regin Group samarbetar vi nära med ledande fastighetsägare, integratörer och installatörer för att utveckla smarta lösningar inom fastighetsautomation som är enkla att konfigurera, installera och driftsätta. Vårt erbjudande omfattar en helhetslösning som sträcker sig från IoT-plattformar och mjukvara till fritt programmerbara och förprogrammerade controllers, tillsammans med långsiktigt hållbara fältenheter. Alltid med målsättningen om att bidra till energibesparande automation i högpresterande fastigheter världen över.', 'sv', 'Regin, DEOS och Industrietechnik står alla inför ett gemensamt uppdrag - att skapa energibesparande lösningar för framtidens hållbara fastigheter.

Inom Regin Group samarbetar vi nära med ledande fastighetsägare, integratörer och installatörer för att utveckla smarta lösningar inom fastighetsautomation som är enkla att konfigurera, installera och driftsätta. Vårt erbjudande omfattar en helhetslösning som sträcker sig från IoT-plattformar och mjukvara till fritt programmerbara och förprogrammerade controllers, tillsammans med långsiktigt hållbara fältenheter. Alltid med målsättningen om att bidra till energibesparande automation i högpresterande fastigheter världen över.'), 'https://www.regingroup.com', 'assets/images/exhibitors/nordbygg-2026-regin-group.jpg'),
  ('nordbygg-2026-exhibitor-134010', 'nordbygg-2026', 'Relekta AS', 'C02:40', null, 'https://www.relekta.no', null),
  ('nordbygg-2026-exhibitor-134666', 'nordbygg-2026', 'REMS Scandinavia A/S', 'A10:18', jsonb_build_object('en', 'REMS är en ledande Tysk tillverkare av maskiner och verktyg för proffs!
Sedan 1909 har vi utvecklat och producerad verktyg och maskiner för rörbearbetning på vår fabriker nära Stuttgart i Tyskland. I dag har vi en högmodern CNC styrd tillverkning och eget härderi - som tillsäkrar kvalitet i alla leden.
I Sverige är vi representerade vid återförsäljare och de ledande fackgrossister samt såklart med våra 4 säljare som finns att träffa på plats överallt i landet.', 'sv', 'REMS är en ledande Tysk tillverkare av maskiner och verktyg för proffs!
Sedan 1909 har vi utvecklat och producerad verktyg och maskiner för rörbearbetning på vår fabriker nära Stuttgart i Tyskland. I dag har vi en högmodern CNC styrd tillverkning och eget härderi - som tillsäkrar kvalitet i alla leden.
I Sverige är vi representerade vid återförsäljare och de ledande fackgrossister samt såklart med våra 4 säljare som finns att träffa på plats överallt i landet.'), 'https://www.rems.de', 'assets/images/exhibitors/nordbygg-2026-rems-scandinavia-a-s.jpg'),
  ('nordbygg-2026-exhibitor-139646', 'nordbygg-2026', 'reshareapp.se', 'BG:19', jsonb_build_object('en', 'Digital plattform för cirkulär materialhantering. Vi hjälper företag att öka lönsamheten i sina projekt genom att minimera avfallskostnasder. ReShare möjliggör enkel dokumentation av cirkulära flöden och ger en beräknad uppföljning av klimatpåverkan baserat på standardiserad information.
Kom och snacka app, abonnemang och tävla i cirkulär design!', 'sv', 'Digital plattform för cirkulär materialhantering. Vi hjälper företag att öka lönsamheten i sina projekt genom att minimera avfallskostnasder. ReShare möjliggör enkel dokumentation av cirkulära flöden och ger en beräknad uppföljning av klimatpåverkan baserat på standardiserad information.
Kom och snacka app, abonnemang och tävla i cirkulär design!'), 'https://reshareapp.se', 'assets/images/exhibitors/nordbygg-2026-reshareapp-se.jpg'),
  ('nordbygg-2026-exhibitor-137011', 'nordbygg-2026', 'RexNordic AB', 'B11:33', null, 'https://www.rexnordic.com', null),
  ('nordbygg-2026-exhibitor-137353', 'nordbygg-2026', 'RHEINZINK', 'C17:51', null, 'https://www.rheinzink.com', null),
  ('nordbygg-2026-exhibitor-135356', 'nordbygg-2026', 'Ridgid Scandinavia A/S', 'A11:10', jsonb_build_object('en', 'RIDGIDs stolta historia bygger på förtroende från yrkespersoner
Sedan den dag då vi uppfann den moderna rörtången har vi gjort det till vårt uppdrag att bygga för världens främsta yrkespersoner – de som känner till arbetets gränser och hur man tänjer på dem.

Dessa verktyg används i extrem värme och kyla, de tål smuts och lera och fungerar tillförlitligt dag ut och dag in. RIDGID-verktyg är kända världen över som branschledande produkter som gör att yrkespersoner som du kan slutföra arbeten snabbare och mer tillförlitligt.

Några av våra kunder berättar för oss om saker som de byggt, medan andra berättar om de män och kvinnor som föregick dem. Våra verktyg går i arv från generation till generation. Det gör oss mycket stolta och glada att veta att RIDGIDs kvalitetsverktyg är lika tidlösa som den entreprenörsanda och hantverksskicklighet de är avsedda för.', 'sv', 'RIDGIDs stolta historia bygger på förtroende från yrkespersoner
Sedan den dag då vi uppfann den moderna rörtången har vi gjort det till vårt uppdrag att bygga för världens främsta yrkespersoner – de som känner till arbetets gränser och hur man tänjer på dem.

Dessa verktyg används i extrem värme och kyla, de tål smuts och lera och fungerar tillförlitligt dag ut och dag in. RIDGID-verktyg är kända världen över som branschledande produkter som gör att yrkespersoner som du kan slutföra arbeten snabbare och mer tillförlitligt.

Några av våra kunder berättar för oss om saker som de byggt, medan andra berättar om de män och kvinnor som föregick dem. Våra verktyg går i arv från generation till generation. Det gör oss mycket stolta och glada att veta att RIDGIDs kvalitetsverktyg är lika tidlösa som den entreprenörsanda och hantverksskicklighet de är avsedda för.'), 'https://www.ridgid.eu/se/sv', 'assets/images/exhibitors/nordbygg-2026-ridgid-scandinavia-a-s.jpg'),
  ('nordbygg-2026-exhibitor-139680', 'nordbygg-2026', 'Riksförbundet Sveriges Ventilationsrengörare', 'A19:37', null, 'https://www.rsvr.nu', 'assets/images/exhibitors/nordbygg-2026-riksforbundet-sveriges-ventilationsrengorare.jpg'),
  ('nordbygg-2026-exhibitor-134675', 'nordbygg-2026', 'Rinkaby Rör', 'A03:06', null, 'https://www.rinkabyror.se', 'assets/images/exhibitors/nordbygg-2026-rinkaby-ror.jpg'),
  ('nordbygg-2026-exhibitor-140185', 'nordbygg-2026', 'RISE Research Institutes of Sweden', 'AG:16', null, 'https://www.sp.se/energy', null),
  ('nordbygg-2026-exhibitor-133994', 'nordbygg-2026', 'RIVIERA', 'C12:21', jsonb_build_object('en', 'Vi på Riviera utvecklar solskydd som markiser, persienner och gardiner helt efter dina mått och önskemål. Våra produkter är designade för den skandinaviska arkitekturen och utvecklade för förhållanden som råder här.', 'sv', 'Vi på Riviera utvecklar solskydd som markiser, persienner och gardiner helt efter dina mått och önskemål. Våra produkter är designade för den skandinaviska arkitekturen och utvecklade för förhållanden som råder här.'), 'https://www.riviera.se', 'assets/images/exhibitors/nordbygg-2026-riviera.jpg'),
  ('nordbygg-2026-exhibitor-134027', 'nordbygg-2026', 'RM Snickerier AB', 'C14:53', jsonb_build_object('en', 'RM Snickerier grundades 1986 av företagets ägare samt VD Mikael Carlsson. Vi är ett företag som tillverkar specialanpassade fönster främst med allmogeprofil likt gammal hantverkstradition.

-Vår målsättning är att kundanpassa våra produkter helt efter kundens önskemål, vi har ett fönsterkunnande som funnits i generationer.

-Målet är att komma nära kunden och leverera högklassiga kvalitetsfönster efter beställning och att hålla utlovad leveranstid till kund. Våra specialtillverkade fönster och ytterdörrar levereras direkt till våra kunder med DHL.', 'sv', 'RM Snickerier grundades 1986 av företagets ägare samt VD Mikael Carlsson. Vi är ett företag som tillverkar specialanpassade fönster främst med allmogeprofil likt gammal hantverkstradition.

-Vår målsättning är att kundanpassa våra produkter helt efter kundens önskemål, vi har ett fönsterkunnande som funnits i generationer.

-Målet är att komma nära kunden och leverera högklassiga kvalitetsfönster efter beställning och att hålla utlovad leveranstid till kund. Våra specialtillverkade fönster och ytterdörrar levereras direkt till våra kunder med DHL.'), 'https://www.rm.se', 'assets/images/exhibitors/nordbygg-2026-rm-snickerier-ab.jpg'),
  ('nordbygg-2026-exhibitor-136371', 'nordbygg-2026', 'RMIG Sweden AB', 'C12:22', jsonb_build_object('en', 'Passion for perforation

Tillsammans med arkitekter, designers och entreprenörer utmanar RMIG Solutions gränserna för hur perforerad metall kan skapa mer funktionella, kreativa och hållbara fasadlösningar för nya konstruktioner och renoveringar. Vi brinner för perforering och på Nordbygg 2026 inbjuder vi dig att upptäcka potentialen och träffa vår erfarna och engagerade personal.

Som världens största tillverkare av perforerad metall kan vi ge dig råd om valet av design och material, liksom olika sekundära operationer och avslutande behandlingar. Du drar också nytta av flexibel logistik, sparar värdefull tid på byggarbetsplatsen och säkerställer en effektiv installationsprocess. Besök vår monter och lär dig mer om dina alternativ.', 'sv', 'Passion for perforation

Tillsammans med arkitekter, designers och entreprenörer utmanar RMIG Solutions gränserna för hur perforerad metall kan skapa mer funktionella, kreativa och hållbara fasadlösningar för nya konstruktioner och renoveringar. Vi brinner för perforering och på Nordbygg 2026 inbjuder vi dig att upptäcka potentialen och träffa vår erfarna och engagerade personal.

Som världens största tillverkare av perforerad metall kan vi ge dig råd om valet av design och material, liksom olika sekundära operationer och avslutande behandlingar. Du drar också nytta av flexibel logistik, sparar värdefull tid på byggarbetsplatsen och säkerställer en effektiv installationsprocess. Besök vår monter och lär dig mer om dina alternativ.'), 'https://rmigsolutions.com/architecture/city-emotion-case-studies/', 'assets/images/exhibitors/nordbygg-2026-rmig-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-136722', 'nordbygg-2026', 'Robakke Natursten', 'C04:61J', null, 'https://www.kullaro.se', null),
  ('nordbygg-2026-exhibitor-134724', 'nordbygg-2026', 'ROCA Industry AB', 'C09:41', jsonb_build_object('en', 'ROCA Industry, etablerat 1976, är ett familjeägt företag som levererar kvalitetsbeslag för dörrar, fönster, glasväggar, duschar och båtar. Vi erbjuder allt från gångjärn till vindrutetorkare, med mottot ”When small things matter”. ISO-certifierade för kvalitet och miljö har vi stor expertis samt en global närvaro med lokal förankring.', 'sv', 'ROCA Industry, etablerat 1976, är ett familjeägt företag som levererar kvalitetsbeslag för dörrar, fönster, glasväggar, duschar och båtar. Vi erbjuder allt från gångjärn till vindrutetorkare, med mottot ”When small things matter”. ISO-certifierade för kvalitet och miljö har vi stor expertis samt en global närvaro med lokal förankring.'), 'https://www.rocaindustry.com', 'assets/images/exhibitors/nordbygg-2026-roca-industry-ab.jpg'),
  ('nordbygg-2026-exhibitor-137912', 'nordbygg-2026', 'Rockpanel', 'C12:20', jsonb_build_object('en', 'Rockpanel utvecklar och tillverkar ett innovativt fasadmaterial av vulkanstenen basalt som passar för fasader, gavlar, takuthäng, takfot och andra byggnadsdetaljer. Rockpanel fasadbeklädnad har en rad naturliga egenskaper som bidrar till hållbarhet, brandmotstånd, robusthet, estetisk mångsidighet och enkel montering. Därutöver frostspränger skivorna inte.

Skivorna är betydligt lättare än de flesta fasadbeklädnadsmaterial och kan bearbetas med standardverktyg som också används för trä. Med mer än 200 färger och färgmönster som enkelt kan kapas, böjas, formas och fräsas erbjuder Rockpanel också stor designfrihet utan att kompromissa med kvaliteten.

Vi har ett brett sortiment av euroklassade A2-s1,d0 fasadskivor med en beräknad livslängd på 50 år. Skivorna kan även återvinnas i det oändliga. Dessutom är 98 % av Rockpanels produktsortiment Cradle to Cradle-certifierat® på silvernivå. Det bekräftar att produkterna är säkra, mer hållbara och stödjer en cirkulär produktlivscykel som bidrar till en mer hållbar framtid.', 'sv', 'Rockpanel utvecklar och tillverkar ett innovativt fasadmaterial av vulkanstenen basalt som passar för fasader, gavlar, takuthäng, takfot och andra byggnadsdetaljer. Rockpanel fasadbeklädnad har en rad naturliga egenskaper som bidrar till hållbarhet, brandmotstånd, robusthet, estetisk mångsidighet och enkel montering. Därutöver frostspränger skivorna inte.

Skivorna är betydligt lättare än de flesta fasadbeklädnadsmaterial och kan bearbetas med standardverktyg som också används för trä. Med mer än 200 färger och färgmönster som enkelt kan kapas, böjas, formas och fräsas erbjuder Rockpanel också stor designfrihet utan att kompromissa med kvaliteten.

Vi har ett brett sortiment av euroklassade A2-s1,d0 fasadskivor med en beräknad livslängd på 50 år. Skivorna kan även återvinnas i det oändliga. Dessutom är 98 % av Rockpanels produktsortiment Cradle to Cradle-certifierat® på silvernivå. Det bekräftar att produkterna är säkra, mer hållbara och stödjer en cirkulär produktlivscykel som bidrar till en mer hållbar framtid.'), 'https://www.rockpanel.se', 'assets/images/exhibitors/nordbygg-2026-rockpanel.jpg'),
  ('nordbygg-2026-exhibitor-139581', 'nordbygg-2026', 'Roll-on Insulation', 'C14:69', null, 'https://www.drynex.se', null),
  ('nordbygg-2026-exhibitor-138689', 'nordbygg-2026', 'Roofit.Solar', 'A23:15', null, 'https://www.roofit.solar', 'assets/images/exhibitors/nordbygg-2026-roofit-solar.jpg'),
  ('nordbygg-2026-exhibitor-134023', 'nordbygg-2026', 'Rukkor AB', 'C01:08', jsonb_build_object('en', 'Rukkor är ett innovativt företag baserat i Ystad. Vi utvecklar programvaror som är enkla att använda – för alla. Vårt flaggskepp, Geometra, är ett professionellt mängdprogram för byggbranschen, och varje dag använder tusentals människor det för att räkna på sina projekt.

På Nordbygg presenterar vi också vår nya produkt, Rukkor – en plattform för digital kommunikation, dokumenthantering och samarbete för företag. Utvecklad i Sverige, fri från annonser och med användaren i fokus.', 'sv', 'Rukkor är ett innovativt företag baserat i Ystad. Vi utvecklar programvaror som är enkla att använda – för alla. Vårt flaggskepp, Geometra, är ett professionellt mängdprogram för byggbranschen, och varje dag använder tusentals människor det för att räkna på sina projekt.

På Nordbygg presenterar vi också vår nya produkt, Rukkor – en plattform för digital kommunikation, dokumenthantering och samarbete för företag. Utvecklad i Sverige, fri från annonser och med användaren i fokus.'), 'https://rukkor.com', 'assets/images/exhibitors/nordbygg-2026-rukkor-ab.jpg'),
  ('nordbygg-2026-exhibitor-135298', 'nordbygg-2026', 'Rutab AB', 'B10:41', jsonb_build_object('en', 'Rutab är Sveriges ledande leverantör av kabelförskruvningar, genomföringar och skyddsslang samt en mycket stark aktör inom maskinkabel, belysningsstyrning och arbetsbelysning.

Det ställs idag höga krav på rätt arbetsmiljö, där tillfällig belysning är en viktig parameter för din säkerhet, effektivitet och möjlighet till att utföra ett professionellt arbete. Vårt breda sortiment av tillfällig belysning är speciellt anpassat för det nordiska klimatet. Vi tillhandahåller  allt från säkerhetsklassade handlampor till större belysningsmaster, alltid utrustade med den senaste batteri och LED tekniken. Genom produktutveckling i vårt eget varumärke tillsammans med Europas främsta tillverkare är vi sedan mer än 15 år en av landets främsta distributör inom professionell belysning för tillfälliga arbetsplatser.', 'sv', 'Rutab är Sveriges ledande leverantör av kabelförskruvningar, genomföringar och skyddsslang samt en mycket stark aktör inom maskinkabel, belysningsstyrning och arbetsbelysning.

Det ställs idag höga krav på rätt arbetsmiljö, där tillfällig belysning är en viktig parameter för din säkerhet, effektivitet och möjlighet till att utföra ett professionellt arbete. Vårt breda sortiment av tillfällig belysning är speciellt anpassat för det nordiska klimatet. Vi tillhandahåller  allt från säkerhetsklassade handlampor till större belysningsmaster, alltid utrustade med den senaste batteri och LED tekniken. Genom produktutveckling i vårt eget varumärke tillsammans med Europas främsta tillverkare är vi sedan mer än 15 år en av landets främsta distributör inom professionell belysning för tillfälliga arbetsplatser.'), 'https://www.rutab.se', 'assets/images/exhibitors/nordbygg-2026-rutab-ab.jpg'),
  ('nordbygg-2026-exhibitor-139143', 'nordbygg-2026', 'Ruukki Sverige AB', 'C17:51', jsonb_build_object('en', 'Vi tillverkar våra produkter ur ett hållbart perspektiv, vägg- och taklösningar för logistik- och industribyggnader, kontor, idrottshallar och arenor. Vi erbjuder dessutom våra kunder design- och produktoptimeringstjänster.', 'sv', 'Vi tillverkar våra produkter ur ett hållbart perspektiv, vägg- och taklösningar för logistik- och industribyggnader, kontor, idrottshallar och arenor. Vi erbjuder dessutom våra kunder design- och produktoptimeringstjänster.'), 'https://www.ruukki.se', 'assets/images/exhibitors/nordbygg-2026-ruukki-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-137895', 'nordbygg-2026', 'Rättviks Trappfabrik AB', 'C07:33E (+1)', null, 'https://www.trappfabriken.se', null),
  ('nordbygg-2026-exhibitor-136680', 'nordbygg-2026', 'S:t Eriks', 'C04:61H (+1)', jsonb_build_object('en', 'S:t Eriks AB ingår i S:t Eriks Group som är en ledande svensk tillverkare och leverantör av betong- och naturstensprodukter till entreprenörer och återförsäljare på den nordiska marknaden för infrastruktur, bygg och landskapsarkitektur. Koncernen har cirka 550 medarbetare vid fabriker och kontor över hela Sverige och en årsomsättning på cirka 1,5 miljarder kronor. I koncernen ingår företagen S:t Eriks, Gunnar Prefab, Isolergrund, Nordskiffer, Stenentreprenader samt Vinninga Cement. S:t Eriks Group är en del av Volati.', 'sv', 'S:t Eriks AB ingår i S:t Eriks Group som är en ledande svensk tillverkare och leverantör av betong- och naturstensprodukter till entreprenörer och återförsäljare på den nordiska marknaden för infrastruktur, bygg och landskapsarkitektur. Koncernen har cirka 550 medarbetare vid fabriker och kontor över hela Sverige och en årsomsättning på cirka 1,5 miljarder kronor. I koncernen ingår företagen S:t Eriks, Gunnar Prefab, Isolergrund, Nordskiffer, Stenentreprenader samt Vinninga Cement. S:t Eriks Group är en del av Volati.'), 'https://steriks.se', 'assets/images/exhibitors/nordbygg-2026-s-t-eriks.jpg'),
  ('nordbygg-2026-exhibitor-135231', 'nordbygg-2026', 'S+S Regeltechnik GmbH', 'A13:02', null, 'https://www.spluss.de', 'assets/images/exhibitors/nordbygg-2026-s-s-regeltechnik-gmbh.jpg'),
  ('nordbygg-2026-exhibitor-139387', 'nordbygg-2026', 'Sabine-E', 'C04:41', jsonb_build_object('en', 'Vi är en lettisk tillverkare av vattenbaserade byggkemikalier och träskyddsprodukter med verksamhet sedan 2002.

Under varumärket ELVI producerar vi träfärger, interiör- och fasadfärger, primers, lim, dekorativa putser, värmebärarvätskor, trädskyddskalk samt professionella träspackel som används inom möbeltillverkning, inklusive produktion för IKEA.

Vår styrka ligger i jämn och hög produktkvalitet, snabba produktionscykler och pålitliga långsiktiga partnerskap. Vi fokuserar på flexibel samverkan med distributörer, tillverkare och private label-partners över hela Europa.', 'sv', 'Vi är en lettisk tillverkare av vattenbaserade byggkemikalier och träskyddsprodukter med verksamhet sedan 2002.

Under varumärket ELVI producerar vi träfärger, interiör- och fasadfärger, primers, lim, dekorativa putser, värmebärarvätskor, trädskyddskalk samt professionella träspackel som används inom möbeltillverkning, inklusive produktion för IKEA.

Vår styrka ligger i jämn och hög produktkvalitet, snabba produktionscykler och pålitliga långsiktiga partnerskap. Vi fokuserar på flexibel samverkan med distributörer, tillverkare och private label-partners över hela Europa.'), 'https://www.sabine-e.lv', 'assets/images/exhibitors/nordbygg-2026-sabine-e.jpg'),
  ('nordbygg-2026-exhibitor-137965', 'nordbygg-2026', 'Safe At Site AB', 'B08:11', jsonb_build_object('en', 'Safe at Site är ett företag med idéer och innovationer grundade i gedigen erfarenhet från många år i säkerhetens tjänst.

Vår vision är att i grunden förändra säkerhetsnivån på bygg- och vägarbetsplatser för att undvika allvarliga olyckor. Detta genom att utveckla smarta produkter, lösningar och tjänster som enkelt säkrar bygg- och vägarbetsplatser och effektivt låter alla som befinner sig på plats arbeta tryggt. Everyone, Everyday.', 'sv', 'Safe at Site är ett företag med idéer och innovationer grundade i gedigen erfarenhet från många år i säkerhetens tjänst.

Vår vision är att i grunden förändra säkerhetsnivån på bygg- och vägarbetsplatser för att undvika allvarliga olyckor. Detta genom att utveckla smarta produkter, lösningar och tjänster som enkelt säkrar bygg- och vägarbetsplatser och effektivt låter alla som befinner sig på plats arbeta tryggt. Everyone, Everyday.'), 'https://www.safeatsite.com', 'assets/images/exhibitors/nordbygg-2026-safe-at-site-ab.jpg'),
  ('nordbygg-2026-exhibitor-139776', 'nordbygg-2026', 'Safera Oy', 'A13:14', null, 'https://www.safera.com/flowhero', 'assets/images/exhibitors/nordbygg-2026-safera-oy.jpg'),
  ('nordbygg-2026-exhibitor-136467', 'nordbygg-2026', 'Safestep', 'C11:31', jsonb_build_object('en', 'Lösningar inom halkskydd, glasfiber, taktila ledstråk och kontrastmarkering som utmanar det förväntade. För en säkrare morgondag.', 'sv', 'Lösningar inom halkskydd, glasfiber, taktila ledstråk och kontrastmarkering som utmanar det förväntade. För en säkrare morgondag.'), 'https://www.safestep.se', 'assets/images/exhibitors/nordbygg-2026-safestep.jpg'),
  ('nordbygg-2026-exhibitor-138125', 'nordbygg-2026', 'Safety GO', 'BG:09', jsonb_build_object('en', 'Vi tror på att lärande ska vara engagerande och minnesvärt. Genom att använda interaktiva metoder, realistiska scenarier och praktiska simuleringar skapar vi en utbildningsupplevelse som håller utbildningsdeltagaren engagerad och aktiv.

Gratis ID06-registrering
Flexibel onlineutbildning
Alla intyg i appen', 'sv', 'Vi tror på att lärande ska vara engagerande och minnesvärt. Genom att använda interaktiva metoder, realistiska scenarier och praktiska simuleringar skapar vi en utbildningsupplevelse som håller utbildningsdeltagaren engagerad och aktiv.

Gratis ID06-registrering
Flexibel onlineutbildning
Alla intyg i appen'), 'https://www.pol.se', 'assets/images/exhibitors/nordbygg-2026-safety-go.jpg'),
  ('nordbygg-2026-exhibitor-138018', 'nordbygg-2026', 'Saint-Gobain Abrasives AB', 'B09:11', jsonb_build_object('en', 'Genom vårt varumärke Norton Clipper erbjuder vi ett komplett sortiment för kapning, sågning, håltagning, borrning och slipning inom bygg- och anläggningsindustrin. Vi erbjuder produkter för såväl byggande av småhus som för stora byggprojekt, omfattande diamantklingor, borrkronor, maskiner och slipprodukter som har högsta möjliga säkerhetsnivå och som bidrar till en bättre miljö.', 'sv', 'Genom vårt varumärke Norton Clipper erbjuder vi ett komplett sortiment för kapning, sågning, håltagning, borrning och slipning inom bygg- och anläggningsindustrin. Vi erbjuder produkter för såväl byggande av småhus som för stora byggprojekt, omfattande diamantklingor, borrkronor, maskiner och slipprodukter som har högsta möjliga säkerhetsnivå och som bidrar till en bättre miljö.'), 'https://www.saint-gobain-abrasives.com/sv-sv', 'assets/images/exhibitors/nordbygg-2026-saint-gobain-abrasives-ab.jpg'),
  ('nordbygg-2026-exhibitor-136824', 'nordbygg-2026', 'Saku Metall Uksetehas AS', 'C15:31', null, 'https://www.sakumetall.ee', 'assets/images/exhibitors/nordbygg-2026-saku-metall-uksetehas-as.jpg'),
  ('nordbygg-2026-exhibitor-137803', 'nordbygg-2026', 'SALDA UAB', 'A21:23', null, 'https://www.salda.lt', 'assets/images/exhibitors/nordbygg-2026-salda-uab.jpg'),
  ('nordbygg-2026-exhibitor-134799', 'nordbygg-2026', 'Samsung Electronics Air Conditioner Europe B.V.', 'A17:22', jsonb_build_object('en', 'Samsung Electronics har kontinuerligt omdefinierat inomhusklimatet för morgondagens samhälle sedan vår första luftkonditioneringsenhet introducerades 1974. År 2005 gav sig Samsung Electronics in på den europeiska marknaden för kommersiella luftkonditioneringsenheter. Samsung Climate Solutions vill hjälpa personer hitta sitt ”flow”, så att de kan leva sina bästa liv – på jobbet och på fritiden. Vi strävar efter att erbjuda mer energieffektiva lösningar med innovativa lösningar för kylning, uppvärmning, varmvatten i bostäder och smarta byggnader. Vi jobbar med alla utrymmen där människor skapar minnesvärda upplevelser tillsammans, oavsett om det handlar om kommersiella utrymmen eller bostäder. Vi erbjuder kontinuerligt våra industripartner tekniska utbildningar om klimat och lösningar för smarta byggnader, teknisk support och support efter försäljning. Med utgångspunkt i Samsungs goda anseende inom kvalitet och innovation, inklusive lösningar för digitala anslutningar.

En långsiktig satsning på marknaden i Europa ledde till att Samsung Electronics Air Conditioner Europe B.V. (SEACE) grundades 2017 i Amsterdam, Nederländerna. På SEACE strävar vi efter att harmonisera verksamheten i över 30 europeiska länder.', 'sv', 'Samsung Electronics har kontinuerligt omdefinierat inomhusklimatet för morgondagens samhälle sedan vår första luftkonditioneringsenhet introducerades 1974. År 2005 gav sig Samsung Electronics in på den europeiska marknaden för kommersiella luftkonditioneringsenheter. Samsung Climate Solutions vill hjälpa personer hitta sitt ”flow”, så att de kan leva sina bästa liv – på jobbet och på fritiden. Vi strävar efter att erbjuda mer energieffektiva lösningar med innovativa lösningar för kylning, uppvärmning, varmvatten i bostäder och smarta byggnader. Vi jobbar med alla utrymmen där människor skapar minnesvärda upplevelser tillsammans, oavsett om det handlar om kommersiella utrymmen eller bostäder. Vi erbjuder kontinuerligt våra industripartner tekniska utbildningar om klimat och lösningar för smarta byggnader, teknisk support och support efter försäljning. Med utgångspunkt i Samsungs goda anseende inom kvalitet och innovation, inklusive lösningar för digitala anslutningar.

En långsiktig satsning på marknaden i Europa ledde till att Samsung Electronics Air Conditioner Europe B.V. (SEACE) grundades 2017 i Amsterdam, Nederländerna. På SEACE strävar vi efter att harmonisera verksamheten i över 30 europeiska länder.'), 'https://samsung-climatesolutions.com/', 'assets/images/exhibitors/nordbygg-2026-samsung-electronics-air-conditioner-europe-b-v.jpg'),
  ('nordbygg-2026-exhibitor-138342', 'nordbygg-2026', 'Sanova AB', 'A05:16', jsonb_build_object('en', 'I över 40 år har Sanova handplockat och samlat några av de finaste varumärkena inom badrumsinredning och belysning under samma tak. Idag samsas designikoner som Stella, LH, Duravit, Brian Parry och Astro Lighting hos oss, vilket gör det enkelt att skapa badrumsmiljöer utöver det vanliga.

Våra produkter tillverkas av människor med genuin kunskap om materialen de arbetar med, och med vårt breda sortiment och helhetskoncept kan du skapa en enhetlig, inspirerande lösning. Vi brinner för badrum och låter gärna vår expertis möta dina behov – med fokus på design, kvalitet och hållbarhet.', 'sv', 'I över 40 år har Sanova handplockat och samlat några av de finaste varumärkena inom badrumsinredning och belysning under samma tak. Idag samsas designikoner som Stella, LH, Duravit, Brian Parry och Astro Lighting hos oss, vilket gör det enkelt att skapa badrumsmiljöer utöver det vanliga.

Våra produkter tillverkas av människor med genuin kunskap om materialen de arbetar med, och med vårt breda sortiment och helhetskoncept kan du skapa en enhetlig, inspirerande lösning. Vi brinner för badrum och låter gärna vår expertis möta dina behov – med fokus på design, kvalitet och hållbarhet.'), 'https://www.sanova.se', 'assets/images/exhibitors/nordbygg-2026-sanova-ab.jpg'),
  ('nordbygg-2026-exhibitor-137899', 'nordbygg-2026', 'SATEMA', 'B09:21', null, 'https://satema.se', 'assets/images/exhibitors/nordbygg-2026-satema.jpg'),
  ('nordbygg-2026-exhibitor-139706', 'nordbygg-2026', 'Sauter Automation AB', 'A22:16', jsonb_build_object('en', 'Sauter Sverige – Precision i varje komponent

Vi är specialister på högkvalitativa fältprodukter för fastighetsautomation. Med schweizisk ingenjörskonst i grunden levererar Sauter marknadsledande ställdon, ventiler, sensorer och regulatorer som säkrar exakt styrning och lång livslängd.

Våra komponenter är utvecklade för att maximera energieffektiviteten och driftsäkerheten i varje installation. Genom innovation och hållbarhet i fokus ser vi till att tekniken bakom inomhusklimatet alltid presterar på topp.', 'sv', 'Sauter Sverige – Precision i varje komponent

Vi är specialister på högkvalitativa fältprodukter för fastighetsautomation. Med schweizisk ingenjörskonst i grunden levererar Sauter marknadsledande ställdon, ventiler, sensorer och regulatorer som säkrar exakt styrning och lång livslängd.

Våra komponenter är utvecklade för att maximera energieffektiviteten och driftsäkerheten i varje installation. Genom innovation och hållbarhet i fokus ser vi till att tekniken bakom inomhusklimatet alltid presterar på topp.'), 'https://www.sauter.se', 'assets/images/exhibitors/nordbygg-2026-sauter-automation-ab.jpg'),
  ('nordbygg-2026-exhibitor-136813', 'nordbygg-2026', 'SCADA Expert Sweden AB', 'A12:06', jsonb_build_object('en', 'SESAB - SCADA Expert Sweden AB gör fastigheter framtidssäkra, trygga och mer hållbara genom byggnadsautomation och fastighetsstyrning. Med expertis inom våra fyra affärsben – SESAB Innovation, SESAB XMC, SESAB Konsult och SESAB Expert Service – skapar vi lösningar som är driftsäkra, kostnadseffektiva och redo för framtiden.

Våra ledord - "Vårt arbete gör skillnad!" är SESAB:s viktigaste drivkraft och en av grundbultarna till att bolagsidén föddes. Att göra skillnad ska finnas med oss i varje beslut och interaktion – i arbetet med kund, kollegor, intressenter och samhället. Stort som smått, varje insats på SESAB ska göra skillnad!', 'sv', 'SESAB - SCADA Expert Sweden AB gör fastigheter framtidssäkra, trygga och mer hållbara genom byggnadsautomation och fastighetsstyrning. Med expertis inom våra fyra affärsben – SESAB Innovation, SESAB XMC, SESAB Konsult och SESAB Expert Service – skapar vi lösningar som är driftsäkra, kostnadseffektiva och redo för framtiden.

Våra ledord - "Vårt arbete gör skillnad!" är SESAB:s viktigaste drivkraft och en av grundbultarna till att bolagsidén föddes. Att göra skillnad ska finnas med oss i varje beslut och interaktion – i arbetet med kund, kollegor, intressenter och samhället. Stort som smått, varje insats på SESAB ska göra skillnad!'), 'https://sesabgroup.com/', 'assets/images/exhibitors/nordbygg-2026-scada-expert-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-137703', 'nordbygg-2026', 'ScandKran', 'B06:30', null, 'https://www.scandkran.se', null),
  ('nordbygg-2026-exhibitor-135954', 'nordbygg-2026', 'Scandtap Bathroom and Kitchen', 'A06:12', jsonb_build_object('en', 'Scandtap Bathroom & Kitchen tillverkar unika produkter i skandinavisk design för ditt kök och badrum.
Materialen som används har valts ut med yttersta precision för att skapa ett klassiskt och stilrent intryck, med en utmärkt beständighet över tid.', 'sv', 'Scandtap Bathroom & Kitchen tillverkar unika produkter i skandinavisk design för ditt kök och badrum.
Materialen som används har valts ut med yttersta precision för att skapa ett klassiskt och stilrent intryck, med en utmärkt beständighet över tid.'), 'https://scandtap.com/', 'assets/images/exhibitors/nordbygg-2026-scandtap-bathroom-and-kitchen.jpg'),
  ('nordbygg-2026-exhibitor-134604', 'nordbygg-2026', 'ScanFast AB', 'B04:21', jsonb_build_object('en', 'Scanfast är ett rikstäckande familjeföretag med rötterna i Bohuslän och Uddevalla på den svenska västkusten, och har varit en ledande kraft inom infästningsbranschen sedan starten 1987. Med ett orubbligt fokus på infästning, fortsätter vi att tänja på gränserna och utrusta byggbranschen med smarta, innovativa lösningar som driver effektivitet och produktivitet.', 'sv', 'Scanfast är ett rikstäckande familjeföretag med rötterna i Bohuslän och Uddevalla på den svenska västkusten, och har varit en ledande kraft inom infästningsbranschen sedan starten 1987. Med ett orubbligt fokus på infästning, fortsätter vi att tänja på gränserna och utrusta byggbranschen med smarta, innovativa lösningar som driver effektivitet och produktivitet.'), 'https://www.scanfast.se', 'assets/images/exhibitors/nordbygg-2026-scanfast-ab.jpg'),
  ('nordbygg-2026-exhibitor-136158', 'nordbygg-2026', 'Scanmaskin', 'B07:20', jsonb_build_object('en', 'Tyrolit – Division Bygg & Anläggning är ett företag specialiserat inom kärnborrning, betongsågning och vajersågning.

Scanmaskin, som numera är en del av Tyrolit Group, har sedan 1975 tillverkat marknadsledande golv-, ytbehandlings- och poleringsutrustning för alla typer av golvprojekt, inklusive slipning, polering, fräsning och blästring.

Vi båda prioriterar hög service, snabba leveranser och absolut bästa kvalitet. All utveckling och tillverkning av golvslipmaskiner sker i vår anläggning i Lindome, i utkanten av Göteborg. Där finns även Tyrolit, med lager samt serviceverkstad för maskinreparationer och omslipning av borr och klingor.', 'sv', 'Tyrolit – Division Bygg & Anläggning är ett företag specialiserat inom kärnborrning, betongsågning och vajersågning.

Scanmaskin, som numera är en del av Tyrolit Group, har sedan 1975 tillverkat marknadsledande golv-, ytbehandlings- och poleringsutrustning för alla typer av golvprojekt, inklusive slipning, polering, fräsning och blästring.

Vi båda prioriterar hög service, snabba leveranser och absolut bästa kvalitet. All utveckling och tillverkning av golvslipmaskiner sker i vår anläggning i Lindome, i utkanten av Göteborg. Där finns även Tyrolit, med lager samt serviceverkstad för maskinreparationer och omslipning av borr och klingor.'), 'https://www.scanmaskin.se', 'assets/images/exhibitors/nordbygg-2026-scanmaskin.jpg'),
  ('nordbygg-2026-exhibitor-137277', 'nordbygg-2026', 'Schneider Electric Sverige AB', 'A15:10', null, 'https://www.schneider-electric.se', 'assets/images/exhibitors/nordbygg-2026-schneider-electric-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-139388', 'nordbygg-2026', 'SCM Latvia', 'C04:41', jsonb_build_object('en', 'Reliable subcontractor for engineering, fabrication and installation of construction, bridge and custom steel structures.
Also providing installation of bearing roof profiles and sandwich panels.

Extensive experience across the Baltics and Scandinavia.

Certified according to ISO 9001, ISO 3834-2, EN 1090-2 (up to EXC4), ISO 14001 and ISO 45001.

SCM Latvia LinkedIn page: https://www.linkedin.com/company/1103767', 'sv', 'Reliable subcontractor for engineering, fabrication and installation of construction, bridge and custom steel structures.
Also providing installation of bearing roof profiles and sandwich panels.

Extensive experience across the Baltics and Scandinavia.

Certified according to ISO 9001, ISO 3834-2, EN 1090-2 (up to EXC4), ISO 14001 and ISO 45001.

SCM Latvia LinkedIn page: https://www.linkedin.com/company/1103767'), 'https://www.scm.lv', 'assets/images/exhibitors/nordbygg-2026-scm-latvia.jpg'),
  ('nordbygg-2026-exhibitor-139526', 'nordbygg-2026', 'SCMREF AB', 'A13:33', null, 'https://www.scmref.se', 'assets/images/exhibitors/nordbygg-2026-scmref-ab.jpg'),
  ('nordbygg-2026-exhibitor-140038', 'nordbygg-2026', 'Scudo Solutions Oy', 'BG:04', jsonb_build_object('en', 'Marknadsledande molntjänst för projektkostnadsstyrning

Scudo Solutions är ett finskbaserat teknikföretag specialiserat på projektkostnadshanteringstjänster och systemutveckling som nu även finns etablerade i sverige. Med erfarenheten av att hantera fler än 50 000 projekt värda över 20 miljarder euro möjliggör vi besparingar på upp till 5 % av projektkostnaderna inom bygg- och fastighetsbranschen.', 'sv', 'Marknadsledande molntjänst för projektkostnadsstyrning

Scudo Solutions är ett finskbaserat teknikföretag specialiserat på projektkostnadshanteringstjänster och systemutveckling som nu även finns etablerade i sverige. Med erfarenheten av att hantera fler än 50 000 projekt värda över 20 miljarder euro möjliggör vi besparingar på upp till 5 % av projektkostnaderna inom bygg- och fastighetsbranschen.'), 'https://www.scudo.se', 'assets/images/exhibitors/nordbygg-2026-scudo-solutions-oy.jpg'),
  ('nordbygg-2026-exhibitor-137394', 'nordbygg-2026', 'SealEco AB', 'C08:51', jsonb_build_object('en', 'Sealeco erbjuder högkvalitativa EPDM-produkter som är både hållbara och miljövänliga, perfekt lämpade för användning i tak, fasader samt geo- och tätningssystem. Våra EPDM-lösningar tillverkas i Sverige och är kända för sin långa livslängd, starka motståndskraft mot väder och goda miljöförhållanden.

Med våra avancerade teknologier kan vi skapa olika typer av EPDM-membran, till och med skräddarsydda ner till varje centimeter för att säkerställa optimal prestanda och passform för alla tillämpningar. Vi har gjort detta sedan 1967 och är mycket stolta över den erfarenhet och expertis som krävs för att leverera enastående resultat.', 'sv', 'Sealeco erbjuder högkvalitativa EPDM-produkter som är både hållbara och miljövänliga, perfekt lämpade för användning i tak, fasader samt geo- och tätningssystem. Våra EPDM-lösningar tillverkas i Sverige och är kända för sin långa livslängd, starka motståndskraft mot väder och goda miljöförhållanden.

Med våra avancerade teknologier kan vi skapa olika typer av EPDM-membran, till och med skräddarsydda ner till varje centimeter för att säkerställa optimal prestanda och passform för alla tillämpningar. Vi har gjort detta sedan 1967 och är mycket stolta över den erfarenhet och expertis som krävs för att leverera enastående resultat.'), 'https://www.sealeco.com', 'assets/images/exhibitors/nordbygg-2026-sealeco-ab.jpg'),
  ('nordbygg-2026-exhibitor-134662', 'nordbygg-2026', 'Sealmaker Finland OY', 'A19:24', null, 'https://www.sealmaker.fi/sv', null),
  ('nordbygg-2026-exhibitor-134701', 'nordbygg-2026', 'SellPower Nordic AB', 'A21:10', null, 'https://www.sellpower.se', 'assets/images/exhibitors/nordbygg-2026-sellpower-nordic-ab.jpg'),
  ('nordbygg-2026-exhibitor-139424', 'nordbygg-2026', 'Sense Dome', 'EÖ:28', null, 'https://sensedome.com/en', null),
  ('nordbygg-2026-exhibitor-138762', 'nordbygg-2026', 'Sensus International', 'A08:35', jsonb_build_object('en', 'Sensus International är en global ledare inom avancerade mätlösningar för vatten och energi, med över 180 års teknisk excellens som grund. Vi utvecklar och levererar både mekaniska och statiska vattenmätare samt energimätare, kompletterade med intelligenta och framtidssäkra systemlösningar.

Genom att stödja energibolag, vattenverk och tillsynsmyndigheter världen över bidrar vi med precisionsmätning, hög driftsäkerhet och digital innovation. Med omfattande produktutveckling i Tyskland och moderna produktionsanläggningar i Tyskland och Slovakien erbjuder Sensus International mät- och systemlösningar som sätter nya standarder för noggrannhet, hållbarhet och smart uppkoppling.', 'sv', 'Sensus International är en global ledare inom avancerade mätlösningar för vatten och energi, med över 180 års teknisk excellens som grund. Vi utvecklar och levererar både mekaniska och statiska vattenmätare samt energimätare, kompletterade med intelligenta och framtidssäkra systemlösningar.

Genom att stödja energibolag, vattenverk och tillsynsmyndigheter världen över bidrar vi med precisionsmätning, hög driftsäkerhet och digital innovation. Med omfattande produktutveckling i Tyskland och moderna produktionsanläggningar i Tyskland och Slovakien erbjuder Sensus International mät- och systemlösningar som sätter nya standarder för noggrannhet, hållbarhet och smart uppkoppling.'), null, 'assets/images/exhibitors/nordbygg-2026-sensus-international.jpg'),
  ('nordbygg-2026-exhibitor-139162', 'nordbygg-2026', 'Senzomatic', 'C08:71', null, 'https://senzomatic.com/en/home', null),
  ('nordbygg-2026-exhibitor-134665', 'nordbygg-2026', 'Sewatek', 'A10:20', jsonb_build_object('en', 'Sewatek är en finsk tillverkare av brandtätningsprodukter. Vi är specialiserade på tidsbesparande lösningar som ofta installeras i samband med VVS-arbeten. Sewatek är inte bara en tillverkare, utan även din partner inom passivt brandskydd. Din lokala partner i Sverige är Sewatek Sverige AB.', 'sv', 'Sewatek är en finsk tillverkare av brandtätningsprodukter. Vi är specialiserade på tidsbesparande lösningar som ofta installeras i samband med VVS-arbeten. Sewatek är inte bara en tillverkare, utan även din partner inom passivt brandskydd. Din lokala partner i Sverige är Sewatek Sverige AB.'), 'https://www.sewatek.se', 'assets/images/exhibitors/nordbygg-2026-sewatek.jpg'),
  ('nordbygg-2026-exhibitor-140007', 'nordbygg-2026', 'SHAH Oy', 'A22:10', null, 'https://shah.fi/en/home', null),
  ('nordbygg-2026-exhibitor-134770', 'nordbygg-2026', 'Shenzhen Everbright Optoelectronics Co.,Ltd', 'A10:24', null, 'https://www.ledeverbright.com', 'assets/images/exhibitors/nordbygg-2026-shenzhen-everbright-optoelectronics-co-ltd.jpg'),
  ('nordbygg-2026-exhibitor-135958', 'nordbygg-2026', 'SI - Sustainable Intelligence', 'A14:02', jsonb_build_object('en', 'Vi på SI-gruppen brinner för att skapa klimat- och energismarta lösningar som gör skillnad. Våra system och mjukvaror används i allt från kontor och affärslokaler till bostäder, VA, spa & bad, hotell och logistikfastigheter – alltid med målet att nå högt ställda hållbarhetskrav och vår vision om en energieffektiv värld.

TILLSAMMANS har vi Sveriges bredaste och djupaste kompetens inom hela kedjan. Det ger oss möjlighet att driva spännande utvecklingsprojekt och utforska nya tekniker som formar framtiden.

Idag är vi över 500 engagerade medarbetare utspridda över 34 kontor i Sverige, Finland & Norge. Vår decentraliserade struktur ger varje kontor stort lokalt ansvar, samtidigt som vi arbetar tätt tillsammans över hela norden – en kultur som förenar lokal förankring med gemensam styrka och expertis

Vi skapar lösningar som gör skillnad – för dig som individ, företag och miljön.', 'sv', 'Vi på SI-gruppen brinner för att skapa klimat- och energismarta lösningar som gör skillnad. Våra system och mjukvaror används i allt från kontor och affärslokaler till bostäder, VA, spa & bad, hotell och logistikfastigheter – alltid med målet att nå högt ställda hållbarhetskrav och vår vision om en energieffektiv värld.

TILLSAMMANS har vi Sveriges bredaste och djupaste kompetens inom hela kedjan. Det ger oss möjlighet att driva spännande utvecklingsprojekt och utforska nya tekniker som formar framtiden.

Idag är vi över 500 engagerade medarbetare utspridda över 34 kontor i Sverige, Finland & Norge. Vår decentraliserade struktur ger varje kontor stort lokalt ansvar, samtidigt som vi arbetar tätt tillsammans över hela norden – en kultur som förenar lokal förankring med gemensam styrka och expertis

Vi skapar lösningar som gör skillnad – för dig som individ, företag och miljön.'), 'https://www.wearesi.se', 'assets/images/exhibitors/nordbygg-2026-si-sustainable-intelligence.jpg'),
  ('nordbygg-2026-exhibitor-139391', 'nordbygg-2026', 'SIA Tenax Panel', 'C04:41', jsonb_build_object('en', 'ONE OF THE LEADING SANDWICH PANEL PRODUCERS IN NORTHERN EUROPE.', 'sv', 'ONE OF THE LEADING SANDWICH PANEL PRODUCERS IN NORTHERN EUROPE.'), 'https://www.tenaxpanel.lv', 'assets/images/exhibitors/nordbygg-2026-sia-tenax-panel.jpg'),
  ('nordbygg-2026-exhibitor-139399', 'nordbygg-2026', 'SIA VIA-S Modular Houses', 'C04:41', jsonb_build_object('en', '22 years of experience in production, delivery and installation of of high-quality prefabricated modular houses suitable for any climate conditions and seasons.
Specializing in long-term B2B partnerships models with developers, resorts, and campsites, architects across Europe - delivering high-quality modular houses at scale.', 'sv', '22 years of experience in production, delivery and installation of of high-quality prefabricated modular houses suitable for any climate conditions and seasons.
Specializing in long-term B2B partnerships models with developers, resorts, and campsites, architects across Europe - delivering high-quality modular houses at scale.'), 'https://en.via-s.lv/', 'assets/images/exhibitors/nordbygg-2026-sia-via-s-modular-houses.jpg'),
  ('nordbygg-2026-exhibitor-137701', 'nordbygg-2026', 'SIBE International AB', 'A21:21', jsonb_build_object('en', 'SIBE International AB har varit verksamma i över 50 år och är specialister på all teknik för luftbefuktning, evaporativ kylning, vattenrening och avfuktning. SIBE är också den enda leverantören i Sverige med ett komplett teknikspektrum inom befuktning, med egna funktionslösningar och konstruktioner. Detta säkerställer att systemlösningarna alltid kan optimeras, dimensioneras och anpassas efter aktuella förutsättningar, med rätt teknik, för rätt applikation.

SIBE finns i regionerna Stockholm – Vimmerby – Göteborg, där företaget har egna tekniker och lager av förbrukningsmaterial, reservdelar och kompletta anläggningskomponenter. Utöver detta finns även ett etablerat samarbete med ett stort antal grossister, återförsäljare och entreprenörer i Sverige och Europa.

Med helheten och systemets livscykel i fokus, skapas energi- och vatteneffektiva funktionslösningar för miljövänlig luftbefuktning, evaporativ kylning, vattenrening och avfuktning, där det adderas olika mervärden för slutanvändaren.', 'sv', 'SIBE International AB har varit verksamma i över 50 år och är specialister på all teknik för luftbefuktning, evaporativ kylning, vattenrening och avfuktning. SIBE är också den enda leverantören i Sverige med ett komplett teknikspektrum inom befuktning, med egna funktionslösningar och konstruktioner. Detta säkerställer att systemlösningarna alltid kan optimeras, dimensioneras och anpassas efter aktuella förutsättningar, med rätt teknik, för rätt applikation.

SIBE finns i regionerna Stockholm – Vimmerby – Göteborg, där företaget har egna tekniker och lager av förbrukningsmaterial, reservdelar och kompletta anläggningskomponenter. Utöver detta finns även ett etablerat samarbete med ett stort antal grossister, återförsäljare och entreprenörer i Sverige och Europa.

Med helheten och systemets livscykel i fokus, skapas energi- och vatteneffektiva funktionslösningar för miljövänlig luftbefuktning, evaporativ kylning, vattenrening och avfuktning, där det adderas olika mervärden för slutanvändaren.'), 'https://www.sibe.se', 'assets/images/exhibitors/nordbygg-2026-sibe-international-ab.jpg'),
  ('nordbygg-2026-exhibitor-140021', 'nordbygg-2026', 'Siemens AB', 'A09:22', jsonb_build_object('en', 'Siemens AG is a leading technology company focused on industry, infrastructure, mobility, and healthcare. The company’s purpose is to create technology to transform the everyday, for everyone. By combining the real and the digital worlds, Siemens empowers customers to accelerate their digital and sustainability transformations, making factories more efficient, cities more livable, and transportation more sustainable. A leader in industrial AI, Siemens leverages its deep domain know-how to apply AI – including generative AI – to real-world applications, making AI accessible and impactful for customers across diverse industries. For more information, visit www.siemens.com.', 'sv', 'Siemens AG is a leading technology company focused on industry, infrastructure, mobility, and healthcare. The company’s purpose is to create technology to transform the everyday, for everyone. By combining the real and the digital worlds, Siemens empowers customers to accelerate their digital and sustainability transformations, making factories more efficient, cities more livable, and transportation more sustainable. A leader in industrial AI, Siemens leverages its deep domain know-how to apply AI – including generative AI – to real-world applications, making AI accessible and impactful for customers across diverse industries. For more information, visit www.siemens.com.'), 'https://www.siemens.se', 'assets/images/exhibitors/nordbygg-2026-siemens-ab.jpg'),
  ('nordbygg-2026-exhibitor-136912', 'nordbygg-2026', 'Sievi AB', 'B02:01', jsonb_build_object('en', 'Säkra och bekväma skor utgör grunden för en bra arbetsdag. Sievi skor är resultatet av teknologisk innovation, högkvalitativa material och ett gediget hantverk. Dessa tillsammans med en ansvarsfull och hållbar produktion garanterar högsta kvalitet, säkerhet och komfort. Så när du har på dig Sievi skyddsskor kan du vara trygg - de gör sitt jobb utmärkt precis som du.', 'sv', 'Säkra och bekväma skor utgör grunden för en bra arbetsdag. Sievi skor är resultatet av teknologisk innovation, högkvalitativa material och ett gediget hantverk. Dessa tillsammans med en ansvarsfull och hållbar produktion garanterar högsta kvalitet, säkerhet och komfort. Så när du har på dig Sievi skyddsskor kan du vara trygg - de gör sitt jobb utmärkt precis som du.'), 'https://www.sievi.se', 'assets/images/exhibitors/nordbygg-2026-sievi-ab.jpg'),
  ('nordbygg-2026-exhibitor-138962', 'nordbygg-2026', 'SIFU', 'EH:11', jsonb_build_object('en', 'SIFU är ett utbildningsföretag som har hjälpt personer att växa i sin yrkesroll sedan 1922. Varje år utbildar vi
tusentals personer inom privat näringsliv och offentlig sektor

Vi utbildar främst inom bygg, betong, teknik och ledarskap men även inom samhällsutveckling, offentlig administration, vård och skola. Våra kunder kommer från både privata och offentliga företag, små som stora organisationer.

Med över 200 kurser och konferenser bidrar vi årligen till tusentals personers kompetensutveckling. Det här gör oss till ett av Sveriges ledande utbildningsföretag inom specifika branscher. Vi ger våra kursdeltagare värdefulla kunskaper och erfarenheter så att din organisation tryggt kan möta omvärldens krav på utveckling och förändring.

SIFUs alla kursområden
Arbetsmiljö  |  Betong  |  Bygg och anläggning  |  Elteknik  | Energi | Fastighet  |  Hälsa, vård och omsorg  |  Industriproduktion  | Inköp och ekonomi  |  Kemikalier och laboratorieverksamhet  | Ledarskap och projektledning |  Medicinska gaser  |  Skola och utbildning  |  Strålskydd  |  Vatten och avlopp |  VVS', 'sv', 'SIFU är ett utbildningsföretag som har hjälpt personer att växa i sin yrkesroll sedan 1922. Varje år utbildar vi
tusentals personer inom privat näringsliv och offentlig sektor

Vi utbildar främst inom bygg, betong, teknik och ledarskap men även inom samhällsutveckling, offentlig administration, vård och skola. Våra kunder kommer från både privata och offentliga företag, små som stora organisationer.

Med över 200 kurser och konferenser bidrar vi årligen till tusentals personers kompetensutveckling. Det här gör oss till ett av Sveriges ledande utbildningsföretag inom specifika branscher. Vi ger våra kursdeltagare värdefulla kunskaper och erfarenheter så att din organisation tryggt kan möta omvärldens krav på utveckling och förändring.

SIFUs alla kursområden
Arbetsmiljö  |  Betong  |  Bygg och anläggning  |  Elteknik  | Energi | Fastighet  |  Hälsa, vård och omsorg  |  Industriproduktion  | Inköp och ekonomi  |  Kemikalier och laboratorieverksamhet  | Ledarskap och projektledning |  Medicinska gaser  |  Skola och utbildning  |  Strålskydd  |  Vatten och avlopp |  VVS'), 'https://www.sifu.se', 'assets/images/exhibitors/nordbygg-2026-sifu.jpg'),
  ('nordbygg-2026-exhibitor-136923', 'nordbygg-2026', 'Sika Footwear A/S', 'B02:50', jsonb_build_object('en', 'Sika Footwear A/S utvecklar, producerar och levererar skyddsskor och arbetsfotbeklädnad till en mängd olika branscher, användare och behov. Vårt sortiment är brett och omfattar allt från träskor, skor och sandaler till boots, stövlar och tillbehör. På Nordbygg sätter vi fokus på ett av våra egna varumärken – BRYNJE.

BRYNJE är ett välkänt danskt varumärke som utvecklar skyddsskor för många branscher – från bygg och transport till lager, lantbruk och industri. Med innovation och erfarenhet som grund skapar BRYNJE skor som kombinerar säkerhet, modern design och enastående komfort. Varje BRYNJE-sko är utvecklad med noggrant utvalda material och avancerade teknologier som ger energi hela dagen och kraft även efter jobbet.

Få mer information om vårt företag och våra produkter på www.sikafootwear.se eller besök oss i monter B02:50.', 'sv', 'Sika Footwear A/S utvecklar, producerar och levererar skyddsskor och arbetsfotbeklädnad till en mängd olika branscher, användare och behov. Vårt sortiment är brett och omfattar allt från träskor, skor och sandaler till boots, stövlar och tillbehör. På Nordbygg sätter vi fokus på ett av våra egna varumärken – BRYNJE.

BRYNJE är ett välkänt danskt varumärke som utvecklar skyddsskor för många branscher – från bygg och transport till lager, lantbruk och industri. Med innovation och erfarenhet som grund skapar BRYNJE skor som kombinerar säkerhet, modern design och enastående komfort. Varje BRYNJE-sko är utvecklad med noggrant utvalda material och avancerade teknologier som ger energi hela dagen och kraft även efter jobbet.

Få mer information om vårt företag och våra produkter på www.sikafootwear.se eller besök oss i monter B02:50.'), 'https://www.sikafootwear.dk', 'assets/images/exhibitors/nordbygg-2026-sika-footwear-a-s.jpg'),
  ('nordbygg-2026-exhibitor-138694', 'nordbygg-2026', 'SIKAB', 'C07:71', jsonb_build_object('en', 'Tejp, märk och gravyrspecialist med mer än 60 års erfarenhet med tekniska industrilösningar. Vi erbjuder ett brett sortiment av tejper, anpassade efter era behov och krav. I vår ISO 9001/14001 certifierade fabrik har vi konvertering, gravyr, lasermärkning, skylttillverkning och CNC fräsning.

Allt inom skärning av tejp, längd eller bredd spelar ingen roll, vi anpassar till kundens behov. Dessutom kan vi stansa eller laserskära till önskad dimension.
2026 Nordbygg genomför vi tillsammans med vår partner KISO. Ni träffar dem i vår monter där vi fokuserar på tejp inom Bygg, Glasvägg och Industri segmenten.', 'sv', 'Tejp, märk och gravyrspecialist med mer än 60 års erfarenhet med tekniska industrilösningar. Vi erbjuder ett brett sortiment av tejper, anpassade efter era behov och krav. I vår ISO 9001/14001 certifierade fabrik har vi konvertering, gravyr, lasermärkning, skylttillverkning och CNC fräsning.

Allt inom skärning av tejp, längd eller bredd spelar ingen roll, vi anpassar till kundens behov. Dessutom kan vi stansa eller laserskära till önskad dimension.
2026 Nordbygg genomför vi tillsammans med vår partner KISO. Ni träffar dem i vår monter där vi fokuserar på tejp inom Bygg, Glasvägg och Industri segmenten.'), 'https://www.sikab.se', 'assets/images/exhibitors/nordbygg-2026-sikab.jpg'),
  ('nordbygg-2026-exhibitor-138138', 'nordbygg-2026', 'Silent Decor Sweden AB', 'C15:11', jsonb_build_object('en', 'Vi analyserar och åtgärdar
era bullerproblem

Silentdecor har ett stort kunnande och ett brett sortiment av bullerdämpande och
ljudisolerande produkter.
Alla våra produkter tillverkas i Sverige och uppfyller högt ställda krav när det gäller kvalitet, miljö och hälsa.

Är ni i behov av ljuddämpande åtgärder men vet inte vad ni ska välja? Då är ni välkomna att använda vår populära tjänst Akustikhjälpen.', 'sv', 'Vi analyserar och åtgärdar
era bullerproblem

Silentdecor har ett stort kunnande och ett brett sortiment av bullerdämpande och
ljudisolerande produkter.
Alla våra produkter tillverkas i Sverige och uppfyller högt ställda krav när det gäller kvalitet, miljö och hälsa.

Är ni i behov av ljuddämpande åtgärder men vet inte vad ni ska välja? Då är ni välkomna att använda vår populära tjänst Akustikhjälpen.'), 'https://www.silentdecor.com', 'assets/images/exhibitors/nordbygg-2026-silent-decor-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-138824', 'nordbygg-2026', 'SIS Svenska Institutet för Standarder', 'C06:11', jsonb_build_object('en', 'Hållbar samhällsbyggnad – standarder för en hållbar framtid!

SIS är en ideell förening som samlar experter från näringsliv, offentlig sektor och akademi för att ta fram gemensamma standarder. Genom standardisering stärker SIS Sveriges konkurrenskraft och bidrar till en smart och hållbar samhällsutveckling – i Sverige och internationellt.', 'sv', 'Hållbar samhällsbyggnad – standarder för en hållbar framtid!

SIS är en ideell förening som samlar experter från näringsliv, offentlig sektor och akademi för att ta fram gemensamma standarder. Genom standardisering stärker SIS Sveriges konkurrenskraft och bidrar till en smart och hållbar samhällsutveckling – i Sverige och internationellt.'), 'https://www.sis.se', 'assets/images/exhibitors/nordbygg-2026-sis-svenska-institutet-for-standarder.jpg'),
  ('nordbygg-2026-exhibitor-137751', 'nordbygg-2026', 'Sjöholms Snickeri', 'C07:33C', null, 'https://www.sjoholmssnickeri.se', null),
  ('nordbygg-2026-exhibitor-137879', 'nordbygg-2026', 'Skawen', 'A20:16', jsonb_build_object('en', 'Kundanpassade Ventilationslösningar för Krävande Applikationer
Det som verkligen skiljer Skawen från mängden är vårt unika casing-koncept. Genom att bygga våra anläggningar i aluminiumkomposit skapar vi en lösning som står emot de allra tuffaste miljöerna – från badhus och poolanläggningar till krävande industriella miljöer som slakterier och kvarnar.
Resultatet? Marknadens mest hållbara och långlivade system.

Men hållbarhet är bara början. Tack vare en extremt flexibel design- och tillverkningsprocess kan vi göra sådant våra konkurrenter inte klarar. Vi anpassar varje anläggning efter befintliga utrymmen – perfekt för renoveringsmarknaden där varje centimeter räknas. Genom att leverera våra system i moduler minimerar vi dessutom installationsarbete och stillestånd på plats.

Full kontroll – dygnet runt
Vi har även tagit ett stort steg framåt inom styrning och övervakning. Vår egenutvecklade kontrollenhet med tillhörande app ger oss möjlighet att följa drift och prestanda 24/7, helt transparent.
Till skillnad från vissa aktörer på marknaden behöver vi inte dölja någonting – våra system är inte underdimensionerade, de levererar vad de lovar och mer därtill.

Pionjärer inom ventilationssystem med värmepump
Skawen var tidiga med att integrera värmepumpsteknik direkt i ventilationssystemen. Idag ser vi en stark efterfrågan – särskilt i Centraleuropa och nu även i Norden – på våra system med reversibel värmepump, som skapar ett stabilt och energieffektivt inomhusklimat året runt för kontor och mindre kommersiella miljöer.

Skawen Residential – revolutionen inom renovering av flerbostadshus
För renovering av flerbostadshus har vi utvecklat Skawen Residential, ett helt nytt och patenterat produktprogram för ventilation och värmeåtervinning.
Vår unika installationsplattform – där patentansökan nyligen lämnats in – gör installationen snabb, kostnadseffektiv och minimalt störande för både byggherre och boende.
Med bevisat hög värmeåtervinningsgrad skapar vi dessutom korta återbetalningstider och starka ekonomiska incitament i varje projekt', 'sv', 'Kundanpassade Ventilationslösningar för Krävande Applikationer
Det som verkligen skiljer Skawen från mängden är vårt unika casing-koncept. Genom att bygga våra anläggningar i aluminiumkomposit skapar vi en lösning som står emot de allra tuffaste miljöerna – från badhus och poolanläggningar till krävande industriella miljöer som slakterier och kvarnar.
Resultatet? Marknadens mest hållbara och långlivade system.

Men hållbarhet är bara början. Tack vare en extremt flexibel design- och tillverkningsprocess kan vi göra sådant våra konkurrenter inte klarar. Vi anpassar varje anläggning efter befintliga utrymmen – perfekt för renoveringsmarknaden där varje centimeter räknas. Genom att leverera våra system i moduler minimerar vi dessutom installationsarbete och stillestånd på plats.

Full kontroll – dygnet runt
Vi har även tagit ett stort steg framåt inom styrning och övervakning. Vår egenutvecklade kontrollenhet med tillhörande app ger oss möjlighet att följa drift och prestanda 24/7, helt transparent.
Till skillnad från vissa aktörer på marknaden behöver vi inte dölja någonting – våra system är inte underdimensionerade, de levererar vad de lovar och mer därtill.

Pionjärer inom ventilationssystem med värmepump
Skawen var tidiga med att integrera värmepumpsteknik direkt i ventilationssystemen. Idag ser vi en stark efterfrågan – särskilt i Centraleuropa och nu även i Norden – på våra system med reversibel värmepump, som skapar ett stabilt och energieffektivt inomhusklimat året runt för kontor och mindre kommersiella miljöer.

Skawen Residential – revolutionen inom renovering av flerbostadshus
För renovering av flerbostadshus har vi utvecklat Skawen Residential, ett helt nytt och patenterat produktprogram för ventilation och värmeåtervinning.
Vår unika installationsplattform – där patentansökan nyligen lämnats in – gör installationen snabb, kostnadseffektiv och minimalt störande för både byggherre och boende.
Med bevisat hög värmeåtervinningsgrad skapar vi dessutom korta återbetalningstider och starka ekonomiska incitament i varje projekt'), 'https://www.skawen.com', 'assets/images/exhibitors/nordbygg-2026-skawen.jpg'),
  ('nordbygg-2026-exhibitor-137551', 'nordbygg-2026', 'SKIL B.V.', 'B03:32', null, 'https://www.skil.se', null),
  ('nordbygg-2026-exhibitor-138486', 'nordbygg-2026', 'SkorstensFolket Sverige AB', 'A22:20', jsonb_build_object('en', 'SkorstensFolket är landets ledande entreprenörsorganisation när det gäller skorstenar, skorstensrenovering och ventilation. Vi består av fler än 40 företag över hela Sverige.

SkorstensFolket har den nordiska agenturen för VentilFlex®, en marknadsledande produkt för relining av ventilationskanaler. Bland beställarna och projekten finns bland annat Sveriges Allmännytta, Peab, HSB Göteborg, Signalisten Solna, SKB, Statens Fastighetsverk och många bostadsrättsföreningar.', 'sv', 'SkorstensFolket är landets ledande entreprenörsorganisation när det gäller skorstenar, skorstensrenovering och ventilation. Vi består av fler än 40 företag över hela Sverige.

SkorstensFolket har den nordiska agenturen för VentilFlex®, en marknadsledande produkt för relining av ventilationskanaler. Bland beställarna och projekten finns bland annat Sveriges Allmännytta, Peab, HSB Göteborg, Signalisten Solna, SKB, Statens Fastighetsverk och många bostadsrättsföreningar.'), 'https://www.ventilflex.se', 'assets/images/exhibitors/nordbygg-2026-skorstensfolket-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-134783', 'nordbygg-2026', 'Slussen Building Services', 'A12:08', null, 'https://www.slussen.biz', 'assets/images/exhibitors/nordbygg-2026-slussen-building-services.jpg'),
  ('nordbygg-2026-exhibitor-137187', 'nordbygg-2026', 'Sluta Riv i Sverige AB', 'A11:18', null, 'https://www.slutariv.se', null),
  ('nordbygg-2026-exhibitor-139728', 'nordbygg-2026', 'Smart Hamster', 'C02:10', null, 'https://smarthamster.se', null),
  ('nordbygg-2026-exhibitor-139911', 'nordbygg-2026', 'Smartax', 'C12:52', jsonb_build_object('en', 'Smartax – framtidens innerväggar för cirkulärt byggande
Smartax utvecklar och levererar innovativa innerväggssystem anpassade för ett mer flexibelt och hållbart byggande. Våra lösningar är designade för demontering och återbruk – vilket gör det möjligt att anpassa lokaler över tid utan att skapa onödigt avfall.
I en byggbransch där lokaler ofta byggs om vart 7–10 år möjliggör Smartax en ny standard: väggar som kan flyttas, återanvändas och skapa långsiktigt värde för fastighetsägare och hyresgäster.
Genom att kombinera cirkulär systemdesign med effektiv installation bidrar vi till:
Minskad klimatpåverkan
Lägre livscykelkostnader
Ökad flexibilitet och mer uthyrningsbar yta
Smartax är en partner för framtidens byggande – där varje komponent är designad för fler livscykler.', 'sv', 'Smartax – framtidens innerväggar för cirkulärt byggande
Smartax utvecklar och levererar innovativa innerväggssystem anpassade för ett mer flexibelt och hållbart byggande. Våra lösningar är designade för demontering och återbruk – vilket gör det möjligt att anpassa lokaler över tid utan att skapa onödigt avfall.
I en byggbransch där lokaler ofta byggs om vart 7–10 år möjliggör Smartax en ny standard: väggar som kan flyttas, återanvändas och skapa långsiktigt värde för fastighetsägare och hyresgäster.
Genom att kombinera cirkulär systemdesign med effektiv installation bidrar vi till:
Minskad klimatpåverkan
Lägre livscykelkostnader
Ökad flexibilitet och mer uthyrningsbar yta
Smartax är en partner för framtidens byggande – där varje komponent är designad för fler livscykler.'), 'https://www.smartax.se', 'assets/images/exhibitors/nordbygg-2026-smartax.jpg'),
  ('nordbygg-2026-exhibitor-135900', 'nordbygg-2026', 'SmartCraft', 'C01:13', jsonb_build_object('en', 'SmartCraft är Nordens ledande leverantör av programvara som tjänst (SaaS) för hantverkare och byggbranschen. Koncernen består av 270 anställda som betjänar över 13?800 kunder från 16 kontor i Norge, Sverige, Finland och Storbritannien.Vi täcker ett brett spektrum av områden inom byggbranschen med våra lösningar. Djup kunskap om de nischer vi verkar inom och riktade lösningar som löser byggföretags och hantverkares behov har varit centralt för vårt fokus. Våra bolag erbjuder marknadsledande SaaS-lösningar och våra medarbetare samlar tillsammans på sig över 1000 års erfarenhet.

På Nordbygg representeras vi av:

Bygglet: Ett digitalt projektledningsverktyg utvecklat för små och medelstora entreprenörer.

Congrid: En digital plattform för kvalitets- och säkerhetshantering på byggarbetsplatser.

Homerun: Ett kommunikations- och dokumentationsverktyg för bostadsrenoveringsprojekt och boendedialog.', 'sv', 'SmartCraft är Nordens ledande leverantör av programvara som tjänst (SaaS) för hantverkare och byggbranschen. Koncernen består av 270 anställda som betjänar över 13?800 kunder från 16 kontor i Norge, Sverige, Finland och Storbritannien.Vi täcker ett brett spektrum av områden inom byggbranschen med våra lösningar. Djup kunskap om de nischer vi verkar inom och riktade lösningar som löser byggföretags och hantverkares behov har varit centralt för vårt fokus. Våra bolag erbjuder marknadsledande SaaS-lösningar och våra medarbetare samlar tillsammans på sig över 1000 års erfarenhet.

På Nordbygg representeras vi av:

Bygglet: Ett digitalt projektledningsverktyg utvecklat för små och medelstora entreprenörer.

Congrid: En digital plattform för kvalitets- och säkerhetshantering på byggarbetsplatser.

Homerun: Ett kommunikations- och dokumentationsverktyg för bostadsrenoveringsprojekt och boendedialog.'), 'https://www.bygglet.com', 'assets/images/exhibitors/nordbygg-2026-smartcraft.jpg'),
  ('nordbygg-2026-exhibitor-139201', 'nordbygg-2026', 'Smartpanel', 'C04:11', jsonb_build_object('en', 'Smartpanel förenklar byggprocessen med norsktillverkade paneler som kombinerar estetik med extrem tidseffektivitet. Vi erbjuder ett brett sortiment av färdigbehandlade vägg- och taklösningar som eliminerar behovet av gipsning, spackling och målning.

Besök oss i vår monter CO4:11 för att uppleva hur vi förenklar vardagen för både hantverkare och arkitekter genom smartare byggmaterial.', 'sv', 'Smartpanel förenklar byggprocessen med norsktillverkade paneler som kombinerar estetik med extrem tidseffektivitet. Vi erbjuder ett brett sortiment av färdigbehandlade vägg- och taklösningar som eliminerar behovet av gipsning, spackling och målning.

Besök oss i vår monter CO4:11 för att uppleva hur vi förenklar vardagen för både hantverkare och arkitekter genom smartare byggmaterial.'), 'https://smartpanel.no/se/', 'assets/images/exhibitors/nordbygg-2026-smartpanel.jpg'),
  ('nordbygg-2026-exhibitor-139282', 'nordbygg-2026', 'Smartproduktion Sverige AB', 'BG:12', jsonb_build_object('en', 'Smartproduktion är ett entreprenörsdrivet bolag specifikt inriktat på bygg- och tjänsteföretag. Vi hjälper dig att spara tid, öka lönsamheten och växa tryggt genom digital marknadsföring, digitalisering och branschspecifik mjukvara.', 'sv', 'Smartproduktion är ett entreprenörsdrivet bolag specifikt inriktat på bygg- och tjänsteföretag. Vi hjälper dig att spara tid, öka lönsamheten och växa tryggt genom digital marknadsföring, digitalisering och branschspecifik mjukvara.'), 'https://www.smartproduktion.se', 'assets/images/exhibitors/nordbygg-2026-smartproduktion-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-134391', 'nordbygg-2026', 'Smeg Nordic AB', 'C06:12', null, 'https://www.smeg.se', 'assets/images/exhibitors/nordbygg-2026-smeg-nordic-ab.jpg'),
  ('nordbygg-2026-exhibitor-134022', 'nordbygg-2026', 'Snidex AB', 'C13:40', null, 'https://www.snidex.se', null),
  ('nordbygg-2026-exhibitor-139175', 'nordbygg-2026', 'SoftOne', 'A07:33', jsonb_build_object('en', 'SoftOne hjälper företag att förenkla och effektivisera sina verksamheter genom smarta, molnbaserade affärssystem. Med över 30 års erfarenhet erbjuder vi lösningar inom HR, lön, tidrapportering, schemaläggning och ekonomi – särskilt anpassade för tjänsteintensiva branscher som retail, hotell och restaurang.

Vår plattform samlar hela verksamheten i ett och samma system, vilket ger bättre kontroll, ökad lönsamhet och mer tid till det som verkligen skapar värde. Med fokus på användarvänlighet och automation hjälper vi företag att växa – utan att öka administrationen.', 'sv', 'SoftOne hjälper företag att förenkla och effektivisera sina verksamheter genom smarta, molnbaserade affärssystem. Med över 30 års erfarenhet erbjuder vi lösningar inom HR, lön, tidrapportering, schemaläggning och ekonomi – särskilt anpassade för tjänsteintensiva branscher som retail, hotell och restaurang.

Vår plattform samlar hela verksamheten i ett och samma system, vilket ger bättre kontroll, ökad lönsamhet och mer tid till det som verkligen skapar värde. Med fokus på användarvänlighet och automation hjälper vi företag att växa – utan att öka administrationen.'), 'https://www.softone.se', 'assets/images/exhibitors/nordbygg-2026-softone.jpg'),
  ('nordbygg-2026-exhibitor-140105', 'nordbygg-2026', 'Solarix', 'C03:41', jsonb_build_object('en', 'Transform every building into a powerhouse with solar facades.

Solarix designs and manufactures coloured solar panels for building facades. Using advanced colour technology, curated design collections, and an integrated mounting system, Solarix panels blend seamlessly into architecture, creating elegant facades that support energy-positive buildings and more sustainable cities.', 'sv', 'Transform every building into a powerhouse with solar facades.

Solarix designs and manufactures coloured solar panels for building facades. Using advanced colour technology, curated design collections, and an integrated mounting system, Solarix panels blend seamlessly into architecture, creating elegant facades that support energy-positive buildings and more sustainable cities.'), 'https://solarix-solar.com/en', 'assets/images/exhibitors/nordbygg-2026-solarix.jpg'),
  ('nordbygg-2026-exhibitor-139845', 'nordbygg-2026', 'Sollenberg Verktyg', 'BG:28', jsonb_build_object('en', 'S Sollenberg Verktyg är en av Sveriges mest erfarna leverantörer av kvalitetsverktyg så som Borr, Bits, Sågblad, Hammare mm.', 'sv', 'S Sollenberg Verktyg är en av Sveriges mest erfarna leverantörer av kvalitetsverktyg så som Borr, Bits, Sågblad, Hammare mm.'), 'https://www.sollenberg-verktyg.se', null),
  ('nordbygg-2026-exhibitor-134645', 'nordbygg-2026', 'Somatherm VVS AB', 'A06:18', jsonb_build_object('en', 'Somatherm VVS AB ligger i Arvika, Värmland där vi har lager och kontor. Vår verksamhet bedriver försäljning inom tryckhållning/expansionskärl, avgasning, avskiljning och VVS armatur.', 'sv', 'Somatherm VVS AB ligger i Arvika, Värmland där vi har lager och kontor. Vår verksamhet bedriver försäljning inom tryckhållning/expansionskärl, avgasning, avskiljning och VVS armatur.'), 'https://somathermvvs.se', 'assets/images/exhibitors/nordbygg-2026-somatherm-vvs-ab.jpg'),
  ('nordbygg-2026-exhibitor-139196', 'nordbygg-2026', 'Sortimo Bilinredning', 'AG:132', jsonb_build_object('en', 'Maximera din arbetsdag med Sortimo bilinredning

Vill du ha full kontroll i servicebilen, spara tid varje dag och samtidigt ge ett professionellt intryck hos kund? Med bilinredning från Sortimo får du en genomtänkt lösning där kvalitet, säkerhet och effektivitet står i centrum.

Slipp leta efter verktyg och material. Sortimos system gör det enkelt att organisera allt från smådelar till tunga maskiner. Varje sak har sin plats – vilket minskar stress, sparar tid och ökar produktiviteten.

Sortimos krocktestade inredningar är utvecklade för att skydda både förare och last. Smarta låssystem, robusta material och innovativ design gör att du kan köra tryggt, även med tung utrustning ombord.

Skräddarsytt för din verksamhet

Oavsett om du är elektriker, VVS-montör, servicetekniker eller entreprenör anpassas lösningen efter dina behov och ditt fordon. Resultatet? En mobil arbetsplats som stärker ditt varumärke och gör varje uppdrag mer effektivt.

Gör servicebilen till din bästa medarbetare – välj Sortimo.', 'sv', 'Maximera din arbetsdag med Sortimo bilinredning

Vill du ha full kontroll i servicebilen, spara tid varje dag och samtidigt ge ett professionellt intryck hos kund? Med bilinredning från Sortimo får du en genomtänkt lösning där kvalitet, säkerhet och effektivitet står i centrum.

Slipp leta efter verktyg och material. Sortimos system gör det enkelt att organisera allt från smådelar till tunga maskiner. Varje sak har sin plats – vilket minskar stress, sparar tid och ökar produktiviteten.

Sortimos krocktestade inredningar är utvecklade för att skydda både förare och last. Smarta låssystem, robusta material och innovativ design gör att du kan köra tryggt, även med tung utrustning ombord.

Skräddarsytt för din verksamhet

Oavsett om du är elektriker, VVS-montör, servicetekniker eller entreprenör anpassas lösningen efter dina behov och ditt fordon. Resultatet? En mobil arbetsplats som stärker ditt varumärke och gör varje uppdrag mer effektivt.

Gör servicebilen till din bästa medarbetare – välj Sortimo.'), 'https://www.sortimo.se', 'assets/images/exhibitors/nordbygg-2026-sortimo-bilinredning.jpg'),
  ('nordbygg-2026-exhibitor-135890', 'nordbygg-2026', 'Soudal AB', 'C07:61', null, 'https://www.soudal.se', null),
  ('nordbygg-2026-exhibitor-137395', 'nordbygg-2026', 'SPAX Sweden AB', 'B06:20', null, 'https://www.spax.com', null),
  ('nordbygg-2026-exhibitor-138265', 'nordbygg-2026', 'Specialfastigheter AB', 'AG:07', null, 'https://www.specialfastigheter.se', null),
  ('nordbygg-2026-exhibitor-139620', 'nordbygg-2026', 'Spilka Building Solutions AS', 'C12:51', null, 'https://www.spilka-sbs.com/en', 'assets/images/exhibitors/nordbygg-2026-spilka-building-solutions-as.jpg'),
  ('nordbygg-2026-exhibitor-136294', 'nordbygg-2026', 'SSAB', 'C17:33', jsonb_build_object('en', 'Great things start from within

Stål finns överallt. SSAB är en global ledare inom special- och premiumstål. Vi omdefinierar framtidens stålproduktion och leder stålindustrins gröna omställning. SSAB utmanar gränserna för innovationer med stål som har praktiskt taget noll fossila CO2-utsläpp, och hjälper till att forma en grönare värld. Upptäck en ny era av ståltillverkning.', 'sv', 'Great things start from within

Stål finns överallt. SSAB är en global ledare inom special- och premiumstål. Vi omdefinierar framtidens stålproduktion och leder stålindustrins gröna omställning. SSAB utmanar gränserna för innovationer med stål som har praktiskt taget noll fossila CO2-utsläpp, och hjälper till att forma en grönare värld. Upptäck en ny era av ståltillverkning.'), 'https://www.ssab.se', 'assets/images/exhibitors/nordbygg-2026-ssab.jpg'),
  ('nordbygg-2026-exhibitor-138872', 'nordbygg-2026', 'STACBOND', 'C15:23', null, 'https://stacbond.com', 'assets/images/exhibitors/nordbygg-2026-stacbond.jpg'),
  ('nordbygg-2026-exhibitor-139927', 'nordbygg-2026', 'Standwood OÜ', 'C03:51', jsonb_build_object('en', 'Standwoods högteknologiska fabrik för termiskt modifierat trä ligger i byn Alliku nära Tallinn, mitt i naturen, på ett område om tre hektar. Sedan 2018 har vi fokuserat på produktion av högkvalitativa träprodukter. Vi är stolta över vår hållbarhet och våra innovativa lösningar.
Standwoods fabrik producerar paneler och lavar (bänkskivor) med hjälp av naturträ, limträ och termiskt modifierade trämaterial. Tack vare vår avancerade maskinpark kan vi producera en mängd olika profiler, huvudsakligen av asp, termoasp, al och termoal.
Våra produkter är de första i Estland som behandlas i en värmebehandlingskammare baserad på vakuumteknologi. Denna innovativa teknik avlägsnar fukt, kåda och mögel från träet helt utan användning av kemikalier, vilket gör träet stabilt, hållbart och underhållsfritt. Resultatet är ett lättare trä med låg fukthalt som passar väl i olika miljöer, med en vacker struktur och smutsavvisande egenskaper.
Vår produktionsprocess är energieffektiv och miljövänlig. Speciella behandlingskammare säkerställer noggrannhet och jämn kvalitet i varje steg. Varje produkt genomgår noggrann kvalitetskontroll för att garantera konsekvent hög kvalitet.
Standwoods tillverkningsprocess kombinerar innovativ teknik, omsorg om naturen och långsiktig hållbarhet, och erbjuder högkvalitativa träprodukter som uppfyller alla dina behov inom byggnation och inredning.
Väggpanelen Respect är Standwoods senaste produkt som kombinerar naturvård, innovation och kvalitet. Den är det perfekta valet för både företag och privatkunder och erbjuder miljövänliga och funktionella lösningar.
Innovativ och hållbar lösning
• Sparar naturen: Väggpanelen Respect produceras med upp till 7 gånger mindre råmaterial, vilket minskar avverkning och följer hållbarhetsprinciper.
• Kemikaliefri och luktfri: Bearbetad med vakuumteknologi är Respect fri från kemikalier, vilket gör den till ett hälsosamt och rent val – idealiskt för allergiker och hälsomedvetna kunder.
• Perfekt för varma och fuktiga miljöer: Respect är motståndskraftig mot värme och fukt, vilket gör den idealisk för bastur, badrum och terrasser.
• Enkel att installera: Den snabba och enkla installationen gör Respect lämplig för både små företag och större projekt.
• Verkligt hållbar: Respect-produkter är slitstarka och långlivade, och klarar även de mest krävande väderförhållanden.
Respect hjälper till att bevara skogar, minska CO2-avtrycket och bidra till en mer miljövänlig framtid. Genom att välja Respect väljer du kvalitet, lång livslängd och naturvård. Standwood – en ledare inom hållbart tänkande och kvalitet i träindustrin.', 'sv', 'Standwoods högteknologiska fabrik för termiskt modifierat trä ligger i byn Alliku nära Tallinn, mitt i naturen, på ett område om tre hektar. Sedan 2018 har vi fokuserat på produktion av högkvalitativa träprodukter. Vi är stolta över vår hållbarhet och våra innovativa lösningar.
Standwoods fabrik producerar paneler och lavar (bänkskivor) med hjälp av naturträ, limträ och termiskt modifierade trämaterial. Tack vare vår avancerade maskinpark kan vi producera en mängd olika profiler, huvudsakligen av asp, termoasp, al och termoal.
Våra produkter är de första i Estland som behandlas i en värmebehandlingskammare baserad på vakuumteknologi. Denna innovativa teknik avlägsnar fukt, kåda och mögel från träet helt utan användning av kemikalier, vilket gör träet stabilt, hållbart och underhållsfritt. Resultatet är ett lättare trä med låg fukthalt som passar väl i olika miljöer, med en vacker struktur och smutsavvisande egenskaper.
Vår produktionsprocess är energieffektiv och miljövänlig. Speciella behandlingskammare säkerställer noggrannhet och jämn kvalitet i varje steg. Varje produkt genomgår noggrann kvalitetskontroll för att garantera konsekvent hög kvalitet.
Standwoods tillverkningsprocess kombinerar innovativ teknik, omsorg om naturen och långsiktig hållbarhet, och erbjuder högkvalitativa träprodukter som uppfyller alla dina behov inom byggnation och inredning.
Väggpanelen Respect är Standwoods senaste produkt som kombinerar naturvård, innovation och kvalitet. Den är det perfekta valet för både företag och privatkunder och erbjuder miljövänliga och funktionella lösningar.
Innovativ och hållbar lösning
• Sparar naturen: Väggpanelen Respect produceras med upp till 7 gånger mindre råmaterial, vilket minskar avverkning och följer hållbarhetsprinciper.
• Kemikaliefri och luktfri: Bearbetad med vakuumteknologi är Respect fri från kemikalier, vilket gör den till ett hälsosamt och rent val – idealiskt för allergiker och hälsomedvetna kunder.
• Perfekt för varma och fuktiga miljöer: Respect är motståndskraftig mot värme och fukt, vilket gör den idealisk för bastur, badrum och terrasser.
• Enkel att installera: Den snabba och enkla installationen gör Respect lämplig för både små företag och större projekt.
• Verkligt hållbar: Respect-produkter är slitstarka och långlivade, och klarar även de mest krävande väderförhållanden.
Respect hjälper till att bevara skogar, minska CO2-avtrycket och bidra till en mer miljövänlig framtid. Genom att välja Respect väljer du kvalitet, lång livslängd och naturvård. Standwood – en ledare inom hållbart tänkande och kvalitet i träindustrin.'), 'https://standwood.com/en', 'assets/images/exhibitors/nordbygg-2026-standwood-ou.jpg'),
  ('nordbygg-2026-exhibitor-138118', 'nordbygg-2026', 'Stanley', 'B02:20', jsonb_build_object('en', 'STANLEY® har satt standarden för kvalitetsverktyg och tekniska lösningar för specialister över hela världen i mer än 175 år. Med en lång erfarenhet av tillförlitlighet är STANLEY nummer ett 1 bland måttbandstillverkare i världen och fortsätter att driva branschen framåt med innovationer som produktserien STANLEY® FATMAX® samt handverktyg, batteri- och nätdrivna elverktyg, förvaring och tillbehör som får jobbet gjort.

Vi är stolta över vårt rykte om utmärkt kvalitet och arbetar ständigt med att testa, designa och förbättra våra produkter för att säkerställa kvalitet och maximal funktion. Att upprätthålla vår ställning som bäst i världen på det vi gör är mycket viktigt för oss, och för dina förväntningar på namnet STANLEY.

I mer än 175 år har våra innovativa produkter hjälpt till att bygga, reparera och skydda vår värld. Vi arbetar i dag vidare med detta arv.

DO MORE WITH STANLEY', 'sv', 'STANLEY® har satt standarden för kvalitetsverktyg och tekniska lösningar för specialister över hela världen i mer än 175 år. Med en lång erfarenhet av tillförlitlighet är STANLEY nummer ett 1 bland måttbandstillverkare i världen och fortsätter att driva branschen framåt med innovationer som produktserien STANLEY® FATMAX® samt handverktyg, batteri- och nätdrivna elverktyg, förvaring och tillbehör som får jobbet gjort.

Vi är stolta över vårt rykte om utmärkt kvalitet och arbetar ständigt med att testa, designa och förbättra våra produkter för att säkerställa kvalitet och maximal funktion. Att upprätthålla vår ställning som bäst i världen på det vi gör är mycket viktigt för oss, och för dina förväntningar på namnet STANLEY.

I mer än 175 år har våra innovativa produkter hjälpt till att bygga, reparera och skydda vår värld. Vi arbetar i dag vidare med detta arv.

DO MORE WITH STANLEY'), 'https://www.stanleyworks.se', 'assets/images/exhibitors/nordbygg-2026-stanley.jpg'),
  ('nordbygg-2026-exhibitor-137696', 'nordbygg-2026', 'Starke Arvid AB', 'B05:03', null, 'https://www.starkearvid.se', null),
  ('nordbygg-2026-exhibitor-138850', 'nordbygg-2026', 'Stegia AB', 'A22:26', null, 'https://www.stegia.se', 'assets/images/exhibitors/nordbygg-2026-stegia-ab.jpg'),
  ('nordbygg-2026-exhibitor-139179', 'nordbygg-2026', 'Steins Diamantwerkzeuge GmbH', 'B06:53', jsonb_build_object('en', 'Steins Diamantwerkzeuge GmbH – Din specialist på diamantverktyg för private label från Tyskland
Vi är baserade i Wuppertal och specialiserar oss på diamantverktyg för private label (egna märkesvaror) inom industri och byggbranschen – högpresterande produkter som säljs under ditt eget varumärke.
Våra huvudprodukter inkluderar:

•	Diamantsågar för precisionskapning
•	Diamantskålskivor för snabb slipning
•	Diamantslipskivor för slät ytbehandling
•	Diamantkärnborrar för exakt borrning

Tack vare vårt breda produktsortiment och starka samarbeten med tillverkare garanterar vi snabba leveranstider – du får rätt verktyg snabbt och pålitligt. Vi erbjuder även anpassad branding (logotyper, förpackningar, specifikationer) och skräddarsydda lösningar för unika behov.

Stick ut på marknaden med verktyg gjorda för dina kunder. Kontakta oss för att bygga din private label-framgång.', 'sv', 'Steins Diamantwerkzeuge GmbH – Din specialist på diamantverktyg för private label från Tyskland
Vi är baserade i Wuppertal och specialiserar oss på diamantverktyg för private label (egna märkesvaror) inom industri och byggbranschen – högpresterande produkter som säljs under ditt eget varumärke.
Våra huvudprodukter inkluderar:

•	Diamantsågar för precisionskapning
•	Diamantskålskivor för snabb slipning
•	Diamantslipskivor för slät ytbehandling
•	Diamantkärnborrar för exakt borrning

Tack vare vårt breda produktsortiment och starka samarbeten med tillverkare garanterar vi snabba leveranstider – du får rätt verktyg snabbt och pålitligt. Vi erbjuder även anpassad branding (logotyper, förpackningar, specifikationer) och skräddarsydda lösningar för unika behov.

Stick ut på marknaden med verktyg gjorda för dina kunder. Kontakta oss för att bygga din private label-framgång.'), 'https://www.steins-diamantwerkzeuge.de', null),
  ('nordbygg-2026-exhibitor-139390', 'nordbygg-2026', 'Stikla Serviss', 'C04:41', null, 'https://www.stikla-serviss.lv', null),
  ('nordbygg-2026-exhibitor-140016', 'nordbygg-2026', 'Stockholm Business Region AB', 'EH:07', null, 'https://www.stockholmbusinessregion.se', null),
  ('nordbygg-2026-exhibitor-137893', 'nordbygg-2026', 'Stombergs Massiva Trägolv AB', 'C07:33D', null, 'https://www.stombergs.se', 'assets/images/exhibitors/nordbygg-2026-stombergs-massiva-tragolv-ab.jpg'),
  ('nordbygg-2026-exhibitor-138859', 'nordbygg-2026', 'STRAUSS', 'B03:42', jsonb_build_object('en', 'STRAUSS – Europe’s No. 1 for professional workwear and safety footwear

Strauss is known for professional workwear – specially designed for the tough conditions of the crafts and construction sectors. With over 40,000 products available online, ranging from workwear and safety footwear to protective equipment and high-quality custom branding service, we reliably equip various industries from head to toe.

At Nordbygg, we present a product range tailored to the specific requirements of the construction and installation sectors.

www.strauss.com', 'sv', 'STRAUSS – Europe’s No. 1 for professional workwear and safety footwear

Strauss is known for professional workwear – specially designed for the tough conditions of the crafts and construction sectors. With over 40,000 products available online, ranging from workwear and safety footwear to protective equipment and high-quality custom branding service, we reliably equip various industries from head to toe.

At Nordbygg, we present a product range tailored to the specific requirements of the construction and installation sectors.

www.strauss.com'), 'https://strauss.com', 'assets/images/exhibitors/nordbygg-2026-strauss.jpg'),
  ('nordbygg-2026-exhibitor-140081', 'nordbygg-2026', 'StreamBIM', 'C01:14', jsonb_build_object('en', 'StreamBIM bygger för framtiden med TotalBIM

StreamBIM hjälper bygg- och fastighetsbranschen att arbeta datadrivet genom hela projektet. Med TotalBIM binder vi samman projektering, bygg och överlämning i en gemensam datagrund – med modellen som nav och data som grund för bättre beslut, bättre samordning och bättre överlämning.

Vår modell bygger på sex centrala delar: projektering, bygg, överlämning, Single source of truth, SecureBIM och OpenDataBIM. Tillsammans skapar de bättre kontroll på säkerhet, ägarskap, spårbarhet och informationsflöde i komplexa projekt.

Besök oss om du vill se hur en gemensam datagrund kan minska versionskaos, stärka samordningen och skapa mer värde från tidig fas till färdig överlämning.', 'sv', 'StreamBIM bygger för framtiden med TotalBIM

StreamBIM hjälper bygg- och fastighetsbranschen att arbeta datadrivet genom hela projektet. Med TotalBIM binder vi samman projektering, bygg och överlämning i en gemensam datagrund – med modellen som nav och data som grund för bättre beslut, bättre samordning och bättre överlämning.

Vår modell bygger på sex centrala delar: projektering, bygg, överlämning, Single source of truth, SecureBIM och OpenDataBIM. Tillsammans skapar de bättre kontroll på säkerhet, ägarskap, spårbarhet och informationsflöde i komplexa projekt.

Besök oss om du vill se hur en gemensam datagrund kan minska versionskaos, stärka samordningen och skapa mer värde från tidig fas till färdig överlämning.'), 'https://www.streambim.com', 'assets/images/exhibitors/nordbygg-2026-streambim.jpg'),
  ('nordbygg-2026-exhibitor-139995', 'nordbygg-2026', 'Struqtur AB', 'C02:41', jsonb_build_object('en', 'Struqtur är projektverktyget för små och snabba byggföretag som inte är intresserade av krångel och dyra lösningar.', 'sv', 'Struqtur är projektverktyget för små och snabba byggföretag som inte är intresserade av krångel och dyra lösningar.'), 'https://www.struqtur.se', 'assets/images/exhibitors/nordbygg-2026-struqtur-ab.jpg'),
  ('nordbygg-2026-exhibitor-134980', 'nordbygg-2026', 'Ställning.se', 'B06:41', jsonb_build_object('en', 'Välkommen till Ställning.se!
Det självklara valet för alla som behöver arbeta på höjd, låg som hög, utan att tumma på säkerheten.
Vare sig Ni är ute efter en fasadställning, hantverks- eller rullställning så har Ställning.se de produkter Ni behöver.

Vår affärsidé är enkel - Att sälja lättbyggda och säkra byggställningar till oslagbara priser.
Vi stävar ständigt efter att hålla korta ledtider och ett sätt är att hålla vårt 20.000 m² stora lager av ställning och ställningsdelar så välfyllt vi bara kan.

Vi ses!', 'sv', 'Välkommen till Ställning.se!
Det självklara valet för alla som behöver arbeta på höjd, låg som hög, utan att tumma på säkerheten.
Vare sig Ni är ute efter en fasadställning, hantverks- eller rullställning så har Ställning.se de produkter Ni behöver.

Vår affärsidé är enkel - Att sälja lättbyggda och säkra byggställningar till oslagbara priser.
Vi stävar ständigt efter att hålla korta ledtider och ett sätt är att hålla vårt 20.000 m² stora lager av ställning och ställningsdelar så välfyllt vi bara kan.

Vi ses!'), 'https://www.stallning.se', 'assets/images/exhibitors/nordbygg-2026-stallning-se.jpg'),
  ('nordbygg-2026-exhibitor-136644', 'nordbygg-2026', 'Ställningsdepån Sverige AB', 'B08:30', null, 'https://www.stallningsdepan.se', null),
  ('nordbygg-2026-exhibitor-134018', 'nordbygg-2026', 'Ställningsprodukter.se', 'B05:41', jsonb_build_object('en', 'Ställningsprodukter.se på NORDBYGG 2026

Ställningsprodukter.se är din kompletta leverantör av ställningar, stegar, arbetsplattformar och fallskydd för säkert arbete på hög höjd. Vi erbjuder godkända, användarvänliga och prisvärda produkter, alltid med fokus på säkerhet, kvalitet och funktion i vardagen.

På NORDBYGG 2026 satsar vi större än någonsin med vår största monter hittills. Här visar vi upp våra storsäljare, presenterar nya innovativa lösningar och bjuder på aktiviteter i montern hela dagarna. Hos oss får du se, testa och diskutera produkter tillsammans med ett kunnigt team som kan branschen på riktigt.

Vi är ett familjeägt företag med butik, lager och kontor i Göteborg, där personlig service, snabba leveranser och hög tillgänglighet är en självklar del av erbjudandet.

Välkommen till Ställningsprodukter.se – mer än bara ställning.', 'sv', 'Ställningsprodukter.se på NORDBYGG 2026

Ställningsprodukter.se är din kompletta leverantör av ställningar, stegar, arbetsplattformar och fallskydd för säkert arbete på hög höjd. Vi erbjuder godkända, användarvänliga och prisvärda produkter, alltid med fokus på säkerhet, kvalitet och funktion i vardagen.

På NORDBYGG 2026 satsar vi större än någonsin med vår största monter hittills. Här visar vi upp våra storsäljare, presenterar nya innovativa lösningar och bjuder på aktiviteter i montern hela dagarna. Hos oss får du se, testa och diskutera produkter tillsammans med ett kunnigt team som kan branschen på riktigt.

Vi är ett familjeägt företag med butik, lager och kontor i Göteborg, där personlig service, snabba leveranser och hög tillgänglighet är en självklar del av erbjudandet.

Välkommen till Ställningsprodukter.se – mer än bara ställning.'), 'https://Stallningsprodukter.se', 'assets/images/exhibitors/nordbygg-2026-stallningsprodukter-se.jpg'),
  ('nordbygg-2026-exhibitor-138267', 'nordbygg-2026', 'SUN WINNER GROUP', 'C15:21', null, 'https://www.sunwinner.pl', null),
  ('nordbygg-2026-exhibitor-135705', 'nordbygg-2026', 'Sundström Safety AB', 'B03:31', null, 'https://www.srsafety.com', 'assets/images/exhibitors/nordbygg-2026-sundstrom-safety-ab.jpg'),
  ('nordbygg-2026-exhibitor-137913', 'nordbygg-2026', 'SunStop Solskydd', 'C14:22', jsonb_build_object('en', 'Smart solskydd för fastigheter!

Genom en ärlig, faktabaserad och kompetent rådgivning levererar vi på SunStop alltid rätt solskydd till fastigheten.
Vi analyserar och ställer rätt frågor för att hitta den optimala lösningen.', 'sv', 'Smart solskydd för fastigheter!

Genom en ärlig, faktabaserad och kompetent rådgivning levererar vi på SunStop alltid rätt solskydd till fastigheten.
Vi analyserar och ställer rätt frågor för att hitta den optimala lösningen.'), 'https://www.sunstop.se', 'assets/images/exhibitors/nordbygg-2026-sunstop-solskydd.jpg'),
  ('nordbygg-2026-exhibitor-134013', 'nordbygg-2026', 'Svalson AB', 'C10:33', jsonb_build_object('en', 'Skräddarsydda glaslösningar för alla miljöer.

Under drygt 40 år har Svalson erbjudit kreativa och specialanpassade glas- och säkerhetslösningar – som balkongsystem, höj- och sänkbara glasräcken, eldrivna fönster eller skottsäkra receptionsluckor.

På Nordbygg, norra Europas största mötesplats för bygg- och fastighetsbranschen, presenterar vi ett urval av våra produkter, bland annat:

Svalson AB
•	Höj- och sänkbart glasräcke - manuellt och eldrivet utförande
•	Eldrivet vertikalgående fönster för bostäder, kontor och liknande

Svalson Safety AB
•	Skottsäker eldriven skjutlucka för optimalt skydd mot skjutvapen
•	Brandklassad eldriven skjutlucka
•	Skottsäkra skjutlådor och intercomsystem', 'sv', 'Skräddarsydda glaslösningar för alla miljöer.

Under drygt 40 år har Svalson erbjudit kreativa och specialanpassade glas- och säkerhetslösningar – som balkongsystem, höj- och sänkbara glasräcken, eldrivna fönster eller skottsäkra receptionsluckor.

På Nordbygg, norra Europas största mötesplats för bygg- och fastighetsbranschen, presenterar vi ett urval av våra produkter, bland annat:

Svalson AB
•	Höj- och sänkbart glasräcke - manuellt och eldrivet utförande
•	Eldrivet vertikalgående fönster för bostäder, kontor och liknande

Svalson Safety AB
•	Skottsäker eldriven skjutlucka för optimalt skydd mot skjutvapen
•	Brandklassad eldriven skjutlucka
•	Skottsäkra skjutlådor och intercomsystem'), 'https://www.svalson.com', 'assets/images/exhibitors/nordbygg-2026-svalson-ab.jpg'),
  ('nordbygg-2026-exhibitor-138432', 'nordbygg-2026', 'Svanen, Miljömärkning Sverige AB', 'C09:11', null, 'https://www.svanen.se', 'assets/images/exhibitors/nordbygg-2026-svanen-miljomarkning-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-134583', 'nordbygg-2026', 'Svedbergs i Dalstorp AB', 'A10:14', jsonb_build_object('en', 'Våra tidlösa och personligt anpassade badrumsinredningar tillverkas i vår egen fabrik i Dalstorp. Där har vi odlat vårt design- och hantverkskunnande så att vi tillsammans med dig kan forma rummet som ger dig energi och formar din dag. Från morgon till kväll, idag och imorgon.', 'sv', 'Våra tidlösa och personligt anpassade badrumsinredningar tillverkas i vår egen fabrik i Dalstorp. Där har vi odlat vårt design- och hantverkskunnande så att vi tillsammans med dig kan forma rummet som ger dig energi och formar din dag. Från morgon till kväll, idag och imorgon.'), 'https://www.svedbergs.se', 'assets/images/exhibitors/nordbygg-2026-svedbergs-i-dalstorp-ab.jpg'),
  ('nordbygg-2026-exhibitor-135299', 'nordbygg-2026', 'Svensk Byggplåt', 'C17:51', jsonb_build_object('en', 'Svensk Byggplåt är en branschorganisation för tak- och fasadplåt. Vi arbetar för att fler ska upptäcka byggplåtens möjligheter och fördelar.

Vi representeras av i stort sett alla Sveriges ledande leverantörer inom byggplåt samt Plåt & Ventföretagen, bransch- och arbetsgivarorganisation för företag inom byggplåt och ventilation.

Våra medlemmar är:
ArcelorMittal, Areco, Bevego, Dala-Profil, Lindab, Plannja, Plåt & Ventföretagen, Prefa, Rheinzink, Ruukki, SSAB, VM Building Solutions.', 'sv', 'Svensk Byggplåt är en branschorganisation för tak- och fasadplåt. Vi arbetar för att fler ska upptäcka byggplåtens möjligheter och fördelar.

Vi representeras av i stort sett alla Sveriges ledande leverantörer inom byggplåt samt Plåt & Ventföretagen, bransch- och arbetsgivarorganisation för företag inom byggplåt och ventilation.

Våra medlemmar är:
ArcelorMittal, Areco, Bevego, Dala-Profil, Lindab, Plannja, Plåt & Ventföretagen, Prefa, Rheinzink, Ruukki, SSAB, VM Building Solutions.'), 'https://www.svenskbyggplat.se', 'assets/images/exhibitors/nordbygg-2026-svensk-byggplat.jpg'),
  ('nordbygg-2026-exhibitor-136831', 'nordbygg-2026', 'Svensk Dataförvaltning AB', 'A16:23', jsonb_build_object('en', 'Svensk Dataförvaltning (SDF) utvecklar program för service- och installationsbranschen. Programmen underlättar hantering och planering av arbetsorder, projekt och dokumentation

SDF ger dig det perfekta stödet i varje del av hanteringen av dina arbetsordrar. Enkelt, tryggt och digitalt

De flesta tekniker är utpräglade problemlösare. Men det finns många problem som de flesta helst av allt skulle vilja slippa. Offerter som ska skrivas, tid som ska rapporteras och fakturor som ska upprättas.

Våra verktyg hjälper dig att lösa allt detta. Och det var faktiskt därför som vi startade SDF. För att hjälpa dig att lösa rätt problem – så att du kan gå till jobbet med lättare steg.', 'sv', 'Svensk Dataförvaltning (SDF) utvecklar program för service- och installationsbranschen. Programmen underlättar hantering och planering av arbetsorder, projekt och dokumentation

SDF ger dig det perfekta stödet i varje del av hanteringen av dina arbetsordrar. Enkelt, tryggt och digitalt

De flesta tekniker är utpräglade problemlösare. Men det finns många problem som de flesta helst av allt skulle vilja slippa. Offerter som ska skrivas, tid som ska rapporteras och fakturor som ska upprättas.

Våra verktyg hjälper dig att lösa allt detta. Och det var faktiskt därför som vi startade SDF. För att hjälpa dig att lösa rätt problem – så att du kan gå till jobbet med lättare steg.'), 'https://www.sdfab.se', 'assets/images/exhibitors/nordbygg-2026-svensk-dataforvaltning-ab.jpg'),
  ('nordbygg-2026-exhibitor-138805', 'nordbygg-2026', 'Svensk Ventilation', 'A18:15', null, 'https://www.svenskventilation.se', null),
  ('nordbygg-2026-exhibitor-139042', 'nordbygg-2026', 'Svenska Kakel AB', 'A01:205', null, 'https://www.svenskakakel.se', 'assets/images/exhibitors/nordbygg-2026-svenska-kakel-ab.jpg'),
  ('nordbygg-2026-exhibitor-136817', 'nordbygg-2026', 'Svenskt Trä', 'C14:31', jsonb_build_object('en', 'Svenskt Trä sprider kunskap om trä, träprodukter och träbyggande för att främja ett hållbart samhälle och en livskraftig sågverksnäring.

I år delar vi utställningsytan med Setra Trävaror AB, Moelven Limtre AB, Holmen Wood Products AB/Martinsons Byggsystem AB, Norra Timber och Svenska Träskyddsföreningen.

Tillsammans visar vi ett urval som spänner från material till systemlösningar: trall, CMP-paneler, limträ- och KL-trä¬konstruktioner, en husmodell, en bromodell samt flera av Svenskt Träs efterfrågade publikationer. Precis intill finns även Woodlife utställningen som lyfter fram byggprojekt där många av våra medlemsföretag medverkat – en bra plats för att diskutera val av material, detaljlösningar och gestaltning.

I montern skapar vi möten och praktiska upplevelser: en kaffestation för snabba samtal, en skogshörna där våra skogsexperter svarar på frågor om allt från brukningsmetoder till biologisk mångfald, en boulebana med träklot, ”gissa träslaget” samt en dedikerad exponeringsyta per företag med modeller och exempel. Välkommen till monter C14:31.', 'sv', 'Svenskt Trä sprider kunskap om trä, träprodukter och träbyggande för att främja ett hållbart samhälle och en livskraftig sågverksnäring.

I år delar vi utställningsytan med Setra Trävaror AB, Moelven Limtre AB, Holmen Wood Products AB/Martinsons Byggsystem AB, Norra Timber och Svenska Träskyddsföreningen.

Tillsammans visar vi ett urval som spänner från material till systemlösningar: trall, CMP-paneler, limträ- och KL-trä¬konstruktioner, en husmodell, en bromodell samt flera av Svenskt Träs efterfrågade publikationer. Precis intill finns även Woodlife utställningen som lyfter fram byggprojekt där många av våra medlemsföretag medverkat – en bra plats för att diskutera val av material, detaljlösningar och gestaltning.

I montern skapar vi möten och praktiska upplevelser: en kaffestation för snabba samtal, en skogshörna där våra skogsexperter svarar på frågor om allt från brukningsmetoder till biologisk mångfald, en boulebana med träklot, ”gissa träslaget” samt en dedikerad exponeringsyta per företag med modeller och exempel. Välkommen till monter C14:31.'), 'https://arbio.se/om-arbio', 'assets/images/exhibitors/nordbygg-2026-svenskt-tra.jpg'),
  ('nordbygg-2026-exhibitor-138259', 'nordbygg-2026', 'Svenssons i Tenhult AB', 'C11:41B', jsonb_build_object('en', 'Svenssons i Tenhult grundades 1931 och vi är experter på lås och beslag. Förutom lås och beslag till dörrar och fönster erbjuder vi även ett stort sortiment av inredningsbeslag, möbellås, fästmaterial och andra tillbehör.

Sedan 2021 tillhör vi den internationella industrikoncernen Indutrade. Våra säljkontor finns i Tenhult (Småland) och Knislinge (Skåne), lagerplats i Tenhult.

Vi väljer våra varumärken med omsorg och är noga med att du får den kvalité och funktion som du önskar. Kunskap, service och engagemang är vår styrka och för oss är det viktigt att du som kund känner dig trygg i ditt val av beslagsleverantör!

Läs gärna mer om oss på vår hemsida: svenssonsbeslag.se', 'sv', 'Svenssons i Tenhult grundades 1931 och vi är experter på lås och beslag. Förutom lås och beslag till dörrar och fönster erbjuder vi även ett stort sortiment av inredningsbeslag, möbellås, fästmaterial och andra tillbehör.

Sedan 2021 tillhör vi den internationella industrikoncernen Indutrade. Våra säljkontor finns i Tenhult (Småland) och Knislinge (Skåne), lagerplats i Tenhult.

Vi väljer våra varumärken med omsorg och är noga med att du får den kvalité och funktion som du önskar. Kunskap, service och engagemang är vår styrka och för oss är det viktigt att du som kund känner dig trygg i ditt val av beslagsleverantör!

Läs gärna mer om oss på vår hemsida: svenssonsbeslag.se'), 'https://www.svenssonsitenhult.se', 'assets/images/exhibitors/nordbygg-2026-svenssons-i-tenhult-ab.jpg'),
  ('nordbygg-2026-exhibitor-137954', 'nordbygg-2026', 'Sveriges Bad & Värmebutiker AB', 'A06:19', jsonb_build_object('en', 'Bad & Värme är en av Sveriges ledande VVS-kedjor med över 140 lokala medlemsföretag och mer än 1 100 certifierade installatörer runt om i landet. Tillsammans erbjuder vi trygga, hållbara och professionella lösningar inom badrum, värme och VVS – alltid med kunden i fokus.

Vår styrka ligger i kombinationen av lokalt hantverk och gemensam kraft. Varje Bad & Värme-företag är lokalt förankrat, samtidigt som de ingår i en rikstäckande kedja med gemensamma arbetssätt, kvalitetssäkring och starka leverantörssamarbeten.

Ett av våra viktigaste erbjudanden är konceptet Installerat & Klart – en helhetslösning där kunden får en trygg affär från första rådgivning till färdig installation, utförd av behöriga och certifierade installatörer.', 'sv', 'Bad & Värme är en av Sveriges ledande VVS-kedjor med över 140 lokala medlemsföretag och mer än 1 100 certifierade installatörer runt om i landet. Tillsammans erbjuder vi trygga, hållbara och professionella lösningar inom badrum, värme och VVS – alltid med kunden i fokus.

Vår styrka ligger i kombinationen av lokalt hantverk och gemensam kraft. Varje Bad & Värme-företag är lokalt förankrat, samtidigt som de ingår i en rikstäckande kedja med gemensamma arbetssätt, kvalitetssäkring och starka leverantörssamarbeten.

Ett av våra viktigaste erbjudanden är konceptet Installerat & Klart – en helhetslösning där kunden får en trygg affär från första rådgivning till färdig installation, utförd av behöriga och certifierade installatörer.'), 'https://www.bad-varme.se', 'assets/images/exhibitors/nordbygg-2026-sveriges-bad-varmebutiker-ab.jpg'),
  ('nordbygg-2026-exhibitor-136641', 'nordbygg-2026', 'Sveriges Stenindustri förbund', 'C04:61', jsonb_build_object('en', 'Sveriges Stenindustriförbund, STEN, är stenindustrins branschorganisation. Medlemmarna är företag i alla led, från brytning till tillverkning, försäljning och montering av naturstensprodukter. Även konsulter och leverantörer kan vara medlemmar. Den gemensamma nämnaren är materialet natursten.', 'sv', 'Sveriges Stenindustriförbund, STEN, är stenindustrins branschorganisation. Medlemmarna är företag i alla led, från brytning till tillverkning, försäljning och montering av naturstensprodukter. Även konsulter och leverantörer kan vara medlemmar. Den gemensamma nämnaren är materialet natursten.'), 'https://www.sten.se', 'assets/images/exhibitors/nordbygg-2026-sveriges-stenindustri-forbund.jpg'),
  ('nordbygg-2026-exhibitor-139604', 'nordbygg-2026', 'Sweco', 'EH:65', jsonb_build_object('en', 'Sweco Environment & Planning – Livscykelperspektiv för hållbar samhällsutveckling

Inom Swecos division Environment & Planning arbetar vi med att skapa hållbara lösningar för samhällen, städer och infrastruktur – alltid med ett helhetsperspektiv på miljö, klimat och resurser. Swecos ambition är att vara en partner genom projekt där vi arbetar tillsammans för att nå uppsatta mål.

En central del av vårt arbete är livscykelanalys (LCA). Genom att analysera miljöpåverkan från råvara till färdig produkt – och vidare till drift, underhåll och avveckling – hjälper vi våra kunder att fatta välgrundade, datadrivna beslut som leder till en hållbar utveckling.

Swecos erbjudande inom LCA inkluderar bland annat:
•	Framtagande av miljövarudeklarationer (EPD:er): Sweco har omfattande erfarenhet av att ta fram EPD:er inom en rad olika produktkategorier som exempelvis byggmaterial och installationsprodukter
•	LCA för produkter: Vi har omfattande erfarenhet av LCA enligt ISO 14040/44 och ISO 14067
•	Rådgivning för att minska klimatpåverkan baserat på LCA och kommunikation av resultat
•	Kritisk granskning av LCA enligt ISO 14040/44
•	Tredjepartsverifiering inom EPD International
•	Klimat- och miljöbedömningar: vi anpassar lösningar efter kundens behov, exempelvis genom skräddarsydda klimatberäkningsverktyg i Excel eller webbaserade gränssnitt enligt kundens önskemål
•	Rådgivning kring aktuella och kommande kravställningar på marknaden
•	Framtagande av underlag för beslut

Tillsammans gör vi hållbarhet mätbar, jämförbar och genomförbar.', 'sv', 'Sweco Environment & Planning – Livscykelperspektiv för hållbar samhällsutveckling

Inom Swecos division Environment & Planning arbetar vi med att skapa hållbara lösningar för samhällen, städer och infrastruktur – alltid med ett helhetsperspektiv på miljö, klimat och resurser. Swecos ambition är att vara en partner genom projekt där vi arbetar tillsammans för att nå uppsatta mål.

En central del av vårt arbete är livscykelanalys (LCA). Genom att analysera miljöpåverkan från råvara till färdig produkt – och vidare till drift, underhåll och avveckling – hjälper vi våra kunder att fatta välgrundade, datadrivna beslut som leder till en hållbar utveckling.

Swecos erbjudande inom LCA inkluderar bland annat:
•	Framtagande av miljövarudeklarationer (EPD:er): Sweco har omfattande erfarenhet av att ta fram EPD:er inom en rad olika produktkategorier som exempelvis byggmaterial och installationsprodukter
•	LCA för produkter: Vi har omfattande erfarenhet av LCA enligt ISO 14040/44 och ISO 14067
•	Rådgivning för att minska klimatpåverkan baserat på LCA och kommunikation av resultat
•	Kritisk granskning av LCA enligt ISO 14040/44
•	Tredjepartsverifiering inom EPD International
•	Klimat- och miljöbedömningar: vi anpassar lösningar efter kundens behov, exempelvis genom skräddarsydda klimatberäkningsverktyg i Excel eller webbaserade gränssnitt enligt kundens önskemål
•	Rådgivning kring aktuella och kommande kravställningar på marknaden
•	Framtagande av underlag för beslut

Tillsammans gör vi hållbarhet mätbar, jämförbar och genomförbar.'), 'https://www.sweco.se', 'assets/images/exhibitors/nordbygg-2026-sweco.jpg'),
  ('nordbygg-2026-exhibitor-138803', 'nordbygg-2026', 'SweDendro AB', 'B07:51', jsonb_build_object('en', 'Snickerimaskiner i alla tänkbara modeller och utföranden, handmaskiner, skärande verktyg och maskintillbehör, handverktyg av hög kvalitet och enkla spånsugar samt mer kvalificerade system för spånhantering till såväl snickerier, som byggfirmor, institutioner, skolor och hobbysnickare.
I vår utställning i Växjö, webshop samt hemsida visar vi ett urval av våra leverantörers produkter.
Nu med över 25 års positiv utveckling ser vi med tillförsikt på framtiden.', 'sv', 'Snickerimaskiner i alla tänkbara modeller och utföranden, handmaskiner, skärande verktyg och maskintillbehör, handverktyg av hög kvalitet och enkla spånsugar samt mer kvalificerade system för spånhantering till såväl snickerier, som byggfirmor, institutioner, skolor och hobbysnickare.
I vår utställning i Växjö, webshop samt hemsida visar vi ett urval av våra leverantörers produkter.
Nu med över 25 års positiv utveckling ser vi med tillförsikt på framtiden.'), 'https://www.swedendro.se', null),
  ('nordbygg-2026-exhibitor-137856', 'nordbygg-2026', 'Swedol AB', 'B01:50 (+1)', jsonb_build_object('en', 'Swedol erbjuder produkter, tjänster och utbildningar som vilar på hög kunskapsnivå, djup branschkännedom och stor förståelse för Nordens yrkesfolk.

Vi fokuserar på att vara en engagerande partner till företag inom industri och verkstad, bygg och anläggning, offentlig verksamhet, åkeri- och transport samt jord- och skogsbruk.', 'sv', 'Swedol erbjuder produkter, tjänster och utbildningar som vilar på hög kunskapsnivå, djup branschkännedom och stor förståelse för Nordens yrkesfolk.

Vi fokuserar på att vara en engagerande partner till företag inom industri och verkstad, bygg och anläggning, offentlig verksamhet, åkeri- och transport samt jord- och skogsbruk.'), 'https://www.swedol.se', 'assets/images/exhibitors/nordbygg-2026-swedol-ab.jpg'),
  ('nordbygg-2026-exhibitor-140070', 'nordbygg-2026', 'Sweftico', 'AG:95', jsonb_build_object('en', 'Sweftico är en digital plattform för bygg- och fastighetsbranschen där företag, yrkespersoner, leverantörer och organisationer kan hitta varandra, visa kompetens och skapa nya affärsmöjligheter.

Plattformen gör det enkelt att hitta rätt företag, leverantörer, resurser och samarbetspartners genom smart filtrering och tydlig information om tillgänglighet.

Sweftico är utvecklad utifrån verkliga behov i branschen med fokus på effektivitet, transparens och bättre samarbete.', 'sv', 'Sweftico är en digital plattform för bygg- och fastighetsbranschen där företag, yrkespersoner, leverantörer och organisationer kan hitta varandra, visa kompetens och skapa nya affärsmöjligheter.

Plattformen gör det enkelt att hitta rätt företag, leverantörer, resurser och samarbetspartners genom smart filtrering och tydlig information om tillgänglighet.

Sweftico är utvecklad utifrån verkliga behov i branschen med fokus på effektivitet, transparens och bättre samarbete.'), 'https://Sweftico.se', 'assets/images/exhibitors/nordbygg-2026-sweftico.jpg'),
  ('nordbygg-2026-exhibitor-134009', 'nordbygg-2026', 'Swema AB', 'A13:11', null, 'https://www.swema.se', null),
  ('nordbygg-2026-exhibitor-137876', 'nordbygg-2026', 'SWEP', 'A12:04', jsonb_build_object('en', 'SWEP ensures efficient heat transfer where less means more. Since 1983, millions of our innovative brazed plate heat exchangers have been integrated into HVACR and industrial applications worldwide, enhancing the quality of life for billions of people. Our expertise in sustainable energy use has grown SWEP into a global company with more than 1,100 employees, five production sites, and a presence in 50 countries. As part of Dover Corporation, we help redefine what is possible within the Climate & Sustainability Technologies segment. Make a difference. Visit swepgroup.com.', 'sv', 'SWEP ensures efficient heat transfer where less means more. Since 1983, millions of our innovative brazed plate heat exchangers have been integrated into HVACR and industrial applications worldwide, enhancing the quality of life for billions of people. Our expertise in sustainable energy use has grown SWEP into a global company with more than 1,100 employees, five production sites, and a presence in 50 countries. As part of Dover Corporation, we help redefine what is possible within the Climate & Sustainability Technologies segment. Make a difference. Visit swepgroup.com.'), 'https://www.swepgroup.com', 'assets/images/exhibitors/nordbygg-2026-swep.jpg'),
  ('nordbygg-2026-exhibitor-138586', 'nordbygg-2026', 'SWISS KRONO', 'C14:51', jsonb_build_object('en', 'SWISS KRONO is one of the world’s leading manufacturers of wood-based materials. Our diverse portfolio includes solutions in the areas of Interiors, Flooring, and Building Materials.

As a family-owned company, we have stood for high quality and outstanding price-performance ratio for more than 50 years. We set benchmarks in design, comfort, and durability – creating living spaces for our customers in over 120 countries worldwide.

We ensure that our wood-based products are available anytime, anywhere, and in premium quality. This is made possible by around 5,000 dedicated employees at twelve locations worldwide.', 'sv', 'SWISS KRONO is one of the world’s leading manufacturers of wood-based materials. Our diverse portfolio includes solutions in the areas of Interiors, Flooring, and Building Materials.

As a family-owned company, we have stood for high quality and outstanding price-performance ratio for more than 50 years. We set benchmarks in design, comfort, and durability – creating living spaces for our customers in over 120 countries worldwide.

We ensure that our wood-based products are available anytime, anywhere, and in premium quality. This is made possible by around 5,000 dedicated employees at twelve locations worldwide.'), 'https://swisskrono.com', 'assets/images/exhibitors/nordbygg-2026-swiss-krono.jpg'),
  ('nordbygg-2026-exhibitor-134788', 'nordbygg-2026', 'Swisspearl', 'C04:21', jsonb_build_object('en', 'Swisspearl är en av Europas ledande tillverkare av byggmaterial i fibercement.
Sortimentet omfattar bygg- och konstruktionsskivor samt fasadlösningar som används inom både nybyggnation och renovering.
Produkterna erbjuder pålitliga och välutvecklade lösningar för tak, fasader och interiörer.

Utöver fibercementprodukterna erbjuder Swisspearl även byggnadsintegrerade solceller (BIPV) – en lösning som kombinerar design och energiproduktion.
Solcellerna kan integreras direkt i tak och fasader och finns, för fasad, i flera färger utöver svart. Det ger möjlighet att förena teknik och arkitektur med ett enhetligt uttryck.

Swisspearl arbetar för en mer hållbar byggbransch och stödjer sina kunder med produkter, lösningar och expertis utvecklade av ett internationellt team på cirka 2 400 medarbetare i över 20 länder.

Swisspearls svenska försäljningskontor är beläget i Stockholm, medan koncernens huvudkontor ligger i Niederurnen i Schweiz. Swisspearl har dessutom nio produktionsanläggningar i Europa.

Produkterna finns tillgängliga via landets ledande återförsäljare för byggproffs.

För mer information, besök www.swisspearl.com', 'sv', 'Swisspearl är en av Europas ledande tillverkare av byggmaterial i fibercement.
Sortimentet omfattar bygg- och konstruktionsskivor samt fasadlösningar som används inom både nybyggnation och renovering.
Produkterna erbjuder pålitliga och välutvecklade lösningar för tak, fasader och interiörer.

Utöver fibercementprodukterna erbjuder Swisspearl även byggnadsintegrerade solceller (BIPV) – en lösning som kombinerar design och energiproduktion.
Solcellerna kan integreras direkt i tak och fasader och finns, för fasad, i flera färger utöver svart. Det ger möjlighet att förena teknik och arkitektur med ett enhetligt uttryck.

Swisspearl arbetar för en mer hållbar byggbransch och stödjer sina kunder med produkter, lösningar och expertis utvecklade av ett internationellt team på cirka 2 400 medarbetare i över 20 länder.

Swisspearls svenska försäljningskontor är beläget i Stockholm, medan koncernens huvudkontor ligger i Niederurnen i Schweiz. Swisspearl har dessutom nio produktionsanläggningar i Europa.

Produkterna finns tillgängliga via landets ledande återförsäljare för byggproffs.

För mer information, besök www.swisspearl.com'), 'https://www.swisspearl.com', 'assets/images/exhibitors/nordbygg-2026-swisspearl.jpg'),
  ('nordbygg-2026-exhibitor-137945', 'nordbygg-2026', 'Swoosh Group AB', 'A20:29', jsonb_build_object('en', 'Swoosh är en rikstäckande partner inom underhåll av fastigheters infrastruktur. Vi arbetar med tjänster som relining, stamspolning, högtrycksspolning, vacuumsugning och rörinspektion. Nu lyfter vi särskilt fram Kanaltätning som ett växande område där vi tillsammans med Linervent erbjuder lösningar för att täta ventilationskanaler miljövänligt, smidigt och kostnadseffektivt.

Genom modern teknik och egen personal kan vi förbättra inneklimat, energieffektivitet och driftsäkerhet i både nya och äldre byggnader.

Vi finns nära våra kunder genom lokala filialer i hela Sverige. Målet är alltid samma. trygg drift. hållbara lösningar. och minimal påverkan på verksamheten.

Besök oss gärna så berättar vi mer om hur Kanaltätning kan ge både energibesparingar och bättre luftkvalitet.', 'sv', 'Swoosh är en rikstäckande partner inom underhåll av fastigheters infrastruktur. Vi arbetar med tjänster som relining, stamspolning, högtrycksspolning, vacuumsugning och rörinspektion. Nu lyfter vi särskilt fram Kanaltätning som ett växande område där vi tillsammans med Linervent erbjuder lösningar för att täta ventilationskanaler miljövänligt, smidigt och kostnadseffektivt.

Genom modern teknik och egen personal kan vi förbättra inneklimat, energieffektivitet och driftsäkerhet i både nya och äldre byggnader.

Vi finns nära våra kunder genom lokala filialer i hela Sverige. Målet är alltid samma. trygg drift. hållbara lösningar. och minimal påverkan på verksamheten.

Besök oss gärna så berättar vi mer om hur Kanaltätning kan ge både energibesparingar och bättre luftkvalitet.'), 'https://www.swooshsverige.se', 'assets/images/exhibitors/nordbygg-2026-swoosh-group-ab.jpg'),
  ('nordbygg-2026-exhibitor-139525', 'nordbygg-2026', 'Synoptik Sweden AB', 'BG:16', jsonb_build_object('en', 'Synoptik – framtidens arbetsverktyg är här

Vi på Synoptik är en av Nordens ledande optikkedjor och en del av EssilorLuxottica – världsledande inom glasögon och innovation.

På den här mässan presenterar vi nästa steg inom optik:
Framtidens arbetsverktyg – smarta glasögon

Med smarta glasögon kan du arbeta effektivare, säkrare och helt handsfree:

Kommunicera utan att ta upp telefonen – ring och ta emot samtal direkt
Visa vad du ser i realtid via livevideo och få support direkt på plats
Dokumentera arbetet enkelt med foto och video
Gör anteckningar med rösten och dela information direkt

Ett nytt sätt att arbeta smartare inom bygg, installation och service.
Besök oss på Nordbygg – monter BG:16', 'sv', 'Synoptik – framtidens arbetsverktyg är här

Vi på Synoptik är en av Nordens ledande optikkedjor och en del av EssilorLuxottica – världsledande inom glasögon och innovation.

På den här mässan presenterar vi nästa steg inom optik:
Framtidens arbetsverktyg – smarta glasögon

Med smarta glasögon kan du arbeta effektivare, säkrare och helt handsfree:

Kommunicera utan att ta upp telefonen – ring och ta emot samtal direkt
Visa vad du ser i realtid via livevideo och få support direkt på plats
Dokumentera arbetet enkelt med foto och video
Gör anteckningar med rösten och dela information direkt

Ett nytt sätt att arbeta smartare inom bygg, installation och service.
Besök oss på Nordbygg – monter BG:16'), 'https://www.synoptik.se', 'assets/images/exhibitors/nordbygg-2026-synoptik-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-137127', 'nordbygg-2026', 'System Edström Bilinredningar AB', 'AG:117', jsonb_build_object('en', 'På System Edström strävar vi alltid efter att skapa mobila arbetsplatser utifrån dina behov. Vi är marknadsledande inom bilinredning och har över 65 års erfarenhet i branschen. Idag finns vi i 20 länder och över 500 000 hantverkare litar på bilinredning från oss.

Vi är specialiserade på skräddarsydda lösningar för alla märken och modeller. Oavsett vilken skåpbil du kör hjälper våra bilinredningssystem dig att få ut det mesta av din arbetsbil. Säkerhet och hållbarhet är centralt i vårt arbete. Vi utvecklar ständigt våra produkter för att möta framtidens krav genom nya och innovativa lösningar.

Under mässdagarna har du möjlighet att träffa våra säljare som gärna berättar mer om våra produkter och hur vi arbetar. Vi ser fram emot att träffa dig!', 'sv', 'På System Edström strävar vi alltid efter att skapa mobila arbetsplatser utifrån dina behov. Vi är marknadsledande inom bilinredning och har över 65 års erfarenhet i branschen. Idag finns vi i 20 länder och över 500 000 hantverkare litar på bilinredning från oss.

Vi är specialiserade på skräddarsydda lösningar för alla märken och modeller. Oavsett vilken skåpbil du kör hjälper våra bilinredningssystem dig att få ut det mesta av din arbetsbil. Säkerhet och hållbarhet är centralt i vårt arbete. Vi utvecklar ständigt våra produkter för att möta framtidens krav genom nya och innovativa lösningar.

Under mässdagarna har du möjlighet att träffa våra säljare som gärna berättar mer om våra produkter och hur vi arbetar. Vi ser fram emot att träffa dig!'), 'https://www.edstrom.se', 'assets/images/exhibitors/nordbygg-2026-system-edstrom-bilinredningar-ab.jpg'),
  ('nordbygg-2026-exhibitor-135452', 'nordbygg-2026', 'Systemair Sverige AB', 'A16:14', jsonb_build_object('en', 'Systemair är ett världsledande ventilationsföretag som tillverkar och marknadsför energieffektiva och hållbara produkter som bidrar till att förbättra inomhusklimatet och minska koldioxidutsläppen.', 'sv', 'Systemair är ett världsledande ventilationsföretag som tillverkar och marknadsför energieffektiva och hållbara produkter som bidrar till att förbättra inomhusklimatet och minska koldioxidutsläppen.'), 'https://www.systemair.se', 'assets/images/exhibitors/nordbygg-2026-systemair-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-139759', 'nordbygg-2026', 'Säker Bostad AB', 'C15:20', jsonb_build_object('en', 'Vi på Säker Bostad är stolta över att erbjuda innovativa lösningar inom säkerhetsdörrar, branddörrar och ståldörrar. Med fokus på kvalitet och säkerhet strävar vi efter att skydda både människor och egendom. Våra produkter är designade för att möta de högsta standarderna och vi arbetar ständigt med att utveckla våra lösningar för att säkerställa trygghet och hållbarhet.Besök oss gärna för att lära dig mer om hur vi kan hjälpa till att skapa en säkrare miljö!', 'sv', 'Vi på Säker Bostad är stolta över att erbjuda innovativa lösningar inom säkerhetsdörrar, branddörrar och ståldörrar. Med fokus på kvalitet och säkerhet strävar vi efter att skydda både människor och egendom. Våra produkter är designade för att möta de högsta standarderna och vi arbetar ständigt med att utveckla våra lösningar för att säkerställa trygghet och hållbarhet.Besök oss gärna för att lära dig mer om hur vi kan hjälpa till att skapa en säkrare miljö!'), 'https://www.sakerbostad.se', 'assets/images/exhibitors/nordbygg-2026-saker-bostad-ab.jpg'),
  ('nordbygg-2026-exhibitor-138507', 'nordbygg-2026', 'Säker Vatten AB', 'AG:11', jsonb_build_object('en', 'Säker Vatten är en medlemsägd branschorganisation?som har till uppgift att skapa ekonomiskt, miljömässigt och socialt hållbara VVS-installationer. Det gör vi genom att utbilda, auktorisera och kontrollera företag i VVS-branschen. Att utföra installationer enligt branschregler Säker Vatteninstallation är idag likställt med fackmässigt utförande.
Säker Vatten startades 2005. Den 1 sep 2005 lanserades den första upplagan av Branschregler Säker Vatteninstallation? som är ett regelverk framtaget av branschens aktörer för att minska risken för vattenskador, brännskador, förgiftning och mikrobiell tillväxt, framför allt legionella.  Målet är att ge en ökad säkerhet och trygghet för kunden. Branschreglerna ställer krav på det tekniska utförandet av installationerna, produkterna som ska användas samt på kunskap hos de personer och företag som utför arbetet.
Branschreglerna uppdateras var femte år.
Idag finns det cirka 2200 auktoriserade VVS-företag med utbildade VVS-montörer.', 'sv', 'Säker Vatten är en medlemsägd branschorganisation?som har till uppgift att skapa ekonomiskt, miljömässigt och socialt hållbara VVS-installationer. Det gör vi genom att utbilda, auktorisera och kontrollera företag i VVS-branschen. Att utföra installationer enligt branschregler Säker Vatteninstallation är idag likställt med fackmässigt utförande.
Säker Vatten startades 2005. Den 1 sep 2005 lanserades den första upplagan av Branschregler Säker Vatteninstallation? som är ett regelverk framtaget av branschens aktörer för att minska risken för vattenskador, brännskador, förgiftning och mikrobiell tillväxt, framför allt legionella.  Målet är att ge en ökad säkerhet och trygghet för kunden. Branschreglerna ställer krav på det tekniska utförandet av installationerna, produkterna som ska användas samt på kunskap hos de personer och företag som utför arbetet.
Branschreglerna uppdateras var femte år.
Idag finns det cirka 2200 auktoriserade VVS-företag med utbildade VVS-montörer.'), 'https://www.sakervatten.se', 'assets/images/exhibitors/nordbygg-2026-saker-vatten-ab.jpg'),
  ('nordbygg-2026-exhibitor-139220', 'nordbygg-2026', 'Söderberg & Partners', 'A06:10', null, 'https://www.soderbergpartners.se', null),
  ('nordbygg-2026-exhibitor-139133', 'nordbygg-2026', 'Tabergkonstruktioner AB', 'C12:70', jsonb_build_object('en', 'Varmt välkomna att besöka oss i monter C12:70!

Vi på värmländska Tabergkonstruktioner AB presenterar våra egenutvecklade jordskruvar och tillhörande beslag.
Vi har tagit fram olika alternativ på monteringsmaskiner.  Det finns både batteri-, el- och hydrauliska alternativ från handhållen till entreprenad.

Stor vikt är lagd vid detaljerna för att effektivisera monteringen, så enkel och pålitlig som möjligt – något som sparar både tid och arbete för montörerna.

Jordskruv är en modern grundläggningsmetod.
Den är tidsbesparande, hållfast och lämnar minimalt med spår och påverkan på miljön.

Tabergs tillverkar även ett system för markmonterad solenergi. Det är helt flexibelt gällande konfiguration och layout.', 'sv', 'Varmt välkomna att besöka oss i monter C12:70!

Vi på värmländska Tabergkonstruktioner AB presenterar våra egenutvecklade jordskruvar och tillhörande beslag.
Vi har tagit fram olika alternativ på monteringsmaskiner.  Det finns både batteri-, el- och hydrauliska alternativ från handhållen till entreprenad.

Stor vikt är lagd vid detaljerna för att effektivisera monteringen, så enkel och pålitlig som möjligt – något som sparar både tid och arbete för montörerna.

Jordskruv är en modern grundläggningsmetod.
Den är tidsbesparande, hållfast och lämnar minimalt med spår och påverkan på miljön.

Tabergs tillverkar även ett system för markmonterad solenergi. Det är helt flexibelt gällande konfiguration och layout.'), 'https://www.tabergs.com', 'assets/images/exhibitors/nordbygg-2026-tabergkonstruktioner-ab.jpg'),
  ('nordbygg-2026-exhibitor-137848', 'nordbygg-2026', 'Tajima Trading', 'B10:31', null, 'https://www.tajima.dk', null),
  ('nordbygg-2026-exhibitor-135899', 'nordbygg-2026', 'Tantum', 'C07:11', jsonb_build_object('en', 'HÅLLBAR INREDNING

Tantum tillverkar kök och inredning som ska tåla en tuff miljö.

I skolor, förskolor, äldreboenden och andra offentliga miljöer är köket en arbetsplats. Det används av många olika personer och ofta under stora delar av dagen och utsätts det för ganska stora påfrestningar. Även annan inredning, som elevskåp och kapprumsskåp, måste klara en omild behandling.

Tantum byggs i plywood, alltså skiktlimmat massivträ – betydligt starkare och tåligare än vanliga spånplatteskåp. Därmed klarar de också att stå emot slitaget.', 'sv', 'HÅLLBAR INREDNING

Tantum tillverkar kök och inredning som ska tåla en tuff miljö.

I skolor, förskolor, äldreboenden och andra offentliga miljöer är köket en arbetsplats. Det används av många olika personer och ofta under stora delar av dagen och utsätts det för ganska stora påfrestningar. Även annan inredning, som elevskåp och kapprumsskåp, måste klara en omild behandling.

Tantum byggs i plywood, alltså skiktlimmat massivträ – betydligt starkare och tåligare än vanliga spånplatteskåp. Därmed klarar de också att stå emot slitaget.'), 'https://www.tantum.se', 'assets/images/exhibitors/nordbygg-2026-tantum.jpg'),
  ('nordbygg-2026-exhibitor-134011', 'nordbygg-2026', 'TEBO Byggtillbehör AB', 'B07:30', jsonb_build_object('en', 'I över 50 år har vi utvecklat och marknadsfört specialprodukter för professionella hantverkare inom plattsättning, golvavjämning och murning. Tillsammans med egna och utvalda partners varumärken erbjuder vi en unik och innovativ produktportfölj.

Under Nordbygg hittar ni oss i monter B07:30, en över 80m² stor monter med fokus på verktyg.
Här presenterar vi TEBO och våra partners och fyller montern med specialprodukter för professionella hantverkare. Kolla in våra demos, produktnyheter och se till att du får en TEBO-påse.', 'sv', 'I över 50 år har vi utvecklat och marknadsfört specialprodukter för professionella hantverkare inom plattsättning, golvavjämning och murning. Tillsammans med egna och utvalda partners varumärken erbjuder vi en unik och innovativ produktportfölj.

Under Nordbygg hittar ni oss i monter B07:30, en över 80m² stor monter med fokus på verktyg.
Här presenterar vi TEBO och våra partners och fyller montern med specialprodukter för professionella hantverkare. Kolla in våra demos, produktnyheter och se till att du får en TEBO-påse.'), 'https://www.tebo.se', 'assets/images/exhibitors/nordbygg-2026-tebo-byggtillbehor-ab.jpg'),
  ('nordbygg-2026-exhibitor-134020', 'nordbygg-2026', 'TECE Sverige AB', 'A07:10', jsonb_build_object('en', 'TECE Group grundades i Tyskland 1987 och är i dag en internationell koncern med 22 europeiska dotterbolag och samarbetspartners i ytterligare 39 länder. Koncernen har sex egna fabriker och är specialiserad på sanitetssystem, golvvärme samt avlopps- och tappvattensystem.

TECE har cirka 1 900 medarbetare och huvudkontoret ligger i Emsdetten, Tyskland. I Sverige har TECE lokal närvaro med resurser för produktutveckling, försäljning och distribution.', 'sv', 'TECE Group grundades i Tyskland 1987 och är i dag en internationell koncern med 22 europeiska dotterbolag och samarbetspartners i ytterligare 39 länder. Koncernen har sex egna fabriker och är specialiserad på sanitetssystem, golvvärme samt avlopps- och tappvattensystem.

TECE har cirka 1 900 medarbetare och huvudkontoret ligger i Emsdetten, Tyskland. I Sverige har TECE lokal närvaro med resurser för produktutveckling, försäljning och distribution.'), 'https://www.tece.se', 'assets/images/exhibitors/nordbygg-2026-tece-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-135819', 'nordbygg-2026', 'Techem IMD-system', 'A12:02', jsonb_build_object('en', 'Smart avläsning - Rättvis debitering

Med Individuell Mätning och Debitering (IMD) är det enkelt att debitera de rörliga förbrukningskostnaderna till varje bostad.

Vi erbjuder digitala mätare med automatisk fjärravläsning och har i över 25 år hjälpt föreningar att sänka kostnader och effektivisera energianvändningen med IMD för el, vatten, värme och temperatur.

IMD skapar incitament för de boende att hushålla med sin förbrukning och på så sätt minska fastighetens driftskostnader. Erfarenhet visar att förbrukningen normalt sjunker med 20-30% när man inför IMD.
Med de senaste årens kraftigt stigande energi- och vattenpriser innebär därmed att en investering i IMD är mer lönsamt än någonsin.', 'sv', 'Smart avläsning - Rättvis debitering

Med Individuell Mätning och Debitering (IMD) är det enkelt att debitera de rörliga förbrukningskostnaderna till varje bostad.

Vi erbjuder digitala mätare med automatisk fjärravläsning och har i över 25 år hjälpt föreningar att sänka kostnader och effektivisera energianvändningen med IMD för el, vatten, värme och temperatur.

IMD skapar incitament för de boende att hushålla med sin förbrukning och på så sätt minska fastighetens driftskostnader. Erfarenhet visar att förbrukningen normalt sjunker med 20-30% när man inför IMD.
Med de senaste årens kraftigt stigande energi- och vattenpriser innebär därmed att en investering i IMD är mer lönsamt än någonsin.'), 'https://www.imd-system.se', 'assets/images/exhibitors/nordbygg-2026-techem-imd-system.jpg'),
  ('nordbygg-2026-exhibitor-139607', 'nordbygg-2026', 'Telesteps', 'B01:31 (+1)', jsonb_build_object('en', 'För många år sedan skapade vi en ikon i stegvärlden och är idag erkända som världsledande inom teleskopiska arbetsredskap. Vårt varumärke och våra svensktillverkade och svenskutvecklade produkter, som är erkända för sin kvalitet och design av användare över hela världen, försäkrar att vi alltid sätter säkerhet och kvalitet först.', 'sv', 'För många år sedan skapade vi en ikon i stegvärlden och är idag erkända som världsledande inom teleskopiska arbetsredskap. Vårt varumärke och våra svensktillverkade och svenskutvecklade produkter, som är erkända för sin kvalitet och design av användare över hela världen, försäkrar att vi alltid sätter säkerhet och kvalitet först.'), 'https://www.telesteps.se', 'assets/images/exhibitors/nordbygg-2026-telesteps.jpg'),
  ('nordbygg-2026-exhibitor-138131', 'nordbygg-2026', 'Termo-fol sp.  z o.o.', 'A11:24', jsonb_build_object('en', 'Polish heating film factory.
Electric heating manufacturer.', 'sv', 'Polish heating film factory.
Electric heating manufacturer.'), 'https://www.termofol.com', 'assets/images/exhibitors/nordbygg-2026-termo-fol-sp-z-o-o.jpg'),
  ('nordbygg-2026-exhibitor-137710', 'nordbygg-2026', 'tesa', 'C09:51', null, 'https://www.tesa.com', null),
  ('nordbygg-2026-exhibitor-134015', 'nordbygg-2026', 'Thermokon-Danelko Elektronik AB', 'A15:04', null, 'https://www.danelko.se', null),
  ('nordbygg-2026-exhibitor-134576', 'nordbygg-2026', 'Thermotech Scandinavia AB', 'A07:14', jsonb_build_object('en', 'Thermotech Scandinavia AB utvecklar, tillverkar, projekterar och levererar kundanpassade och hållbara system för värme- och vattendistribution.

I vår monter A07:14 finns våra kunniga medarbetare redo att berätta om våra prefabricerade systemlösningar. Vi visar smarta och smidiga Prefab-lösningar för vattenburen golvvärme, radiatoranslutningar och tappvatten i både villor och flervåningshus.

I år fyller vi 30 år!
Sedan 1996 har vi jobbat för att förenkla kundens vardag genom att göra det enkelt att beställa och installera våra produkter och stödja med relevanta tjänster.

Vi erbjuder en trygg och pålitlig leverans, beprövad över tid.

Varmt välkommen till Thermotech i monter A07:14!', 'sv', 'Thermotech Scandinavia AB utvecklar, tillverkar, projekterar och levererar kundanpassade och hållbara system för värme- och vattendistribution.

I vår monter A07:14 finns våra kunniga medarbetare redo att berätta om våra prefabricerade systemlösningar. Vi visar smarta och smidiga Prefab-lösningar för vattenburen golvvärme, radiatoranslutningar och tappvatten i både villor och flervåningshus.

I år fyller vi 30 år!
Sedan 1996 har vi jobbat för att förenkla kundens vardag genom att göra det enkelt att beställa och installera våra produkter och stödja med relevanta tjänster.

Vi erbjuder en trygg och pålitlig leverans, beprövad över tid.

Varmt välkommen till Thermotech i monter A07:14!'), 'https://www.thermotech.se', 'assets/images/exhibitors/nordbygg-2026-thermotech-scandinavia-ab.jpg'),
  ('nordbygg-2026-exhibitor-137545', 'nordbygg-2026', 'ThermoWhite', 'C07:53', jsonb_build_object('en', 'Thermowhite är ett sömlöst värme- och ljudisolerings- material.
Tack vare materialets beläggningsegenskaper uppnås ett monolitiskt, skarvlöst värmeisoleringsskikt utan köld- och ljudbryggor. ThermoWhite-systemet är ett miljövänligt system som använder återvunnet material - expanderat polystyrenavfall.
Bindemedlet som används är ett mineralmaterial som uppfanns och patenterades för 20 år sedan av Alois Edler, ThermoWhites grundare. Den vita färgen på materialet symboliserar innovativ teknik som ger moderna och praktiska lösningar.', 'sv', 'Thermowhite är ett sömlöst värme- och ljudisolerings- material.
Tack vare materialets beläggningsegenskaper uppnås ett monolitiskt, skarvlöst värmeisoleringsskikt utan köld- och ljudbryggor. ThermoWhite-systemet är ett miljövänligt system som använder återvunnet material - expanderat polystyrenavfall.
Bindemedlet som används är ett mineralmaterial som uppfanns och patenterades för 20 år sedan av Alois Edler, ThermoWhites grundare. Den vita färgen på materialet symboliserar innovativ teknik som ger moderna och praktiska lösningar.'), 'https://www.thermowhite.se', 'assets/images/exhibitors/nordbygg-2026-thermowhite.jpg'),
  ('nordbygg-2026-exhibitor-136725', 'nordbygg-2026', 'Thorsbergs Stenhuggeri AB', 'C04:61C', null, 'https://www.thorsberg.se', null),
  ('nordbygg-2026-exhibitor-139109', 'nordbygg-2026', 'Tidab', 'EÖ:24', null, 'https://www.tidab.se', 'assets/images/exhibitors/nordbygg-2026-tidab.jpg'),
  ('nordbygg-2026-exhibitor-135001', 'nordbygg-2026', 'Timberman Golv AB', 'C03:33', jsonb_build_object('en', 'Golv med stil!
För de flesta är köpet av ett nytt golv en investering i en konsumtionsvara som ska hålla länge, med en förväntad livslängd på 20–25 år. Därför bör man inte enbart låta priset vara avgörande faktorn för det slutliga valet, utan snarare om kvaliteten på golvet ger valuta för pengarna.

I detta sammanhang spelar Timberman en viktig roll som golvleverantör. Med vårt sortiment av vinyl-, kork- och trägolv har vi skapat en kollektion av hårda golvbeläggningar vars funktion och estetik spelar i en division för sig och som därmed kan användas i de flesta hem. För oss är det viktigt att golvet matchar livsstilen i den aktuella miljön.

Kvalitet och säkerhet
När du köper ett Novego-, Wicanders- eller Timberman-golv kan du vara säker på att få en stark och hållbar produkt av hög kvalitet. Alla våra golv är lätta att lägga samt omsorgsfullt testade, har vackra ytor och kräver minimalt underhåll. Överensstämmelsen mellan förväntningar och produkt resulterar i nöjda kunder.

När du väljer ett Timberman-golv får du också professionell vägledning vid val av golv, läggning och efterföljande skötsel. Vi säkerställer att du får en samlad golvlösning som är bättre i längden.', 'sv', 'Golv med stil!
För de flesta är köpet av ett nytt golv en investering i en konsumtionsvara som ska hålla länge, med en förväntad livslängd på 20–25 år. Därför bör man inte enbart låta priset vara avgörande faktorn för det slutliga valet, utan snarare om kvaliteten på golvet ger valuta för pengarna.

I detta sammanhang spelar Timberman en viktig roll som golvleverantör. Med vårt sortiment av vinyl-, kork- och trägolv har vi skapat en kollektion av hårda golvbeläggningar vars funktion och estetik spelar i en division för sig och som därmed kan användas i de flesta hem. För oss är det viktigt att golvet matchar livsstilen i den aktuella miljön.

Kvalitet och säkerhet
När du köper ett Novego-, Wicanders- eller Timberman-golv kan du vara säker på att få en stark och hållbar produkt av hög kvalitet. Alla våra golv är lätta att lägga samt omsorgsfullt testade, har vackra ytor och kräver minimalt underhåll. Överensstämmelsen mellan förväntningar och produkt resulterar i nöjda kunder.

När du väljer ett Timberman-golv får du också professionell vägledning vid val av golv, läggning och efterföljande skötsel. Vi säkerställer att du får en samlad golvlösning som är bättre i längden.'), 'https://www.timbermangolv.se', 'assets/images/exhibitors/nordbygg-2026-timberman-golv-ab.jpg'),
  ('nordbygg-2026-exhibitor-139561', 'nordbygg-2026', 'Tingvalla-Bro Fackförening', 'AG:60', jsonb_build_object('en', 'Tingvalla-Bro Fackförening är en fristående facklig organisation som organiserar alla yrkesgrupper och är partipolitisk obunden där vårt intresse ligger i arbetsrätten och den enskilda medlemmen. Det är viktigt för oss att våra medlemmar ska kunna nå oss lätt och att alla frågor eller problem är lika viktiga. I vårt arbete har vi fokus på våra medlemmar och det är de som avgör vilka frågor som ska drivas.
Företag kan teckna kollektivavtal med Tingvalla-Bro Fackförening, de flesta avtal om vi har idag är inom byggbranschen. Avtalen tecknas direkt mellan företaget och Tingvalla-Bro.
Välkomna till vår monter AG:60', 'sv', 'Tingvalla-Bro Fackförening är en fristående facklig organisation som organiserar alla yrkesgrupper och är partipolitisk obunden där vårt intresse ligger i arbetsrätten och den enskilda medlemmen. Det är viktigt för oss att våra medlemmar ska kunna nå oss lätt och att alla frågor eller problem är lika viktiga. I vårt arbete har vi fokus på våra medlemmar och det är de som avgör vilka frågor som ska drivas.
Företag kan teckna kollektivavtal med Tingvalla-Bro Fackförening, de flesta avtal om vi har idag är inom byggbranschen. Avtalen tecknas direkt mellan företaget och Tingvalla-Bro.
Välkomna till vår monter AG:60'), 'https://www.tingvallabro.se', 'assets/images/exhibitors/nordbygg-2026-tingvalla-bro-fackforening.jpg'),
  ('nordbygg-2026-exhibitor-134673', 'nordbygg-2026', 'TJB Försäljning AB', 'C17:31', jsonb_build_object('en', 'TJB tillverkar och säljer takprodukter till bygghandel, grossister och husproduktion. Idag står vi starka med ett brett sortiment av takpapp, taksäkerhet, takavvattning, taktillbehör, samt Solentra, vårt infästningssystem för solpaneler till alla typer av tak.

Vi har haft samma drivkraft som vi haft sedan starten för över 25 år sedan, att genom egen tillverkning, brett sortiment, stort tekniskt kunnande och service i världsklass erbjuder våra kunder en bättre takaffär.', 'sv', 'TJB tillverkar och säljer takprodukter till bygghandel, grossister och husproduktion. Idag står vi starka med ett brett sortiment av takpapp, taksäkerhet, takavvattning, taktillbehör, samt Solentra, vårt infästningssystem för solpaneler till alla typer av tak.

Vi har haft samma drivkraft som vi haft sedan starten för över 25 år sedan, att genom egen tillverkning, brett sortiment, stort tekniskt kunnande och service i världsklass erbjuder våra kunder en bättre takaffär.'), 'https://www.tjb.se', 'assets/images/exhibitors/nordbygg-2026-tjb-forsaljning-ab.jpg'),
  ('nordbygg-2026-exhibitor-134016', 'nordbygg-2026', 'Tollco AB', 'A10:22', null, 'https://www.tollco.se', 'assets/images/exhibitors/nordbygg-2026-tollco-ab.jpg'),
  ('nordbygg-2026-exhibitor-138951', 'nordbygg-2026', 'Tomoku Hus AB', 'C15:18', null, 'https://www.tomokuhus.se', 'assets/images/exhibitors/nordbygg-2026-tomoku-hus-ab.jpg'),
  ('nordbygg-2026-exhibitor-140005', 'nordbygg-2026', 'Tormek AB', 'B07:51', null, 'https://www.tormek.se', null),
  ('nordbygg-2026-exhibitor-134324', 'nordbygg-2026', 'ToughBuilt Industries UK Ltd', 'B03:11', jsonb_build_object('en', 'VI SKAPAR INNOVATIVA PRODUKTER SOM HJÄLPER DIG ATT BYGGA SNABBARE, BYGGA STARKARE OCH ARBETA SMARTARE.

Hur gör vi det?

Vi lyssnar, vi undersöker hur yrkesverksamma arbetar och skapar sedan verktyg som hjälper dem att spara tid, besvär och pengar. Om det inte är bättre, så tillverkar vi det inte. Så enkelt är det.

TOUGHBUILT INNOVATION

När du kollar in en ToughBuilt-produkt tänker du förmodligen "Jag önskar att jag hade tänkt på det." På sätt och vis gjorde du det. För innan vi börjar designa spenderar vi timmar på att titta på hårt arbetande yrkesverksamma som du i arbete. Sedan listar vi ut hur vi kan göra ditt liv enklare, bättre och snabbare.

TOUGHBUILT KVALITET

Du äger förmodligen ett verktyg som tillhörde din pappa. Det har slipats, oljats, slitits slätt och fungerar fortfarande som den dagen det tillverkades. Det är den typen av verktyg vi tillverkar. Vi designar varje ToughBuilt-produkt för att hålla.

Vi uppfinner, konstruerar, testar och verifierar varje ToughBuilt-produkt i USA, tillverkar var och en enligt våra strikta kvalitetsstandarder och backar upp dem med generösa garantier.

TOUGHBUILT VÄRDE

Vissa tror att för att få det bästa av något måste man betala mycket. Det fungerar inte för oss. Vi är hantverkare, designers, ingenjörer och tillverkningsexperter. Vi är stolta över att värdekonstruera varje ToughBuilt-verktyg för att ge dig oöverträffad prestanda. Precis som du arbetar vi hårt för att arbeta smartare. Vi är stolta över att erbjuda byggkvalitet och innovation, till ett pris som är överkomligt för nästan alla. Innovation gjort överkomlig.

DIN TOUGHBUILT

ToughBuilt är inspirerad av dig och är designad från starten för att göra ditt arbete enklare och effektivare.

Vi är dedikerade till att leverera "Prisvärd innovation" till dig.', 'sv', 'VI SKAPAR INNOVATIVA PRODUKTER SOM HJÄLPER DIG ATT BYGGA SNABBARE, BYGGA STARKARE OCH ARBETA SMARTARE.

Hur gör vi det?

Vi lyssnar, vi undersöker hur yrkesverksamma arbetar och skapar sedan verktyg som hjälper dem att spara tid, besvär och pengar. Om det inte är bättre, så tillverkar vi det inte. Så enkelt är det.

TOUGHBUILT INNOVATION

När du kollar in en ToughBuilt-produkt tänker du förmodligen "Jag önskar att jag hade tänkt på det." På sätt och vis gjorde du det. För innan vi börjar designa spenderar vi timmar på att titta på hårt arbetande yrkesverksamma som du i arbete. Sedan listar vi ut hur vi kan göra ditt liv enklare, bättre och snabbare.

TOUGHBUILT KVALITET

Du äger förmodligen ett verktyg som tillhörde din pappa. Det har slipats, oljats, slitits slätt och fungerar fortfarande som den dagen det tillverkades. Det är den typen av verktyg vi tillverkar. Vi designar varje ToughBuilt-produkt för att hålla.

Vi uppfinner, konstruerar, testar och verifierar varje ToughBuilt-produkt i USA, tillverkar var och en enligt våra strikta kvalitetsstandarder och backar upp dem med generösa garantier.

TOUGHBUILT VÄRDE

Vissa tror att för att få det bästa av något måste man betala mycket. Det fungerar inte för oss. Vi är hantverkare, designers, ingenjörer och tillverkningsexperter. Vi är stolta över att värdekonstruera varje ToughBuilt-verktyg för att ge dig oöverträffad prestanda. Precis som du arbetar vi hårt för att arbeta smartare. Vi är stolta över att erbjuda byggkvalitet och innovation, till ett pris som är överkomligt för nästan alla. Innovation gjort överkomlig.

DIN TOUGHBUILT

ToughBuilt är inspirerad av dig och är designad från starten för att göra ditt arbete enklare och effektivare.

Vi är dedikerade till att leverera "Prisvärd innovation" till dig.'), 'https://www.toughbuilt.com', 'assets/images/exhibitors/nordbygg-2026-toughbuilt-industries-uk-ltd.jpg'),
  ('nordbygg-2026-exhibitor-137998', 'nordbygg-2026', 'tr8con Oy', 'B07:53', null, 'https://tr8con.com', 'assets/images/exhibitors/nordbygg-2026-tr8con-oy.jpg'),
  ('nordbygg-2026-exhibitor-138754', 'nordbygg-2026', 'Trade Estonia', 'C03:51', null, 'https://eas.se', null),
  ('nordbygg-2026-exhibitor-137896', 'nordbygg-2026', 'Trapparvid', 'C07:33B', null, 'https://www.trapparvid.se', 'assets/images/exhibitors/nordbygg-2026-trapparvid.jpg'),
  ('nordbygg-2026-exhibitor-137808', 'nordbygg-2026', 'Trelleborg Seals & Profiles', 'C09:21', null, 'https://www.trelleborg.com/sealingprofiles', 'assets/images/exhibitors/nordbygg-2026-trelleborg-seals-profiles.jpg'),
  ('nordbygg-2026-exhibitor-138456', 'nordbygg-2026', 'Trinax Ab', 'C02:41', jsonb_build_object('en', 'Tidrapportering, projekthantering och körjournaler för hantverkare.', 'sv', 'Tidrapportering, projekthantering och körjournaler för hantverkare.'), 'https://www.trinax.se', 'assets/images/exhibitors/nordbygg-2026-trinax-ab.jpg'),
  ('nordbygg-2026-exhibitor-134669', 'nordbygg-2026', 'Trio Perfekta AB', 'A04:20', jsonb_build_object('en', '- Existerar ni fortfarande?
I allra högsta grad! Trots att vår fabrik brann ner till grunden i mars 2025 så var vi tillbaka redan efter några månader. Vi har en verksamhet som vi är stolta över och som är värd att bevara.
I snart 90 år har vi utvecklat funktionella och säkra detaljer för VVS-branschen. Produkter som leder vattnet fram till blandaren, till slangen i trädgården med alla rör, kopplingar och fästen som krävs för en säker och effektiv vattenledning.', 'sv', '- Existerar ni fortfarande?
I allra högsta grad! Trots att vår fabrik brann ner till grunden i mars 2025 så var vi tillbaka redan efter några månader. Vi har en verksamhet som vi är stolta över och som är värd att bevara.
I snart 90 år har vi utvecklat funktionella och säkra detaljer för VVS-branschen. Produkter som leder vattnet fram till blandaren, till slangen i trädgården med alla rör, kopplingar och fästen som krävs för en säker och effektiv vattenledning.'), 'https://www.trio-perfekta.se', 'assets/images/exhibitors/nordbygg-2026-trio-perfekta-ab.jpg'),
  ('nordbygg-2026-exhibitor-138994', 'nordbygg-2026', 'TROCELLEN ITALIA S.P.A.', 'A05:35', null, 'https://insulation.trocellen.com', 'assets/images/exhibitors/nordbygg-2026-trocellen-italia-s-p-a.jpg'),
  ('nordbygg-2026-exhibitor-137373', 'nordbygg-2026', 'TROX', 'A12:14', null, 'https://www.trox.se', 'assets/images/exhibitors/nordbygg-2026-trox.jpg'),
  ('nordbygg-2026-exhibitor-137683', 'nordbygg-2026', 'Trä- och Möbelföretagen, TMF', 'C07:33', jsonb_build_object('en', 'Under Nordbygg samlar Trä och möbelföretagen (TMF) medlemsföretag, experter och branschaktörer i TMF Torget.

TMF Torget är en gemensam samlingsmonter där sju medlemsföretag medverkar och där TMFs experter finns på plats under mässan. Här skapar vi en öppen mötesplats för dialog om hållbarhet, branschregler, affärsutveckling och branschens framtidsfrågor.

-  Expertmöten i montern
Varje dag finns en av TMFs sakkunniga på plats för samtal om aktuella branschfrågor.

- Samlingsmonter med sju medlemsföretag:
Gripp inredning
Sjöholms Snickeri
Trapparvid
Stombergs Massiva
Edsbyporten
Rättvikstrappfabrik
Lingbo kulturfönster

TMFs närvaro på Nordbygg syftar till att stärka samverkan i branschen, bidra med ny kunskap och driva utvecklingen mot en mer hållbar och konkurrenskraftig bransch.

Presentation av ny rapport om hållbar renovering den 22/4 på stora scenen kl 12.30. Rapporten belyser hur styrning och incitament påverkar materialval och klimatnytta vid renovering av Sveriges bostäder. Presentationen följs av panelsamtal med politiska och branschrepresentanter. Läs mer nedan.

Välkommen till TMF Torget och träffa oss och sju av våra medlemsföretag i C-hallen!', 'sv', 'Under Nordbygg samlar Trä och möbelföretagen (TMF) medlemsföretag, experter och branschaktörer i TMF Torget.

TMF Torget är en gemensam samlingsmonter där sju medlemsföretag medverkar och där TMFs experter finns på plats under mässan. Här skapar vi en öppen mötesplats för dialog om hållbarhet, branschregler, affärsutveckling och branschens framtidsfrågor.

-  Expertmöten i montern
Varje dag finns en av TMFs sakkunniga på plats för samtal om aktuella branschfrågor.

- Samlingsmonter med sju medlemsföretag:
Gripp inredning
Sjöholms Snickeri
Trapparvid
Stombergs Massiva
Edsbyporten
Rättvikstrappfabrik
Lingbo kulturfönster

TMFs närvaro på Nordbygg syftar till att stärka samverkan i branschen, bidra med ny kunskap och driva utvecklingen mot en mer hållbar och konkurrenskraftig bransch.

Presentation av ny rapport om hållbar renovering den 22/4 på stora scenen kl 12.30. Rapporten belyser hur styrning och incitament påverkar materialval och klimatnytta vid renovering av Sveriges bostäder. Presentationen följs av panelsamtal med politiska och branschrepresentanter. Läs mer nedan.

Välkommen till TMF Torget och träffa oss och sju av våra medlemsföretag i C-hallen!'), 'https://www.tmf.se', 'assets/images/exhibitors/nordbygg-2026-tra-och-mobelforetagen-tmf.jpg'),
  ('nordbygg-2026-exhibitor-138554', 'nordbygg-2026', 'TS Armatur Aktiebolag', 'A12:22', null, 'https://ts-armatur.se', null),
  ('nordbygg-2026-exhibitor-138287', 'nordbygg-2026', 'TSB Gruppen AB', 'C14:50', null, 'https://www.tsbgruppen.se', 'assets/images/exhibitors/nordbygg-2026-tsb-gruppen-ab.jpg'),
  ('nordbygg-2026-exhibitor-134024', 'nordbygg-2026', 'TSR-ELSITE', 'B10:11', jsonb_build_object('en', 'Experten för bygg-el, belysning, värme och verktyg för den tillfälliga arbetsplatsen.', 'sv', 'Experten för bygg-el, belysning, värme och verktyg för den tillfälliga arbetsplatsen.'), 'https://tsr-elsite.fi/sv', 'assets/images/exhibitors/nordbygg-2026-tsr-elsite.jpg'),
  ('nordbygg-2026-exhibitor-134007', 'nordbygg-2026', 'TTM Energiprodukter AB', 'A05:14', jsonb_build_object('en', 'Vi skapar effektiva flöden i värme- och kylsystem.

TTM:s sortiment inom vätskebehandling består av produkter för kontroll, rening, undertrycksavgasning, tryckhållning och påfyllning av systemvätska i VVS-system.

Är du fastighetsägare, förvaltare, VVS-konsult, professionell inköpare eller installatör? Vi har gedigen kompetens om kvalificerade produkter inom VVS för att underlätta ditt arbete med att planera, specificera och införskaffa produkter som skapar effektiva flöden i VVS-system.

TTM Energiprodukter är efter 50 år Sveriges ledande leverantör av prefabricerade Shuntgrupper och utrustning inom vätskebehandlings för VVS- och Fastighetsbranschen.

Vi drivs av att förse våra kunder med lösningar som förenklar tillvaron och ger effektiva flöden med en säker, långsiktig funktion och bra totalekonomi. I dagsläget är vi verksamma i Sverige, Norge, Danmark, Finland och Holland med huvudkontor och tillverkning i Kalmar.', 'sv', 'Vi skapar effektiva flöden i värme- och kylsystem.

TTM:s sortiment inom vätskebehandling består av produkter för kontroll, rening, undertrycksavgasning, tryckhållning och påfyllning av systemvätska i VVS-system.

Är du fastighetsägare, förvaltare, VVS-konsult, professionell inköpare eller installatör? Vi har gedigen kompetens om kvalificerade produkter inom VVS för att underlätta ditt arbete med att planera, specificera och införskaffa produkter som skapar effektiva flöden i VVS-system.

TTM Energiprodukter är efter 50 år Sveriges ledande leverantör av prefabricerade Shuntgrupper och utrustning inom vätskebehandlings för VVS- och Fastighetsbranschen.

Vi drivs av att förse våra kunder med lösningar som förenklar tillvaron och ger effektiva flöden med en säker, långsiktig funktion och bra totalekonomi. I dagsläget är vi verksamma i Sverige, Norge, Danmark, Finland och Holland med huvudkontor och tillverkning i Kalmar.'), 'https://www.ttmenergi.se', 'assets/images/exhibitors/nordbygg-2026-ttm-energiprodukter-ab.jpg'),
  ('nordbygg-2026-exhibitor-139125', 'nordbygg-2026', 'Tubman AB', 'C06:70', null, 'https://www.tubman.se', null),
  ('nordbygg-2026-exhibitor-140118', 'nordbygg-2026', 'Tulvari Oy', 'A04:02', jsonb_build_object('en', 'Med Tulvaris produkter förhindrar du läckage och gör VVS-monteringen behändig. Samtidigt säkerställer du att slutliga installationen blir både prydligt utförd.', 'sv', 'Med Tulvaris produkter förhindrar du läckage och gör VVS-monteringen behändig. Samtidigt säkerställer du att slutliga installationen blir både prydligt utförd.'), 'https://www.tulvari.fi', 'assets/images/exhibitors/nordbygg-2026-tulvari-oy.jpg'),
  ('nordbygg-2026-exhibitor-138453', 'nordbygg-2026', 'Tyrolit  AB', 'B07:20 (+1)', null, 'https://www.tyrolit.se', null),
  ('nordbygg-2026-exhibitor-140135', 'nordbygg-2026', 'UAB ASMODAS', 'C15:20', jsonb_build_object('en', 'Asmodas is a manufacturer specializing in both historical-style and modern doors. The company combines traditional craftsmanship with contemporary engineering to create high-quality, secure, and aesthetically distinctive products.

With a strong focus on durability, design, and customization, Asmodas serves a wide range of clients—from private homeowners to commercial projects. Its portfolio includes heritage-inspired doors that reflect classic architectural styles, as well as modern solutions tailored to today’s functional and security standards.

Asmodas is committed to delivering reliable, visually refined, and long-lasting door solutions.', 'sv', 'Asmodas is a manufacturer specializing in both historical-style and modern doors. The company combines traditional craftsmanship with contemporary engineering to create high-quality, secure, and aesthetically distinctive products.

With a strong focus on durability, design, and customization, Asmodas serves a wide range of clients—from private homeowners to commercial projects. Its portfolio includes heritage-inspired doors that reflect classic architectural styles, as well as modern solutions tailored to today’s functional and security standards.

Asmodas is committed to delivering reliable, visually refined, and long-lasting door solutions.'), 'https://asmodas.eu', 'assets/images/exhibitors/nordbygg-2026-uab-asmodas.jpg'),
  ('nordbygg-2026-exhibitor-134818', 'nordbygg-2026', 'Ulma AB', 'A09:02', null, 'https://www.ulma.se', null),
  ('nordbygg-2026-exhibitor-139580', 'nordbygg-2026', 'UltraGrime', 'B11:35', null, 'https://ultragrime.com', 'assets/images/exhibitors/nordbygg-2026-ultragrime.jpg'),
  ('nordbygg-2026-exhibitor-137951', 'nordbygg-2026', 'Unipak A/S', 'A12:12', null, 'https://www.unipak.dk', null),
  ('nordbygg-2026-exhibitor-139803', 'nordbygg-2026', 'Unity Living', 'AG:68', null, 'https://unity-living.com/se', 'assets/images/exhibitors/nordbygg-2026-unity-living.jpg'),
  ('nordbygg-2026-exhibitor-138771', 'nordbygg-2026', 'Uqesh AB', 'C07:62', jsonb_build_object('en', 'UQESH är ett biobaserat och lösningsmedelsfritt polyuretanmaterial, inspirerat av ricinolja. Med över 150 års japansk forskning genom ITOH OIL, i kombination med modern tillverkning i Kina erbjuder UQESH ett hållbart och högpresterande alternativ för golv- och väggapplikationer.

Uqesh polyuretanbeläggning är vattenburen, luktfri och mycket slitstark med en livslängd på över 20 år. Den förhindrar sprickor och bakterietillväxt, är kemikalie- och fuktresistent. Tack vare sina internationella kvalitetscertifieringar, bland annat  HACCP, CSM (Cleanroom suitable materials) och den franska A+ klassificeringen, används UQESH i krävande miljöer som livsmedelsindustri, renrum, läkemedelsanläggningar, parkeringsgarage och fordonsindustri.

UQESH står för nästa generation av hållbara golvbeläggningar ,en kombination av miljöansvar, teknisk prestanda och långsiktig trygghet för både företag och samhälle.', 'sv', 'UQESH är ett biobaserat och lösningsmedelsfritt polyuretanmaterial, inspirerat av ricinolja. Med över 150 års japansk forskning genom ITOH OIL, i kombination med modern tillverkning i Kina erbjuder UQESH ett hållbart och högpresterande alternativ för golv- och väggapplikationer.

Uqesh polyuretanbeläggning är vattenburen, luktfri och mycket slitstark med en livslängd på över 20 år. Den förhindrar sprickor och bakterietillväxt, är kemikalie- och fuktresistent. Tack vare sina internationella kvalitetscertifieringar, bland annat  HACCP, CSM (Cleanroom suitable materials) och den franska A+ klassificeringen, används UQESH i krävande miljöer som livsmedelsindustri, renrum, läkemedelsanläggningar, parkeringsgarage och fordonsindustri.

UQESH står för nästa generation av hållbara golvbeläggningar ,en kombination av miljöansvar, teknisk prestanda och långsiktig trygghet för både företag och samhälle.'), 'https://www.uqesh.com', 'assets/images/exhibitors/nordbygg-2026-uqesh-ab.jpg'),
  ('nordbygg-2026-exhibitor-136587', 'nordbygg-2026', 'Uveco AB', 'C16:31', jsonb_build_object('en', 'Uveco är en ledande leverantör inom professionella plåtverktyg och erbjuder ett brett sortiment av verktyg och produkter till byggplåt- och ventilationsplåtslagare. Vår vision är att erbjuda kvalitetsprodukter som underlättar proffsens vardag att utföra ett professionellt arbete.', 'sv', 'Uveco är en ledande leverantör inom professionella plåtverktyg och erbjuder ett brett sortiment av verktyg och produkter till byggplåt- och ventilationsplåtslagare. Vår vision är att erbjuda kvalitetsprodukter som underlättar proffsens vardag att utföra ett professionellt arbete.'), 'https://www.uveco.se', 'assets/images/exhibitors/nordbygg-2026-uveco-ab.jpg'),
  ('nordbygg-2026-exhibitor-135992', 'nordbygg-2026', 'VA & VVS-Fabrikanterna', 'A03:02', jsonb_build_object('en', 'VA & VVS-Fabrikanterna är branschorganisationen som samlar och stärker tillverkande företag inom VA- och VS-industrin. Vi driver branschens hållbara utveckling för att säkra tillgången till livsviktig infrastruktur, rent vatten, trygg värme och säkra avloppslösningar. Vår vision är att vara en ledande kraft för världens mest livskraftiga bransch.

Varje dag levererar vår bransch livsviktig lyx till dig och alla andra i hela Sverige. Det gör vi genom att förse samhället med robusta system för säker infrastruktur. Miljarder smarta komponenter som du sällan ser eller tänker på. Men som ändå alltid finns där.

Det är så du får friskt vatten i din kran och värme i ditt hem. Det är så vi håller våra sjöar och hav rena och skyddar vår natur. Inte bara idag, utan också för kommande generationer.

Vi jobbar ofta i det tysta. Från sjö till kran. Genom grus till hus. Från ett verk i fjärran, hem till din vardag. Allt det där som bara måste funka, det löser vi. För allt vi gör leder till dig.', 'sv', 'VA & VVS-Fabrikanterna är branschorganisationen som samlar och stärker tillverkande företag inom VA- och VS-industrin. Vi driver branschens hållbara utveckling för att säkra tillgången till livsviktig infrastruktur, rent vatten, trygg värme och säkra avloppslösningar. Vår vision är att vara en ledande kraft för världens mest livskraftiga bransch.

Varje dag levererar vår bransch livsviktig lyx till dig och alla andra i hela Sverige. Det gör vi genom att förse samhället med robusta system för säker infrastruktur. Miljarder smarta komponenter som du sällan ser eller tänker på. Men som ändå alltid finns där.

Det är så du får friskt vatten i din kran och värme i ditt hem. Det är så vi håller våra sjöar och hav rena och skyddar vår natur. Inte bara idag, utan också för kommande generationer.

Vi jobbar ofta i det tysta. Från sjö till kran. Genom grus till hus. Från ett verk i fjärran, hem till din vardag. Allt det där som bara måste funka, det löser vi. För allt vi gör leder till dig.'), 'https://vavvs.se', 'assets/images/exhibitors/nordbygg-2026-va-vvs-fabrikanterna.jpg'),
  ('nordbygg-2026-exhibitor-139318', 'nordbygg-2026', 'Vaara', 'C11:71', jsonb_build_object('en', 'Vaara är ett familjeföretag från Finland som erbjuder högkvalitativa trälösningar av nordiskt trä.

Våra huvudprodukter är färdigbehandlade Vaara Nordic™ ytterpaneler och Vaara Nordic™ Wide limträpaneler. Vi tillverkar även Vaara Stabil™ sättningsfria lamellstock.', 'sv', 'Vaara är ett familjeföretag från Finland som erbjuder högkvalitativa trälösningar av nordiskt trä.

Våra huvudprodukter är färdigbehandlade Vaara Nordic™ ytterpaneler och Vaara Nordic™ Wide limträpaneler. Vi tillverkar även Vaara Stabil™ sättningsfria lamellstock.'), 'https://vaaranordic.se', 'assets/images/exhibitors/nordbygg-2026-vaara.jpg'),
  ('nordbygg-2026-exhibitor-135658', 'nordbygg-2026', 'Vageler & Christiansen GmbH', 'B07:13', jsonb_build_object('en', 'Vageler & Christiansen GmbH har sedan 1897 levererat verktyg, maskiner, personlig skyddsutrustning och tillbehör från ledande varumärken till fackhandeln. Med över 150 års erfarenhet och ett starkt leverantörsnätverk erbjuder vi återförsäljare i hela Europa pålitliga inköpslösningar, produkter av hög kvalitet och effektiva köptjänster – allt från en och samma källa. Vårt mål är att göra det enkelt, snabbt och kostnadseffektivt för kunder att hitta rätt verktyg och utrustning.', 'sv', 'Vageler & Christiansen GmbH har sedan 1897 levererat verktyg, maskiner, personlig skyddsutrustning och tillbehör från ledande varumärken till fackhandeln. Med över 150 års erfarenhet och ett starkt leverantörsnätverk erbjuder vi återförsäljare i hela Europa pålitliga inköpslösningar, produkter av hög kvalitet och effektiva köptjänster – allt från en och samma källa. Vårt mål är att göra det enkelt, snabbt och kostnadseffektivt för kunder att hitta rätt verktyg och utrustning.'), 'https://www.vachri-shop.com', 'assets/images/exhibitors/nordbygg-2026-vageler-christiansen-gmbh.jpg'),
  ('nordbygg-2026-exhibitor-138146', 'nordbygg-2026', 'Vallox Oy', 'A17:18', jsonb_build_object('en', 'Vallox är ett finskt företag som utvecklar, tillverkar och säljer produkter relaterade till ventilation, såsom ventilationsaggregat, luftbehandlingsaggregat och takfläktar.

Vallox produkter är utformade för att förbättra inomhusluftens kvalitet, energieffektivitet samt komforten i boende och arbetsmiljöer.

Återförsäljare i Sverige:
LTS Products AB | Plåtgatan 1, 614 31 Söderköping |  lts.eu | info@lts.eu', 'sv', 'Vallox är ett finskt företag som utvecklar, tillverkar och säljer produkter relaterade till ventilation, såsom ventilationsaggregat, luftbehandlingsaggregat och takfläktar.

Vallox produkter är utformade för att förbättra inomhusluftens kvalitet, energieffektivitet samt komforten i boende och arbetsmiljöer.

Återförsäljare i Sverige:
LTS Products AB | Plåtgatan 1, 614 31 Söderköping |  lts.eu | info@lts.eu'), 'https://www.vallox.com', 'assets/images/exhibitors/nordbygg-2026-vallox-oy.jpg'),
  ('nordbygg-2026-exhibitor-139266', 'nordbygg-2026', 'Varem SPA', 'A08:30', jsonb_build_object('en', 'Produttore di vasi di espansione da 0,16 L a 2000 L', 'sv', 'Produttore di vasi di espansione da 0,16 L a 2000 L'), 'https://www.varem.com', 'assets/images/exhibitors/nordbygg-2026-varem-spa.jpg'),
  ('nordbygg-2026-exhibitor-136679', 'nordbygg-2026', 'VE Sten AB', 'C04:61I', null, 'https://www.ve-sten.se', 'assets/images/exhibitors/nordbygg-2026-ve-sten-ab.jpg'),
  ('nordbygg-2026-exhibitor-136145', 'nordbygg-2026', 'VEAB Heat Tech AB', 'A19:14', jsonb_build_object('en', 'VEAB mer än bara ett företag. Det är en historia som startade i Hässleholm 1967 och som fortsätter att växa och inspirera genom kvalitet, passion och globalt engagemang.
Där vi en gång började som en lokal aktör sträcker vi nu våra vingar internationellt och levererar våra klimatlösningar till hela världen.
Vår förmåga att anpassa oss efter kundernas behov har gjort oss till en pålitlig partner för alla de som söker miljömedvetna och hållbara produkter inom kyla och värme.', 'sv', 'VEAB mer än bara ett företag. Det är en historia som startade i Hässleholm 1967 och som fortsätter att växa och inspirera genom kvalitet, passion och globalt engagemang.
Där vi en gång började som en lokal aktör sträcker vi nu våra vingar internationellt och levererar våra klimatlösningar till hela världen.
Vår förmåga att anpassa oss efter kundernas behov har gjort oss till en pålitlig partner för alla de som söker miljömedvetna och hållbara produkter inom kyla och värme.'), 'https://www.veab.com', 'assets/images/exhibitors/nordbygg-2026-veab-heat-tech-ab.jpg'),
  ('nordbygg-2026-exhibitor-137537', 'nordbygg-2026', 'Vedum Kök & Bad AB', 'C05:11', jsonb_build_object('en', 'I den lilla orten Vedum, Västergötland, tillverkar vi inredningar för hela hemmet – och hela människan. Det har vi gjort i över ett sekel och vi tänker fortsätta i minst 100 år till. Vår verksamhet har alltid präglats av en naturlig omtanke. För hantverket, bygden omkring oss och välbefinnandet hos de som ska leva med våra produkter. Vi tror att alla behöver en välkomnande plats där de känner sig hemma – och att våra kök, badrum, tvättstugor och annan inredning hjälper till att skapa sådana platser. Men för oss betyder omtanke mycket mer. Det handlar även om att tänka om. Att tänka till och göra saker på nya och bättre sätt. För att utvecklas med tiden, livet och de nya krav som ställs på oss alla, inte minst vad gäller miljö och klimat. Den stora kunskap, kärlek och kreativitet som vi lägger ned i våra lösningar följer med hem till dig och får ditt hjärta att bulta lika varmt i dag som i morgon. Det är att leva med omtanke.', 'sv', 'I den lilla orten Vedum, Västergötland, tillverkar vi inredningar för hela hemmet – och hela människan. Det har vi gjort i över ett sekel och vi tänker fortsätta i minst 100 år till. Vår verksamhet har alltid präglats av en naturlig omtanke. För hantverket, bygden omkring oss och välbefinnandet hos de som ska leva med våra produkter. Vi tror att alla behöver en välkomnande plats där de känner sig hemma – och att våra kök, badrum, tvättstugor och annan inredning hjälper till att skapa sådana platser. Men för oss betyder omtanke mycket mer. Det handlar även om att tänka om. Att tänka till och göra saker på nya och bättre sätt. För att utvecklas med tiden, livet och de nya krav som ställs på oss alla, inte minst vad gäller miljö och klimat. Den stora kunskap, kärlek och kreativitet som vi lägger ned i våra lösningar följer med hem till dig och får ditt hjärta att bulta lika varmt i dag som i morgon. Det är att leva med omtanke.'), 'https://www.vedum.se', 'assets/images/exhibitors/nordbygg-2026-vedum-kok-bad-ab.jpg'),
  ('nordbygg-2026-exhibitor-139070', 'nordbygg-2026', 'VELUX Svenska AB', 'C10:51', null, 'https://www.velux.se', 'assets/images/exhibitors/nordbygg-2026-velux-svenska-ab.jpg'),
  ('nordbygg-2026-exhibitor-139366', 'nordbygg-2026', 'Verbo', 'C05:70', jsonb_build_object('en', 'At Verbo, we believe that every project starts with a solid foundation, and that means protecting what matters. Whether you’re working on a new build or a renovation, the right floor protection is essential to make sure your work goes smoothly. That’s why we developed Perfect Cover®: a range of high-quality, self-adhesive floor coverings specifically designed to meet the diverse needs of the modern construction professional. With Perfect Cover®, you can be sure of reliable protection, so you can focus on what really matters: completing your project successfully.', 'sv', 'At Verbo, we believe that every project starts with a solid foundation, and that means protecting what matters. Whether you’re working on a new build or a renovation, the right floor protection is essential to make sure your work goes smoothly. That’s why we developed Perfect Cover®: a range of high-quality, self-adhesive floor coverings specifically designed to meet the diverse needs of the modern construction professional. With Perfect Cover®, you can be sure of reliable protection, so you can focus on what really matters: completing your project successfully.'), 'https://www.verbonet.com', 'assets/images/exhibitors/nordbygg-2026-verbo.jpg'),
  ('nordbygg-2026-exhibitor-138517', 'nordbygg-2026', 'Verkstadsbolaget', 'C14:71', jsonb_build_object('en', 'Verkstadsbolaget tillverkar Automation till främst träindustri, med fokus på special och kundanpassade lösningar.
Vad kan vi hjälpa dig med?', 'sv', 'Verkstadsbolaget tillverkar Automation till främst träindustri, med fokus på special och kundanpassade lösningar.
Vad kan vi hjälpa dig med?'), 'https://verkstadsbolaget.se', 'assets/images/exhibitors/nordbygg-2026-verkstadsbolaget.jpg'),
  ('nordbygg-2026-exhibitor-135252', 'nordbygg-2026', 'Vertex Systems Sweden', 'C02:21', jsonb_build_object('en', 'Vertex BD är en professionell mjukvara för byggdesign, som automatiserar dina arkitekt- och konstruktionsprocesser.

Den bygger på automatiserade verktyg, som utför de många repetitiva uppgifterna i byggprocessen, och på så vis minskar arbetsbördan för personalen', 'sv', 'Vertex BD är en professionell mjukvara för byggdesign, som automatiserar dina arkitekt- och konstruktionsprocesser.

Den bygger på automatiserade verktyg, som utför de många repetitiva uppgifterna i byggprocessen, och på så vis minskar arbetsbördan för personalen'), 'https://vertexcad.com/se/', 'assets/images/exhibitors/nordbygg-2026-vertex-systems-sweden.jpg'),
  ('nordbygg-2026-exhibitor-139183', 'nordbygg-2026', 'Vexcolt (UK) Ltd', 'C09:70', null, 'https://www.vexcolt.com', 'assets/images/exhibitors/nordbygg-2026-vexcolt-uk-ltd.jpg'),
  ('nordbygg-2026-exhibitor-134019', 'nordbygg-2026', 'Vibisol AB', 'C06:60', jsonb_build_object('en', 'Vibisol är verksamt i de nordiska länderna. Vår ambition är att vara en av de ledande aktörerna inom flera teknikområden. Vi erbjuder lösningar och produkter för att isolera stegljud, stomljud och vibrationer. Vårt breda produktutbud omfattar PUR-elastomererna Vibrafoam® och Vibradyn®, Vibisol® HLB, stålfjäderisolatorer, elastiska hängare, dämpare och stegljudsmattor för en rad olika golvkonstruktioner.

Våra leverantörer är Kraiburg PuraSys, Kraiburg Relastec, HET-Group, AMC, Danalim, Insulco, Senor m.fl.', 'sv', 'Vibisol är verksamt i de nordiska länderna. Vår ambition är att vara en av de ledande aktörerna inom flera teknikområden. Vi erbjuder lösningar och produkter för att isolera stegljud, stomljud och vibrationer. Vårt breda produktutbud omfattar PUR-elastomererna Vibrafoam® och Vibradyn®, Vibisol® HLB, stålfjäderisolatorer, elastiska hängare, dämpare och stegljudsmattor för en rad olika golvkonstruktioner.

Våra leverantörer är Kraiburg PuraSys, Kraiburg Relastec, HET-Group, AMC, Danalim, Insulco, Senor m.fl.'), 'https://www.vibisol.se', 'assets/images/exhibitors/nordbygg-2026-vibisol-ab.jpg'),
  ('nordbygg-2026-exhibitor-134017', 'nordbygg-2026', 'Vibratec Akustikprodukter AB', 'C07:41', jsonb_build_object('en', 'Vibratec Akustikprodukter är en av Skandinaviens främsta leverantörer av buller- och vibrationslösningar.
Vibratecs ambition är att vara det självklara valet för kunder som behöver lösa problem med buller, vibration och chock. Vibratec tillverkar och lagerför många produkter som dämpar och isolerar vibration, chock och buller i många olika tillämpningar.', 'sv', 'Vibratec Akustikprodukter är en av Skandinaviens främsta leverantörer av buller- och vibrationslösningar.
Vibratecs ambition är att vara det självklara valet för kunder som behöver lösa problem med buller, vibration och chock. Vibratec tillverkar och lagerför många produkter som dämpar och isolerar vibration, chock och buller i många olika tillämpningar.'), 'https://www.vibratec.se', 'assets/images/exhibitors/nordbygg-2026-vibratec-akustikprodukter-ab.jpg'),
  ('nordbygg-2026-exhibitor-139456', 'nordbygg-2026', 'Victrix Bygg & Bo SHOWROOM', 'C03:11', jsonb_build_object('en', 'Varmt välkommen till vårt Showroom i Stockholm. Alla är välkomna, en plats för både branschfolk och privatpersoner. Vardagar kl 09-16. Här hämtas inspiration och kunskap på 1800 kvm med branschens mest kända varumärken. Missa inte att boka något av våra konferensrum eller skapa ett event i ett Showroom med härlig oförglömlig känsla. Victrix formar miljöer för bygg och bostadsbranschen. Allt från koncept och stilpaket till olika tillvalsprocesser vid nyproduktion och ROT. Det är vi som skapat Bygg&bomässan och som blivit ett kunskapskluster för branschen.', 'sv', 'Varmt välkommen till vårt Showroom i Stockholm. Alla är välkomna, en plats för både branschfolk och privatpersoner. Vardagar kl 09-16. Här hämtas inspiration och kunskap på 1800 kvm med branschens mest kända varumärken. Missa inte att boka något av våra konferensrum eller skapa ett event i ett Showroom med härlig oförglömlig känsla. Victrix formar miljöer för bygg och bostadsbranschen. Allt från koncept och stilpaket till olika tillvalsprocesser vid nyproduktion och ROT. Det är vi som skapat Bygg&bomässan och som blivit ett kunskapskluster för branschen.'), 'https://www.victrix.se', 'assets/images/exhibitors/nordbygg-2026-victrix-bygg-bo-showroom.jpg'),
  ('nordbygg-2026-exhibitor-138252', 'nordbygg-2026', 'VidaFlam', 'C11:41F', jsonb_build_object('en', 'Vida International AB', 'sv', 'Vida International AB'), 'https://www.vidainternational.com', 'assets/images/exhibitors/nordbygg-2026-vidaflam.jpg'),
  ('nordbygg-2026-exhibitor-135467', 'nordbygg-2026', 'Vieser Sweden', 'A11:16', jsonb_build_object('en', 'Vieser designar och säljer högkvalitativa golvbrunnsslösningar och unika designgaller och badrumsprodukter som har tillverkats i Finland sedan 1973.', 'sv', 'Vieser designar och säljer högkvalitativa golvbrunnsslösningar och unika designgaller och badrumsprodukter som har tillverkats i Finland sedan 1973.'), 'https://www.vieser.se', 'assets/images/exhibitors/nordbygg-2026-vieser-sweden.jpg'),
  ('nordbygg-2026-exhibitor-139353', 'nordbygg-2026', 'Villavagnar', 'B07:02', jsonb_build_object('en', 'Morgan Nyman AB är med sina snart 20 år i branschen Sveriges största inom villavagnar. Hos oss finns alltid minst 40 olika modeller för omgående leverans samt att vi via vår egna fabrik i Stenstorp bygger och anpassar modeller helt enligt våra kunders behov. Vi finns numera också med en utställning på Idévägen 23 i Laholm.', 'sv', 'Morgan Nyman AB är med sina snart 20 år i branschen Sveriges största inom villavagnar. Hos oss finns alltid minst 40 olika modeller för omgående leverans samt att vi via vår egna fabrik i Stenstorp bygger och anpassar modeller helt enligt våra kunders behov. Vi finns numera också med en utställning på Idévägen 23 i Laholm.'), 'https://www.villavagnar.com', null),
  ('nordbygg-2026-exhibitor-139916', 'nordbygg-2026', 'Vinden Storage', 'A14:13D', jsonb_build_object('en', 'Proptech när det är som smartast!

Vinden har digitaliserat flödet runt förvaring och transport. Smidigt hämtar Vinden och förvarar det ni eller era hyresgäster vill få undan. Allt märks upp med bild, QR-kod, vikt och mått - ni beställer sen tillbaka det ni behöver.

Man har tillgång till sitt förråd direkt i mobilen, där man kan titta på sina saker, sälja, hyra ut eller beställa hem. Vinden frigör tid och skapar plats för alla typer av företag.', 'sv', 'Proptech när det är som smartast!

Vinden har digitaliserat flödet runt förvaring och transport. Smidigt hämtar Vinden och förvarar det ni eller era hyresgäster vill få undan. Allt märks upp med bild, QR-kod, vikt och mått - ni beställer sen tillbaka det ni behöver.

Man har tillgång till sitt förråd direkt i mobilen, där man kan titta på sina saker, sälja, hyra ut eller beställa hem. Vinden frigör tid och skapar plats för alla typer av företag.'), 'https://www.vinden.com', 'assets/images/exhibitors/nordbygg-2026-vinden-storage.jpg'),
  ('nordbygg-2026-exhibitor-139584', 'nordbygg-2026', 'Visiofy', 'AG:40', jsonb_build_object('en', 'Förvandla arkitektmodeller till realistiska virtuella husvisningar i VR eller webbläsaren – på bara två minuter', 'sv', 'Förvandla arkitektmodeller till realistiska virtuella husvisningar i VR eller webbläsaren – på bara två minuter'), 'https://www.visiofy.com', 'assets/images/exhibitors/nordbygg-2026-visiofy.jpg'),
  ('nordbygg-2026-exhibitor-140095', 'nordbygg-2026', 'VISITEK', 'AG:62', jsonb_build_object('en', 'VISITEK producerar och säljer strålskyddsutrustning som väggskivor, dörrar och fönster.

Vi har ett komplett sortiment av produkter som behövs för att lösa strålskyddet.', 'sv', 'VISITEK producerar och säljer strålskyddsutrustning som väggskivor, dörrar och fönster.

Vi har ett komplett sortiment av produkter som behövs för att lösa strålskyddet.'), 'https://visitek.se', 'assets/images/exhibitors/nordbygg-2026-visitek.jpg'),
  ('nordbygg-2026-exhibitor-140044', 'nordbygg-2026', 'Visneto Rumsbokningssystem', 'AG:41', jsonb_build_object('en', 'Visneto är en svenskutvecklad mötesrumsdisplay- och bokningshanteringssystem. Användare bokar du snabbt direkt på plats i
det genomtänkta menysystemet eller genom datorn eller mobilen. Med Visneto får företag och organisationer full kontroll på mötesrummen. All utveckling, programmering samt support sker i Sverige med svensk välmeriterad personal!', 'sv', 'Visneto är en svenskutvecklad mötesrumsdisplay- och bokningshanteringssystem. Användare bokar du snabbt direkt på plats i
det genomtänkta menysystemet eller genom datorn eller mobilen. Med Visneto får företag och organisationer full kontroll på mötesrummen. All utveckling, programmering samt support sker i Sverige med svensk välmeriterad personal!'), 'https://www.visneto.se', 'assets/images/exhibitors/nordbygg-2026-visneto-rumsbokningssystem.jpg'),
  ('nordbygg-2026-exhibitor-137077', 'nordbygg-2026', 'VM Building Solutions', 'C17:51', jsonb_build_object('en', 'VM Building Solutions är en ledande leverantör av zink- och kopparlösningar för tak, fasader och arkitektoniska detaljer. Med djupa rötter i europeisk byggtradition och  ett starkt internationellt nätverk stödjer vi arkitekter, entreprenörer och hantverkare i hela Norden.

Våra varumärken VMZINC och Nordic Copper är kända för sin kvalitet, hållbarhet och estetiska möjligheter. Materialen utvecklar en vacker patina med tiden, vilket skapar byggnader med karaktär och lång livslängd. Vi erbjuder både produkter och specialiserad rådgivning, tekniska detaljer och riktlinjer för att hjälpa till att förverkliga även komplexa designvisioner i zink och koppar.', 'sv', 'VM Building Solutions är en ledande leverantör av zink- och kopparlösningar för tak, fasader och arkitektoniska detaljer. Med djupa rötter i europeisk byggtradition och  ett starkt internationellt nätverk stödjer vi arkitekter, entreprenörer och hantverkare i hela Norden.

Våra varumärken VMZINC och Nordic Copper är kända för sin kvalitet, hållbarhet och estetiska möjligheter. Materialen utvecklar en vacker patina med tiden, vilket skapar byggnader med karaktär och lång livslängd. Vi erbjuder både produkter och specialiserad rådgivning, tekniska detaljer och riktlinjer för att hjälpa till att förverkliga även komplexa designvisioner i zink och koppar.'), 'https://www.vmzinc.se', 'assets/images/exhibitors/nordbygg-2026-vm-building-solutions.jpg'),
  ('nordbygg-2026-exhibitor-134660', 'nordbygg-2026', 'VoltAir System AB', 'A14:18', jsonb_build_object('en', 'VoltAir System AB producerar och levererar luftbehandlingsaggregat och system till den nordiska fastighetsmarknaden. Fokus ligger alltid på bästa totalekonomi, för såväl entreprenörer som fastighetsägare.

Svensktillverkat och unikt sortiment
Från produktionsenheterna i Torsby och Nyland tillverkar VoltAir lösningar för både fabrikstillverkade enhetsaggregat och för platsmontage.', 'sv', 'VoltAir System AB producerar och levererar luftbehandlingsaggregat och system till den nordiska fastighetsmarknaden. Fokus ligger alltid på bästa totalekonomi, för såväl entreprenörer som fastighetsägare.

Svensktillverkat och unikt sortiment
Från produktionsenheterna i Torsby och Nyland tillverkar VoltAir lösningar för både fabrikstillverkade enhetsaggregat och för platsmontage.'), 'https://www.voltairsystem.com', 'assets/images/exhibitors/nordbygg-2026-voltair-system-ab.jpg'),
  ('nordbygg-2026-exhibitor-134498', 'nordbygg-2026', 'Volution Sweden AB', 'C06:32', jsonb_build_object('en', 'Volution Sweden AB är Nordens marknadsledande producent av ventilationsprodukter för hemmet.

Med vår starka portfölj av varumärken som Fresh, Pax och Klimatfabriken finns vi närvarande i bostadens alla rum, med målet att skapa en sund och hållbar inomhusmiljö i ditt hem.

Volution Sweden AB har geografisk spridning i Europa, Asien samt Nord- och Sydamerika, med huvudkontor i Växjö.', 'sv', 'Volution Sweden AB är Nordens marknadsledande producent av ventilationsprodukter för hemmet.

Med vår starka portfölj av varumärken som Fresh, Pax och Klimatfabriken finns vi närvarande i bostadens alla rum, med målet att skapa en sund och hållbar inomhusmiljö i ditt hem.

Volution Sweden AB har geografisk spridning i Europa, Asien samt Nord- och Sydamerika, med huvudkontor i Växjö.'), 'https://www.volutiongroup.se', 'assets/images/exhibitors/nordbygg-2026-volution-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-134026', 'nordbygg-2026', 'Voxear Technologies AB', 'B03:01', jsonb_build_object('en', 'Voxear Technologies AB är ett svenskt safetytech-företag. Företaget grundades 2020 utanför Stockholm och fokuserar på innovativa hörselskydd med kommunikation för professionella användare. Vi är innovatören och tillverkaren. Vår vision är att förnya hörselskydd i nära samarbete med användarna i Skandinavien och Europa. Vi belönades med Red Dot Award Product Design 2024 för vår första produkt, Voxear™ Protect.', 'sv', 'Voxear Technologies AB är ett svenskt safetytech-företag. Företaget grundades 2020 utanför Stockholm och fokuserar på innovativa hörselskydd med kommunikation för professionella användare. Vi är innovatören och tillverkaren. Vår vision är att förnya hörselskydd i nära samarbete med användarna i Skandinavien och Europa. Vi belönades med Red Dot Award Product Design 2024 för vår första produkt, Voxear™ Protect.'), 'https://voxear.com', 'assets/images/exhibitors/nordbygg-2026-voxear-technologies-ab.jpg'),
  ('nordbygg-2026-exhibitor-140170', 'nordbygg-2026', 'Vubadesign', 'EÖ:38', null, 'https://www.vubadesign.se', null),
  ('nordbygg-2026-exhibitor-135581', 'nordbygg-2026', 'VVS Börssen Ab LVI-Pörssi Oy', 'A04:02', jsonb_build_object('en', 'LVI-Pörssi
Developer- Manufacturer - Importer - Wholesales

LVI-Pörssi is developing and manufacturing Finnish company with HVAC-products.
Our main products are Wall Box, Water traps, Floor grating and Leak Detectors

Our mission is to make the work of the professional plumper’s as easy and safe as possible. We are constantly developing our products and looking for innovations and new ways to make Finnish living more ingenious and comfortable.', 'sv', 'LVI-Pörssi
Developer- Manufacturer - Importer - Wholesales

LVI-Pörssi is developing and manufacturing Finnish company with HVAC-products.
Our main products are Wall Box, Water traps, Floor grating and Leak Detectors

Our mission is to make the work of the professional plumper’s as easy and safe as possible. We are constantly developing our products and looking for innovations and new ways to make Finnish living more ingenious and comfortable.'), 'https://www.vvsbörsen.se/en', 'assets/images/exhibitors/nordbygg-2026-vvs-borssen-ab-lvi-porssi-oy.jpg'),
  ('nordbygg-2026-exhibitor-139587', 'nordbygg-2026', 'VVS-Info', 'A03:02', null, 'https://www.vvsinfo.se', null),
  ('nordbygg-2026-exhibitor-139569', 'nordbygg-2026', 'Vyrk AS', 'C13:60', jsonb_build_object('en', 'Vyrk AS er en norsk produsent av eksklusive interiør- og byggeløsninger med fabrikker i Valdres, Trysil og Stange. Vi leverer skreddersydde produkter til noen av Skandinavias mest krevende prosjekter. Vi kombinerer tradisjon og innovasjon for å skape løsninger som forener design, funksjon og bærekraft.', 'sv', 'Vyrk AS er en norsk produsent av eksklusive interiør- og byggeløsninger med fabrikker i Valdres, Trysil og Stange. Vi leverer skreddersydde produkter til noen av Skandinavias mest krevende prosjekter. Vi kombinerer tradisjon og innovasjon for å skape løsninger som forener design, funksjon og bærekraft.'), 'https://www.vyrk.no', 'assets/images/exhibitors/nordbygg-2026-vyrk-as.jpg'),
  ('nordbygg-2026-exhibitor-134008', 'nordbygg-2026', 'Värmebaronen AB', 'A04:10', jsonb_build_object('en', 'Det svenska valet!

Värmebaronen tillverkar pelletsbrännare, pelletspannor, vedpannor, solfångare och elpannor för villor, industrier och fastigheter.', 'sv', 'Det svenska valet!

Värmebaronen tillverkar pelletsbrännare, pelletspannor, vedpannor, solfångare och elpannor för villor, industrier och fastigheter.'), 'https://www.varmebaronen.se', 'assets/images/exhibitors/nordbygg-2026-varmebaronen-ab.jpg'),
  ('nordbygg-2026-exhibitor-139452', 'nordbygg-2026', 'W.AG Funktion + Design GmbH', 'B11:37', null, 'https://www.wag.de', null),
  ('nordbygg-2026-exhibitor-139555', 'nordbygg-2026', 'W.steps', 'B01:31 (+1)', jsonb_build_object('en', 'W.steps är den ledande nordiska tillverkaren av stegar, arbetsbockar och byggnadsställningar för professionella användare. I mer än 90 år har vi lett utvecklingen av pålitliga stegar som uppfyller de allra högsta marknadsstandarderna.', 'sv', 'W.steps är den ledande nordiska tillverkaren av stegar, arbetsbockar och byggnadsställningar för professionella användare. I mer än 90 år har vi lett utvecklingen av pålitliga stegar som uppfyller de allra högsta marknadsstandarderna.'), 'https://www.wsteps.se', 'assets/images/exhibitors/nordbygg-2026-w-steps.jpg'),
  ('nordbygg-2026-exhibitor-139592', 'nordbygg-2026', 'Wanas sp. z o. o.', 'A22:22', jsonb_build_object('en', 'Varför besöka vår monter?
Upptäck förstklassig ventilationsutrustning med värmeåtervinning. Besök vår monter och upplev effektivitet, komfort och design – konstruerad enligt de högsta standarderna.

Vi är en polsk tillverkare av förstklassiga ventilationssystem med värmeåtervinning med över 18 års erfarenhet. Vi använder endast material av högsta kvalitet och beprövad teknik. Som det enda företaget i världen tillverkar vi en unik 4-i-1-ventilationsenhet som erbjuder ventilation, befuktning, uppvärmning och kylning. Våra system levereras som standard med avancerad automatisering som maximerar prestandan, inklusive intelligent zonstyrning.

Translated with DeepL.com (free version)', 'sv', 'Varför besöka vår monter?
Upptäck förstklassig ventilationsutrustning med värmeåtervinning. Besök vår monter och upplev effektivitet, komfort och design – konstruerad enligt de högsta standarderna.

Vi är en polsk tillverkare av förstklassiga ventilationssystem med värmeåtervinning med över 18 års erfarenhet. Vi använder endast material av högsta kvalitet och beprövad teknik. Som det enda företaget i världen tillverkar vi en unik 4-i-1-ventilationsenhet som erbjuder ventilation, befuktning, uppvärmning och kylning. Våra system levereras som standard med avancerad automatisering som maximerar prestandan, inklusive intelligent zonstyrning.

Translated with DeepL.com (free version)'), 'https://www.wanas.pl', 'assets/images/exhibitors/nordbygg-2026-wanas-sp-z-o-o.jpg'),
  ('nordbygg-2026-exhibitor-138327', 'nordbygg-2026', 'Wareco International AB', 'AG:96', jsonb_build_object('en', 'Wareco bildades 1967 med en klar vision om att bli en ledande leverantör på marknaden.

Vi tycker att vi har lyckats. Ett stort antal av världens ledande verktygsleverantörer samarbetar idag med Wareco på den Skandinaviska marknaden.

Wareco finns i Norge sedan 1988
och i Danmark sedan 1999. Försäljning i Finland startade 2003.', 'sv', 'Wareco bildades 1967 med en klar vision om att bli en ledande leverantör på marknaden.

Vi tycker att vi har lyckats. Ett stort antal av världens ledande verktygsleverantörer samarbetar idag med Wareco på den Skandinaviska marknaden.

Wareco finns i Norge sedan 1988
och i Danmark sedan 1999. Försäljning i Finland startade 2003.'), 'https://www.wareco.se', 'assets/images/exhibitors/nordbygg-2026-wareco-international-ab.jpg'),
  ('nordbygg-2026-exhibitor-136728', 'nordbygg-2026', 'Wasasten of Sweden', 'C04:61A', jsonb_build_object('en', 'På Wasasten of Sweden förstår vi att varje byggnadsprojekt, oavsett om det är ett arkitektoniskt mästerverk eller ett privat hem, förtjänar material av högsta kvalitet. Vi är stolta över att kunna erbjuda den mest exklusiva och unika stenen på marknaden – Älvdalskvartsit.

Med en lång och stolt historia av att leverera sten av enastående kvalitet, är vi inte bara en pålitlig partner för arkitekter och byggnadsentreprenörer, utan vi är också kunglig hovleverantör. Vår sten är så anmärkningsvärd att den valts för att pryda några av Sveriges och Europas mest prestigefyllda byggnader.', 'sv', 'På Wasasten of Sweden förstår vi att varje byggnadsprojekt, oavsett om det är ett arkitektoniskt mästerverk eller ett privat hem, förtjänar material av högsta kvalitet. Vi är stolta över att kunna erbjuda den mest exklusiva och unika stenen på marknaden – Älvdalskvartsit.

Med en lång och stolt historia av att leverera sten av enastående kvalitet, är vi inte bara en pålitlig partner för arkitekter och byggnadsentreprenörer, utan vi är också kunglig hovleverantör. Vår sten är så anmärkningsvärd att den valts för att pryda några av Sveriges och Europas mest prestigefyllda byggnader.'), 'https://www.wasasten.se', 'assets/images/exhibitors/nordbygg-2026-wasasten-of-sweden.jpg'),
  ('nordbygg-2026-exhibitor-140104', 'nordbygg-2026', 'Watermeln', 'C03:41', jsonb_build_object('en', 'Watermeln provides zero-emission, off-grid power solutions for construction sites facing grid constraints or strict environmental requirements. Our hydrogen-powered generators and large batteries function as a direct replacement for diesel gensets, delivering reliable baseload power while enabling the full electrification of on-site equipment.

With fast deployment and no need for grid connection, we help construction companies start projects sooner, reduce emissions, and comply with increasingly strict zero-emission regulations—without compromising on performance or uptime.', 'sv', 'Watermeln provides zero-emission, off-grid power solutions for construction sites facing grid constraints or strict environmental requirements. Our hydrogen-powered generators and large batteries function as a direct replacement for diesel gensets, delivering reliable baseload power while enabling the full electrification of on-site equipment.

With fast deployment and no need for grid connection, we help construction companies start projects sooner, reduce emissions, and comply with increasingly strict zero-emission regulations—without compromising on performance or uptime.'), 'https://watermeln.com/en', 'assets/images/exhibitors/nordbygg-2026-watermeln.jpg'),
  ('nordbygg-2026-exhibitor-137949', 'nordbygg-2026', 'Watts Industries Nordic AB', 'A11:29', null, 'https://watts.eu', 'assets/images/exhibitors/nordbygg-2026-watts-industries-nordic-ab.jpg'),
  ('nordbygg-2026-exhibitor-134555', 'nordbygg-2026', 'Weland AB ', 'C15:51', jsonb_build_object('en', 'Välkommen till C15:51 och möt oss från Weland AB!

Weland AB är ett familjeföretag med rötterna i Smålandsstenar och en ledande tillverkare av trappor, räcken, gallerdurk, gångbryggor och entresoler. Vårt breda sortiment kombinerar flexibilitet, innovation och svenskt kunnande med fokus på hållbarhet.

I vår monter möter du, förutom oss, flera av bolagen inom Welandkoncernen. Lär känna dem under Innovationsdagen – mässans första dag – då även finalisterna och vinnaren i Weland  Next Step offentliggörs. Smålandsprofilen Thomas Ravelli finns dessutom på plats redo att bli utmanad i räckhäng i aktiviteten Mässans Mästare. Dagens bästa tid vinner en Welandcykel från Skeppshult med ny chans varje mässdag!

Varmt välkommen till spännande dagar med Weland!', 'sv', 'Välkommen till C15:51 och möt oss från Weland AB!

Weland AB är ett familjeföretag med rötterna i Smålandsstenar och en ledande tillverkare av trappor, räcken, gallerdurk, gångbryggor och entresoler. Vårt breda sortiment kombinerar flexibilitet, innovation och svenskt kunnande med fokus på hållbarhet.

I vår monter möter du, förutom oss, flera av bolagen inom Welandkoncernen. Lär känna dem under Innovationsdagen – mässans första dag – då även finalisterna och vinnaren i Weland  Next Step offentliggörs. Smålandsprofilen Thomas Ravelli finns dessutom på plats redo att bli utmanad i räckhäng i aktiviteten Mässans Mästare. Dagens bästa tid vinner en Welandcykel från Skeppshult med ny chans varje mässdag!

Varmt välkommen till spännande dagar med Weland!'), 'https://www.weland.se', 'assets/images/exhibitors/nordbygg-2026-weland-ab.jpg'),
  ('nordbygg-2026-exhibitor-137984', 'nordbygg-2026', 'Weland Aluminim', 'C15:51', jsonb_build_object('en', 'Välkommen till C15:51 och möt oss från Weland Aluminium & Utemiljö!

Här kan du utforska balkongräcken och vårt modulära miljöhus.

Weland Aluminium erbjuder smarta lösningar och inglasningar av balkonger i aluminium – underhållsfria produkter som är hållbara och flexibla.
Weland Utemiljö tillverkar bland annat miljöhus, cykelskydd och förråd – snygga, funktionella och hållbara lösningar för olika typer av utemiljöer.

Svenskt, innovativt och hållbart – i montern möter du, förutom oss, även några av de andra företagen som ingår i Welandkoncernen. Varmt välkommen!', 'sv', 'Välkommen till C15:51 och möt oss från Weland Aluminium & Utemiljö!

Här kan du utforska balkongräcken och vårt modulära miljöhus.

Weland Aluminium erbjuder smarta lösningar och inglasningar av balkonger i aluminium – underhållsfria produkter som är hållbara och flexibla.
Weland Utemiljö tillverkar bland annat miljöhus, cykelskydd och förråd – snygga, funktionella och hållbara lösningar för olika typer av utemiljöer.

Svenskt, innovativt och hållbart – i montern möter du, förutom oss, även några av de andra företagen som ingår i Welandkoncernen. Varmt välkommen!'), 'https://www.welandalumi.se', 'assets/images/exhibitors/nordbygg-2026-weland-aluminim.jpg'),
  ('nordbygg-2026-exhibitor-137987', 'nordbygg-2026', 'Weland Design', 'C15:51', jsonb_build_object('en', 'Välkommen till C15:51 och möt oss från Weland Design!

Här visar vi upp våra hållbara produkter för utomhusmiljöer – som planteringskärl, kantplåt och cortenrör med utskuren text.

Weland Design erbjuder tidlös och minimalistisk design i stål med produkter som planteringskärl, odlingslådor, kantstål och avskärmare. Vi kombinerar hållbarhet, funktionalitet och estetik för både större offentliga miljöer och privata trädgårdar – och tar även fram kundspecifika, skräddarsydda lösningar.

Svenskt, innovativt och hållbart – i montern möter du, förutom oss, även några av de andra företagen som ingår i Welandkoncernen. Varmt välkommen!', 'sv', 'Välkommen till C15:51 och möt oss från Weland Design!

Här visar vi upp våra hållbara produkter för utomhusmiljöer – som planteringskärl, kantplåt och cortenrör med utskuren text.

Weland Design erbjuder tidlös och minimalistisk design i stål med produkter som planteringskärl, odlingslådor, kantstål och avskärmare. Vi kombinerar hållbarhet, funktionalitet och estetik för både större offentliga miljöer och privata trädgårdar – och tar även fram kundspecifika, skräddarsydda lösningar.

Svenskt, innovativt och hållbart – i montern möter du, förutom oss, även några av de andra företagen som ingår i Welandkoncernen. Varmt välkommen!'), 'https://www.welanddesign.se', 'assets/images/exhibitors/nordbygg-2026-weland-design.jpg'),
  ('nordbygg-2026-exhibitor-137986', 'nordbygg-2026', 'Weland Stål', 'C15:51', jsonb_build_object('en', 'Välkommen till C15:51 och möt oss från Weland Stål!

Här visar vi upp våra lösningar för taksäkerhet och solpanelsfästen.

Vi är en ledande leverantör av produkter för taksäkerhet och utrymning. I vårt sortiment ingår även räcken. Vårt löfte är att leverera pålitliga svensktillverkade produkter med lång livslängd.

Svenskt, innovativt och hållbart – i montern möter du, förutom oss, även några av de andra företagen som ingår i Welandkoncernen. Varmt välkommen!', 'sv', 'Välkommen till C15:51 och möt oss från Weland Stål!

Här visar vi upp våra lösningar för taksäkerhet och solpanelsfästen.

Vi är en ledande leverantör av produkter för taksäkerhet och utrymning. I vårt sortiment ingår även räcken. Vårt löfte är att leverera pålitliga svensktillverkade produkter med lång livslängd.

Svenskt, innovativt och hållbart – i montern möter du, förutom oss, även några av de andra företagen som ingår i Welandkoncernen. Varmt välkommen!'), 'https://www.welandstal.se', 'assets/images/exhibitors/nordbygg-2026-weland-stal.jpg'),
  ('nordbygg-2026-exhibitor-136772', 'nordbygg-2026', 'Wemel Wood', 'C08:11', jsonb_build_object('en', '99,9% of wall surface outlets and switches are still today made from plastic. We are the first in the world to use thermowood as a replacement for plastics in wall surface outlets and switches. Our mission is that by 2040, at least half of all wall surface outlets and switches will be made from renewable materials such as thermowood.', 'sv', '99,9% of wall surface outlets and switches are still today made from plastic. We are the first in the world to use thermowood as a replacement for plastics in wall surface outlets and switches. Our mission is that by 2040, at least half of all wall surface outlets and switches will be made from renewable materials such as thermowood.'), 'https://www.wemelwood.com', 'assets/images/exhibitors/nordbygg-2026-wemel-wood.jpg'),
  ('nordbygg-2026-exhibitor-137432', 'nordbygg-2026', 'Wera Tools Sweden AB', 'B04:51', jsonb_build_object('en', 'Använder du skruvverktyg professionellt? Tror du att det är säkrare och roligare att arbeta med högkvalitativa och hållbara verktyg? Om du svarade ja, kan vi göra dig till en Tool Rebel!

Wera är en tysk tillverkare av skruvverktyg av högsta kvalitet. Vi kallar både oss själva och våra kunder för Tool Rebels. Vi är verktygsmarknadens rebeller. Vi går vår egen väg, ifrågasätter och utmanar befintliga standarder för att hjälpa dig att utföra ditt arbete enklare, snabbare och säkrare. Vi tror genuint att våra produkter oftare sätter ett leende på dina läppar än en svordom under arbetsdagen. Vi älskar innovationer. Vi älskar design. Vi älskar rockmusik.

Under årens lopp har vi utvecklat ett flertal geniala nyheter som Zyklop-spärrskaften och Joker-blocknycklarna. I vårt växande sortiment med över 3 000 produkter finns det garanterat rätt verktyg även för dig.', 'sv', 'Använder du skruvverktyg professionellt? Tror du att det är säkrare och roligare att arbeta med högkvalitativa och hållbara verktyg? Om du svarade ja, kan vi göra dig till en Tool Rebel!

Wera är en tysk tillverkare av skruvverktyg av högsta kvalitet. Vi kallar både oss själva och våra kunder för Tool Rebels. Vi är verktygsmarknadens rebeller. Vi går vår egen väg, ifrågasätter och utmanar befintliga standarder för att hjälpa dig att utföra ditt arbete enklare, snabbare och säkrare. Vi tror genuint att våra produkter oftare sätter ett leende på dina läppar än en svordom under arbetsdagen. Vi älskar innovationer. Vi älskar design. Vi älskar rockmusik.

Under årens lopp har vi utvecklat ett flertal geniala nyheter som Zyklop-spärrskaften och Joker-blocknycklarna. I vårt växande sortiment med över 3 000 produkter finns det garanterat rätt verktyg även för dig.'), 'https://www-de.wera.de/se', 'assets/images/exhibitors/nordbygg-2026-wera-tools-sweden-ab.jpg'),
  ('nordbygg-2026-exhibitor-134598', 'nordbygg-2026', 'WESAG', 'A04:21', null, 'https://www.wesag.se', 'assets/images/exhibitors/nordbygg-2026-wesag.jpg'),
  ('nordbygg-2026-exhibitor-138241', 'nordbygg-2026', 'Wide Industrier AS', 'A19:25', jsonb_build_object('en', 'Wide Industrier grundades 1996 som ett ingenjörsföretag med specialkompetens inom droppteknologi. Företagets huvudprodukt var redan från starten luftintagssystem, bestående av ventilationsgaller och filter för montering på yttervägg.
Med användning av ett egenutvecklat testlaboratorium, sannolikt ett av Europas mest avancerade, är Widerista marknadens mest effektiva ventilationsgaller.
Wides målsättning är att mekaniskt stoppa 100 % av regn och dimma med lägsta möjliga tryckfall. Ljudnivå har också varit viktig. Produkterna Wide har kan bevisligen stoppa 100 % av regn och vid hastigheter över ca 2 m/s även upp till 100 % av dimma. Tryckfall och ljudnivå är mycket låga.
Wide hade 2025 en omsättning på 38 miljoner. Den största kundgruppen är byggventilation och offshore', 'sv', 'Wide Industrier grundades 1996 som ett ingenjörsföretag med specialkompetens inom droppteknologi. Företagets huvudprodukt var redan från starten luftintagssystem, bestående av ventilationsgaller och filter för montering på yttervägg.
Med användning av ett egenutvecklat testlaboratorium, sannolikt ett av Europas mest avancerade, är Widerista marknadens mest effektiva ventilationsgaller.
Wides målsättning är att mekaniskt stoppa 100 % av regn och dimma med lägsta möjliga tryckfall. Ljudnivå har också varit viktig. Produkterna Wide har kan bevisligen stoppa 100 % av regn och vid hastigheter över ca 2 m/s även upp till 100 % av dimma. Tryckfall och ljudnivå är mycket låga.
Wide hade 2025 en omsättning på 38 miljoner. Den största kundgruppen är byggventilation och offshore'), 'https://www.wide.no', 'assets/images/exhibitors/nordbygg-2026-wide-industrier-as.jpg'),
  ('nordbygg-2026-exhibitor-140039', 'nordbygg-2026', 'WIDMO Spectral Technologies', 'C03:61', null, 'https://www.widmo.tech', 'assets/images/exhibitors/nordbygg-2026-widmo-spectral-technologies.jpg'),
  ('nordbygg-2026-exhibitor-140115', 'nordbygg-2026', 'Wiitta Oy', 'A04:02', jsonb_build_object('en', 'Wiitta Oy är en finländsk tillverkare av formsprutade plastprodukter med över 50 års erfarenhet av krävande produktion i Finland.

Vår kärnkompetens ligger i rördelar, som vi har tillverkat ända sedan företaget grundades. Våra produkter är designade för hållbarhet och tillförlitlig prestanda. Nordic Polymark-certifieringen garanterar jämn kvalitet och att alla krav uppfylls.

Vi betjänar kunder inom olika branscher med både standardprodukter och skräddarsydda lösningar, med ett flexibelt och långsiktigt förhållningssätt.

Utöver rördelar tillverkar vi konsumentprodukter under varumärket ”The Pulkka” och erbjuder såväl kontraktstillverkning som storskaliga lösningar inom 3D-printing.

Wiitta, en pålitlig partner inom plasttillverkning.

Varför välja Wiitta?

Tillverkning i Finland
Över 50 års erfarenhet
Jämn kvalitet och leveranssäkerhet
Flexibelt och kundorienterat samarbete', 'sv', 'Wiitta Oy är en finländsk tillverkare av formsprutade plastprodukter med över 50 års erfarenhet av krävande produktion i Finland.

Vår kärnkompetens ligger i rördelar, som vi har tillverkat ända sedan företaget grundades. Våra produkter är designade för hållbarhet och tillförlitlig prestanda. Nordic Polymark-certifieringen garanterar jämn kvalitet och att alla krav uppfylls.

Vi betjänar kunder inom olika branscher med både standardprodukter och skräddarsydda lösningar, med ett flexibelt och långsiktigt förhållningssätt.

Utöver rördelar tillverkar vi konsumentprodukter under varumärket ”The Pulkka” och erbjuder såväl kontraktstillverkning som storskaliga lösningar inom 3D-printing.

Wiitta, en pålitlig partner inom plasttillverkning.

Varför välja Wiitta?

Tillverkning i Finland
Över 50 års erfarenhet
Jämn kvalitet och leveranssäkerhet
Flexibelt och kundorienterat samarbete'), 'https://www.wiitta.fi', 'assets/images/exhibitors/nordbygg-2026-wiitta-oy.jpg'),
  ('nordbygg-2026-exhibitor-134012', 'nordbygg-2026', 'Wikells Byggberäkningar AB', 'C02:13', jsonb_build_object('en', 'Varje kalkyl du gör påverkar ditt företags ekonomi. Med Wikells kalkylverktyg är det enkelt att räkna på hur ett jobb ska prissättas för att ge den lönsamhet som behövs.
Tillsammans bygger vi affärer.

Med över 60 års erfarenhet har vi utvecklat kalkylverktyg som förenklar vardagen för entreprenörer, installatörer, projektörer, konsulter, kommuner, regioner och fastighetsbolag inom bygg, el och VVS.

Oavsett om du räknar på mindre jobb eller stora projekt finns ett verktyg som passar – anpassat efter din bransch, dina behov och ditt sätt att arbeta.', 'sv', 'Varje kalkyl du gör påverkar ditt företags ekonomi. Med Wikells kalkylverktyg är det enkelt att räkna på hur ett jobb ska prissättas för att ge den lönsamhet som behövs.
Tillsammans bygger vi affärer.

Med över 60 års erfarenhet har vi utvecklat kalkylverktyg som förenklar vardagen för entreprenörer, installatörer, projektörer, konsulter, kommuner, regioner och fastighetsbolag inom bygg, el och VVS.

Oavsett om du räknar på mindre jobb eller stora projekt finns ett verktyg som passar – anpassat efter din bransch, dina behov och ditt sätt att arbeta.'), 'https://www.wikells.se', 'assets/images/exhibitors/nordbygg-2026-wikells-byggberakningar-ab.jpg'),
  ('nordbygg-2026-exhibitor-138634', 'nordbygg-2026', 'Wiklunds Åkeri AB', 'C10:53', jsonb_build_object('en', 'Wiklunds är ett bolag med lång erfarenhet av lösningar för bygg-, fastighets- och anläggningssektorn. Vi arbetar nära våra kunder för att skapa funktionella, hållbara och kostnadseffektiva lösningar som möter både dagens och morgondagens krav.

En central del av vår verksamhet är satsningen inom KRETS – ett cirkulärt arbetssätt där vi fokuserar på återbruk, resurseffektivitet och minskad miljöpåverkan genom hela värdekedjan. Genom KRETS hjälper vi våra kunder att kombinera praktisk funktion med ökade hållbarhetskrav. Se mer på www.kretsaterbruk.se

Wiklunds är en del av en koncern med kompletterande kompetenser. Tillsammans med våra systerbolag Wiklunds Logistik, EDS Återvinning och CUWAB Verkstad kan vi erbjuda helhetslösningar som omfattar logistik, återvinning, verkstad och teknisk utveckling – från etablering till återbruk och avveckling.

På Nordbygg möter du Wiklunds för att diskutera cirkulära lösningar, effektiva byggarbetsplatser och hur vi tillsammans kan bidra till ett mer hållbart byggande.', 'sv', 'Wiklunds är ett bolag med lång erfarenhet av lösningar för bygg-, fastighets- och anläggningssektorn. Vi arbetar nära våra kunder för att skapa funktionella, hållbara och kostnadseffektiva lösningar som möter både dagens och morgondagens krav.

En central del av vår verksamhet är satsningen inom KRETS – ett cirkulärt arbetssätt där vi fokuserar på återbruk, resurseffektivitet och minskad miljöpåverkan genom hela värdekedjan. Genom KRETS hjälper vi våra kunder att kombinera praktisk funktion med ökade hållbarhetskrav. Se mer på www.kretsaterbruk.se

Wiklunds är en del av en koncern med kompletterande kompetenser. Tillsammans med våra systerbolag Wiklunds Logistik, EDS Återvinning och CUWAB Verkstad kan vi erbjuda helhetslösningar som omfattar logistik, återvinning, verkstad och teknisk utveckling – från etablering till återbruk och avveckling.

På Nordbygg möter du Wiklunds för att diskutera cirkulära lösningar, effektiva byggarbetsplatser och hur vi tillsammans kan bidra till ett mer hållbart byggande.'), 'https://www.wiklunds.se', 'assets/images/exhibitors/nordbygg-2026-wiklunds-akeri-ab.jpg'),
  ('nordbygg-2026-exhibitor-134723', 'nordbygg-2026', 'Wilfa', 'A19:28', jsonb_build_object('en', 'Sedan 1948 har Wilfa skapat kvalitetsprodukter med tydligt fokus på hållbarhet, innovativa lösningar och nordisk design. Som klimatleverantör erbjuder vi energieffektiva produkter som kombinerar hög prestanda med en design som ofta lyfts fram som Nordens snyggaste.

Varmt välkommen till vår monter, där vi visar våra värmepumpar utvecklade för nordiskt klimat och backade av marknadens längsta garanti på 7 år.', 'sv', 'Sedan 1948 har Wilfa skapat kvalitetsprodukter med tydligt fokus på hållbarhet, innovativa lösningar och nordisk design. Som klimatleverantör erbjuder vi energieffektiva produkter som kombinerar hög prestanda med en design som ofta lyfts fram som Nordens snyggaste.

Varmt välkommen till vår monter, där vi visar våra värmepumpar utvecklade för nordiskt klimat och backade av marknadens längsta garanti på 7 år.'), 'https://www.wilfa.se', 'assets/images/exhibitors/nordbygg-2026-wilfa.jpg'),
  ('nordbygg-2026-exhibitor-138978', 'nordbygg-2026', 'Wilms', 'C14:62', jsonb_build_object('en', 'Since 1975, we have been Wilms. A family business where well-being and innovation come together harmoniously. With roller shutters, sun protection and ventilation, we create a new dimension in extraordinary living comfort.

With Wilms, you choose durability, quality and innovation. Our roller shutters, sun protection and ventilation are cleverly developed and craftily produced in our factory in Belgium.', 'sv', 'Since 1975, we have been Wilms. A family business where well-being and innovation come together harmoniously. With roller shutters, sun protection and ventilation, we create a new dimension in extraordinary living comfort.

With Wilms, you choose durability, quality and innovation. Our roller shutters, sun protection and ventilation are cleverly developed and craftily produced in our factory in Belgium.'), 'https://www.wilms.se', 'assets/images/exhibitors/nordbygg-2026-wilms.jpg'),
  ('nordbygg-2026-exhibitor-135543', 'nordbygg-2026', 'WILO Nordic AB', 'A04:15', jsonb_build_object('en', 'WILO SE är med över 70 dotterbolag och en årlig omsättning på 22,4 miljarder SEK en världsledande tillverkare av pumpar och pumpsystem inom segmenten för cirkulation, tryckstegring och avlopp.
Med blicken riktad mot framtiden engagerar sig pumpföretaget starkt inom forskning och utveckling. Företaget med säte i Dortmund utvecklas mer och mer från komponentleverantör till systemleverantör.
Wilo erbjuder hållbara lösningar genom ett helhetsgrepp som omfattar produktion, energieffektivitet och proaktiv service. I produktionen arbetar Wilo systematiskt för att minska miljöpåverkan genom resurseffektiva processer, minskade utsläpp och ett ökat fokus på materialval med lång livslängd och återvinningsbarhet.', 'sv', 'WILO SE är med över 70 dotterbolag och en årlig omsättning på 22,4 miljarder SEK en världsledande tillverkare av pumpar och pumpsystem inom segmenten för cirkulation, tryckstegring och avlopp.
Med blicken riktad mot framtiden engagerar sig pumpföretaget starkt inom forskning och utveckling. Företaget med säte i Dortmund utvecklas mer och mer från komponentleverantör till systemleverantör.
Wilo erbjuder hållbara lösningar genom ett helhetsgrepp som omfattar produktion, energieffektivitet och proaktiv service. I produktionen arbetar Wilo systematiskt för att minska miljöpåverkan genom resurseffektiva processer, minskade utsläpp och ett ökat fokus på materialval med lång livslängd och återvinningsbarhet.'), 'https://www.wilo.se', 'assets/images/exhibitors/nordbygg-2026-wilo-nordic-ab.jpg'),
  ('nordbygg-2026-exhibitor-134372', 'nordbygg-2026', 'Winbag', 'B07:01', jsonb_build_object('en', 'WINBAG är ett danskutvecklat professionellt installationsverktyg som gör det enklare att lyfta, positionera och justera tunga komponenter med precision och kontroll. Produkten bygger på en uppblåsbar luftkudde som ersätter traditionella kilar och distanser, vilket förbättrar effektivitet, noggrannhet och säkerhet vid installationsarbete.

WINBAG utvecklades ursprungligen för montering av fönster och dörrar men används idag inom flera olika branscher, bland annat bygg, inredningsinstallation, fordonsapplikationer, industriell montering och räddningsinsatser. Dess mångsidighet, hållbarhet och användarvänlighet gör den till en uppskattad lösning bland yrkesproffs världen över.

WINBAG-produkterna är kända för hög kvalitet, tillförlitlighet och stark dansk designtradition. Idag distribueras varumärket internationellt och fortsätter att expandera genom samarbeten med professionella verktygsleverantörer och byggvaruhandelskedjor globalt.', 'sv', 'WINBAG är ett danskutvecklat professionellt installationsverktyg som gör det enklare att lyfta, positionera och justera tunga komponenter med precision och kontroll. Produkten bygger på en uppblåsbar luftkudde som ersätter traditionella kilar och distanser, vilket förbättrar effektivitet, noggrannhet och säkerhet vid installationsarbete.

WINBAG utvecklades ursprungligen för montering av fönster och dörrar men används idag inom flera olika branscher, bland annat bygg, inredningsinstallation, fordonsapplikationer, industriell montering och räddningsinsatser. Dess mångsidighet, hållbarhet och användarvänlighet gör den till en uppskattad lösning bland yrkesproffs världen över.

WINBAG-produkterna är kända för hög kvalitet, tillförlitlighet och stark dansk designtradition. Idag distribueras varumärket internationellt och fortsätter att expandera genom samarbeten med professionella verktygsleverantörer och byggvaruhandelskedjor globalt.'), 'https://winbag.eu/', 'assets/images/exhibitors/nordbygg-2026-winbag.jpg'),
  ('nordbygg-2026-exhibitor-139523', 'nordbygg-2026', 'WINTERSTEIGER Dry & Protect', 'BG:24', null, 'https://www.wintersteiger.com/dry-protect/sv', 'assets/images/exhibitors/nordbygg-2026-wintersteiger-dry-protect.jpg'),
  ('nordbygg-2026-exhibitor-140139', 'nordbygg-2026', 'WJAP', 'C13:33', null, 'https://www.wjap.pl/en', 'assets/images/exhibitors/nordbygg-2026-wjap.jpg'),
  ('nordbygg-2026-exhibitor-139448', 'nordbygg-2026', 'Wolf Bavaria GmbH', 'C02:51', null, 'https://www.wolf-bavaria.com', 'assets/images/exhibitors/nordbygg-2026-wolf-bavaria-gmbh.jpg'),
  ('nordbygg-2026-exhibitor-139846', 'nordbygg-2026', 'Wood Panel of Sweden', 'C15:22', null, 'https://woodpanelofsweden.com', 'assets/images/exhibitors/nordbygg-2026-wood-panel-of-sweden.jpg'),
  ('nordbygg-2026-exhibitor-139035', 'nordbygg-2026', 'Woodlife', 'C14:41', null, 'https://arbio.se/om-arbio', 'assets/images/exhibitors/nordbygg-2026-woodlife.jpg'),
  ('nordbygg-2026-exhibitor-137596', 'nordbygg-2026', 'Woolpower AB', 'B03:43', null, 'https://www.woolpower.se', null),
  ('nordbygg-2026-exhibitor-135008', 'nordbygg-2026', 'Work System', 'AG:111', jsonb_build_object('en', 'Work System erbjuder premiumlösningar till marknadens bästa pris och med marknadens bästa service. Med 100% fokus på bilutrustning, bilinredningar och tillbehör skapar vi ordning och reda för maximal effektivitet samt bästa arbetsmiljö och säkerhet för arbetsbilar.

Work System är en One-Stop-Shop, där man hittar allt man behöver i utrustningsväg för att skräddarsy sin arbetsbil. All inredning är uppbyggd genom ett modulärt koncept så att inredningslösningen kan anpassas exakt efter dina specifika behov. Vår prioritet är din arbetsbil och våra lösningar kan hjälpa till att göra din vardag säkrare och effektivare.', 'sv', 'Work System erbjuder premiumlösningar till marknadens bästa pris och med marknadens bästa service. Med 100% fokus på bilutrustning, bilinredningar och tillbehör skapar vi ordning och reda för maximal effektivitet samt bästa arbetsmiljö och säkerhet för arbetsbilar.

Work System är en One-Stop-Shop, där man hittar allt man behöver i utrustningsväg för att skräddarsy sin arbetsbil. All inredning är uppbyggd genom ett modulärt koncept så att inredningslösningen kan anpassas exakt efter dina specifika behov. Vår prioritet är din arbetsbil och våra lösningar kan hjälpa till att göra din vardag säkrare och effektivare.'), 'https://www.worksystem.se', 'assets/images/exhibitors/nordbygg-2026-work-system.jpg'),
  ('nordbygg-2026-exhibitor-139530', 'nordbygg-2026', 'WORKSOBER.COM', 'AG:94', null, 'https://www.ips.lt', null),
  ('nordbygg-2026-exhibitor-138153', 'nordbygg-2026', 'WUKO Maschinenbau GmbH', 'C19:31', null, 'https://www.wuko.at', 'assets/images/exhibitors/nordbygg-2026-wuko-maschinenbau-gmbh.jpg'),
  ('nordbygg-2026-exhibitor-138039', 'nordbygg-2026', 'X Workwear', 'B02:52', jsonb_build_object('en', 'X Workwear är uppstickaren som utvecklar och säljer egenutvecklade arbetskläder och arbetsskor direkt till yrkesproffs i hela Sverige via vår e-handel. Genom att plocka bort traditionella mellanhänder kan vi fokusera på funktion, passform och kvalitet, samtidigt som vi erbjuder ett mer konkurrenskraftigt pris utan att behöva kompromissa.

På Nordbygg 2026 hittar du oss i monter B02:52. Här visar vi produktnyheter, våra storsäljare och bjuder in till tävlingar. För oss handlar mässan lika mycket om att visa produkter som att lyssna och låta er vara med och påverka branschen framåt.

Till vardags möter vi våra kunder digitalt, vilket gör Nordbygg 2026 till ett av få tillfällen att uppleva våra produkter fysiskt. Följ resan mot Nordbygg i våra sociala medier, @xworkwear.

Kom förbi, säg hej och ta en pratstund med oss!', 'sv', 'X Workwear är uppstickaren som utvecklar och säljer egenutvecklade arbetskläder och arbetsskor direkt till yrkesproffs i hela Sverige via vår e-handel. Genom att plocka bort traditionella mellanhänder kan vi fokusera på funktion, passform och kvalitet, samtidigt som vi erbjuder ett mer konkurrenskraftigt pris utan att behöva kompromissa.

På Nordbygg 2026 hittar du oss i monter B02:52. Här visar vi produktnyheter, våra storsäljare och bjuder in till tävlingar. För oss handlar mässan lika mycket om att visa produkter som att lyssna och låta er vara med och påverka branschen framåt.

Till vardags möter vi våra kunder digitalt, vilket gör Nordbygg 2026 till ett av få tillfällen att uppleva våra produkter fysiskt. Följ resan mot Nordbygg i våra sociala medier, @xworkwear.

Kom förbi, säg hej och ta en pratstund med oss!'), 'https://xworkwear.com/se', 'assets/images/exhibitors/nordbygg-2026-x-workwear.jpg'),
  ('nordbygg-2026-exhibitor-140111', 'nordbygg-2026', 'X-Floc Dämmtechnik Maschinen GmbH', 'AG:106', null, 'https://www.x-floc.com/en', null),
  ('nordbygg-2026-exhibitor-137926', 'nordbygg-2026', 'Xella Sverige AB', 'C09:50', jsonb_build_object('en', 'Xella Sverige är en del av Xella Group, som är en europeisk leverantör av effektiva och hållbara vägglösningar för alla typer av byggprojekt. Xella står bakom välkända varumärken som Ytong, Silka, Hebel och Multipor och är en pionjär inom digitalt stödda byggprocesser. Våra produkter är baserade på mineralråvaror och möter behovet av effektivt byggande samt efterfrågan på hållbara bygglösningar. Koncernen driver innovation längs hela värdekedjan, från planering till produktion och montering. Xella förbättrar byggnaders hållbarhet under hela deras livscykel och bidrar till en koldioxidsnål industri som är kompatibel med en cirkulär ekonomi. Xella-koncernen har sitt huvudkontor i Duisburg i Tyskland och sysselsätter mer än 4 000 personer.', 'sv', 'Xella Sverige är en del av Xella Group, som är en europeisk leverantör av effektiva och hållbara vägglösningar för alla typer av byggprojekt. Xella står bakom välkända varumärken som Ytong, Silka, Hebel och Multipor och är en pionjär inom digitalt stödda byggprocesser. Våra produkter är baserade på mineralråvaror och möter behovet av effektivt byggande samt efterfrågan på hållbara bygglösningar. Koncernen driver innovation längs hela värdekedjan, från planering till produktion och montering. Xella förbättrar byggnaders hållbarhet under hela deras livscykel och bidrar till en koldioxidsnål industri som är kompatibel med en cirkulär ekonomi. Xella-koncernen har sitt huvudkontor i Duisburg i Tyskland och sysselsätter mer än 4 000 personer.'), 'https://www.xella.se', 'assets/images/exhibitors/nordbygg-2026-xella-sverige-ab.jpg'),
  ('nordbygg-2026-exhibitor-139668', 'nordbygg-2026', 'XMReality', 'A14:30', null, 'https://www.xmreality.se', 'assets/images/exhibitors/nordbygg-2026-xmreality.jpg'),
  ('nordbygg-2026-exhibitor-139171', 'nordbygg-2026', 'Xodor AB', 'A11:19', jsonb_build_object('en', 'Xodor AB – Framtidens lösningar för lukt  och bakteriekontroll i avluftningar o golvbrunnar.

På Xodor AB skapar vi nästa generations hållbara teknik för att eliminera bakterier och oönskade lukter – helt utan kemikalier. Vår unika patenterade filterteknik bygger på Sorbonite®, ett naturligt aktivt material med exceptionellt högt pH-värde som gör processen både effektiv och miljövänlig. Xodors produkter finns redan att beställa hos Ahlsell - se www.xodor.se hur beställning går till.

Med över 20 års forskning och utveckling i ryggen erbjuder vi produkter som löser verkliga problem för fastighetsägare, driftbolag och industrier – snabbt, enkelt och långsiktigt.
________________________________________
Varför Sorbonite®?

Naturligt. Kraftfullt. Pålitligt.
Sorbonite® utvecklades ursprungligen för rening av avloppsvatten, där det visade sig reducera bakterietillväxt mycket effektivt. Under forskningen upptäckte en professor vid KTH att materialet även har en stark förmåga att neutralisera både bakterier och odörer i luftmiljöer – en upptäckt som lade grunden till Xodor AB:s innovationer.

Idag är Sorbonite® kärnan i vår passiva cirkulära filterteknik – en metod som:

- Eliminerar bakterier
- Neutraliserar odörer
- Kräver ingen energi
- Inga rörliga delar som kan gå sönder
- Är helt fri från kemikalier
- Är enkel att installera
- Är kostnadseffektiv över tid
- Kan nyttjas av växter

________________________________________
Våra produkter – framtagen för verkliga problem

PCF Pipe

Ett smart och underhållsfritt system för att förhindra luktproblem från avluftningar såsom fettavskiljare och toaletter. PCF Pipe är också en ersättare till vakuumventiler som flera på marknaden efterfrågar.

DryDrain®

En innovativ lösning som skyddar uttorkade golvbrunnar från att sprida dålig lukt och bakterier– helt utan kemikalier eller rörliga delar.
Båda produkterna bygger på vår passiva filterteknik och är framtagna för att ge maximal effekt med minimal insats.
________________________________________
På väg ut på marknaden – med starka partners
Vi har redan etablerat oss hos ledande grossister och kontrakterat agenter som hjälper oss nå ut nationellt och internationellt.

Genom vårt samgående med VJU AB får vi dessutom en marknadsföringspartner som accelererar vår tillväxt och stärker vår position i branschen. Tillsammans tar vi innovativa, hållbara och kemikaliefria lösningar för bakterie-  och odörkontroll till en helt ny nivå.', 'sv', 'Xodor AB – Framtidens lösningar för lukt  och bakteriekontroll i avluftningar o golvbrunnar.

På Xodor AB skapar vi nästa generations hållbara teknik för att eliminera bakterier och oönskade lukter – helt utan kemikalier. Vår unika patenterade filterteknik bygger på Sorbonite®, ett naturligt aktivt material med exceptionellt högt pH-värde som gör processen både effektiv och miljövänlig. Xodors produkter finns redan att beställa hos Ahlsell - se www.xodor.se hur beställning går till.

Med över 20 års forskning och utveckling i ryggen erbjuder vi produkter som löser verkliga problem för fastighetsägare, driftbolag och industrier – snabbt, enkelt och långsiktigt.
________________________________________
Varför Sorbonite®?

Naturligt. Kraftfullt. Pålitligt.
Sorbonite® utvecklades ursprungligen för rening av avloppsvatten, där det visade sig reducera bakterietillväxt mycket effektivt. Under forskningen upptäckte en professor vid KTH att materialet även har en stark förmåga att neutralisera både bakterier och odörer i luftmiljöer – en upptäckt som lade grunden till Xodor AB:s innovationer.

Idag är Sorbonite® kärnan i vår passiva cirkulära filterteknik – en metod som:

- Eliminerar bakterier
- Neutraliserar odörer
- Kräver ingen energi
- Inga rörliga delar som kan gå sönder
- Är helt fri från kemikalier
- Är enkel att installera
- Är kostnadseffektiv över tid
- Kan nyttjas av växter

________________________________________
Våra produkter – framtagen för verkliga problem

PCF Pipe

Ett smart och underhållsfritt system för att förhindra luktproblem från avluftningar såsom fettavskiljare och toaletter. PCF Pipe är också en ersättare till vakuumventiler som flera på marknaden efterfrågar.

DryDrain®

En innovativ lösning som skyddar uttorkade golvbrunnar från att sprida dålig lukt och bakterier– helt utan kemikalier eller rörliga delar.
Båda produkterna bygger på vår passiva filterteknik och är framtagna för att ge maximal effekt med minimal insats.
________________________________________
På väg ut på marknaden – med starka partners
Vi har redan etablerat oss hos ledande grossister och kontrakterat agenter som hjälper oss nå ut nationellt och internationellt.

Genom vårt samgående med VJU AB får vi dessutom en marknadsföringspartner som accelererar vår tillväxt och stärker vår position i branschen. Tillsammans tar vi innovativa, hållbara och kemikaliefria lösningar för bakterie-  och odörkontroll till en helt ny nivå.'), 'https://www.xodor.se', 'assets/images/exhibitors/nordbygg-2026-xodor-ab.jpg'),
  ('nordbygg-2026-exhibitor-139909', 'nordbygg-2026', 'YSS ab', 'C05:53', jsonb_build_object('en', 'YSS AB – Ytskyddsspecialisterna

Ytskyddsspecialisterna är ett specialistföretag inom hygieniska och slitstarka golv- och ytskyddslösningar för industri, livsmedel, logistik och kommersiella miljöer. Vi projekterar och installerar moderna system i epoxi, polyuretan-cement och andra högpresterande beläggningar med fokus på funktion, hållbarhet och lång livslängd.

Med gedigen erfarenhet från produktionsmiljöer över hela Sverige hjälper vi våra kunder att skapa säkra, lättstädade och driftsäkra ytor som uppfyller höga krav på hygien och slitstyrka.

Vi arbetar nära våra kunder genom hela processen – från behovsanalys och teknisk rådgivning till färdig installation och uppföljning.', 'sv', 'YSS AB – Ytskyddsspecialisterna

Ytskyddsspecialisterna är ett specialistföretag inom hygieniska och slitstarka golv- och ytskyddslösningar för industri, livsmedel, logistik och kommersiella miljöer. Vi projekterar och installerar moderna system i epoxi, polyuretan-cement och andra högpresterande beläggningar med fokus på funktion, hållbarhet och lång livslängd.

Med gedigen erfarenhet från produktionsmiljöer över hela Sverige hjälper vi våra kunder att skapa säkra, lättstädade och driftsäkra ytor som uppfyller höga krav på hygien och slitstyrka.

Vi arbetar nära våra kunder genom hela processen – från behovsanalys och teknisk rådgivning till färdig installation och uppföljning.'), 'https://Www.yssab.se', 'assets/images/exhibitors/nordbygg-2026-yss-ab.jpg'),
  ('nordbygg-2026-exhibitor-140134', 'nordbygg-2026', 'Zaklad Kamieniarski Przywala Stones', 'C13:33', null, 'https://marmur.com.pl', 'assets/images/exhibitors/nordbygg-2026-zaklad-kamieniarski-przywala-stones.jpg'),
  ('nordbygg-2026-exhibitor-135553', 'nordbygg-2026', 'Zarges AB', 'B06:40', null, 'https://www.zarges.com/se', 'assets/images/exhibitors/nordbygg-2026-zarges-ab.jpg'),
  ('nordbygg-2026-exhibitor-140101', 'nordbygg-2026', 'Zavhy', 'C03:41', jsonb_build_object('en', 'Zavhy is a Dutch startup digitising and decarbonising construction through reinforced 3D concrete printing (3DCP) such as fabricating specialised bicycle bridges and landscape elements. We design, build, and operate the full technology stack in-house. Robotics, software, and materials. Enabling scalable, precision-engineered construction.

Our 3DCP microfactory with patented printhead systems integrates structural fibres, aggregates, and steel cable reinforcement directly during printing, enabling load-bearing construction. For bridges, facades, and infrastructure without formwork/moulds and with minimal waste.

Zavhy delivers measurable impact: up to 70% lower CO2 emissions, 60% faster flexible construction, and improved structural printed performance. Our technology is proven in practice. Our CEO contributed to the world’s first 3D-printed bridges and house in Europe.

With labour shortages, sustainability targets, and a focus on prefabrication, the Nordic region is a good fit for Zavhy’s scalable, low-carbon construction solutions.', 'sv', 'Zavhy is a Dutch startup digitising and decarbonising construction through reinforced 3D concrete printing (3DCP) such as fabricating specialised bicycle bridges and landscape elements. We design, build, and operate the full technology stack in-house. Robotics, software, and materials. Enabling scalable, precision-engineered construction.

Our 3DCP microfactory with patented printhead systems integrates structural fibres, aggregates, and steel cable reinforcement directly during printing, enabling load-bearing construction. For bridges, facades, and infrastructure without formwork/moulds and with minimal waste.

Zavhy delivers measurable impact: up to 70% lower CO2 emissions, 60% faster flexible construction, and improved structural printed performance. Our technology is proven in practice. Our CEO contributed to the world’s first 3D-printed bridges and house in Europe.

With labour shortages, sustainability targets, and a focus on prefabrication, the Nordic region is a good fit for Zavhy’s scalable, low-carbon construction solutions.'), 'https://zavhy.com', 'assets/images/exhibitors/nordbygg-2026-zavhy.jpg'),
  ('nordbygg-2026-exhibitor-138226', 'nordbygg-2026', 'Zego Tech Aps', 'A18:25', null, 'https://www.zegowater.dk               www.zegotech.dk', null),
  ('nordbygg-2026-exhibitor-139065', 'nordbygg-2026', 'ZERN ENGINEERING / BLAUBERG MOTOREN', 'A22:27', jsonb_build_object('en', 'ZERN ENGINEERING is a full-cycle manufacturer with over 15 years of experience in the field of energy-efficient ventilation technologies. We specialize in the development and production of counter-flow, cross-flow, enthalpy, and rotary air-to-air heat exchangers. BLAUBERG MOTOREN produce wide range of motors and fans with EC and AC technology for clients all around the world. It includes axial fans, backward curved fans, forward curved fans, blowers.', 'sv', 'ZERN ENGINEERING is a full-cycle manufacturer with over 15 years of experience in the field of energy-efficient ventilation technologies. We specialize in the development and production of counter-flow, cross-flow, enthalpy, and rotary air-to-air heat exchangers. BLAUBERG MOTOREN produce wide range of motors and fans with EC and AC technology for clients all around the world. It includes axial fans, backward curved fans, forward curved fans, blowers.'), null, 'assets/images/exhibitors/nordbygg-2026-zern-engineering-blauberg-motoren.jpg'),
  ('nordbygg-2026-exhibitor-139813', 'nordbygg-2026', 'Zhejiang Haozhuo', 'C15:61', null, 'https://www.sinomates.com', null),
  ('nordbygg-2026-exhibitor-139392', 'nordbygg-2026', 'ZIEHL-ABEGG', 'A22:18', jsonb_build_object('en', 'ZIEHL-ABEGG är en global ledare inom ventilations-, styr- och drivteknik med fokus på energieffektiva och hållbara lösningar för byggnader och industri.

Med över 110 års global erfarenhet och mer än 50 år i Sverige har ZIEHL-ABEGG byggt upp en djup kompetens och stark närvaro på marknaden. Sedan etableringen i Sverige på 1970-talet har vi varit en pålitlig partner inom ventilationslösningar och fortsatt att utvecklas tillsammans med våra kunder.

Med innovativ teknik och hög kvalitet utvecklar vi produkter som axial- och radialfläktar, elmotorer samt avancerade styrsystem – anpassade för allt från komfortventilation till komplexa industriella applikationer.

Vårt mål är att bidra till en mer hållbar framtid genom minskad energiförbrukning, lägre ljudnivåer och smartare systemlösningar. Genom kontinuerlig utveckling och nära samarbete med våra kunder skapar vi lösningar som möter morgondagens krav redan idag.

Besök vår monter för att upptäcka våra senaste innovationer – och hur över ett halvt sekels erfarenhet i Sverige kan hjälpa dig optimera dina ventilationslösningar.', 'sv', 'ZIEHL-ABEGG är en global ledare inom ventilations-, styr- och drivteknik med fokus på energieffektiva och hållbara lösningar för byggnader och industri.

Med över 110 års global erfarenhet och mer än 50 år i Sverige har ZIEHL-ABEGG byggt upp en djup kompetens och stark närvaro på marknaden. Sedan etableringen i Sverige på 1970-talet har vi varit en pålitlig partner inom ventilationslösningar och fortsatt att utvecklas tillsammans med våra kunder.

Med innovativ teknik och hög kvalitet utvecklar vi produkter som axial- och radialfläktar, elmotorer samt avancerade styrsystem – anpassade för allt från komfortventilation till komplexa industriella applikationer.

Vårt mål är att bidra till en mer hållbar framtid genom minskad energiförbrukning, lägre ljudnivåer och smartare systemlösningar. Genom kontinuerlig utveckling och nära samarbete med våra kunder skapar vi lösningar som möter morgondagens krav redan idag.

Besök vår monter för att upptäcka våra senaste innovationer – och hur över ett halvt sekels erfarenhet i Sverige kan hjälpa dig optimera dina ventilationslösningar.'), 'https://www.ziehl-abegg.se', 'assets/images/exhibitors/nordbygg-2026-ziehl-abegg.jpg'),
  ('nordbygg-2026-exhibitor-134021', 'nordbygg-2026', 'Zip-Up Svenska AB', 'UTE:02 (+2)', jsonb_build_object('en', 'Zip-Up – Sveriges förstahandsval för säkra liftar och byggställningar sedan 1978
Vi levererar kvalitet, service och trygghet till hela lift- och byggställningsbranschen. Hos oss hittar du allt du behöver för att arbeta säkert på höjd. Utforska vårt breda sortiment och hitta rätt lösning för dina behov.', 'sv', 'Zip-Up – Sveriges förstahandsval för säkra liftar och byggställningar sedan 1978
Vi levererar kvalitet, service och trygghet till hela lift- och byggställningsbranschen. Hos oss hittar du allt du behöver för att arbeta säkert på höjd. Utforska vårt breda sortiment och hitta rätt lösning för dina behov.'), 'https://www.zipup.se', null),
  ('nordbygg-2026-exhibitor-138786', 'nordbygg-2026', 'Zodiac Sverige AB', 'B10:10', null, 'https://www.zodiac.se', null),
  ('nordbygg-2026-exhibitor-138797', 'nordbygg-2026', 'Älvdalsfönster AB', 'C16:22', null, 'https://www.alvdalsfonster.se', 'assets/images/exhibitors/nordbygg-2026-alvdalsfonster-ab.jpg'),
  ('nordbygg-2026-exhibitor-139929', 'nordbygg-2026', 'ÖÖD OÜ', 'C03:51', null, 'https://oodhouse.com/en', null),
  ('estro-2026-exhibitor-radonicsolutions', 'estro-2026', 'Radonic Solutions', 'Stand 12', jsonb_build_object('en', 'Simulated exhibitor. Treatment planning systems and adaptive radiotherapy tools.', 'sv', 'Simulerad utställare. Dosplaneringssystem och verktyg för adaptiv strålbehandling.'), 'https://example.com/radonicsolutions', 'assets/images/exhibitors/estro-2026-radonicsolutions.svg'),
  ('estro-2026-exhibitor-northimaging', 'estro-2026', 'North Imaging', 'Stand 18', jsonb_build_object('en', 'Simulated exhibitor. On-treatment imaging and image guidance for radiation oncology.', 'sv', 'Simulerad utställare. Bildtagning under behandling och bildstyrning för strålterapi.'), 'https://example.com/northimaging', 'assets/images/exhibitors/estro-2026-northimaging.svg'),
  ('eha-2026-exhibitor-hematechnordic', 'eha-2026', 'Hematech Nordic', 'Stand 22', jsonb_build_object('en', 'Simulated exhibitor. Hematology diagnostics and laboratory instruments.', 'sv', 'Simulerad utställare. Hematologisk diagnostik och laboratorieinstrument.'), 'https://example.com/hematechnordic', 'assets/images/exhibitors/eha-2026-hematechnordic.svg')
on conflict (id) do update set
  name = excluded.name,
  booth = excluded.booth,
  description = excluded.description,
  website = excluded.website,
  logo = excluded.logo;

-- Points system: event-specific add-ons. ~3 rows per fully-seeded event
-- (Nordbygg 2026 and ESTRO 2026). Redeemable with points only; the
-- UI shows `stock` as advisory and does not decrement it in the
-- prototype. Images reuse each event's hero image as a stand-in —
-- same pattern used by news_items and articles — so the prototype
-- does not need new binary assets to render a card.
insert into public.point_addons (
  id, event_id, name, description, points_cost, image, stock, active
) values
  ('nordbygg-2026-addon-gift-bag', 'nordbygg-2026',
   jsonb_build_object('en', 'Exhibitor gift bag', 'sv', 'Utställargåvopåse'),
   jsonb_build_object('en', 'Simulated add-on. A curated canvas tote with samples, a sustainability guide, and a Nordbygg pin.', 'sv', 'Simulerat tillval. En kurerad tygkasse med varuprover, en hållbarhetsguide och en Nordbygg-pin.'),
   80, 'assets/images/events/nordbygg-2026.jpg', 50, true),
  ('nordbygg-2026-addon-sustainability-stage', 'nordbygg-2026',
   jsonb_build_object('en', 'Sustainability Stage seat reservation', 'sv', 'Sittplatsreservation, Hållbarhetsscenen'),
   jsonb_build_object('en', 'Simulated add-on. Reserves a front-row seat at the Sustainability Stage keynote on day one.', 'sv', 'Simulerat tillval. Reserverar en plats längst fram vid Hållbarhetsscenens huvudtal under dag ett.'),
   150, 'assets/images/events/nordbygg-2026.jpg', 20, true),
  ('nordbygg-2026-addon-catalog', 'nordbygg-2026',
   jsonb_build_object('en', 'Event catalog hardcover', 'sv', 'Evenemangskatalog inbunden'),
   jsonb_build_object('en', 'Simulated add-on. Hardcover copy of the Nordbygg 2026 catalog with exhibitor index and floor plan.', 'sv', 'Simulerat tillval. Inbundet exemplar av Nordbygg 2026-katalogen med utställarregister och planritning.'),
   120, 'assets/images/events/nordbygg-2026.jpg', null, true),
  ('estro-2026-addon-gift-bag', 'estro-2026',
   jsonb_build_object('en', 'Delegate gift bag', 'sv', 'Delegatgåvopåse'),
   jsonb_build_object('en', 'Simulated add-on. ESTRO 2026 delegate tote with abstracts booklet and sponsor samples.', 'sv', 'Simulerat tillval. ESTRO 2026 delegattygkasse med abstracthäfte och sponsorprover.'),
   80, 'assets/images/events/estro-2026.webp', 50, true),
  ('estro-2026-addon-vip-keynote', 'estro-2026',
   jsonb_build_object('en', 'VIP access to keynote', 'sv', 'VIP-tillträde till huvudtalet'),
   jsonb_build_object('en', 'Simulated add-on. Priority seating and a meet-and-greet slot after the opening keynote.', 'sv', 'Simulerat tillval. Förtursplats och meet-and-greet-pass efter öppningstalet.'),
   200, 'assets/images/events/estro-2026.webp', 10, true),
  ('estro-2026-addon-proceedings', 'estro-2026',
   jsonb_build_object('en', 'Proceedings hardcover', 'sv', 'Konferensrapport inbunden'),
   jsonb_build_object('en', 'Simulated add-on. Hardcover printing of the full ESTRO 2026 proceedings.', 'sv', 'Simulerat tillval. Inbunden tryckning av hela ESTRO 2026-konferensrapporten.'),
   150, 'assets/images/events/estro-2026.webp', null, true)
on conflict (id) do update set
  event_id = excluded.event_id,
  name = excluded.name,
  description = excluded.description,
  points_cost = excluded.points_cost,
  image = excluded.image,
  stock = excluded.stock,
  active = excluded.active;

-- Points system: venue-wide merchandise catalog. Independent of any
-- event (no `event_id`); reachable from `#/points` at any time.
insert into public.merchandise (
  id, name, description, points_cost, image, stock, active
) values
  ('merch-tote-bag',
   jsonb_build_object('en', 'Stockholmsmassan tote bag', 'sv', 'Stockholmsmässan-tygkasse'),
   jsonb_build_object('en', 'Simulated item. Sturdy canvas tote with the Stockholmsmassan wordmark.', 'sv', 'Simulerad artikel. Robust tygkasse med Stockholmsmässans ordmärke.'),
   120, 'assets/images/merchandise/tote-bag.svg', null, true),
  ('merch-cap',
   jsonb_build_object('en', 'Stockholmsmassan cap', 'sv', 'Stockholmsmässan-keps'),
   jsonb_build_object('en', 'Simulated item. Six-panel cap with embroidered Stockholmsmassan logo.', 'sv', 'Simulerad artikel. Sexpanelskeps med broderad Stockholmsmässan-logotyp.'),
   150, 'assets/images/merchandise/cap.svg', 100, true),
  ('merch-notebook',
   jsonb_build_object('en', 'Notebook', 'sv', 'Anteckningsbok'),
   jsonb_build_object('en', 'Simulated item. A5 hardcover notebook with numbered pages and a ribbon marker.', 'sv', 'Simulerad artikel. Inbunden A5-anteckningsbok med numrerade sidor och bokmärkesband.'),
   90, 'assets/images/merchandise/notebook.svg', null, true),
  ('merch-enamel-pin',
   jsonb_build_object('en', 'Enamel pin', 'sv', 'Emaljpin'),
   jsonb_build_object('en', 'Simulated item. Enamel pin with the Stockholmsmassan roundel.', 'sv', 'Simulerad artikel. Emaljpin med Stockholmsmässans cirkelmärke.'),
   60, 'assets/images/merchandise/enamel-pin.svg', 200, true)
on conflict (id) do update set
  name = excluded.name,
  description = excluded.description,
  points_cost = excluded.points_cost,
  image = excluded.image,
  stock = excluded.stock,
  active = excluded.active;

commit;
