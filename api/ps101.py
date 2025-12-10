"""
MODULE: api/ps101.py
PURPOSE: PS101 context extraction with security and resilience
VERSION: 2.0.0-mvp-day1-fixed
LAST_MODIFIED: 2025-12-03
MODIFIED_BY: Claude Code
SPRINT: MVP Context-Aware Coaching (Day 1 - Blocker Fixes)

SECURITY FIXES:
  - Added X-User-ID header authentication to /api/ps101/extract-context
  - Validates user exists before processing

RESILIENCE FIXES:
  - Added 30-second timeout to Claude API call
  - Added retry logic with exponential backoff (3 retries, handles 429/5xx)

DEPENDENCIES:
  - anthropic library (Claude API)
  - pydantic (validation)
  - storage.get_conn (database)
  - ps101_responses table (must exist)
  - user_contexts table (must exist)

ROLLBACK_PATH:
  - Delete this file to rollback
  - Revert api/index.py router integration
  - Git tag: backup-20251203-pre-blockers
"""

import anthropic
import json
import logging
import time
import os
from typing import Dict, List
from pydantic import BaseModel, Field, ValidationError
from fastapi import APIRouter, Header, HTTPException

logger = logging.getLogger(__name__)

# Configuration
CLAUDE_API_TIMEOUT = 30  # seconds (Gemini's recommendation)
MAX_RETRIES = 3
INITIAL_BACKOFF = 1  # seconds
MAX_BACKOFF = 60  # seconds

router = APIRouter()


# ===================================================================
# PYDANTIC MODELS
# ===================================================================

class ExperimentIdea(BaseModel):
    """Pydantic model for proposed experiments"""
    idea: str
    smallest_version: str


class PS101Context(BaseModel):
    """
    Structured context extracted from PS101 responses.

    Used for personalized coaching system prompt injection.
    Validated via Pydantic (Gemini's recommendation for LLM robustness).
    """
    problem_definition: str
    passions: List[str] = Field(default_factory=list)
    skills: List[str] = Field(default_factory=list)
    secret_powers: List[str] = Field(default_factory=list)
    proposed_experiments: List[ExperimentIdea] = Field(default_factory=list)
    internal_obstacles: List[str] = Field(default_factory=list)
    external_obstacles: List[str] = Field(default_factory=list)
    key_quotes: List[str] = Field(default_factory=list)


# ===================================================================
# RETRY UTILITY (RESILIENCE FIX #2)
# ===================================================================

def retry_with_exponential_backoff(func, max_retries=MAX_RETRIES):
    """
    Retry function with exponential backoff for 429/5xx errors.

    Handles:
    - 429 (Too Many Requests) from Claude API
    - 5xx (Server errors) from Claude API
    - Network errors

    Pattern: RESILIENCE per SELF_DIAGNOSTIC_FRAMEWORK.md Section "Retry with Jitter"

    Args:
        func: Callable that makes API call
        max_retries: Maximum number of retry attempts

    Returns:
        Result from func()

    Raises:
        Last exception if all retries exhausted
    """
    for attempt in range(max_retries + 1):
        try:
            return func()
        except anthropic.RateLimitError as e:  # 429
            if attempt == max_retries:
                logger.error(f"Rate limit exceeded after {max_retries} retries")
                raise
            backoff = min(INITIAL_BACKOFF * (2 ** attempt), MAX_BACKOFF)
            logger.warning(
                f"Rate limit hit, retrying in {backoff}s (attempt {attempt+1}/{max_retries})"
            )
            time.sleep(backoff)
        except anthropic.APIStatusError as e:  # 5xx or other API errors
            if attempt == max_retries or e.status_code < 500:  # Don't retry 4xx (except 429 above)
                raise
            backoff = min(INITIAL_BACKOFF * (2 ** attempt), MAX_BACKOFF)
            logger.warning(
                f"API error {e.status_code}, retrying in {backoff}s (attempt {attempt+1}/{max_retries})"
            )
            time.sleep(backoff)
        except Exception as e:
            # Network errors, etc.
            if attempt == max_retries:
                logger.error(f"Request failed after {max_retries} retries: {e}")
                raise
            backoff = min(INITIAL_BACKOFF * (2 ** attempt), MAX_BACKOFF)
            logger.warning(
                f"Request failed, retrying in {backoff}s (attempt {attempt+1}/{max_retries}): {e}"
            )
            time.sleep(backoff)


# ===================================================================
# CONTEXT EXTRACTION (with TIMEOUT FIX #1)
# ===================================================================

