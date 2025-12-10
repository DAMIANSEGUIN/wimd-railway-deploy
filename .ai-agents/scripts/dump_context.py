#!/usr/bin/env python3
"""
MCP Debug Context Dumper
Provides /debug dump-context command for observability
"""

import json
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, List


def get_session_context_size() -> Dict[str, Any]:
    """Calculate current session context size"""
    context_dir = Path(".ai-agents/session_context")

    sizes = {}
    total_size = 0

    if context_dir.exists():
        for file in context_dir.glob("*.md"):
            size = file.stat().st_size
            sizes[file.name] = {
                "size_bytes": size,
                "size_kb": round(size / 1024, 2)
            }
            total_size += size

        for file in context_dir.glob("*.json"):
            size = file.stat().st_size
            sizes[file.name] = {
                "size_bytes": size,
                "size_kb": round(size / 1024, 2)
            }
            total_size += size

    return {
        "files": sizes,
        "total_bytes": total_size,
        "total_kb": round(total_size / 1024, 2)
    }


def get_baseline_context_size() -> Dict[str, Any]:
    """Get baseline (full docs) context size"""
    baseline_files = [
        "CLAUDE.md",
        "TROUBLESHOOTING_CHECKLIST.md",
        "SELF_DIAGNOSTIC_FRAMEWORK.md",
        "docs/README.md"
    ]

    sizes = {}
    total_size = 0

    for filepath in baseline_files:
        path = Path(filepath)
        if path.exists():
            size = path.stat().st_size
            sizes[filepath] = {
                "size_bytes": size,
                "size_kb": round(size / 1024, 2)
            }
            total_size += size

    return {
        "files": sizes,
        "total_bytes": total_size,
        "total_kb": round(total_size / 1024, 2)
    }


def get_active_sessions() -> List[Dict[str, Any]]:
    """List all active session logs"""
    sessions_dir = Path(".ai-agents/sessions")

    if not sessions_dir.exists():
        return []

    sessions = []
    for log_file in sessions_dir.glob("*.jsonl"):
        size = log_file.stat().st_size
        event_count = sum(1 for _ in open(log_file) if _.strip())

        sessions.append({
            "session_id": log_file.stem,
            "size_bytes": size,
            "size_kb": round(size / 1024, 2),
            "event_count": event_count,
            "last_modified": datetime.fromtimestamp(log_file.stat().st_mtime).isoformat()
        })

    return sessions


def get_completion_gates() -> Dict[str, Any]:
    """List all completion gates"""
    status_dir = Path(".ai-agents/status")

    if not status_dir.exists():
        return {"gates": [], "total": 0}

    gates = []
    for gate_file in status_dir.glob("*.complete"):
        try:
            with open(gate_file) as f:
                gate_data = json.load(f)
                gates.append({
                    "file": gate_file.name,
                    "task": gate_data.get("task"),
                    "agent": gate_data.get("agent"),
                    "completed": gate_data.get("completed_at")
                })
        except:
            gates.append({
                "file": gate_file.name,
                "task": gate_file.stem,
                "agent": "unknown",
                "completed": "unknown"
            })

    return {
        "gates": gates,
        "total": len(gates)
    }


def get_feature_flags() -> Dict[str, Any]:
    """Read current feature flag state"""
    flags_file = Path(".ai-agents/config/feature_flags.json")

    if not flags_file.exists():
        return {"error": "Feature flags file not found"}

    try:
        with open(flags_file) as f:
            return json.load(f)
    except Exception as e:
        return {"error": f"Failed to read flags: {e}"}


def calculate_context_reduction() -> Dict[str, Any]:
    """Calculate context size reduction percentage"""
    baseline = get_baseline_context_size()
    current = get_session_context_size()

    baseline_kb = baseline["total_kb"]
    current_kb = current["total_kb"]

    if baseline_kb == 0:
        return {"error": "No baseline data"}

    reduction_kb = baseline_kb - current_kb
    reduction_percent = (reduction_kb / baseline_kb) * 100

    return {
        "baseline_kb": baseline_kb,
        "current_kb": current_kb,
        "reduction_kb": round(reduction_kb, 2),
        "reduction_percent": round(reduction_percent, 2)
    }


def dump_full_context(output_format: str = "json") -> str:
    """Dump complete MCP context state"""

    context = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "mcp_version": "v1.1",

        "context_sizes": {
            "baseline": get_baseline_context_size(),
            "session": get_session_context_size(),
            "reduction": calculate_context_reduction()
        },

        "sessions": {
            "active": get_active_sessions(),
            "total_active": len(get_active_sessions())
        },

        "gates": get_completion_gates(),

        "feature_flags": get_feature_flags(),

        "directories": {
            "session_context": str(Path(".ai-agents/session_context").exists()),
            "sessions": str(Path(".ai-agents/sessions").exists()),
            "status": str(Path(".ai-agents/status").exists()),
            "templates": str(Path(".ai-agents/templates").exists()),
            "validation": str(Path(".ai-agents/validation").exists())
        }
    }

    if output_format == "json":
        return json.dumps(context, indent=2)

    elif output_format == "summary":
        baseline_kb = context["context_sizes"]["baseline"]["total_kb"]
        session_kb = context["context_sizes"]["session"]["total_kb"]
        reduction = context["context_sizes"]["reduction"]

        summary = f"""
╔════════════════════════════════════════════════════════════╗
║  MCP v1.1 Context Status                                   ║
╚════════════════════════════════════════════════════════════╝

📊 CONTEXT SIZE:
   Baseline:  {baseline_kb} KB (full governance docs)
   Current:   {session_kb} KB (MCP summaries)
   Reduction: {reduction.get('reduction_kb', 0)} KB ({reduction.get('reduction_percent', 0)}%)

📝 SESSIONS:
   Active: {context['sessions']['total_active']} session logs
   Total Events: {sum(s['event_count'] for s in context['sessions']['active'])}

✅ COMPLETION GATES:
   Total: {context['gates']['total']} tasks complete

🚩 FEATURE FLAGS:
"""
        for flag, value in context["feature_flags"].items():
            status = "✅ ENABLED" if value else "⏸️  DISABLED"
            summary += f"   {flag}: {status}\n"

        return summary

    return "Invalid format. Use 'json' or 'summary'."


def main():
    """CLI interface for debug dump-context"""

    if len(sys.argv) < 2:
        print("Usage: python3 dump_context.py [json|summary]")
        print("\nExamples:")
        print("  python3 dump_context.py summary   # Human-readable summary")
        print("  python3 dump_context.py json      # Full JSON dump")
        sys.exit(1)

    output_format = sys.argv[1].lower()

    if output_format not in ["json", "summary"]:
        print(f"Error: Invalid format '{output_format}'. Use 'json' or 'summary'.")
        sys.exit(1)

    output = dump_full_context(output_format)
    print(output)


if __name__ == "__main__":
    main()
