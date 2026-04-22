// Shared Alpine-store stub used by the view-level unit tests. Installs
// a minimal `globalThis.Alpine.store(id)` implementation backed by the
// `stores` map, runs `body`, and restores the previous `globalThis.Alpine`
// even if `body` throws. Awaits `body()` so the same helper works for
// sync and async test bodies. The filename is underscore-prefixed so the
// `tests/unit/*.test.mjs` glob in `npm run test:unit` skips it.

export async function withAlpine(stores, body) {
  const prev = globalThis.Alpine;
  globalThis.Alpine = {
    store(id) {
      return stores[id];
    },
  };
  try {
    return await body();
  } finally {
    globalThis.Alpine = prev;
  }
}
