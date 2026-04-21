// UI translations for the prototype. Only the app chrome is
// translated — event content (news, articles, program, exhibitor
// copy) remains in the language it was seeded in. See the
// internationalization section of docs/functional-specification.md.
//
// Adding a new key: add it to both `en` and `sv` entries. When a key
// is missing from the active locale the English copy is used as the
// fallback so a half-translated build still renders.

export const SUPPORTED_LANGUAGES = ["en", "sv"];
export const DEFAULT_LANGUAGE = "en";

export const LANGUAGE_LABELS = {
  en: "English",
  sv: "Svenska",
};

// Locale tags used by Intl APIs when formatting dates. Swedish uses
// `sv-SE` so weekday and month names render in Swedish.
export const DATE_LOCALES = {
  en: "en-GB",
  sv: "sv-SE",
};

const TRANSLATIONS = {
  en: {
    "sim.chip": "simulated",

    "chrome.events": "Events",
    "chrome.lang_aria": "Language",
    "chrome.me_aria": "My Pages",
    "chrome.nav_aria": "Menu",
    "chrome.nav.start": "Start",
    "chrome.nav.my_tickets": "My tickets",
    "chrome.nav.food": "Food",
    "chrome.nav.program": "Program",
    "chrome.nav.exhibitors": "Exhibitors",
    "chrome.nav.practical": "Practical information",
    "chrome.nav.other_events": "Other events",
    "chrome.nav.my_pages": "My pages",

    "title.events": "Events",
    "title.sign_in": "Sign in",
    "title.my_pages": "My Pages",
    "title.my_tickets": "My Tickets",
    "title.get_tickets": "Get tickets",
    "title.get_tickets_for": "Get tickets · {name}",
    "title.points_shop": "Points shop",
    "title.event_default": "Event",
    "title.app_default": "MassanApp",

    "calendar.search_placeholder": "Search events",
    "calendar.search_label": "Search events",
    "calendar.type_label": "Type",
    "calendar.category_label": "Category",
    "calendar.month_label": "Month",
    "calendar.all_types": "All types",
    "calendar.all_categories": "All categories",
    "calendar.all_months": "All months",
    "calendar.loading": "Loading events…",
    "calendar.load_error": "Could not load events: {error}",
    "calendar.no_match": "No events match the current filters.",

    "event.pick_section": "Pick a section above to explore this event.",
    "event.no_news": "No news yet for this event.",
    "event.no_articles": "No articles yet for this event.",
    "event.no_program": "No program published yet for this event.",
    "event.speakers_prefix": "Speakers: ",
    "event.booth_prefix": "Booth ",
    "event.search_exhibitors_label": "Search exhibitors",
    "event.search_exhibitors_placeholder": "Search exhibitors",
    "event.no_exhibitor_match": "No exhibitors match your search.",
    "event.back_exhibitors": "Back to exhibitors",
    "event.exhibitor_not_found": "Exhibitor not found.",
    "event.hero_image_alt": "{name} hero image",
    "event.image_credit_prefix": "Image: ",
    "event.news_image_alt": "{name}",
    "event.article_image_alt": "{title}",
    "event.exhibitor_logo_alt": "{name} logo",
    "event.speaker_avatar_alt": "{name}",
    "event.view_ticket": "View ticket",
    "event.not_found": "Event not found. Return to the calendar.",
    "event.sections_nav_aria": "Event sections",
    "event.see_all_news": "All news ({count})",
    "event.see_all_articles": "All articles ({count})",
    "event.see_all_program": "Full program ({count})",
    "event.see_all_exhibitors": "All exhibitors ({count})",
    "event.see_all_food": "Order food",
    "event.back_to_event": "Back to event",

    "event.addons_title": "Event add-ons",
    "event.addons_intro":
      "Points-only extras for ticket holders. Simulated — no physical item is produced.",
    "event.addons_image_alt": "{name}",
    "event.addons_cost": "{cost} points",
    "event.addons_stock": "{count} left",
    "event.addons_redeem": "Redeem",
    "event.addons_redeeming": "Redeeming…",
    "event.addons_insufficient_balance":
      "You need {cost} points to redeem this.",
    "event.addons_sold_out": "Sold out for this session.",
    "event.addons_confirmed": "Add-on redeemed",
    "event.addons_confirmed_body":
      "You redeemed {name} for {cost} points.",
    "event.addons_dismiss": "Dismiss",
    "event.addons_err_generic": "Could not redeem this add-on.",

    "sections.news": "News",
    "sections.articles": "Articles",
    "sections.program": "Program",
    "sections.exhibitors": "Exhibitors",
    "sections.practical": "Practical info",
    "sections.food": "Food",
    "sections.newsletter": "Newsletter",

    "practical.getting_here": "Getting here",
    "practical.parking": "Parking",
    "practical.restaurants": "Restaurants and cafes",
    "practical.security": "Security and entry",
    "practical.maps": "Venue maps",
    "practical.overrides": "Notes for this event",

    "overrides.entrance": "Entrance",
    "overrides.bag_rules": "Bag rules",
    "overrides.access_notes": "Access notes",

    "newsletter.signup_intro_prefix": "Get updates about ",
    "newsletter.signup_intro_suffix":
      " by email. Your subscription is saved to the shared prototype database. The confirmation email is simulated — no mail is actually sent.",
    "newsletter.topics_legend": "I want to hear about",
    "newsletter.signup_submit": "Sign up for updates",
    "newsletter.success_title": "You're signed up.",
    "newsletter.success_prefix": "We'll send updates to ",
    "newsletter.success_about": " about ",
    "newsletter.edit": "Edit preferences",

    "newsletter.prefs_title": "Newsletter preferences",
    "newsletter.prefs_empty":
      "No newsletter subscriptions yet. Visit an event and open its Newsletter tab to sign up.",
    "newsletter.prefs_load_error":
      "Could not load your newsletter preferences: {error}",
    "newsletter.venue_wide": "All Stockholmsmassan events",
    "newsletter.venue_wide_hint": "Receive venue-wide announcements.",
    "newsletter.unsubscribe": "Unsubscribe",

    "newsletter.topic.program_highlights": "Program highlights",
    "newsletter.topic.news": "News",
    "newsletter.topic.exhibitor_updates": "Exhibitor updates",

    "auth.tab_signin": "Sign in",
    "auth.tab_register": "Register",
    "auth.email": "Email",
    "auth.display_name": "Display name",
    "auth.password": "Password",
    "auth.submit_signin": "Sign in",
    "auth.submit_register": "Create account",
    "auth.working": "Working…",
    "auth.or": "or",
    "auth.continue_google": "Continue with Google",
    "auth.continue_microsoft": "Continue with Microsoft",
    "auth.generic_error": "Something went wrong.",
    "auth.mode_tablist_aria": "Auth mode",
    "auth.err_email_required": "Enter an email address.",
    "auth.err_confirm_email":
      "Check your email to confirm the account, then sign in.",
    "auth.err_bad_credentials": "Email or password is incorrect.",
    "auth.err_simulated_social":
      "Could not start simulated {provider} sign-in: {reason}",

    "me.signed_in_with": "Signed in with",
    "me.my_tickets_link": "My Tickets",
    "me.no_tickets_hint": "No tickets yet",
    "me.one_ticket_hint": "1 ticket",
    "me.n_tickets_hint": "{count} tickets",
    "me.signout": "Sign out",
    "me.signed_out_hint": "Sign in to see your tickets and newsletter preferences.",
    "me.signin_or_register": "Sign in or register",

    "points.section_title": "Points",
    "points.balance_label": "Balance",
    "points.balance_value": "{points} points",
    "points.earn_blurb":
      "Earn points on simulated ticket purchases and food orders. Redeem them on event add-ons and venue merchandise.",
    "points.shop_link": "Open the points shop",
    "points.recent_title": "Recent activity",
    "points.empty": "No point activity yet.",
    "points.load_error": "Could not load your points: {error}",
    "points.tx_delta_positive": "+{delta}",
    "points.tx_delta_negative": "{delta}",
    "points.tx_venue_wide": "Venue-wide",
    "points.tx_source.ticket": "Ticket purchase",
    "points.tx_source.food": "Food order",
    "points.tx_source.addon_redemption": "Add-on redemption",
    "points.tx_source.merch_redemption": "Merchandise redemption",
    "points.tx_source.other": "Points activity",

    "shop.title": "Points shop",
    "shop.intro":
      "Venue-wide Stockholmsmassan merchandise, redeemed with points. Simulated — no physical item is produced or shipped.",
    "shop.image_alt": "{name}",
    "shop.empty": "The points shop is empty right now.",
    "shop.signed_out_hint":
      "Sign in to see your points balance and redeem merchandise.",
    "shop.insufficient_balance": "You need {cost} points to redeem this.",
    "shop.sold_out": "Sold out for this session.",
    "shop.confirmed": "Merchandise redeemed",
    "shop.confirmed_body": "You redeemed {name} for {cost} points.",
    "shop.dismiss": "Dismiss",
    "shop.err_generic": "Could not redeem this item.",

    "providers.email": "Email",
    "providers.google": "Google",
    "providers.microsoft": "Microsoft",
    "providers.anonymous": "Guest",

    "purchase.step_ticket": "1. Ticket",
    "purchase.step_questionnaire": "2. Questionnaire",
    "purchase.step_details": "3. Details",
    "purchase.step_confirm": "4. Confirm",
    "purchase.steps_aria": "Purchase progress",
    "purchase.pick_ticket": "Pick a ticket",
    "purchase.continue": "Continue",
    "purchase.attendee_details": "Attendee details",
    "purchase.questionnaire_title": "A few quick questions",
    "purchase.questionnaire_intro":
      "Your answers help the event organiser tailor the program. Fields are optional unless marked as required.",
    "purchase.q_required": "(required)",
    "purchase.q_visit_type": "I am visiting as",
    "purchase.q_visit_professional": "A professional",
    "purchase.q_visit_private": "A private visitor",
    "purchase.q_company": "Company",
    "purchase.q_role": "Role",
    "purchase.q_gender": "Gender",
    "purchase.q_choose": "Prefer not to answer",
    "purchase.q_gender_female": "Female",
    "purchase.q_gender_male": "Male",
    "purchase.q_gender_non_binary": "Non-binary",
    "purchase.q_gender_prefer_not": "Prefer not to say",
    "purchase.q_country": "Country of residence",
    "purchase.q_region": "Region or county",
    "purchase.q_subjects": "Subjects I'm interested in",
    "purchase.q_subjects_hint":
      "Pick any number. We'll use this to recommend sessions and exhibitors.",
    "purchase.attendee_name": "Attendee name",
    "purchase.attendee_email": "Attendee email",
    "purchase.summary_title": "Order summary",
    "purchase.summary_event": "Event",
    "purchase.summary_dates": "Dates",
    "purchase.summary_ticket": "Ticket",
    "purchase.summary_price": "Price",
    "purchase.sim_note_prefix": "Payment is ",
    "purchase.sim_note_suffix": " — no real charge is made.",
    "purchase.back": "Back",
    "purchase.confirm": "Confirm purchase",
    "purchase.processing": "Processing…",
    "purchase.ticket_confirmed": "Ticket confirmed",
    "purchase.transaction_ref": "Transaction reference:",
    "purchase.ticket_field_ticket": "Ticket",
    "purchase.ticket_field_attendee": "Attendee",
    "purchase.view_in_my_tickets": "View in My Tickets",
    "purchase.back_to_event": "Back to event",
    "purchase.err_pick_type": "Pick a ticket type to continue.",
    "purchase.err_pick_first": "Pick a ticket type first.",
    "purchase.err_pick_visit_type": "Pick whether you're visiting as a professional or a private visitor.",
    "purchase.err_sign_in": "Sign in to complete the purchase.",
    "purchase.err_attendee_required": "Attendee name and email are required.",
    "purchase.err_generic": "Could not complete the purchase.",

    "ticket_types.day_pass.label": "Day pass",
    "ticket_types.day_pass.description": "Entry for one day of the event.",
    "ticket_types.full_event.label": "Full event pass",
    "ticket_types.full_event.description":
      "Entry for every day of the event.",
    "ticket_types.delegate.label": "Delegate registration",
    "ticket_types.delegate.description":
      "Full congress access for all program days.",

    "ticket_cta.public": "Get tickets",
    "ticket_cta.registration": "Register as delegate",

    "tickets.signed_out_hint": "Sign in to see your tickets.",
    "tickets.empty":
      "You don't have any tickets yet. Pick an event from the calendar to buy one.",
    "tickets.load_error": "Could not load your tickets: {error}",
    "tickets.field_ticket": "Ticket",
    "tickets.field_attendee": "Attendee",
    "tickets.field_email": "Email",
    "tickets.field_purchased": "Purchased",
    "tickets.sim_entry_prefix": "Venue entry is ",
    "tickets.sim_entry_suffix": ".",

    "newsletter.venue_wide_event_name": "All Stockholmsmassan events",
    "newsletter.err_signup": "Could not sign up.",
    "newsletter.err_email_required": "Enter an email address.",

    "food.intro":
      "Order food from the venue and pick it up nearby, or book a table slot at one of the restaurants. Payment is simulated — no real charge is made.",
    "food.step_menu": "1. Menu",
    "food.step_delivery": "2. Delivery",
    "food.step_confirm": "3. Confirm",
    "food.steps_aria": "Order progress",
    "food.pick_menu": "Pick a menu",
    "food.pick_delivery": "Pick delivery",
    "food.menu_image_alt": "{name}",
    "food.continue": "Continue",
    "food.back": "Back",
    "food.delivery_pickup": "Pick up in the venue",
    "food.delivery_timeslot": "Book a restaurant slot",
    "food.pickup_legend": "Pickup location",
    "food.restaurant_legend": "Restaurant",
    "food.timeslot_legend": "Timeslot",
    "food.summary_title": "Order summary",
    "food.summary_menu": "Menu",
    "food.summary_price": "Price",
    "food.summary_delivery": "Delivery",
    "food.confirm": "Pay and order",
    "food.processing": "Processing…",
    "food.confirmed": "Order confirmed",
    "food.transaction_ref": "Transaction reference:",
    "food.pickup_instructions":
      "Pick up your order at {location} within 20 minutes.",
    "food.timeslot_instructions":
      "Your table is reserved at {restaurant} · {slot}.",
    "food.order_another": "Order another",
    "food.back_to_event": "Back to event",
    "food.err_pick_menu": "Pick a menu to continue.",
    "food.err_pick_menu_first": "Pick a menu first.",
    "food.err_pick_pickup": "Pick a pickup location.",
    "food.err_pick_slot": "Pick a restaurant and a timeslot.",
    "food.err_pick_delivery": "Pick a delivery option.",
    "food.err_generic": "Could not place the order.",

    "food.menus.burger_classic.name": "Classic Burger",
    "food.menus.burger_classic.desc":
      "Beef patty, lettuce, tomato, pickles, house sauce in a brioche bun.",
    "food.menus.cheeseburger_double.name": "Double Cheeseburger",
    "food.menus.cheeseburger_double.desc":
      "Two patties, double cheddar, caramelised onion, smoked mayo.",
    "food.menus.pizza_margherita.name": "Pizza Margherita",
    "food.menus.pizza_margherita.desc":
      "Stone-baked pizza with tomato, mozzarella, and fresh basil.",
    "food.menus.hotdog_classic.name": "Classic Hot Dog",
    "food.menus.hotdog_classic.desc":
      "Grilled sausage in a soft bun with mustard, ketchup, and crispy onion.",
    "food.menus.chicken_nuggets.name": "Chicken Nuggets (8)",
    "food.menus.chicken_nuggets.desc":
      "Eight breaded chicken pieces with your choice of dip.",
    "food.menus.fries_large.name": "Large Fries",
    "food.menus.fries_large.desc":
      "Crispy golden fries, lightly salted. Serves two as a side.",
    "food.menus.caesar_salad.name": "Caesar Salad",
    "food.menus.caesar_salad.desc":
      "Romaine, grilled chicken, parmesan, croutons, Caesar dressing.",
    "food.menus.wrap_chicken.name": "Chicken Wrap",
    "food.menus.wrap_chicken.desc":
      "Soft tortilla, grilled chicken, lettuce, tomato, chipotle mayo.",
    "food.menus.sushi_box.name": "Sushi Box",
    "food.menus.sushi_box.desc":
      "Eight pieces of salmon and tuna nigiri plus four maki rolls.",
    "food.menus.ice_cream.name": "Ice Cream Scoop",
    "food.menus.ice_cream.desc":
      "A single scoop of vanilla or chocolate, topped with sprinkles.",

    "food.pickup.entrance_north.name": "North Entrance kiosk",
    "food.pickup.entrance_north.desc":
      "Main north entrance, to the right of the turnstiles.",
    "food.pickup.hall_b_lobby.name": "Hall B lobby counter",
    "food.pickup.hall_b_lobby.desc":
      "Inside Hall B, opposite the coat check.",
    "food.pickup.central_plaza.name": "Central Plaza pickup",
    "food.pickup.central_plaza.desc":
      "Central plaza, between Halls A and C.",

    "food.restaurants.smakverket.name": "Smakverket",
    "food.restaurants.smakverket.desc":
      "Bistro-style seating with a Nordic seasonal menu.",
    "food.restaurants.torget_bistro.name": "Torget Bistro",
    "food.restaurants.torget_bistro.desc":
      "Casual canteen at the venue square, family friendly.",

    "food.includes_label": "Includes",
    "food.extras.small_fries": "Small fries",
    "food.extras.soft_drink": "Soft drink (33 cl)",
    "food.extras.garlic_bread": "Garlic bread",
    "food.extras.dip": "Dipping sauce",
    "food.extras.bottled_water": "Bottled water (33 cl)",
    "food.extras.edamame": "Edamame",
    "food.extras.miso_soup": "Miso soup",
    "food.extras.waffle_cone": "Waffle cone",
    "food.extras.toppings": "Sprinkles",
  },

  sv: {
    "sim.chip": "simulerad",

    "chrome.events": "Evenemang",
    "chrome.lang_aria": "Språk",
    "chrome.me_aria": "Mina sidor",
    "chrome.nav_aria": "Meny",
    "chrome.nav.start": "Start",
    "chrome.nav.my_tickets": "Mina biljetter",
    "chrome.nav.food": "Mat",
    "chrome.nav.program": "Program",
    "chrome.nav.exhibitors": "Utställare",
    "chrome.nav.practical": "Praktisk info",
    "chrome.nav.other_events": "Andra evenemang",
    "chrome.nav.my_pages": "Mina sidor",

    "title.events": "Evenemang",
    "title.sign_in": "Logga in",
    "title.my_pages": "Mina sidor",
    "title.my_tickets": "Mina biljetter",
    "title.get_tickets": "Köp biljetter",
    "title.get_tickets_for": "Köp biljetter · {name}",
    "title.points_shop": "Poängbutik",
    "title.event_default": "Evenemang",
    "title.app_default": "MassanApp",

    "calendar.search_placeholder": "Sök evenemang",
    "calendar.search_label": "Sök evenemang",
    "calendar.type_label": "Typ",
    "calendar.category_label": "Kategori",
    "calendar.month_label": "Månad",
    "calendar.all_types": "Alla typer",
    "calendar.all_categories": "Alla kategorier",
    "calendar.all_months": "Alla månader",
    "calendar.loading": "Laddar evenemang…",
    "calendar.load_error": "Kunde inte ladda evenemang: {error}",
    "calendar.no_match": "Inga evenemang matchar de valda filtren.",

    "event.pick_section":
      "Välj en sektion ovan för att utforska evenemanget.",
    "event.no_news": "Inga nyheter publicerade för det här evenemanget än.",
    "event.no_articles":
      "Inga artiklar publicerade för det här evenemanget än.",
    "event.no_program":
      "Inget program publicerat för det här evenemanget än.",
    "event.speakers_prefix": "Talare: ",
    "event.booth_prefix": "Monter ",
    "event.search_exhibitors_label": "Sök utställare",
    "event.search_exhibitors_placeholder": "Sök utställare",
    "event.no_exhibitor_match": "Inga utställare matchar sökningen.",
    "event.back_exhibitors": "Tillbaka till utställare",
    "event.exhibitor_not_found": "Utställaren hittades inte.",
    "event.hero_image_alt": "{name} bild",
    "event.image_credit_prefix": "Bild: ",
    "event.news_image_alt": "{name}",
    "event.article_image_alt": "{title}",
    "event.exhibitor_logo_alt": "{name} logotyp",
    "event.speaker_avatar_alt": "{name}",
    "event.view_ticket": "Visa biljett",
    "event.not_found": "Evenemanget hittades inte. Återvänd till kalendern.",
    "event.sections_nav_aria": "Evenemangssektioner",
    "event.see_all_news": "Alla nyheter ({count})",
    "event.see_all_articles": "Alla artiklar ({count})",
    "event.see_all_program": "Hela programmet ({count})",
    "event.see_all_exhibitors": "Alla utställare ({count})",
    "event.see_all_food": "Beställ mat",
    "event.back_to_event": "Tillbaka till evenemanget",

    "event.addons_title": "Evenemangstillägg",
    "event.addons_intro":
      "Extratillval bara för poäng, för dig som har biljett. Simulerat — inget fysiskt föremål produceras.",
    "event.addons_image_alt": "{name}",
    "event.addons_cost": "{cost} poäng",
    "event.addons_stock": "{count} kvar",
    "event.addons_redeem": "Lös in",
    "event.addons_redeeming": "Löser in…",
    "event.addons_insufficient_balance":
      "Du behöver {cost} poäng för att lösa in det här.",
    "event.addons_sold_out": "Slut för den här sessionen.",
    "event.addons_confirmed": "Tillägg inlöst",
    "event.addons_confirmed_body":
      "Du löste in {name} för {cost} poäng.",
    "event.addons_dismiss": "Stäng",
    "event.addons_err_generic": "Kunde inte lösa in det här tillägget.",

    "sections.news": "Nyheter",
    "sections.articles": "Artiklar",
    "sections.program": "Program",
    "sections.exhibitors": "Utställare",
    "sections.practical": "Praktisk info",
    "sections.food": "Mat",
    "sections.newsletter": "Nyhetsbrev",

    "practical.getting_here": "Hitta hit",
    "practical.parking": "Parkering",
    "practical.restaurants": "Restauranger och caféer",
    "practical.security": "Säkerhet och entré",
    "practical.maps": "Kartor över mässan",
    "practical.overrides": "Notiser för det här evenemanget",

    "overrides.entrance": "Entré",
    "overrides.bag_rules": "Väskregler",
    "overrides.access_notes": "Åtkomstnotiser",

    "newsletter.signup_intro_prefix": "Få uppdateringar om ",
    "newsletter.signup_intro_suffix":
      " via e-post. Din prenumeration sparas i den gemensamma prototypdatabasen. Bekräftelsemejlet är simulerat — inget mejl skickas i verkligheten.",
    "newsletter.topics_legend": "Jag vill få information om",
    "newsletter.signup_submit": "Prenumerera på uppdateringar",
    "newsletter.success_title": "Du är anmäld.",
    "newsletter.success_prefix": "Vi skickar uppdateringar till ",
    "newsletter.success_about": " om ",
    "newsletter.edit": "Ändra inställningar",

    "newsletter.prefs_title": "Inställningar för nyhetsbrev",
    "newsletter.prefs_empty":
      "Inga prenumerationer än. Besök ett evenemang och öppna dess Nyhetsbrev-flik för att anmäla dig.",
    "newsletter.prefs_load_error":
      "Kunde inte ladda dina nyhetsbrevsinställningar: {error}",
    "newsletter.venue_wide": "Alla Stockholmsmässan-evenemang",
    "newsletter.venue_wide_hint": "Få meddelanden från hela mässan.",
    "newsletter.unsubscribe": "Avprenumerera",

    "newsletter.topic.program_highlights": "Utvalt ur programmet",
    "newsletter.topic.news": "Nyheter",
    "newsletter.topic.exhibitor_updates": "Utställaruppdateringar",

    "auth.tab_signin": "Logga in",
    "auth.tab_register": "Registrera",
    "auth.email": "E-post",
    "auth.display_name": "Visningsnamn",
    "auth.password": "Lösenord",
    "auth.submit_signin": "Logga in",
    "auth.submit_register": "Skapa konto",
    "auth.working": "Arbetar…",
    "auth.or": "eller",
    "auth.continue_google": "Fortsätt med Google",
    "auth.continue_microsoft": "Fortsätt med Microsoft",
    "auth.generic_error": "Något gick fel.",
    "auth.mode_tablist_aria": "Inloggningsläge",
    "auth.err_email_required": "Ange en e-postadress.",
    "auth.err_confirm_email":
      "Kontrollera din e-post för att bekräfta kontot och logga sedan in.",
    "auth.err_bad_credentials": "E-post eller lösenord är felaktigt.",
    "auth.err_simulated_social":
      "Kunde inte starta simulerad inloggning med {provider}: {reason}",

    "me.signed_in_with": "Inloggad med",
    "me.my_tickets_link": "Mina biljetter",
    "me.no_tickets_hint": "Inga biljetter än",
    "me.one_ticket_hint": "1 biljett",
    "me.n_tickets_hint": "{count} biljetter",
    "me.signout": "Logga ut",
    "me.signed_out_hint":
      "Logga in för att se dina biljetter och nyhetsbrevsinställningar.",
    "me.signin_or_register": "Logga in eller registrera",

    "points.section_title": "Poäng",
    "points.balance_label": "Saldo",
    "points.balance_value": "{points} poäng",
    "points.earn_blurb":
      "Tjäna poäng på simulerade biljettköp och matbeställningar. Lös in dem på evenemangstillägg och mässans souvenirer.",
    "points.shop_link": "Öppna poängbutiken",
    "points.recent_title": "Senaste aktivitet",
    "points.empty": "Ingen poängaktivitet än.",
    "points.load_error": "Kunde inte ladda dina poäng: {error}",
    "points.tx_delta_positive": "+{delta}",
    "points.tx_delta_negative": "{delta}",
    "points.tx_venue_wide": "Hela mässan",
    "points.tx_source.ticket": "Biljettköp",
    "points.tx_source.food": "Matbeställning",
    "points.tx_source.addon_redemption": "Inlöst tillägg",
    "points.tx_source.merch_redemption": "Inlöst souvenir",
    "points.tx_source.other": "Poängaktivitet",

    "shop.title": "Poängbutik",
    "shop.intro":
      "Souvenirer från Stockholmsmässan som du löser in med poäng. Simulerat — inget fysiskt föremål produceras eller levereras.",
    "shop.image_alt": "{name}",
    "shop.empty": "Poängbutiken är tom just nu.",
    "shop.signed_out_hint":
      "Logga in för att se ditt poängsaldo och lösa in souvenirer.",
    "shop.insufficient_balance":
      "Du behöver {cost} poäng för att lösa in det här.",
    "shop.sold_out": "Slut för den här sessionen.",
    "shop.confirmed": "Souvenir inlöst",
    "shop.confirmed_body": "Du löste in {name} för {cost} poäng.",
    "shop.dismiss": "Stäng",
    "shop.err_generic": "Kunde inte lösa in det här objektet.",

    "providers.email": "E-post",
    "providers.google": "Google",
    "providers.microsoft": "Microsoft",
    "providers.anonymous": "Gäst",

    "purchase.step_ticket": "1. Biljett",
    "purchase.step_questionnaire": "2. Frågor",
    "purchase.step_details": "3. Uppgifter",
    "purchase.step_confirm": "4. Bekräfta",
    "purchase.steps_aria": "Köpförlopp",
    "purchase.pick_ticket": "Välj en biljett",
    "purchase.continue": "Fortsätt",
    "purchase.attendee_details": "Deltagaruppgifter",
    "purchase.questionnaire_title": "Några snabba frågor",
    "purchase.questionnaire_intro":
      "Dina svar hjälper arrangören att anpassa programmet. Fälten är frivilliga om inte annat anges.",
    "purchase.q_required": "(obligatoriskt)",
    "purchase.q_visit_type": "Jag besöker som",
    "purchase.q_visit_professional": "Yrkesbesökare",
    "purchase.q_visit_private": "Privatbesökare",
    "purchase.q_company": "Företag",
    "purchase.q_role": "Roll",
    "purchase.q_gender": "Kön",
    "purchase.q_choose": "Vill inte svara",
    "purchase.q_gender_female": "Kvinna",
    "purchase.q_gender_male": "Man",
    "purchase.q_gender_non_binary": "Icke-binär",
    "purchase.q_gender_prefer_not": "Vill inte uppge",
    "purchase.q_country": "Bosatt i land",
    "purchase.q_region": "Region eller län",
    "purchase.q_subjects": "Ämnen jag är intresserad av",
    "purchase.q_subjects_hint":
      "Välj så många du vill. Vi använder det för att tipsa om programpunkter och utställare.",
    "purchase.attendee_name": "Deltagarens namn",
    "purchase.attendee_email": "Deltagarens e-post",
    "purchase.summary_title": "Beställningssammanfattning",
    "purchase.summary_event": "Evenemang",
    "purchase.summary_dates": "Datum",
    "purchase.summary_ticket": "Biljett",
    "purchase.summary_price": "Pris",
    "purchase.sim_note_prefix": "Betalningen är ",
    "purchase.sim_note_suffix": " — ingen riktig debitering görs.",
    "purchase.back": "Tillbaka",
    "purchase.confirm": "Bekräfta köp",
    "purchase.processing": "Bearbetar…",
    "purchase.ticket_confirmed": "Biljett bekräftad",
    "purchase.transaction_ref": "Transaktionsreferens:",
    "purchase.ticket_field_ticket": "Biljett",
    "purchase.ticket_field_attendee": "Deltagare",
    "purchase.view_in_my_tickets": "Visa i Mina biljetter",
    "purchase.back_to_event": "Tillbaka till evenemanget",
    "purchase.err_pick_type": "Välj en biljettyp för att fortsätta.",
    "purchase.err_pick_first": "Välj en biljettyp först.",
    "purchase.err_pick_visit_type":
      "Ange om du besöker som yrkesbesökare eller privat.",
    "purchase.err_sign_in": "Logga in för att slutföra köpet.",
    "purchase.err_attendee_required":
      "Namn och e-post för deltagaren krävs.",
    "purchase.err_generic": "Kunde inte slutföra köpet.",

    "ticket_types.day_pass.label": "Dagskort",
    "ticket_types.day_pass.description": "Inträde för en dag av evenemanget.",
    "ticket_types.full_event.label": "Fullt evenemangskort",
    "ticket_types.full_event.description":
      "Inträde för alla dagar av evenemanget.",
    "ticket_types.delegate.label": "Delegatregistrering",
    "ticket_types.delegate.description":
      "Full kongressåtkomst för alla programdagar.",

    "ticket_cta.public": "Köp biljetter",
    "ticket_cta.registration": "Registrera som delegat",

    "tickets.signed_out_hint": "Logga in för att se dina biljetter.",
    "tickets.empty":
      "Du har inga biljetter än. Välj ett evenemang i kalendern och köp en.",
    "tickets.load_error": "Kunde inte ladda dina biljetter: {error}",
    "tickets.field_ticket": "Biljett",
    "tickets.field_attendee": "Deltagare",
    "tickets.field_email": "E-post",
    "tickets.field_purchased": "Köpt",
    "tickets.sim_entry_prefix": "Inträde till mässan är ",
    "tickets.sim_entry_suffix": ".",

    "newsletter.venue_wide_event_name": "Alla Stockholmsmässan-evenemang",
    "newsletter.err_signup": "Kunde inte prenumerera.",
    "newsletter.err_email_required": "Ange en e-postadress.",

    "food.intro":
      "Beställ mat i mässan och hämta i närheten, eller boka en plats på en av restaurangerna. Betalningen är simulerad — ingen riktig debitering görs.",
    "food.step_menu": "1. Meny",
    "food.step_delivery": "2. Leverans",
    "food.step_confirm": "3. Bekräfta",
    "food.steps_aria": "Beställningsförlopp",
    "food.pick_menu": "Välj en meny",
    "food.pick_delivery": "Välj leverans",
    "food.menu_image_alt": "{name}",
    "food.continue": "Fortsätt",
    "food.back": "Tillbaka",
    "food.delivery_pickup": "Hämta inom mässan",
    "food.delivery_timeslot": "Boka bord på restaurang",
    "food.pickup_legend": "Hämtställe",
    "food.restaurant_legend": "Restaurang",
    "food.timeslot_legend": "Tidslucka",
    "food.summary_title": "Sammanfattning",
    "food.summary_menu": "Meny",
    "food.summary_price": "Pris",
    "food.summary_delivery": "Leverans",
    "food.confirm": "Betala och beställ",
    "food.processing": "Bearbetar…",
    "food.confirmed": "Beställning bekräftad",
    "food.transaction_ref": "Transaktionsreferens:",
    "food.pickup_instructions":
      "Hämta din beställning vid {location} inom 20 minuter.",
    "food.timeslot_instructions":
      "Ditt bord är reserverat på {restaurant} · {slot}.",
    "food.order_another": "Beställ igen",
    "food.back_to_event": "Tillbaka till evenemanget",
    "food.err_pick_menu": "Välj en meny för att fortsätta.",
    "food.err_pick_menu_first": "Välj en meny först.",
    "food.err_pick_pickup": "Välj ett hämtställe.",
    "food.err_pick_slot": "Välj restaurang och tidslucka.",
    "food.err_pick_delivery": "Välj ett leveranssätt.",
    "food.err_generic": "Kunde inte slutföra beställningen.",

    "food.menus.burger_classic.name": "Klassisk burgare",
    "food.menus.burger_classic.desc":
      "Nötfärs, sallad, tomat, pickles och husets sås i briochebröd.",
    "food.menus.cheeseburger_double.name": "Dubbel cheeseburger",
    "food.menus.cheeseburger_double.desc":
      "Två färsbiffar, dubbel cheddar, karamelliserad lök och rökt majonnäs.",
    "food.menus.pizza_margherita.name": "Pizza Margherita",
    "food.menus.pizza_margherita.desc":
      "Stenugnsbakad pizza med tomat, mozzarella och färsk basilika.",
    "food.menus.hotdog_classic.name": "Klassisk varmkorv",
    "food.menus.hotdog_classic.desc":
      "Grillad korv i mjukt bröd med senap, ketchup och rostad lök.",
    "food.menus.chicken_nuggets.name": "Kycklingnuggets (8)",
    "food.menus.chicken_nuggets.desc":
      "Åtta panerade kycklingbitar med valfri dipp.",
    "food.menus.fries_large.name": "Stor pommes",
    "food.menus.fries_large.desc":
      "Knapriga pommes, lätt saltade. Räcker till två som tillbehör.",
    "food.menus.caesar_salad.name": "Caesarsallad",
    "food.menus.caesar_salad.desc":
      "Romansallad, grillad kyckling, parmesan, krutonger och caesardressing.",
    "food.menus.wrap_chicken.name": "Kycklingwrap",
    "food.menus.wrap_chicken.desc":
      "Mjuk tortilla med grillad kyckling, sallad, tomat och chipotlemajonnäs.",
    "food.menus.sushi_box.name": "Sushibox",
    "food.menus.sushi_box.desc":
      "Åtta nigiri med lax och tonfisk plus fyra makirullar.",
    "food.menus.ice_cream.name": "Glasskula",
    "food.menus.ice_cream.desc":
      "En kula vanilj eller choklad med strössel.",

    "food.pickup.entrance_north.name": "Norra entrén",
    "food.pickup.entrance_north.desc":
      "Vid norra huvudentrén, höger om spärrarna.",
    "food.pickup.hall_b_lobby.name": "Hall B-foajén",
    "food.pickup.hall_b_lobby.desc":
      "I Hall B, mitt emot garderoben.",
    "food.pickup.central_plaza.name": "Centrala torget",
    "food.pickup.central_plaza.desc":
      "Mellan Hall A och Hall C på centrala torget.",

    "food.restaurants.smakverket.name": "Smakverket",
    "food.restaurants.smakverket.desc":
      "Bistrokänsla med nordisk säsongsmeny.",
    "food.restaurants.torget_bistro.name": "Torget Bistro",
    "food.restaurants.torget_bistro.desc":
      "Avslappnad matsal vid torget, familjevänlig.",

    "food.includes_label": "Ingår",
    "food.extras.small_fries": "Liten pommes",
    "food.extras.soft_drink": "Läsk (33 cl)",
    "food.extras.garlic_bread": "Vitlöksbröd",
    "food.extras.dip": "Dippsås",
    "food.extras.bottled_water": "Vatten på flaska (33 cl)",
    "food.extras.edamame": "Edamame",
    "food.extras.miso_soup": "Misosoppa",
    "food.extras.waffle_cone": "Våffelstrut",
    "food.extras.toppings": "Strössel",
  },
};

