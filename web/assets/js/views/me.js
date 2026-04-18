// My Pages view: shows the signed-in user's profile summary, a link
// to My Tickets, and the newsletter preferences component. Visitors
// who arrive at #/me without a session see a sign-in prompt.

const PROVIDER_LABELS = {
  email: "Email",
  google: "Google",
  microsoft: "Microsoft",
  anonymous: "Guest",
};

function providerLabel(provider) {
  return PROVIDER_LABELS[provider] ?? provider;
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
      if (!count) return "No tickets yet";
      return count === 1 ? "1 ticket" : `${count} tickets`;
    },
  };
}
