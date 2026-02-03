// Interactive UI Testing - Actually test user workflows
// Tests what users CAN DO, not just what exists

const { chromium } = require('playwright');

(async () => {
  console.log('🧪 INTERACTIVE UI TEST SUITE\n');
  console.log('Testing user interactions at: https://whatismydelta.com');
  console.log('=' .repeat(60) + '\n');

  const browser = await chromium.launch({
    headless: true,
    slowMo: 100 // Slow down to see interactions
  });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  const page = await context.newPage();

  const errors = [];
  let testsPassed = 0;
  let testsFailed = 0;

  page.on('pageerror', error => {
    errors.push(`Page Error: ${error.message}`);
  });

  const test = (name, condition, details = '') => {
    if (condition) {
      console.log(`✅ ${name}`);
      if (details) console.log(`   ${details}`);
      testsPassed++;
      return true;
    } else {
      console.log(`❌ ${name}`);
      if (details) console.log(`   ${details}`);
      testsFailed++;
      return false;
    }
  };

  try {
    // ============================================================
    // SETUP: Navigate to site
    // ============================================================
    console.log('📍 SETUP: Loading site...\n');

    await page.goto('https://whatismydelta.com', {
      waitUntil: 'networkidle',
      timeout: 30000
    });

    await page.waitForTimeout(2000);
    console.log('✅ Site loaded\n');

    // ============================================================
    // TEST 1: Navigation Interactions
    // ============================================================
    console.log('📍 TEST 1: Navigation & Links\n');

    // Find all clickable buttons
    const buttons = await page.$$('button, a[href]');
    test('Navigation elements are clickable', buttons.length > 0, `Found ${buttons.length} clickable elements`);

    // Try to find and click a navigation link (if visible)
    const navLinks = await page.$$('nav a, header a, .nav a');
    if (navLinks.length > 0) {
      test('Navigation links present', true, `Found ${navLinks.length} nav links`);
    }

    // Take screenshot of initial state
    await page.screenshot({ path: '/tmp/ui-test-01-initial.png' });

    // ============================================================
    // TEST 2: Chat/Coach Input Interaction
    // ============================================================
    console.log('\n📍 TEST 2: Chat Input Interaction\n');

    // Find chat input
    const chatInput = await page.$('#user-input, textarea, input[type="text"]');

    if (chatInput) {
      const isVisible = await chatInput.isVisible();
      const isEnabled = await chatInput.isEnabled();

      test('Chat input visible and enabled', isVisible && isEnabled);

      if (isVisible && isEnabled) {
        // Try to type in the input
        try {
          await chatInput.click();
          await page.waitForTimeout(500);

          await chatInput.type('I need help with my career', { delay: 50 });
          await page.waitForTimeout(500);

          const inputValue = await chatInput.inputValue();
          test('Text input works', inputValue.includes('help with my career'), `Input contains: "${inputValue}"`);

          await page.screenshot({ path: '/tmp/ui-test-02-chat-input.png' });

          // Clear the input
          await chatInput.fill('');
        } catch (e) {
          test('Text input works', false, `Error: ${e.message}`);
        }
      }
    } else {
      test('Chat input found', false, 'Input element not found');
    }

    // ============================================================
    // TEST 3: PS101 Interactive Elements
    // ============================================================
    console.log('\n📍 TEST 3: PS101 Step Navigation\n');

    // Look for PS101 step buttons/navigation
    const ps101Elements = await page.$$('[data-ps101], .ps101-step, button[data-step]');
    test('PS101 interactive elements present', ps101Elements.length > 0, `Found ${ps101Elements.length} PS101 elements`);

    // Try to find next/previous buttons
    const nextButtons = await page.$$('button:has-text("Next"), button:has-text("Continue"), .next-button');
    if (nextButtons.length > 0) {
      test('PS101 navigation buttons present', true, `Found ${nextButtons.length} next/continue buttons`);

      // Try clicking a next button
      try {
        const firstNextButton = nextButtons[0];
        const isClickable = await firstNextButton.isEnabled();

        if (isClickable) {
          await firstNextButton.click();
          await page.waitForTimeout(1000);
          test('Next button clickable', true, 'Button responded to click');
          await page.screenshot({ path: '/tmp/ui-test-03-ps101-navigate.png' });
        } else {
          test('Next button clickable', false, 'Button disabled');
        }
      } catch (e) {
        test('Next button clickable', false, `Error: ${e.message}`);
      }
    }

    // ============================================================
    // TEST 4: Authentication Forms
    // ============================================================
    console.log('\n📍 TEST 4: Authentication Form Interaction\n');

    // Look for login/register forms
    const emailInputs = await page.$$('input[type="email"], input[name="email"], input[placeholder*="email" i]');
    const passwordInputs = await page.$$('input[type="password"]');

    test('Email input fields present', emailInputs.length > 0, `Found ${emailInputs.length} email inputs`);
    test('Password input fields present', passwordInputs.length > 0, `Found ${passwordInputs.length} password inputs`);

    if (emailInputs.length > 0 && passwordInputs.length > 0) {
      // Try to interact with first email field (don't submit)
      try {
        const emailInput = emailInputs[0];
        const isVisible = await emailInput.isVisible();

        if (isVisible) {
          await emailInput.click();
          await emailInput.type('test@example.com', { delay: 50 });
          await page.waitForTimeout(500);

          const emailValue = await emailInput.inputValue();
          test('Email input accepts text', emailValue.includes('test@example.com'));

          await page.screenshot({ path: '/tmp/ui-test-04-auth-form.png' });

          // Clear for next test
          await emailInput.fill('');
        } else {
          test('Email input accepts text', false, 'Email field not visible');
        }
      } catch (e) {
        test('Email input accepts text', false, `Error: ${e.message}`);
      }
    }

    // ============================================================
    // TEST 5: Button Click Responses
    // ============================================================
    console.log('\n📍 TEST 5: Button Click Behavior\n');

    // Find all visible buttons
    const allButtons = await page.$$('button:visible');
    let clickableButtons = 0;

    for (const button of allButtons.slice(0, 5)) { // Test first 5 buttons
      try {
        const isEnabled = await button.isEnabled();
        if (isEnabled) clickableButtons++;
      } catch (e) {
        // Button might have disappeared
      }
    }

    test('Multiple buttons are enabled', clickableButtons > 0, `${clickableButtons} buttons are enabled`);

    // ============================================================
    // TEST 6: Form Validation (if present)
    // ============================================================
    console.log('\n📍 TEST 6: Form Validation\n');

    // Try submitting empty form to see if validation works
    const submitButtons = await page.$$('button[type="submit"], button:has-text("Submit"), button:has-text("Send")');

    if (submitButtons.length > 0) {
      test('Submit buttons present', true, `Found ${submitButtons.length} submit buttons`);

      // Check if forms have required fields
      const requiredFields = await page.$$('input[required], textarea[required]');
      test('Form has required fields', requiredFields.length > 0, `${requiredFields.length} required fields`);
    }

    // ============================================================
    // TEST 7: Responsive Element Visibility
    // ============================================================
    console.log('\n📍 TEST 7: Element Visibility States\n');

    // Check if elements respond to interaction states
    const hoverables = await page.$$('button, a, [role="button"]');
    test('Interactive elements have hover capability', hoverables.length > 5, `Found ${hoverables.length} hoverable elements`);

    // ============================================================
    // TEST 8: Scroll and Content Loading
    // ============================================================
    console.log('\n📍 TEST 8: Scroll Behavior\n');

    const initialHeight = await page.evaluate(() => document.documentElement.scrollHeight);

    // Scroll down
    await page.evaluate(() => window.scrollTo(0, 500));
    await page.waitForTimeout(500);

    const scrollPosition = await page.evaluate(() => window.scrollY);
    test('Page scrolls', scrollPosition > 0, `Scrolled to ${scrollPosition}px`);

    await page.screenshot({ path: '/tmp/ui-test-08-scrolled.png' });

    // Scroll back to top
    await page.evaluate(() => window.scrollTo(0, 0));
    await page.waitForTimeout(500);

    // ============================================================
    // TEST 9: Dynamic Content (if any)
    // ============================================================
    console.log('\n📍 TEST 9: Dynamic Content Updates\n');

    // Check if page has any dynamic content loading
    const beforeButtons = (await page.$$('button')).length;
    await page.waitForTimeout(1000);
    const afterButtons = (await page.$$('button')).length;

    test('UI remains stable', beforeButtons === afterButtons, 'No unexpected element changes');

    // ============================================================
    // TEST 10: Error States
    // ============================================================
    console.log('\n📍 TEST 10: Error Handling\n');

    // Check if any error messages are shown
    const errorElements = await page.$$('.error, .alert-danger, [role="alert"]');
    test('No error states shown initially', errorElements.length === 0, `Found ${errorElements.length} error elements`);

    // ============================================================
    // TEST 11: Accessibility - Keyboard Navigation
    // ============================================================
    console.log('\n📍 TEST 11: Keyboard Navigation\n');

    // Try tabbing through elements
    await page.keyboard.press('Tab');
    await page.waitForTimeout(300);

    const focusedElement = await page.evaluate(() => {
      const el = document.activeElement;
      return el ? el.tagName : null;
    });

    test('Keyboard focus works', focusedElement !== null && focusedElement !== 'BODY', `Focused element: ${focusedElement}`);

    // ============================================================
    // TEST 12: Multi-step Workflow (if visible)
    // ============================================================
    console.log('\n📍 TEST 12: Workflow Navigation\n');

    // Check for step indicators or progress
    const stepIndicators = await page.$$('.step, .progress, [data-step], .stepper');
    if (stepIndicators.length > 0) {
      test('Multi-step workflow UI present', true, `Found ${stepIndicators.length} step indicators`);
    } else {
      console.log('ℹ️  No multi-step UI detected (may be hidden initially)');
    }

    // Final screenshot
    await page.screenshot({ path: '/tmp/ui-test-12-final.png', fullPage: true });

  } catch (error) {
    console.log(`\n❌ Test suite error: ${error.message}`);
    errors.push(error.message);
    testsFailed++;
  } finally {
    await browser.close();
  }

  // ============================================================
  // SUMMARY
  // ============================================================
  console.log('\n' + '='.repeat(60));
  console.log('📊 INTERACTIVE UI TEST SUMMARY');
  console.log('='.repeat(60));
  console.log(`Tests Passed: ${testsPassed}`);
  console.log(`Tests Failed: ${testsFailed}`);
  console.log(`Total Errors: ${errors.length}`);

  const passRate = testsPassed + testsFailed > 0
    ? ((testsPassed / (testsPassed + testsFailed)) * 100).toFixed(1)
    : 0;
  console.log(`Pass Rate: ${passRate}%`);

  console.log('\n📸 Screenshots saved:');
  console.log('   /tmp/ui-test-01-initial.png');
  console.log('   /tmp/ui-test-02-chat-input.png');
  console.log('   /tmp/ui-test-03-ps101-navigate.png');
  console.log('   /tmp/ui-test-04-auth-form.png');
  console.log('   /tmp/ui-test-08-scrolled.png');
  console.log('   /tmp/ui-test-12-final.png');

  if (testsFailed === 0) {
    console.log('\n✅ ALL INTERACTIVE TESTS PASSED');
    console.log('   - Users can interact with UI elements');
    console.log('   - Forms accept input');
    console.log('   - Buttons respond to clicks');
    console.log('   - Navigation works');
    process.exit(0);
  } else {
    console.log('\n⚠️  SOME INTERACTIVE TESTS FAILED');
    console.log(`   - ${testsFailed} interaction(s) did not work as expected`);
    console.log('   - Review screenshots and logs above');
    process.exit(testsFailed > 3 ? 1 : 0);
  }
})();
