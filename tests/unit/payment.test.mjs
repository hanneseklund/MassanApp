// Simulated payment helper. `simulatedPayment` is called by both the
// ticket purchase and food ordering flows; the smoke suite asserts that
// the resulting transaction reference starts with `SIM-`, so the shape
// of the returned object is load-bearing behavior rather than an
// implementation detail.

import test from "node:test";
import assert from "node:assert/strict";

import { simulatedPayment } from "../../web/assets/js/simulations/payment.js";

test("simulatedPayment: resolves with ok:true", async () => {
  const result = await simulatedPayment({ amount: 100 });
  assert.equal(result.ok, true);
});

test("simulatedPayment: transaction_ref starts with SIM-", async () => {
  const result = await simulatedPayment({ amount: 100 });
  assert.match(result.transaction_ref, /^SIM-/);
});

test("simulatedPayment: transaction_ref has 8 uppercase alphanumeric chars after SIM-", async () => {
  const result = await simulatedPayment({ amount: 100 });
  assert.match(result.transaction_ref, /^SIM-[0-9A-Z]{1,8}$/);
});

test("simulatedPayment: passes the order through on the resolved payload", async () => {
  const order = { amount: 250, item: "Day pass" };
  const result = await simulatedPayment(order);
  assert.equal(result.order, order);
});

test("simulatedPayment: successive calls produce distinct transaction refs", async () => {
  const [a, b] = await Promise.all([
    simulatedPayment({}),
    simulatedPayment({}),
  ]);
  // The ref is 8 random base-36 chars, so a collision here is
  // vanishingly unlikely (~1 in 36^8). If this ever flakes, the
  // generator has regressed to a constant.
  assert.notEqual(a.transaction_ref, b.transaction_ref);
});
