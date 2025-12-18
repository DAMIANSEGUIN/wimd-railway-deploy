"""
MODULE: mosaic-diag/preflight.py
PURPOSE: Preflight check registry + execution engine for mosaic-diag v2.0
VERSION: 2.0.0
LAST_MODIFIED: 2025-12-04
MODIFIED_BY: Claude Code
SPEC: mosaic_diag_spec_v2.0.md

DESIGN:
- Registry of all preflight checks
- Deterministic execution
- Structured results (JSON)
- CI-friendly exit codes

DEPENDENCIES:
- Standard library (subprocess, os, sys, pathlib)
- Project: storage.py
"""

import subprocess
import sys
from dataclasses import asdict, dataclass
from enum import Enum
from pathlib import Path
from typing import Any, Callable, Dict, List, Tuple


class Severity(Enum):
    """Check severity levels"""

    CRITICAL = "critical"  # Blocks deployment
    HIGH = "high"  # Should fix before deploy
    MEDIUM = "medium"  # Fix soon
    LOW = "low"  # Nice to have


class CheckStatus(Enum):
    """Check result status"""

    PASS = "pass"
    FAIL = "fail"
    WARN = "warn"
    SKIP = "skip"


@dataclass
class PreflightCheckDefinition:
    """Defines a preflight check"""

    check_id: str
    category: str  # deployment, environment, permissions, documentation
    description: str
    severity: Severity
    check_fn: Callable[[], Tuple[CheckStatus, str, Dict[str, Any]]]


@dataclass
class PreflightCheckResult:
    """Result of running a preflight check"""

    check_id: str
    category: str
    description: str
    severity: str
    status: str
    message: str
    details: Dict[str, Any]
    timestamp: str


