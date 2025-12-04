"""
MODULE: mosaic-diag/incidents.py
PURPOSE: Incident logging, parsing, and classification for mosaic-diag v2.0
VERSION: 2.0.0
LAST_MODIFIED: 2025-12-04
MODIFIED_BY: Claude Code
SPEC: mosaic_diag_spec_v2.0.md

DESIGN:
- Structured incident records
- Rule-based classification
- Integration with RECURRING_BLOCKERS.md patterns

DEPENDENCIES:
- Standard library
- Project: storage.py, classifiers.py
"""

from dataclasses import dataclass, asdict
from typing import Dict, List, Any, Optional
from datetime import datetime
from enum import Enum


class IncidentCategory(Enum):
    """Incident categories (from RECURRING_BLOCKERS.md)"""
    DEPLOYMENT = "deployment"
    ENVIRONMENT = "environment"
    PERMISSIONS = "permissions"
    DOCUMENTATION = "documentation"
    UNKNOWN = "unknown"


class IncidentSeverity(Enum):
    """Incident severity levels"""
    CRITICAL = "critical"  # Blocks all work
    HIGH = "high"          # Blocks current task
    MEDIUM = "medium"      # Workaround exists
    LOW = "low"            # Annoying but not blocking


@dataclass
class IncidentRecord:
    """
    Structured incident record.

    Maps to RECURRING_BLOCKERS.md structure.
    """
    incident_id: str
    timestamp: str
    category: str
    severity: str
    symptom: str
    root_cause: Optional[str]
    context: Dict[str, Any]
    linked_docs: List[str]
    linked_checks: List[str]
    resolution: Optional[str]
    prevention_added: bool


class IncidentLogger:
    """Logs and manages incidents"""

    def __init__(self, storage):
        """
        Initialize incident logger.

        Args:
            storage: Storage instance
        """
        self.storage = storage

    def log_incident(
        self,
        category: IncidentCategory,
        severity: IncidentSeverity,
        symptom: str,
        root_cause: Optional[str] = None,
        context: Optional[Dict[str, Any]] = None,
        resolution: Optional[str] = None
    ) -> IncidentRecord:
        """
        Log a new incident.

        Args:
            category: Incident category
            severity: Severity level
            symptom: Description of what happened
            root_cause: Why it happened (if known)
            context: Additional context dict
            resolution: How it was resolved (if resolved)

        Returns:
            IncidentRecord
        """
        from uuid import uuid4

        incident = IncidentRecord(
            incident_id=str(uuid4())[:8],
            timestamp=datetime.utcnow().isoformat(),
            category=category.value,
            severity=severity.value,
            symptom=symptom,
            root_cause=root_cause,
            context=context or {},
            linked_docs=[],
            linked_checks=[],
            resolution=resolution,
            prevention_added=False
        )

        # Save to storage
        self.storage.append_incident(asdict(incident))

        return incident

    def list_incidents(
        self,
        category: Optional[str] = None,
        severity: Optional[str] = None,
        limit: Optional[int] = None
    ) -> List[Dict[str, Any]]:
        """
        List incidents with optional filters.

        Args:
            category: Filter by category
            severity: Filter by severity
            limit: Maximum number to return

        Returns:
            List of incident dicts
        """
        incidents = self.storage.read_incidents()

        # Apply filters
        if category:
            incidents = [i for i in incidents if i.get("category") == category]

        if severity:
            incidents = [i for i in incidents if i.get("severity") == severity]

        # Sort by timestamp (most recent first)
        incidents.sort(key=lambda i: i.get("timestamp", ""), reverse=True)

        # Apply limit
        if limit:
            incidents = incidents[:limit]

        return incidents

    def get_recurrence_count(self, symptom_pattern: str) -> int:
        """
        Count how many times a symptom pattern has occurred.

        Args:
            symptom_pattern: Substring to search for in symptoms

        Returns:
            Count of matching incidents
        """
        incidents = self.storage.read_incidents()
        return sum(
            1 for i in incidents
            if symptom_pattern.lower() in i.get("symptom", "").lower()
        )

    def mark_prevention_added(self, incident_id: str) -> None:
        """
        Mark an incident as having prevention added.

        NOTE: This requires rewriting the entire JSONL file since
        incidents are append-only. For v2.0, we'll accept this limitation.

        Args:
            incident_id: Incident to update
        """
        incidents = self.storage.read_incidents()

        updated = False
        for incident in incidents:
            if incident.get("incident_id") == incident_id:
                incident["prevention_added"] = True
                updated = True

        if updated:
            # Rewrite entire file (atomic)
            import tempfile
            with tempfile.NamedTemporaryFile(
                mode="w",
                dir=self.storage.base_dir,
                delete=False,
                suffix=".jsonl"
            ) as tmp:
                for incident in incidents:
                    import json
                    tmp.write(json.dumps(incident) + "\n")
                tmp_path = tmp.name

            # Atomic replace
            from pathlib import Path
            Path(tmp_path).replace(self.storage.incidents_file)


def format_incidents_human(incidents: List[Dict[str, Any]]) -> str:
    """Format incidents for human reading"""
    lines = []
    lines.append("=" * 60)
    lines.append(f"INCIDENT LOG ({len(incidents)} total)")
    lines.append("=" * 60)

    for incident in incidents:
        severity_icon = {
            "critical": "🔴",
            "high": "🟠",
            "medium": "🟡",
            "low": "🟢"
        }.get(incident.get("severity", ""), "⚪")

        lines.append(f"\n{severity_icon} [{incident.get('incident_id')}] {incident.get('category', 'unknown').upper()}")
        lines.append(f"   Timestamp: {incident.get('timestamp', 'unknown')}")
        lines.append(f"   Symptom: {incident.get('symptom', 'none')}")

        if incident.get("root_cause"):
            lines.append(f"   Root Cause: {incident['root_cause']}")

        if incident.get("resolution"):
            lines.append(f"   Resolution: {incident['resolution']}")

        if incident.get("prevention_added"):
            lines.append("   ✅ Prevention Added")

        if incident.get("linked_docs"):
            lines.append(f"   Docs: {', '.join(incident['linked_docs'])}")

    lines.append("\n" + "=" * 60)
    return "\n".join(lines)
