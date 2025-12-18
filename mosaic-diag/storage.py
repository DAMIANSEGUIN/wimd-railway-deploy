"""
MODULE: mosaic-diag/storage.py
PURPOSE: File IO + transactional writes for mosaic-diag v2.0
VERSION: 2.0.0
LAST_MODIFIED: 2025-12-04
MODIFIED_BY: Claude Code
SPEC: mosaic_diag_spec_v2.0.md

DESIGN:
- Atomic writes (write to temp, rename)
- JSONL for incidents (append-only)
- JSON for structured data (roadmap, suggestions)
- No external network calls
- Deterministic behavior

DEPENDENCIES:
- Standard library only (json, pathlib, tempfile)
"""

import json
import tempfile
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List


class Storage:
    """Atomic file storage for mosaic-diag"""

    def __init__(self, base_dir: Path = None):
        """
        Initialize storage manager.

        Args:
            base_dir: Base directory for diagnostics (defaults to ./mosaic-diag/diagnostics)
        """
        if base_dir is None:
            base_dir = Path(__file__).parent / "diagnostics"

        self.base_dir = Path(base_dir)
        self.base_dir.mkdir(parents=True, exist_ok=True)

        # File paths
        self.incidents_file = self.base_dir / "incidents.jsonl"
        self.roadmap_file = self.base_dir / "roadmap.json"
        self.check_suggestions_file = self.base_dir / "check_suggestions.json"
        self.doc_suggestions_file = self.base_dir / "doc_suggestions.json"
        self.roadmap_suggestions_file = self.base_dir / "roadmap_suggestions.json"

    def append_incident(self, incident: Dict[str, Any]) -> None:
        """
        Append incident to JSONL file (atomic).

        Args:
            incident: Incident record dict
        """
        # Add timestamp if not present
        if "timestamp" not in incident:
            incident["timestamp"] = datetime.utcnow().isoformat()

        # Atomic append
        with open(self.incidents_file, "a") as f:
            f.write(json.dumps(incident) + "\n")

    def read_incidents(self) -> List[Dict[str, Any]]:
        """
        Read all incidents from JSONL file.

        Returns:
            List of incident dicts
        """
        if not self.incidents_file.exists():
            return []

        incidents = []
        with open(self.incidents_file) as f:
            for line in f:
                line = line.strip()
                if line:
                    incidents.append(json.loads(line))

        return incidents

    def write_json(self, filepath: Path, data: Any) -> None:
        """
        Atomically write JSON to file (write to temp, rename).

        Args:
            filepath: Target file path
            data: Data to serialize
        """
        # Write to temp file first
        with tempfile.NamedTemporaryFile(
            mode="w", dir=self.base_dir, delete=False, suffix=".tmp"
        ) as tmp:
            json.dump(data, tmp, indent=2, sort_keys=True)
            tmp_path = tmp.name

        # Atomic rename
        Path(tmp_path).replace(filepath)

    def read_json(self, filepath: Path, default: Any = None) -> Any:
        """
        Read JSON from file.

        Args:
            filepath: Source file path
            default: Default value if file doesn't exist

        Returns:
            Parsed JSON or default
        """
        if not filepath.exists():
            return default if default is not None else {}

        with open(filepath) as f:
            return json.load(f)

    def read_roadmap(self) -> Dict[str, Any]:
        """Read roadmap.json"""
        return self.read_json(
            self.roadmap_file,
            default={
                "version": "2.0",
                "last_updated": datetime.utcnow().isoformat(),
                "future_issues": [],
            },
        )

    def write_roadmap(self, roadmap: Dict[str, Any]) -> None:
        """Write roadmap.json atomically"""
        roadmap["last_updated"] = datetime.utcnow().isoformat()
        self.write_json(self.roadmap_file, roadmap)

    def read_suggestions(self, suggestion_type: str) -> List[Dict[str, Any]]:
        """
        Read suggestions by type.

        Args:
            suggestion_type: "check", "doc", or "roadmap"

        Returns:
            List of suggestion dicts
        """
        filepath_map = {
            "check": self.check_suggestions_file,
            "doc": self.doc_suggestions_file,
            "roadmap": self.roadmap_suggestions_file,
        }

        filepath = filepath_map.get(suggestion_type)
        if not filepath:
            raise ValueError(f"Unknown suggestion type: {suggestion_type}")

        return self.read_json(filepath, default=[])

    def write_suggestions(self, suggestion_type: str, suggestions: List[Dict[str, Any]]) -> None:
        """
        Write suggestions by type atomically.

        Args:
            suggestion_type: "check", "doc", or "roadmap"
            suggestions: List of suggestion dicts
        """
        filepath_map = {
            "check": self.check_suggestions_file,
            "doc": self.doc_suggestions_file,
            "roadmap": self.roadmap_suggestions_file,
        }

        filepath = filepath_map.get(suggestion_type)
        if not filepath:
            raise ValueError(f"Unknown suggestion type: {suggestion_type}")

        self.write_json(filepath, suggestions)