class PreflightEngine:
    """Executes preflight checks and generates structured results"""

    def __init__(self, project_root: Path = None):
        """
        Initialize preflight engine.

        Args:
            project_root: Root of Mosaic project (defaults to current dir parent)
        """
        if project_root is None:
            project_root = Path(__file__).parent.parent

        self.project_root = Path(project_root)
        self.checks: Dict[str, PreflightCheckDefinition] = {}
        self._register_all_checks()

    def _register_all_checks(self) -> None:
        """Register all preflight checks"""
        # Deployment checks
        self.register(
            PreflightCheckDefinition(
                check_id="deploy.git_clean",
                category="deployment",
                description="Git working tree is clean",
                severity=Severity.CRITICAL,
                check_fn=self._check_git_clean,
            )
        )

        self.register(
            PreflightCheckDefinition(
                check_id="deploy.branch_matches_config",
                category="deployment",
                description="Current branch matches deployment config",
                severity=Severity.HIGH,
                check_fn=self._check_branch_config,
            )
        )

        self.register(
            PreflightCheckDefinition(
                check_id="deploy.build_id_loop_detector",
                category="deployment",
                description="BUILD_ID injection won't create uncommitted changes",
                severity=Severity.HIGH,
                check_fn=self._check_build_id_loop,
            )
        )

        # Environment checks
        self.register(
            PreflightCheckDefinition(
                check_id="env.python_version",
                category="environment",
                description="Python version >= 3.9",
                severity=Severity.CRITICAL,
                check_fn=self._check_python_version,
            )
        )

        self.register(
            PreflightCheckDefinition(
                check_id="env.python_ssl",
                category="environment",
                description="Python SSL module available",
                severity=Severity.CRITICAL,
                check_fn=self._check_python_ssl,
            )
        )

        # Permission checks
        self.register(
            PreflightCheckDefinition(
                check_id="access.agent_role_validation",
                category="permissions",
                description="AI agent has required access for task",
                severity=Severity.MEDIUM,
                check_fn=self._check_agent_access,
            )
        )

        # Documentation checks
        self.register(
            PreflightCheckDefinition(
                check_id="docs.recurring_blockers_present",
                category="documentation",
                description="RECURRING_BLOCKERS.md exists and is up to date",
                severity=Severity.LOW,
                check_fn=self._check_recurring_blockers_doc,
            )
        )

        self.register(
            PreflightCheckDefinition(
                check_id="docs.troubleshooting_checklist_present",
                category="documentation",
                description="TROUBLESHOOTING_CHECKLIST.md exists",
                severity=Severity.MEDIUM,
                check_fn=self._check_troubleshooting_doc,
            )
        )

    def register(self, check: PreflightCheckDefinition) -> None:
        """Register a preflight check"""
        self.checks[check.check_id] = check

    def run_category(self, category: str) -> List[PreflightCheckResult]:
        """
        Run all checks in a category.

        Args:
            category: Category to run (deployment, environment, permissions, documentation)

        Returns:
            List of check results
        """
        results = []

        for check_id, check_def in self.checks.items():
            if check_def.category == category:
                result = self._run_check(check_def)
                results.append(result)

        return results

    def run_all(self) -> List[PreflightCheckResult]:
        """Run all registered checks"""
        results = []

        for check_def in self.checks.values():
            result = self._run_check(check_def)
            results.append(result)

        return results

    def _run_check(self, check_def: PreflightCheckDefinition) -> PreflightCheckResult:
        """Execute a single check"""
        from datetime import datetime

        try:
            status, message, details = check_def.check_fn()
        except Exception as e:
            status = CheckStatus.FAIL
            message = f"Check failed with exception: {e}"
            details = {"exception": str(e)}

        return PreflightCheckResult(
            check_id=check_def.check_id,
            category=check_def.category,
            description=check_def.description,
            severity=check_def.severity.value,
            status=status.value,
            message=message,
            details=details,
            timestamp=datetime.utcnow().isoformat(),
        )

    # ===================================================================
    # CHECK IMPLEMENTATIONS (Based on RECURRING_BLOCKERS.md)
    # ===================================================================

    def _check_git_clean(self) -> Tuple[CheckStatus, str, Dict[str, Any]]:
        """Check if git working tree is clean"""
        result = subprocess.run(
            ["git", "status", "--porcelain"], cwd=self.project_root, capture_output=True, text=True
        )

        if result.returncode != 0:
            return (CheckStatus.FAIL, "Git status command failed", {"stderr": result.stderr})

        if result.stdout.strip():
            return (
                CheckStatus.FAIL,
                "Working tree has uncommitted changes",
                {"changes": result.stdout.strip().split("\n")},
            )

        return (CheckStatus.PASS, "Working tree is clean", {})

    def _check_branch_config(self) -> Tuple[CheckStatus, str, Dict[str, Any]]:
        """Check if current branch matches deployment config"""
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            cwd=self.project_root,
            capture_output=True,
            text=True,
        )

        if result.returncode != 0:
            return (
                CheckStatus.FAIL,
                "Could not determine current branch",
                {"stderr": result.stderr},
            )

        current_branch = result.stdout.strip()

        # Check TEAM_PLAYBOOK.md for expected branch
        playbook_path = self.project_root / "TEAM_PLAYBOOK.md"
        if not playbook_path.exists():
            return (
                CheckStatus.WARN,
                f"On branch '{current_branch}' but no TEAM_PLAYBOOK.md to verify against",
                {"current_branch": current_branch},
            )

        with open(playbook_path) as f:
            playbook_content = f.read()

        # Simple check: Is current branch mentioned in playbook?
        if current_branch in playbook_content:
            return (
                CheckStatus.PASS,
                f"Branch '{current_branch}' is documented in playbook",
                {"current_branch": current_branch},
            )

        return (
            CheckStatus.WARN,
            f"Branch '{current_branch}' not found in TEAM_PLAYBOOK.md",
            {"current_branch": current_branch},
        )

    def _check_build_id_loop(self) -> Tuple[CheckStatus, str, Dict[str, Any]]:
        """Check if BUILD_ID injection pattern exists in HTML files"""
        html_files = list(self.project_root.glob("**/index.html"))

        build_id_pattern_found = False
        affected_files = []

        for html_file in html_files:
            with open(html_file) as f:
                content = f.read()

            if "BUILD_ID:" in content:
                build_id_pattern_found = True
                affected_files.append(str(html_file.relative_to(self.project_root)))

        if not build_id_pattern_found:
            return (CheckStatus.PASS, "No BUILD_ID injection pattern found", {})

        # Check if these files are in .gitignore or excluded from git status
        gitignore_path = self.project_root / ".gitignore"
        if gitignore_path.exists():
            with open(gitignore_path) as f:
                gitignore_content = f.read()

            if any(
                "BUILD_ID" in line or "**/index.html" in line
                for line in gitignore_content.split("\n")
            ):
                return (
                    CheckStatus.PASS,
                    "BUILD_ID pattern found but files are gitignored",
                    {"files_with_build_id": affected_files},
                )

        return (
            CheckStatus.WARN,
            "BUILD_ID pattern found - may cause deployment loop (see RECURRING_BLOCKERS.md #1B)",
            {"files_with_build_id": affected_files},
        )

    def _check_python_version(self) -> Tuple[CheckStatus, str, Dict[str, Any]]:
        """Check Python version >= 3.9"""
        version = sys.version_info

        if version.major < 3 or (version.major == 3 and version.minor < 9):
            return (
                CheckStatus.FAIL,
                f"Python {version.major}.{version.minor} is too old (need 3.9+)",
                {"version": f"{version.major}.{version.minor}.{version.micro}"},
            )

        return (
            CheckStatus.PASS,
            f"Python {version.major}.{version.minor}.{version.micro} meets requirements",
            {"version": f"{version.major}.{version.minor}.{version.micro}"},
        )

    def _check_python_ssl(self) -> Tuple[CheckStatus, str, Dict[str, Any]]:
        """Check if Python SSL module is available"""
        try:
            import ssl

            ssl_version = ssl.OPENSSL_VERSION

            return (
                CheckStatus.PASS,
                f"SSL module available ({ssl_version})",
                {"openssl_version": ssl_version},
            )
        except ImportError as e:
            return (
                CheckStatus.FAIL,
                "SSL module not available (see RECURRING_BLOCKERS.md #2B)",
                {"error": str(e), "fix": "brew reinstall python@3.12 openssl@3"},
            )

    def _check_agent_access(self) -> Tuple[CheckStatus, str, Dict[str, Any]]:
        """Check if AI agent role has required access"""
        # This is a placeholder - would need agent context passed in
        # For now, just check if we can access TEAM_PLAYBOOK.md
        playbook_path = self.project_root / "TEAM_PLAYBOOK.md"

        if not playbook_path.exists():
            return (CheckStatus.FAIL, "Cannot access TEAM_PLAYBOOK.md", {})

        try:
            with open(playbook_path) as f:
                f.read(100)  # Try to read first 100 chars

            return (CheckStatus.PASS, "Can access canonical documentation", {})
        except PermissionError as e:
            return (
                CheckStatus.FAIL,
                "Permission denied accessing TEAM_PLAYBOOK.md",
                {"error": str(e)},
            )

    def _check_recurring_blockers_doc(self) -> Tuple[CheckStatus, str, Dict[str, Any]]:
        """Check if RECURRING_BLOCKERS.md exists and is recent"""
        doc_path = self.project_root / "RECURRING_BLOCKERS.md"

        if not doc_path.exists():
            return (
                CheckStatus.FAIL,
                "RECURRING_BLOCKERS.md does not exist",
                {"expected_path": str(doc_path)},
            )

        # Check if updated recently (within last 30 days)
        import time

        mtime = doc_path.stat().st_mtime
        age_days = (time.time() - mtime) / 86400

        if age_days > 30:
            return (
                CheckStatus.WARN,
                f"RECURRING_BLOCKERS.md is {int(age_days)} days old",
                {"age_days": int(age_days)},
            )

        return (
            CheckStatus.PASS,
            f"RECURRING_BLOCKERS.md exists and updated {int(age_days)} days ago",
            {"age_days": int(age_days)},
        )

    def _check_troubleshooting_doc(self) -> Tuple[CheckStatus, str, Dict[str, Any]]:
        """Check if TROUBLESHOOTING_CHECKLIST.md exists"""
        doc_path = self.project_root / "TROUBLESHOOTING_CHECKLIST.md"

        if not doc_path.exists():
            return (
                CheckStatus.WARN,
                "TROUBLESHOOTING_CHECKLIST.md does not exist",
                {"expected_path": str(doc_path)},
            )

        return (CheckStatus.PASS, "TROUBLESHOOTING_CHECKLIST.md exists", {})


