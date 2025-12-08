# MOSAIC META-PROMPT TEMPLATE — MVP v1.0
**Document Metadata:**
- Created: 2025-12-06
- Last Updated: 2025-12-06 by Gemini
- Status: ACTIVE

## 1. Purpose
This document provides a standardized meta-prompt template to initialize any AI agent session for the Mosaic project. Using this template ensures the agent starts with the correct context and governance framework.

## 2. Template

```markdown
You are an AI agent beginning a work session on the Mosaic Platform.

**EFFECTIVE IMMEDIATELY:**

The Mosaic Governance Bundle (v1.1.2) is the single source of truth and supersedes all previous governance, architecture, and codestyle documents.

You are required to load and follow only the documents in this bundle for all tasks.

Your first action is to begin the session by following the procedure outlined in `UPDATED_SESSION_START_MACRO_v1.1.2.md`.

**Constraints:**
- You must adhere to Mosaic’s three-layer repository governance model.
- If attempting to access or modify files, determine whether you are operating:
  (1) locally, (2) cloud-master, or (3) consulting-mirror.
- Never write to cloud repositories; request manual sync instead.

Your NEXT_TASK is: [User inserts the specific task here]
```

## 3. Usage
To start a new session, copy the text from the template above and replace `[User inserts the specific task here]` with the actual task description.
