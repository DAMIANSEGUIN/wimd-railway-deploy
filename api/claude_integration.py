from typing import Any, Literal
from pydantic import BaseModel

# Assuming AnthropicVertex is available from a library like google-cloud-aiplatform
# If not, this will need to be adjusted. For now, we create a placeholder.
try:
    from anthropic.vertex import AnthropicVertex
except ImportError:
    class AnthropicVertex:
        def __init__(self, model, max_tokens, temperature, **kwargs):
            pass

# Placeholder for the @prompter decorator, as its definition was not provided.
def prompter(func):
    """A decorator to register a function as a prompter."""
    return func

# Placeholder for the LLM and Message classes.
class LLM:
    """A generic Language Model class."""
    def __init__(self, model, input_template=None, output_parser=None):
        pass

class Message:
    """A generic Message class."""
    pass

def template_messages(messages):
    """A placeholder for a message templating function."""
    pass


class ClaudeRequest(BaseModel):
    model: str
    messages: list[dict[str, str]]
    max_tokens: int
    stream: bool = False

class Claude(AnthropicVertex):
    """A Claude prompter that uses the Anthropic Vertex SDK."""

    def __init__(
        self,
        model: Literal[
            "claude-3-opus-20240229",
            "claude-3-sonnet-20240229",
            "claude-3-haiku-20240307",
        ] = "claude-3-opus-20240229",
        api_key: str | None = None, # api_key is not used by AnthropicVertex but kept for signature consistency
        max_tokens: int = 1024,
        temperature: float = 0.7,
        **kwargs: Any,
    ):
        super().__init__(
            model=model,
            max_tokens=max_tokens,
            temperature=temperature,
            **kwargs,
        )


@prompter
def claude(
    model: Literal[
        "claude-3-opus-20240229",
        "claude-3-sonnet-20240229",
        "claude-3-haiku-20240307",
    ] = "claude-3-opus-20240229",
    api_key: str | None = None,
) -> Claude:
    """Create a Claude prompter."""
    return Claude(model=model, api_key=api_key)


def claude_llm(
    model: str = "claude-3-opus-20240229",
) -> LLM: # Simplified return type annotation
    # TODO: Add temperature, etc.
    return LLM(
        model=Claude(model=model),
        input_template=template_messages,
        output_parser=str,
    )

def to_claude_role(role: Literal["system", "user", "assistant"]) -> str:
    """Convert a role to the format expected by Claude."""
    if role == "assistant":
        return "assistant"
    return "user"

def _match_claude_family(model_name: str) -> bool:
    """Helper to check if a model name belongs to the Claude family."""
    return model_name.startswith("claude-")
