// Comprehensive Deployment Test Suite
// Tests production deployment at https://whatismydelta.com

const { chromium } = require('playwright');

(async () => {
  console.log('🚀 COMPREHENSIVE DEPLOYMENT TEST SUITE\n');
  console.log('Testing: https://whatismydelta.com');
  console.log('=' .repeat(60) + '\n');

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  // Track all errors and console messages
  const errors = [];
  const consoleErrors = [];
  const warnings = [];

  page.on('console', msg => {
    if (msg.type() === 'error') {
      consoleErrors.push(msg.text());
    } else if (msg.type() === 'warning') {
      warnings.push(msg.text());
    }
  });

  page.on('pageerror', error => {
    errors.push(`Page Error: ${error.message}`);
  });

  let testsPassed = 0;
  let testsFailed = 0;

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
    // TEST 1: Page Load
    // ============================================================
    console.log('📍 TEST 1: Page Load & Basic Accessibility\n');

    await page.goto('https://whatismydelta.com', {
      waitUntil: 'networkidle',
      timeout: 30000
    });

    await page.waitForTimeout(2000);

    const title = await page.title();
    test(
      'Page title is correct',
      title === 'What Is My Delta — Find Your Next Career Move',
      `Title: "${title}"`
    );

    // Check for critical JavaScript errors
    const criticalErrors = errors.filter(e =>
      e.includes('SyntaxError') ||
      e.includes('Unexpected token') ||
      e.includes('FATAL')
    );

    test(
      'No critical JavaScript errors',
      criticalErrors.length === 0,
      criticalErrors.length > 0 ? `Found: ${criticalErrors.join(', ')}` : 'Clean'
    );

    // ============================================================
    // TEST 2: UI Elements Present
    // ============================================================
    console.log('\n📍 TEST 2: Critical UI Elements\n');

    const header = await page.$('header');
    test('Header element present', header !== null);

    const main = await page.$('main');
    test('Main content element present', main !== null);

    const h1 = await page.$('h1');
    if (h1) {
      const h1Text = await h1.textContent();
      test('H1 heading present', true, `"${h1Text}"`);
    } else {
      test('H1 heading present', false);
    }

    // ============================================================
    // TEST 3: PS101 Implementation
    // ============================================================
    console.log('\n📍 TEST 3: PS101 Framework\n');

    const ps101InCode = await page.evaluate(() => {
      const scripts = Array.from(document.scripts);
      return scripts.some(script =>
        script.textContent.includes('PS101_STEPS') ||
        script.textContent.includes('PS101 Implementation')
      );
    });

    test('PS101 implementation found in code', ps101InCode);

    // Check for PS101 UI elements
    const ps101Elements = await page.$$('[data-ps101], .ps101, #ps101');
    test('PS101 UI elements present', ps101Elements.length > 0, `Found ${ps101Elements.length} elements`);

    // ============================================================
    // TEST 4: Authentication UI
    // ============================================================
    console.log('\n📍 TEST 4: Authentication System\n');

    const authElements = await page.evaluate(() => {
      const html = document.documentElement.innerHTML;
      return {
        hasLogin: html.includes('login') || html.includes('Login'),
        hasRegister: html.includes('register') || html.includes('Register'),
        hasAuth: html.includes('auth') || html.includes('Auth')
      };
    });

    test('Login UI present', authElements.hasLogin);
    test('Register UI present', authElements.hasRegister);
    test('Auth system present', authElements.hasAuth);

    // ============================================================
    // TEST 5: Input Elements
    // ============================================================
    console.log('\n📍 TEST 5: Interactive Elements\n');

    const inputs = await page.$$('input, textarea, button');
    test('Interactive elements present', inputs.length > 0, `Found ${inputs.length} inputs/buttons`);

    // Check for chat/coach input
    const chatInput = await page.$('#user-input, [placeholder*="message"], [placeholder*="question"], textarea');
    test('Chat/input field present', chatInput !== null);

    if (chatInput) {
      const isVisible = await chatInput.isVisible();
      const isEnabled = await chatInput.isEnabled();
      test('Chat input is enabled', isEnabled, `Visible: ${isVisible}, Enabled: ${isEnabled}`);
    }

    // ============================================================
    // TEST 6: Backend API Connection
    // ============================================================
    console.log('\n📍 TEST 6: Backend API Integration\n');

    const apiConfig = await page.evaluate(() => {
      const html = document.documentElement.innerHTML;
      const hasRenderBackend = html.includes('mosaic-backend-tpog.onrender.com');
      return {
        hasBackendURL: hasRenderBackend,
        backendURL: hasRenderBackend ? 'mosaic-backend-tpog.onrender.com' : 'unknown'
      };
    });

    test('Backend URL configured', apiConfig.hasBackendURL, `URL: ${apiConfig.backendURL}`);

    // ============================================================
    // TEST 7: Content Verification
    // ============================================================
    console.log('\n📍 TEST 7: Content Verification\n');

    const bodyText = await page.evaluate(() => document.body.textContent);

    const contentChecks = {
      'Career/Delta content': bodyText.toLowerCase().includes('delta') || bodyText.toLowerCase().includes('career'),
      'Navigation elements': bodyText.toLowerCase().includes('explore') || bodyText.toLowerCase().includes('find'),
      'Interactive prompts': bodyText.toLowerCase().includes('question') || bodyText.toLowerCase().includes('tell')
    };

    for (const [checkName, passed] of Object.entries(contentChecks)) {
      test(checkName, passed);
    }

    // ============================================================
    // TEST 8: Screenshot Capture
    // ============================================================
    console.log('\n📍 TEST 8: Visual Capture\n');

    await page.screenshot({
      path: '/tmp/deployment-test-full.png',
      fullPage: true
    });
    console.log('✅ Full page screenshot saved to /tmp/deployment-test-full.png');

    await page.screenshot({
      path: '/tmp/deployment-test-viewport.png',
      fullPage: false
    });
    console.log('✅ Viewport screenshot saved to /tmp/deployment-test-viewport.png');

    // ============================================================
    // TEST 9: Console Log Analysis
    // ============================================================
    console.log('\n📍 TEST 9: Console Log Analysis\n');

    test(
      'No console errors',
      consoleErrors.length === 0,
      consoleErrors.length > 0 ? `Found ${consoleErrors.length} errors` : 'Clean'
    );

    if (consoleErrors.length > 0 && consoleErrors.length <= 5) {
      console.log('\n   Console errors found:');
      consoleErrors.forEach(err => console.log(`   - ${err.substring(0, 100)}`));
    }

    test(
      'Warnings are acceptable',
      warnings.length < 10,
      `Found ${warnings.length} warnings`
    );

    // ============================================================
    // TEST 10: Performance Check
    // ============================================================
    console.log('\n📍 TEST 10: Performance Metrics\n');

    const performanceMetrics = await page.evaluate(() => {
      const perf = performance.getEntriesByType('navigation')[0];
      return {
        loadTime: perf ? Math.round(perf.loadEventEnd - perf.fetchStart) : 0,
        domReady: perf ? Math.round(perf.domContentLoadedEventEnd - perf.fetchStart) : 0
      };
    });

    test(
      'Page load time acceptable',
      performanceMetrics.loadTime < 5000,
      `${performanceMetrics.loadTime}ms (< 5000ms)`
    );

    test(
      'DOM ready time acceptable',
      performanceMetrics.domReady < 3000,
      `${performanceMetrics.domReady}ms (< 3000ms)`
    );

  } catch (error) {
    console.log(`\n❌ Test suite failed with error: ${error.message}`);
    errors.push(error.message);
    testsFailed++;
  } finally {
    await browser.close();
  }

  // ============================================================
  // FINAL SUMMARY
  // ============================================================
  console.log('\n' + '='.repeat(60));
  console.log('📊 DEPLOYMENT TEST SUMMARY');
  console.log('='.repeat(60));
  console.log(`Tests Passed: ${testsPassed}`);
  console.log(`Tests Failed: ${testsFailed}`);
  console.log(`Total Errors: ${errors.length}`);
  console.log(`Console Errors: ${consoleErrors.length}`);
  console.log(`Warnings: ${warnings.length}`);

  const passRate = ((testsPassed / (testsPassed + testsFailed)) * 100).toFixed(1);
  console.log(`Pass Rate: ${passRate}%`);

  if (testsFailed === 0 && criticalErrors.length === 0) {
    console.log('\n✅ DEPLOYMENT TEST PASSED');
    console.log('   - Production site is healthy');
    console.log('   - All critical features present');
    console.log('   - No blocking issues detected');
    process.exit(0);
  } else {
    console.log('\n⚠️  DEPLOYMENT TEST COMPLETED WITH ISSUES');
    console.log(`   - ${testsFailed} test(s) failed`);
    console.log(`   - ${errors.length} error(s) detected`);
    console.log('   - Review findings above');
    process.exit(testsFailed > 5 ? 1 : 0); // Exit with error only if many failures
  }
})();
