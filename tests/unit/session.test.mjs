// Supabase-user mapping in stores/session.js. `mapSupabaseUser` is the
// glue between Supabase Auth and the flat `session.user` shape the rest
// of the UI consumes. It covers three identity paths — email-backed
// sign-up/sign-in, simulated Google / Microsoft riding on anonymous
// sessions, and a defensive anonymous fallback — and each needs to
// settle `auth_provider`, `display_name`, `email`, and `simulated`
// correctly. Testing it directly catches regressions that would
// otherwise only surface in the Supabase-backed smoke suite.

import test from "node:test";
import assert from "node:assert/strict";

import { mapSupabaseUser } from "../../web/assets/js/stores/session.js";

test("mapSupabaseUser: null or undefined input returns null", () => {
  assert.equal(mapSupabaseUser(null), null);
  assert.equal(mapSupabaseUser(undefined), null);
});

test("mapSupabaseUser: email-backed user resolves display_name from metadata", () => {
  const out = mapSupabaseUser({
    id: "u-1",
    email: "jane@example.com",
    user_metadata: {
      display_name: "Jane Doe",
      auth_provider: "email",
    },
  });
  assert.deepEqual(out, {
    id: "u-1",
    email: "jane@example.com",
    display_name: "Jane Doe",
    auth_provider: "email",
    simulated: false,
  });
});

test("mapSupabaseUser: email user without display_name falls back to email", () => {
  const out = mapSupabaseUser({
    id: "u-2",
    email: "noname@example.com",
    user_metadata: {},
  });
  assert.equal(out.display_name, "noname@example.com");
  assert.equal(out.auth_provider, "email");
  assert.equal(out.simulated, false);
});

test("mapSupabaseUser: missing user_metadata entirely is tolerated", () => {
  const out = mapSupabaseUser({
    id: "u-3",
    email: "raw@example.com",
  });
  assert.equal(out.email, "raw@example.com");
  assert.equal(out.display_name, "raw@example.com");
  assert.equal(out.auth_provider, "email");
  assert.equal(out.simulated, false);
});

test("mapSupabaseUser: simulated Google sign-in carries provider and simulated flag", () => {
  const out = mapSupabaseUser({
    id: "u-4",
    email: null,
    is_anonymous: true,
    user_metadata: {
      auth_provider: "google",
      simulated: true,
      display_name: "Google user",
      email: "google-simulated@massanapp.local",
    },
  });
  assert.equal(out.auth_provider, "google");
  assert.equal(out.simulated, true);
  assert.equal(out.display_name, "Google user");
  assert.equal(out.email, "google-simulated@massanapp.local");
});

test("mapSupabaseUser: simulated Microsoft sign-in carries provider and simulated flag", () => {
  const out = mapSupabaseUser({
    id: "u-5",
    email: null,
    is_anonymous: true,
    user_metadata: {
      auth_provider: "microsoft",
      simulated: true,
      display_name: "Microsoft user",
      email: "microsoft-simulated@massanapp.local",
    },
  });
  assert.equal(out.auth_provider, "microsoft");
  assert.equal(out.simulated, true);
  assert.equal(out.display_name, "Microsoft user");
});

test("mapSupabaseUser: anonymous user without provider metadata falls back to 'anonymous'", () => {
  // Defensive path. The prototype's simulated social buttons always
  // stamp `auth_provider`, so this branch fires only if Supabase
  // returns an anonymous session from an unexpected code path.
  const out = mapSupabaseUser({
    id: "u-6",
    email: null,
    is_anonymous: true,
    user_metadata: {},
  });
  assert.equal(out.auth_provider, "anonymous");
  assert.equal(out.simulated, false);
  assert.equal(out.email, "");
  assert.equal(out.display_name, "Guest");
});

test("mapSupabaseUser: app_metadata.provider is used when user_metadata.auth_provider is missing", () => {
  // Future OAuth migration (see agent/tasks_blocked/migrate-auth-to-supabase.md):
  // real OAuth providers populate app_metadata.provider rather than
  // user_metadata.auth_provider. The mapping must recognize both.
  const out = mapSupabaseUser({
    id: "u-7",
    email: "real-google@example.com",
    user_metadata: {},
    app_metadata: { provider: "google" },
  });
  assert.equal(out.auth_provider, "google");
  assert.equal(out.simulated, false);
});

test("mapSupabaseUser: is_anonymous inferred from missing email + simulated metadata", () => {
  // Older Supabase JS clients did not expose `is_anonymous` directly.
  // `mapSupabaseUser` infers anonymity from the combination of a missing
  // email and a `simulated` flag in metadata. A fallback without a
  // stamped provider must still land on "anonymous" rather than "email".
  const out = mapSupabaseUser({
    id: "u-8",
    email: null,
    user_metadata: { simulated: true },
  });
  assert.equal(out.auth_provider, "anonymous");
  assert.equal(out.simulated, true);
});

test("mapSupabaseUser: simulated flag is coerced to a plain boolean", () => {
  const out = mapSupabaseUser({
    id: "u-9",
    email: "real@example.com",
    user_metadata: { simulated: 1 },
  });
  assert.equal(out.simulated, true);
  assert.equal(typeof out.simulated, "boolean");
});
