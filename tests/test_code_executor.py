from unittest.mock import MagicMock

import pytest

from api.code_executor import CodeExecutor, ResourceLimits


@pytest.fixture
def mock_container():
    """Fixture to create a mock container object."""
    return MagicMock()


@pytest.fixture
def resource_limits():
    """Fixture to create a ResourceLimits object."""
    return ResourceLimits(timeout_seconds=5, max_output_bytes=100)


def test_successful_execution(mock_container, resource_limits):
    # Arrange
    mock_container.exec_run.return_value = (0, (b"hello world", b""))
    executor = CodeExecutor(mock_container, resource_limits)

    # Act
    result = executor.execute("print('hello world')")

    # Assert
    assert result.success is True
    assert result.exit_code == 0
    assert result.stdout == "hello world"
    assert result.stderr == ""
    assert result.error is None


def test_execution_with_error(mock_container, resource_limits):
    # Arrange
    mock_container.exec_run.return_value = (1, (b"", b"ValueError: test error"))
    executor = CodeExecutor(mock_container, resource_limits)

    # Act
    result = executor.execute("raise ValueError('test error')")

    # Assert
    assert result.success is False
    assert result.exit_code == 1
    assert result.stdout == ""
    assert result.stderr == "ValueError: test error"
    assert result.error is not None
    assert result.error.type == "runtime_error"


def test_import_handling(mock_container, resource_limits):
    # Arrange
    executor = CodeExecutor(mock_container, resource_limits)

    # First execution with an import
    mock_container.exec_run.return_value = (0, (b"", b""))
    executor.execute("import os")

    # Second execution using the import
    mock_container.exec_run.return_value = (0, (b"/app", b""))
    result = executor.execute("print(os.getcwd())")

    # Assert
    # Check that the second command sent to exec_run included the import
    last_call_args = mock_container.exec_run.call_args[0][0]
    assert "import os" in last_call_args[2]
    assert result.stdout == "/app"


def test_output_truncation(mock_container, resource_limits):
    # Arrange
    long_string = "a" * 200
    mock_container.exec_run.return_value = (0, (long_string.encode(), b""))
    executor = CodeExecutor(mock_container, resource_limits)

    # Act
    result = executor.execute(f"print('{long_string}')")

    # Assert
    assert len(result.stdout) == resource_limits.max_output_bytes
    assert result.stdout == "a" * 100


def test_timeout(mock_container, resource_limits):
    # Arrange
    # Configure the mock to raise a timeout exception
    mock_container.exec_run.side_effect = Exception("Timeout")
    executor = CodeExecutor(mock_container, resource_limits)

    # Act
    result = executor.execute("import time; time.sleep(10)")

    # Assert
    assert result.success is False
    assert result.exit_code == -1
    assert result.error is not None
    assert result.error.type == "timeout"
