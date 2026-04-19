// Event section labels shown under the hero, plus the ticket-type
// catalog keyed by event.ticket_model. Ticket types live in the
// frontend so the catalog stays stable regardless of how the event was
// loaded (see docs/implementation-specification.md under "Ticket").
//
// All user-visible strings are looked up from the `lang` store so the
// same catalog renders in both supported UI languages. Persisted
// fields (e.g. `ticket_type_label` on a saved ticket) use the
// canonical English copy so the wallet entry does not flip language
// based on whoever happens to view it later.

import { activeTranslate, translate, DEFAULT_LANGUAGE } from "../i18n.js";

const t = activeTranslate;

// English-only lookup for values that persist to the database and
// therefore must not change with the active UI language.
function tCanonical(key) {
  return translate(key, DEFAULT_LANGUAGE);
}

// `label` is a getter so switching language immediately updates every
// template that iterates over `SECTION_LABELS` — the Alpine effect
// backing `x-text="section.label"` tracks `$store.lang.current` via
// `t()` and re-runs on change.
const SECTION_ENTRIES = [
  { id: "news", key: "sections.news" },
  { id: "articles", key: "sections.articles" },
  { id: "program", key: "sections.program" },
  { id: "exhibitors", key: "sections.exhibitors" },
  { id: "practical", key: "sections.practical" },
  { id: "food", key: "sections.food" },
  { id: "newsletter", key: "sections.newsletter" },
];

export const SECTION_LABELS = SECTION_ENTRIES.map((entry) => ({
  id: entry.id,
  get label() {
    return t(entry.key);
  },
}));

const TICKET_TYPE_ENTRIES = {
  public_ticket: [
    {
      id: "day_pass",
      label_key: "ticket_types.day_pass.label",
      description_key: "ticket_types.day_pass.description",
      price: "SEK 295",
    },
    {
      id: "full_event",
      label_key: "ticket_types.full_event.label",
      description_key: "ticket_types.full_event.description",
      price: "SEK 595",
    },
  ],
  registration: [
    {
      id: "delegate",
      label_key: "ticket_types.delegate.label",
      description_key: "ticket_types.delegate.description",
      price: "EUR 450",
    },
  ],
};

// The `label` / `description` getters resolve against the active UI
// language on access so switching language re-renders bound templates.
const TICKET_TYPES = Object.fromEntries(
  Object.entries(TICKET_TYPE_ENTRIES).map(([model, entries]) => [
    model,
    entries.map((entry) => ({
      id: entry.id,
      price: entry.price,
      get label() {
        return t(entry.label_key);
      },
      get description() {
        return t(entry.description_key);
      },
    })),
  ]),
);

export function ticketTypesFor(event) {
  if (!event) return [];
  return TICKET_TYPES[event.ticket_model] ?? [];
}

export function ticketCtaLabel(event) {
  if (!event) return "";
  if (event.ticket_model === "public_ticket") return t("ticket_cta.public");
  if (event.ticket_model === "registration")
    return t("ticket_cta.registration");
  return "";
}

// Canonical English label for a given ticket-type id. Used by the
// purchase flow when persisting the chosen ticket type — the stored
// label must stay stable independent of the UI language at checkout
// time.
export function canonicalTicketTypeLabel(ticketTypeId) {
  for (const entries of Object.values(TICKET_TYPE_ENTRIES)) {
    const entry = entries.find((e) => e.id === ticketTypeId);
    if (entry) return tCanonical(entry.label_key);
  }
  return ticketTypeId;
}
