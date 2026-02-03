// UI Flow Test - Simulate actual user journey
// Tests the ENTIRE user flow from landing to interaction

const { chromium } = require('playwright');

(async () => {
  console.log('🎬 USER FLOW TEST\n');
  console.log('Simulating actual user journey at: https://whatismydelta.com');
  console.log('=' .repeat(60) + '\n');

  const browser = await chromium.launch({ headless: true, slowMo: 500 });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  const page = await context.newPage();

  let step = 1;
  const log = (message) => {
    console.log(`[Step ${step++}] ${message}`);
  };

  try {
    log('Navigate to homepage');
    await page.goto('https://whatismydelta.com', {
      waitUntil: 'networkidle',
      timeout: 30000
    });
    await page.waitForTimeout(2000);

    // Take screenshot of landing page
    await page.screenshot({ path: '/tmp/flow-01-landing.png', fullPage: true });
    log('📸 Landing page screenshot saved');

    // Check what's visible to users initially
    log('Analyzing what users see on landing...');

    const visibleElements = await page.evaluate(() => {
      const isVisible = (el) => {
        const style = window.getComputedStyle(el);
        return style.display !== 'none' &&
               style.visibility !== 'hidden' &&
               style.opacity !== '0' &&
               el.offsetParent !== null;
      };

      return {
        buttons: Array.from(document.querySelectorAll('button'))
          .filter(isVisible)
          .map(b => ({ text: b.textContent.trim().substring(0, 30), class: b.className }))
          .slice(0, 10),
        inputs: Array.from(document.querySelectorAll('input, textarea'))
          .filter(isVisible)
          .map(i => ({ type: i.type, placeholder: i.placeholder, visible: true }))
          .slice(0, 5),
        headings: Array.from(document.querySelectorAll('h1, h2, h3'))
          .filter(isVisible)
          .map(h => h.textContent.trim().substring(0, 50))
          .slice(0, 5)
      };
    });

    console.log('\n📊 INITIALLY VISIBLE TO USERS:\n');
    console.log('Headings:', visibleElements.headings);
    console.log('Buttons:', visibleElements.buttons.length, 'buttons visible');
    console.log('Inputs:', visibleElements.inputs.length, 'inputs visible\n');

    if (visibleElements.buttons.length > 0) {
      log(`Found ${visibleElements.buttons.length} visible buttons`);
      console.log('   Top buttons:', visibleElements.buttons.slice(0, 3).map(b => b.text));
    }

    // Try to find and click a CTA or Start button
    log('Looking for main call-to-action...');

    const ctaSelectors = [
      'button:has-text("Start")',
      'button:has-text("Begin")',
      'button:has-text("Get Started")',
      'button:has-text("Try")',
      'a:has-text("Start")',
      '.cta-button',
      '[data-action="start"]'
    ];

    let ctaClicked = false;
    for (const selector of ctaSelectors) {
      try {
        const cta = await page.$(selector);
        if (cta && await cta.isVisible()) {
          log(`Found CTA: "${selector}"`);
          await cta.click();
          await page.waitForTimeout(1500);
          await page.screenshot({ path: '/tmp/flow-02-after-cta.png', fullPage: true });
          log('📸 After CTA click screenshot saved');
          ctaClicked = true;
          break;
        }
      } catch (e) {
        // Try next selector
      }
    }

    if (!ctaClicked) {
      log('No CTA button found, checking if chat/PS101 is already visible...');
    }

    // Check if PS101 or chat is now visible
    log('Checking if PS101 workflow is visible...');

    const ps101Visible = await page.evaluate(() => {
      const ps101 = document.querySelector('[data-ps101], .ps101, #ps101');
      if (!ps101) return false;

      const style = window.getComputedStyle(ps101);
      return style.display !== 'none' && ps101.offsetParent !== null;
    });

    log(`PS101 workflow visible: ${ps101Visible}`);

    // Try to find visible text inputs
    log('Looking for active input fields...');

    const activeInputs = await page.$$('input:visible, textarea:visible');
    log(`Found ${activeInputs.length} visible inputs`);

    if (activeInputs.length > 0) {
      try {
        const firstInput = activeInputs[0];
        log('Attempting to type in first visible input...');

        await firstInput.click();
        await page.waitForTimeout(500);
        await firstInput.type('I want to explore new career opportunities', { delay: 50 });
        await page.waitForTimeout(1000);

        await page.screenshot({ path: '/tmp/flow-03-input-filled.png' });
        log('📸 Input filled screenshot saved');

        // Look for submit/send button near the input
        const submitButton = await page.$('button[type="submit"]:visible, button:has-text("Send"):visible, button:has-text("Submit"):visible');
        if (submitButton) {
          log('Found submit button, clicking...');
          await submitButton.click();
          await page.waitForTimeout(2000);

          await page.screenshot({ path: '/tmp/flow-04-after-submit.png', fullPage: true });
          log('📸 After submit screenshot saved');
        } else {
          log('No submit button found near input');
        }
      } catch (e) {
        log(`Error interacting with input: ${e.message}`);
      }
    }

    // Check for authentication prompts
    log('Checking authentication state...');

    const authVisible = await page.evaluate(() => {
      const loginModal = document.querySelector('[id*="login"], [class*="login"], [id*="auth"], [class*="auth"]');
      if (!loginModal) return false;

      const style = window.getComputedStyle(loginModal);
      return style.display !== 'none' && loginModal.offsetParent !== null;
    });

    log(`Authentication UI visible: ${authVisible}`);

    if (authVisible) {
      log('Found authentication UI - testing form fields...');
      await page.screenshot({ path: '/tmp/flow-05-auth-modal.png' });
      log('📸 Auth modal screenshot saved');
    }

    // Final state check
    log('Checking final UI state...');

    const finalState = await page.evaluate(() => {
      return {
        url: window.location.href,
        title: document.title,
        visibleButtons: document.querySelectorAll('button:visible').length,
        visibleInputs: document.querySelectorAll('input:visible, textarea:visible').length,
        ps101Elements: document.querySelectorAll('[data-ps101], .ps101').length,
        errorMessages: document.querySelectorAll('.error:visible, [role="alert"]:visible').length
      };
    });

    console.log('\n📊 FINAL STATE:\n');
    console.log(`   URL: ${finalState.url}`);
    console.log(`   Title: ${finalState.title}`);
    console.log(`   Visible buttons: ${finalState.visibleButtons}`);
    console.log(`   Visible inputs: ${finalState.visibleInputs}`);
    console.log(`   PS101 elements: ${finalState.ps101Elements}`);
    console.log(`   Error messages: ${finalState.errorMessages}`);

    await page.screenshot({ path: '/tmp/flow-06-final-state.png', fullPage: true });
    log('📸 Final state screenshot saved');

    log('Keeping browser open for 5 seconds for inspection...');
    await page.waitForTimeout(5000);

  } catch (error) {
    console.log(`\n❌ Flow test error: ${error.message}`);
  } finally {
    await browser.close();
  }

  console.log('\n✅ User flow test complete');
  console.log('\nScreenshots saved to:');
  console.log('   /tmp/flow-01-landing.png');
  console.log('   /tmp/flow-02-after-cta.png');
  console.log('   /tmp/flow-03-input-filled.png');
  console.log('   /tmp/flow-04-after-submit.png');
  console.log('   /tmp/flow-05-auth-modal.png');
  console.log('   /tmp/flow-06-final-state.png');
})();
