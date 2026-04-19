// Session store: backed by Supabase Auth. `register`, `signIn`,
// `signOut`, and `simulatedSocialSignIn` call into the Supabase JS
// client; the store subscribes to `onAuthStateChange` so sign-in
// state, including token refresh and persisted sessions across
// reloads, propagates through the UI.

import { supabaseClient } from "../supabase.js";
import { activeTranslate } from "../i18n.js";

// Map a Supabase auth user into the flat shape the UI consumes. Works
// for email-backed users and for anonymous users carrying simulated
// social-sign-in metadata. Exported so the unit suite can exercise the
// provider-detection branches without a live Supabase session.
export function mapSupabaseUser(supabaseUser) {
  if (!supabaseUser) return null;
  const metadata = supabaseUser.user_metadata || {};
  const isAnonymous =
    supabaseUser.is_anonymous === true ||
    (!supabaseUser.email && !!metadata.simulated);
  const provider =
    metadata.auth_provider ||
    supabaseUser.app_metadata?.provider ||
    (isAnonymous ? "anonymous" : "email");
  const email = supabaseUser.email || metadata.email || "";
  const displayName =
    metadata.display_name || supabaseUser.email || "Guest";
  return {
    id: supabaseUser.id,
    email,
    display_name: displayName,
    auth_provider: provider,
    simulated: !!metadata.simulated,
  };
}

export function sessionStore() {
  return {
    user: null,
    loading: true,

    async init() {
      const db = supabaseClient();
      const { data, error } = await db.auth.getSession();
      if (error) {
        console.warn("Could not restore session:", error.message);
      }
      this.user = mapSupabaseUser(data?.session?.user);
      this.loading = false;
      db.auth.onAuthStateChange((_event, session) => {
        this.user = mapSupabaseUser(session?.user);
        Alpine.store("tickets")?._onSessionChange?.();
        Alpine.store("newsletter")?._onSessionChange?.();
      });
      Alpine.store("tickets")?._onSessionChange?.();
      Alpine.store("newsletter")?._onSessionChange?.();
    },

    get isSignedIn() {
      return !!this.user;
    },

    async register({ email, displayName, password }) {
      const trimmedEmail = String(email || "").trim();
      if (!trimmedEmail) {
        throw new Error(activeTranslate("auth.err_email_required"));
      }
      const db = supabaseClient();
      const { data, error } = await db.auth.signUp({
        email: trimmedEmail,
        password: String(password || ""),
        options: {
          data: {
            display_name:
              String(displayName || "").trim() || trimmedEmail,
            auth_provider: "email",
          },
        },
      });
      if (error) throw new Error(error.message);
      if (!data.session) {
        throw new Error(activeTranslate("auth.err_confirm_email"));
      }
      return this.user;
    },

    async signIn({ email, password }) {
      const trimmedEmail = String(email || "").trim();
      const db = supabaseClient();
      const { error } = await db.auth.signInWithPassword({
        email: trimmedEmail,
        password: String(password || ""),
      });
      if (error) {
        throw new Error(activeTranslate("auth.err_bad_credentials"));
      }
      return this.user;
    },

    async signOut() {
      const db = supabaseClient();
      const { error } = await db.auth.signOut();
      if (error) throw new Error(error.message);
    },

    // Simulated Google / Microsoft sign-in. Creates a Supabase
    // anonymous session and stamps provider metadata so the UI can
    // label the session as simulated. RLS treats the anonymous
    // user_id like any other for ticket and newsletter ownership.
    async simulatedSocialSignIn(provider) {
      if (!["google", "microsoft"].includes(provider)) {
        throw new Error(`Unknown provider: ${provider}`);
      }
      const displayName =
        provider === "google" ? "Google user" : "Microsoft user";
      const placeholderEmail = `${provider}-simulated@massanapp.local`;
      const db = supabaseClient();
      const { error } = await db.auth.signInAnonymously({
        options: {
          data: {
            auth_provider: provider,
            simulated: true,
            display_name: displayName,
            email: placeholderEmail,
          },
        },
      });
      if (error) {
        throw new Error(
          activeTranslate("auth.err_simulated_social", {
            provider,
            reason: error.message,
          }),
        );
      }
      return this.user;
    },
  };
}
