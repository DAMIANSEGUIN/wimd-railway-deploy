# Gemini Agent: MCP Context Engineering Responses

This document contains my responses to the prompts from `docs/MCP_CONTEXT_ENGINEERING_PROMPTS.md` that are relevant to my workflow as the Gemini API Mode Agent.

---

### **Prompt #1: State Persistence Analysis**

**Purpose:** To classify information I interact with and determine how it should be managed.

**Agent Description:**

- **Identity:** Gemini API Mode Agent
- **Inputs:** I receive prompts and context via a broker shell script (`agent_send.sh`). This includes user instructions and piped file content.
- **Outputs:** I return text, which is typically a plan, analysis, or a shell command to be executed.
- **Lifecycle:** My lifecycle is transactional and stateless. I am invoked for a single turn and have no memory beyond the context provided in that turn's prompt.

**State Analysis Table:**

| Information Item | Proposed Category | Risk if Missing Later | Risk if Always Present | Notes / Solution |
| :--- | :--- | :--- | :--- | :--- |
| Core Governance Docs | **Durable** | **Catastrophic.** I would lose my core instructions, constraints, and protocols, making my actions unpredictable and unsafe. | Low risk, but high cost. Including full text in every prompt is inefficient. | **Solution:** MCP should store these as versioned, canonical documents. My context should only include a version hash, and I should retrieve the full text via a trigger if the hash changes. |
| Conversation History (Last N turns) | **Decision-Relevant** | I would lose short-term context, ask repetitive questions, and fail to follow multi-step instructions. | Can clutter the context window with irrelevant details from past turns, reducing focus. | **Solution:** MCP should manage this, providing a concise summary of the last 3-5 turns. I should be able to retrieve the full transcript for a specific turn via a trigger. |
| API Keys / Secrets | **Durable (Secure)** | I cannot access external tools or services required for my tasks. | **High security risk.** Should never be present in prompt context or logs. | **Solution:** MCP should not store these. A dedicated secrets manager should handle them. My broker scripts should load them into the runtime environment, and I should use them via `process.env` or equivalent, not direct injection. |
| Full content of a large file | **Decision-Relevant** | I cannot perform specific analysis or modifications (e.g., refactoring) on that file. | Wastes significant context space if I only need to check one field or line. | **Solution:** My context should default to including only file paths. I should use a `read_file` tool or an MCP retrieval trigger to get full content or specific snippets on demand. |

---

### **Prompt #3: Retrieval Trigger Design**

**Purpose:** To define the specific events that should cause me to fetch additional context from an external source like MCP.

**COMPLETED:** Task 1C - Retrieval Trigger Detection (2025-12-09)
File: `.ai-agents/session_context/trigger_detector.py`

**Retrieval Trigger Table:**

| Trigger Scenario | Signal (keywords/state/tool) | Retrieval Mechanism (Proposed) | Context Source | Owner |
| :--- | :--- | :--- | :--- | :--- |
| A command fails unexpectedly. | **Tool Output:** `command not found`, `exit code 1`, `permission denied`, `stderr` not empty. | `mcp_get_troubleshooting("command_failed", last_command, stderr)` | `TROUBLESHOOTING_CHECKLIST.md` (via MCP) | Gemini |
| User asks about another agent's work. | **Keywords:** "Claude said", "Codex created", "the other agent did..." | `mcp_get_agent_handoff(agent_name="Claude", last_n=1)` | MCP Agent Coordination Log | Gemini |
| I need to remember a specific detail from earlier in the conversation. | **Internal Thought:** "I need to confirm the port number we discussed." | `mcp_get_conversation_summary(query="port number decision")` | MCP Conversation History | Gemini |
| Starting a complex, broad task. | **Keywords:** "refactor the auth logic", "implement the new feature", "analyze the database schema" | `mcp_get_architectural_overview("auth")` | Relevant governance and architecture docs (via MCP) | Gemini |
| A file path is referenced that I haven't seen. | **Pattern Match:** A string in the prompt matches a file path format but is not in my file listing. | `mcp_get_file_content("path/to/file.py")` | Filesystem / MCP Cache | Gemini |

---

### **Prompt #2: View Compilation Design**

**Purpose:** To define what information must be in my context for different types of tasks.

**My Main Step Types:**

1. **PLANNING:** Analyzing a user request to form a multi-step plan.
2. **EXECUTION:** Issuing a single, specific shell command.
3. **ANALYSIS:** Reading command output or file content to decide the next step.
4. **SYNTHESIS:** Generating a final answer, creating code, or writing a commit message.

**Context View Matrix:**

| Step Type | MUST Include | SHOULD Include | Reference Only (by ID/Path) | Exclude Rationale | Owner |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **PLANNING** | User's immediate prompt, conversation summary. | Core governance rules summary. | Full governance docs, full file contents. | Full, verbose text wastes context on high-level planning. | Gemini |
| **EXECUTION**| The exact command from the plan to execute. | Relevant file paths, environment variables. | The full plan, conversation history. | The context for execution should be minimal to avoid ambiguity. | Gemini |
| **ANALYSIS** | The full `stdout` and `stderr` from the last command. | The original goal from the user prompt. | Troubleshooting docs, other file contents. | Irrelevant data can interfere with correctly interpreting the command output. | Gemini |
| **SYNTHESIS**| The result of my analysis and the user's original goal. | The conversation summary. | The full `stdout`/`stderr` that was already analyzed. | Redundant data that has already been processed into a conclusion. | Gemini |

