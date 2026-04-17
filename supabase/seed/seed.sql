-- MassanApp prototype seed data.
--
-- Kept in sync by hand with web/data/catalog.json. The frontend can run
-- against either source; Supabase is the target once credentials are
-- configured, JSON is the local-dev fallback.
--
-- Venue facts are from public Stockholmsmassan sources (see
-- docs/research-stockholmsmassan-and-venue-apps.md). Per-event news,
-- articles, program items, exhibitors, and speakers below are clearly
-- simulated content scoped to this prototype.

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
    'summary', 'Alvsjo station is adjacent to Stockholmsmassan. Commuter trains from Stockholm City take about 9 minutes. Direct travel from Arlanda Airport to Alvsjo is also available.',
    'modes', jsonb_build_array(
      jsonb_build_object('mode', 'Commuter train', 'detail', 'SL pendeltag from Stockholm City stops directly at Alvsjo station in about 9 minutes.'),
      jsonb_build_object('mode', 'From Arlanda Airport', 'detail', 'Direct services from Arlanda to Alvsjo are available without changing in central Stockholm.'),
      jsonb_build_object('mode', 'Bus', 'detail', 'Several SL bus lines stop at Alvsjo stationsplan, which is a short walk from the main entrance.'),
      jsonb_build_object('mode', 'Bike', 'detail', 'Marked cycle paths connect Alvsjo to central Stockholm. Covered bike parking is available near the main entrance.')
    )
  ),
  jsonb_build_object(
    'summary', 'About 2,000 parking spaces on site, additional nearby overflow parking, and EV charging.',
    'onsite_spaces', 2000,
    'ev_charging', true,
    'notes', 'Parking is paid and fills quickly during large trade fairs and congresses. Pre-booking is recommended for events with heavy visitor volumes.'
  ),
  jsonb_build_array(
    jsonb_build_object('name', 'Restaurant Rattvik', 'description', 'Full-service on-site restaurant serving lunch during events.'),
    jsonb_build_object('name', 'Cafe Kista', 'description', 'Coffee, pastries, and quick lunch options near the main foyer.'),
    jsonb_build_object('name', 'Bistro Nordic', 'description', 'Seasonal a-la-carte menu oriented to business lunches and congress delegates.'),
    jsonb_build_object('name', 'Hall Cafeteria East', 'description', 'Buffet-style cafeteria close to the East Halls for peak-lunch throughput.'),
    jsonb_build_object('name', 'Hall Cafeteria West', 'description', 'Buffet-style cafeteria close to the West Halls.'),
    jsonb_build_object('name', 'Espresso Bar Foyer', 'description', 'Quick espresso and grab-and-go snacks inside the main foyer.')
  ),
  jsonb_build_object(
    'summary', 'Stockholmsmassan is the first exhibition venue in Sweden certified to the SHORE safety standard. Bag checks, access control, and event-specific entry procedures are in place.',
    'general_rules', jsonb_build_array(
      'Bags are subject to visual inspection at entry.',
      'Oversize luggage should be left at the cloakroom or returned to a hotel.',
      'Follow staff and signage regarding special entrances for specific events.',
      'Report anything suspicious to on-site security; emergency exits are marked throughout the venue.'
    )
  ),
  'Stockholmsmassan is ISO 20121 certified and runs an active sustainability program spanning energy, waste, catering, and supplier choices.',
  jsonb_build_array(
    jsonb_build_object(
      'id', 'stockholmsmassan-overview',
      'name', 'Venue overview',
      'description', 'High-level map showing entrances, halls, foyers, and conference rooms. Rendered inline in the prototype as a placeholder graphic.'
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
  start_date, end_date, summary, branding, overrides
) values
  (
    'nordbygg-2026', 'stockholmsmassan', 'Nordbygg 2026', 'Nordic construction trade fair',
    'Trade fair', 'Construction and real estate', 'public', 'public_ticket',
    date '2026-04-21', date '2026-04-24',
    'Nordbygg is the leading Nordic meeting place for the construction and real-estate industry, with exhibitors, seminars, and industry news across four days at Stockholmsmassan.',
    jsonb_build_object('primary_color', '#0b3d91', 'accent_color', '#f4b400', 'logo', null),
    jsonb_build_object(
      'entrance', 'Enter through the main foyer at Stockholmsmassan. Nordbygg signage guides visitors to registration in the A-Hall foyer.',
      'bag_rules', 'Work bags and smaller backpacks are allowed on the fair floor; oversize luggage should be checked at the cloakroom.',
      'access_notes', 'A visitor ticket grants access to all exhibition halls and seminar rooms. Some seminars have limited seating on a first-come basis.'
    )
  ),
  (
    'estro-2026', 'stockholmsmassan', 'ESTRO 2026', 'European Society for Radiotherapy and Oncology Annual Congress',
    'Congress', 'Health & Medicine', 'professional', 'registration',
    date '2026-05-15', date '2026-05-19',
    'ESTRO 2026 is the European Society for Radiotherapy and Oncology annual congress, covering clinical practice, physics, radiobiology, and technology across a multi-track program.',
    jsonb_build_object('primary_color', '#123f66', 'accent_color', '#ce3f4a', 'logo', null),
    jsonb_build_object(
      'entrance', 'Registration and badge pickup for ESTRO 2026 are located in the North Foyer. Delegates should bring photo ID on the first day.',
      'bag_rules', 'Standard venue bag rules apply; congress materials are distributed at the registration desk.',
      'access_notes', 'Access is restricted to registered delegates, exhibitors, and accredited media. Sessions marked as closed require additional access codes.'
    )
  ),
  (
    'eha-2026', 'stockholmsmassan', 'EHA2026 Congress', 'European Hematology Association Annual Congress',
    'Congress', 'Health & Medicine', 'professional', 'registration',
    date '2026-06-11', date '2026-06-14',
    'The European Hematology Association annual congress brings clinicians and researchers together for plenaries, symposia, abstract presentations, and an industry exhibition.',
    jsonb_build_object('primary_color', '#8a1f57', 'accent_color', '#f5b233', 'logo', null),
    jsonb_build_object(
      'entrance', 'EHA2026 delegates enter through the East Foyer. Congress badges are required for all sessions.',
      'bag_rules', 'Standard venue bag rules apply. Poster tubes and rollable cases are accommodated at the cloakroom.',
      'access_notes', 'On-demand session recordings are available to registered delegates on the EHA congress platform after the congress.'
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

insert into public.news_items (id, event_id, published_at, title, body) values
  ('nordbygg-2026-news-exhibitors-crossed', 'nordbygg-2026', timestamptz '2026-03-02T09:00:00Z',
   'Nordbygg 2026 exhibitor registrations cross 700',
   'Simulated. Nordbygg reports that more than 700 exhibitors have confirmed attendance, spanning sustainable materials, prefabrication, building services, and digital tools for the construction industry.'),
  ('nordbygg-2026-news-sustainability-stage', 'nordbygg-2026', timestamptz '2026-03-18T09:00:00Z',
   'Sustainability stage program finalized',
   'Simulated. The Sustainability Stage program for Nordbygg 2026 covers circular construction, low-carbon concrete, and energy retrofits. All sessions are open to fair visitors without extra registration.'),
  ('nordbygg-2026-news-safety-workshop', 'nordbygg-2026', timestamptz '2026-04-01T09:00:00Z',
   'Site-safety workshops added to day three',
   'Simulated. Day three of the fair adds hands-on workshops on site-safety equipment, PPE, and fall-protection. Capacity is limited and managed at the workshop entrance.'),
  ('nordbygg-2026-news-ticket-pickup', 'nordbygg-2026', timestamptz '2026-04-14T09:00:00Z',
   'Ticket pickup and visitor tips for opening day',
   'Simulated. Visitors are encouraged to pre-register and use mobile tickets to skip the queues at opening. Coffee will be available in the main foyer from 8:00.'),
  ('estro-2026-news-late-breaking', 'estro-2026', timestamptz '2026-04-05T09:00:00Z',
   'Late-breaking abstract window closes',
   'Simulated. The late-breaking abstract submission window for ESTRO 2026 has closed. Accepted late-breakers will be added to the searchable program next week.'),
  ('estro-2026-news-industry-symposia', 'estro-2026', timestamptz '2026-04-20T09:00:00Z',
   'Industry symposia and hands-on demos announced',
   'Simulated. Industry symposia and hands-on demos for ESTRO 2026 have been published in the congress program. Delegates can filter their personal agenda to include or exclude industry content.'),
  ('eha-2026-news-platform-open', 'eha-2026', timestamptz '2026-05-05T09:00:00Z',
   'EHA2026 congress platform opens to registered delegates',
   'Simulated. The EHA2026 congress platform is now available to registered delegates, with networking, profile setup, and the full searchable program.')
on conflict (id) do update set
  title = excluded.title,
  body = excluded.body,
  published_at = excluded.published_at;

insert into public.articles (id, event_id, title, body, hero_image) values
  ('nordbygg-2026-article-why-attend', 'nordbygg-2026',
   'Why Nordbygg 2026 is the Nordic construction meeting point',
   'Simulated. Nordbygg collects the Nordic construction and real-estate industry under one roof at Stockholmsmassan: manufacturers, consultants, architects, developers, and public-sector procurement teams. The fair combines an exhibitor floor, a seminar program, and dedicated stages for sustainability and digital tools. Visitors use the fair to benchmark products, meet suppliers in person, and get an overview of emerging regulation.',
   null),
  ('nordbygg-2026-article-what-to-see', 'nordbygg-2026',
   'What to see on a one-day visit',
   'Simulated. If you only have one day at Nordbygg 2026, focus on the Sustainability Stage in the morning, spend midday on the exhibitor floor around the prefabrication and building-services areas, and close the day with a site-safety workshop or a digital-tools demo. The event-first app view lets you save a short list of exhibitors to visit on the floor.',
   null),
  ('estro-2026-article-program-highlights', 'estro-2026',
   'ESTRO 2026 program highlights',
   'Simulated. The ESTRO 2026 program covers clinical radiation oncology, medical physics, radiobiology, brachytherapy, and technology and innovation tracks. Plenary sessions open and close each day, with parallel tracks and poster sessions filling the rest of the schedule. Delegates are encouraged to build a personal agenda before the congress opens.',
   null)
on conflict (id) do update set
  title = excluded.title,
  body = excluded.body,
  hero_image = excluded.hero_image;

insert into public.speakers (id, name, bio, affiliation, avatar) values
  ('estro-2026-speaker-lindqvist', 'Dr. Eva Lindqvist',
   'Simulated speaker profile. Radiation oncologist focused on adaptive radiotherapy.',
   'Karolinska University Hospital', null),
  ('estro-2026-speaker-morales', 'Dr. Luis Morales',
   'Simulated speaker profile. Clinical researcher in head-and-neck radiation oncology.',
   'Hospital Clinic de Barcelona', null),
  ('estro-2026-speaker-bergstrom', 'Dr. Anna Bergstrom',
   'Simulated speaker profile. Medical physicist focused on dose calculation and QA.',
   'Uppsala University Hospital', null)
on conflict (id) do update set
  name = excluded.name,
  bio = excluded.bio,
  affiliation = excluded.affiliation;

insert into public.program_items (
  id, event_id, day, start_time, end_time, title, description, location, track, speaker_ids
) values
  ('nordbygg-2026-program-opening', 'nordbygg-2026', date '2026-04-21', time '09:00', time '09:30',
   'Opening and industry welcome',
   'Simulated. Official opening of Nordbygg 2026 with remarks from industry and venue representatives.',
   'Main Stage, A-Hall', 'Keynote', '{}'),
  ('nordbygg-2026-program-low-carbon-concrete', 'nordbygg-2026', date '2026-04-21', time '10:00', time '11:00',
   'Low-carbon concrete in practice',
   'Simulated. Practitioner panel on low-carbon concrete mixes and procurement practices in Nordic construction projects.',
   'Sustainability Stage, B-Hall', 'Sustainability', '{}'),
  ('nordbygg-2026-program-circular-construction', 'nordbygg-2026', date '2026-04-21', time '13:00', time '14:00',
   'Circular construction from design to demolition',
   'Simulated. Case studies from Nordic developers on circular construction, material reuse, and end-of-life planning.',
   'Sustainability Stage, B-Hall', 'Sustainability', '{}'),
  ('nordbygg-2026-program-prefab', 'nordbygg-2026', date '2026-04-22', time '10:00', time '11:00',
   'Prefabrication and industrialized building',
   'Simulated. Current state of prefabricated construction systems in the Nordic market and what large public projects are adopting.',
   'Main Stage, A-Hall', 'Industry', '{}'),
  ('nordbygg-2026-program-digital-tools', 'nordbygg-2026', date '2026-04-22', time '11:30', time '12:30',
   'Digital tools on site',
   'Simulated. Live demos of site-management, BIM, and field-reporting tools relevant to Nordic contractors and consultants.',
   'Digital Stage, C-Hall', 'Digital', '{}'),
  ('nordbygg-2026-program-procurement', 'nordbygg-2026', date '2026-04-22', time '14:00', time '15:00',
   'Sustainable procurement in the public sector',
   'Simulated. How Nordic municipalities and public-sector developers are integrating climate, circularity, and social criteria into procurement.',
   'Sustainability Stage, B-Hall', 'Sustainability', '{}'),
  ('nordbygg-2026-program-safety-workshop', 'nordbygg-2026', date '2026-04-23', time '10:00', time '11:30',
   'Hands-on site safety workshop',
   'Simulated. Hands-on workshop on PPE, fall-protection, and incident response on construction sites. Capacity is limited and managed at the workshop entrance.',
   'Workshop Room 3, C-Hall', 'Safety', '{}'),
  ('nordbygg-2026-program-energy-retrofits', 'nordbygg-2026', date '2026-04-23', time '13:00', time '14:00',
   'Energy retrofits at scale',
   'Simulated. Case studies from Nordic property owners on large-scale energy retrofits, financing, and tenant communication.',
   'Main Stage, A-Hall', 'Industry', '{}'),
  ('nordbygg-2026-program-networking', 'nordbygg-2026', date '2026-04-23', time '16:00', time '18:00',
   'Industry networking reception',
   'Simulated. Evening networking reception for exhibitors and registered industry visitors in the main foyer.',
   'Main Foyer', 'Networking', '{}'),
  ('nordbygg-2026-program-closing-panel', 'nordbygg-2026', date '2026-04-24', time '13:00', time '14:00',
   'Closing panel and 2027 outlook',
   'Simulated. Closing panel reflecting on the 2026 edition and previewing the Nordic construction outlook for 2027.',
   'Main Stage, A-Hall', 'Keynote', '{}'),

  ('estro-2026-program-opening-plenary', 'estro-2026', date '2026-05-15', time '09:00', time '10:00',
   'Opening plenary',
   'Simulated. Opening plenary of ESTRO 2026 with state-of-the-art lectures across radiation oncology.',
   'Auditorium North', 'Plenary', '{estro-2026-speaker-lindqvist}'),
  ('estro-2026-program-clinical-track', 'estro-2026', date '2026-05-15', time '11:00', time '12:30',
   'Clinical track: adaptive radiotherapy',
   'Simulated. Parallel clinical session on adaptive radiotherapy workflows and outcomes.',
   'Room 210', 'Clinical', '{estro-2026-speaker-morales}'),
  ('estro-2026-program-physics-track', 'estro-2026', date '2026-05-16', time '09:00', time '10:30',
   'Physics track: dose calculation and QA',
   'Simulated. Parallel physics session on dose calculation advances and treatment quality assurance.',
   'Room 220', 'Physics', '{estro-2026-speaker-bergstrom}'),
  ('estro-2026-program-radiobiology-track', 'estro-2026', date '2026-05-16', time '13:00', time '14:30',
   'Radiobiology track: combination therapies',
   'Simulated. Parallel radiobiology session on combining radiation with systemic therapies.',
   'Room 230', 'Radiobiology', '{}'),
  ('estro-2026-program-poster-session', 'estro-2026', date '2026-05-17', time '12:30', time '14:00',
   'Poster session A',
   'Simulated. First poster session with authors present at their posters on the exhibition floor.',
   'Exhibition Hall', 'Posters', '{}'),
  ('estro-2026-program-industry-symposium', 'estro-2026', date '2026-05-18', time '12:45', time '13:45',
   'Industry symposium: imaging advances',
   'Simulated. Sponsored industry symposium on imaging advances in radiation oncology.',
   'Auditorium East', 'Industry', '{}'),
  ('estro-2026-program-closing', 'estro-2026', date '2026-05-19', time '15:00', time '16:00',
   'Closing ceremony',
   'Simulated. Closing ceremony and awards for ESTRO 2026.',
   'Auditorium North', 'Plenary', '{}'),

  ('eha-2026-program-opening-plenary', 'eha-2026', date '2026-06-11', time '09:00', time '10:00',
   'Opening plenary',
   'Simulated. Opening plenary of the EHA2026 congress with keynote lectures on hematology research.',
   'Auditorium North', 'Plenary', '{}'),
  ('eha-2026-program-symposium', 'eha-2026', date '2026-06-12', time '11:00', time '12:30',
   'Symposium: lymphoid malignancies',
   'Simulated. Multi-presenter symposium on advances in lymphoid malignancy treatment.',
   'Room 310', 'Clinical', '{}'),
  ('eha-2026-program-late-breaker', 'eha-2026', date '2026-06-13', time '14:00', time '15:30',
   'Late-breaking abstracts',
   'Simulated. Late-breaking abstract session with oral presentations selected for high impact.',
   'Auditorium North', 'Late-breaking', '{}'),
  ('eha-2026-program-poster-walks', 'eha-2026', date '2026-06-13', time '12:30', time '14:00',
   'Poster walks',
   'Simulated. Guided poster walks through selected abstracts, with authors present.',
   'Exhibition Hall', 'Posters', '{}'),
  ('eha-2026-program-closing', 'eha-2026', date '2026-06-14', time '15:30', time '16:30',
   'Closing ceremony',
   'Simulated. Closing ceremony with awards and 2027 preview.',
   'Auditorium North', 'Plenary', '{}')
on conflict (id) do update set
  day = excluded.day,
  start_time = excluded.start_time,
  end_time = excluded.end_time,
  title = excluded.title,
  description = excluded.description,
  location = excluded.location,
  track = excluded.track,
  speaker_ids = excluded.speaker_ids;

insert into public.exhibitors (id, event_id, name, booth, description, website, logo) values
  ('nordbygg-2026-exhibitor-nordicpanel', 'nordbygg-2026', 'NordicPanel Systems', 'A12',
   'Simulated exhibitor. Prefabricated wall and roof systems for Nordic residential and commercial projects.',
   'https://example.com/nordicpanel', null),
  ('nordbygg-2026-exhibitor-betoncircular', 'nordbygg-2026', 'BetonCircular', 'A14',
   'Simulated exhibitor. Low-carbon and recycled-content concrete for infrastructure and residential projects.',
   'https://example.com/betoncircular', null),
  ('nordbygg-2026-exhibitor-bytetools', 'nordbygg-2026', 'ByteTools Site', 'C22',
   'Simulated exhibitor. Field-reporting and BIM coordination tools for construction sites.',
   'https://example.com/bytetools', null),
  ('nordbygg-2026-exhibitor-fjordwin', 'nordbygg-2026', 'FjordWin Windows', 'B08',
   'Simulated exhibitor. Triple-glazed windows designed for Nordic climates.',
   'https://example.com/fjordwin', null),
  ('nordbygg-2026-exhibitor-kalmarpipe', 'nordbygg-2026', 'KalmarPipe', 'B10',
   'Simulated exhibitor. Plumbing and building-services solutions for large residential projects.',
   'https://example.com/kalmarpipe', null),
  ('nordbygg-2026-exhibitor-greenroofsnordic', 'nordbygg-2026', 'GreenRoofs Nordic', 'B24',
   'Simulated exhibitor. Green-roof and stormwater retention systems for urban projects.',
   'https://example.com/greenroofsnordic', null),
  ('nordbygg-2026-exhibitor-safeliftnordic', 'nordbygg-2026', 'SafeLift Nordic', 'C12',
   'Simulated exhibitor. Fall-protection, site-safety PPE, and training services.',
   'https://example.com/safeliftnordic', null),
  ('nordbygg-2026-exhibitor-boreasinsulation', 'nordbygg-2026', 'Boreas Insulation', 'A22',
   'Simulated exhibitor. High-performance insulation for passive-house and retrofit projects.',
   'https://example.com/boreasinsulation', null),
  ('nordbygg-2026-exhibitor-voltagridhvac', 'nordbygg-2026', 'VoltaGrid HVAC', 'B30',
   'Simulated exhibitor. Electrified heating, ventilation, and air-conditioning systems.',
   'https://example.com/voltagridhvac', null),
  ('nordbygg-2026-exhibitor-sagasurveys', 'nordbygg-2026', 'Saga Surveys', 'C30',
   'Simulated exhibitor. Drone-based site surveys and as-built 3D scanning.',
   'https://example.com/sagasurveys', null),
  ('nordbygg-2026-exhibitor-lundwoodworks', 'nordbygg-2026', 'Lund Woodworks', 'A30',
   'Simulated exhibitor. Engineered timber and cross-laminated timber components.',
   'https://example.com/lundwoodworks', null),
  ('nordbygg-2026-exhibitor-gridlinepower', 'nordbygg-2026', 'GridLine Power', 'C14',
   'Simulated exhibitor. Site power distribution, temporary grid solutions, and EV charging for construction sites.',
   'https://example.com/gridlinepower', null),
  ('estro-2026-exhibitor-radonicsolutions', 'estro-2026', 'Radonic Solutions', 'Stand 12',
   'Simulated exhibitor. Treatment planning systems and adaptive radiotherapy tools.',
   'https://example.com/radonicsolutions', null),
  ('estro-2026-exhibitor-northimaging', 'estro-2026', 'North Imaging', 'Stand 18',
   'Simulated exhibitor. On-treatment imaging and image guidance for radiation oncology.',
   'https://example.com/northimaging', null),
  ('eha-2026-exhibitor-hematechnordic', 'eha-2026', 'Hematech Nordic', 'Stand 22',
   'Simulated exhibitor. Hematology diagnostics and laboratory instruments.',
   'https://example.com/hematechnordic', null)
on conflict (id) do update set
  name = excluded.name,
  booth = excluded.booth,
  description = excluded.description,
  website = excluded.website,
  logo = excluded.logo;

commit;
