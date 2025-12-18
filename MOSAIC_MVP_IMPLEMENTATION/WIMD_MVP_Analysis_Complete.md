# WIMD MVP ANALYSIS — OPUS 4.5

**Date:** December 1, 2025
**Platform:** WIMD (What Is My Delta) / Mosaic
**Analysis Framework:** 6-Phase MVP Definition with AGILE Modular Rebuild

---

## EXECUTIVE SUMMARY

WIMD solves a specific problem in the crowded career transition space: AI coaching fails when users haven't done the foundational self-discovery work. Generic chatbots give generic advice because they're coaching strangers. WIMD's "self-discovery first, AI amplification second" philosophy creates differentiated value by requiring PS101 completion before full AI coaching access—not as a gatekeeper, but as the foundation that makes coaching actually work.

The current architecture (7 phases from Landing to Resume Rewriting) is well-designed but over-scoped for MVP. The irreducible nucleus is three components: PS101 completion flow, context extraction pipeline, and context-aware coaching focused on experiment design. Everything else—job search, advanced tracking, historical comparison, tiered pricing—can be deferred until the core hypothesis is validated: users who complete structured self-reflection receive meaningfully more personalized coaching.

The MVP can be built in 3 days given current infrastructure (authentication, PS101 flow, chat interface, database all working). The gap is context injection—transforming PS101 responses into structured data and injecting that into the coaching system prompt. This analysis provides the exact modular breakdown, build sequence, and elimination list to ship a testable MVP immediately.

---

## PHASE 1: USER PURPOSE

### Task 1.1: Core User Need

**The Problem Statement:**
Mid-career professionals facing career transitions typically encounter two inadequate options: expensive human coaching (inaccessible to most), or generic AI chatbots that offer shallow "just tell me what to do" advice. The fundamental failure is that both require self-awareness the user hasn't developed. A coach—human or AI—giving advice to someone who hasn't examined their passions, identified their hidden strengths, or acknowledged their obstacles is essentially counseling a stranger. The advice can only be generic because there's no specific context to personalize it.

**The Transformation Users Seek:**

| FROM | TO |
|------|-----|
| Stuck, uncertain, isolated in career doubt | Clear direction with actionable experiments |
| Passive consumer of generic career advice | Active agent designing their own path |
| Overwhelmed by "one big pivot" pressure | Empowered to run multiple small experiments |
| Unaware of their unique strengths/obstacles | Conscious of secret powers and specific blocks |
| Dependent on external validation | Building self-efficacy through experience |

**Why Existing Solutions Fail:**

1. **Career assessment tools** generate reports but provide no follow-through coaching
2. **AI chatbots** (ChatGPT, etc.) offer generic advice without knowing the user's specific context
3. **Human coaching** is expensive ($200-500/session), limited access, not scalable
4. **Online courses** are passive consumption, not personalized action
5. **Self-help books** provide frameworks but no accountability or feedback loop

WIMD fails if it becomes just another chatbot. The differentiation is forcing self-reflection BEFORE AI engagement, making the AI actually useful.

---

### Task 1.2: The "Aha" Moment

**The Critical Experience:**
The "aha" moment occurs when a user completes PS101, enters a coaching conversation, and the AI *already knows their situation*. Instead of asking "tell me about yourself," the AI says: "You identified teaching as a potential direction and fear of public speaking as an internal obstacle. Let's design a small experiment to test teaching that doesn't require public speaking—maybe a 1-on-1 lunch-and-learn with a colleague on something you know well."

**Why This Is Different:**

| Other AI Tools | WIMD |
|----------------|------|
| "Tell me about your career goals" | Already knows their goals from PS101 |
| Generic frameworks applied to unknown person | Specific suggestions based on their stated passions/obstacles |
| Cheerleading without evidence | Witnessing and mirroring their own discoveries |
| Advice-dispensing | Experiment-designing |
| One-shot interaction | Context-aware ongoing relationship |