---

### **Prompt #6: External Memory Architecture**

**Purpose:** To decide the appropriate storage mechanism for different types of content.

**Storage Architecture Table:**

| Content Type | In-Context Summary? | External Storage Plan | Retrieval Method | Owner |
| :--- | :--- | :--- | :--- | :--- |
| **Governance Docs** | Yes (version hash) | MCP Document Store | `mcp_get_doc("CANON_MVP", version_hash)` | Gemini |
| **Runtime Logs (`stdout`/`stderr`)** | Yes ("succeeded" or "failed with error...") | Filesystem (`.gemini_logs/turn_123.log`) | On-demand via `read_file` for debugging. | Gemini |
| **Source Code** | Yes (file paths, function signatures if relevant) | Filesystem | `read_file("path/to/file.py")` or `search_file_content(...)` | Gemini |
| **Conversation History** | Yes (summary of last 3 turns) | MCP Conversation Database | `mcp_get_conversation(query="...")` | Gemini |

---

### **Prompt #9: Failure Reflection System**

**Purpose:** To define how I capture, structure, and learn from failures.

**Failure Reflection Workflow:**

| Failure Signal | Capture Method | Memory Delta Schema | Integration Rule | Decay Policy | Owner |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `exit code != 0` on a shell command. | Broker script automatically captures `command`, `exit_code`, and `stderr`. | `{ "command": "...", "exit_code": 1, "stderr": "...", "proposed_fix": "..." }` | The delta is added to a "Session Issues" log in MCP and injected into my context for the next turn. | The delta is cleared at the end of the session unless explicitly promoted to a permanent troubleshooting document. | Gemini |
| I produce a hallucinated or incorrect response. | User provides feedback: "That's wrong," "That file doesn't exist." | `{ "turn_id": "...", "bad_response": "...", "user_correction": "...", "root_cause": "..." }` | An MCP process flags this for review. A summary is added to my agent profile. | High-severity issues become permanent constraints. Minor ones decay after a few sessions. | Gemini |

---

### **Prompt #11: Context Observability Audit**

**Purpose:** To ensure my context can be inspected for debugging and verification.

**Observability Plan:**

| Observability Aspect | Current Capability | Gap | Proposed Instrumentation | Owner |
| :--- | :--- | :--- | :--- | :--- |
| **Dump Context Window** | None. The context is constructed and used ephemerally by the broker script. | **Complete.** There is no way to know what my exact prompt was. | The broker script MUST write the full and final prompt context sent to me to a log file (e.g., `.gemini_logs/turn_123_context.txt`) for every turn. | Gemini |
| **Trace Provenance** | None. I don't know why a piece of information is in my context. | **Complete.** I can't distinguish between user input, file content, or historical context. | The context itself should be structured (e.g., JSON) with metadata: `{ "source": "user_prompt", "content": "..." }`, `{ "source": "file:main.py", "content": "..." }`. | Gemini |
| **Log Exclusions** | None. I don't know what *wasn't* included. | **Complete.** I cannot ask "what did you leave out?" | The broker script should log a summary of excluded items (e.g., "omitted 5 files from directory listing," "truncated conversation history"). | Gemini |

---

### Phase 0 Work Completed

**Task 0.4.1: Create Golden Dataset for Trigger Detection**

- **Deliverable:** `.ai-agents/test_data/TRIGGER_TEST_DATASET.json`
- **Status:** COMPLETED (2025-12-09 14:54)
- **Findings:** Successfully created 25 test cases covering all 5 trigger types and edge cases, following the specified JSON format.

**Task 0.3.2: Create Feature Flag System**

- **Deliverable:** `.ai-agents/config/feature_flags.json`, `.ai-agents/config/read_flags.py`
- **Status:** COMPLETED (2025-12-09 14:55)
- **Findings:** Successfully created JSON configuration for feature flags and a Python utility for reading them, ensuring all flags default to `false`.

---

### Phase 1 Task 1C Complete

**Task:** Implement the trigger detector that uses the golden dataset.

- **Status:** COMPLETED (2025-12-10 10:15)
- **Deliverables:**
  - `.ai-agents/session_context/trigger_detector.py`
  - `tests/test_trigger_detector.py`
  - `.ai-agents/validation/TRIGGER_DETECTION_RESULTS.md`
- **Findings:**
  - Implemented the `TriggerDetector` class as specified in `docs/GEMINI_PHASE_1_TASK.md`.
  - Created the `test_trigger_detector.py` script to validate the implementation against the golden dataset.
  - After fixing an initial Python import issue related to the `.ai-agents` directory naming convention, the test script ran successfully.
  - The trigger detector achieved **100% precision** and a **0% false positive rate** on the golden dataset, exceeding the success criteria (>90% precision, <10% FP rate).
  - All results and test outputs are documented in `.ai-agents/validation/TRIGGER_DETECTION_RESULTS.md`.
  - The `docs/MCP_V1_1_MASTER_CHECKLIST.md` has been updated to reflect the completion of all tasks under section 1.3.
- **Challenges:**
  - The primary challenge was the Python `ModuleNotFoundError` caused by the `.ai-agents` directory starting with a dot. Standard import logic failed.
  - **Resolution:** Modified the test script to add the `.ai-agents` directory directly to `sys.path`, allowing the import to succeed. Renaming the directory was considered but deemed too risky due to its extensive use throughout the project.
