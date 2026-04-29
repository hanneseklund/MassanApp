// Event view: mini-homepage scoped to the currently selected event.
// Renders the event hero and a stacked layout where every section
// (News, Articles, Program, Exhibitors, Practical info, Food,
// Newsletter) appears one below the other. Lists that can grow long
// truncate to `INLINE_LIMIT` items inline with a "see all" link to a
// dedicated full-list page; Practical info and Newsletter render in
// full inline. Dedicated `#/event/<id>/<section>` routes render only
// the full list plus a back link, driven off `$store.app.eventSubview`.

import {
  formatDates,
  formatShortDate,
  formatDayHeading,
} from "../util/dates.js";
import { ticketCtaLabel } from "../util/sections.js";
import { logoDataUri, avatarDataUri } from "../util/placeholders.js";
import { createRedemptionController } from "../util/redemption.js";
import { FOOD_MENUS, themedMenuForEvent } from "../util/food.js";

const OVERRIDE_KEYS = {
  entrance: "overrides.entrance",
  bag_rules: "overrides.bag_rules",
  access_notes: "overrides.access_notes",
};

const INLINE_LIMIT = 5;

export function eventView() {
  return {
    INLINE_LIMIT,
    foodMenus: FOOD_MENUS,
    exhibitorQuery: "",
    // Shared redemption controller: per-session stock adjustments,
    // pending indicator, last-success banner, and error. See
    // util/redemption.js. The points-shop view uses the same factory
    // so the two surfaces stay in sync.
    redemption: createRedemptionController({
      source: "addon_redemption",
      eventIdFor: (addon) => addon.event_id ?? null,
      insufficientKey: "event.addons_insufficient_balance",
      soldOutKey: "event.addons_sold_out",
      genericErrorKey: "event.addons_err_generic",
    }),
    formatDates,
    formatShortDate,
    formatDayHeading,
    ticketCtaLabel,
    init() {
      this.$watch(
        () => Alpine.store("app").eventId,
        () => {
          this.redemption.reset();
        },
      );
      // The `practical` and `newsletter` subview routes redirect to the
      // stacked landing view and request a scroll to the matching
      // section anchor (see stores/app.js). Consume any pending request
      // once the event view is mounted, and again whenever the field
      // changes.
      this.$nextTick(() => this._consumePendingScroll());
      this.$watch(
        () => Alpine.store("app").pendingScrollSection,
        () => this._consumePendingScroll(),
      );
    },
    _consumePendingScroll() {
      const app = Alpine.store("app");
      const target = app.pendingScrollSection;
      if (!target) return;
      app.pendingScrollSection = null;
      // Wait one more frame so the section template has rendered.
      requestAnimationFrame(() => {
        const el = document.getElementById(`event-section-${target}`);
        if (el) el.scrollIntoView({ behavior: "smooth", block: "start" });
      });
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
    inlineNews() {
      return this.news().slice(0, INLINE_LIMIT);
    },
    hasMoreNews() {
      return this.news().length > INLINE_LIMIT;
    },
    inlineArticles() {
      return this.articles().slice(0, INLINE_LIMIT);
    },
    hasMoreArticles() {
      return this.articles().length > INLINE_LIMIT;
    },
    // Truncate the program to `INLINE_LIMIT` sessions in total across
    // all days, keeping the by-day grouping. The dedicated program page
    // shows every day with every session.
    inlineProgramByDay() {
      const groups = this.programByDay();
      const result = [];
      let remaining = INLINE_LIMIT;
      for (const group of groups) {
        if (remaining <= 0) break;
        const sessions = group.sessions.slice(0, remaining);
        if (sessions.length === 0) continue;
        result.push({ day: group.day, sessions });
        remaining -= sessions.length;
      }
      return result;
    },
    programSessionCount() {
      return this.programByDay().reduce(
        (sum, group) => sum + group.sessions.length,
        0,
      );
    },
    hasMoreProgram() {
      return this.programSessionCount() > INLINE_LIMIT;
    },
    exhibitorsForEvent() {
      const ev = this.event();
      if (!ev) return [];
      return Alpine.store("catalog").exhibitorsForEvent(ev.id);
    },
    inlineExhibitors() {
      return this.exhibitorsForEvent().slice(0, INLINE_LIMIT);
    },
    hasMoreExhibitors() {
      return this.exhibitorsForEvent().length > INLINE_LIMIT;
    },
    themedFoodMenu() {
      return themedMenuForEvent(this.event());
    },
    themedFoodMenuItems() {
      return this.themedFoodMenu()?.items ?? [];
    },
    inlineFoodMenus() {
      // Show event-themed items at the top of the preview, then fill
      // the remaining slots with regular menu items.
      const themed = this.themedFoodMenuItems();
      return [...themed, ...this.foodMenus].slice(0, INLINE_LIMIT);
    },
    hasMoreFoodMenus() {
      const total = this.themedFoodMenuItems().length + this.foodMenus.length;
      return total > INLINE_LIMIT;
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
      const lang = Alpine.store("lang");
      return list.filter(
        (e) =>
          e.name.toLowerCase().includes(q) ||
          (e.booth ?? "").toLowerCase().includes(q) ||
          lang.pick(e.description).toLowerCase().includes(q)
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
