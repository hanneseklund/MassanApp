# Add automated smoke coverage for food ordering

The food ordering feature (issue #15) is implemented end-to-end: an
event Food tab, a 10-menu picker, pickup/timeslot delivery selection,
simulated payment, and persisted rows in `public.food_orders`. The
smoke checklist in `docs/installation-testing-specification.md` only
verifies that the Food tab renders the menu picker; it does not yet
exercise an actual order through to confirmation.

The Playwright suite at `tests/playwright/smoke.spec.js` mirrors the
checklist. It currently asserts the Food tab is reachable (step 5)
but does not place an order.

## What to add

1. Add a new numbered section to the smoke checklist after "Newsletter"
   (call it "Food ordering (simulated)") with steps that:
   - Sign in with the smoke account from step 12.
   - Open `Nordbygg 2026` → Food.
   - Pick any menu, continue, pick a pickup location, confirm.
   - Assert the confirmation screen shows the `simulated` chip, a
     `SIM-` transaction reference, the chosen menu label, and the
     pickup location label.
   - Repeat with the timeslot delivery mode and assert the
     confirmation references the chosen restaurant + timeslot.

2. Add matching assertions to `tests/playwright/smoke.spec.js` in a new
   `test.describe("Food ordering (simulated)", ...)` block. Follow the
   pattern in the existing `Ticket purchase (simulated)` block. Use
   serial mode so it runs after the registration block has produced a
   signed-in account.

3. The food order rows persist to `public.food_orders` under RLS, so
   the smoke account will accumulate rows over time. Document this
   under the existing "Smoke testing against the shared project"
   note in the same way the ticket / newsletter rows are called out.

4. Confirm that the food order's `delivery_label` field stores the
   canonical English label (`canonicalPickupLabel`,
   `canonicalRestaurantLabel`) so the wallet entry does not flip
   language across language switches — same rule as
   `ticket_type_label`. The view already does this; the smoke test
   should make the assertion explicit by toggling language after
   placing the order and confirming the persisted label.

## Why this is its own task

The current improvement pass reconciled the documentation gap (the
food feature was implemented without updating the specs). Adding the
full automated smoke coverage is a substantive test addition that
deserves its own pull request rather than being bundled with the
docs reconciliation.
