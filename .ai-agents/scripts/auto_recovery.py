#!/usr/bin/env python3
"""
MCP Auto-Recovery System
Detects failures and automatically falls back to baseline behavior
"""

import json
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, Tuple, Optional


class MCPRecovery:
    """Automatic recovery for MCP failures"""

    def __init__(self):
        self.config_dir = Path(".ai-agents/config")
        self.session_context_dir = Path(".ai-agents/session_context")
        self.fallback_docs = [
            "CLAUDE.md",
            "TROUBLESHOOTING_CHECKLIST.md",
            "SELF_DIAGNOSTIC_FRAMEWORK.md"
        ]

    def check_mcp_health(self) -> Tuple[bool, Dict[str, Any]]:
        """
        Check MCP system health

        Returns:
            (is_healthy, diagnostics)
        """

        diagnostics = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "checks": {}
        }

        # Check 1: MCP summary files exist
        required_summaries = [
            "GOVERNANCE_SUMMARY.md",
            "TROUBLESHOOTING_SUMMARY.md",
            "RETRIEVAL_TRIGGERS.md"
        ]

        summaries_ok = True
        for filename in required_summaries:
            filepath = self.session_context_dir / filename
            exists = filepath.exists()
            diagnostics["checks"][f"summary_{filename}"] = {
                "exists": exists,
                "path": str(filepath)
            }
            if not exists:
                summaries_ok = False

        # Check 2: Session log schema exists
        schema_file = self.session_context_dir / "SESSION_LOG_SCHEMA.json"
        schema_ok = schema_file.exists()
        diagnostics["checks"]["schema"] = {
            "exists": schema_ok,
            "path": str(schema_file)
        }

        # Check 3: Feature flags accessible
        flags_file = self.config_dir / "feature_flags.json"
        flags_ok = flags_file.exists()

        if flags_ok:
            try:
                with open(flags_file) as f:
                    flags = json.load(f)
                    mcp_enabled = flags.get("flags", {}).get("MCP_ENABLED", False)
                    diagnostics["checks"]["feature_flags"] = {
                        "exists": True,
                        "mcp_enabled": mcp_enabled,
                        "path": str(flags_file)
                    }
            except Exception as e:
                flags_ok = False
                diagnostics["checks"]["feature_flags"] = {
                    "exists": True,
                    "error": str(e),
                    "path": str(flags_file)
                }
        else:
            diagnostics["checks"]["feature_flags"] = {
                "exists": False,
                "path": str(flags_file)
            }

        # Check 4: Fallback docs exist
        fallback_ok = True
        for doc in self.fallback_docs:
            filepath = Path(doc)
            exists = filepath.exists()
            diagnostics["checks"][f"fallback_{doc}"] = {
                "exists": exists,
                "path": str(filepath)
            }
            if not exists:
                fallback_ok = False

        # Overall health
        is_healthy = summaries_ok and schema_ok and flags_ok and fallback_ok

        diagnostics["overall_health"] = "healthy" if is_healthy else "degraded"
        diagnostics["can_fallback"] = fallback_ok

        return (is_healthy, diagnostics)

    def attempt_recovery(self) -> Tuple[bool, str]:
        """
        Attempt to recover from MCP failure

        Returns:
            (success, message)
        """

        is_healthy, diagnostics = self.check_mcp_health()

        if is_healthy:
            return (True, "MCP system is healthy, no recovery needed")

        # Recovery strategy: Disable MCP, fallback to baseline

        flags_file = self.config_dir / "feature_flags.json"

        if not flags_file.exists():
            return (False, "Cannot recover: Feature flags file missing")

        try:
            # Read current flags
            with open(flags_file) as f:
                flags = json.load(f)

            # Disable MCP
            if "flags" not in flags:
                flags["flags"] = {}

            flags["flags"]["MCP_ENABLED"] = False
            flags["last_updated"] = datetime.utcnow().isoformat() + "Z"
            flags["notes"] = "Auto-disabled by recovery system due to MCP component failure"

            # Write updated flags
            with open(flags_file, 'w') as f:
                json.dump(flags, f, indent=2)

            return (True, "MCP disabled, system will fallback to baseline docs")

        except Exception as e:
            return (False, f"Recovery failed: {e}")

    def log_incident(self, diagnostics: Dict[str, Any], recovery_result: Tuple[bool, str]):
        """Log recovery incident"""

        incidents_dir = Path(".ai-agents/logs/incidents")
        incidents_dir.mkdir(parents=True, exist_ok=True)

        timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
        incident_file = incidents_dir / f"incident_{timestamp}.json"

        incident = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "type": "mcp_failure",
            "diagnostics": diagnostics,
            "recovery": {
                "attempted": True,
                "success": recovery_result[0],
                "message": recovery_result[1]
            }
        }

        with open(incident_file, 'w') as f:
            json.dump(incident, f, indent=2)

        return str(incident_file)

    def run_recovery_check(self) -> Dict[str, Any]:
        """Run health check and attempt recovery if needed"""

        is_healthy, diagnostics = self.check_mcp_health()

        if is_healthy:
            return {
                "status": "healthy",
                "recovery_attempted": False,
                "diagnostics": diagnostics
            }

        # Attempt recovery
        success, message = self.attempt_recovery()

        # Log incident
        incident_file = self.log_incident(diagnostics, (success, message))

        return {
            "status": "recovered" if success else "failed",
            "recovery_attempted": True,
            "recovery_success": success,
            "recovery_message": message,
            "incident_log": incident_file,
            "diagnostics": diagnostics
        }


def main():
    """CLI interface for auto-recovery"""

    print("\n" + "=" * 60)
    print("MCP AUTO-RECOVERY SYSTEM")
    print("=" * 60)

    recovery = MCPRecovery()

    # Run health check
    print("\n🔍 Running MCP health check...")
    is_healthy, diagnostics = recovery.check_mcp_health()

    print(f"\n   Overall Health: {diagnostics['overall_health'].upper()}")

    if is_healthy:
        print("\n   ✅ All MCP components healthy")
        print("\n   No recovery needed.")
        return 0

    # Show failed checks
    print("\n   ⚠️  MCP system degraded\n")
    print("   Failed checks:")
    for check_name, check_data in diagnostics["checks"].items():
        if not check_data.get("exists", True):
            print(f"      ❌ {check_name}: Missing")
        elif "error" in check_data:
            print(f"      ❌ {check_name}: {check_data['error']}")

    # Attempt recovery
    print("\n🔧 Attempting auto-recovery...")

    success, message = recovery.attempt_recovery()

    if success:
        print(f"\n   ✅ RECOVERED: {message}")

        # Log incident
        incident_file = recovery.log_incident(diagnostics, (success, message))
        print(f"   📝 Incident logged: {incident_file}")

        return 0
    else:
        print(f"\n   ❌ RECOVERY FAILED: {message}")

        # Log incident
        incident_file = recovery.log_incident(diagnostics, (success, message))
        print(f"   📝 Incident logged: {incident_file}")

        if diagnostics.get("can_fallback"):
            print("\n   ℹ️  Fallback docs available - system can still function")
            return 1
        else:
            print("\n   ❌ CRITICAL: No fallback available")
            return 2


if __name__ == "__main__":
    sys.exit(main())
