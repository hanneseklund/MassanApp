// My Pages view: shows the signed-in user's profile summary, a link
// to My Tickets, and the newsletter preferences component. Visitors
// who arrive at #/me without a session see a sign-in prompt.

const PROVIDER_KEYS = {
  email: "providers.email",
  google: "providers.google",
  microsoft: "providers.microsoft",
  anonymous: "providers.anonymous",
};

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
  };
}