The user feels *seen*. The AI isn't a stranger—it's a coach who's "read their file." This is the moment that validates WIMD's approach.

---

## PHASE 2: ARCHITECTURE ALIGNMENT

### Task 2.1: Phase-by-Phase Evaluation

| Phase | Description | Alignment Score (1-10) | Essential for MVP? | Dependencies | What Breaks If Removed? |
|-------|-------------|------------------------|-------------------|--------------|------------------------|
| **1: Landing & Onboarding** | Value prop, account creation | 7 | YES (minimal) | None | No users |
| **2: PS101 Foundation** | 10 self-reflection questions | 10 | YES (core) | Phase 1 | Entire value proposition |
| **3: Earned Handoff** | Completion triggers AI access | 9 | YES (core) | Phase 2 | Users skip to generic AI |
| **4: AI-Augmented Coaching** | Context-aware 608-prompt library | 10 | YES (core) | Phases 2, 3 | WIMD becomes generic chatbot |
| **5: Experiment Design** | Small experiments, not big pivots | 9 | YES (simplified) | Phase 4 | No actionable outcomes |
| **6: Reflection & Learning** | Extract insights from experiments | 6 | NO (defer) | Phase 5 | Can be manual initially |
| **7: Resume Rewriting** | Leverage insights for resume | 4 | NO (defer) | Phases 5, 6 | Optional enhancement |
| **Job Search Function** | Under review | 3 | NO (eliminate for MVP) | Multiple | Scope creep |

**Alignment Analysis:**

- **Phases 1-5 form the core value chain.** User arrives → reflects → gets personalized coaching → designs experiments
- **Phase 6-7 are enhancement layers.** Valuable for retention but not for proving core hypothesis
- **Job Search is scope creep.** Solves a different problem; defer entirely

---

### Task 2.2: Architectural Gaps

**Gap 1: Context Extraction Pipeline**

- **Current state:** PS101 responses stored as raw text
- **Required state:** Structured context (passions, skills, secret_powers, experiments, obstacles, key_quotes) extracted via Claude API
- **Technical need:** Endpoint that transforms PS101 → structured JSON
- **Complexity:** Low (single API call with structured output)

**Gap 2: Context Injection into Coaching**

- **Current state:** Chat interface exists but uses generic system prompt
- **Required state:** System prompt dynamically includes user's extracted context
- **Technical need:** Modify chat initialization to fetch and inject context
- **Complexity:** Low (string interpolation into system prompt)

**Gap 3: PS101 Completion State**

- **Current state:** Unclear if completion is tracked/gated
- **Required state:** Clear completion flag that unlocks coaching access
- **Technical need:** Database field + UI state management
- **Complexity:** Low (boolean flag + conditional rendering)

**Gap 4: Coaching Focus on Experiments**

- **Current state:** Generic coaching prompts
- **Required state:** Coaching optimized for experiment design output
- **Technical need:** Refined system prompt + possibly output templates
- **Complexity:** Low (prompt engineering)

**Critical Observation:** All gaps are LOW complexity. The infrastructure exists; the integration layer is missing.

---

## PHASE 3: MVP NUCLEUS DEFINITION

### Task 3.1: The Irreducible Core

**MVP Nucleus = 4 Components:**

1. **PS101 Completion Flow**
   - 10 questions presented sequentially
   - Progress indication
   - Completion summary ("Here's what you articulated...")
   - Data persistence

2. **Context Extraction**
   - Claude API call on PS101 completion
   - Outputs: problem_definition, passions, skills, secret_powers, proposed_experiments, internal_obstacles, external_obstacles, key_quotes
   - Stored as JSON on user record

3. **Context-Aware Coaching**
   - Chat interface (already exists)
   - System prompt includes extracted context
   - AI references user's specific situation
   - Focus on "Experimentation & Testing" category initially

