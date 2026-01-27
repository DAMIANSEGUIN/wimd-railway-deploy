# DNS Configuration for whatismydelta.com

## Current Setup

- **Domain:** whatismydelta.com
- **Current Provider:** Netlify
- **Current Target:** resonant-crostata-90b706.netlify.app
- **New Target:** Render deployment

## Render Domain Setup (CORRECT METHOD)

### Step 1: Add Custom Domain in Render

1. Go to Render dashboard → **"Settings"** → **"Domains"**
2. Add **<www.whatismydelta.com>**
3. Add **whatismydelta.com** (bare domain)
4. Render will show a **verification TXT record**

### Step 2: Create Verification Record in Netlify

1. Log into Netlify DNS panel
2. Add the **TXT record** Render shows (name/value exactly)
3. This lets Render issue the SSL certificate

### Step 3: Point the Apex Domain

**Option A (Recommended):**

- Create **ANAME/ALIAS** record for `whatismydelta.com`
- Point to: `what-is-my-delta-site-production.up.render.app`

**Option B (Alternative):**

- Keep apex on Netlify
- Add redirect rule: `whatismydelta.com` → `www.whatismydelta.com`

### Step 4: Wait for Render Verification

- Render will show domain as **"Ready"** (green)
- If stuck in "Pending", check TXT record spelling

### Step 5: Verify Propagation

```bash
dig +short www.whatismydelta.com
curl https://www.whatismydelta.com/health
```

## Test Commands

```bash
# Test domain
curl https://whatismydelta.com/health

# Test Render URL (backup)
curl https://what-is-my-delta-site-production.up.render.app/health
```

## Render Configuration

- **Service:** what-is-my-delta-site
- **Project:** wimd-career-coaching
- **Environment:** production
- **Custom Domain:** whatismydelta.com
- **Render Target:** igv415qp.up.render.app

## Last Updated

2025-09-25 - DNS configuration for Render deployment
