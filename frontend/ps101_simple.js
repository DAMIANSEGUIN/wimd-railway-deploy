// PS101 Simple Sequential Flow (8 Prompts)
// Replaces complex 10-step multi-prompt architecture

(function() {
  'use strict';

  // State Management
  const PS101State = {
    currentPromptIndex: 0,
    prompts: [],
    answers: [],
    startedAt: null,
    completed: false,

    async init() {
      // Load prompts from JSON
      try {
        const response = await fetch('./data/prompts.ps101.json');
        const data = await response.json();
        this.prompts = data.prompts;
        console.log('[PS101] Loaded', this.prompts.length, 'prompts');

        // Load saved state from localStorage
        const saved = localStorage.getItem('ps101_simple_state');
        if (saved) {
          const parsed = JSON.parse(saved);
          this.currentPromptIndex = Math.max(0, Math.min(parsed.currentPromptIndex || 0, this.prompts.length - 1));
          this.answers = parsed.answers || [];
          this.startedAt = parsed.startedAt;
          this.completed = parsed.completed || false;
        }

        if (!this.startedAt) {
          this.startedAt = new Date().toISOString();
        }

        // Ensure answers array is same length as prompts
        while (this.answers.length < this.prompts.length) {
          this.answers.push('');
        }
      } catch (error) {
        console.error('[PS101] Failed to load prompts:', error);
        // Fallback to hardcoded prompts
        this.prompts = [
          "What problem are you trying to solve, in one sentence?",
          "What would 'success' look like in 4–6 weeks? Be specific.",
          "What is the single biggest obstacle between you and that success?",
          "What's one action you can take in the next 48 hours?",
          "If you had to cut the plan to a third, what would you keep?",
          "Who can you ask for help, and what exactly will you ask?",
          "What data would convince you the plan is working?",
          "What's the smallest test that would move this forward?"
        ];
      }
    },

    save() {
      localStorage.setItem('ps101_simple_state', JSON.stringify({
        currentPromptIndex: this.currentPromptIndex,
        answers: this.answers,
        startedAt: this.startedAt,
        completed: this.completed
      }));
    },

    getAnswer(index) {
      return this.answers[index] || '';
    },

    setAnswer(index, answer) {
      this.answers[index] = answer;
      this.save();
    },

    nextPrompt() {
      if (this.currentPromptIndex < this.prompts.length - 1) {
        this.currentPromptIndex++;
        this.save();
        renderCurrentPrompt();
      } else {
        // Flow complete
        this.completed = true;
        this.save();
        renderCompletion();
      }
    },

    prevPrompt() {
      if (this.currentPromptIndex > 0) {
        this.currentPromptIndex--;
        this.save();
        renderCurrentPrompt();
      }
    },

    reset() {
      this.currentPromptIndex = 0;
      this.answers = new Array(this.prompts.length).fill('');
      this.startedAt = new Date().toISOString();
      this.completed = false;
      this.save();
      renderWelcome();
    }
  };

  // Render Functions
  function renderWelcome() {
    const welcome = document.getElementById('ps101-welcome');
    const flow = document.getElementById('ps101-flow');
    const completion = document.getElementById('ps101-completion');

    if (welcome) welcome.classList.remove('hidden');
    if (flow) flow.classList.add('hidden');
    if (completion) completion.classList.add('hidden');
  }

  function renderCurrentPrompt() {
    const welcome = document.getElementById('ps101-welcome');
    const flow = document.getElementById('ps101-flow');
    const completion = document.getElementById('ps101-completion');

    if (welcome) welcome.classList.add('hidden');
    if (flow) flow.classList.remove('hidden');
    if (completion) completion.classList.add('hidden');

    const index = PS101State.currentPromptIndex;
    const total = PS101State.prompts.length;
    const prompt = PS101State.prompts[index];

    // Update progress indicator
    const progressLabel = document.getElementById('step-label');
    if (progressLabel) {
      progressLabel.textContent = `Question ${index + 1} of ${total}`;
    }

    // Update progress dots
    const dots = document.querySelectorAll('.progress-dots .dot');
    dots.forEach((dot, i) => {
      dot.classList.remove('active', 'completed');
      if (i < index) {
        dot.classList.add('completed');
      } else if (i === index) {
        dot.classList.add('active');
      }
      dot.textContent = i + 1;
    });

    // Update question text
    const questionText = document.getElementById('question-text');
    if (questionText) {
      questionText.textContent = prompt;
    }

    // Update textarea
    const textarea = document.getElementById('step-answer');
    if (textarea) {
      textarea.value = PS101State.getAnswer(index);
      textarea.placeholder = `Type your response to: ${prompt}`;
    }

    // Update navigation buttons
    const backBtn = document.getElementById('ps101-back');
    const nextBtn = document.getElementById('ps101-next');

    if (backBtn) {
      backBtn.disabled = index === 0;
    }

    if (nextBtn) {
      const answer = PS101State.getAnswer(index);
      const isValid = answer.trim().length >= 10;
      nextBtn.disabled = !isValid;
      nextBtn.textContent = index === total - 1 ? 'Complete →' : 'Next →';
    }
  }

  function renderCompletion() {
    const welcome = document.getElementById('ps101-welcome');
    const flow = document.getElementById('ps101-flow');
    const completion = document.getElementById('ps101-completion');

    if (welcome) welcome.classList.add('hidden');
    if (flow) flow.classList.add('hidden');
    if (completion) completion.classList.remove('hidden');

    // Display all answers
    const answersContainer = document.getElementById('completion-answers');
    if (answersContainer) {
      answersContainer.innerHTML = '';
      PS101State.prompts.forEach((prompt, i) => {
        const answer = PS101State.getAnswer(i);
        const card = document.createElement('div');
        card.className = 'answer-card';
        card.innerHTML = `
          <div class="answer-header">
            <span class="answer-step">Question ${i + 1}: ${prompt}</span>
          </div>
          <div class="answer-content">${escapeHtml(answer)}</div>
        `;
        answersContainer.appendChild(card);
      });
    }
  }

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  // Event Listeners
  function initEventListeners() {
    const startBtn = document.getElementById('start-ps101');
    if (startBtn) {
      startBtn.addEventListener('click', () => {
        PS101State.currentPromptIndex = 0;
        PS101State.save();
        renderCurrentPrompt();
      });
    }

    const continueBtn = document.getElementById('continue-ps101');
    if (continueBtn) {
      continueBtn.addEventListener('click', () => {
        renderCurrentPrompt();
      });
    }

    const backBtn = document.getElementById('ps101-back');
    if (backBtn) {
      backBtn.addEventListener('click', () => {
        PS101State.prevPrompt();
      });
    }

    const nextBtn = document.getElementById('ps101-next');
    if (nextBtn) {
      nextBtn.addEventListener('click', () => {
        const textarea = document.getElementById('step-answer');
        if (textarea) {
          PS101State.setAnswer(PS101State.currentPromptIndex, textarea.value);
          PS101State.nextPrompt();
        }
      });
    }

    const textarea = document.getElementById('step-answer');
    if (textarea) {
      textarea.addEventListener('input', (e) => {
        PS101State.setAnswer(PS101State.currentPromptIndex, e.target.value);

        // Update next button state
        const nextBtn = document.getElementById('ps101-next');
        if (nextBtn) {
          const isValid = e.target.value.trim().length >= 10;
          nextBtn.disabled = !isValid;
        }
      });
    }
  }

  // Initialize
  async function initialize() {
    await PS101State.init();
    initEventListeners();

    // Decide what to show
    if (PS101State.completed) {
      renderCompletion();
    } else if (PS101State.answers.some(a => a.trim().length > 0)) {
      renderCurrentPrompt();
    } else {
      renderWelcome();
    }
  }

  // Export to global scope
  window.PS101State = PS101State;
  window.renderCurrentPrompt = renderCurrentPrompt;
  window.renderWelcome = renderWelcome;
  window.renderCompletion = renderCompletion;

  // Auto-initialize on DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initialize);
  } else {
    initialize();
  }

})();
