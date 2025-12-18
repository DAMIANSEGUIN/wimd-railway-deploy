#!/usr/bin/env python3
"""
MODULE: mosaic-diag/cli.py
PURPOSE: CLI entrypoint for mosaic-diag v2.0
VERSION: 2.0.0
LAST_MODIFIED: 2025-12-04
MODIFIED_BY: Claude Code
SPEC: mosaic_diag_spec_v2.0.md

USAGE:
    mosaic-diag preflight deploy
    mosaic-diag preflight env
    mosaic-diag incident add --category deployment --severity high --symptom "..."
    mosaic-diag incidents list
    mosaic-diag incidents list --category deployment
    mosaic-diag suggestions list

EXIT CODES:
    0 - Success
    1 - General error
    2 - Preflight checks failed
    3 - Invalid arguments
"""

import argparse
import json
import sys
from pathlib import Path

# Add parent dir to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from incidents import IncidentCategory, IncidentLogger, IncidentSeverity, format_incidents_human
from preflight import PreflightEngine, format_results_human, format_results_json
from storage import Storage


def cmd_preflight(args):
    """Run preflight checks"""
    engine = PreflightEngine()

    if args.category == "all":
        results = engine.run_all()
    else:
        results = engine.run_category(args.category)

    # Output
    if args.json:
        print(format_results_json(results))
    else:
        print(format_results_human(results))

    # Exit code
    failed = any(r.status == "fail" for r in results)
    if failed:
        sys.exit(2)

    sys.exit(0)


def cmd_incident_add(args):
    """Add a new incident"""
    storage = Storage()
    logger = IncidentLogger(storage)

    # Parse category and severity
    try:
        category = IncidentCategory[args.category.upper()]
    except KeyError:
        print(f"Error: Invalid category '{args.category}'", file=sys.stderr)
        print(
            f"Valid categories: {', '.join(c.name.lower() for c in IncidentCategory)}",
            file=sys.stderr,
        )
        sys.exit(3)

    try:
        severity = IncidentSeverity[args.severity.upper()]
    except KeyError:
        print(f"Error: Invalid severity '{args.severity}'", file=sys.stderr)
        print(
            f"Valid severities: {', '.join(s.name.lower() for s in IncidentSeverity)}",
            file=sys.stderr,
        )
        sys.exit(3)

    # Log incident
    incident = logger.log_incident(
        category=category,
        severity=severity,
        symptom=args.symptom,
        root_cause=args.root_cause,
        context=json.loads(args.context) if args.context else {},
        resolution=args.resolution,
    )

    print(f"✅ Incident logged: {incident.incident_id}")
    print(f"   Category: {incident.category}")
    print(f"   Severity: {incident.severity}")
    print(f"   Symptom: {incident.symptom}")

    sys.exit(0)


def cmd_incidents_list(args):
    """List incidents"""
    storage = Storage()
    logger = IncidentLogger(storage)

    incidents = logger.list_incidents(
        category=args.category, severity=args.severity, limit=args.limit
    )

    if args.json:
        print(json.dumps(incidents, indent=2))
    else:
        print(format_incidents_human(incidents))

    sys.exit(0)


def cmd_suggestions_list(args):
    """List suggestions"""
    storage = Storage()

    suggestion_type = args.type or "check"
    suggestions = storage.read_suggestions(suggestion_type)

    if not suggestions:
        print(f"No {suggestion_type} suggestions found.")
        sys.exit(0)

    print(json.dumps(suggestions, indent=2))
    sys.exit(0)


def main():
    """Main CLI entrypoint"""
    parser = argparse.ArgumentParser(
        prog="mosaic-diag", description="Mosaic diagnostic and prognostic system v2.0"
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    # preflight command
    preflight_parser = subparsers.add_parser("preflight", help="Run preflight checks")
    preflight_parser.add_argument(
        "category",
        choices=[
            "deploy",
            "deployment",
            "env",
            "environment",
            "access",
            "permissions",
            "docs",
            "documentation",
            "all",
        ],
        help="Category of checks to run",
    )
    preflight_parser.add_argument("--json", action="store_true", help="Output as JSON")
    preflight_parser.set_defaults(func=cmd_preflight)

    # Normalize category names
    def normalize_category(category):
        mapping = {
            "deploy": "deployment",
            "env": "environment",
            "access": "permissions",
            "docs": "documentation",
        }
        return mapping.get(category, category)

    # incident command
    incident_parser = subparsers.add_parser("incident", help="Incident operations")
    incident_subparsers = incident_parser.add_subparsers(dest="subcommand", required=True)

    # incident add
    incident_add_parser = incident_subparsers.add_parser("add", help="Add a new incident")
    incident_add_parser.add_argument("--category", required=True, help="Incident category")
    incident_add_parser.add_argument("--severity", required=True, help="Incident severity")
    incident_add_parser.add_argument("--symptom", required=True, help="What happened")
    incident_add_parser.add_argument("--root-cause", help="Why it happened")
    incident_add_parser.add_argument("--context", help="Additional context (JSON)")
    incident_add_parser.add_argument("--resolution", help="How it was resolved")
    incident_add_parser.set_defaults(func=cmd_incident_add)

    # incidents command
    incidents_parser = subparsers.add_parser("incidents", help="List incidents")
    incidents_parser.add_argument("--category", help="Filter by category")
    incidents_parser.add_argument("--severity", help="Filter by severity")
    incidents_parser.add_argument("--limit", type=int, help="Maximum number to return")
    incidents_parser.add_argument("--json", action="store_true", help="Output as JSON")
    incidents_parser.set_defaults(func=cmd_incidents_list)

    # suggestions command
    suggestions_parser = subparsers.add_parser("suggestions", help="List suggestions")
    suggestions_parser.add_argument(
        "--type", choices=["check", "doc", "roadmap"], help="Suggestion type"
    )
    suggestions_parser.set_defaults(func=cmd_suggestions_list)

    # Parse args
    args = parser.parse_args()

    # Normalize category if needed
    if hasattr(args, "category"):
        args.category = normalize_category(args.category)

    # Execute command
    if hasattr(args, "func"):
        args.func(args)
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
