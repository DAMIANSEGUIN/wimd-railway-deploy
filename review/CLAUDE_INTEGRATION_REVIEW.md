# Claude Integration Review

**Purpose:** This document aggregates various implementations and context for a "Claude" integration to facilitate a comprehensive review. There are multiple, conflicting implementations of prompter functions and classes that need to be resolved into a single, canonical approach.

---

## 1. Conflicting `claude()` Prompter Functions

There are several different implementations of the main `claude()` prompter function.

### Implementation A
```python
@prompter
def claude(
    model: str = "claude-3-haiku-20240307",
) -> Claude:
    ...
```

### Implementation B
```python
@prompter
def claude(
    model: str = "claude-3-opus-20240229",
) -> Claude:
    ...
```

### Implementation C
```python
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
```

---

## 2. Conflicting `Claude` Class Implementations

There are two different `Claude` classes, one using Vertex AI and one using a direct Anthropic client.

### Class A: Vertex AI Integration
```python
class Claude(AnthropicVertex):
    """A Claude prompter that uses the Anthropic Vertex SDK."""

    def __init__(
        self,
        model: Literal[
            "claude-3-opus-20240229",
            "claude-3-sonnet-20240229",
            "claude-3-haiku-20240307",
        ] = "claude-3-opus-20240229",
        api_key: str | None = None,
        max_tokens: int = 1024,
        temperature: float = 0.7,
        **kwargs: Any,
    ):
        super().__init__(
            model=model,
            api_key=api_key,
            max_tokens=max_tokens,
            temperature=temperature,
            **kwargs,
        )
```

### Class B: Direct Client Integration
```python
class Claude(LLM[ClaudeRequest, str]):
    def __init__(
        self,
        model: str = "claude-3-opus-20240229",
        api_key: str | None = None,
        api_client: anthropic.Client | None = None,
    ):
        self._model = model
        self._api_key = api_key
        self._api_client = api_client

    @property
    def api_client(self) -> anthropic.Client:
        if self._api_client is None:
            self._api_client = anthropic.Client(api_key=self._api_key)
        return self._api_client
```

---

## 3. Supporting Code and Models

### `ClaudeRequest` Model
```python
class ClaudeRequest(BaseModel):
    model: str
    messages: list[dict[str, str]]
    max_tokens: int
    stream: bool = False
```

### `claude_llm()` Factory Function
```python
def claude_llm(
    model: str = "claude-3-opus-20240229",
) -> LLM[list[Message], str]:
    # TODO: Add temperature, etc.
    return LLM(
        model=Claude(model=model),
        input_template=template_messages,
        output_parser=str,
    )
```

### `to_claude_role()` Helper Function
```python
def to_claude_role(role: Literal["system", "user", "assistant"]) -> str:
    """Convert a role to the format expected by Claude."""
    if role == "assistant":
        return "assistant"
    return "user"
```

### `test_match_claude_family()` Test Function
```python
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
```

---

## 4. Related Information

### Claude API Grading Benchmark
```
**Claude API Grading Benchmark**

**Scenario:** Evaluate a series of text prompts using the Claude API
**SoT:** magentic-ui/src/app/page.tsx (contains React components for grading)
**Instruction:** Create a Python script that takes a JSON file of prompts, sends each to the Claude API, and then uses a series of weighted checks to assign a grade. The script must include a confidence score for each grade.
**Benchmark:** Output must match the grading distribution in `sample_outputs/claude_benchmark_results.json` ±5%.
```

### Magentic-UI
```
Magentic-UI

This is a web UI for interacting with Magentic.
It is a Next.js app with a Python backend.

The UI allows the user to:
- Select a model
- Enter a prompt
- See the model's response
- View the history of prompts and responses

The backend is a Flask app that uses Magentic to interact with the models.
It has a single endpoint that takes a prompt and returns the model's response.
```
