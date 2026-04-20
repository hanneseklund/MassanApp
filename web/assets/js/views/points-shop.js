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
import { createRedemptionController } from "../util/redemption.js";

export function pointsShopView() {
  return {
    // Shared redemption controller: per-session stock adjustments,
    // pending indicator, last-success banner, and error. See
    // util/redemption.js. The event add-ons section on views/event.js
    // uses the same factory so the two surfaces stay in sync.
    redemption: createRedemptionController({
      source: "merch_redemption",
      insufficientKey: "shop.insufficient_balance",
      soldOutKey: "shop.sold_out",
      genericErrorKey: "shop.err_generic",
      requireSignIn: () => Alpine.store("app").goAuth({ view: "points" }),
    }),

    init() {
      this.$watch(
        () => Alpine.store("app").view,
        (view) => {
          if (view !== "points") {
            this.redemption.lastRedemption = null;
            this.redemption.error = "";
          }
        },
      );
      this.$watch(
        () => Alpine.store("session").user?.id,
        () => {
          this.redemption.reset();
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

    balanceLabel() {
      return Alpine.store("lang").t("points.balance_value", {
        points: Alpine.store("points").balance,
      });
    },
  };
}
