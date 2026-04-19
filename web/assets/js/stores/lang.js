// Language store. Holds the active UI language (`en` or `sv`) and
// exposes a translator `t(key, params)` plus a `dateLocale` for the
// formatting helpers in util/dates.js. The choice is persisted to
// localStorage under `massanapp_lang` so it survives reloads, but the
// default on first load is English so smoke tests and reviewers see
// the same chrome they always have.
//
// Alpine re-evaluates expressions that read store state when that
// state changes. Reading `this.current` inside `t()` therefore makes
// every `$store.lang.t('...')` binding in the DOM reactive to a
// language switch.

import {
  DEFAULT_LANGUAGE,
  SUPPORTED_LANGUAGES,
  LANGUAGE_LABELS,
  translate,
  dateLocaleFor,
} from "../i18n.js";

const STORAGE_KEY = "massanapp_lang";

function readStoredLanguage() {
  try {
    const stored = window.localStorage?.getItem(STORAGE_KEY);
    if (stored && SUPPORTED_LANGUAGES.includes(stored)) return stored;
  } catch {
    // localStorage can throw in private browsing modes — fall through.
  }
  return DEFAULT_LANGUAGE;
}

export function langStore() {
  return {
    current: DEFAULT_LANGUAGE,
    supported: SUPPORTED_LANGUAGES,
    labels: LANGUAGE_LABELS,

    init() {
      this.current = readStoredLanguage();
      document.documentElement.setAttribute("lang", this.current);
    },

    set(lang) {
      if (!SUPPORTED_LANGUAGES.includes(lang) || lang === this.current) {
        return;
      }
      this.current = lang;
      document.documentElement.setAttribute("lang", lang);
      try {
        window.localStorage?.setItem(STORAGE_KEY, lang);
      } catch {
        // Ignore persistence failures — the choice still applies for
        // this session.
      }
    },

    t(key, params) {
      return translate(key, this.current, params);
    },

    dateLocale() {
      return dateLocaleFor(this.current);
    },
  };
}
