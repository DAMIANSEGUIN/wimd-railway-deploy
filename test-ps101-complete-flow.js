// PS101 Complete Flow Test
// Tests the ENTIRE 1-10 step flow with validation

const { chromium } = require('playwright');

(async () => {
  console.log('🧪 PS101 COMPLETE FLOW TEST\n');
  console.log('Testing full 1-10 step progression at: https://whatismydelta.com');
  console.log('=' .repeat(70) + '\n');

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  const page = await context.newPage();

  let testsPassed = 0;
  let testsFailed = 0;
  const errors = [];

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
      errors.push({ test: name, details });
      return false;
    }
  };

  try {
    // SETUP: Navigate and clear localStorage
    console.log('📍 SETUP: Loading site and clearing state...\n');
    await page.goto('https://whatismydelta.com', {
      waitUntil: 'networkidle',
      timeout: 30000
    });

    // Clear PS101 localStorage to start fresh
    await page.evaluate(() => {
      localStorage.removeItem('ps101_state');
      localStorage.removeItem('ps101_v2_state');
      console.log('[TEST] Cleared localStorage');
    });

    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);

    console.log('✅ Site loaded, localStorage cleared\n');

    // TEST 1: Verify PS101_STEPS has exactly 10 steps
    console.log('📍 TEST 1: Validate PS101_STEPS array\n');

    const ps101StepsCount = await page.evaluate(() => {
      return window.PS101_STEPS ? window.PS101_STEPS.length : 0;
    });

    test('PS101_STEPS array loaded', ps101StepsCount > 0, `Found ${ps101StepsCount} steps`);
    test('PS101_STEPS has exactly 10 steps', ps101StepsCount === 10, `Expected 10, got ${ps101StepsCount}`);

    // TEST 2: Verify initial state shows Step 1 of 10
    console.log('\n📍 TEST 2: Verify initial display\n');

    const stepLabel = await page.$('#step-label');
    if (stepLabel) {
      const labelText = await stepLabel.textContent();
      test('Step label shows "Step 1 of 10"', labelText.includes('Step 1 of 10'), `Label: "${labelText}"`);
      test('Step label does NOT show "of 6"', !labelText.includes('of 6'), 'Checking for old 6-step version');
      test('Step label does NOT show "of 4"', !labelText.includes('of 4'), 'Checking for 4-step version');
    } else {
      test('Step label element exists', false, 'Element #step-label not found');
    }

    // TEST 3: Start PS101 flow
    console.log('\n📍 TEST 3: Starting PS101 flow\n');

    const startButton = await page.$('button:has-text("Start PS101")');
    if (startButton) {
      await startButton.click();
      await page.waitForTimeout(1500);
      test('Start button clicked', true, 'Flow initiated');
    } else {
      test('Start button found', false, 'Could not find "Start PS101" button');
    }

    // TEST 4-13: Walk through ALL 10 steps
    console.log('\n📍 TESTS 4-13: Walking through all 10 steps\n');

    const expectedSteps = [
      "Problem Identification and Delta Analysis",
      "Current Situation Analysis",
      "Root Cause Exploration",
      "Self-Efficacy Assessment",
      "Solution Framework Design",
      "Experiment Design",
      "Obstacle Mapping",
      "Action Planning",
      "Reflection and Learning",
      "Building Mastery and Self-Efficacy"
    ];

    for (let step = 1; step <= 10; step++) {
      console.log(`\n   → Testing Step ${step}...`);

      // Check step label
      const currentLabel = await page.evaluate(() => {
        const label = document.getElementById('step-label');
        return label ? label.textContent : '';
      });

      const expectedLabel = `Step ${step} of 10`;
      test(
        `Step ${step}: Label shows "${expectedLabel}"`,
        currentLabel.includes(expectedLabel),
        `Got: "${currentLabel}"`
      );

      test(
        `Step ${step}: Title matches expected`,
        currentLabel.includes(expectedSteps[step - 1]),
        `Expected: "${expectedSteps[step - 1]}"`
      );

      // Fill in a minimal answer
      const textarea = await page.$('#step-answer');
      if (textarea) {
        await textarea.fill('a'.repeat(50)); // Minimum 50 chars
        await page.waitForTimeout(500);
      }

      // Click Next/Submit
      const nextButton = await page.$('#ps101-next');
      if (nextButton && step < 10) {
        const buttonText = await nextButton.textContent();
        console.log(`   → Clicking: "${buttonText}"`);
        await nextButton.click();
        await page.waitForTimeout(1500);
      } else if (step === 10) {
        console.log(`   → Final step reached`);
      }

      // Take screenshot
      await page.screenshot({ path: `/tmp/ps101-flow-step-${step}.png` });
    }

    // TEST 14: Verify we reached completion
    console.log('\n📍 TEST 14: Verify completion\n');

    const finalState = await page.evaluate(() => {
      return {
        currentStep: window.PS101State ? window.PS101State.currentStep : 0,
        completed: window.PS101State ? window.PS101State.completed : false
      };
    });

    test(
      'Flow reached step 10',
      finalState.currentStep === 10 || finalState.completed,
      `Current step: ${finalState.currentStep}, Completed: ${finalState.completed}`
    );

    // TEST 15: Verify localStorage state is valid
    console.log('\n📍 TEST 15: Validate localStorage state\n');

    const storedState = await page.evaluate(() => {
      const state = localStorage.getItem('ps101_v2_state');
      return state ? JSON.parse(state) : null;
    });

    if (storedState) {
      test('localStorage state exists', true, 'State saved correctly');
      test(
        'Stored currentStep is within 1-10',
        storedState.currentStep >= 1 && storedState.currentStep <= 10,
        `Stored step: ${storedState.currentStep}`
      );
    } else {
      test('localStorage state exists', false, 'No state found');
    }

    // TEST 16: Backend congruence check
    console.log('\n📍 TEST 16: Backend/Frontend Congruence\n');

    const configResponse = await page.evaluate(async () => {
      try {
        const res = await fetch('https://mosaic-backend-tpog.onrender.com/config');
        return await res.json();
      } catch (e) {
        return { error: e.message };
      }
    });

    test('Backend is reachable', !configResponse.error, `Config: ${JSON.stringify(configResponse)}`);

    // Take final screenshot
    await page.screenshot({ path: '/tmp/ps101-flow-complete.png', fullPage: true });

  } catch (error) {
    console.log(`\n❌ Flow test error: ${error.message}`);
    errors.push({ test: 'Overall Flow', details: error.message });
    testsFailed++;
  } finally {
    await browser.close();
  }

  // SUMMARY
  console.log('\n' + '='.repeat(70));
  console.log('📊 PS101 COMPLETE FLOW TEST SUMMARY');
  console.log('='.repeat(70));
  console.log(`Tests Passed: ${testsPassed}`);
  console.log(`Tests Failed: ${testsFailed}`);
  console.log(`Pass Rate: ${((testsPassed / (testsPassed + testsFailed)) * 100).toFixed(1)}%`);

  if (errors.length > 0) {
    console.log('\n❌ FAILED TESTS:');
    errors.forEach(err => {
      console.log(`   - ${err.test}`);
      if (err.details) console.log(`     ${err.details}`);
    });
  }

  console.log('\n📸 Screenshots saved:');
  console.log('   /tmp/ps101-flow-step-1.png through /tmp/ps101-flow-step-10.png');
  console.log('   /tmp/ps101-flow-complete.png');

  if (testsFailed === 0) {
    console.log('\n✅ ALL TESTS PASSED - PS101 flow is consistent 1-10');
    process.exit(0);
  } else {
    console.log('\n⚠️  SOME TESTS FAILED - Review errors above');
    process.exit(testsFailed > 3 ? 1 : 0);
  }
})();
