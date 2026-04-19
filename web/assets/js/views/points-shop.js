// Points shop view: venue-wide merchandise catalog, reachable at
// `#/points`. Mirrors the event add-ons section on `views/event.js`,
// but without an event context — merch rows have no `event_id` and
// the redemption transaction records `event_id = null`.
//
// Signed-out visitors are redirected to `auth` and returned here
// after sign-in. Redemption writes a negative-delta
// `point_transactions` row via the `points` store and surfaces a
// confirmation banner with the `simulated` chip.

import { logoDataUri } from "../util/placeholders.js";

export function pointsShopView() {
  return {
    // Per-session local stock adjustments. Prototype does not
    // decrement the database row (see the functional spec's
    // "Stock is advisory" note); the value here only reflects what
    // the current session redeemed so the "X left" label changes
    // after a redemption.
    merchStockConsumed: {},
    merchRedeemPending: {},
    lastRedemption: null,
    shopError: "",

    init() {
      this.$watch(
        () => Alpine.store("app").view,
        (view) => {
          if (view !== "points") {
            this.lastRedemption = null;
            this.shopError = "";
          }
        },
      );
      this.$watch(
        () => Alpine.store("session").user?.id,
        () => {
          this.merchStockConsumed = {};
          this.merchRedeemPending = {};
          this.lastRedemption = null;
          this.shopError = "";
        },
      );
    },

    items() {
      return Alpine.store("catalog").activeMerchandise();
    },

    merchImage(item) {
      if (item?.image) return item.image;
      return logoDataUri(item?.name ?? "");
    },

    remainingStock(item) {
      if (item.stock == null) return null;
      const consumed = this.merchStockConsumed[item.id] || 0;
      return Math.max(0, item.stock - consumed);
    },

    canRedeem(item) {
      if (this.merchRedeemPending[item.id]) return false;
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
        return lang.t("shop.insufficient_balance", {
          cost: item.points_cost,
        });
      }
      const remaining = this.remainingStock(item);
      if (remaining !== null && remaining <= 0) {
        return lang.t("shop.sold_out");
      }
      return "";
    },

    async redeem(item) {
      if (!item || !this.canRedeem(item)) return;
      if (!Alpine.store("session").isSignedIn) {
        Alpine.store("app").goAuth({ view: "points" });
        return;
      }
      this.shopError = "";
      this.merchRedeemPending[item.id] = true;
      try {
        await Alpine.store("points").redeem({
          source: "merch_redemption",
          source_ref: item.id,
          amount: item.points_cost,
          event_id: null,
        });
        this.merchStockConsumed[item.id] =
          (this.merchStockConsumed[item.id] || 0) + 1;
        this.lastRedemption = {
          merch_id: item.id,
          name: item.name,
          cost: item.points_cost,
          at: new Date().toISOString(),
        };
      } catch (err) {
        this.shopError =
          err.message || Alpine.store("lang").t("shop.err_generic");
      } finally {
        this.merchRedeemPending[item.id] = false;
      }
    },

    dismissLastRedemption() {
      this.lastRedemption = null;
    },

    balanceLabel() {
      return Alpine.store("lang").t("points.balance_value", {
        points: Alpine.store("points").balance,
      });
    },
  };
}
