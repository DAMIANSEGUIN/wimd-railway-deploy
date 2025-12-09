import json
from pathlib import Path

def read_feature_flags() -> dict:
    """Read feature flags from JSON file"""
    flag_file = Path(".ai-agents/config/feature_flags.json")

    if not flag_file.exists():
        # Default: all disabled
        return {
            "MCP_ENABLED": False,
            "MCP_SESSION_SUMMARIES": False,
            "MCP_RETRIEVAL_TRIGGERS": False,
            "MCP_STRUCTURED_LOGS": False,
            "MCP_BROKER_INTEGRATION": False,
            "MCP_MIRROR_EXPORTS": False
        }

    with open(flag_file) as f:
        data = json.load(f)
        return data.get("flags", {})

def is_feature_enabled(feature_name: str) -> bool:
    """Check if a specific feature is enabled"""
    flags = read_feature_flags()

    # If master switch is off, all features disabled
    if not flags.get("MCP_ENABLED", False):
        return False

    return flags.get(feature_name, False)

# Usage example:
# if is_feature_enabled("MCP_SESSION_SUMMARIES"):
#     load_summaries()
# else:
#     load_full_docs()
