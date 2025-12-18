#!/usr/bin/env python3
"""
MCP Gate Checker - Determines agent's next task based on completion gates
"""

import json
import sys
from pathlib import Path


def load_gate_file(filepath):
    """Load a gate completion file"""
    try:
        with open(filepath) as f:
            return json.load(f)
    except:
        return None


def check_my_next_task(agent_name):
    """
    Check what task this agent should work on next

    Returns:
        dict with:
        - task: Task identifier
        - should_start: Boolean
        - reason: Why or why not
        - dependencies: What's needed
    """

    status_dir = Path(".ai-agents/status")

    # Load all completion gates
    gates = {}
    gate_tasks = {}  # Map task IDs to gate data
    for gate_file in status_dir.glob("*.complete"):
        gate = load_gate_file(gate_file)
        if gate:
            gates[gate_file.stem] = gate
            # Also index by task ID from the gate content
            if "task" in gate:
                gate_tasks[gate["task"]] = gate

    # Phase 1 tasks
    phase1_tasks = {
        "claude_code": ["phase1_task1a_claude"],
        "gemini": ["phase1_task1c_gemini"],
    }

    # Phase 2 tasks
    phase2_tasks = {
        "gemini": {
            "task": "phase2_task2.1_broker",
            "name": "Broker Integration",
            "dependencies": ["phase1_validation"],
            "description": "Build broker scripts for automatic doc retrieval",
        },
        "codex": {
            "task": "phase2_task2.2_logging",
            "name": "Structured Session Logs",
            "dependencies": ["phase2_task2.1_broker_integration"],
            "description": "Implement session log schema and rotation",
        },
        "claude_code": {
            "task": "phase2_task2.3_handoffs",
            "name": "Handoff Protocol Standardization",
            "dependencies": ["phase2_task2.1_broker_integration", "phase2_task2.2_logging"],
            "description": "Create standardized handoff templates",
        },
    }

    # Check Phase 1 status
    phase1_complete = {
        "task1a": "phase1_task1a_claude" in gates,
        "task1c": "phase1_task1c_gemini" in gates,
        "validation": "phase1_validation" in gates,
    }

    # If Phase 1 not complete for this agent
    if agent_name in phase1_tasks:
        for task in phase1_tasks[agent_name]:
            if task not in gates:
                return {
                    "task": task,
                    "should_start": True,
                    "reason": "Phase 1 task not yet complete",
                    "dependencies": [],
                }

    # If all Phase 1 complete, check Phase 2
    if all(phase1_complete.values()):
        if agent_name in phase2_tasks:
            task_info = phase2_tasks[agent_name]
            task_id = task_info["task"]

            # Check if already complete
            if task_id in gates:
                return {
                    "task": None,
                    "should_start": False,
                    "reason": f"{task_info['name']} already complete",
                    "dependencies": [],
                }

            # Check dependencies (check both gate file stems and task IDs)
            deps_met = []
            deps_missing = []
            for dep in task_info["dependencies"]:
                # Check if dependency exists either as gate file stem or task ID
                if dep in gates or dep in gate_tasks:
                    deps_met.append(dep)
                else:
                    deps_missing.append(dep)

            if not deps_missing:
                return {
                    "task": task_id,
                    "name": task_info["name"],
                    "should_start": True,
                    "reason": "All dependencies satisfied",
                    "dependencies": deps_met,
                    "description": task_info["description"],
                }
            else:
                return {
                    "task": task_id,
                    "name": task_info["name"],
                    "should_start": False,
                    "reason": "Waiting for dependencies",
                    "dependencies_met": deps_met,
                    "dependencies_missing": deps_missing,
                }

    # Phase 1 not complete yet
    if not all(phase1_complete.values()):
        waiting_for = [k for k, v in phase1_complete.items() if not v]
        return {
            "task": None,
            "should_start": False,
            "reason": "Phase 1 not complete",
            "waiting_for": waiting_for,
        }

    # No tasks for this agent
    return {"task": None, "should_start": False, "reason": "No tasks assigned", "dependencies": []}


def print_status_report(agent_name):
    """Print a human-readable status report"""
    result = check_my_next_task(agent_name)

    print(f"\n{'='*60}")
    print(f"MCP Gate Status for: {agent_name.upper()}")
    print(f"{'='*60}\n")

    if result["should_start"]:
        print("🚀 READY TO START")
        print(f"   Task: {result.get('name', result['task'])}")
        print(f"   Description: {result.get('description', 'N/A')}")
        print(f"   Reason: {result['reason']}")
        if result.get("dependencies"):
            print(f"   Dependencies met: {', '.join(result['dependencies'])}")
    else:
        print("⏳ WAITING")
        print(f"   Reason: {result['reason']}")
        if result.get("waiting_for"):
            print(f"   Waiting for: {', '.join(result['waiting_for'])}")
        if result.get("dependencies_missing"):
            print(f"   Missing: {', '.join(result['dependencies_missing'])}")

    print(f"\n{'='*60}\n")

    return result


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 check_gates.py <agent_name>")
        print("  agent_name: claude_code, gemini, codex")
        sys.exit(1)

    agent = sys.argv[1].lower()
    result = print_status_report(agent)

    # Exit code: 0 if should start, 1 if waiting
    sys.exit(0 if result["should_start"] else 1)
