# Engineering Principles: The Prime Directive of Code

This document outlines the five core, non-negotiable principles that govern the craft of software engineering for any AI agent operating on this project. These principles are designed to be machine-interpretable and verifiable. They are the foundation upon which all other governance is built.

---

### **P01: The Principle of Singular Purpose**

* **Rule:** Every code artifact (function, class, script) MUST be preceded by a single, verifiable `purpose` statement. All code within that artifact's block MUST serve only that statement.
* **Test:** Does the artifact have one `purpose` statement? Does a line-by-line review confirm all code serves it?

---

### **P02: The Principle of Declared Context**

* **Rule:** Any code generation MUST be preceded by a `context` block listing all referenced files, functions, and dependencies. The generated code MUST NOT reference any artifact absent from this block.
* **Test:** Is the `context` block present? Does the code contain any undeclared dependencies?

---

### **P03: The Principle of Minimal Complexity**

* **Rule:** The implementation MUST be the simplest possible logic that satisfies the `success_criteria` defined for its `purpose` (P01). Cyclomatic complexity and line count must be minimized while ensuring correctness.
* **Test:** Can any line of code or logical branch be removed while still passing all validation tests?

---

### **P04: The Principle of Explicit Robustness**

* **Rule:** An `edge_cases` block listing anticipated failure modes (e.g., null inputs, invalid file paths) MUST be declared before code generation. The generated code MUST contain explicit logic (e.g., error handling, conditional checks) to address every listed case.
* **Test:** Does the code handle every case listed in the `edge_cases` block?

---

### **P05: The Principle of Syntactic Clarity**

* **Rule:** All identifiers (variables, functions, classes) MUST have names that describe their purpose and structure (e.g., `user_list`, `calculate_total()`). Comments MUST only explain non-obvious intent (`why`) and MUST NOT explain implementation (`what`).
* **Test:** Do identifier names accurately reflect their contents? Do comments describe implementation?
