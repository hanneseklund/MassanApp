// Newsletter preference shape. Missing keys are treated as `true` so
// older rows keep working when new topic keys are added later.
//
// `NEWSLETTER_TOPICS` resolves its labels against the active UI
// language so the topic list translates with the rest of the chrome.

import { activeTranslate } from "../i18n.js";

export const NEWSLETTER_PREF_KEYS = [
  "program_highlights",
  "news",
  "exhibitor_updates",
];

// Each topic exposes its label via a getter so Alpine bindings that
// iterate over `topics` re-read the label on every render, which is
// enough to make the switcher repaint the list.
export const NEWSLETTER_TOPICS = NEWSLETTER_PREF_KEYS.map((pref) => ({
  key: pref,
  get label() {
    return activeTranslate(`newsletter.topic.${pref}`);
  },
}));

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
