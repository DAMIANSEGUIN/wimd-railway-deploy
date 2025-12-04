# User Experience Map & Architectural Analysis

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                VISUAL USER FLOW MAP                               │
└─────────────────────────────────────────────────────────────────────────────────┘

[ Phase 1: Onboarding ]
  • User lands on website
  • Interacts with `index.html`
  • Clicks "Start PS101"
       │
       ▼
[ Phase 2: PS101 Core Questionnaire ]
  • User answers prompts in the UI
  • All progress is saved ONLY to Local Storage
  • `PS101State` object manages flow
  • User navigates through all steps
       │
       ▼
[ Phase 3: "Completion" ]
  • `renderCompletionScreen()` is called
  • User sees a summary screen
  • User can download a local JSON file
       │
       │
  //== GAP ======================================================================\
  \== GAP ======================================================================//
       │
       │
       ▼
[ (Not Implemented) Phase 4: WIMD Analysis ]
  • PS101 data should be sent to `/wimd/analysis` API endpoint
  • Backend should process data & generate metrics
  • Results should be displayed on a dashboard

       │
       ▼
[ (Not Implemented) Phase 5: Opportunity Bridge & Resume Rewrite ]
  • User should be able to explore opportunities based on their analysis
  • User should be able to use the Resume Rewrite tool

```

This document maps the user's journey through the Mosaic platform, connecting each step to its underlying technical components. It is intended to clarify the current architecture and identify potential gaps.

---

## Phase 1: Onboarding & Initial Interaction

This phase covers the user's first contact with the platform and their initial choices.

### 1.1. User Lands on the Website

*   **User Action:** Navigates to `whatismydelta.com`.
*   **UI Component:** The main landing page (`index.html`).
*   **Key Functions (Frontend):
    *   `initApp()`: The main initialization function that sets up all event listeners and initial states.
    *   `renderWelcomeScreen()`: Renders the initial PS101 welcome/choice screen.
*   **API Endpoint:** None at this stage.
*   **Key Files:** `frontend/index.html`, `mosaic_ui/index.html`.
*   **Architectural Notes/Gaps:**
    *   **Redundancy:** There are two primary `index.html` files (`frontend/` and `mosaic_ui/`). The code within them is very similar but not identical. This creates a maintenance overhead and risk of inconsistent user experiences.
    *   **Monolithic Frontend:** All UI logic, including the PS101 flow, authentication, and other components, is contained within a single large HTML file. This makes it difficult to maintain and debug.

### 1.2. User Starts the PS101 Flow

*   **User Action:** Clicks "Start PS101" or a similar button.
*   **UI Component:** The PS101 welcome screen buttons (`#start-ps101`, `#continue-ps101`).
*   **Key Functions (Frontend):
    *   `initPS101EventListeners()`: Sets up the click handlers for the PS101 buttons.
    *   `PS101State.init()`: Initializes the state of the PS101 module from `localStorage`.
    *   `renderCurrentStep()`: Renders the first (or current) step of the PS101 questionnaire.
*   **API Endpoint:** None at this stage.
*   **Key Files:** `frontend/index.html`, `mosaic_ui/index.html`.
*   **Architectural Notes/Gaps:**
    *   **State Management:** The `PS101State` object is a global object that manages its own state via `localStorage`. While functional, this is not a robust state management solution and can be prone to errors. A dedicated state management library or a more structured approach would be beneficial.
    *   **Tight Coupling:** The PS101 logic is tightly coupled to the DOM, with many `document.getElementById` calls. This makes the code brittle and hard to test.

---

## Phase 2: PS101 - The Core Questionnaire

This is the interactive part of the journey where the user answers questions.

### 2.1. User Answers a Prompt

*   **User Action:** Types an answer into the textarea.
*   **UI Component:** The main PS101 textarea (`#step-answer`).
*   **Key Functions (Frontend):
    *   `handleStepAnswerInput(event)`: The primary event handler for the textarea's `input` event.
    *   `updateCharCount()`: Updates the character count display.
    *   `PS101State.setAnswer()`: Saves the user's answer to the `PS101State` object and `localStorage`.
    *   `updateNavButtons()`: Enables/disables the "Next" button based on validation rules.
*   **API Endpoint:** None. All state is currently managed on the client-side.
*   **Key Files:** `frontend/index.html`, `mosaic_ui/index.html`.
*   **Architectural Notes/Gaps:**
    *   **Client-Side Validation:** All validation logic is on the client side in the `validateCurrentStep` function. This is acceptable for a simple questionnaire, but more complex validation would be better handled on the server.
    *   **No Backend Sync:** User progress is only saved in `localStorage`. If the user clears their cache or switches devices, their progress is lost. The architecture document mentions API endpoints like `/wimd/metrics`, but these do not seem to be integrated into the current PS101 flow. **This is a significant architectural gap.**

### 2.2. User Navigates Through Steps

*   **User Action:** Clicks the "Next" or "Back" buttons.
*   **UI Component:** The navigation buttons (`#ps101-next`, `#ps101-back`).
*   **Key Functions (Frontend):
    *   Event listeners within `initPS101EventListeners()` trigger `PS101State.nextPrompt()` or `PS101State.prevPrompt()`.
    *   `renderCurrentStep()`: Re-renders the UI for the new step/prompt.
*   **API Endpoint:** None.
*   **Key Files:** `frontend/index.html`, `mosaic_ui/index.html`.
*   **Architectural Notes/Gaps:**
    *   The navigation logic is entirely self-contained within the `PS101State` object, which is good for modularity, but again highlights the lack of backend integration.

---

## Phase 3: Post-PS101 & Next Steps

This phase is currently not fully implemented, representing a major gap between the current application and the vision in `MOSAIC_ARCHITECTURE.md`.

### 3.1. User Completes the PS101 Flow

*   **User Action:** Clicks the "Complete PS101" button on the final step.
*   **UI Component:** The final "Next" button, which should read "Complete PS101".
*   **Key Functions (Frontend):** `renderCompletionScreen()`.
*   **API Endpoint (Hypothetical):** The user's collected answers should be sent to a `/wimd` or `/wimd/analysis` endpoint.
*   **Key Files:** `frontend/index.html`, `mosaic_ui/index.html`.
*   **Architectural Notes/Gaps:**
    *   **Major Gap:** The `MOSAIC_ARCHITECTURE.md` document describes a "WIMD Analysis" phase where data is processed by the backend to generate metrics and a dashboard. **This is not implemented.** The current flow ends with a simple completion screen and a "Download Summary" button.
    *   **No Data Handoff:** There is no handoff of the user's data to the.