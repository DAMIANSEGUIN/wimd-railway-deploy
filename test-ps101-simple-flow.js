// PS101 Simple Flow Test (v3 - 8 prompts)
// Tests the corrected 8-prompt linear architecture

const { chromium } = require('playwright');

(async () => {
  console.log('🧪 PS101 SIMPLE FLOW TEST (v3)\n');
  console.log('Testing 8-prompt linear progression at: https://whatismydelta.com');
  console.log('=' .repeat(70) + '\n');

  const launchOptions = { headless: false };
  if (process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH) {
    launchOptions.executablePath = process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH;
  }
  const browser = await chromium.launch(launchOptions);
  const context = await browser.newContext({
    viewport: { width: 1280, height: 720 }
  });
  const page = await context.newPage();

  // Capture console logs
  page.on('console', msg => {
    if (msg.text().includes('[PS101]')) {
      console.log(`         [BROWSER] ${msg.text()}`);
    }
  });

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

    // Clear all PS101 localStorage keys
    await page.evaluate(() => {
      localStorage.removeItem('ps101_state');
      localStorage.removeItem('ps101_v2_state');
      localStorage.removeItem('ps101_simple_state');
      console.log('[TEST] Cleared localStorage');
    });

    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);

    console.log('✅ Site loaded, localStorage cleared\n');

    // TEST 1: Verify new state structure exists
    console.log('📍 TEST 1: Validate PS101 v3 architecture\n');

    const hasNewState = await page.evaluate(() => {
      return typeof window.PS101State !== 'undefined';
    });

    test('PS101State object exists', hasNewState, 'New simple architecture loaded');

    const prompts = await page.evaluate(() => {
      return window.PS101State ? window.PS101State.prompts : [];
    });

    test('PS101State has prompts array', prompts.length > 0, `Found ${prompts.length} prompts`);
    test('PS101State has exactly 8 prompts', prompts.length === 8, `Expected 8, got ${prompts.length}`);

    // TEST 2: Verify initial display shows "Question 1 of 8"
    console.log('\n📍 TEST 2: Verify initial display\n');

    const stepLabel = await page.$('#step-label');
    if (stepLabel) {
      const labelText = await stepLabel.textContent();
      test('Step label shows "Question 1 of 8"', labelText.includes('Question 1 of 8'), `Label: "${labelText}"`);
      test('Step label does NOT show "Step 1 of 10"', !labelText.includes('Step 1 of 10'), 'Old architecture removed');
      test('Step label does NOT show "of 6"', !labelText.includes('of 6'), 'No nested prompts');
    } else {
      test('Step label element exists', false, 'Element #step-label not found');
    }

    // Count progress dots (should be 8)
    const dotCount = await page.evaluate(() => {
      return document.querySelectorAll('.progress-dots .dot').length;
    });

    test('Progress indicator has 8 dots', dotCount === 8, `Found ${dotCount} dots`);

    // TEST 3: Start PS101 flow
    console.log('\n📍 TEST 3: Starting PS101 flow\n');

    const buttonSelectors = [
      '#start-ps101',
      '#linkFast',
      'button:has-text("start with questions")',
      'button:has-text("Start")'
    ];

    let startButton = null;
    for (const selector of buttonSelectors) {
      startButton = await page.$(selector);
      if (startButton && await startButton.isVisible()) {
        console.log(`   → Found button with selector: ${selector}`);
        break;
      }
    }

    if (startButton) {
      await startButton.click();
      await page.waitForTimeout(1500);
      test('Start button clicked', true, 'Flow initiated');

      const flowVisible = await page.evaluate(() => {
        const flow = document.getElementById('ps101-flow');
        if (!flow) return false;
        const hasHidden = flow.classList.contains('hidden');
        const display = getComputedStyle(flow).display;
        return !hasHidden && display !== 'none';
      });

      test('PS101 flow container is visible', flowVisible, 'Flow shown after clicking start');

      if (!flowVisible) {
        console.log('   ⚠️  Flow container hidden, forcing visibility...');
        await page.evaluate(() => {
          const flow = document.getElementById('ps101-flow');
          if (flow) {
            flow.classList.remove('hidden');
            flow.style.display = 'block';
          }
        });
      }
    }

    // TEST 4-11: Walk through all 8 prompts
    console.log('\n📍 TESTS 4-11: Walking through all 8 prompts\n');

    for (let i = 0; i < 8; i++) {
      const questionNum = i + 1;
      console.log(`\n   → Testing Question ${questionNum} of 8`);

      // Verify label shows correct question number
      const currentLabel = await page.evaluate(() => {
        return document.getElementById('step-label')?.textContent || '';
      });

      test(
        `Question ${questionNum}: Label shows "Question ${questionNum} of 8"`,
        currentLabel.includes(`Question ${questionNum} of 8`),
        `Got: "${currentLabel}"`
      );

      // Get the prompt text
      const promptText = await page.evaluate(() => {
        return document.getElementById('question-text')?.textContent || '';
      });

      test(
        `Question ${questionNum}: Prompt text is present`,
        promptText.length > 10,
        `Prompt: "${promptText.substring(0, 50)}..."`
      );

      // Fill answer
      const textarea = await page.$('#step-answer');
      if (textarea) {
        const testAnswer = `This is my test answer for question ${questionNum}. I'm providing enough characters to pass the validation (minimum 10 characters required).`;
        await textarea.fill(testAnswer);
        await page.waitForTimeout(500);

        console.log(`      ✓ Filled answer (${testAnswer.length} chars)`);

        // Click Next (or Complete on question 8)
        const nextBtn = await page.$('#ps101-next');
        if (nextBtn) {
          const btnText = await nextBtn.textContent();
          const isEnabled = await nextBtn.evaluate(el => !el.disabled);

          test(
            `Question ${questionNum}: Next button enabled after valid answer`,
            isEnabled,
            `Button text: "${btnText}"`
          );

          if (isEnabled) {
            await nextBtn.click();
            await page.waitForTimeout(1000);

            console.log(`      ✓ Clicked: "${btnText}"`);

            // On question 8, we should see completion screen
            if (questionNum === 8) {
              const completionVisible = await page.evaluate(() => {
                const completion = document.getElementById('ps101-completion');
                return completion && !completion.classList.contains('hidden');
              });

              test(
                'Completion screen shown after question 8',
                completionVisible,
                'All 8 questions completed'
              );

              // Verify all 8 answers are displayed
              const answerCards = await page.evaluate(() => {
                return document.querySelectorAll('#completion-answers .answer-card').length;
              });

              test(
                'Completion shows all 8 answers',
                answerCards === 8,
                `Found ${answerCards} answer cards`
              );
            }
          } else {
            console.log(`      ⚠️  Next button disabled`);
          }
        } else {
          test(`Question ${questionNum}: Next button exists`, false, 'Button #ps101-next not found');
        }
      } else {
        test(`Question ${questionNum}: Textarea exists`, false, 'Element #step-answer not found');
      }
    }

    // TEST 12: Verify localStorage state
    console.log('\n📍 TEST 12: Verify localStorage state\n');

    const savedState = await page.evaluate(() => {
      const state = localStorage.getItem('ps101_simple_state');
      return state ? JSON.parse(state) : null;
    });

    test('localStorage has ps101_simple_state', savedState !== null, 'State persisted');

    if (savedState) {
      test('Saved state has 8 answers', savedState.answers?.length === 8, `Found ${savedState.answers?.length} answers`);
      test('Saved state marked as completed', savedState.completed === true, 'Flow completed');
    }

    // Take final screenshot
    await page.screenshot({ path: '/tmp/ps101-simple-flow-complete.png', fullPage: true });
    console.log('\n📸 Screenshot saved: /tmp/ps101-simple-flow-complete.png\n');

  } catch (error) {
    console.error('\n❌ Test error:', error.message);
    errors.push({ test: 'Overall Flow', details: error.message });
    testsFailed++;

    // Screenshot on error
    try {
      await page.screenshot({ path: '/tmp/ps101-simple-flow-error.png', fullPage: true });
      console.log('📸 Error screenshot: /tmp/ps101-simple-flow-error.png\n');
    } catch (screenshotError) {
      console.error('Could not capture error screenshot');
    }
  } finally {
    await browser.close();

    // Summary
    console.log('=' .repeat(70));
    console.log('📊 PS101 SIMPLE FLOW TEST SUMMARY');
    console.log('=' .repeat(70));
    console.log(`Tests Passed: ${testsPassed}`);
    console.log(`Tests Failed: ${testsFailed}`);
    console.log(`Pass Rate: ${((testsPassed / (testsPassed + testsFailed)) * 100).toFixed(1)}%\n`);

    if (testsFailed > 0) {
      console.log('❌ FAILED TESTS:');
      errors.forEach(({ test, details }) => {
        console.log(`   - ${test}`);
        if (details) console.log(`     ${details}`);
      });
      console.log('\n⚠️  SOME TESTS FAILED - Review errors above\n');
      process.exit(1);
    } else {
      console.log('✅ ALL TESTS PASSED\n');
      const receipt = {
        timestamp_utc: Math.floor(Date.now() / 1000),
        test_name: 'ps101-simple-flow-v3',
        target_url: 'https://whatismydelta.com',
        tests_passed: testsPassed,
        tests_failed: testsFailed,
        exit_code: 0
      };
      require('fs').writeFileSync('/tmp/e2e_receipt.json', JSON.stringify(receipt, null, 2));
      console.log('📋 E2E receipt written: /tmp/e2e_receipt.json\n');
      process.exit(0);
    }
  }
})();
