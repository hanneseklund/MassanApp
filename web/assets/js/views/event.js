// Event view: mini-homepage scoped to the currently selected event.
// Renders the event hero and fans out to the News, Articles, Program,
// Exhibitors (index and detail), Practical info, and Newsletter
// subviews via `$store.app.eventSubview`.

import {
  formatDates,
  formatShortDate,
  formatDayHeading,
} from "../util/dates.js";
import { SECTION_LABELS, ticketCtaLabel } from "../util/sections.js";
import { logoDataUri, avatarDataUri } from "../util/placeholders.js";

const OVERRIDE_KEYS = {
  entrance: "overrides.entrance",
  bag_rules: "overrides.bag_rules",
  access_notes: "overrides.access_notes",
};

export function eventView() {
  return {
    sections: SECTION_LABELS,
    exhibitorQuery: "",
    // Per-session local stock adjustments for add-ons. The prototype
    // does not decrement the database row (see the functional spec's
    // "Stock is advisory" note); redeemed items are counted here only
    // so the card's "X left" label reflects what the current session
    // redeemed. Keyed by addon id.
    addonStockConsumed: {},
    // Redeeming in progress for a given addon id, so the button can
    // show a "Redeeming…" state and we debounce double-taps.
    addonRedeemPending: {},
    // Last successful redemption, surfaced as a banner above the list
    // with the `simulated` chip. Cleared on event change or when the
    // user dismisses it.
    lastRedemption: null,
    addonError: "",
    formatDates,
    formatShortDate,
    formatDayHeading,
    ticketCtaLabel,
    init() {
      this.$watch(
        () => Alpine.store("app").eventId,
        () => {
          this.addonStockConsumed = {};
          this.addonRedeemPending = {};
          this.lastRedemption = null;
          this.addonError = "";
        },
      );
    },
    event() {
      const id = Alpine.store("app").eventId;
      return id ? Alpine.store("catalog").eventById(id) : null;
    },
    hasTicket() {
      const ev = this.event();
      const user = Alpine.store("session").user;
      if (!ev || !user) return false;
      return Alpine.store("tickets").hasForEvent(user.id, ev.id);
    },
    startPurchase() {
      const ev = this.event();
      if (ev) Alpine.store("app").startPurchase(ev.id);
    },
    addons() {
      const ev = this.event();
      return ev ? Alpine.store("catalog").addonsForEvent(ev.id) : [];
    },
    addonsVisible() {
      return this.hasTicket() && this.addons().length > 0;
    },
    addonImage(addon) {
      if (addon?.image) return addon.image;
      return this.event()?.branding?.hero_image ?? null;
    },
    addonRemainingStock(addon) {
      if (addon.stock == null) return null;
      const consumed = this.addonStockConsumed[addon.id] || 0;
      return Math.max(0, addon.stock - consumed);
    },
    addonCanRedeem(addon) {
      if (this.addonRedeemPending[addon.id]) return false;
      if (Alpine.store("points").balance < (addon.points_cost || 0)) {
        return false;
      }
      const remaining = this.addonRemainingStock(addon);
      if (remaining !== null && remaining <= 0) return false;
      return true;
    },
    addonDisabledReason(addon) {
      const lang = Alpine.store("lang");
      if (Alpine.store("points").balance < (addon.points_cost || 0)) {
        return lang.t("event.addons_insufficient_balance", {
          cost: addon.points_cost,
        });
      }
      const remaining = this.addonRemainingStock(addon);
      if (remaining !== null && remaining <= 0) {
        return lang.t("event.addons_sold_out");
      }
      return "";
    },
    async redeemAddon(addon) {
      if (!addon || !this.addonCanRedeem(addon)) return;
      const ev = this.event();
      if (!ev) return;
      this.addonError = "";
      this.addonRedeemPending[addon.id] = true;
      try {
        await Alpine.store("points").redeem({
          source: "addon_redemption",
          source_ref: addon.id,
          amount: addon.points_cost,
          event_id: ev.id,
        });
        this.addonStockConsumed[addon.id] =
          (this.addonStockConsumed[addon.id] || 0) + 1;
        this.lastRedemption = {
          addon_id: addon.id,
          name: addon.name,
          cost: addon.points_cost,
          at: new Date().toISOString(),
        };
      } catch (err) {
        this.addonError =
          err.message || Alpine.store("lang").t("event.addons_err_generic");
      } finally {
        this.addonRedeemPending[addon.id] = false;
      }
    },
    dismissLastRedemption() {
      this.lastRedemption = null;
    },
    news() {
      const ev = this.event();
      return ev ? Alpine.store("catalog").newsForEvent(ev.id) : [];
    },
    articles() {
      const ev = this.event();
      return ev ? Alpine.store("catalog").articlesForEvent(ev.id) : [];
    },
    programByDay() {
      const ev = this.event();
      return ev ? Alpine.store("catalog").programByDayForEvent(ev.id) : [];
    },
    sessionSpeakers(session) {
      if (!session.speaker_ids?.length) return [];
      return session.speaker_ids
        .map((id) => Alpine.store("catalog").speakerById(id))
        .filter(Boolean);
    },
    newsImage(item) {
      if (item?.hero_image) return item.hero_image;
      const ev = this.event();
      return ev?.branding?.hero_image ?? null;
    },
    articleImage(article) {
      if (article?.hero_image) return article.hero_image;
      const ev = this.event();
      return ev?.branding?.hero_image ?? null;
    },
    exhibitorLogo(exhibitor) {
      return exhibitor?.logo || logoDataUri(exhibitor?.name ?? "");
    },
    speakerAvatar(speaker) {
      return speaker?.avatar || avatarDataUri(speaker?.name ?? "");
    },
    filteredExhibitors() {
      const ev = this.event();
      if (!ev) return [];
      const list = Alpine.store("catalog").exhibitorsForEvent(ev.id);
      const q = this.exhibitorQuery.trim().toLowerCase();
      if (!q) return list;
      return list.filter(
        (e) =>
          e.name.toLowerCase().includes(q) ||
          (e.booth ?? "").toLowerCase().includes(q) ||
          (e.description ?? "").toLowerCase().includes(q)
      );
    },
    exhibitor() {
      const id = Alpine.store("app").exhibitorId;
      return id ? Alpine.store("catalog").exhibitorById(id) : null;
    },
    venue() {
      return Alpine.store("catalog").venue ?? {};
    },
    overrides() {
      return this.event()?.overrides ?? {};
    },
    hasOverrides() {
      return Object.keys(this.overrides()).length > 0;
    },
    overrideLabel(key) {
      const translationKey = OVERRIDE_KEYS[key];
      if (translationKey) return Alpine.store("lang").t(translationKey);
      return key.replace(/_/g, " ");
    },
  };
}
