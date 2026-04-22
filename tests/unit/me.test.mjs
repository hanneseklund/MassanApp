// meView() in views/me.js is the My Pages view factory. Most of its
// methods are thin delegations to stores, but the points-transaction
// labeling (source, event, delta) and the ticket-count hint phrasing
// have enough branching to be worth pinning down. The recent-
// transactions slice also carries a hardcoded limit that should not
// quietly drift.
//
// Follows the Alpine.store stub pattern from my-tickets.test.mjs —
// no browser, no Supabase, no Alpine runtime.

import test from "node:test";
import assert from "node:assert/strict";

import { meView } from "../../web/assets/js/views/me.js";
import { withAlpine } from "./_alpine.mjs";

// Minimal lang stub. Returns `key` verbatim for lookups without params,
// or `key|k=v&...` when params are supplied, so tests can assert both
// the key chosen and the interpolation values without depending on
// i18n.js copy.
function langStub() {
  return {
    t(key, params) {
      if (!params) return key;
      const parts = Object.entries(params)
        .map(([k, v]) => `${k}=${v}`)
        .join("&");
      return `${key}|${parts}`;
    },
  };
}

function makeStores({
  user = null,
  tickets = [],
  points = { balance: 0, transactions: [], error: null },
  events = {},
} = {}) {
  return {
    lang: langStub(),
    session: { user },
    app: {},
    tickets: {
      forUser(userId) {
        return tickets.filter((ticket) => ticket.user_id === userId);
      },
    },
    points: {
      get balance() {
        return points.balance;
      },
      get transactions() {
        return points.transactions;
      },
      get error() {
        return points.error;
      },
    },
    catalog: {
      eventById(id) {
        return events[id] ?? null;
      },
    },
  };
}

test("isSimulated(): false when signed out, reflects user.simulated otherwise", () => {
  withAlpine(makeStores({ user: null }), () => {
    assert.equal(meView().isSimulated(), false);
  });
  withAlpine(makeStores({ user: { id: "u", simulated: true } }), () => {
    assert.equal(meView().isSimulated(), true);
  });
  withAlpine(makeStores({ user: { id: "u", simulated: false } }), () => {
    assert.equal(meView().isSimulated(), false);
  });
});

test("ticketCountHint(): empty string when signed out", () => {
  withAlpine(makeStores({ user: null }), () => {
    assert.equal(meView().ticketCountHint(), "");
  });
});

test("ticketCountHint(): picks the 0 / 1 / n copy variants", () => {
  withAlpine(makeStores({ user: { id: "u" }, tickets: [] }), () => {
    assert.equal(meView().ticketCountHint(), "me.no_tickets_hint");
  });
  withAlpine(
    makeStores({
      user: { id: "u" },
      tickets: [{ id: "t1", user_id: "u" }],
    }),
    () => {
      assert.equal(meView().ticketCountHint(), "me.one_ticket_hint");
    },
  );
  withAlpine(
    makeStores({
      user: { id: "u" },
      tickets: [
        { id: "t1", user_id: "u" },
        { id: "t2", user_id: "u" },
        { id: "t3", user_id: "u" },
      ],
    }),
    () => {
      assert.equal(meView().ticketCountHint(), "me.n_tickets_hint|count=3");
    },
  );
});

test("ticketCountHint(): only counts the signed-in user's tickets", () => {
  withAlpine(
    makeStores({
      user: { id: "u-1" },
      tickets: [
        { id: "t1", user_id: "u-1" },
        { id: "t2", user_id: "u-2" },
        { id: "t3", user_id: "u-2" },
      ],
    }),
    () => {
      assert.equal(meView().ticketCountHint(), "me.one_ticket_hint");
    },
  );
});

test("pointsBalance() / pointsError(): delegate to the points store", () => {
  withAlpine(
    makeStores({
      user: { id: "u" },
      points: { balance: 237, transactions: [], error: "boom" },
    }),
    () => {
      assert.equal(meView().pointsBalance(), 237);
      assert.equal(meView().pointsError(), "boom");
    },
  );
});

