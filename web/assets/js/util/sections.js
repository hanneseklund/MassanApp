// Event section labels shown under the hero, plus the ticket-type
// catalog keyed by event.ticket_model. Ticket types live in the
// frontend so the catalog stays stable regardless of how the event was
// loaded (see docs/implementation-specification.md under "Ticket").
//
// User-visible strings here are looked up from the `lang` store so the
// catalog renders in either supported UI language. Two distinct rules
// govern multilingual text in the prototype, and this file lives at
// the boundary:
//
//   1. Catalog content (event names, news bodies, exhibitor copy,
//      venue copy, etc.) is stored in the database as
//      `jsonb { en, sv }` and resolved at render time via the
//      `pickLang` helper in util/i18n-content.js (or the ergonomic
//      `$store.lang.pick(...)` accessor). Switching language re-reads
//      the same row and re-renders.
//
//   2. Persisted display labels — `ticket_type_label` on a saved
//      ticket, `menu_label` / `delivery_label` on a saved food order —
//      keep the **canonical-English rule** via `canonicalTranslate`
//      (and `canonicalTicketTypeLabel` below). The wallet entry must
//      not flip language depending on whoever views it later, so the
//      English copy is frozen into the row at write time.

import { activeTranslate, canonicalTranslate } from "../i18n.js";

const t = activeTranslate;

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
    if (entry) return canonicalTranslate(entry.label_key);
  }
  return ticketTypeId;
}
