// `simulatedEmail(kind, payload)` — logs a structured record to the
// browser console on prototype hosts (local dev and the Cloudflare
// Pages preview) so reviewers and the smoke suite can see the
// would-be email. Silent on any other host. The kind values are
// documented in docs/implementation-specification.md.

export function simulatedEmail(kind, payload) {
  const host = typeof window !== "undefined" ? window.location?.hostname : "";
  const isPrototypeHost =
    !host ||
    host === "localhost" ||
    host === "127.0.0.1" ||
    host.endsWith(".local") ||
    host.endsWith(".pages.dev");
  if (isPrototypeHost && typeof console !== "undefined") {
    console.info("[simulatedEmail]", kind, payload);
  }
}
