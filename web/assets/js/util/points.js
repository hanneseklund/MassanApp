// Points earning rules. Per the functional spec:
//   - A successful ticket purchase awards 100 points per ticket.
//   - A successful food order awards 1 point per SEK of the menu price.
// The helpers are pure so they unit test without a browser; the
// points store calls them from the purchase and food-ordering views
// after the simulated payment resolves.

export const POINTS_PER_TICKET = 100;

// Pull an integer SEK amount out of a menu's `price` string. The
// food catalog in util/food.js stores prices as strings like
// "SEK 129" / "SEK 39"; this extracts the digits so the earning
// calculator does not have to hardcode every menu's price. Falls
// back to 0 on anything it cannot parse so a malformed row never
// crashes the purchase flow.
function parseSekPrice(priceString) {
  if (typeof priceString !== "string") return 0;
  const match = priceString.match(/(\d+)/);
  return match ? parseInt(match[1], 10) : 0;
}

export function pointsForTicket(_ticket) {
  return POINTS_PER_TICKET;
}

export function pointsForFoodOrder(order) {
  if (!order) return 0;
  return parseSekPrice(order.price);
}
