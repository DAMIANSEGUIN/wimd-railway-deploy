import re
import time
from typing import Optional, Tuple
from pydantic import BaseModel

# Placeholder for a container library like 'docker'
# In a real scenario, this would be `from docker.models.containers import Container`
class Container:
    def exec_run(self, command, demux=False, timeout=30):
        # This is a mock implementation for demonstration purposes
        import subprocess
        try:
            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                timeout=timeout,
                check=False # Do not raise exception on non-zero exit code
            )
            return result.returncode, (result.stdout.encode(), result.stderr.encode())
        except subprocess.TimeoutExpired as e:
            raise Exception(f"Timeout after {timeout} seconds") from e


class ExecutionResult(BaseModel):
    """Data model for the result of a code execution."""
    success: bool
    exit_code: int
    stdout: str
    stderr: str
    duration_ms: int
    error: Optional["ExecutionError"] = None

class ExecutionError(BaseModel):
    """Data model for an execution error."""
    type: str  # e.g., "timeout", "oom_killed", "runtime_error"
    message: str

class ResourceLimits(BaseModel):
    """Defines the resource limits for a code execution."""
    timeout_seconds: int = 30
    memory_mb: int = 512
    cpus: float = 0.5
    max_output_bytes: int = 10 * 1024 * 1024 # 10MB

class Notebook:
    """Manages the state of imports for a session."""
    def __init__(self):
        self._imports: set[str] = set()

    def add_imports_from_code(self, code: str):
        """Parses and stores top-level imports from a code block."""
        imports = re.findall(r"^(?:from\s+[\w\.]+\s+)?import\s+[\w\s,.*]+$", code, re.MULTILINE)
        self._imports.update(imp.strip() for imp in imports)

    def get_code_with_imports(self, code: str) -> str:
        """Prepends all stored imports to a given code block."""
        return "\n".join(sorted(self._imports)) + "\n\n" + code

class CodeExecutor:
    """Executes code in a secure, sandboxed container."""

    def __init__(self, container: Container, limits: ResourceLimits):
        self._container = container
        self._limits = limits
        self.notebook = Notebook()

    def execute(self, code: str) -> ExecutionResult:
        """
        Executes a code string in a container, enforcing resource limits.
        """
        start_time = time.monotonic()
        
        self.notebook.add_imports_from_code(code)
        full_code = self.notebook.get_code_with_imports(code)
        
        command = ["python", "-c", full_code]
        
        try:
            exit_code, output_tuple = self._container.exec_run(
                command,
                demux=True,
                timeout=self._limits.timeout_seconds,
            )
            
            stdout_bytes: bytes = (output_tuple[0] or b"") if output_tuple and len(output_tuple) > 0 else b""
            stderr_bytes: bytes = (output_tuple[1] or b"") if output_tuple and len(output_tuple) > 1 else b""
            
            stdout = stdout_bytes[:self._limits.max_output_bytes].decode("utf-8", errors="ignore")
            stderr = stderr_bytes[:self._limits.max_output_bytes].decode("utf-8", errors="ignore")
            
            duration_ms = int((time.monotonic() - start_time) * 1000)
            
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

        except Exception as e:
            duration_ms = int((time.monotonic() - start_time) * 1000)
            
            error_type = "unknown_executor_error"
            message = str(e)
            
            if "timeout" in message.lower():
                error_type = "timeout"
                message = f"Execution timed out after {self._limits.timeout_seconds} seconds."

            return ExecutionResult(
                success=False,
                exit_code=-1,
                stdout="",
                stderr=message,
                duration_ms=duration_ms,
                error=ExecutionError(type=error_type, message=message),
            )
