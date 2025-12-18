# CODESTYLE CODEX — MVP v1.0

**Document Metadata:**

- Created: 2025-12-06
- Last Updated: 2025-12-06
- Status: ACTIVE

## 1. General Principles

- **Clarity:** Code should be clear and readable. Favor straightforward logic over complex one-liners.
- **Consistency:** Adhere to the style of the existing codebase.
- **Simplicity:** Write the simplest code that solves the problem.

## 2. Python

- **Base Standard:** Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/).
- **Strings:** Use f-strings for string formatting (e.g., `f"Hello, {name}"`).
- **Type Hinting:** Use type hints for function signatures and variables where it improves clarity.
- **Imports:** Group imports in the following order: standard library, third-party libraries, local application.

## 3. JavaScript / React

- **Base Standard:** Follow a common standard like the Airbnb JavaScript Style Guide.
- **Variables:** Use `const` by default; use `let` only when a variable must be reassigned. Avoid `var`.
- **Functions:** Prefer arrow functions, especially for callbacks.
- **React:**
  - Use functional components with Hooks.
  - Component names should be in `PascalCase`.
  - Hook names should start with `use` (e.g., `useMyHook`).

## 4. Markdown

- Use Prettier-compatible markdown formatting.
- Use headings (`#`, `##`, etc.) to structure documents.
- Use backticks for inline code (`` `code` ``) and triple backticks for code blocks.
