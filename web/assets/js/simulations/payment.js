// `simulatedPayment(order)` — always resolves after a short delay with
// a plausible transaction reference. No payment service is contacted.

export function simulatedPayment(order) {
  return new Promise((resolve) => {
    const ref = "SIM-" + Math.random().toString(36).slice(2, 10).toUpperCase();
    setTimeout(() => resolve({ ok: true, transaction_ref: ref, order }), 600);
  });
}
