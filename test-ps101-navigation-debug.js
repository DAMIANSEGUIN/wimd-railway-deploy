// Focused diagnostic: Track PS101State during navigation
const { chromium } = require('playwright');

(async () => {
  console.log('🔍 PS101 NAVIGATION DEBUG\n');

  const browser = await chromium.launch({ headless: false, slowMo: 1000 });
  const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });

  await page.goto('https://whatismydelta.com', { waitUntil: 'networkidle' });

  // Clear localStorage
  await page.evaluate(() => {
    localStorage.removeItem('ps101_state');
    localStorage.removeItem('ps101_v2_state');
  });
  await page.reload({ waitUntil: 'networkidle' });

  // Click start
  const startBtn = await page.$('#linkFast');
  if (startBtn) {
    await startBtn.click();
    await page.waitForTimeout(2000);
  }

  // Force visibility
  await page.evaluate(() => {
    const flow = document.getElementById('ps101-flow');
    if (flow) {
      flow.classList.remove('hidden');
      flow.style.display = 'block';
    }
  });

  console.log('Starting navigation test through Steps 1-6...\n');

  for (let step = 1; step <= 6; step++) {
    console.log(`\n=== STEP ${step} ===`);

    const state = await page.evaluate(() => {
      return {
        currentStep: window.PS101State?.currentStep,
        currentPromptIndex: window.PS101State?.currentPromptIndex,
        stepLabel: document.getElementById('step-label')?.textContent,
        nextButtonText: document.getElementById('ps101-next')?.textContent?.trim(),
        nextButtonDisabled: document.getElementById('ps101-next')?.disabled
      };
    });

    console.log(`Current State:`, JSON.stringify(state, null, 2));

    // Get prompt count for this step
    const stepInfo = await page.evaluate((stepNum) => {
      const step = window.PS101_STEPS?.find(s => s.step === stepNum);
      return step ? { prompts: step.prompts.length, title: step.title } : null;
    }, step);

    if (!stepInfo) {
      console.log(`❌ Could not find step ${step} info`);
      break;
    }

    console.log(`Step Info: ${stepInfo.prompts} prompts, "${stepInfo.title}"`);

    // Answer each prompt
    for (let promptIdx = 0; promptIdx < stepInfo.prompts; promptIdx++) {
      console.log(`\n  Prompt ${promptIdx + 1}/${stepInfo.prompts}`);

      // Check if experiment component
      const isExpComponent = await page.evaluate(({stepNum, promptIndex, totalPrompts}) => {
        return [6, 7, 8, 9].includes(stepNum) && promptIndex === totalPrompts - 1;
      }, {stepNum: step, promptIndex: promptIdx, totalPrompts: stepInfo.prompts});

      if (isExpComponent) {
        console.log(`    → Experiment component (Step ${step})`);

        if (step === 6) {
          // Fill experiment canvas
          await page.evaluate(() => {
            const hypothesis = document.getElementById('exp-hypothesis');
            const successMetric = document.getElementById('exp-success-metric');
            const startDate = document.getElementById('exp-start-date');

            if (hypothesis) hypothesis.value = 'Test hypothesis';
            if (successMetric) successMetric.value = 'Success metric';
            if (startDate) startDate.value = new Date().toISOString().split('T')[0];

            // Trigger change events
            [hypothesis, successMetric, startDate].forEach(el => {
              if (el) el.dispatchEvent(new Event('input', { bubbles: true }));
            });

            // Update PS101State
            const activeExp = window.PS101State?.getActiveExperiment();
            if (activeExp && window.PS101State) {
              window.PS101State.updateExperiment(activeExp.id, {
                hypothesis: hypothesis?.value,
                successMetric: successMetric?.value,
                duration: { start: startDate?.value }
              });
            }

            console.log('[DEBUG] Filled experiment canvas, activeExp:', activeExp);
          });

          await page.waitForTimeout(500);
        }
      } else {
        // Fill regular textarea
        await page.evaluate(() => {
          const textarea = document.getElementById('step-answer');
          if (textarea) {
            textarea.value = 'Test answer with enough characters to meet minimum requirements.';
            textarea.dispatchEvent(new Event('input', { bubbles: true }));
          }
        });
      }

      // Check if Next button is now enabled
      const btnState = await page.evaluate(() => {
        const btn = document.getElementById('ps101-next');
        return {
          disabled: btn?.disabled,
          text: btn?.textContent?.trim()
        };
      });

      console.log(`    Button: "${btnState.text}", disabled: ${btnState.disabled}`);

      if (!btnState.disabled) {
        // Click Next
        console.log(`    → Clicking Next...`);

        const beforeClick = await page.evaluate(() => ({
          step: window.PS101State?.currentStep,
          prompt: window.PS101State?.currentPromptIndex
        }));

        await page.evaluate(() => {
          document.getElementById('ps101-next').click();
        });

        await page.waitForTimeout(1500);

        const afterClick = await page.evaluate(() => ({
          step: window.PS101State?.currentStep,
          prompt: window.PS101State?.currentPromptIndex
        }));

        console.log(`    State changed: ${beforeClick.step}:${beforeClick.prompt} → ${afterClick.step}:${afterClick.prompt}`);

        if (beforeClick.step === afterClick.step && beforeClick.prompt === afterClick.prompt) {
          console.log(`    ⚠️  STATE DID NOT CHANGE - Navigation stuck!`);

          // Debug why
          const debugInfo = await page.evaluate(() => {
            const step = window.PS101_STEPS?.find(s => s.step === window.PS101State?.currentStep);
            const totalPrompts = step?.prompts?.length || 0;
            const currentPromptIndex = window.PS101State?.currentPromptIndex || 0;

            return {
              currentStep: window.PS101State?.currentStep,
              currentPromptIndex,
              totalPrompts,
              shouldAdvanceStep: currentPromptIndex + 1 >= totalPrompts,
              stepObject: step ? { step: step.step, title: step.title, prompts: totalPrompts } : null
            };
          });

          console.log(`    Debug Info:`, JSON.stringify(debugInfo, null, 2));
          break; // Stop at first navigation failure
        }
      } else {
        console.log(`    ⏸ Button disabled, cannot proceed`);
        break;
      }
    }

    // Check final state after step
    const finalState = await page.evaluate(() => ({
      step: window.PS101State?.currentStep,
      prompt: window.PS101State?.currentPromptIndex,
      label: document.getElementById('step-label')?.textContent
    }));

    console.log(`\nAfter Step ${step}: State = ${finalState.step}:${finalState.prompt}, Label = "${finalState.label}"`);

    if (finalState.step !== step + 1 && step < 6) {
      console.log(`❌ Expected to advance to step ${step + 1}, but still at step ${finalState.step}`);
      break;
    }
  }

  console.log('\n\nKeeping browser open for inspection...');
  await page.waitForTimeout(30000);

  await browser.close();
})();