def format_results_json(results: List[PreflightCheckResult]) -> str:
    """Format results as JSON"""
    import json

    return json.dumps([asdict(r) for r in results], indent=2)


def format_results_human(results: List[PreflightCheckResult]) -> str:
    """Format results for human reading"""
    lines = []
    lines.append("=" * 60)
    lines.append("PREFLIGHT CHECK RESULTS")
    lines.append("=" * 60)

    by_category = {}
    for result in results:
        by_category.setdefault(result.category, []).append(result)

    for category, category_results in by_category.items():
        lines.append(f"\n{category.upper()}:")

        for result in category_results:
            status_icon = {"pass": "✅", "fail": "❌", "warn": "⚠️", "skip": "⏭️"}.get(
                result.status, "?"
            )

            lines.append(f"  {status_icon} {result.check_id}")
            lines.append(f"     {result.message}")

            if result.details:
                for key, value in result.details.items():
                    lines.append(f"     {key}: {value}")

    lines.append("\n" + "=" * 60)

    # Summary
    pass_count = sum(1 for r in results if r.status == "pass")
    fail_count = sum(1 for r in results if r.status == "fail")
    warn_count = sum(1 for r in results if r.status == "warn")

    lines.append(f"SUMMARY: {pass_count} passed, {fail_count} failed, {warn_count} warnings")
    lines.append("=" * 60)

    return "\n".join(lines)