test("pointsBalanceLabel(): formats through the lang store with the balance", () => {
  withAlpine(
    makeStores({
      user: { id: "u" },
      points: { balance: 42, transactions: [], error: null },
    }),
    () => {
      assert.equal(
        meView().pointsBalanceLabel(),
        "points.balance_value|points=42",
      );
    },
  );
});

test("recentTransactions(): returns up to the 5 most recent transactions in store order", () => {
  const transactions = Array.from({ length: 8 }, (_, i) => ({
    id: `tx-${i}`,
    delta: i,
  }));
  withAlpine(
    makeStores({
      user: { id: "u" },
      points: { balance: 0, transactions, error: null },
    }),
    () => {
      const ids = meView()
        .recentTransactions()
        .map((t) => t.id);
      assert.deepEqual(ids, ["tx-0", "tx-1", "tx-2", "tx-3", "tx-4"]);
    },
  );
});

test("transactionSourceLabel(): known sources map to dedicated keys", () => {
  withAlpine(makeStores(), () => {
    const view = meView();
    assert.equal(view.transactionSourceLabel("ticket"), "points.tx_source.ticket");
    assert.equal(view.transactionSourceLabel("food"), "points.tx_source.food");
    assert.equal(
      view.transactionSourceLabel("addon_redemption"),
      "points.tx_source.addon_redemption",
    );
    assert.equal(
      view.transactionSourceLabel("merch_redemption"),
      "points.tx_source.merch_redemption",
    );
  });
});

test("transactionSourceLabel(): unknown sources fall back to the 'other' key", () => {
  withAlpine(makeStores(), () => {
    const view = meView();
    assert.equal(view.transactionSourceLabel("unexpected"), "points.tx_source.other");
    assert.equal(view.transactionSourceLabel(null), "points.tx_source.other");
    assert.equal(view.transactionSourceLabel(undefined), "points.tx_source.other");
  });
});

test("transactionEventLabel(): null / missing event_id resolves to the venue-wide key", () => {
  withAlpine(makeStores(), () => {
    const view = meView();
    assert.equal(view.transactionEventLabel(null), "points.tx_venue_wide");
    assert.equal(view.transactionEventLabel(undefined), "points.tx_venue_wide");
    assert.equal(view.transactionEventLabel(""), "points.tx_venue_wide");
  });
});

test("transactionEventLabel(): known event ids render the event name; unknown ids echo the id", () => {
  withAlpine(
    makeStores({
      events: {
        "nordbygg-2026": { id: "nordbygg-2026", name: "Nordbygg 2026" },
      },
    }),
    () => {
      const view = meView();
      assert.equal(view.transactionEventLabel("nordbygg-2026"), "Nordbygg 2026");
      assert.equal(view.transactionEventLabel("missing"), "missing");
    },
  );
});

test("transactionDeltaLabel(): positive and zero deltas use the positive-sign key", () => {
  withAlpine(makeStores(), () => {
    const view = meView();
    assert.equal(view.transactionDeltaLabel(100), "points.tx_delta_positive|delta=100");
    assert.equal(view.transactionDeltaLabel(0), "points.tx_delta_positive|delta=0");
  });
});

test("transactionDeltaLabel(): negative deltas use the negative-sign key", () => {
  withAlpine(makeStores(), () => {
    const view = meView();
    assert.equal(
      view.transactionDeltaLabel(-75),
      "points.tx_delta_negative|delta=-75",
    );
  });
});

test("providerLabel(): known providers map to dedicated keys; unknown values pass through", () => {
  withAlpine(makeStores(), () => {
    const view = meView();
    assert.equal(view.providerLabel("email"), "providers.email");
    assert.equal(view.providerLabel("google"), "providers.google");
    assert.equal(view.providerLabel("microsoft"), "providers.microsoft");
    assert.equal(view.providerLabel("anonymous"), "providers.anonymous");
    assert.equal(view.providerLabel("future-provider"), "future-provider");
  });
});
