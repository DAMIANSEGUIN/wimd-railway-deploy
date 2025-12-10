# Broker Architecture for MCP v1.1

**Author:** Gemini
**Date:** 2025-12-10
**Status:** DRAFT
**Related Task:** Phase 2, Task 2.1 (Broker Integration)

---

## 1. Overview

This document outlines the architecture for a "Broker" script. The broker's primary function is to act as an intermediary between the user and the AI agent. It enhances the agent's context by automatically retrieving relevant documentation based on triggers detected in the user's conversation.

This system is a direct implementation of the requirements outlined in the MCP v1.1 Master Checklist, Section 2.1. It leverages the `trigger_detector.py` script created in Phase 1.

The core goals of this architecture are:
- To automate the retrieval of full documentation when a trigger is fired.
- To provide the agent with just-in-time context, improving response quality without manually loading large documents at the start of a session.
- To maintain a log of the context provided to the agent for debugging and analysis.

---

## 2. Architecture Diagram

The data flow is simple and linear:

```
+------+   1. User Message   +--------+   2. Detect Triggers   +------------------+
| User | ----------------> | Broker | ---------------------> | Trigger Detector |
+------+                   +--------+                        +------------------+
                               |                                      | 3. Return Triggers
                               | 6. Agent Call                        | 
                               v                                      v
                           +-------+   5. Augmented Prompt   +----------------+
                           | Agent | <---------------------  | Document Store |
                           +-------+                         +----------------+
                                                                     ^
                                                                     | 4. Fetch Docs
                                                                     | 
                                                               +--------+
                                                               | Broker |
                                                               +--------+
```

---

## 3. Component: Broker Script (`broker.py`)

The heart of the system is a Python script, `broker.py`.

### Responsibilities:
1.  **Entrypoint:** It will be the new entrypoint for handling user messages, replacing direct calls to the agent.
2.  **Trigger Detection:** It will import `TriggerDetector` from `.ai-agents/session_context/trigger_detector.py`.
3.  **Document Retrieval:** It will read the content of the files identified by the trigger detector.
4.  **Prompt Augmentation:** It will construct a new, augmented prompt for the agent.
5.  **Agent Invocation:** It will call the main agent with the augmented prompt.
6.  **Logging:** It will log the full context sent to the agent for every turn.

### Proposed Implementation (`broker.py`):

```python
import datetime
import os
from trigger_detector import TriggerDetector

class Broker:
    def __init__(self, agent_interface):
        self.detector = TriggerDetector()
        self.agent = agent_interface
        self.log_dir = ".gemini_logs"
        os.makedirs(self.log_dir, exist_ok=True)

    def _log_context(self, context):
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        log_file = os.path.join(self.log_dir, f"turn_{timestamp}_context.txt")
        with open(log_file, "w") as f:
            f.write(context)

    def process_message(self, user_message):
        # 1. Detect Triggers
        triggers = self.detector.detect_triggers(user_message)
        
        # 2. Get Document Paths
        doc_paths = self.detector.get_document_paths(triggers)
        
        # 3. Retrieve Document Content
        retrieved_docs = ""
        if doc_paths:
            retrieved_docs += "--- RETRIEVED CONTEXT ---
"
            for trigger, path in doc_paths.items():
                try:
                    with open(path, "r") as f:
                        content = f.read()
                    retrieved_docs += f"--- Start of {path} ---
"
                    retrieved_docs += content
                    retrieved_docs += f"\n--- End of {path} ---
\n"
                except FileNotFoundError:
                    retrieved_docs += f"--- WARNING: Could not find document for trigger '{trigger}' at path: {path} ---
\n"
            retrieved_docs += "---------------------------
\n"

        # 4. Construct Augmented Prompt
        augmented_prompt = f"{retrieved_docs}User message: {user_message}"

        # 5. Log the context
        self._log_context(augmented_prompt)

        # 6. Call the agent
        agent_response = self.agent.handle_message(augmented_prompt)
        return agent_response

# This is a placeholder for whatever the actual agent interface is.
class AgentInterface:
    def handle_message(self, prompt):
        # In a real scenario, this would call the agent's API or main function
        print("--- AGENT PROMPT ---")
        print(prompt)
        print("--- END AGENT PROMPT ---")
        return "This is the agent's response."

if __name__ == '__main__':
    # Example Usage
    broker = Broker(agent_interface=AgentInterface())
    test_message = "The deployment is failing with a 500 error, can you look into the postgres database connection?"
    broker.process_message(test_message)
```

---

## 4. Specification: Agent & Trigger Detector Interface

### Agent Interface
The broker will call the agent. This inverts the current model where the agent might call other tools. The agent must be adaptable to receive a pre-processed, augmented prompt. The interface will be a simple function call.

-   `agent.handle_message(prompt: str) -> str`

The `prompt` will contain the original user message, prefixed with any retrieved documentation.

### Trigger Detector Interface
The broker will use the existing `TriggerDetector` class and its methods as defined in `.ai-agents/session_context/trigger_detector.py`.

1.  **Instantiation:**
    `detector = TriggerDetector()`

2.  **Trigger Detection:**
    `triggers = detector.detect_triggers(user_message)`
    -   **Input:** `user_message` (str)
    -   **Output:** `List[str]` (e.g., `["TROUBLESHOOTING_CHECKLIST", "DEPLOYMENT_TRUTH"]`)

3.  **Document Path Mapping:**
    `doc_paths = detector.get_document_paths(triggers)`
    -   **Input:** `triggers` (List[str])
    -   **Output:** `Dict[str, str]` (e.g., `{"TROUBLESHOOTING_CHECKLIST": "TROUBLESHOOTING_CHECKLIST.md"}`)

---

## 5. Logging

As specified in the MCP Master Checklist, observability is key. The broker will be responsible for logging the *exact* context provided to the agent for each turn.

-   **Location:** `.gemini_logs/`
-   **Filename:** `turn_<YYYYMMDD_HHMMSS>_context.txt`
-   **Content:** The full, augmented prompt string sent to the agent.

This allows for perfect reproducibility of any agent interaction and is critical for debugging why an agent made a particular decision.

```