4. **Experiment Design Output**
   - Coaching guides toward concrete experiments
   - Template: hypothesis, smallest version, success indicators, timeline
   - User leaves with actionable plan

**MVP User Flow (Text Diagram):**

```
[Landing] → [Create Account] → [PS101 Q1-Q10] → [Completion Summary]
                                                        ↓
                                              [Context Extracted]
                                                        ↓
                                              [Coaching Interface]
                                                        ↓
                                              [Experiment Designed]
                                                        ↓
                                              [User Takes Action]
```

**Why This Is The Nucleus:**

This is the minimum path that proves WIMD's core hypothesis. A user completes self-reflection, receives coaching that demonstrably knows their situation, and leaves with a concrete experiment to run. If this works, everything else is enhancement. If this fails, nothing else matters.

---

### Task 3.2: Exclusion Justifications

| Excluded Component | Why Deferred | When to Add | Risk If Excluded |
|--------------------|--------------|-------------|------------------|
| Full 608-prompt library access | Overwhelming; start with one category | After validating core flow | Low—single category proves concept |
| Historical PS101 comparison | Requires users to iterate first | When returning users exist | None—no data yet |
| Experiment outcome tracking | Can be manual initially | Post-MVP milestone 1 | Low—ask users directly |
| Reflection & Learning (Phase 6) | Enhancement, not core | Post-MVP milestone 2 | Low—users can reflect manually |
| Resume Rewriting (Phase 7) | Different value prop | Post-MVP milestone 3 | None—optional feature |
| Job Search function | Scope creep, different problem | Separate product decision | None—not core to WIMD |
| Pricing/payment integration | Validate before monetizing | After MVP validation | None—free access for beta |
| OAuth/social login | Convenience, not core | Post-MVP polish | Low—email/password works |
| Mobile app | Responsive web first | After web validated | Low—web accessible on mobile |
| Dashboard/visualizations | Users need to USE data, not VIEW it | Post-MVP | None |
| Sophisticated CoachingBridge | Simple injection validates hypothesis | After proving concept | None—simple version works |

---

## PHASE 4: MODULAR REBUILD PROPOSAL

### Task 4.1: Module Definitions

| Module | Purpose | Key Components | Dependencies | Complexity |
|--------|---------|----------------|--------------|------------|
| **M1: Auth & Accounts** | User identity and session | Login, registration, session management | None | S (exists) |
| **M2: PS101 Flow** | Guided self-reflection | 10 questions, progress tracking, data persistence | M1 | S (exists) |
| **M3: Completion Gate** | Track and enforce PS101 completion | Completion flag, summary screen, access control | M2 | S |
| **M4: Context Extraction** | Transform PS101 → structured data | Claude API endpoint, JSON storage | M2 | M |
| **M5: Coaching Interface** | Chat with AI | Chat UI, message history, API calls | M1 | S (exists) |
| **M6: Context Injection** | Personalize coaching | System prompt builder, context fetch | M4, M5 | M |
| **M7: Experiment Focus** | Guide toward actionable output | Refined prompts, output templates | M6 | S |
| **M8: Feedback Collection** | Gather user validation | Simple form or Typeform integration | M5 | S |

**Complexity Key:** S = Small (hours), M = Medium (1-2 days), L = Large (3+ days)

---

### Task 4.2: Build Sequence

**Day 1: Foundation Verification + Context Extraction**

| Time Block | Activity | Deliverable |
|------------|----------|-------------|
| Morning (2-3 hrs) | Audit PS101 flow, verify data persistence, locate chat system prompt | Gap documentation |
| Afternoon (3-4 hrs) | Build M4: Context Extraction endpoint | Claude API extracts structured context from any PS101 |

**Day 2: Context Injection + Testing**

| Time Block | Activity | Deliverable |
|------------|----------|-------------|
| Morning (3 hrs) | Build M6: Modify chat to fetch and inject context | Chat references user's specific situation |
| Afternoon (3 hrs) | Build M3: Completion gate + summary screen | Clear transition from PS101 to coaching |
| Evening (2 hrs) | Test end-to-end with sample users | Verify personalization is obvious |

