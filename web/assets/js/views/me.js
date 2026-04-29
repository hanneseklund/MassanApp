// My Pages view: shows the signed-in user's profile summary, a link
// to My Tickets, the Points section (balance + recent transactions),
// and the newsletter preferences component. Visitors who arrive at
// #/me without a session see a sign-in prompt.

const PROVIDER_KEYS = {
  email: "providers.email",
  google: "providers.google",
  microsoft: "providers.microsoft",
  anonymous: "providers.anonymous",
};

const TRANSACTION_SOURCE_KEYS = {
  ticket: "points.tx_source.ticket",
  food: "points.tx_source.food",
  addon_redemption: "points.tx_source.addon_redemption",
  merch_redemption: "points.tx_source.merch_redemption",
};

const RECENT_TRANSACTIONS_LIMIT = 5;

function providerLabel(provider) {
  const key = PROVIDER_KEYS[provider];
  if (key) return Alpine.store("lang").t(key);
  return provider;
}

export function meView() {
  return {
    providerLabel,
    user() {
      return Alpine.store("session").user;
    },
    isSimulated() {
      return !!this.user()?.simulated;
    },
    async signOut() {
      try {
        await Alpine.store("session").signOut();
      } catch (err) {
        console.warn("Sign-out failed:", err.message);
      }
      Alpine.store("app").goCalendar();
    },
    openTickets() {
      Alpine.store("app").goTickets();
    },
    openPointsShop() {
      Alpine.store("app").goPoints();
    },
    ticketCountHint() {
      const user = this.user();
      if (!user) return "";
      const count = Alpine.store("tickets").forUser(user.id).length;
      const t = Alpine.store("lang").t.bind(Alpine.store("lang"));
      if (!count) return t("me.no_tickets_hint");
      return count === 1
        ? t("me.one_ticket_hint")
        : t("me.n_tickets_hint", { count });
    },
    pointsError() {
      return Alpine.store("points").error;
    },
    pointsBalance() {
      return Alpine.store("points").balance;
    },
    pointsBalanceLabel() {
      const balance = this.pointsBalance();
      return Alpine.store("lang").t("points.balance_value", {
        points: balance,
      });
    },
    recentTransactions() {
      return Alpine.store("points").transactions.slice(
        0,
        RECENT_TRANSACTIONS_LIMIT,
      );
    },
    transactionSourceLabel(source) {
      const key = TRANSACTION_SOURCE_KEYS[source] || "points.tx_source.other";
      return Alpine.store("lang").t(key);
    },
    transactionEventLabel(eventId) {
      const lang = Alpine.store("lang");
      if (!eventId) {
        return lang.t("points.tx_venue_wide");
      }
      const event = Alpine.store("catalog").eventById(eventId);
      return event ? lang.pick(event.name) : eventId;
    },
    transactionDeltaLabel(delta) {
      const t = Alpine.store("lang").t.bind(Alpine.store("lang"));
      const key =
        delta >= 0 ? "points.tx_delta_positive" : "points.tx_delta_negative";
      return t(key, { delta });
    },
  };
}