function interpolate(template, params) {
  if (!params) return template;
  return template.replace(/\{(\w+)\}/g, (_, key) =>
    params[key] === undefined ? `{${key}}` : String(params[key]),
  );
}

// Look up a translation key in the active language. Falls back to
// English, then to the key itself, so templates keep rendering even if
// a key is not yet translated.
export function translate(key, lang, params) {
  const active = TRANSLATIONS[lang] ?? TRANSLATIONS[DEFAULT_LANGUAGE];
  const raw =
    (active && active[key]) ??
    TRANSLATIONS[DEFAULT_LANGUAGE][key] ??
    key;
  return interpolate(raw, params);
}

export function dateLocaleFor(lang) {
  return DATE_LOCALES[lang] ?? DATE_LOCALES[DEFAULT_LANGUAGE];
}

// Keys defined for `lang`. Used by the unit suite to assert that every
// language carries the same set of keys, so a new key that forgets its
// non-English counterpart fails tests instead of silently rendering in
// the English fallback.
export function availableKeys(lang) {
  const dict = TRANSLATIONS[lang];
  return dict ? Object.keys(dict) : [];
}

// Translate against the active UI language when Alpine's `lang` store
// is available, otherwise fall back to the default-language entry.
// Use this from modules that initialize before Alpine or from error
// paths in stores that must keep working during the pre-init window.
export function activeTranslate(key, params) {
  const store = globalThis.Alpine?.store?.("lang");
  if (store) return store.t(key, params);
  return translate(key, DEFAULT_LANGUAGE, params);
}

// Resolve `key` against the canonical (English) dictionary regardless
// of the active UI language. Used when a label is about to be
// persisted (e.g. `ticket_type_label` on `public.tickets`,
// `menu_label` / `delivery_label` on `public.food_orders`) so the
// stored copy does not flip language depending on whoever views it
// later.
export function canonicalTranslate(key, params) {
  return translate(key, DEFAULT_LANGUAGE, params);
}
