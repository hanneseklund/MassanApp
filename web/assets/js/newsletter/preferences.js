// Newsletter preference shape. Missing keys are treated as `true` so
// older rows keep working when new topic keys are added later.

export const NEWSLETTER_PREF_KEYS = [
  "program_highlights",
  "news",
  "exhibitor_updates",
];

export const NEWSLETTER_TOPICS = [
  { key: "program_highlights", label: "Program highlights" },
  { key: "news", label: "News" },
  { key: "exhibitor_updates", label: "Exhibitor updates" },
];

export function defaultNewsletterPreferences() {
  return Object.fromEntries(NEWSLETTER_PREF_KEYS.map((k) => [k, true]));
}

export function normalizeNewsletterPreferences(pref) {
  const out = defaultNewsletterPreferences();
  if (pref && typeof pref === "object") {
    for (const k of NEWSLETTER_PREF_KEYS) {
      if (k in pref) out[k] = !!pref[k];
    }
  }
  return out;
}
