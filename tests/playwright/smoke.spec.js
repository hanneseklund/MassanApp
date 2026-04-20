// MassanApp smoke suite. Mirrors the numbered checklist in
// docs/installation-testing-specification.md. Runs against the shared
// Supabase prototype project via the app's committed anon key.

const { test, expect } = require("@playwright/test");

const TEST_EMAIL = "smoke+e2e@example.com";
const TEST_PASSWORD = "MassanApp-smoke-2026!";
const TEST_DISPLAY_NAME = "Smoke Tester";

// One suite, one sequence: later tests depend on the account created
// or signed into by earlier ones.
test.describe.configure({ mode: "serial" });

// Collect console messages across the full run. Several steps assert
// that a `[simulatedEmail]` info log was emitted, and the events fire
// well after their user action on the app side.
function attachConsoleCapture(page) {
  const messages = [];
  page.on("console", (msg) => {
    const text = msg.text();
    messages.push({ type: msg.type(), text });
  });
  return messages;
}

function hasSimulatedEmail(messages, kind) {
  return messages.some(
    (m) => m.text.includes("[simulatedEmail]") && m.text.includes(kind),
  );
}

async function gotoHome(page) {
  await page.goto("/");
  await expect(page.locator(".chrome__title")).toHaveText("Events");
  // Alpine keeps the "Loading events…" hint in the DOM and toggles it
  // via x-show, so wait on visibility — not presence.
  await expect(
    page.locator(".hint", { hasText: "Loading events" }),
  ).toBeHidden({ timeout: 15_000 });
}

async function openEventByName(page, name) {
  await gotoHome(page);
  await page.fill('input[type="search"][placeholder="Search events"]', name);
  const card = page.locator(".events__card", { hasText: name });
  await expect(card).toHaveCount(1);
  await card.locator("button.events__link").click();
  await expect(page.locator(".chrome__title")).toHaveText(name);
}

