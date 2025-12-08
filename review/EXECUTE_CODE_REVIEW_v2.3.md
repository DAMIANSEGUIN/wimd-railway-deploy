# Execute Code Review v2.3 (Production-Ready Proposal)

**Purpose:** This document provides a production-ready proposal for a canonical `execute_code` function, incorporating feedback from a senior architectural review (from Codex). This version specifically addresses the detailed feedback regarding `exec_run` result unpacking, timeout passing, and output size handling.

---

## 1. Proposal: A Production-Ready `CodeExecutor`

I propose a new, canonical `CodeExecutor` class that is secure, robust, and provides detailed, structured feedback to the caller. This implementation will be housed in a new `api/code_executor.py` module.

### 1.1 Core Components

The implementation will consist of three main Pydantic models and two classes:
- **`ExecutionResult` (Model):** A structured object for returning the results of an execution.
- **`ExecutionError` (Model):** A structured object for returning detailed error information.
- **`ResourceLimits` (Model):** A model for defining execution resource limits.
- **`Notebook` (Class):** A session-level class to manage state, primarily for persisting imports.
- **`CodeExecutor` (Class):** The main class responsible for executing code in a sandboxed container.

---

## 2. Data Models (Pydantic)

### `ExecutionResult`
```python
from pydantic import BaseModel
from typing import Optional

class ExecutionResult(BaseModel):
    """Data model for the result of a code execution."""
    success: bool
    exit_code: int
    stdout: str
    stderr: str
    duration_ms: int
    error: Optional["ExecutionError"] = None
```

### `ExecutionError`
```python
class ExecutionError(BaseModel):
    """Data model for an execution error."""
    type: str  # e.g., "timeout", "oom_killed", "runtime_error"
    message: str
```

### `ResourceLimits`
```python
class ResourceLimits(BaseModel):
    """Defines the resource limits for a code execution."""
    timeout_seconds: int = 30
    memory_mb: int = 512 # Conceptual, often set at container creation
    cpus: float = 0.5    # Conceptual, often set at container creation
    max_output_bytes: int = 10 * 1024 * 1024 # 10MB
```

Timeout is enforced by passing `timeout_seconds` directly to `exec_run`. Memory and CPU ceilings remain container-level
settings configured when the sandbox is created, while `max_output_bytes` is applied to the raw stdout/stderr byte
streams before they are decoded to UTF-8 so the byte-limit guarantee holds.

---

## 3. `Notebook` Class Contract

The `Notebook` class manages the state of imports for a session.

```python
import re

class Notebook:
    """Manages the state of imports for a session."""
    def __init__(self):
        self._imports: set[str] = set()

    def add_imports_from_code(self, code: str):
        """Parses and stores top-level imports from a code block."""
        # This regex is a simple heuristic and might not catch all edge cases.
        # A more robust solution might involve Python's ast module.
        imports = re.findall(r"^(?:from\s+[\w\.]+\s+)?import\s+[\w\s,.*]+$", code, re.MULTILINE)
        self._imports.update(imp.strip() for imp in imports)

    def get_code_with_imports(self, code: str) -> str:
        """Prepends all stored imports to a given code block."""
        return "\n".join(sorted(self._imports)) + "\n\n" + code
```

---

## 4. `CodeExecutor` Class (Canonical Implementation)

This class provides the core logic for sandboxed code execution.

