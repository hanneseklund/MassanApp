// Event section labels shown under the hero, plus the ticket-type
// catalog keyed by event.ticket_model. Ticket types live in the
// frontend so the catalog stays stable regardless of how the event was
// loaded (see docs/implementation-specification.md under "Ticket").

export const SECTION_LABELS = [
  { id: "news", label: "News" },
  { id: "articles", label: "Articles" },
  { id: "program", label: "Program" },
  { id: "exhibitors", label: "Exhibitors" },
  { id: "practical", label: "Practical info" },
  { id: "newsletter", label: "Newsletter" },
];

export const TICKET_TYPES = {
  public_ticket: [
    {
      id: "day_pass",
      label: "Day pass",
      description: "Entry for one day of the event.",
      price: "SEK 295",
    },
    {
      id: "full_event",
      label: "Full event pass",
      description: "Entry for every day of the event.",
      price: "SEK 595",
    },
  ],
  registration: [
    {
      id: "delegate",
      label: "Delegate registration",
      description: "Full congress access for all program days.",
      price: "EUR 450",
    },
  ],
};

export function ticketTypesFor(event) {
  if (!event) return [];
  return TICKET_TYPES[event.ticket_model] ?? [];
}

export function ticketCtaLabel(event) {
  if (!event) return "";
  if (event.ticket_model === "public_ticket") return "Get tickets";
  if (event.ticket_model === "registration") return "Register as delegate";
  return "";
}
