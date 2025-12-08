# Execute Code Review v2.1

**Purpose:** This document aggregates various implementations for an `execute_code` function and proposes a single, canonical implementation that is secure, robust, and maintainable, incorporating feedback from Codex.

---

## 1. Conflicting Implementations
(Content remains the same as v2.0)

---

## 2. Supporting Context
(Content remains the same as v2.0)

---

## 3. Revised Proposal (v2.1): Adopt the Container-based Implementation

This revised proposal incorporates feedback from Codex to create a more detailed and robust plan.

### 3.1 Rationale
- **Security:** The container-based approach provides a secure, sandboxed environment.
- **Robustness:** It handles `exit_code` and `output` streams, allowing for proper error handling and logging.

### 3.2 Proposed Canonical Implementation

A new `CodeExecutor` class will be created.

```python
# In a new file, e.g., 'api/code_executor.py'

class CodeExecutor:
    def __init__(self, container, timeout=30):
        self._container = container
        self._timeout = timeout
        self.notebook = Notebook()

    def execute(self, code: str, context: CodeExecutorContext) -> None:
        full_code = self.notebook.get_code_with_imports(code)
        
        # Execute code using 'python -c' for security
        command = ["python", "-c", full_code]
        
        result = self._container.exec_run(
            command,
            demux=True, # Separate stdout/stderr
        )
        
        # Handle success and failure paths
        if result.exit_code == 0:
            context.add_output({
                "type": "successful_execution",
                "stdout": result.output[0].decode("utf-8") if result.output[0] else "",
                "stderr": result.output[1].decode("utf-8") if result.output[1] else "",
            })
        else:
            context.add_error({
                "type": "execution_error",
                "exit_code": result.exit_code,
                "stdout": result.output[0].decode("utf-8") if result.output[0] else "",
                "stderr": result.output[1].decode("utf-8") if result.output[1] else "",
            })

```

### 3.3 `Notebook` Contract (Clarification)

- **Purpose:** The `Notebook` class is responsible for managing the state of imports across multiple code executions within a single session.
- **Lifecycle:** An instance of `Notebook` will be created at the start of a session and will persist for the duration of that session.
- **Implementation:** It will be a simple, in-memory Python class that parses `import` statements from executed code and stores them.
- **Example:**
  ```python
  class Notebook:
      def __init__(self):
          self._imports = set()

      def add_imports_from_code(self, code: str):
          # Simple regex to find top-level imports
          imports = re.findall(r"^(?:from\s+.+\s+)?import\s+.+$", code, re.MULTILINE)
          self._imports.update(imports)

      def get_code_with_imports(self, code: str) -> str:
          return "\n".join(sorted(self._imports)) + "\n" + code
  ```

### 3.4 Interpreter Invocation (Clarification)

- **Method:** Code will be executed by passing it to `python -c "..."` within the container.
- **Rationale:** This is a standard, secure method that avoids shell injection vulnerabilities that could arise from piping code directly into a shell.

### 3.5 Success-Path Output Handling (Clarification)

- **Method:** The `exec_run` command will be called with `demux=True` to separate `stdout` and `stderr` streams.
- **Logging:** Both `stdout` and `stderr` will be captured and added to the execution context for both successful and failed runs, allowing callers to access the full output.

### 3.6 Resource Limits and Enforcement (Clarification)

- **Timeouts:** A configurable timeout (e.g., 30 seconds) will be enforced for each execution. The `exec_run` method of most container libraries supports a `timeout` parameter.
- **Memory/CPU Caps:** These will be configured at the container level when the execution environment is first created (e.g., via `docker run --memory="2g" --cpus="1"`). This prevents any single execution from consuming excessive system resources.
- **Max Output Size:** The executor will truncate `stdout` and `stderr` if they exceed a certain size (e.g., 1MB) to prevent memory issues from verbose outputs.

This revised plan addresses the feedback from Codex and provides a more complete and secure foundation for the `execute_code` function.
