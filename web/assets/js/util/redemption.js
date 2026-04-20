// Shared redemption controller for the two points-spending surfaces:
// the event add-ons section on `views/event.js` and the venue-wide
// merchandise shop on `views/points-shop.js`. Both flows deduct points
// via `Alpine.store("points").redeem(...)` and track the same local
// state (per-session stock adjustments, pending indicator, last-success
// banner, error). Factoring the shared state + behaviour keeps the two
// surfaces from drifting — if the spec adds a new guard (e.g. a cool-off
// window) there is one place to add it.
//
// Stock is advisory in the prototype: `stockConsumed[item.id]` tracks
// only what this browser session redeemed so the "X left" label can
// tick down. The database row is not decremented (see the functional
// spec's "Stock is advisory" note).

export function createRedemptionController({
  source,
  eventIdFor = () => null,
  insufficientKey,
  soldOutKey,
  genericErrorKey,
  requireSignIn = null,
}) {
  return {
    stockConsumed: {},
    pending: {},
    lastRedemption: null,
    error: "",

    remainingStock(item) {
      if (item.stock == null) return null;
      const consumed = this.stockConsumed[item.id] || 0;
      return Math.max(0, item.stock - consumed);
    },

    canRedeem(item) {
      if (this.pending[item.id]) return false;
      if (Alpine.store("points").balance < (item.points_cost || 0)) {
        return false;
      }
      const remaining = this.remainingStock(item);
      if (remaining !== null && remaining <= 0) return false;
      return true;
    },

    disabledReason(item) {
      const lang = Alpine.store("lang");
      if (Alpine.store("points").balance < (item.points_cost || 0)) {
        return lang.t(insufficientKey, { cost: item.points_cost });
      }
      const remaining = this.remainingStock(item);
      if (remaining !== null && remaining <= 0) {
        return lang.t(soldOutKey);
      }
      return "";
    },

    async redeem(item) {
      if (!item || !this.canRedeem(item)) return;
      if (requireSignIn && !Alpine.store("session").isSignedIn) {
        requireSignIn();
        return;
      }
      this.error = "";
      this.pending[item.id] = true;
      try {
        await Alpine.store("points").redeem({
          source,
          source_ref: item.id,
          amount: item.points_cost,
          event_id: eventIdFor(item),
        });
        this.stockConsumed[item.id] =
          (this.stockConsumed[item.id] || 0) + 1;
        this.lastRedemption = {
          id: item.id,
          name: item.name,
          cost: item.points_cost,
          at: new Date().toISOString(),
        };
      } catch (err) {
        this.error =
          err.message || Alpine.store("lang").t(genericErrorKey);
      } finally {
        this.pending[item.id] = false;
      }
    },

    dismissLastRedemption() {
      this.lastRedemption = null;
    },

    reset() {
      this.stockConsumed = {};
      this.pending = {};
      this.lastRedemption = null;
      this.error = "";
    },
  };
}
