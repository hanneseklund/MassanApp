// Food view: three-step simulated food ordering flow rendered inside
// the event "Food" subview. Mirrors the ticket purchase flow in
// purchase.js — local Alpine state owns the step counter and form
// values; the persisted order is written through
// `Alpine.store("foodOrders").add` once simulated payment succeeds.
//
// Step 1: pick a menu (10 static entries from util/food.js).
// Step 2: pick delivery (pickup location OR restaurant timeslot) and
//         confirm with a simulated payment.
// Step 3: confirmation screen with the transaction reference.

import {
  FOOD_MENUS,
  PICKUP_LOCATIONS,
  RESTAURANTS,
  menuById,
  pickupById,
  restaurantById,
  canonicalMenuLabel,
  canonicalPickupLabel,
  canonicalRestaurantLabel,
  upcomingTimeslots,
} from "../util/food.js";
import { simulatedPayment } from "../simulations/payment.js";
import { pointsForFoodOrder } from "../util/points.js";

export function foodView() {
  return {
    step: 1,
    menuId: null,
    deliveryMode: "pickup",
    pickupId: null,
    restaurantId: null,
    timeslotId: null,
    timeslots: [],
    processing: false,
    error: "",
    confirmedOrder: null,
    menus: FOOD_MENUS,
    pickupLocations: PICKUP_LOCATIONS,
    restaurants: RESTAURANTS,

    init() {
      this.$watch(
        () => [
          Alpine.store("app").view,
          Alpine.store("app").eventSubview,
          Alpine.store("app").eventId,
          Alpine.store("session").user?.id,
        ],
        () => {
          if (
            Alpine.store("app").view === "event" &&
            Alpine.store("app").eventSubview === "food"
          ) {
            this._hydrate();
          }
        }
      );
      this._hydrate();
    },

    _hydrate() {
      this.step = 1;
      this.menuId = null;
      this.deliveryMode = "pickup";
      this.pickupId = null;
      this.restaurantId = null;
      this.timeslotId = null;
      this.timeslots = upcomingTimeslots();
      this.processing = false;
      this.error = "";
      this.confirmedOrder = null;
    },

    event() {
      const id = Alpine.store("app").eventId;
      return id ? Alpine.store("catalog").eventById(id) : null;
    },

    selectedMenu() {
      return menuById(this.menuId);
    },

    selectedPickup() {
      return pickupById(this.pickupId);
    },

    selectedRestaurant() {
      return restaurantById(this.restaurantId);
    },

    selectedTimeslot() {
      return this.timeslots.find((s) => s.id === this.timeslotId) ?? null;
    },

    confirmedExtras() {
      const id = this.confirmedOrder?.menu_id;
      if (!id) return [];
      return menuById(id)?.extras ?? [];
    },

    setDeliveryMode(mode) {
      this.deliveryMode = mode;
      this.error = "";
    },

    goToStep(step) {
      this.step = step;
      this.error = "";
    },

    continueToDelivery() {
      if (!this.menuId) {
        this.error = Alpine.store("lang").t("food.err_pick_menu");
        return;
      }
      this.goToStep(2);
    },

    async confirm() {
      const lang = Alpine.store("lang");
      const ev = this.event();
      const menu = this.selectedMenu();
      if (!ev || !menu) {
        this.error = lang.t("food.err_pick_menu_first");
        this.step = 1;
        return;
      }
      if (!Alpine.store("session").isSignedIn) {
        Alpine.store("app").goAuth({
          view: "event",
          eventId: ev.id,
          eventSubview: "food",
        });
        return;
      }
      const user = Alpine.store("session").user;
      let deliveryId = null;
      let deliveryLabel = null;
      let timeslotFrom = null;
      let timeslotTo = null;
      if (this.deliveryMode === "pickup") {
        const pickup = this.selectedPickup();
        if (!pickup) {
          this.error = lang.t("food.err_pick_pickup");
          return;
        }
        deliveryId = pickup.id;
        deliveryLabel = canonicalPickupLabel(pickup.id);
      } else if (this.deliveryMode === "timeslot") {
        const restaurant = this.selectedRestaurant();
        const slot = this.selectedTimeslot();
        if (!restaurant || !slot) {
          this.error = lang.t("food.err_pick_slot");
          return;
        }
        deliveryId = `${restaurant.id}:${slot.id}`;
        deliveryLabel = `${canonicalRestaurantLabel(restaurant.id)} · ${slot.label}`;
        timeslotFrom = slot.from;
        timeslotTo = slot.to;
      } else {
        this.error = lang.t("food.err_pick_delivery");
        return;
      }
      this.error = "";
      this.processing = true;
      try {
        const payment = await simulatedPayment({
          user_id: user.id,
          event_id: ev.id,
          menu_id: menu.id,
          delivery_mode: this.deliveryMode,
          delivery_id: deliveryId,
        });
        const draft = {
          id: crypto.randomUUID(),
          user_id: user.id,
          event_id: ev.id,
          menu_id: menu.id,
          menu_label: canonicalMenuLabel(menu.id),
          price: menu.price,
          delivery_mode: this.deliveryMode,
          delivery_id: deliveryId,
          delivery_label: deliveryLabel,
          timeslot_from: timeslotFrom,
          timeslot_to: timeslotTo,
          transaction_ref: payment.transaction_ref,
          ordered_at: new Date().toISOString(),
        };
        const saved = await Alpine.store("foodOrders").add(draft);
        // Award points for the simulated order. `tryEarn` swallows a
        // failed insert so the user-visible "order placed" outcome
        // stands; the failure surfaces through the points store's
        // `error` state instead.
        await Alpine.store("points").tryEarn({
          source: "food",
          source_ref: saved.id,
          amount: pointsForFoodOrder(saved),
          event_id: saved.event_id,
        });
        this.confirmedOrder = saved;
        this.step = 3;
      } catch (err) {
        this.error = err.message || lang.t("food.err_generic");
      } finally {
        this.processing = false;
      }
    },
  };
}
