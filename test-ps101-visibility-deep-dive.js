// Deep dive: Why can't Playwright see the textarea?
const { chromium } = require('playwright');

(async () => {
  console.log('🔬 DEEP VISIBILITY DIAGNOSTIC\n');

  const browser = await chromium.launch({ headless: false, slowMo: 500 });
  const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });

  await page.goto('https://whatismydelta.com', { waitUntil: 'networkidle' });

  // Clear localStorage
  await page.evaluate(() => {
    localStorage.removeItem('ps101_state');
    localStorage.removeItem('ps101_v2_state');
  });
  await page.reload({ waitUntil: 'networkidle' });

  // Click start button
  const startBtn = await page.$('#linkFast');
  if (startBtn) {
    await startBtn.click();
    await page.waitForTimeout(2000);
  }

  console.log('📊 COMPREHENSIVE VISIBILITY CHECK:\n');

  // Check ALL visibility factors
  const visibilityReport = await page.evaluate(() => {
    const textarea = document.getElementById('step-answer');
    if (!textarea) return { error: 'Textarea not found' };

    const computed = getComputedStyle(textarea);
    const rect = textarea.getBoundingClientRect();

    // Check all parent elements
    let parent = textarea.parentElement;
    const parentChain = [];
    while (parent) {
      const pComputed = getComputedStyle(parent);
      parentChain.push({
        tag: parent.tagName,
        id: parent.id || '(no id)',
        class: parent.className || '(no class)',
        display: pComputed.display,
        visibility: pComputed.visibility,
        opacity: pComputed.opacity,
        zIndex: pComputed.zIndex
      });
      parent = parent.parentElement;
      if (parentChain.length > 10) break; // Safety limit
    }

    return {
      textarea: {
        id: textarea.id,
        tagName: textarea.tagName,
        value: textarea.value,
        disabled: textarea.disabled,
        readOnly: textarea.readOnly,
        tabIndex: textarea.tabIndex
      },
      computedStyle: {
        display: computed.display,
        visibility: computed.visibility,
        opacity: computed.opacity,
        zIndex: computed.zIndex,
        position: computed.position,
        width: computed.width,
        height: computed.height,
        overflow: computed.overflow
      },
      boundingRect: {
        top: rect.top,
        left: rect.left,
        width: rect.width,
        height: rect.height,
        bottom: rect.bottom,
        right: rect.right
      },
      viewport: {
        width: window.innerWidth,
        height: window.innerHeight
      },
      isInViewport: (
        rect.top >= 0 &&
        rect.left >= 0 &&
        rect.bottom <= window.innerHeight &&
        rect.right <= window.innerWidth
      ),
      parentChain: parentChain
    };
  });

  console.log('Textarea Properties:');
  console.log(JSON.stringify(visibilityReport.textarea, null, 2));
  console.log('\nComputed Style:');
  console.log(JSON.stringify(visibilityReport.computedStyle, null, 2));
  console.log('\nBounding Rect:');
  console.log(JSON.stringify(visibilityReport.boundingRect, null, 2));
  console.log('\nViewport:');
  console.log(JSON.stringify(visibilityReport.viewport, null, 2));
  console.log('\nIs in viewport:', visibilityReport.isInViewport);
  console.log('\nParent Chain (first 5):');
  visibilityReport.parentChain.slice(0, 5).forEach((p, i) => {
    console.log(`  ${i}. <${p.tag}> id="${p.id}" class="${p.class}"`);
    console.log(`     display: ${p.display}, visibility: ${p.visibility}, opacity: ${p.opacity}, z-index: ${p.zIndex}`);
  });

  // Try different Playwright selectors and methods
  console.log('\n🎯 PLAYWRIGHT SELECTOR TESTS:\n');

  const tests = [
    { name: 'getElementById via evaluate', method: async () => {
      return await page.evaluate(() => {
        const el = document.getElementById('step-answer');
        return el ? 'Found' : 'Not found';
      });
    }},
    { name: 'page.$()', method: async () => {
      const el = await page.$('#step-answer');
      return el ? 'Found' : 'Not found';
    }},
    { name: 'page.locator()', method: async () => {
      const el = page.locator('#step-answer');
      const count = await el.count();
      return count > 0 ? 'Found' : 'Not found';
    }},
    { name: 'isVisible() via $', method: async () => {
      const el = await page.$('#step-answer');
      if (!el) return 'Element not found';
      try {
        const visible = await el.isVisible();
        return visible ? 'Visible' : 'Not visible';
      } catch (e) {
        return `Error: ${e.message}`;
      }
    }},
    { name: 'isVisible() via locator', method: async () => {
      const el = page.locator('#step-answer');
      try {
        const visible = await el.isVisible({ timeout: 1000 });
        return visible ? 'Visible' : 'Not visible';
      } catch (e) {
        return `Error: ${e.message}`;
      }
    }},
    { name: 'waitForSelector visible', method: async () => {
      try {
        await page.waitForSelector('#step-answer', { state: 'visible', timeout: 2000 });
        return 'Visible';
      } catch (e) {
        return `Not visible: ${e.message}`;
      }
    }}
  ];

  for (const test of tests) {
    try {
      const result = await test.method();
      console.log(`  ${test.name}: ${result}`);
    } catch (e) {
      console.log(`  ${test.name}: Error - ${e.message}`);
    }
  }

  // Try to interact using different methods
  console.log('\n🔧 INTERACTION TESTS:\n');

  // Method 1: Direct fill via evaluate
  console.log('  → Trying direct JavaScript fill...');
  const jsResult = await page.evaluate(() => {
    const textarea = document.getElementById('step-answer');
    if (textarea) {
      textarea.value = 'Test value via JavaScript';
      textarea.dispatchEvent(new Event('input', { bubbles: true }));
      textarea.dispatchEvent(new Event('change', { bubbles: true }));
      return 'Success: ' + textarea.value;
    }
    return 'Failed: textarea not found';
  });
  console.log(`     ${jsResult}`);

  // Method 2: Scroll into view + click + type
  console.log('  → Trying scroll + click + type...');
  try {
    await page.evaluate(() => {
      document.getElementById('step-answer').scrollIntoView({ behavior: 'smooth', block: 'center' });
    });
    await page.waitForTimeout(500);

    const textarea = await page.$('#step-answer');
    await textarea.click({ force: true });
    await page.waitForTimeout(200);
    await textarea.type('Test via click+type', { delay: 50 });
    console.log('     Success');
  } catch (e) {
    console.log(`     Failed: ${e.message}`);
  }

  // Method 3: Focus + type
  console.log('  → Trying focus + keyboard type...');
  try {
    await page.evaluate(() => document.getElementById('step-answer').focus());
    await page.keyboard.type('Test via keyboard', { delay: 50 });
    console.log('     Success');
  } catch (e) {
    console.log(`     Failed: ${e.message}`);
  }

  // Check final value
  const finalValue = await page.evaluate(() => {
    return document.getElementById('step-answer').value;
  });
  console.log(`\n✅ Final textarea value: "${finalValue}"`);

  // Take screenshot
  await page.screenshot({ path: '/tmp/ps101-visibility-debug.png', fullPage: true });
  console.log('\n📸 Screenshot saved: /tmp/ps101-visibility-debug.png');

  console.log('\nKeeping browser open for 20 seconds...');
  await page.waitForTimeout(20000);

  await browser.close();
})();
