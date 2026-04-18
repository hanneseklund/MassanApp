// `simulatedEmail(kind, payload)` — no-op in production hosting; logs a
// structured record to the console during development so reviewers can
// see the would-be email. The kind values are documented in
// docs/implementation-specification.md.

export function simulatedEmail(kind, payload) {
  const host = typeof window !== "undefined" ? window.location?.hostname : "";
  const isDev =
    !host ||
    host === "localhost" ||
    host === "127.0.0.1" ||
    host.endsWith(".local");
  if (isDev && typeof console !== "undefined") {
    console.info("[simulatedEmail]", kind, payload);
  }
}