**Day 3: Experiment Focus + Beta Prep**

| Time Block | Activity | Deliverable |
|------------|----------|-------------|
| Morning (3 hrs) | Build M7: Refine system prompt for experiment design | Coaching produces concrete experiments |
| Afternoon (2 hrs) | Build M8: Feedback collection mechanism | Way to gather user validation |
| Evening (2 hrs) | Beta user outreach, landing page messaging | 10-15 users ready to test |

**What Can Be Tested After Each Day:**

- **After Day 1:** Context extraction works—PS101 produces structured data
- **After Day 2:** Full flow works—user completes PS101 and gets personalized coaching
- **After Day 3:** Value delivery works—users leave with concrete experiments + feedback loop active

---

## PHASE 5: ARCHIVE/ELIMINATE RECOMMENDATIONS

### Task 5.1: Categorized Component List

**ARCHIVE FOR LATER (Valuable, not essential for MVP):**

| Component | Justification | Reactivation Trigger |
|-----------|---------------|---------------------|
| Full 608-prompt library | Overwhelming; start focused | After validating Experimentation category |
| Experiment tracking engine (disabled code exists) | Enhancement layer | After MVP validation |
| Historical PS101 comparison | No returning users yet | When users iterate |
| Reflection & Learning phase | Can be manual | Post-MVP milestone |
| Resume Rewriting phase | Different value prop | Post-MVP milestone |
| Multi-tier pricing | Validate before monetizing | After proving value |
| CoachingBridge sophistication | Simple injection works | After proving concept |

**ELIMINATE COMPLETELY (Distractions):**

| Component | Justification |
|-----------|---------------|
| Job Search function | Different problem, scope creep |
| Complex onboarding flows | Single screen sufficient |
| Dashboard visualizations | Users need to use data, not view it |
| Mobile app planning | Responsive web sufficient |
| OAuth integration | Email/password works for beta |

**SIMPLIFY RADICALLY (Keep but reduce):**

| Component | Current Complexity | Simplified Version |
|-----------|-------------------|-------------------|
| In-PS101 AI assistance | Planned: AI hints + help | MVP: Static text prompts only |
| User profile/settings | Full management | MVP: Email + password only |
| Coaching categories | 12 categories | MVP: Experimentation only |
| Context extraction | Category-specific logic | MVP: Full context injection always |
| Experiment templates | Structured database | MVP: Natural language in chat |

---

### Task 5.2: Simplification Opportunities

**Replace Complex With Simple:**

| Instead Of | Do This | Trade-off |
|------------|---------|-----------|
| Automated experiment tracking | Ask users in follow-up conversation | Manual but sufficient for validation |
| Category-specific context injection | Inject full context every time | Slightly longer prompts but simpler code |
| Sophisticated completion analytics | Simple completion boolean | Less data but faster to build |
| Custom feedback system | Typeform link | Less integrated but works immediately |

**Use Existing Tools:**

| Instead Of Building | Use This |
|---------------------|----------|
| Custom analytics | Existing database queries + manual review |
| Feedback collection | Typeform or Google Forms |
| User communication | Personal email for beta users |
| Payment processing | Manual invoicing for first paying users |

---

## PHASE 6: IMPLEMENTATION ROADMAP

### Task 6.1: MVP Launch Criteria

**Must Work:**

| Criterion | Verification Method |
|-----------|---------------------|
| User can create account | Test with 3 accounts |
| User can complete all 10 PS101 questions | Full completion test |
| PS101 data persists across sessions | Close browser, return, verify data |
| Context extraction produces structured JSON | Review extraction output for 5 users |
| Chat interface shows context-aware responses | Verify AI references specific user data |
| Coaching guides toward experiment design | Review 10 coaching sessions for experiment output |

