"""
Smoke Tests for Semantic Match Upgrade
Tests embedding, reranking, analytics, and cost controls
"""

import sys
import os

# Add api directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

def test_embedding_upgrade():
    """Test text-embedding-3-small integration."""
    print("\n🧪 Test 1: Embedding Upgrade")
    try:
        from api.rag_engine import compute_embedding

        # Test embedding generation
        result = compute_embedding("test query for job search")

        if result and result.model == "text-embedding-3-small":
            print("   ✅ PASS: Using text-embedding-3-small")
            print(f"   - Embedding dimension: {len(result.embedding)}")
            return True
        else:
            print(f"   ❌ FAIL: Model is {result.model if result else 'None'}")
            return False

    except Exception as e:
        print(f"   ❌ FAIL: {e}")
        return False


def test_reranker_integration():
    """Test cross-encoder reranker."""
    print("\n🧪 Test 2: Reranker Integration")
    try:
        from api.reranker import rerank_documents, get_reranker_health

        # Check reranker health
        health = get_reranker_health()
        print(f"   - Reranker status: {health['status']}")
        print(f"   - Model: {health['model_name']}")
        print(f"   - Sentence transformers: {health['sentence_transformers_available']}")

        # Test reranking
        test_docs = [
            {"text": "Python developer position", "similarity": 0.85},
            {"text": "Java engineer role", "similarity": 0.80},
            {"text": "Data scientist opportunity", "similarity": 0.75},
        ]

        result = rerank_documents("python developer", test_docs)

        if result and len(result.reranked_documents) > 0:
            print(f"   ✅ PASS: Reranked {len(result.reranked_documents)} documents")
            print(f"   - Improvement: {result.improvement_pct:.1f}%")
            print(f"   - Processing time: {result.processing_time:.3f}s")
            return True
        else:
            print("   ❌ FAIL: No reranked documents returned")
            return False

    except Exception as e:
        print(f"   ❌ FAIL: {e}")
        return False


def test_analytics_dashboard():
    """Test analytics dashboard and logging."""
    print("\n🧪 Test 3: Analytics Dashboard")
    try:
        from api.analytics import log_match_analytics, get_analytics_dashboard, get_analytics_health

        # Check analytics health
        health = get_analytics_health()
        print(f"   - Analytics status: {health['status']}")

        # Test logging
        log_match_analytics(
            query="test query",
            pre_scores=[0.7, 0.6, 0.5],
            post_scores=[0.85, 0.75, 0.65],
            improvement_pct=25.0,
            processing_time=0.15
        )

        # Get dashboard data
        dashboard = get_analytics_dashboard()

        if dashboard and dashboard['status'] == 'operational':
            print("   ✅ PASS: Analytics dashboard operational")
            print(f"   - Match analytics: {dashboard['match_analytics']['status']}")
            print(f"   - Token usage: {dashboard['token_usage']['status']}")
            return True
        else:
            print("   ❌ FAIL: Analytics dashboard not operational")
            return False

    except Exception as e:
        print(f"   ❌ FAIL: {e}")
        return False


def test_cost_controls():
    """Test cost control and monitoring."""
    print("\n🧪 Test 4: Cost Controls")
    try:
        from api.cost_controls import check_cost_limits, check_resource_limits

        # Test cost limits
        cost_check = check_cost_limits("embedding", 0.01)
        print(f"   - Cost check: {cost_check['allowed']}")

        # Test resource limits
        resource_check = check_resource_limits("embedding")
        print(f"   - Resource check: {resource_check['allowed']}")

        if cost_check and resource_check:
            print("   ✅ PASS: Cost controls operational")
            return True
        else:
            print("   ❌ FAIL: Cost controls not working")
            return False

    except Exception as e:
        print(f"   ❌ FAIL: {e}")
        return False


def test_rag_health():
    """Test RAG engine health endpoint."""
    print("\n🧪 Test 5: RAG Health Check")
    try:
        from api.rag_engine import get_rag_health

        health = get_rag_health()
        print(f"   - RAG enabled: {health['rag_enabled']}")
        print(f"   - Status: {health['status']}")
        print(f"   - Cache size: {health['cache_size']}")

        if health['status'] == 'operational' or health['status'] == 'disabled':
            print("   ✅ PASS: RAG health check working")
            return True
        else:
            print("   ❌ FAIL: RAG health check failed")
            return False

    except Exception as e:
        print(f"   ❌ FAIL: {e}")
        return False


def main():
    """Run all smoke tests."""
    print("=" * 60)
    print("🔬 SEMANTIC MATCH UPGRADE - SMOKE TESTS")
    print("=" * 60)

    tests = [
        test_embedding_upgrade,
        test_reranker_integration,
        test_analytics_dashboard,
        test_cost_controls,
        test_rag_health,
    ]

    results = []
    for test in tests:
        results.append(test())

    print("\n" + "=" * 60)
    print(f"📊 RESULTS: {sum(results)}/{len(results)} tests passed")
    print("=" * 60)

    if all(results):
        print("✅ All smoke tests PASSED")
        return 0
    else:
        print("❌ Some smoke tests FAILED")
        return 1


if __name__ == "__main__":
    sys.exit(main())
