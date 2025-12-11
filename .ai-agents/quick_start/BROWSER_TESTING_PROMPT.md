# Browser Testing Prompt for CodexCapture
**Copy-paste prompt for opening Chrome with CodexCapture**

---

## Command

```bash
open -a "Google Chrome" https://whatismydelta.com
```

---

## Testing Checklist (Copy to CodexCapture)

**Test 1: Registration**
- Email: test+mosaic_[TIMESTAMP]@example.com
- Password: TestPass123!
- Expected: Successful registration → redirect to app

**Test 2: PS101 Flow (Complete all 10)**

Q1 - Problem: I'm stuck in a corporate job and want to transition to freelance consulting in AI/ML

Q2 - Passions: Building ML models, teaching others about AI, writing technical tutorials

Q3 - Skills: Python, PyTorch, data analysis, technical writing, presenting

Q4 - Secret Powers: Explaining complex concepts simply, spotting patterns in data, staying calm under pressure

Q5 - Experiments: Offer free ML consulting to 2 startups, publish 1 tutorial per week, give a conference talk

Q6 - Smallest: Reach out to 3 founders on LinkedIn offering free 30-min ML consulting calls

Q7 - Internal Obstacles: Imposter syndrome, fear of unstable income, worried I'm not expert enough

Q8 - External Obstacles: Need $5k/month to cover expenses, have 20 hours/week max for side projects, location-limited

Q9 - Key Quotes: I feel like I'm building someone else's dream instead of my own

Q10 - Commitment: Send 3 LinkedIn messages to founders offering free ML consulting

**After PS101:**
- Check console for: "Context extraction successful"
- If error: Report logs to Claude Code

**Test 3: Personalized Chat**
- Message: "What should I do next?"
- Expected: Response mentions ML/consulting, references obstacles, suggests experiments
- Should NOT say "PS101"

**Test 4: Completion Gate (New Account)**
- Register 2nd account: test+no_ps101_[TIMESTAMP]@example.com
- Try chat WITHOUT completing PS101
- Expected: "Please complete the PS101 questionnaire first..."

---

## DevTools Checks

**Console tab:**
- Look for: "Context extraction successful"
- No red errors

**Network tab:**
- POST /wimd/ask → Check headers for X-User-ID
- POST /api/ps101/extract-context → Should be 200 OK

**Application tab:**
- localStorage → Check for currentUser object with userId