// Navigate the current event to a section's dedicated full-list page.
// The stacked layout removed the tab bar; sections are reached by
// hash route. The `label` arg stays in the signature for readability
// at call sites but is no longer needed to find a UI element.
async function openSubview(page, id, _label) {
  const url = new URL(page.url());
  const match = url.hash.match(/#\/event\/([^/]+)/);
  const eventId = match?.[1];
  if (!eventId) throw new Error("openSubview: no event in current URL");
  await page.goto(`/#/event/${eventId}/${id}`);
  // Practical and newsletter no longer have dedicated pages; the
  // app collapses them to the landing route via history.replaceState.
  if (id === "practical" || id === "newsletter") {
    await expect(page).toHaveURL(new RegExp(`#/event/${eventId}$`));
  } else {
    await expect(page).toHaveURL(new RegExp(`#/event/${eventId}/${id}($|/)`));
  }
}

// Open the language dropdown and click the option for `lang`. The
// chrome compresses both flags into a single dropdown; the toggle
// button is `.chrome__lang-toggle` and option items expose
// `data-lang` so tests can target them.
async function setLanguage(page, lang) {
  await page.locator(".chrome__lang-toggle").click();
  await page.locator(`.chrome__lang-option[data-lang="${lang}"]`).click();
}

async function signOutIfSignedIn(page) {
  await page.goto("/#/me");
  const signout = page.locator("button.me__signout");
  if (await signout.isVisible().catch(() => false)) {
    await signout.click();
    await waitForSessionState(page, false);
  }
}

async function waitForSessionState(page, expected, timeout = 10_000) {
  await page.waitForFunction(
    (exp) => !!window.Alpine?.store?.("session")?.isSignedIn === exp,
    expected,
    { timeout },
  );
}

async function registerOrSignIn(page) {
  await page.goto("/#/auth");
  // Try Register first. If the email is already registered from a
  // prior run, Supabase returns an error; switch to Sign in and use
  // the same password.
  await page.locator('.auth-tabs__tab', { hasText: "Register" }).click();
  await page.locator('input[autocomplete="email"]').fill(TEST_EMAIL);
  await page.locator('input[autocomplete="name"]').fill(TEST_DISPLAY_NAME);
  await page
    .locator('input[autocomplete="current-password"]')
    .fill(TEST_PASSWORD);
  await page.locator(".auth-form .auth-form__submit").click();

  // Either the session becomes signed-in (afterAuth navigates away
  // from the auth view) or an error message appears.
  try {
    await waitForSessionState(page, true, 8_000);
    return;
  } catch {
    // Fall through to sign-in below.
  }

  // Fall back to Sign in.
  await page.locator('.auth-tabs__tab', { hasText: "Sign in" }).click();
  await page.locator('input[autocomplete="email"]').fill(TEST_EMAIL);
  await page
    .locator('input[autocomplete="current-password"]')
    .fill(TEST_PASSWORD);
  await page.locator(".auth-form .auth-form__submit").click();
  await waitForSessionState(page, true, 10_000);
}

async function waitForSignedIn(page) {
  await waitForSessionState(page, true);
  await page.goto("/#/me");
  await expect(page.locator(".me .me__email")).toHaveText(TEST_EMAIL, {
    timeout: 10_000,
  });
}

test.describe("Calendar and event selection", () => {
  test("1-4: calendar loads, filters narrow the list, Nordbygg opens", async ({
    page,
  }) => {
    await gotoHome(page);
    await expect(page.locator(".events__card")).not.toHaveCount(0);

    await page.selectOption('select >> nth=0', { label: "Trade fair" });
    await expect(page.locator(".events__card")).not.toHaveCount(0);
    const typeCells = page.locator(".events__type");
    const count = await typeCells.count();
    for (let i = 0; i < count; i++) {
      await expect(typeCells.nth(i)).toHaveText("Trade fair");
    }
    await page.selectOption('select >> nth=0', { label: "All types" });

    // Month filter (checklist step 2). The dropdown is populated from
    // `monthLabel()` of the current upcoming events, so pick whatever
    // the first non-default option is and assert the list narrows to
    // at least one card for that month.
    const monthSelect = page.locator("select").nth(2);
    const monthOptions = await monthSelect
      .locator('option:not([value=""])')
      .allTextContents();
    expect(monthOptions.length).toBeGreaterThan(0);
    const chosenMonth = monthOptions[0];
    await monthSelect.selectOption({ label: chosenMonth });
    await expect(page.locator(".events__card")).not.toHaveCount(0);
    await monthSelect.selectOption({ label: "All months" });

    await page.fill(
      'input[type="search"][placeholder="Search events"]',
      "Nordbygg",
    );
    const card = page.locator(".events__card", { hasText: "Nordbygg 2026" });
    await expect(card).toHaveCount(1);

    await card.locator("button.events__link").click();
    await expect(page.locator(".chrome__title")).toHaveText("Nordbygg 2026");
    await expect(page).toHaveURL(/#\/event\/nordbygg-2026/);
  });
});

test.describe("Event content", () => {
  test("5-8: stacked layout renders every section, dedicated pages render full lists, practical shows shared venue facts", async ({
    page,
  }) => {
    await openEventByName(page, "Nordbygg 2026");

    // Stacked landing: every section anchor is rendered, including the
    // inline previews and the in-place Practical info and Newsletter
    // blocks. (Sections that grow long truncate to 5 items; we just
    // assert the section is present here, not the truncation count.)
    for (const sectionId of [
      "news",
      "articles",
      "program",
      "exhibitors",
      "practical",
      "food",
      "newsletter",
    ]) {
      await expect(
        page.locator(`#event-section-${sectionId}`),
      ).toBeAttached();
    }
    await expect(page.locator(".practical").first()).toContainText("Alvsjo");
    await expect(page.locator(".newsletter-form").first()).toBeVisible();

    // Dedicated section pages: navigating directly to the route shows
    // only that section's full content plus a back link. The stacked
    // landing wrapper is x-show=false (hidden) on these routes, so we
    // scope content assertions to `.event-dedicated`. Newsletter is
    // covered by its own test below; we check the five list-style
    // sections here.
    for (const [id, contentSel] of [
      ["news", ".news-item"],
      ["articles", ".article"],
      ["program", ".program-day"],
      ["exhibitors", ".exhibitor-card"],
      ["food", ".menu-card"],
    ]) {
      await openSubview(page, id);
      const dedicated = page.locator(".event-dedicated");
      await expect(dedicated).toBeVisible();
      await expect(dedicated.locator(contentSel).first()).toBeVisible();
      // The stacked landing wrapper is hidden on dedicated routes.
      await expect(page.locator(".event-stacked")).toBeHidden();
    }

    // Exhibitor detail: pick the first exhibitor card on the dedicated
    // exhibitors page and verify the detail view shows a "Back to
    // exhibitors" link.
    await openSubview(page, "exhibitors");
    const firstExhibitor = page.locator(".exhibitor-card__link").first();
    if (await firstExhibitor.isVisible().catch(() => false)) {
      await firstExhibitor.click();
      await expect(page.locator(".back-link")).toBeVisible();
      await page.locator(".back-link").click();
    }

    // Practical info: shared Stockholmsmassan facts render inline on
    // the stacked landing — the practical/newsletter routes redirect
    // there and scroll, so we navigate via openSubview and assert the
    // landing-page section content.
    await openSubview(page, "practical");
    await expect(page.locator(".practical").first()).toContainText("Alvsjo");
    for (const heading of [
      "Getting here",
      "Parking",
      "Restaurants and cafes",
      "Security and entry",
    ]) {
      await expect(
        page.locator(".practical__section h3", { hasText: heading }).first(),
      ).toBeVisible();
    }

    // The top-left back button was replaced by a hamburger menu. Open
    // it and use the "Other events" entry to return to the calendar.
    await page.locator(".chrome__nav-toggle").click();
    await page
      .locator(".chrome__nav-link", { hasText: "Other events" })
      .click();
    await expect(page).toHaveURL(/#\/$|#\/?$/);
    await expect(page.locator(".chrome__title")).toHaveText("Events");
  });
});

test.describe("Congress archetype", () => {
  test("9-11: ESTRO or EHA shows program and shared practical facts", async ({
    page,
  }) => {
    const candidates = ["ESTRO 2026", "EHA2026 Congress"];
    let congressOpened = null;
    for (const name of candidates) {
      await gotoHome(page);
      const card = page.locator(".events__card", { hasText: name });
      if ((await card.count()) > 0) {
        await card.locator("button.events__link").first().click();
        await expect(page.locator(".chrome__title")).toHaveText(name);
        congressOpened = name;
        break;
      }
    }
    expect(congressOpened).not.toBeNull();

    // Delegate CTA text confirms the congress ticket model.
    await expect(page.locator(".event-hero__cta").first()).toContainText(
      "Register as delegate",
    );

    await openSubview(page, "program");
    const dedicatedProgram = page.locator(".event-dedicated");
    const programCount = await dedicatedProgram.locator(".program-day").count();
    const placeholderCount = await dedicatedProgram
      .locator(".placeholder", { hasText: "No program published" })
      .count();
    // Either a seeded program day renders, or we show the empty-state
    // placeholder — both are documented behavior.
    expect(programCount + placeholderCount).toBeGreaterThan(0);
    if (programCount > 0) {
      await expect(dedicatedProgram.locator(".session").first()).toBeVisible();
    }

    await openSubview(page, "practical");
    // Shared-venue-data regression check: the congress practical info
    // must render the same transport copy ("Alvsjo") as Nordbygg, not
    // just the section headings. This enforces the rule in
    // docs/installation-testing-specification.md under "Regression
    // checks for shared venue data".
    await expect(page.locator(".practical").first()).toContainText("Alvsjo");
    for (const heading of [
      "Getting here",
      "Parking",
      "Restaurants and cafes",
      "Security and entry",
    ]) {
      await expect(
        page.locator(".practical__section h3", { hasText: heading }).first(),
      ).toBeVisible();
    }
  });
});

test.describe("Registration and sign-in", () => {
  test("12-14: register or sign in with the smoke account, sign out, sign back in", async ({
    page,
  }) => {
    await signOutIfSignedIn(page);
    await registerOrSignIn(page);
    await waitForSignedIn(page);

    await page.locator(".me__signout").click();
    await waitForSessionState(page, false);

    // Sign back in via the tab.
    await page.goto("/#/auth");
    await page.locator('.auth-tabs__tab', { hasText: "Sign in" }).click();
    await page.locator('input[autocomplete="email"]').fill(TEST_EMAIL);
    await page
      .locator('input[autocomplete="current-password"]')
      .fill(TEST_PASSWORD);
    await page.locator(".auth-form .auth-form__submit").click();
    await waitForSignedIn(page);
  });

  test("15: simulated Google sign-in creates a distinct anonymous session", async ({
    page,
  }) => {
    await signOutIfSignedIn(page);
    await page.goto("/#/auth");
    await page
      .locator(".auth-social__button", { hasText: "Continue with Google" })
      .click();
    await waitForSessionState(page, true);
    await page.goto("/#/me");
    await expect(page.locator(".me .me__provider")).toContainText("Google", {
      timeout: 10_000,
    });
    await expect(page.locator(".me .me__provider .sim-chip")).toBeVisible();
    // The simulated Google session should not carry the smoke email.
    await expect(page.locator(".me .me__email")).not.toHaveText(TEST_EMAIL);

    // Clean up so subsequent tests start from the email account.
    await page.locator(".me__signout").click();
    await waitForSessionState(page, false);
  });
});

test.describe("Ticket purchase (simulated)", () => {
  test("16-22: auth detour, purchase Nordbygg day pass, purchase ESTRO delegate, tickets persist across reload", async ({
    page,
  }) => {
    const messages = attachConsoleCapture(page);

    // 16. While signed out, tap "Get tickets" on Nordbygg.
    await signOutIfSignedIn(page);
    await openEventByName(page, "Nordbygg 2026");
    await page
      .locator(".event-hero__cta", { hasText: "Get tickets" })
      .first()
      .click();
    await expect(page).toHaveURL(/#\/auth/);

    // 17. Sign in → returns to purchase view.
    await page.locator('.auth-tabs__tab', { hasText: "Sign in" }).click();
    await page.locator('input[autocomplete="email"]').fill(TEST_EMAIL);
    await page
      .locator('input[autocomplete="current-password"]')
      .fill(TEST_PASSWORD);
    await page.locator(".auth-form .auth-form__submit").click();
    await expect(page).toHaveURL(/#\/event\/nordbygg-2026\/purchase/, {
      timeout: 10_000,
    });

    // 18. Step 1 → 2 → 3 → 4. Pick Day pass, fill the questionnaire,
    //     confirm.
    await page
      .locator(".ticket-type", { hasText: "Day pass" })
      .click();
    await page
      .locator(".purchase__primary", { hasText: "Continue" })
      .click();
    // Questionnaire: visit type is required, other fields are optional.
    // Pick "professional" so the company/role row opens and is exercised.
    await page
      .locator('input[name="q-visit-type"][value="professional"]')
      .check();
    await page
      .locator(".questionnaire__checkbox", { hasText: "Sustainable construction" })
      .locator('input[type="checkbox"]')
      .check();
    await page
      .locator(".purchase__primary", { hasText: "Continue" })
      .click();
    await expect(
      page.locator(".purchase__summary-row", { hasText: "Event" }),
    ).toContainText("Nordbygg 2026");
    await page
      .locator(".purchase__primary", { hasText: "Confirm purchase" })
      .click();
    await expect(
      page.locator(".purchase__step-title", { hasText: "Ticket confirmed" }),
    ).toBeVisible({ timeout: 15_000 });
    await expect(page.locator(".purchase__ref code")).toContainText(/^SIM-/);
    await expect(page.locator(".purchase .ticket-card__qr svg")).toBeVisible();
    await expect(
      page.locator(".purchase__step-title .sim-chip", { hasText: "simulated" }),
    ).toBeVisible();

    // Console assertion: ticket_confirmation was logged.
    await expect
      .poll(() => hasSimulatedEmail(messages, "ticket_confirmation"), {
        timeout: 5_000,
      })
      .toBe(true);

    // 19. My Tickets shows the new ticket.
    await page
      .locator(".purchase__primary", { hasText: "View in My Tickets" })
      .click();
    await expect(page).toHaveURL(/#\/tickets/);
    const nordbyggTicket = page.locator(".tickets__list .ticket-card", {
      hasText: "Nordbygg 2026",
    });
    await expect(nordbyggTicket.first()).toBeVisible();
    await expect(nordbyggTicket.first().locator(".ticket-card__qr svg")).toBeVisible();

    // 20. Event home shows "View ticket" alongside "Get tickets",
    //     and "View ticket" opens My Tickets with the ticket visible.
    await openEventByName(page, "Nordbygg 2026");
    await expect(
      page.locator(".event-hero__cta", { hasText: "Get tickets" }),
    ).toBeVisible();
    const viewTicketCta = page.locator(".event-hero__cta", {
      hasText: "View ticket",
    });
    await expect(viewTicketCta).toBeVisible();
    await viewTicketCta.click();
    await expect(page).toHaveURL(/#\/tickets/);
    await expect(
      page
        .locator(".tickets__list .ticket-card", { hasText: "Nordbygg 2026" })
        .first(),
    ).toBeVisible();

    // 21. Register as delegate on ESTRO. Assert the general-profile
    //     fields are pre-filled from the Nordbygg purchase (visit_type
    //     stuck as "professional"), then pick a subject and confirm.
    await gotoHome(page);
    const estroCard = page.locator(".events__card", { hasText: "ESTRO 2026" });
    if ((await estroCard.count()) > 0) {
      await estroCard.locator("button.events__link").first().click();
      await expect(page.locator(".chrome__title")).toHaveText("ESTRO 2026");
      await page
        .locator(".event-hero__cta", { hasText: "Register as delegate" })
        .first()
        .click();
      await page
        .locator(".ticket-type", { hasText: "Delegate registration" })
        .click();
      await page
        .locator(".purchase__primary", { hasText: "Continue" })
        .click();
      // Acceptance criterion: returning purchase pre-fills visit_type
      // from the user's saved profile.
      await expect(
        page.locator('input[name="q-visit-type"][value="professional"]'),
      ).toBeChecked();
      await page
        .locator(".questionnaire__checkbox", {
          hasText: "Clinical radiation oncology",
        })
        .locator('input[type="checkbox"]')
        .check();
      await page
        .locator(".purchase__primary", { hasText: "Continue" })
        .click();
      await page
        .locator(".purchase__primary", { hasText: "Confirm purchase" })
        .click();
      await expect(
        page.locator(".purchase__step-title", {
          hasText: "Ticket confirmed",
        }),
      ).toBeVisible({ timeout: 15_000 });
      await page
        .locator(".purchase__primary", { hasText: "View in My Tickets" })
        .click();
      await expect(
        page
          .locator(".tickets__list .ticket-card", { hasText: "ESTRO 2026" })
          .first(),
      ).toBeVisible();
    }

    // 22. Reload; both tickets are still visible.
    await page.reload();
    await expect(page).toHaveURL(/#\/tickets/);
    await expect(
      page
        .locator(".tickets__list .ticket-card", { hasText: "Nordbygg 2026" })
        .first(),
    ).toBeVisible();

    // Points system sub-task 03: the purchase(s) above awarded at least
    // 100 points per ticket. My Pages must show a non-zero balance and
    // list the ticket earn in the recent-transactions block.
    await page.goto("/#/me");
    await expect(
      page.locator(".me__section--points .me__section-title"),
    ).toContainText("Points");
    await expect(
      page.locator(".me__section--points .me__section-title .sim-chip"),
    ).toBeVisible();
    const balanceValue = page.locator(".points__balance-value");
    await expect(balanceValue).toBeVisible({ timeout: 10_000 });
    await expect
      .poll(async () => {
        const text = (await balanceValue.textContent()) || "";
        const match = text.match(/(\d+)/);
        return match ? parseInt(match[1], 10) : 0;
      }, { timeout: 10_000 })
      .toBeGreaterThan(0);
    await expect(
      page
        .locator(".points__item", { hasText: "Ticket purchase" })
        .first(),
    ).toBeVisible();
    await expect(
      page
        .locator(".points__item", { hasText: "Nordbygg 2026" })
        .first(),
    ).toBeVisible();
  });
});

test.describe("Newsletter", () => {
  test("23-24: anonymous signup shows success; reload returns to blank form (RLS-invisible)", async ({
    page,
  }) => {
    const messages = attachConsoleCapture(page);
    await signOutIfSignedIn(page);
    // Navigate via the newsletter route; the stacked layout collapses
    // it to the landing route and scrolls to the inline newsletter
    // section. The form is rendered inline on the event landing page.
    await page.goto("/#/event/nordbygg-2026/newsletter");
    await expect(page).toHaveURL(/#\/event\/nordbygg-2026$/);
    await expect(
      page.locator("#event-section-newsletter .newsletter-form").first(),
    ).toBeVisible();

    const anonEmail = `smoke-anon+${Date.now()}@example.com`;
    await page
      .locator('.newsletter-form input[autocomplete="email"]')
      .fill(anonEmail);
    await page
      .locator(".auth-form__submit", { hasText: "Sign up for updates" })
      .click();
    await expect(
      page.locator(".newsletter-success__title"),
    ).toBeVisible({ timeout: 10_000 });
    await expect
      .poll(() => hasSimulatedEmail(messages, "newsletter_confirmation"), {
        timeout: 5_000,
      })
      .toBe(true);

    await page.reload();
    // Anonymous inserts cannot be re-read via RLS, so the form goes
    // back to its blank state rather than the success state.
    await expect(
      page.locator(".newsletter-form input[autocomplete='email']"),
    ).toHaveValue("");
  });

  test("25-28: signed-in signup persists; preferences and venue-wide toggle survive reload", async ({
    page,
  }) => {
    await signOutIfSignedIn(page);
    await page.goto("/#/auth");
    await page.locator('.auth-tabs__tab', { hasText: "Sign in" }).click();
    await page.locator('input[autocomplete="email"]').fill(TEST_EMAIL);
    await page
      .locator('input[autocomplete="current-password"]')
      .fill(TEST_PASSWORD);
    await page.locator(".auth-form .auth-form__submit").click();
    await waitForSignedIn(page);

    // 25. Subscribe to Nordbygg as signed-in user.
    await page.goto("/#/event/nordbygg-2026/newsletter");
    const emailInput = page.locator(
      ".newsletter-form input[autocomplete='email']",
    );
    // If already subscribed from a prior run, the form skips straight
    // to the success state — treat both as valid entry points into
    // the flow.
    if (await emailInput.isVisible().catch(() => false)) {
      await expect(emailInput).toHaveValue(TEST_EMAIL);
      await page
        .locator(".auth-form__submit", { hasText: "Sign up for updates" })
        .click();
    }
    await expect(page.locator(".newsletter-success__title")).toBeVisible({
      timeout: 10_000,
    });

    // 26. My Pages → Newsletter preferences lists Nordbygg.
    await page.goto("/#/me");
    const nordbyggPref = page.locator(".newsletter-prefs__item", {
      hasText: "Nordbygg 2026",
    });
    await expect(nordbyggPref.first()).toBeVisible({ timeout: 10_000 });

    // 27. Toggle one per-event topic off, reload, confirm it's still off.
    const firstTopicCheckbox = nordbyggPref
      .first()
      .locator(".newsletter-prefs__topic input[type='checkbox']")
      .first();
    const wasChecked = await firstTopicCheckbox.isChecked();
    await firstTopicCheckbox.click();
    const desiredState = !wasChecked;
    await expect(firstTopicCheckbox).toBeChecked({ checked: desiredState });
    await page.reload();
    const reloadedCheckbox = page
      .locator(".newsletter-prefs__item", { hasText: "Nordbygg 2026" })
      .first()
      .locator(".newsletter-prefs__topic input[type='checkbox']")
      .first();
    await expect(reloadedCheckbox).toBeChecked({ checked: desiredState });

    // 28. Venue-wide toggle on → reload → still on → toggle off → reload → still off.
    const venueToggle = page.locator(
      ".newsletter-prefs__venue-row input[type='checkbox']",
    );
    if (!(await venueToggle.isChecked())) {
      await venueToggle.click();
      await expect(venueToggle).toBeChecked();
    }
    await page.reload();
    await expect(
      page.locator(".newsletter-prefs__venue-row input[type='checkbox']"),
    ).toBeChecked();

    await page
      .locator(".newsletter-prefs__venue-row input[type='checkbox']")
      .click();
    await expect(
      page.locator(".newsletter-prefs__venue-row input[type='checkbox']"),
    ).not.toBeChecked();
    await page.reload();
    await expect(
      page.locator(".newsletter-prefs__venue-row input[type='checkbox']"),
    ).not.toBeChecked();
  });
});

test.describe("Food ordering (simulated)", () => {
  test("29-32: pickup order, language toggle keeps canonical labels, timeslot order", async ({
    page,
  }) => {
    // 29. Sign in with the smoke account, open Nordbygg → Food, and
    //     confirm the menu picker renders.
    await signOutIfSignedIn(page);
    await page.goto("/#/auth");
    await page.locator('.auth-tabs__tab', { hasText: "Sign in" }).click();
    await page.locator('input[autocomplete="email"]').fill(TEST_EMAIL);
    await page
      .locator('input[autocomplete="current-password"]')
      .fill(TEST_PASSWORD);
    await page.locator(".auth-form .auth-form__submit").click();
    await waitForSignedIn(page);

    await openEventByName(page, "Nordbygg 2026");
    await openSubview(page, "food");
    // Scope menu-card lookups to the dedicated food page; the stacked
    // landing also renders preview tiles with the same class but they
    // are hidden under the parent x-show toggle.
    const foodPage = page.locator(".event-dedicated.food");
    await expect(foodPage.locator(".menu-card").first()).toBeVisible();

    // 30. Pickup order: first menu (Classic Burger), first pickup
    //     location (North Entrance kiosk), confirm.
    await foodPage.locator(".menu-card").first().click();
    await page
      .locator(".food .purchase__primary", { hasText: "Continue" })
      .click();
    await page.locator('input[name="food-pickup"]').first().check();
    await page
      .locator(".food .purchase__primary", { hasText: "Pay and order" })
      .click();
    await expect(
      page.locator(".food .purchase__step-title", { hasText: "Order confirmed" }),
    ).toBeVisible({ timeout: 15_000 });
    await expect(
      page.locator(".food .purchase__step-title .sim-chip", { hasText: "simulated" }),
    ).toBeVisible();
    await expect(page.locator(".food .purchase__ref code")).toContainText(
      /^SIM-/,
    );
    const pickupCard = page.locator(".food .ticket-card");
    await expect(pickupCard.locator(".ticket-card__event")).toHaveText(
      "Classic Burger",
    );
    await expect(pickupCard).toContainText("North Entrance kiosk");

    // 31. Toggle language to Swedish — the persisted canonical labels
    //     stay in English even though the template prose switches.
    await setLanguage(page, "sv");
    await expect(
      page.locator(".food .purchase__step-title", {
        hasText: "Beställning bekräftad",
      }),
    ).toBeVisible();
    await expect(pickupCard.locator(".ticket-card__event")).toHaveText(
      "Classic Burger",
    );
    await expect(pickupCard).toContainText("North Entrance kiosk");
    await setLanguage(page, "en");
    await expect(
      page.locator(".food .purchase__step-title", { hasText: "Order confirmed" }),
    ).toBeVisible();

    // 32. Timeslot order: reset the form, switch delivery mode, pick
    //     Smakverket + the first timeslot, confirm.
    await page
      .locator(".food .purchase__primary", { hasText: "Order another" })
      .click();
    await foodPage.locator(".menu-card").first().click();
    await page
      .locator(".food .purchase__primary", { hasText: "Continue" })
      .click();
    await page
      .locator('input[name="food-delivery-mode"][value="timeslot"]')
      .check();
    await page.locator('input[name="food-restaurant"]').first().check();
    const firstSlotLabel = page.locator(".food-timeslot").first();
    await expect(firstSlotLabel).toBeVisible();
    await firstSlotLabel.locator('input[name="food-timeslot"]').check();
    // Capture the slot label from the adjacent <span> so we can assert
    // it shows up in the confirmation instructions.
    const slotLabel = (await firstSlotLabel.locator("span").textContent())
      ?.trim();
    expect(slotLabel).toMatch(/^\d{2}:\d{2}[–-]\d{2}:\d{2}$/);
    await page
      .locator(".food .purchase__primary", { hasText: "Pay and order" })
      .click();
    await expect(
      page.locator(".food .purchase__step-title", { hasText: "Order confirmed" }),
    ).toBeVisible({ timeout: 15_000 });
    await expect(page.locator(".food .purchase__ref code")).toContainText(
      /^SIM-/,
    );
    const timeslotCard = page.locator(".food .ticket-card");
    await expect(timeslotCard).toContainText("Smakverket");
    await expect(timeslotCard).toContainText(slotLabel);
  });
});

test.describe("Points add-on redemption (simulated)", () => {
  test("35-36: event add-ons redeem for points, banner and balance reflect it", async ({
    page,
  }) => {
    // Depends on the ticket-purchase test having already awarded
    // points for the smoke account. Sign in and open Nordbygg.
    await signOutIfSignedIn(page);
    await page.goto("/#/auth");
    await page.locator('.auth-tabs__tab', { hasText: "Sign in" }).click();
    await page.locator('input[autocomplete="email"]').fill(TEST_EMAIL);
    await page
      .locator('input[autocomplete="current-password"]')
      .fill(TEST_PASSWORD);
    await page.locator(".auth-form .auth-form__submit").click();
    await waitForSignedIn(page);

    // Capture the current balance from My Pages before redemption.
    await page.goto("/#/me");
    const balanceLocator = page.locator(".points__balance-value");
    await expect(balanceLocator).toBeVisible({ timeout: 10_000 });
    await expect
      .poll(
        async () => {
          const text = (await balanceLocator.textContent()) || "";
          const match = text.match(/(\d+)/);
          return match ? parseInt(match[1], 10) : 0;
        },
        { timeout: 10_000 },
      )
      .toBeGreaterThan(0);
    const balanceBeforeText = (await balanceLocator.textContent()) || "";
    const balanceBefore = parseInt(
      balanceBeforeText.match(/(\d+)/)?.[1] ?? "0",
      10,
    );

    await openEventByName(page, "Nordbygg 2026");
    // The add-ons section is only visible on the event home subview
    // for ticket holders.
    const addonsSection = page.locator(".event-addons");
    await expect(addonsSection).toBeVisible({ timeout: 10_000 });
    await expect(
      addonsSection.locator(".event-addons__title .sim-chip"),
    ).toBeVisible();

    // Pick the cheapest add-on whose cost is at or below the current
    // balance. The add-ons list is sorted by cost ascending, so the
    // first enabled Redeem button is the cheapest option.
    const firstCard = addonsSection.locator(".event-addons__card").first();
    await expect(firstCard).toBeVisible();
    const cost = await firstCard
      .locator(".event-addons__cost")
      .textContent()
      .then((t) => parseInt(t?.match(/(\d+)/)?.[1] ?? "0", 10));
    expect(cost).toBeGreaterThan(0);
    const addonName = (
      await firstCard.locator(".event-addons__name").textContent()
    )?.trim();
    expect(addonName).toBeTruthy();

    const redeemButton = firstCard.locator(".event-addons__redeem");
    await expect(redeemButton).toBeEnabled();
    await redeemButton.click();

    // Confirmation banner renders with the simulated chip and the
    // redeemed add-on name/cost.
    const banner = addonsSection.locator(".event-addons__banner");
    await expect(banner).toBeVisible({ timeout: 10_000 });
    await expect(banner.locator(".sim-chip")).toBeVisible();
    await expect(banner).toContainText(addonName);

    // My Pages balance dropped by exactly `cost`, and the recent
    // transactions list now shows the add-on redemption for Nordbygg.
    await page.goto("/#/me");
    await expect(balanceLocator).toBeVisible({ timeout: 10_000 });
    await expect
      .poll(
        async () => {
          const text = (await balanceLocator.textContent()) || "";
          return parseInt(text.match(/(\d+)/)?.[1] ?? "0", 10);
        },
        { timeout: 10_000 },
      )
      .toBe(balanceBefore - cost);
    await expect(
      page
        .locator(".points__item", { hasText: "Add-on redemption" })
        .first(),
    ).toBeVisible();
    await expect(
      page
        .locator(".points__item", { hasText: "Nordbygg 2026" })
        .first(),
    ).toBeVisible();
  });
});

test.describe("Points merchandise shop (simulated)", () => {
  test("37-38: #/points is reachable from My Pages and a merch item can be redeemed", async ({
    page,
  }) => {
    // Sign in so the smoke account's balance (from earlier ticket and
    // food purchases) is available to redeem against.
    await signOutIfSignedIn(page);
    await page.goto("/#/auth");
    await page.locator('.auth-tabs__tab', { hasText: "Sign in" }).click();
    await page.locator('input[autocomplete="email"]').fill(TEST_EMAIL);
    await page
      .locator('input[autocomplete="current-password"]')
      .fill(TEST_PASSWORD);
    await page.locator(".auth-form .auth-form__submit").click();
    await waitForSignedIn(page);

    // 33e. Capture balance on My Pages, then tap the Points-shop link
    //      and assert the venue-wide catalog renders.
    await page.goto("/#/me");
    const balanceLocator = page.locator(".points__balance-value");
    await expect(balanceLocator).toBeVisible({ timeout: 10_000 });
    await expect
      .poll(
        async () => {
          const text = (await balanceLocator.textContent()) || "";
          return parseInt(text.match(/(\d+)/)?.[1] ?? "0", 10);
        },
        { timeout: 10_000 },
      )
      .toBeGreaterThan(0);
    const balanceBefore = parseInt(
      ((await balanceLocator.textContent()) || "").match(/(\d+)/)?.[1] ?? "0",
      10,
    );

    await page.locator(".points__shop-link").click();
    await expect(page).toHaveURL(/#\/points$/);
    await expect(page.locator(".points-shop__title")).toBeVisible();
    await expect(
      page.locator(".points-shop__title .sim-chip"),
    ).toBeVisible();
    const shopCards = page.locator(".points-shop__card");
    await expect(shopCards.first()).toBeVisible({ timeout: 10_000 });
    const shopCardCount = await shopCards.count();
    expect(shopCardCount).toBeGreaterThan(0);

    // 33f. Pick the cheapest redeemable item — the list is sorted by
    //      points_cost ascending in catalogStore.activeMerchandise(),
    //      so the first card is the cheapest option.
    const firstCard = shopCards.first();
    const cost = parseInt(
      ((await firstCard.locator(".event-addons__cost").textContent()) || "")
        .match(/(\d+)/)?.[1] ?? "0",
      10,
    );
    expect(cost).toBeGreaterThan(0);
    expect(balanceBefore).toBeGreaterThanOrEqual(cost);
    const itemName = (
      await firstCard.locator(".event-addons__name").textContent()
    )?.trim();
    expect(itemName).toBeTruthy();

    const redeemButton = firstCard.locator(".points-shop__redeem");
    await expect(redeemButton).toBeEnabled();
    await redeemButton.click();

    // Confirmation banner appears in the shop with the simulated chip.
    const banner = page.locator(".points-shop__banner");
    await expect(banner).toBeVisible({ timeout: 10_000 });
    await expect(banner.locator(".sim-chip")).toBeVisible();
    await expect(banner).toContainText(itemName);

    // My Pages balance dropped by exactly `cost`, and the recent
    // transactions list shows the venue-wide merch redemption.
    await page.goto("/#/me");
    await expect(balanceLocator).toBeVisible({ timeout: 10_000 });
    await expect
      .poll(
        async () => {
          const text = (await balanceLocator.textContent()) || "";
          return parseInt(text.match(/(\d+)/)?.[1] ?? "0", 10);
        },
        { timeout: 10_000 },
      )
      .toBe(balanceBefore - cost);
    await expect(
      page
        .locator(".points__item", { hasText: "Merchandise redemption" })
        .first(),
    ).toBeVisible();
    await expect(
      page
        .locator(".points__item", { hasText: "Venue-wide" })
        .first(),
    ).toBeVisible();
  });
});

test.describe("Language toggle", () => {
  test("39-40: chrome switches between English and Swedish and persists across reload", async ({
    page,
  }) => {
    // Start on a view whose chrome copy differs clearly between the
    // two supported languages — the calendar title is "Events" in
    // English and "Evenemang" in Swedish.
    await gotoHome(page);
    await expect(page.locator(".chrome__title")).toHaveText("Events");

    // The chrome shows a single dropdown toggle for the active flag.
    // Open it and assert the listbox marks the current language.
    const toggle = page.locator(".chrome__lang-toggle");
    await expect(toggle).toHaveAttribute("aria-expanded", "false");
    await toggle.click();
    await expect(toggle).toHaveAttribute("aria-expanded", "true");
    await expect(
      page.locator('.chrome__lang-option[data-lang="en"]'),
    ).toHaveAttribute("aria-selected", "true");
    await expect(
      page.locator('.chrome__lang-option[data-lang="sv"]'),
    ).toHaveAttribute("aria-selected", "false");

    // Picking Swedish closes the dropdown and re-renders the chrome.
    await page.locator('.chrome__lang-option[data-lang="sv"]').click();
    await expect(toggle).toHaveAttribute("aria-expanded", "false");
    await expect(page.locator(".chrome__title")).toHaveText("Evenemang");
    // Calendar placeholder copy should also swap.
    await expect(
      page.locator('input[type="search"]').first(),
    ).toHaveAttribute("placeholder", "Sök evenemang");

    // Persistence across reload.
    await page.reload();
    await expect(page.locator(".chrome__title")).toHaveText("Evenemang");
    await page.locator(".chrome__lang-toggle").click();
    await expect(
      page.locator('.chrome__lang-option[data-lang="sv"]'),
    ).toHaveAttribute("aria-selected", "true");

    // Toggle back to English and confirm it re-renders live.
    await page.locator('.chrome__lang-option[data-lang="en"]').click();
    await expect(page.locator(".chrome__title")).toHaveText("Events");
    await page.locator(".chrome__lang-toggle").click();
    await expect(
      page.locator('.chrome__lang-option[data-lang="en"]'),
    ).toHaveAttribute("aria-selected", "true");
    // Escape closes the dropdown.
    await page.keyboard.press("Escape");
    await expect(page.locator(".chrome__lang-toggle")).toHaveAttribute(
      "aria-expanded",
      "false",
    );

    // Event content stays in its seeded language regardless of toggle
    // (see docs/functional-specification.md, "Accessibility and
    // internationalization"). Open Nordbygg, capture the seeded English
    // summary, switch to Swedish, and assert the summary is unchanged
    // while the section-nav chrome did swap.
    await openEventByName(page, "Nordbygg 2026");
    const summarySelector = ".event-hero__summary";
    const seededSummary = await page
      .locator(summarySelector)
      .first()
      .textContent();
    expect(seededSummary).toMatch(/Nordbygg is the leading Nordic/);

    await setLanguage(page, "sv");
    // Section heading on the stacked layout switches to Swedish copy.
    await expect(
      page
        .locator(".event-section__title", { hasText: "Nyheter" })
        .first(),
    ).toBeVisible();
    await expect(page.locator(summarySelector).first()).toHaveText(
      seededSummary,
    );

    // Practical-info venue copy (seeded English) also stays stable —
    // the section is rendered inline on the stacked landing.
    await expect(page.locator(".practical").first()).toContainText(
      "Alvsjo station",
    );

    // Restore English for later independent runs.
    await setLanguage(page, "en");
  });
});

test.describe("Chrome layout", () => {
  test("41: language flags and me icon are right-justified on the start page", async ({
    page,
  }) => {
    // Regression for issue #10: on the calendar (start) page the back
    // button is hidden, and CSS Grid auto-placement used to pull the
    // actions cluster toward the centre. Pin the cluster's right edge
    // to the chrome's right edge (within the page padding).
    await gotoHome(page);
    const chromeBox = await page.locator(".chrome").boundingBox();
    const actionsBox = await page.locator(".chrome__actions").boundingBox();
    expect(chromeBox).not.toBeNull();
    expect(actionsBox).not.toBeNull();
    const padding = parseFloat(
      await page.evaluate(
        () => getComputedStyle(document.querySelector(".chrome")).paddingRight,
      ),
    );
    const rightGap = chromeBox.x + chromeBox.width - (actionsBox.x + actionsBox.width);
    // Allow 1px slack for sub-pixel rounding on top of the chrome's own
    // right padding.
    expect(Math.abs(rightGap - padding)).toBeLessThanOrEqual(1);
  });
});
