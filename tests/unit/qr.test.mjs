// Simulated ticket QR. The payload binds ticket id to event id; the
// SVG output is a deterministic visual stand-in, not a real QR code.

import test from "node:test";
import assert from "node:assert/strict";

import {
  ticketQrPayload,
  ticketQrSvgFor,
} from "../../web/assets/js/simulations/qr.js";

test("ticketQrPayload: embeds ticket id and event id", () => {
  const payload = ticketQrPayload({
    id: "ticket-123",
    event_id: "nordbygg-2026",
  });
  assert.match(payload, /^massan:ticket-123:nordbygg-2026:/);
});

test("ticketQrPayload: new tickets fall back to 'new' placeholder", () => {
  const payload = ticketQrPayload({ event_id: "nordbygg-2026" });
  assert.match(payload, /^massan:new:nordbygg-2026:/);
});

test("ticketQrPayload: same payload across events stays distinct", () => {
  const a = ticketQrPayload({ id: "shared", event_id: "event-a" });
  const b = ticketQrPayload({ id: "shared", event_id: "event-b" });
  assert.notEqual(a, b);
});

test("ticketQrSvgFor: prefers the stored qr_payload when present", () => {
  const svg = ticketQrSvgFor({
    id: "ignored-id",
    event_id: "ignored-event",
    qr_payload: "massan:stored:payload:salt",
  });
  assert.match(svg, /^<svg /);
  // The returned SVG is a visual matrix; we cannot reverse-engineer
  // the payload from it, but two identical payloads must render
  // identically (determinism).
  const again = ticketQrSvgFor({ qr_payload: "massan:stored:payload:salt" });
  assert.equal(svg, again);
});

test("ticketQrSvgFor: different payloads render different SVGs", () => {
  const svgA = ticketQrSvgFor({ qr_payload: "massan:a:event:salt" });
  const svgB = ticketQrSvgFor({ qr_payload: "massan:b:event:salt" });
  assert.notEqual(svgA, svgB);
});

test("ticketQrSvgFor: SVG includes an accessible label", () => {
  const svg = ticketQrSvgFor({ id: "t", event_id: "e" });
  assert.match(svg, /aria-label="Ticket QR code"/);
});
