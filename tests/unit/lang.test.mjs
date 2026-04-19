// Language store (stores/lang.js). Holds the active UI language, a
// translator `t()`, and the Intl locale used by util/dates.js. The
// store persists the choice to localStorage under `massanapp_lang` so
// it survives reloads, and reflects the active language on
// `<html lang>` so assistive tech reads the right locale. The pieces
// behind `translate` and `dateLocaleFor` are covered by
// i18n.test.mjs; this suite locks in the store's own wiring:
// localStorage persistence, the unsupported-language guard, and the
// delegation to i18n helpers.
//
// The store touches `window` and `document` as bare globals in its
// `init()` and `set()` paths. Node has neither by default, so each
// test stubs them through `globalThis` and restores the previous
// values on completion.

import test from "node:test";
import assert from "node:assert/strict";

import { langStore } from "../../web/assets/js/stores/lang.js";

function makeFakeStorage(initial = {}) {
  const backing = { ...initial };
  return {
    getItem(key) {
      return Object.prototype.hasOwnProperty.call(backing, key)
        ? backing[key]
        : null;
    },
    setItem(key, value) {
      backing[key] = String(value);
    },
    _snapshot() {
      return { ...backing };
    },
  };
}

// Stub `window` and `document` just long enough to run `body`. The
// previous globals are always restored, even if `body` throws, so tests
// cannot leak state into each other.
function withStubbedDom({ storage = makeFakeStorage(), langAttr = null } = {}, body) {
  const prevWindow = globalThis.window;
  const prevDocument = globalThis.document;
  const attrSink = { lang: langAttr };
  globalThis.window = { localStorage: storage };
  globalThis.document = {
    documentElement: {
      setAttribute(name, value) {
        if (name === "lang") attrSink.lang = value;
      },
    },
  };
  try {
    body({ storage, attrSink });
  } finally {
    globalThis.window = prevWindow;
    globalThis.document = prevDocument;
  }
}

test("langStore: default current is English before init", () => {
  const store = langStore();
  assert.equal(store.current, "en");
  assert.deepEqual(store.supported, ["en", "sv"]);
  assert.equal(store.labels.en, "English");
  assert.equal(store.labels.sv, "Svenska");
});

test("langStore.init(): adopts the persisted language when supported", () => {
  withStubbedDom(
    { storage: makeFakeStorage({ massanapp_lang: "sv" }) },
    ({ attrSink }) => {
      const store = langStore();
      store.init();
      assert.equal(store.current, "sv");
      assert.equal(attrSink.lang, "sv");
    },
  );
});

test("langStore.init(): ignores an unsupported persisted value", () => {
  // A stale or user-tampered storage entry must not put the app into
  // an untranslatable state — fall back to English.
  withStubbedDom(
    { storage: makeFakeStorage({ massanapp_lang: "de" }) },
    ({ attrSink }) => {
      const store = langStore();
      store.init();
      assert.equal(store.current, "en");
      assert.equal(attrSink.lang, "en");
    },
  );
});

test("langStore.init(): empty storage keeps the English default", () => {
  withStubbedDom({}, ({ attrSink }) => {
    const store = langStore();
    store.init();
    assert.equal(store.current, "en");
    assert.equal(attrSink.lang, "en");
  });
});

test("langStore.init(): localStorage throwing is swallowed, falls back to default", () => {
  // Private-browsing modes can throw on getItem — the try/catch in
  // readStoredLanguage must keep init working.
  const throwingStorage = {
    getItem() {
      throw new Error("quota");
    },
    setItem() {},
  };
  withStubbedDom({ storage: throwingStorage }, () => {
    const store = langStore();
    store.init();
    assert.equal(store.current, "en");
  });
});

test("langStore.set(): updates current, document lang attribute, and storage", () => {
  withStubbedDom({}, ({ storage, attrSink }) => {
    const store = langStore();
    store.init();
    store.set("sv");
    assert.equal(store.current, "sv");
    assert.equal(attrSink.lang, "sv");
    assert.equal(storage._snapshot().massanapp_lang, "sv");
  });
});

test("langStore.set(): rejects an unsupported language without side effects", () => {
  withStubbedDom({}, ({ storage, attrSink }) => {
    const store = langStore();
    store.init();
    store.set("de");
    assert.equal(store.current, "en");
    assert.equal(attrSink.lang, "en");
    assert.equal(storage._snapshot().massanapp_lang, undefined);
  });
});

test("langStore.set(): same language is a no-op (no storage write)", () => {
  // The guard against same-language sets matters because
  // `document.documentElement.setAttribute` and `localStorage.setItem`
  // are observable side effects — skipping them when nothing changed
  // keeps renders and storage writes tidy.
  let writes = 0;
  const storage = {
    getItem: () => null,
    setItem() {
      writes += 1;
    },
  };
  withStubbedDom({ storage }, () => {
    const store = langStore();
    store.init();
    store.set("en");
    assert.equal(store.current, "en");
    assert.equal(writes, 0);
  });
});

test("langStore.set(): storage failure does not roll back the active language", () => {
  // If persistence fails the in-session change still applies — the
  // visitor should not get a silent revert to the old language.
  const storage = {
    getItem: () => null,
    setItem() {
      throw new Error("quota");
    },
  };
  withStubbedDom({ storage }, ({ attrSink }) => {
    const store = langStore();
    store.init();
    store.set("sv");
    assert.equal(store.current, "sv");
    assert.equal(attrSink.lang, "sv");
  });
});

test("langStore.t(): delegates to translate against the current language", () => {
  withStubbedDom({}, () => {
    const store = langStore();
    store.init();
    assert.equal(store.t("chrome.events"), "Events");
    store.set("sv");
    assert.equal(store.t("chrome.events"), "Evenemang");
  });
});

test("langStore.t(): forwards interpolation params", () => {
  withStubbedDom({}, () => {
    const store = langStore();
    store.init();
    assert.equal(
      store.t("title.get_tickets_for", { name: "Nordbygg 2026" }),
      "Get tickets · Nordbygg 2026",
    );
  });
});

test("langStore.dateLocale(): returns the Intl locale for the active language", () => {
  withStubbedDom({}, () => {
    const store = langStore();
    store.init();
    assert.equal(store.dateLocale(), "en-GB");
    store.set("sv");
    assert.equal(store.dateLocale(), "sv-SE");
  });
});