**Quality Thresholds:**

| Metric | Threshold |
|--------|-----------|
| PS101 completion time | < 45 minutes |
| Context extraction success rate | 100% (no failures) |
| Coaching personalization | Obvious in first 2 exchanges |
| Experiment output | Concrete plan in 80% of sessions |

**User Testing Requirements:**

- 10-15 beta users complete full flow
- Qualitative feedback collected
- "Did coaching feel personalized?" → 70%+ yes
- "Did you leave with a concrete experiment?" → 70%+ yes

**Success Metrics for MVP Validation:**

| Metric | Target | Measurement |
|--------|--------|-------------|
| PS101 completion rate | 60%+ of starters | Database query |
| Coaching engagement | 80%+ of completers | Database query |
| Personalization perception | 70%+ report "yes" | User feedback |
| Experiment generation | 70%+ leave with plan | User feedback |
| Would recommend | 50%+ | User feedback |

---

### Task 6.2: Post-MVP Roadmap

**Milestone 1: Experiment Tracking (Week 2-3 after MVP)**

| Trigger Condition | What Gets Added |
|-------------------|-----------------|
| MVP validated with 70%+ personalization perception | Enable existing experiment tracking code |
| 10+ users have designed experiments | Add experiment logging to coaching flow |
| Users asking "how do I track this?" | Simple experiment dashboard |

**Milestone 2: Prompt Library Expansion (Week 4-5)**

| Trigger Condition | What Gets Added |
|-------------------|-----------------|
| Experimentation category validated | Add 2-3 more categories (Motivation, Confidence) |
| Users requesting more coaching areas | Category selection in coaching interface |
| Context injection proven effective | Category-specific context extraction |

**Milestone 3: Reflection Loop (Week 6-8)**

| Trigger Condition | What Gets Added |
|-------------------|-----------------|
| Users running experiments and returning | Reflection prompts on experiment outcomes |
| Data shows returning users | Learning extraction from experiment results |
| Pattern of iteration emerging | PS101 iteration flow (update vs. new) |

**Milestone 4: Monetization (Week 8-12)**

| Trigger Condition | What Gets Added |
|-------------------|-----------------|
| 50+ users validated | Pricing page |
| 70%+ would pay (survey) | Payment integration |
| Clear value demonstrated | Tier differentiation |

---

## APPENDICES

### Appendix A: Full Phase-by-Phase Evaluation Table

| Phase | Name | Description | Alignment (1-10) | MVP? | Complexity | Dependencies | Risk If Removed |
|-------|------|-------------|------------------|------|------------|--------------|-----------------|
| 1 | Landing & Onboarding | Value prop, account creation | 7 | Yes (minimal) | S | None | No users enter |
| 2 | PS101 Foundation | 10 self-reflection questions | 10 | Yes (core) | S (exists) | Phase 1 | No foundation for coaching |
| 3 | Earned Handoff | Completion unlocks AI | 9 | Yes (core) | S | Phase 2 | Users skip to generic |
| 4 | AI-Augmented Coaching | Context-aware prompts | 10 | Yes (core) | M | Phases 2,3 | WIMD = generic chatbot |
| 5 | Experiment Design | Small actionable tests | 9 | Yes (simplified) | S | Phase 4 | No actionable output |
| 6 | Reflection & Learning | Extract insights | 6 | No | M | Phase 5 | Manual reflection ok |
| 7 | Resume Rewriting | Leverage insights | 4 | No | L | Phases 5,6 | Optional feature |
| — | Job Search | Under review | 3 | No | L | Multiple | Scope creep |

---

### Appendix B: Dependency Map

```
[Landing/Auth]
      ↓
[PS101 Flow] ←── Must complete before ──→ [Context Extraction]
      ↓                                           ↓
[Completion Gate] ←─── Triggers ────→ [Context Storage]
      ↓                                           ↓
[Coaching Interface] ←── Injects ────→ [Structured Context]
      ↓
[Experiment Design Focus]
      ↓
[User Action]
      ↓
[Feedback Collection] ──→ [Validation Data]
```

