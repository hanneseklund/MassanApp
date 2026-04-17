// Shared Supabase prototype config. Committed on purpose: the
// publishable (anon) key is designed to be public and is gated by
// Row Level Security in supabase/migrations/0001_init.sql. The
// service-role key is never committed or used by the frontend.
//
// To point a local dev run at a different Supabase project, create
// web/assets/env.local.js (gitignored) that reassigns window.MASSANAPP_ENV
// and include it via <script src="assets/env.local.js"></script> after
// this file in index.html.

window.MASSANAPP_ENV = {
  SUPABASE_URL: "https://esvyrbsypfgpdhijyywz.supabase.co",
  SUPABASE_ANON_KEY: "sb_publishable_eWlItdVFrEu0nq31AjjN1w_wNLvJ_au",
};
