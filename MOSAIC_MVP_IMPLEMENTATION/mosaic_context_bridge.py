"""
Mosaic Context Bridge
=====================
Two functions that transform PS101 responses into context-aware coaching.

1. extract_ps101_context() - Runs once after PS101 completion
2. build_coaching_system_prompt() - Runs on every chat initialization

This IS the CoachingBridge. It's system prompt injection, not a separate module.

Usage:
    # After PS101 completion:
    context = extract_ps101_context(user_ps101_responses)
    save_to_database(user_id, context)
    
    # On every chat:
    system_prompt = build_coaching_system_prompt(user_context)
    # Pass system_prompt to Claude API call
"""

import anthropic
import json
from typing import Dict, List, Optional


def extract_ps101_context(ps101_responses: Dict[str, str]) -> Dict:
    """
    Transform raw PS101 responses into structured coaching context.
    
    Args:
        ps101_responses: Dict with question numbers/names as keys, user answers as values
        Example: {"q1": "I feel stuck in my current role...", "q2": "...", ...}
    
    Returns:
        Structured context dict for coaching injection:
        {
            "problem_definition": str,
            "passions": List[str],
            "skills": List[str],
            "secret_powers": List[str],
            "proposed_experiments": List[{"idea": str, "smallest_version": str}],
            "internal_obstacles": List[str],
            "external_obstacles": List[str],
            "key_quotes": List[str]
        }
    """
    
    client = anthropic.Anthropic()
    
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

    message = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1500,
        messages=[
            {"role": "user", "content": extraction_prompt}
        ]
    )
    
    # Parse JSON from response
    response_text = message.content[0].text
    
    # Handle potential markdown code blocks
    if "```json" in response_text:
        response_text = response_text.split("```json")[1].split("```")[0]
    elif "```" in response_text:
        response_text = response_text.split("```")[1].split("```")[0]
    
    return json.loads(response_text.strip())


def build_coaching_system_prompt(user_context: Dict) -> str:
    """
    Build the system prompt for context-aware coaching.
    
    Args:
        user_context: The structured context from extract_ps101_context()
    
    Returns:
        System prompt string to pass to Claude API
    """
    
    # Handle empty or missing context gracefully
    if not user_context:
        return _get_fallback_prompt()
    
    # Format experiments list
    experiments_formatted = ""
    for exp in user_context.get('proposed_experiments', []):
        idea = exp.get('idea', 'Unnamed experiment')
        smallest = exp.get('smallest_version', 'Not defined')
        experiments_formatted += f"- {idea} (smallest test: {smallest})\n"
    
    # Format key quotes
    quotes_formatted = ""
    for quote in user_context.get('key_quotes', []):
        quotes_formatted += f'"{quote}"\n'
    
    return f"""You are a career coach with deep knowledge of this specific person. They completed structured self-reflection and here's what they discovered:

PROBLEM THEY'RE SOLVING:
{user_context.get('problem_definition', 'Not yet defined')}

WHAT ENERGIZES THEM:
{', '.join(user_context.get('passions', [])) or 'Still exploring'}

SKILLS THEY BRING:
{', '.join(user_context.get('skills', [])) or 'Still identifying'}

SECRET POWERS (strengths they may undervalue):
{', '.join(user_context.get('secret_powers', [])) or 'Still uncovering'}

EXPERIMENTS THEY'RE CONSIDERING:
{experiments_formatted or 'None yet'}

INTERNAL OBSTACLES (fears, mindset):
{', '.join(user_context.get('internal_obstacles', [])) or 'None identified'}

EXTERNAL OBSTACLES (practical constraints):
{', '.join(user_context.get('external_obstacles', [])) or 'None identified'}

THEIR WORDS WORTH REFLECTING BACK:
{quotes_formatted or 'None captured'}

---

COACHING APPROACH:
- Reference their SPECIFIC situation, not generic advice
- When they mention a challenge, connect it to their identified obstacles
- When suggesting action, build on their proposed experiments
- Mirror their language back—use phrases from "key_quotes" naturally
- Help them design SMALL experiments, not big pivots
- You're a witness and mirror, not an advice dispenser
- If they're stuck, ask what their secret powers suggest about a path forward

Never say "based on what you shared" or "from your reflection"—just know it and use it naturally, like a coach who's been working with them for months."""


def _get_fallback_prompt() -> str:
    """Fallback prompt when no context is available (pre-PS101 users)."""
    return """You are a career coach helping someone explore their next steps.

Since they haven't completed the foundational reflection yet, your role is to:
- Help them articulate what they're trying to solve
- Ask about what energizes them
- Explore their skills and hidden strengths
- Encourage small experiments over big decisions
- Be curious, not prescriptive

Guide them toward completing the PS101 reflection for deeper, personalized coaching."""


# =============================================================================
# FASTAPI INTEGRATION EXAMPLE
# =============================================================================

"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List

router = APIRouter()

class ChatMessage(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    user_id: str
    messages: List[ChatMessage]


@router.post("/api/extract-context/{user_id}")
async def extract_context_endpoint(user_id: str, db: Session = Depends(get_db)):
    '''
    Call this once when user completes PS101.
    Extracts structured context and stores it.
    '''
    # Fetch PS101 responses from your database
    ps101 = db.query(PS101Response).filter_by(user_id=user_id).first()
    
    if not ps101:
        raise HTTPException(status_code=404, detail="PS101 not completed")
    
    # Extract structured context
    context = extract_ps101_context(ps101.responses)
    
    # Store it (assuming JSON field on user model)
    user = db.query(User).filter_by(id=user_id).first()
    user.coaching_context = context
    db.commit()
    
    return {"status": "extracted", "context": context}


@router.post("/api/chat")
async def coaching_chat_endpoint(request: ChatRequest, db: Session = Depends(get_db)):
    '''
    Chat endpoint with context injection.
    '''
    user = db.query(User).filter_by(id=request.user_id).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Build context-aware system prompt
    system_prompt = build_coaching_system_prompt(user.coaching_context or {})
    
    # Call Claude with context
    client = anthropic.Anthropic()
    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1000,
        system=system_prompt,
        messages=[{"role": m.role, "content": m.content} for m in request.messages]
    )
    
    return {"response": response.content[0].text}
"""


# =============================================================================
# TESTING
# =============================================================================

if __name__ == "__main__":
    # Test with sample PS101 responses
    sample_ps101 = {
        "q1": "I've been working in museum exhibition installation for 25 years but I feel like there's something more I should be doing with my skills.",
        "q2": "I love solving complex spatial problems and I get energized when I'm teaching others or facilitating workshops.",
        "q3": "People tell me I'm good at seeing the big picture while handling details. I can calm tense situations.",
        "q4": "I want to explore AI and technology but I'm scared I'm too old to learn new things.",
        "q5": "My main constraint is financial - I need income stability while transitioning.",
        "q6": "I could try offering facilitation workshops or exploring how AI could help career transitions.",
        "q7": "I sometimes doubt whether my museum skills transfer to other fields.",
        "q8": "I'm passionate about helping people find their path, especially mid-career professionals.",
        "q9": "My secret power might be combining physical/spatial thinking with people skills.",
        "q10": "I want to build something that helps others navigate career change using AI."
    }
    
    print("Extracting context from sample PS101...")
    context = extract_ps101_context(sample_ps101)
    print("\nExtracted Context:")
    print(json.dumps(context, indent=2))
    
    print("\n" + "="*50)
    print("Generated Coaching System Prompt:")
    print("="*50)
    print(build_coaching_system_prompt(context))
