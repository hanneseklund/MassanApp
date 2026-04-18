// Singleton Supabase client. A single client per page keeps the auth
// session consistent and lets `onAuthStateChange` fan out to every
// store that subscribes. The URL and publishable key come from
// window.MASSANAPP_ENV (set in assets/env.js).

let client = null;

export function supabaseClient() {
  if (client) return client;
  const env = window.MASSANAPP_ENV;
  if (!env?.SUPABASE_URL || !env?.SUPABASE_ANON_KEY) {
    throw new Error(
      "Supabase config missing. Check that assets/env.js is loaded.",
    );
  }
  if (!window.supabase?.createClient) {
    throw new Error("Supabase JS SDK not loaded.");
  }
  client = window.supabase.createClient(
    env.SUPABASE_URL,
    env.SUPABASE_ANON_KEY,
  );
  return client;
}
