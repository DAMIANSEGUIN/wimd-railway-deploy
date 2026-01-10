"""
Cross-Encoder Reranker for Mosaic 2.0
Implements CPU-hosted cross-encoder reranking using sentence-transformers
"""

import time
from dataclasses import dataclass
from typing import Any, Dict, List

from sentence_transformers import CrossEncoder

@dataclass
class RerankResult:
    """Result of reranking operation"""

    query: str
    reranked_documents: List[Dict[str, Any]]
    pre_rerank_scores: List[float]
    post_rerank_scores: List[float]
    improvement_pct: float
    processing_time: float


class CrossEncoderReranker:
    """CPU-hosted cross-encoder reranker for semantic matching."""

    def __init__(self):
        self.model_name = "cross-encoder/ms-marco-MiniLM-L-6-v2"
        self.model = None
        self.initialized = False
        self.max_candidates = 50  # Rerank top 50 candidates
        self.final_top_k = 12  # Return top 12 results

        # Performance tracking
        self.total_reranks = 0
        self.total_processing_time = 0.0
        self.average_latency = 0.0

        # Initialize model
        self._initialize_model()

    def _initialize_model(self):
        """Initialize the cross-encoder model."""
        try:
            print(f"Initializing cross-encoder model: {self.model_name}")
            self.model = CrossEncoder(self.model_name, device="cpu")
            self.initialized = True
            print("Cross-encoder model initialized successfully")
        except Exception as e:
            print(f"CRITICAL: Error initializing cross-encoder: {e}")
            print("This is a fatal error. The application will not be able to serve reranking requests.")
            # In a real scenario, this should either be handled more gracefully
            # or prevent the application from starting if it's a critical feature.
            self.initialized = False

    def rerank_documents(self, query: str, documents: List[Dict[str, Any]]) -> RerankResult:
        """Rerank documents using cross-encoder."""
        start_time = time.time()

        if not self.initialized or not self.model:
            # This will now be the main failure path if initialization fails.
            # Returning an empty result or raising an exception might be options.
            # For now, return a result that indicates failure.
            return RerankResult(
                query=query,
                reranked_documents=documents, # Return original documents
                pre_rerank_scores=[d.get('similarity', 0.0) for d in documents],
                post_rerank_scores=[d.get('similarity', 0.0) for d in documents],
                improvement_pct=0.0,
                processing_time=time.time() - start_time,
            )

        try:
            # Limit to max candidates
            candidates = documents[: self.max_candidates]

            # Extract text and scores
            texts = [doc.get("text", "") for doc in candidates]
            pre_scores = [doc.get("similarity", 0.0) for doc in candidates]

            # Prepare query-document pairs
            query_doc_pairs = [(query, text) for text in texts]

            # Get rerank scores
            rerank_scores = self.model.predict(query_doc_pairs)

            # Combine with original scores (weighted average)
            combined_scores = []
            for i, (pre_score, rerank_score) in enumerate(zip(pre_scores, rerank_scores)):
                # Weighted combination: 70% rerank, 30% original
                combined_score = 0.7 * rerank_score + 0.3 * pre_score
                combined_scores.append(combined_score)

            # Sort by combined scores
            scored_docs = list(zip(candidates, pre_scores, rerank_scores, combined_scores))
            scored_docs.sort(key=lambda x: x[3], reverse=True)

            # Take top results
            top_results = scored_docs[: self.final_top_k]

            # Format results
            reranked_docs = []
            post_scores = []
            for doc, pre_score, rerank_score, combined_score in top_results:
                doc_copy = doc.copy()
                doc_copy["similarity"] = combined_score
                doc_copy["rerank_score"] = rerank_score
                doc_copy["original_score"] = pre_score
                reranked_docs.append(doc_copy)
                post_scores.append(combined_score)

            # Calculate improvement
            improvement_pct = self._calculate_improvement(pre_scores, post_scores)

            processing_time = time.time() - start_time
            self._update_performance_stats(processing_time)

            return RerankResult(
                query=query,
                reranked_documents=reranked_docs,
                pre_rerank_scores=pre_scores,
                post_rerank_scores=post_scores,
                improvement_pct=improvement_pct,
                processing_time=processing_time,
            )

        except Exception as e:
            print(f"Error in reranking: {e}")
            # Fallback to returning original documents in case of an unexpected error
            return RerankResult(
                query=query,
                reranked_documents=documents,
                pre_rerank_scores=[d.get('similarity', 0.0) for d in documents],
                post_rerank_scores=[d.get('similarity', 0.0) for d in documents],
                improvement_pct=0.0,
                processing_time=time.time() - start_time,
            )

    def _calculate_improvement(self, pre_scores: List[float], post_scores: List[float]) -> float:
        """Calculate percentage improvement from reranking."""
        if not pre_scores or not post_scores:
            return 0.0

        pre_avg = sum(pre_scores) / len(pre_scores) if pre_scores else 0.0
        post_avg = sum(post_scores) / len(post_scores) if post_scores else 0.0

        if pre_avg == 0:
            return 0.0

        return ((post_avg - pre_avg) / abs(pre_avg)) * 100 if pre_avg != 0 else 0.0


    def _update_performance_stats(self, processing_time: float):
        """Update performance statistics."""
        self.total_reranks += 1
        self.total_processing_time += processing_time
        self.average_latency = self.total_processing_time / self.total_reranks

    def get_health_status(self) -> Dict[str, Any]:
        """Get reranker health status."""
        return {
            "initialized": self.initialized,
            "model_name": self.model_name,
            "sentence_transformers_available": True, # Hardcoded to True as it's a firm dependency
            "total_reranks": self.total_reranks,
            "average_latency": self.average_latency,
            "max_candidates": self.max_candidates,
            "final_top_k": self.final_top_k,
            "status": "operational" if self.initialized else "error",
        }


# Global reranker instance
reranker = CrossEncoderReranker()


def rerank_documents(query: str, documents: List[Dict[str, Any]]) -> RerankResult:
    """Rerank documents using the global reranker."""
    return reranker.rerank_documents(query, documents)


def get_reranker_health() -> Dict[str, Any]:
    """Get reranker health status."""
    return reranker.get_health_status()
