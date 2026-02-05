// Debug Step 6 experiment validation specifically
const { chromium } = require('playwright');

(async () => {
  console.log('🔬 STEP 6 EXPERIMENT VALIDATION DEBUG\n');

  const browser = await chromium.launch({ headless: false, slowMo: 500 });
  const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });

  // Handle dialogs
  page.on('dialog', async dialog => {
    console.log(`[DIALOG] ${dialog.message()}`);
    await dialog.accept();
  });

  await page.goto('https://whatismydelta.com', { waitUntil: 'networkidle' });

  // Clear localStorage
  await page.evaluate(() => {
    localStorage.removeItem('ps101_state');
    localStorage.removeItem('ps101_v2_state');
  });
  await page.reload({ waitUntil: 'networkidle' });

  // Start PS101
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

  console.log('Jumping directly to Step 6...\n');

  // Jump to Step 6 directly
  await page.evaluate(() => {
    if (window.PS101State) {
      window.PS101State.currentStep = 6;
      window.PS101State.currentPromptIndex = 2; // Last prompt (index 2 of 3 prompts)
      window.PS101State.save();

      // Trigger render
      const renderFunc = window.renderCurrentStep;
      if (renderFunc) {
        renderFunc();
      }
    }
  });

  await page.waitForTimeout(2000);

  const state = await page.evaluate(() => {
    return {
      currentStep: window.PS101State?.currentStep,
      currentPromptIndex: window.PS101State?.currentPromptIndex,
      stepLabel: document.getElementById('step-label')?.textContent,
      experimentComponentsVisible: !document.getElementById('experiment-components')?.classList.contains('hidden'),
      experimentCanvasVisible: !document.getElementById('experiment-canvas')?.classList.contains('hidden'),
      activeExperiment: window.PS101State?.getActiveExperiment(),
      experimentsCount: window.PS101State?.experiments?.length || 0
    };
  });

  console.log('Current State:', JSON.stringify(state, null, 2));

  if (!state.activeExperiment) {
    console.log('\n⚠️  No active experiment - creating one...\n');

    await page.evaluate(() => {
      if (window.PS101State && !window.PS101State.getActiveExperiment()) {
        window.PS101State.createExperiment();
        console.log('Created experiment');
      }
    });

    await page.waitForTimeout(500);
  }

  console.log('\nFilling experiment canvas fields...\n');

  const fillResult = await page.evaluate(() => {
    const hypothesis = document.getElementById('exp-hypothesis');
    const successMetric = document.getElementById('exp-success-metric');
    const startDate = document.getElementById('exp-start-date');
    const reviewDate = document.getElementById('exp-review-date');

    const results = {
      hypothesis: { found: !!hypothesis },
      successMetric: { found: !!successMetric },
      startDate: { found: !!startDate },
      reviewDate: { found: !!reviewDate }
    };

    if (hypothesis) {
      hypothesis.value = 'Test daily check-ins to improve career clarity';
      hypothesis.dispatchEvent(new Event('input', { bubbles: true }));
      hypothesis.dispatchEvent(new Event('change', { bubbles: true }));
      results.hypothesis.value = hypothesis.value;
    }

    if (successMetric) {
      successMetric.value = 'Feel 50% more confident about career direction within 2 weeks';
      successMetric.dispatchEvent(new Event('input', { bubbles: true }));
      successMetric.dispatchEvent(new Event('change', { bubbles: true }));
      results.successMetric.value = successMetric.value;
    }

    if (startDate) {
      const today = new Date().toISOString().split('T')[0];
      startDate.value = today;
      startDate.dispatchEvent(new Event('input', { bubbles: true }));
      startDate.dispatchEvent(new Event('change', { bubbles: true }));
      results.startDate.value = startDate.value;
    }

    return results;
  });

  console.log('Fill Results:', JSON.stringify(fillResult, null, 2));

  console.log('\nUpdating PS101State experiment...\n');

  const updateResult = await page.evaluate(() => {
    const activeExp = window.PS101State?.getActiveExperiment();
    if (!activeExp) {
      return { error: 'No active experiment found' };
    }

    const hypothesis = document.getElementById('exp-hypothesis')?.value;
    const successMetric = document.getElementById('exp-success-metric')?.value;
    const startDate = document.getElementById('exp-start-date')?.value;

    const updated = window.PS101State.updateExperiment(activeExp.id, {
      hypothesis,
      successMetric,
      duration: { start: startDate, review: '' }
    });

    return {
      success: !!updated,
      experiment: updated
    };
  });

  console.log('Update Result:', JSON.stringify(updateResult, null, 2));

  console.log('\nChecking validation status...\n');

  const validationResult = await page.evaluate(() => {
    const activeExp = window.PS101State?.getActiveExperiment();
    const nextBtn = document.getElementById('ps101-next');

    // Check what the validation logic expects
    const isValid = activeExp &&
                    activeExp.hypothesis &&
                    activeExp.successMetric &&
                    (activeExp.duration?.start || activeExp.duration?.review);

    return {
      nextButtonDisabled: nextBtn?.disabled,
      nextButtonText: nextBtn?.textContent?.trim(),
      activeExperiment: activeExp,
      validationPassed: isValid,
      validationDetails: {
        hasHypothesis: !!activeExp?.hypothesis,
        hasSuccessMetric: !!activeExp?.successMetric,
        hasStartDate: !!activeExp?.duration?.start,
        hasReviewDate: !!activeExp?.duration?.review
      }
    };
  });

  console.log('Validation Result:', JSON.stringify(validationResult, null, 2));

  if (!validationResult.validationPassed) {
    console.log('\n❌ VALIDATION FAILED - Button should be disabled');
    console.log('Missing fields:', Object.entries(validationResult.validationDetails)
      .filter(([k, v]) => !v)
      .map(([k]) => k));
  } else {
    console.log('\n✅ VALIDATION PASSED - Button should be enabled');
  }

  console.log('\n\nKeeping browser open for inspection (30s)...');
  await page.waitForTimeout(30000);

  await browser.close();
})();
