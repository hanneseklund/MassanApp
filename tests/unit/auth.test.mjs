// authView() in views/auth.js is the register / sign-in / simulated
// social-provider surface. It delegates the credential handshake to
// stores/session.js; the view's own job is to gate on the processing
// flag, clear state between mode switches, reset the form after a
// successful attempt, surface errors, and pass control to
// stores/app.js `afterAuth()` on success.
//
// Follows the Alpine.store stub pattern from my-tickets.test.mjs and
// me.test.mjs — no browser, no Supabase, no Alpine runtime.

import test from "node:test";
import assert from "node:assert/strict";

import { authView } from "../../web/assets/js/views/auth.js";

async function withAlpine(stores, body) {
  const prev = globalThis.Alpine;
  globalThis.Alpine = {
    store(id) {
      return stores[id];
    },
  };
  try {
    return await body();
  } finally {
    globalThis.Alpine = prev;
  }
}

function makeStores({
  register,
  signIn,
  simulatedSocialSignIn,
  afterAuth = () => {},
} = {}) {
  const calls = {
    register: [],
    signIn: [],
    simulatedSocialSignIn: [],
    afterAuth: 0,
  };
  return {
    calls,
    stores: {
      lang: { t: (key) => key },
      session: {
        async register(payload) {
          calls.register.push(payload);
          if (register) return register(payload);
        },
        async signIn(payload) {
          calls.signIn.push(payload);
          if (signIn) return signIn(payload);
        },
        async simulatedSocialSignIn(provider) {
          calls.simulatedSocialSignIn.push(provider);
          if (simulatedSocialSignIn) return simulatedSocialSignIn(provider);
        },
      },
      app: {
        afterAuth() {
          calls.afterAuth += 1;
          afterAuth();
        },
      },
    },
  };
}

test("initial state: signin mode, empty fields, not processing, no error", () => {
  const view = authView();
  assert.equal(view.mode, "signin");
  assert.equal(view.email, "");
  assert.equal(view.displayName, "");
  assert.equal(view.password, "");
  assert.equal(view.error, "");
  assert.equal(view.processing, false);
});

test("setMode: switches mode and clears any previous error", () => {
  const view = authView();
  view.error = "stale error";
  view.setMode("register");
  assert.equal(view.mode, "register");
  assert.equal(view.error, "");
});

test("submit (register): calls session.register with form values, clears form, runs afterAuth", async () => {
  const { calls, stores } = makeStores();
  await withAlpine(stores, async () => {
    const view = authView();
    view.mode = "register";
    view.email = " visitor@example.com ";
    view.displayName = "Visitor";
    view.password = "hunter22";
    await view.submit();
    assert.equal(calls.register.length, 1);
    assert.deepEqual(calls.register[0], {
      email: " visitor@example.com ",
      displayName: "Visitor",
      password: "hunter22",
    });
    // Form is cleared on success so the inputs do not leak across mode
    // switches or subsequent attempts.
    assert.equal(view.email, "");
    assert.equal(view.displayName, "");
    assert.equal(view.password, "");
    assert.equal(view.processing, false);
    assert.equal(calls.afterAuth, 1);
  });
});

test("submit (signin): calls session.signIn with email and password; displayName is not forwarded", async () => {
  const { calls, stores } = makeStores();
  await withAlpine(stores, async () => {
    const view = authView();
    view.mode = "signin";
    view.email = "visitor@example.com";
    view.displayName = "ignored in signin";
    view.password = "hunter22";
    await view.submit();
    assert.equal(calls.signIn.length, 1);
    assert.deepEqual(calls.signIn[0], {
      email: "visitor@example.com",
      password: "hunter22",
    });
    assert.equal(calls.register.length, 0);
    assert.equal(calls.afterAuth, 1);
  });
});

test("submit: surfaces store error in view.error and does not call afterAuth", async () => {
  const { calls, stores } = makeStores({
    register: () => {
      throw new Error("Email already registered");
    },
  });
  await withAlpine(stores, async () => {
    const view = authView();
    view.mode = "register";
    view.email = "dup@example.com";
    view.displayName = "Dup";
    view.password = "pw";
    await view.submit();
    assert.equal(view.error, "Email already registered");
    assert.equal(view.processing, false);
    assert.equal(calls.afterAuth, 0);
    // Inputs must stay put so the visitor can correct and retry.
    assert.equal(view.email, "dup@example.com");
    assert.equal(view.password, "pw");
  });
});

test("submit: falls back to auth.generic_error when the thrown error has no message", async () => {
  const { stores } = makeStores({
    signIn: () => {
      // An error without a message surfaces through the lang-store
      // translation key so the UI always has something to show.
      const err = new Error();
      err.message = "";
      throw err;
    },
  });
  await withAlpine(stores, async () => {
    const view = authView();
    view.email = "a@b.c";
    view.password = "pw";
    await view.submit();
    assert.equal(view.error, "auth.generic_error");
  });
});

test("submit: ignores concurrent calls while processing is true", async () => {
  let resolve;
  const inflight = new Promise((r) => {
    resolve = r;
  });
  const { calls, stores } = makeStores({
    signIn: () => inflight,
  });
  await withAlpine(stores, async () => {
    const view = authView();
    view.email = "a@b.c";
    view.password = "pw";
    const first = view.submit();
    // Second call while the first is still in flight must early-return.
    const second = view.submit();
    await second;
    assert.equal(calls.signIn.length, 1);
    resolve();
    await first;
    assert.equal(calls.signIn.length, 1);
  });
});

test("submit: clears any previous error before calling the store", async () => {
  const { stores } = makeStores();
  await withAlpine(stores, async () => {
    const view = authView();
    view.error = "leftover";
    view.email = "a@b.c";
    view.password = "pw";
    await view.submit();
    assert.equal(view.error, "");
  });
});

test("socialSignIn: forwards the provider to the store and runs afterAuth", async () => {
  const { calls, stores } = makeStores();
  await withAlpine(stores, async () => {
    const view = authView();
    await view.socialSignIn("google");
    assert.deepEqual(calls.simulatedSocialSignIn, ["google"]);
    assert.equal(calls.afterAuth, 1);
    assert.equal(view.processing, false);
  });
});

test("socialSignIn: surfaces the error and does not call afterAuth", async () => {
  const { calls, stores } = makeStores({
    simulatedSocialSignIn: () => {
      throw new Error("anonymous sign-in disabled");
    },
  });
  await withAlpine(stores, async () => {
    const view = authView();
    await view.socialSignIn("microsoft");
    assert.equal(view.error, "anonymous sign-in disabled");
    assert.equal(view.processing, false);
    assert.equal(calls.afterAuth, 0);
  });
});

test("socialSignIn: ignored while another attempt is processing", async () => {
  let resolve;
  const inflight = new Promise((r) => {
    resolve = r;
  });
  const { calls, stores } = makeStores({
    simulatedSocialSignIn: () => inflight,
  });
  await withAlpine(stores, async () => {
    const view = authView();
    const first = view.socialSignIn("google");
    const second = view.socialSignIn("microsoft");
    await second;
    assert.equal(calls.simulatedSocialSignIn.length, 1);
    resolve();
    await first;
    assert.equal(calls.simulatedSocialSignIn.length, 1);
  });
});
