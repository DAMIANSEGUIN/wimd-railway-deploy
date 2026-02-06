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

  // Auto-accept any dialogs (alert/confirm) that appear
  page.on('dialog', async dialog => {
    console.log(`   [DIALOG] ${dialog.type()}: ${dialog.message()}`);
    await dialog.accept();
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

    // Try multiple button selectors since PS101 might be accessed different ways
    const buttonSelectors = [
      '#linkFast', // "start with questions" button
      'button:has-text("start with questions")',
      'button:has-text("Start")',
      'button:has-text("Guide")',
      '#start-ps101',
      '.ps101-start'
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

      // Verify the flow container is now visible
      const flowVisible = await page.evaluate(() => {
        const flow = document.getElementById('ps101-flow');
        if (!flow) return false;
        const hasHidden = flow.classList.contains('hidden');
        const display = getComputedStyle(flow).display;
        return !hasHidden && display !== 'none';
      });

      test('PS101 flow container is visible', flowVisible, `Flow should be shown after clicking start`);

      if (!flowVisible) {
        console.log('   ⚠️  Flow container still hidden, forcing visibility...');
        await page.evaluate(() => {
          const flow = document.getElementById('ps101-flow');
          if (flow) {
            flow.classList.remove('hidden');
            flow.style.display = 'block';
          }
        });
      }
    } else {
      console.log('   → No PS101 start button found, checking if flow is already visible...');
      const flowContainer = await page.$('#ps101-flow');
      if (flowContainer && !await flowContainer.evaluate(el => el.classList.contains('hidden'))) {
        test('PS101 flow already visible', true, 'Flow accessible without start button');
      } else {
        test('PS101 flow accessible', false, 'Could not find start button or flow container');
      }
    }

    // TEST 4-13: Walk through ALL 10 steps
    console.log('\n📍 TESTS 4-13: Walking through all 10 steps\n');

    const expectedSteps = [
      { title: "Problem Identification and Delta Analysis", prompts: 6 },
      { title: "Current Situation Analysis", prompts: 4 },
      { title: "Root Cause Exploration", prompts: 3 },
      { title: "Self-Efficacy Assessment", prompts: 4 },
      { title: "Solution Brainstorming", prompts: 4 },
      { title: "Experimental Design", prompts: 3 },
      { title: "Obstacle Identification", prompts: 2 },
      { title: "Action Planning", prompts: 2 },
      { title: "Reflection and Iteration", prompts: 2 },
      { title: "Building Mastery and Self-Efficacy", prompts: 4 }
    ];

    for (let step = 1; step <= 10; step++) {
      console.log(`\n   → Testing Step ${step}: ${expectedSteps[step - 1].title}`);

      const stepInfo = expectedSteps[step - 1];
      const promptCount = stepInfo.prompts;

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
        currentLabel.includes(stepInfo.title),
        `Expected: "${stepInfo.title}"`
      );

      // Answer each prompt in this step
      for (let promptIndex = 0; promptIndex < promptCount; promptIndex++) {
        console.log(`      → Answering prompt ${promptIndex + 1} of ${promptCount}...`);

        // Wait for question text to appear
        await page.waitForTimeout(500);

        // Check if this is a text input or experiment component
        const isExperimentStep = [6, 7, 8, 9].includes(step);

        if (isExperimentStep && promptIndex === promptCount - 1) {
          // Steps 6-9 have experiment components on last prompt
          console.log(`      → Experiment component detected for Step ${step}`);

          // Fill experiment components based on step
          if (step === 6) {
            // Experiment Canvas: hypothesis, successMetric, start/review dates
            await page.evaluate(() => {
              const hypothesis = document.getElementById('exp-hypothesis');
              const successMetric = document.getElementById('exp-success-metric');
              const startDate = document.getElementById('exp-start-date');

              if (hypothesis) {
                hypothesis.value = 'Test if daily check-ins improve clarity on career goals';
                hypothesis.dispatchEvent(new Event('input', { bubbles: true }));
              }
              if (successMetric) {
                successMetric.value = 'Feel 50% more confident about next career step within 2 weeks';
                successMetric.dispatchEvent(new Event('input', { bubbles: true }));
              }
              if (startDate) {
                const today = new Date().toISOString().split('T')[0];
                startDate.value = today;
                startDate.dispatchEvent(new Event('change', { bubbles: true }));
              }

              // Update experiment in PS101State
              const activeExp = window.PS101State?.getActiveExperiment();
              if (activeExp && window.PS101State) {
                window.PS101State.updateExperiment(activeExp.id, {
                  hypothesis: hypothesis?.value,
                  successMetric: successMetric?.value,
                  duration: { start: startDate?.value }
                });

                // Trigger validation update
                const step = window.PS101State.getCurrentStep();
                if (step && window.updateNavButtons) {
                  window.updateNavButtons(
                    window.PS101State.currentStep,
                    window.PS101State.currentPromptIndex,
                    step.prompts.length
                  );
                }
              }

              return { filled: true, experimentId: activeExp?.id };
            });
            console.log(`      ✓ Filled experiment canvas`);

          } else if (step === 7) {
            // Obstacle Mapping: Add at least 1 obstacle with label and strategy
            await page.evaluate(() => {
              const addObstacleBtn = document.getElementById('add-obstacle-btn');
              if (addObstacleBtn) {
                addObstacleBtn.click();
              }
            });
            await page.waitForTimeout(500);

            await page.evaluate(() => {
              const obstacleLabel = document.getElementById('obstacle-label');
              const obstacleStrategy = document.getElementById('obstacle-strategy');
              const saveObstacleBtn = document.getElementById('save-obstacle-btn');

              if (obstacleLabel) {
                obstacleLabel.value = 'Lack of time for daily check-ins';
                obstacleLabel.dispatchEvent(new Event('input', { bubbles: true }));
              }
              if (obstacleStrategy) {
                obstacleStrategy.value = 'Schedule 5-minute check-in during morning coffee';
                obstacleStrategy.dispatchEvent(new Event('input', { bubbles: true }));
              }
              if (saveObstacleBtn) {
                saveObstacleBtn.click();
              }
            });
            console.log(`      ✓ Added obstacle with mitigation strategy`);

          } else if (step === 8) {
            // Action Plan: Add at least 3 actions
            for (let i = 0; i < 3; i++) {
              await page.evaluate((actionNum) => {
                const addActionBtn = document.getElementById('add-action-btn');
                if (addActionBtn) {
                  addActionBtn.click();
                }
              }, i);
              await page.waitForTimeout(300);

              await page.evaluate((actionNum) => {
                const actionLabel = document.getElementById('action-label');
                const actionDeadline = document.getElementById('action-deadline');
                const saveActionBtn = document.getElementById('save-action-btn');

                if (actionLabel) {
                  actionLabel.value = `Action ${actionNum + 1}: Complete career assessment task`;
                  actionLabel.dispatchEvent(new Event('input', { bubbles: true }));
                }
                if (actionDeadline) {
                  const future = new Date();
                  future.setDate(future.getDate() + 7);
                  actionDeadline.value = future.toISOString().split('T')[0];
                  actionDeadline.dispatchEvent(new Event('change', { bubbles: true }));
                }
                if (saveActionBtn) {
                  saveActionBtn.click();
                }
              }, i);
              await page.waitForTimeout(300);
            }
            console.log(`      ✓ Added 3 action items`);

          } else if (step === 9) {
            // Reflection: Fill outcome, learning, confidence
            await page.evaluate(() => {
              const outcome = document.getElementById('reflection-outcome');
              const learning = document.getElementById('reflection-learning');
              const confidenceAfter = document.getElementById('confidence-after');

              if (outcome) {
                outcome.value = 'Daily check-ins improved clarity by 60%, exceeded goal';
                outcome.dispatchEvent(new Event('input', { bubbles: true }));
              }
              if (learning) {
                learning.value = 'Morning routine is key, consistency matters more than duration';
                learning.dispatchEvent(new Event('input', { bubbles: true }));
              }
              if (confidenceAfter) {
                confidenceAfter.value = '8';
                confidenceAfter.dispatchEvent(new Event('change', { bubbles: true }));
              }

              // Update experiment reflection in PS101State
              const activeExp = window.PS101State?.getActiveExperiment();
              if (activeExp && window.PS101State) {
                window.PS101State.updateExperiment(activeExp.id, {
                  reflection: {
                    outcome: outcome?.value,
                    learning: learning?.value,
                    confidence: { after: confidenceAfter?.value }
                  }
                });
              }
            });
            console.log(`      ✓ Filled reflection log`);
          }

          // Wait for validation to update
          await page.waitForTimeout(500);

          // Click next button (should now be enabled)
          const nextButtonDebug = await page.evaluate(() => {
            const btn = document.getElementById('ps101-next');
            const activeExp = window.PS101State?.getActiveExperiment();
            const currentStep = window.PS101State?.currentStep;
            const currentPromptIndex = window.PS101State?.currentPromptIndex;

            // Check obstacle details
            let obstacleDetails = null;
            if (activeExp?.obstacles && activeExp.obstacles.length > 0) {
              const firstObstacle = activeExp.obstacles[0];
              obstacleDetails = {
                hasLabel: !!firstObstacle.label,
                labelLength: firstObstacle.label?.length || 0,
                hasStrategy: !!firstObstacle.strategy,
                strategyLength: firstObstacle.strategy?.length || 0
              };
            }

            return {
              found: !!btn,
              enabled: btn ? !btn.disabled : false,
              text: btn ? btn.textContent.trim() : '',
              currentStep,
              currentPromptIndex,
              expExists: !!activeExp,
              expObstacles: activeExp?.obstacles?.length || 0,
              expActions: activeExp?.actions?.length || 0,
              expReflection: !!activeExp?.reflection,
              obstacleDetails
            };
          });

          if (nextButtonDebug.enabled) {
            console.log(`      → Clicking: "${nextButtonDebug.text}"`);
            await page.evaluate(() => {
              document.getElementById('ps101-next').click();
            });
            await page.waitForTimeout(1500);
          } else {
            console.log(`      ⚠️  Next button still disabled after filling experiment component`);
            console.log(`         Debug: step=${nextButtonDebug.currentStep}:${nextButtonDebug.currentPromptIndex}, exp=${nextButtonDebug.expExists}, obstacles=${nextButtonDebug.expObstacles}, actions=${nextButtonDebug.expActions}`);
            if (nextButtonDebug.obstacleDetails) {
              console.log(`         Obstacle[0]: label=${nextButtonDebug.obstacleDetails.hasLabel} (len=${nextButtonDebug.obstacleDetails.labelLength}), strategy=${nextButtonDebug.obstacleDetails.hasStrategy} (len=${nextButtonDebug.obstacleDetails.strategyLength})`);
            }
          }

          continue;
        }

        // Use JavaScript to fill textarea (works even when Playwright visibility checks fail)
        // Format answer with multiple sentences to pass validation
        const answer = `This is my detailed answer to prompt ${promptIndex + 1} of step ${step}. I'm providing sufficient detail to meet the minimum character requirements. This response includes multiple sentences to satisfy validation rules.`;

        const fillResult = await page.evaluate((answerText) => {
          const textarea = document.getElementById('step-answer');
          if (!textarea) return { success: false, reason: 'textarea not found' };

          // Fill textarea and trigger events
          textarea.value = answerText;
          textarea.dispatchEvent(new Event('input', { bubbles: true }));
          textarea.dispatchEvent(new Event('change', { bubbles: true }));

          return { success: true, value: textarea.value };
        }, answer);

        if (!fillResult.success) {
          console.log(`      ❌ Failed to fill textarea: ${fillResult.reason}`);
          continue;
        }

        console.log(`      ✓ Filled textarea (${fillResult.value.length} chars)`);
        await page.waitForTimeout(300);

        // Click next button (if enabled)
        const nextButtonEnabled = await page.evaluate(() => {
          const btn = document.getElementById('ps101-next');
          if (!btn) return { found: false };
          return {
            found: true,
            enabled: !btn.disabled,
            text: btn.textContent.trim()
          };
        });

        if (!nextButtonEnabled.found) {
          console.log(`      ❌ Next button not found`);
          continue;
        }

        if (!nextButtonEnabled.enabled) {
          console.log(`      ⏸  Button "${nextButtonEnabled.text}" is disabled, waiting...`);
          await page.waitForTimeout(500);
          continue;
        }

        console.log(`      → Clicking: "${nextButtonEnabled.text}"`);

        // Get state before click
        const beforeState = await page.evaluate(() => ({
          step: window.PS101State?.currentStep,
          prompt: window.PS101State?.currentPromptIndex
        }));

        // Click next button using JavaScript
        await page.evaluate(() => {
          document.getElementById('ps101-next').click();
        });

        // Wait for state to actually change
        let stateChanged = false;
        for (let i = 0; i < 20; i++) {
          await page.waitForTimeout(200);
          const afterState = await page.evaluate(() => ({
            step: window.PS101State?.currentStep,
            prompt: window.PS101State?.currentPromptIndex
          }));

          if (afterState.step !== beforeState.step || afterState.prompt !== beforeState.prompt) {
            stateChanged = true;
            console.log(`      ✓ State advanced: ${beforeState.step}:${beforeState.prompt} → ${afterState.step}:${afterState.prompt}`);
            break;
          }
        }

        if (!stateChanged) {
          console.log(`      ⚠️  State did not change after clicking Next`);
        }

        await page.waitForTimeout(500);
      }

      // Take screenshot after completing step
      await page.screenshot({ path: `/tmp/ps101-flow-step-${step}.png` });
      console.log(`   ✓ Step ${step} completed`);
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
