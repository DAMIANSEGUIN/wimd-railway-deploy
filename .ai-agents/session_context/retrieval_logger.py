#!/usr/bin/env python3
"""
MCP Retrieval Logger
Logs all document retrievals triggered by MCP system
"""

import json
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any, Optional


class RetrievalLogger:
    """Log all MCP document retrievals for observability"""

    def __init__(self, log_dir: Path = Path(".ai-agents/logs/retrievals")):
        self.log_dir = log_dir
        self.log_dir.mkdir(parents=True, exist_ok=True)
        self.current_session = None

    def start_session(self, session_id: str):
        """Start a new retrieval logging session"""
        self.current_session = session_id

    def log_retrieval(
        self,
        trigger_type: str,
        documents_retrieved: List[str],
        user_message: str = None,
        agent_response: str = None,
        retrieval_time_ms: float = 0,
        metadata: Optional[Dict[str, Any]] = None
    ):
        """
        Log a document retrieval event

        Args:
            trigger_type: Type of trigger that fired (error, deployment, etc.)
            documents_retrieved: List of document paths fetched
            user_message: User message that triggered retrieval (optional)
            agent_response: Agent response that triggered retrieval (optional)
            retrieval_time_ms: Time taken to retrieve documents
            metadata: Additional metadata
        """

        if not self.current_session:
            self.current_session = f"session_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}"

        event = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "session_id": self.current_session,
            "trigger_type": trigger_type,
            "documents_retrieved": documents_retrieved,
            "document_count": len(documents_retrieved),
            "retrieval_time_ms": retrieval_time_ms,
            "context_snippet": {
                "user_message": user_message[:200] if user_message else None,
                "agent_response": agent_response[:200] if agent_response else None
            },
            "metadata": metadata or {}
        }

        # Append to session log
        log_file = self.log_dir / f"{self.current_session}.jsonl"
        with open(log_file, 'a') as f:
            f.write(json.dumps(event) + '\n')

    def get_session_retrievals(self, session_id: str) -> List[Dict[str, Any]]:
        """Get all retrievals for a session"""
        log_file = self.log_dir / f"{session_id}.jsonl"

        if not log_file.exists():
            return []

        retrievals = []
        with open(log_file, 'r') as f:
            for line in f:
                if line.strip():
                    retrievals.append(json.loads(line))

        return retrievals

    def get_retrieval_stats(self, session_id: str) -> Dict[str, Any]:
        """Get statistics for session retrievals"""
        retrievals = self.get_session_retrievals(session_id)

        if not retrievals:
            return {
                "session_id": session_id,
                "total_retrievals": 0,
                "error": "No retrievals found"
            }

        trigger_counts = {}
        total_docs = 0
        total_time = 0
        document_frequency = {}

        for retrieval in retrievals:
            # Count trigger types
            trigger = retrieval["trigger_type"]
            trigger_counts[trigger] = trigger_counts.get(trigger, 0) + 1

            # Count documents
            total_docs += retrieval["document_count"]
            total_time += retrieval.get("retrieval_time_ms", 0)

            # Track document frequency
            for doc in retrieval["documents_retrieved"]:
                document_frequency[doc] = document_frequency.get(doc, 0) + 1

        # Sort documents by frequency
        most_retrieved = sorted(
            document_frequency.items(),
            key=lambda x: x[1],
            reverse=True
        )[:10]

        return {
            "session_id": session_id,
            "total_retrievals": len(retrievals),
            "total_documents_fetched": total_docs,
            "total_time_ms": round(total_time, 2),
            "avg_time_ms": round(total_time / len(retrievals), 2) if retrievals else 0,
            "trigger_breakdown": trigger_counts,
            "most_retrieved_docs": [
                {"document": doc, "count": count} for doc, count in most_retrieved
            ]
        }

    def get_all_sessions(self) -> List[str]:
        """List all logged sessions"""
        return [f.stem for f in self.log_dir.glob("*.jsonl")]


def main():
    """Test retrieval logger"""
    logger = RetrievalLogger()

    # Test session
    session_id = "test_retrieval_session"
    logger.start_session(session_id)

    # Log some test retrievals
    logger.log_retrieval(
        trigger_type="error",
        documents_retrieved=[
            "TROUBLESHOOTING_CHECKLIST.md",
            "SELF_DIAGNOSTIC_FRAMEWORK.md"
        ],
        user_message="Deployment failed with 500 error",
        retrieval_time_ms=45.3,
        metadata={"trigger_keywords": ["failed", "error"]}
    )

    logger.log_retrieval(
        trigger_type="deployment",
        documents_retrieved=[
            "DEPLOYMENT_TRUTH.md",
            "scripts/deploy.sh"
        ],
        user_message="How do I deploy to Railway?",
        retrieval_time_ms=32.1,
        metadata={"trigger_keywords": ["deploy", "railway"]}
    )

    logger.log_retrieval(
        trigger_type="database",
        documents_retrieved=[
            "SELF_DIAGNOSTIC_FRAMEWORK.md"
        ],
        user_message="PostgreSQL connection failed",
        retrieval_time_ms=28.7,
        metadata={"trigger_keywords": ["postgresql", "connection"]}
    )

    # Get stats
    stats = logger.get_retrieval_stats(session_id)

    print("📊 Retrieval Logger Test Results:")
    print(f"   Session: {stats['session_id']}")
    print(f"   Total Retrievals: {stats['total_retrievals']}")
    print(f"   Total Documents: {stats['total_documents_fetched']}")
    print(f"   Avg Time: {stats['avg_time_ms']} ms")
    print(f"\n🔍 Trigger Breakdown:")
    for trigger, count in stats['trigger_breakdown'].items():
        print(f"   {trigger}: {count}")
    print(f"\n📄 Most Retrieved Docs:")
    for doc_info in stats['most_retrieved_docs']:
        print(f"   {doc_info['document']}: {doc_info['count']}x")

    print("\n✅ Retrieval logger test complete")


if __name__ == "__main__":
    main()