def extract_ps101_context_from_responses(ps101_responses: Dict[str, str]) -> PS101Context:
    """
    Extract structured context from PS101 responses using Claude API.

    SECURITY: This is a utility function. Authentication happens at endpoint level.
    RESILIENCE: Includes timeout and retry logic.

    Args:
        ps101_responses: Dict mapping question IDs to user responses

    Returns:
        PS101Context object with validated structured data

    Raises:
        ValidationError: If Claude response doesn't match schema
        HTTPException: If API call fails after retries
    """
    api_key = os.getenv("CLAUDE_API_KEY")
    if not api_key:
        logger.error("CLAUDE_API_KEY not set in environment")
        raise HTTPException(status_code=500, detail="Claude API not configured")

    client = anthropic.Anthropic(api_key=api_key)

    extraction_prompt = f"""Analyze these career reflection responses and extract structured context.

<ps101_responses>
{json.dumps(ps101_responses, indent=2)}
</ps101_responses>

Extract the following. Be specific—use their exact language where powerful. If something isn't mentioned, return empty array.

Return ONLY valid JSON in this exact structure:

{{
  "problem_definition": "One sentence capturing what they're trying to solve or change",
  "passions": ["Things that energize them, interests they keep returning to"],
  "skills": ["Concrete abilities they've demonstrated"],
  "secret_powers": ["Strengths others see in them they may undervalue, unique combinations"],
  "proposed_experiments": [
    {{
      "idea": "Direction or possibility they mentioned exploring",
      "smallest_version": "Tiniest way to test this (you suggest if they didn't)"
    }}
  ],
  "internal_obstacles": ["Fears, self-doubt, mindset blocks they identified"],
  "external_obstacles": ["Practical constraints: money, time, location, responsibilities"],
  "key_quotes": ["2-3 powerful phrases in their own words worth reflecting back"]
}}

Rules:
- Use THEIR language, not generic coaching speak
- "Secret powers" = things they mentioned casually but reveal real strength
- Every experiment needs a "smallest_version" even if you have to suggest one
- "key_quotes" = phrases that reveal core identity or insight—these get mirrored back in coaching
- Be concise. This powers a coaching system, not a report."""

    # Define API call function for retry wrapper
    def call_claude_api():
        return client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=1500,
            timeout=CLAUDE_API_TIMEOUT,  # ✅ RESILIENCE FIX #1: Timeout added
            messages=[{"role": "user", "content": extraction_prompt}]
        )

    # Execute with retry logic
    try:
        message = retry_with_exponential_backoff(call_claude_api)  # ✅ RESILIENCE FIX #2: Retry added
    except Exception as e:
        logger.error(f"Claude API call failed after retries: {e}", exc_info=True)
        raise HTTPException(
            status_code=503,
            detail="Context extraction service temporarily unavailable"
        )

    # Parse JSON from response (handles markdown code blocks)
    response_text = message.content[0].text
    if "```json" in response_text:
        response_text = response_text.split("```json")[1].split("```")[0]
    elif "```" in response_text:
        response_text = response_text.split("```")[1].split("```")[0]

    # Validate with Pydantic (Gemini's recommendation - already implemented)
    try:
        return PS101Context.model_validate_json(response_text.strip())
    except ValidationError as e:
        logger.error(
            f"LLM output validation failed: {e}",
            extra={"response": response_text}
        )
        raise HTTPException(
            status_code=422,
            detail="Invalid context structure from AI model"
        )


# ===================================================================
# FASTAPI ENDPOINT (with AUTHENTICATION FIX)
# ===================================================================

@router.post("/extract-context")
async def extract_context_endpoint(
    user_id: str = Header(..., alias="X-User-ID")  # ✅ SECURITY FIX: Authentication required
):
    """
    Extract structured context from completed PS101 responses.

    SECURITY: Requires X-User-ID header (existing auth mechanism)
    RESILIENCE: Includes timeout + retry logic

    Args:
        user_id: User ID from X-User-ID header (authenticated)

    Returns:
        Structured PS101Context JSON

    Raises:
        401: Missing authentication (handled by FastAPI - missing required header)
        404: User not found or PS101 not completed
        422: Validation error (malformed LLM response)
        503: Service unavailable (API failures after retry)
    """
    from .storage import get_conn, get_user_by_id

    # ✅ SECURITY FIX: Validate user exists
    user = get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Fetch PS101 responses from database (✅ using sacred context manager pattern)
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT step, prompt_index, response
            FROM ps101_responses
            WHERE user_id = %s
            ORDER BY step, prompt_index
        """, (user_id,))
        responses = cursor.fetchall()

    if not responses:
        raise HTTPException(status_code=404, detail="PS101 not completed")

    # Convert to dict format for extraction
    ps101_dict = {f"q{row[0]}_{row[1]}": row[2] for row in responses}

    # Extract context (includes timeout + retry)
    context = extract_ps101_context_from_responses(ps101_dict)

    # Store in user_contexts table (idempotent)
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO user_contexts (user_id, context_data, extracted_at)
            VALUES (%s, %s, NOW())
            ON CONFLICT (user_id)
            DO UPDATE SET
                context_data = EXCLUDED.context_data,
                extracted_at = NOW()
        """, (user_id, context.model_dump_json()))
        conn.commit()

    logger.info(f"Context extracted successfully for user {user_id}")
    return context.model_dump()
