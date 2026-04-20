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
    profile: {
      gender: "",
      country: "",
      region: "",
      visit_type: "",
      company: "",
      role: "",
    },
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

test("mapSupabaseUser: exposes user_metadata.profile with empty defaults", () => {
  // A fresh user with no saved profile still gets a fully-populated
  // profile object so the purchase view can read `user.profile.gender`
  // without guarding against undefined. Missing fields are empty
  // strings rather than null to match buildQuestionnairePayload's
  // round-trip contract.
  const out = mapSupabaseUser({
    id: "u-10",
    email: "noprofile@example.com",
    user_metadata: {},
  });
  assert.deepEqual(out.profile, {
    gender: "",
    country: "",
    region: "",
    visit_type: "",
    company: "",
    role: "",
  });
});

test("mapSupabaseUser: surfaces a saved profile for purchase pre-fill", () => {
  // Once a visitor completes a ticket purchase, the general-profile
  // answers are persisted to `user_metadata.profile` (see the Ticket
  // entity in docs/implementation-specification.md). The session
  // mapping must expose those fields so the next purchase pre-fills.
  const out = mapSupabaseUser({
    id: "u-11",
    email: "returning@example.com",
    user_metadata: {
      profile: {
        gender: "female",
        country: "Sweden",
        region: "Stockholm",
        visit_type: "professional",
        company: "Acme Construction",
        role: "Architect",
      },
    },
  });
  assert.equal(out.profile.gender, "female");
  assert.equal(out.profile.country, "Sweden");
  assert.equal(out.profile.region, "Stockholm");
  assert.equal(out.profile.visit_type, "professional");
  assert.equal(out.profile.company, "Acme Construction");
  assert.equal(out.profile.role, "Architect");
});

test("mapSupabaseUser: ignores a non-object profile and falls back to empty strings", () => {
  // Defensive: if Supabase somehow stores an unexpected shape (null,
  // a string, an array), the mapper must not crash the UI.
  for (const bogus of [null, "hello", 42, []]) {
    const out = mapSupabaseUser({
      id: "u-bogus",
      email: "bogus@example.com",
      user_metadata: { profile: bogus },
    });
    assert.equal(out.profile.visit_type, "");
    assert.equal(out.profile.company, "");
  }
});
