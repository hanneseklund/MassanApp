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
    "chrome.back_events_aria": "Back to events",
    "chrome.me_aria": "My Pages",

    "title.events": "Events",
    "title.sign_in": "Sign in",
    "title.my_pages": "My Pages",
    "title.my_tickets": "My Tickets",
    "title.get_tickets": "Get tickets",
    "title.get_tickets_for": "Get tickets · {name}",
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

    "sections.news": "News",
    "sections.articles": "Articles",
    "sections.program": "Program",
    "sections.exhibitors": "Exhibitors",
    "sections.practical": "Practical info",
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

    "providers.email": "Email",
    "providers.google": "Google",
    "providers.microsoft": "Microsoft",
    "providers.anonymous": "Guest",

    "purchase.step_ticket": "1. Ticket",
    "purchase.step_details": "2. Details",
    "purchase.step_confirm": "3. Confirm",
    "purchase.steps_aria": "Purchase progress",
    "purchase.pick_ticket": "Pick a ticket",
    "purchase.continue": "Continue",
    "purchase.attendee_details": "Attendee details",
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
    "tickets.field_ticket": "Ticket",
    "tickets.field_attendee": "Attendee",
    "tickets.field_email": "Email",
    "tickets.field_purchased": "Purchased",
    "tickets.sim_entry_prefix": "Venue entry is ",
    "tickets.sim_entry_suffix": ".",

    "newsletter.venue_wide_event_name": "All Stockholmsmassan events",
    "newsletter.err_signup": "Could not sign up.",
    "newsletter.err_email_required": "Enter an email address.",
  },

  sv: {
    "sim.chip": "simulerad",

    "chrome.events": "Evenemang",
    "chrome.lang_aria": "Språk",
    "chrome.back_events_aria": "Tillbaka till evenemang",
    "chrome.me_aria": "Mina sidor",

    "title.events": "Evenemang",
    "title.sign_in": "Logga in",
    "title.my_pages": "Mina sidor",
    "title.my_tickets": "Mina biljetter",
    "title.get_tickets": "Köp biljetter",
    "title.get_tickets_for": "Köp biljetter · {name}",
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

    "sections.news": "Nyheter",
    "sections.articles": "Artiklar",
    "sections.program": "Program",
    "sections.exhibitors": "Utställare",
    "sections.practical": "Praktisk info",
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

    "providers.email": "E-post",
    "providers.google": "Google",
    "providers.microsoft": "Microsoft",
    "providers.anonymous": "Gäst",

    "purchase.step_ticket": "1. Biljett",
    "purchase.step_details": "2. Uppgifter",
    "purchase.step_confirm": "3. Bekräfta",
    "purchase.steps_aria": "Köpförlopp",
    "purchase.pick_ticket": "Välj en biljett",
    "purchase.continue": "Fortsätt",
    "purchase.attendee_details": "Deltagaruppgifter",
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
    "tickets.field_ticket": "Biljett",
    "tickets.field_attendee": "Deltagare",
    "tickets.field_email": "E-post",
    "tickets.field_purchased": "Köpt",
    "tickets.sim_entry_prefix": "Inträde till mässan är ",
    "tickets.sim_entry_suffix": ".",

    "newsletter.venue_wide_event_name": "Alla Stockholmsmässan-evenemang",
    "newsletter.err_signup": "Kunde inte prenumerera.",
    "newsletter.err_email_required": "Ange en e-postadress.",
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
