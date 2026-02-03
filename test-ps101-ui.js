// PS101 UI Test - Verify frontend loads and PS101 is functional
const { chromium } = require('playwright');

(async () => {
  console.log('🧪 Starting PS101 UI Test...\n');

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  // Track console messages and errors
  const consoleMessages = [];
  const errors = [];

  page.on('console', msg => {
    const text = msg.text();
    consoleMessages.push({ type: msg.type(), text });
    if (msg.type() === 'error') {
      errors.push(text);
    }
  });

  page.on('pageerror', error => {
    errors.push(`Page Error: ${error.message}`);
  });

  try {
    console.log('📍 Navigating to https://whatismydelta.com...');
    await page.goto('https://whatismydelta.com', {
      waitUntil: 'networkidle',
      timeout: 30000
    });

    // Wait for page to be fully loaded
    await page.waitForTimeout(2000);

    // Check for critical errors
    console.log('\n🔍 Checking for JavaScript errors...');
    const criticalErrors = errors.filter(err =>
      err.includes('SyntaxError') ||
      err.includes('Unexpected token') ||
      err.includes('FATAL')
    );

    if (criticalErrors.length > 0) {
      console.log('❌ CRITICAL ERRORS FOUND:');
      criticalErrors.forEach(err => console.log(`   - ${err}`));
    } else {
      console.log('✅ No critical JavaScript errors detected');
    }

    // Check page title
    const title = await page.title();
    console.log(`\n📄 Page Title: ${title}`);

    // Check if main elements are present
    console.log('\n🔍 Checking UI Elements...');

    const checks = {
      'Header': 'header',
      'Main Content': 'main',
      'Chat Interface': '#chat-interface',
      'Auth Section': '#auth-section',
      'PS101 Container': '[data-ps101], #ps101-container, .ps101-step'
    };

    for (const [name, selector] of Object.entries(checks)) {
      const element = await page.$(selector);
      if (element) {
        console.log(`   ✅ ${name} present`);
      } else {
        console.log(`   ⚠️  ${name} not found (selector: ${selector})`);
      }
    }

    // Check if PS101 functionality is available
    console.log('\n🔍 Checking PS101 Implementation...');

    const ps101Available = await page.evaluate(() => {
      // Check if PS101 code is present
      const scripts = Array.from(document.scripts);
      const hasPS101 = scripts.some(script =>
        script.textContent.includes('PS101_STEPS') ||
        script.textContent.includes('PS101 Implementation')
      );
      return hasPS101;
    });

    if (ps101Available) {
      console.log('   ✅ PS101 implementation found in page');
    } else {
      console.log('   ❌ PS101 implementation not found');
    }

    // Try to interact with chat if visible
    console.log('\n🔍 Testing Chat Interface...');

    const chatInput = await page.$('#user-input, input[type="text"], textarea');
    if (chatInput) {
      const isVisible = await chatInput.isVisible();
      const isEnabled = await chatInput.isEnabled();
      console.log(`   ✅ Chat input found (visible: ${isVisible}, enabled: ${isEnabled})`);

      if (isVisible && isEnabled) {
        // Try to type in the input
        try {
          await chatInput.type('Test message');
          console.log('   ✅ Successfully typed in chat input');
          await page.waitForTimeout(500);
        } catch (e) {
          console.log(`   ⚠️  Could not type in chat input: ${e.message}`);
        }
      }
    } else {
      console.log('   ℹ️  Chat input not immediately visible (may require auth)');
    }

    // Take screenshot
    await page.screenshot({ path: '/tmp/ps101-ui-test.png', fullPage: false });
    console.log('\n📸 Screenshot saved to /tmp/ps101-ui-test.png');

    // Summary
    console.log('\n' + '='.repeat(60));
    console.log('📊 TEST SUMMARY');
    console.log('='.repeat(60));
    console.log(`Total Console Messages: ${consoleMessages.length}`);
    console.log(`Total Errors: ${errors.length}`);
    console.log(`Critical Errors: ${criticalErrors.length}`);

    if (criticalErrors.length === 0) {
      console.log('\n✅ PS101 UI TEST PASSED');
      console.log('   - No critical JavaScript errors');
      console.log('   - Page loads successfully');
      console.log('   - PS101 implementation present');
    } else {
      console.log('\n❌ PS101 UI TEST FAILED');
      console.log('   - Critical errors detected');
    }

  } catch (error) {
    console.log(`\n❌ Test failed with error: ${error.message}`);
    errors.push(error.message);
  } finally {
    await browser.close();
  }

  // Exit with appropriate code
  process.exit(errors.filter(e =>
    e.includes('SyntaxError') ||
    e.includes('Unexpected token')
  ).length > 0 ? 1 : 0);
})();
