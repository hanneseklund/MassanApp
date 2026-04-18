// Filter state for the calendar view: free-text query, type,
// category, and month.

export function filtersStore() {
  return {
    query: "",
    type: "",
    category: "",
    month: "",
  };
}
