// Simulated email helper. `simulatedEmail(kind, payload)` logs to the
// browser console on prototype hosts (local dev, *.pages.dev preview)
// and is silent on any other host, so a future non-prototype
// deployment does not leak the payload. The host allowlist is the
// behavior the smoke suite depends on when it asserts that
// `[simulatedEmail]` entries appear in the console.

import test from "node:test";
import assert from "node:assert/strict";

import { simulatedEmail } from "../../web/assets/js/simulations/email.js";

function captureConsoleInfo(fn) {
  const original = console.info;
  const calls = [];
  console.info = (...args) => calls.push(args);
  try {
    fn();
  } finally {
    console.info = original;
  }
  return calls;
}

function withWindowHost(hostname, fn) {
  const original = globalThis.window;
  globalThis.window = { location: { hostname } };
  try {
    return fn();
  } finally {
    if (original === undefined) delete globalThis.window;
    else globalThis.window = original;
  }
}

test("simulatedEmail: without a window (node context) logs to console.info", () => {
  assert.equal(typeof globalThis.window, "undefined");
  const calls = captureConsoleInfo(() =>
    simulatedEmail("ticket_confirmation", { to: "a@example.com" }),
  );
  assert.equal(calls.length, 1);
  assert.equal(calls[0][0], "[simulatedEmail]");
  assert.equal(calls[0][1], "ticket_confirmation");
  assert.deepEqual(calls[0][2], { to: "a@example.com" });
});

test("simulatedEmail: localhost is treated as a prototype host and logs", () => {
  const calls = withWindowHost("localhost", () =>
    captureConsoleInfo(() => simulatedEmail("newsletter_confirmation", {})),
  );
  assert.equal(calls.length, 1);
});

test("simulatedEmail: 127.0.0.1 logs", () => {
  const calls = withWindowHost("127.0.0.1", () =>
    captureConsoleInfo(() => simulatedEmail("ticket_confirmation", {})),
  );
  assert.equal(calls.length, 1);
});

test("simulatedEmail: *.local hosts log (mDNS / LAN dev)", () => {
  const calls = withWindowHost("laptop.local", () =>
    captureConsoleInfo(() => simulatedEmail("ticket_confirmation", {})),
  );
  assert.equal(calls.length, 1);
});

test("simulatedEmail: *.pages.dev hosts log (Cloudflare Pages preview)", () => {
  const calls = withWindowHost("agent.massanapp-prototype.pages.dev", () =>
    captureConsoleInfo(() => simulatedEmail("newsletter_confirmation", {})),
  );
  assert.equal(calls.length, 1);
});

test("simulatedEmail: non-prototype hosts stay silent", () => {
  const calls = withWindowHost("massanapp.example.com", () =>
    captureConsoleInfo(() =>
      simulatedEmail("ticket_confirmation", { to: "a@example.com" }),
    ),
  );
  assert.equal(calls.length, 0);
});

test("simulatedEmail: a bare .dev host is not treated as a prototype host", () => {
  // Only `.pages.dev` is allowlisted; a random `.dev` host must not leak.
  const calls = withWindowHost("massanapp.dev", () =>
    captureConsoleInfo(() => simulatedEmail("ticket_confirmation", {})),
  );
  assert.equal(calls.length, 0);
});
