// Playwright config for the MassanApp smoke suite. The frontend in
// web/ has no build step, so we serve it with http-server and point
// Playwright at the resulting origin. See
// docs/installation-testing-specification.md under "Automated smoke
// suite" for how this is used.

const path = require("path");
const { defineConfig, devices } = require("@playwright/test");

const REPO_ROOT = path.resolve(__dirname, "..", "..");

// 8787 avoids the 8080 / 8081 ports that many local dev tools occupy.
// Override with PW_BASE_URL to point the suite at a different origin
// (for example the hosted Cloudflare Pages preview).
const PORT = Number(process.env.PW_PORT) || 8787;
const LOCAL_URL = `http://127.0.0.1:${PORT}`;
const BASE_URL = process.env.PW_BASE_URL || LOCAL_URL;
const useLocalServer = BASE_URL === LOCAL_URL;

module.exports = defineConfig({
  testDir: ".",
  timeout: 60_000,
  expect: { timeout: 10_000 },
  fullyParallel: false,
  workers: 1,
  retries: process.env.CI ? 1 : 0,
  reporter: [["list"]],
  use: {
    baseURL: BASE_URL,
    trace: "retain-on-failure",
  },
  // Mobile emulation via Pixel 7 (Chromium-based). The manual
  // checklist uses iPhone 14 emulation in Chrome DevTools, which is
  // also Chromium; sticking to one engine keeps the smoke install
  // small (one browser download) while still matching a
  // smartphone-sized viewport.
  projects: [
    {
      name: "smoke",
      use: { ...devices["Pixel 7"] },
    },
  ],
  ...(useLocalServer
    ? {
        webServer: {
          command: `npx http-server ./web -p ${PORT} -a 127.0.0.1 -s -c-1`,
          cwd: REPO_ROOT,
          url: LOCAL_URL,
          // Always start our own server. Reusing whatever else happens
          // to be on the port would silently test the wrong app.
          reuseExistingServer: false,
          timeout: 30_000,
        },
      }
    : {}),
});
