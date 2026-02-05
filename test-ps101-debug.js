// Quick diagnostic: What's actually visible on PS101 Step 1?
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false, slowMo: 500 });
  const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });

  await page.goto('https://whatismydelta.com', { waitUntil: 'networkidle' });

  // Clear localStorage
  await page.evaluate(() => {
    localStorage.removeItem('ps101_state');
    localStorage.removeItem('ps101_v2_state');
  });
  await page.reload({ waitUntil: 'networkidle' });

  console.log('\n🔍 DIAGNOSTIC: What elements are visible?\n');

  // Click start button
  const startBtn = await page.$('#linkFast');
  if (startBtn) {
    console.log('✅ Found #linkFast button');
    await startBtn.click();
    await page.waitForTimeout(2000);
  }

  // Check what's visible
  const state = await page.evaluate(() => {
    const textarea = document.getElementById('step-answer');
    const nextBtn = document.getElementById('ps101-next');
    const stepLabel = document.getElementById('step-label');
    const questionText = document.getElementById('question-text');

    return {
      textarea: {
        exists: !!textarea,
        visible: textarea ? getComputedStyle(textarea).display !== 'none' : false,
        value: textarea ? textarea.value : null
      },
      nextBtn: {
        exists: !!nextBtn,
        visible: nextBtn ? getComputedStyle(nextBtn).display !== 'none' : false,
        text: nextBtn ? nextBtn.textContent : null,
        disabled: nextBtn ? nextBtn.disabled : null
      },
      stepLabel: stepLabel ? stepLabel.textContent : null,
      questionText: questionText ? questionText.textContent.substring(0, 100) : null,
      ps101State: window.PS101State ? {
        currentStep: window.PS101State.currentStep,
        currentPromptIndex: window.PS101State.currentPromptIndex,
        totalSteps: window.PS101_STEPS ? window.PS101_STEPS.length : 0
      } : null
    };
  });

  console.log('Current State:', JSON.stringify(state, null, 2));

  // Try to fill textarea if visible
  if (state.textarea.visible) {
    console.log('\n✅ Textarea is visible, filling it...');
    const textarea = await page.$('#step-answer');
    await textarea.fill('Test answer with enough characters to meet minimum requirements.');
    await page.waitForTimeout(1000);

    const nextBtn = await page.$('#ps101-next');
    if (nextBtn) {
      const isEnabled = await nextBtn.isEnabled();
      console.log(`Next button enabled: ${isEnabled}`);
      if (isEnabled) {
        await nextBtn.click();
        console.log('Clicked next button');
        await page.waitForTimeout(2000);
      }
    }
  } else {
    console.log('\n❌ Textarea is NOT visible');
    console.log('Taking screenshot for debugging...');
    await page.screenshot({ path: '/tmp/ps101-debug.png', fullPage: true });
    console.log('Saved: /tmp/ps101-debug.png');
  }

  // Check state after clicking
  const stateAfter = await page.evaluate(() => {
    return window.PS101State ? {
      currentStep: window.PS101State.currentStep,
      currentPromptIndex: window.PS101State.currentPromptIndex
    } : null;
  });

  console.log('\nState after action:', JSON.stringify(stateAfter, null, 2));

  console.log('\nKeeping browser open for 30 seconds for manual inspection...');
  await page.waitForTimeout(30000);

  await browser.close();
})();
