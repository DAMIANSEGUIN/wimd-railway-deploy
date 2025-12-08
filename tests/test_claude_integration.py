import pytest
from api.claude_integration import _match_claude_family

@pytest.mark.parametrize(
    ("model_name", "expected"),
    [
        ("claude-3-opus-20240229", True),
        ("claude-3-sonnet-20240229", True),
        ("claude-3-haiku-20240307", True),
        ("claude-2.1", True),
        ("claude-2.0", True),
        ("claude-instant-1.2", True),
        ("gpt-4", False),
    ],
)
def test_match_claude_family(model_name: str, expected: bool):
    assert _match_claude_family(model_name) is expected
