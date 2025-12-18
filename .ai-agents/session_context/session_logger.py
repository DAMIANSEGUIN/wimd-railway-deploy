#!/usr/bin/env python3
"""
MCP Session Logger
Append-only structured logging for agent sessions
"""

import json
import uuid
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import jsonschema


class SessionLogger:
    """Append-only session event logger with schema validation"""

    def __init__(self, sessions_dir: Path = Path(".ai-agents/sessions")):
        self.sessions_dir = sessions_dir
        self.sessions_dir.mkdir(parents=True, exist_ok=True)

        # Load schema
        schema_path = Path(".ai-agents/session_context/SESSION_LOG_SCHEMA.json")
        with open(schema_path) as f:
            self.schema = json.load(f)

    def _generate_event_id(self) -> str:
        """Generate unique event ID"""
        return f"evt_{uuid.uuid4().hex[:8]}"

    def _validate_event(self, event: Dict[str, Any]) -> Tuple[bool, Optional[str]]:
        """
        Validate event against schema

        Returns:
            (is_valid, error_message)
        """
        try:
            jsonschema.validate(event, self.schema)
            return (True, None)
        except jsonschema.exceptions.ValidationError as e:
            return (False, str(e))

    def append_event(
        self,
        session_id: str,
        event_type: str,
        agent: str,
        source: str,
        data: Optional[Dict] = None,
        causal_steps: Optional[List[Dict]] = None,
        active_constraints: Optional[List[Dict]] = None,
        failure_ledger: Optional[List[Dict]] = None,
        open_commitments: Optional[List[Dict]] = None,
        key_entities: Optional[Dict] = None,
        dependencies: Optional[Dict] = None,
        confidence: float = 1.0,
    ) -> Tuple[bool, Optional[str]]:
        """
        Append event to session log

        Args:
            session_id: Unique session identifier
            event_type: Type of event (user_message, tool_call, etc.)
            agent: Agent creating this event
            source: Source of information
            data: Event-specific data
            causal_steps: Decision reasoning
            active_constraints: Governance rules in effect
            failure_ledger: Failed attempts
            open_commitments: Pending promises
            key_entities: Entity mappings
            dependencies: Event dependencies
            confidence: Confidence in information (0-1)

        Returns:
            (success, error_message)
        """

        # Build event
        event = {
            "event_id": self._generate_event_id(),
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "event_type": event_type,
            "provenance": {"source": source, "agent": agent, "confidence": confidence},
        }

        # Add optional fields
        if causal_steps:
            event["causal_steps"] = causal_steps
        if active_constraints:
            event["active_constraints"] = active_constraints
        if failure_ledger:
            event["failure_ledger"] = failure_ledger
        if open_commitments:
            event["open_commitments"] = open_commitments
        if key_entities:
            event["key_entities"] = key_entities
        if dependencies:
            event["dependencies"] = dependencies
        if data:
            event["data"] = data

        # Validate
        is_valid, error = self._validate_event(event)
        if not is_valid:
            return (False, f"Validation failed: {error}")

        # Write to log (append-only)
        log_file = self.sessions_dir / f"{session_id}.jsonl"
        try:
            with open(log_file, "a") as f:
                f.write(json.dumps(event) + "\n")
            return (True, None)
        except Exception as e:
            return (False, f"Write failed: {e}")

    def read_session(self, session_id: str) -> List[Dict[str, Any]]:
        """
        Read all events from a session log

        Args:
            session_id: Session to read

        Returns:
            List of events in chronological order
        """
        log_file = self.sessions_dir / f"{session_id}.jsonl"

        if not log_file.exists():
            return []

        events = []
        with open(log_file) as f:
            for line in f:
                if line.strip():
                    events.append(json.loads(line))

        return events

    def query_events(
        self,
        session_id: str,
        event_type: Optional[str] = None,
        agent: Optional[str] = None,
        after_timestamp: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """
        Query events with filters

        Args:
            session_id: Session to query
            event_type: Filter by event type
            agent: Filter by agent
            after_timestamp: Only events after this timestamp

        Returns:
            Filtered list of events
        """
        events = self.read_session(session_id)

        filtered = events

        if event_type:
            filtered = [e for e in filtered if e.get("event_type") == event_type]

        if agent:
            filtered = [e for e in filtered if e.get("provenance", {}).get("agent") == agent]

        if after_timestamp:
            filtered = [e for e in filtered if e.get("timestamp", "") > after_timestamp]

        return filtered

    def get_open_commitments(self, session_id: str) -> List[Dict]:
        """Get all open commitments from session"""
        events = self.read_session(session_id)

        all_commitments = []
        for event in events:
            if "open_commitments" in event:
                for commitment in event["open_commitments"]:
                    if commitment.get("status") != "completed":
                        all_commitments.append(commitment)

        return all_commitments

    def get_failure_history(self, session_id: str) -> List[Dict]:
        """Get all failures from session"""
        events = self.read_session(session_id)

        all_failures = []
        for event in events:
            if "failure_ledger" in event:
                all_failures.extend(event["failure_ledger"])

        return all_failures


def main():
    """Test the session logger"""
    logger = SessionLogger()

    session_id = "test_session_001"

    # Test event 1: User message
    success, error = logger.append_event(
        session_id=session_id,
        event_type="user_message",
        agent="user",
        source="terminal",
        data={"message": "Deploy to production"},
        causal_steps=[{"step": "Parse user request", "reasoning": "User wants deployment action"}],
    )
    print(f"Event 1: {'✅ Success' if success else f'❌ Failed - {error}'}")

    # Test event 2: Tool call
    success, error = logger.append_event(
        session_id=session_id,
        event_type="tool_call",
        agent="claude_code",
        source="./scripts/deploy.sh",
        data={"tool": "bash", "command": "./scripts/deploy.sh railway"},
        active_constraints=[
            {
                "constraint": "Use wrapper scripts for deployment",
                "source": "CLAUDE.md",
                "priority": "mandatory",
            }
        ],
    )
    print(f"Event 2: {'✅ Success' if success else f'❌ Failed - {error}'}")

    # Test event 3: Error with failure ledger
    success, error = logger.append_event(
        session_id=session_id,
        event_type="error",
        agent="claude_code",
        source="railway_api",
        data={"error_code": "500", "message": "Internal server error"},
        failure_ledger=[
            {
                "attempt": "Direct git push to railway",
                "failure_reason": "Permission denied",
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "error_code": "403",
            }
        ],
        open_commitments=[
            {
                "commitment": "Deploy to production",
                "status": "blocked",
                "dependencies": ["Fix railway authentication"],
            }
        ],
    )
    print(f"Event 3: {'✅ Success' if success else f'❌ Failed - {error}'}")

    # Read back events
    print(f"\n📋 Total events logged: {len(logger.read_session(session_id))}")

    # Query examples
    errors = logger.query_events(session_id, event_type="error")
    print(f"❌ Errors: {len(errors)}")

    commitments = logger.get_open_commitments(session_id)
    print(f"📝 Open commitments: {len(commitments)}")

    failures = logger.get_failure_history(session_id)
    print(f"⚠️  Failures: {len(failures)}")

    print("\n✅ Session logger test complete")


if __name__ == "__main__":
    main()
