#!/usr/bin/env node
/**
 * Toggle the PS101 trial override flag and optionally reset the timer.
 *
 * Usage:
 *   node scripts/reset_ps101_trial.mjs          # enable QA mode + reset trial (default)
 *   node scripts/reset_ps101_trial.mjs --off    # disable QA mode flag
 *   node scripts/reset_ps101_trial.mjs --no-reset
 *   node scripts/reset_ps101_trial.mjs --url https://staging.example.com
 */

import { chromium } from 'playwright';

const args = process.argv.slice(2);
const disable = args.includes('--off') || args.includes('--disable');
const noReset = args.includes('--no-reset');
const urlFlagIndex = args.findIndex(arg => arg === '--url');
const targetUrl = urlFlagIndex >= 0 && args[urlFlagIndex + 1]
  ? args[urlFlagIndex + 1]
  : process.env.PS101_URL || 'https://whatismydelta.com/';

const enable = !disable;
const resetTrial = !noReset;

const QA_FLAG = 'ps101_force_trial';
const TRIAL_KEY = 'delta_trial_start';

const log = msg => console.log(`[ps101-reset] ${msg}`);

async function run() {
  log(`Launching Chromium to update localStorage @ ${targetUrl}`);
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  try {
    await page.goto(targetUrl, { waitUntil: 'domcontentloaded' });

    await page.evaluate(({ enable, resetTrial, QA_FLAG, TRIAL_KEY }) => {
      if (resetTrial) {
        localStorage.removeItem(TRIAL_KEY);
      }
      if (enable) {
        localStorage.setItem(QA_FLAG, 'true');
      } else {
        localStorage.removeItem(QA_FLAG);
      }
    }, { enable, resetTrial, QA_FLAG, TRIAL_KEY });

    if (enable) {
      log('QA mode flag ENABLED (ps101_force_trial=true)');
    } else {
      log('QA mode flag DISABLED (ps101_force_trial removed)');
    }

    if (resetTrial) {
      log('Existing trial timestamp cleared.');
    } else {
      log('Trial timestamp left untouched (--no-reset).');
    }
  } finally {
    await browser.close();
    log('Chromium session closed.');
  }
}

run().catch(err => {
  console.error('[ps101-reset] Failed:', err);
  process.exitCode = 1;
});