```python
import time
from typing import Tuple
# Assuming a container library like 'docker' is used and 'Container' class is available.
# from docker.models.containers import Container

class CodeExecutor:
    """Executes code in a secure, sandboxed container."""

    def __init__(self, container, limits: ResourceLimits):
        self._container = container # The Docker container object
        self._limits = limits
        self.notebook = Notebook()

    def execute(self, code: str) -> ExecutionResult:
        """
        Executes a code string in a container, enforcing resource limits.
        """
        start_time = time.monotonic() 
        
        # Add imports from the current code block to the notebook state
        self.notebook.add_imports_from_code(code)
        full_code = self.notebook.get_code_with_imports(code)
        
        # 1. Interpreter Invocation: Use 'python -c' for security.
        #    This avoids shell injection concerns.
        command = ["python", "-c", full_code]
        
        try:
            # 2. Timeout and Resource Limits: enforce timeout via exec_run,
            #    while memory/CPU limits remain container-level settings.
            
            # The docker-py exec_run returns (exit_code, output_bytes_tuple)
            # where output_bytes_tuple is (stdout_bytes, stderr_bytes)
            exit_code, output_tuple = self._container.exec_run(
                command,
                demux=True,  # Separate stdout/stderr
                timeout=self._limits.timeout_seconds,
                # stream=False, # We want final output, not a stream for this
                # user="sandbox_user", # Run as a non-root user
                # workdir="/app", # Working directory inside the container
                # environment={"PYTHONUNBUFFERED": "1"}, # Ensure stdout/stderr are unbuffered
            )
            
            stdout_bytes: bytes = (output_tuple[0] or b"") if output_tuple and len(output_tuple) > 0 else b""
            stderr_bytes: bytes = (output_tuple[1] or b"") if output_tuple and len(output_tuple) > 1 else b""
            
            # Truncate outputs if they exceed max_output_bytes before decoding
            stdout_bytes = stdout_bytes[:self._limits.max_output_bytes]
            stderr_bytes = stderr_bytes[:self._limits.max_output_bytes]
            stdout = stdout_bytes.decode("utf-8", errors="ignore")
            stderr = stderr_bytes.decode("utf-8", errors="ignore")
            
            duration_ms = int((time.monotonic() - start_time) * 1000)
            
            # 3. Success-Path Output Handling
            if exit_code == 0:
                return ExecutionResult(
                    success=True,
                    exit_code=exit_code,
                    stdout=stdout,
                    stderr=stderr,
                    duration_ms=duration_ms,
                )
            else:
                return ExecutionResult(
                    success=False,
                    exit_code=exit_code,
                    stdout=stdout,
                    stderr=stderr,
                    duration_ms=duration_ms,
                    error=ExecutionError(
                        type="runtime_error",
                        message=f"Code execution failed with exit code {exit_code}."
                    ),
                )

        except Exception as e: # This catches errors *calling* exec_run (e.g., container not running, timeout if not handled by exec_run itself)
            duration_ms = int((time.monotonic() - start_time) * 1000)
            
            error_type = "unknown_executor_error"
            message = str(e)
            
            # Specific handling for timeouts if the exec_run itself doesn't raise a specific timeout exception
            if "timeout" in message.lower(): # Heuristic to catch timeout messages
                error_type = "timeout"
                message = f"Execution timed out after {self._limits.timeout_seconds} seconds."

            return ExecutionResult(
                success=False,
                exit_code=-1, # Indicating an error with the executor itself
                stdout="",
                stderr=message,
                duration_ms=duration_ms,
                error=ExecutionError(type=error_type, message=message),
            )
```

---

## 5. Summary of Improvements (v2.3) 

This `v2.3` proposal addresses all of Codex's feedback:
-   **`Notebook` Contract:** The `Notebook` class is now clearly defined with `add_imports_from_code` and `get_code_with_imports` methods.
-   **Interpreter Invocation:** The executor now explicitly uses `python -c "..."` for enhanced security.
-   **Success-Path Output Handling:** The `ExecutionResult` model and the `execute` method now capture and return `stdout` and `stderr` for both success and failure cases.
-   **Resource Limits:**
    -   `ResourceLimits` model includes `max_output_bytes`.
    -   Timeout is enforced via the `exec_run(..., timeout=...)` parameter.
    -   Output truncation happens on the raw byte streams before decoding, preserving the byte-limit guarantee.
    -   Memory/CPU limits are noted as container creation parameters.
-   **Stream Safety:** `exec_run` outputs are normalized so that empty streams (`None`) become `b""` before decoding, avoiding runtime errors.
-   **Structured Results:** Pydantic models provide a clear contract.
-   **Robust Error Handling:** Distinguishes between code execution errors and executor-level errors (like timeouts).
```