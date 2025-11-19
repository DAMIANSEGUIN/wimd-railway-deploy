#!/usr/bin/env node
import { chromium } from 'playwright';

const targetUrl = process.env.PS101_URL || 'https://whatismydelta.com/';
const QA_FLAG = 'ps101_force_trial';

const log = msg => console.log(`[ps101-verify] ${msg}`);

async function run() {
  log(`Launching Chromium to set and verify localStorage @ ${targetUrl}`);
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  try {
    await page.goto(targetUrl, { waitUntil: 'domcontentloaded' });

    log(`Setting '${QA_FLAG}' to 'true'...`);
    await page.evaluate((QA_FLAG) => {
      localStorage.setItem(QA_FLAG, 'true');
    }, QA_FLAG);

    log('Reloading the page to check for persistence...');
    await page.reload({ waitUntil: 'domcontentloaded' });

    log(`Reading value of '${QA_FLAG}' after reload...`);
    const qaFlagValue = await page.evaluate((QA_FLAG) => {
      return localStorage.getItem(QA_FLAG);
    }, QA_FLAG);

    log(`Value of '${QA_FLAG}': ${qaFlagValue}`);

    if (qaFlagValue === 'true') {
      log('✅ Verification successful: QA mode flag persisted across reload.');
    } else {
      log('❌ Verification failed: QA mode flag did not persist across reload.');
      process.exitCode = 1;
    }

  } finally {
    await browser.close();
    log('Chromium session closed.');
  }
}

run().catch(err => {
  console.error('[ps101-verify] Failed:', err);
  process.exitCode = 1;
});