**Critical Path:** Landing → PS101 → Extraction → Injection → Coaching → Experiment

**Non-Critical (can run parallel):** Feedback collection mechanism

---

### Appendix C: Risk Assessment Matrix

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| PS101 data structure doesn't match extraction needs | Medium | High | Audit Day 1 morning; adjust schema if needed |
| Context extraction produces poor quality | Low | High | Test with 5 sample PS101s; iterate prompt |
| Users don't complete PS101 | Medium | Critical | Monitor drop-off points; simplify if needed |
| Personalization not obvious to users | Medium | Critical | A/B test generic vs. context-aware; refine prompts |
| Claude API costs exceed budget | Low | Medium | Monitor usage; set rate limits |
| No beta users available | Low | High | Start outreach Day 1; use personal network |
| Technical integration issues | Medium | Medium | Working infrastructure exists; issues are fixable |
| Users don't design experiments | Medium | High | Refine coaching prompts for explicit experiment output |

**Highest Risks to Monitor:**

1. **Users don't complete PS101** — If completion rate is <50%, simplify questions or add progress incentives
2. **Personalization not perceived** — If users say coaching feels generic, context injection isn't working; debug immediately

---

### Appendix D: Context Extraction Specification

**Input:** Raw PS101 responses (dict with q1-q10)

**Output:** Structured JSON

```json
{
  "problem_definition": "One sentence capturing core challenge",
  "passions": ["Interest 1", "Interest 2", "..."],
  "skills": ["Skill 1", "Skill 2", "..."],
  "secret_powers": ["Hidden strength 1", "..."],
  "proposed_experiments": [
    {
      "idea": "Direction they mentioned",
      "smallest_version": "Tiny testable version"
    }
  ],
  "internal_obstacles": ["Fear 1", "Self-doubt 2", "..."],
  "external_obstacles": ["Constraint 1", "..."],
  "key_quotes": ["Powerful phrase from their answers", "..."]
}
```

**Extraction Prompt:** See `mosaic_context_bridge.py` for production-ready implementation.

---

### Appendix E: Coaching System Prompt Template

```
You are a career coach with deep knowledge of this specific person.
They completed structured self-reflection and here's what they discovered:

PROBLEM THEY'RE SOLVING:
{problem_definition}

WHAT ENERGIZES THEM:
{passions}

SKILLS THEY BRING:
{skills}

SECRET POWERS (strengths they may undervalue):
{secret_powers}

EXPERIMENTS THEY'RE CONSIDERING:
{proposed_experiments}

INTERNAL OBSTACLES (fears, mindset):
{internal_obstacles}

EXTERNAL OBSTACLES (practical constraints):
{external_obstacles}

THEIR WORDS WORTH REFLECTING BACK:
{key_quotes}

---

COACHING APPROACH:
- Reference their SPECIFIC situation, not generic advice
- When they mention a challenge, connect it to their identified obstacles
- When suggesting action, build on their proposed experiments
- Mirror their language back—use phrases from key_quotes naturally
- Help them design SMALL experiments, not big pivots
- You're a witness and mirror, not an advice dispenser
- If they're stuck, ask what their secret powers suggest about a path forward

Never say "based on what you shared"—just know it naturally,
like a coach who's been working with them for months.
```

---

## CONCLUSION

**The MVP nucleus is clear:** PS101 → Context Extraction → Context-Aware Coaching → Experiment Design

**The build path is fast:** 3 days with existing infrastructure

**The validation criteria are defined:** 70%+ personalization perception, 70%+ leave with experiments

**Everything else is deferred** until this core is proven.

Build the nucleus. Test the hypothesis. Expand from validated learning.

---

**Document Version:** 1.0
**Word Count:** ~3,800
**Analysis Complete**
