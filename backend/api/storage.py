import json
import os
import psycopg2
import psycopg2.extras
import uuid
from contextlib import contextmanager
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any, Dict, List, Optional

# DATA_ROOT and UPLOAD_ROOT are still used for file uploads, not the DB
DATA_ROOT = Path(os.getenv("DATA_ROOT", "data"))
UPLOAD_ROOT = Path(os.getenv("UPLOAD_ROOT", DATA_ROOT / "uploads"))
SESSION_TTL_DAYS = int(os.getenv("SESSION_TTL_DAYS", "30"))

UPLOAD_ROOT.mkdir(parents=True, exist_ok=True)
DATA_ROOT.mkdir(parents=True, exist_ok=True)


def _json_dump(data: Any) -> str:
    return json.dumps(data, ensure_ascii=False)


def _json_load(raw: Optional[str]) -> Any:
    if raw is None:
        return None
    # psycopg2 automatically decodes JSONB to dict, so this is a fallback
    if isinstance(raw, dict):
        return raw
    try:
        return json.loads(raw)
    except (json.JSONDecodeError, TypeError):
        return None


@contextmanager
def get_conn():
    """Establishes a connection to the PostgreSQL database."""
    DATABASE_URL = os.getenv("DATABASE_URL")
    if not DATABASE_URL:
        raise ValueError("DATABASE_URL environment variable is not set")

    conn = psycopg2.connect(DATABASE_URL)
    try:
        yield conn
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        conn.close()


def init_db() -> None:
    """Initializes the database tables for PostgreSQL, dropping them first to ensure a clean state."""
    with get_conn() as conn:
        with conn.cursor() as cursor:
            # Drop tables in reverse order of creation due to foreign keys
            cursor.execute("DROP TABLE IF EXISTS file_uploads CASCADE;")
            cursor.execute("DROP TABLE IF EXISTS resume_versions CASCADE;")
            cursor.execute("DROP TABLE IF EXISTS job_matches CASCADE;")
            cursor.execute("DROP TABLE IF EXISTS wimd_outputs CASCADE;")
            cursor.execute("DROP TABLE IF EXISTS sessions CASCADE;")
            # Also drop analytics tables if they exist
            cursor.execute("DROP TABLE IF EXISTS match_analytics CASCADE;")
            cursor.execute("DROP TABLE IF EXISTS token_usage CASCADE;")

            # Re-create tables
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS sessions (
                    id TEXT PRIMARY KEY,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'utc'),
                    expires_at TIMESTAMP WITH TIME ZONE,
                    user_data JSONB
                )
                """
            )

            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS wimd_outputs (
                    id SERIAL PRIMARY KEY,
                    session_id TEXT,
                    prompt TEXT,
                    response TEXT,
                    analysis_data JSONB,
                    metrics JSONB,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'utc'),
                    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
                )
                """
            )

            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS job_matches (
                    id SERIAL PRIMARY KEY,
                    session_id TEXT,
                    job_id TEXT,
                    company TEXT,
                    role TEXT,
                    fit_score REAL,
                    skills_match JSONB,
                    values_match JSONB,
                    extras JSONB,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'utc'),
                    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
                )
                """
            )

            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS resume_versions (
                    id SERIAL PRIMARY KEY,
                    session_id TEXT,
                    job_id TEXT,
                    version_name TEXT,
                    content TEXT,
                    feedback JSONB,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'utc'),
                    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
                )
                """
            )

            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS file_uploads (
                    id SERIAL PRIMARY KEY,
                    session_id TEXT,
                    filename TEXT,
                    file_path TEXT,
                    file_type TEXT,
                    file_size BIGINT,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() AT TIME ZONE 'utc'),
                    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
                )
                """
            )


def _expiry_ts() -> datetime:
    return datetime.utcnow() + timedelta(days=SESSION_TTL_DAYS)


def create_session(user_data: Optional[Dict[str, Any]] = None) -> str:
    session_id = uuid.uuid4().hex
    payload = _json_dump(user_data or {})
    with get_conn() as conn:
        with conn.cursor() as cursor:
            cursor.execute(
                "INSERT INTO sessions (id, expires_at, user_data) VALUES (%s, %s, %s) ON CONFLICT (id) DO NOTHING",
                (session_id, _expiry_ts(), payload),
            )
    return session_id


def ensure_session(session_id: Optional[str], user_data: Optional[Dict[str, Any]] = None) -> str:
    if not session_id:
        return create_session(user_data)
    with get_conn() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT id FROM sessions WHERE id = %s", (session_id,))
            if cursor.fetchone() is None:
                # Use ON CONFLICT to handle race conditions where another process creates the session
                cursor.execute(
                    "INSERT INTO sessions (id, expires_at, user_data) VALUES (%s, %s, %s) ON CONFLICT (id) DO NOTHING",
                    (session_id, _expiry_ts(), _json_dump(user_data or {})),
                )
            else:
                cursor.execute(
                    "UPDATE sessions SET expires_at = %s, user_data = COALESCE(%s, user_data) WHERE id = %s",
                    (_expiry_ts(), _json_dump(user_data) if user_data is not None else None, session_id),
                )
    return session_id


def session_exists(session_id: str) -> bool:
    with get_conn() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT 1 FROM sessions WHERE id = %s", (session_id,))
            return cursor.fetchone() is not None


def record_wimd_output(
    session_id: str,
    prompt: str,
    response: str,
    analysis_data: Optional[Dict[str, Any]] = None,
    metrics: Optional[Dict[str, Any]] = None,
) -> None:
    with get_conn() as conn:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO wimd_outputs (session_id, prompt, response, analysis_data, metrics)
                VALUES (%s, %s, %s, %s, %s)
                """,
                (
                    session_id,
                    prompt,
                    response,
                    _json_dump(analysis_data or {}),
                    _json_dump(metrics or {}),
                ),
            )


def latest_metrics(session_id: str) -> Optional[Dict[str, Any]]:
    with get_conn() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cursor:
            cursor.execute(
                "SELECT metrics FROM wimd_outputs WHERE session_id = %s ORDER BY created_at DESC LIMIT 1",
                (session_id,),
            )
            row = cursor.fetchone()
    if row and row["metrics"]:
        # metrics are already parsed as dict by psycopg2 if column is JSONB
        return _json_load(row["metrics"])
    return None


def wimd_history(session_id: str, limit: int = 25) -> List[Dict[str, Any]]:
    with get_conn() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cursor:
            cursor.execute(
                """
                SELECT prompt, response, analysis_data, metrics, created_at
                FROM wimd_outputs
                WHERE session_id = %s
                ORDER BY created_at DESC
                LIMIT %s
                """,
                (session_id, limit),
            )
            rows = cursor.fetchall()
    history: List[Dict[str, Any]] = []
    for row in rows:
        row_dict = dict(row)
        row_dict['analysis_data'] = _json_load(row_dict['analysis_data'])
        row_dict['metrics'] = _json_load(row_dict['metrics'])
        history.append(row_dict)
    return history


def store_job_matches(session_id: str, matches: List[Dict[str, Any]]) -> None:
    with get_conn() as conn:
        with conn.cursor() as cursor:
            cursor.execute("DELETE FROM job_matches WHERE session_id = %s", (session_id,))
            for match in matches:
                cursor.execute(
                    """
                    INSERT INTO job_matches (session_id, job_id, company, role, fit_score, skills_match, values_match, extras)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                    """,
                    (
                        session_id,
                        match.get("job_id"),
                        match.get("company"),
                        match.get("role"),
                        float(match.get("fit_score", 0.0)),
                        _json_dump(match.get("skills_match", [])),
                        _json_dump(match.get("values_match", [])),
                        _json_dump(match.get("extras", {})),
                    ),
                )


def fetch_job_matches(session_id: str) -> List[Dict[str, Any]]:
    with get_conn() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cursor:
            cursor.execute(
                "SELECT job_id, company, role, fit_score, skills_match, values_match, extras, created_at FROM job_matches WHERE session_id = %s ORDER BY fit_score DESC",
                (session_id,),
            )
            rows = cursor.fetchall()
    matches = []
    for row in rows:
        row_dict = dict(row)
        row_dict['skills_match'] = _json_load(row_dict['skills_match'])
        row_dict['values_match'] = _json_load(row_dict['values_match'])
        row_dict['extras'] = _json_load(row_dict['extras'])
        matches.append(row_dict)
    return matches


def update_job_match_status(
    session_id: str,
    job_id: str,
    status: str,
    notes: Optional[str] = None,
) -> None:
    with get_conn() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cursor:
            cursor.execute(
                "SELECT extras FROM job_matches WHERE session_id = %s AND job_id = %s",
                (session_id, job_id),
            )
            row = cursor.fetchone()
            if row is None:
                raise ValueError("job_match_not_found")
            extras = _json_load(row['extras']) or {}
            extras.update(
                {
                    "status": status,
                    "status_notes": notes or "",
                    "status_at": datetime.utcnow().isoformat() + "Z",
                }
            )
            cursor.execute(
                "UPDATE job_matches SET extras = %s WHERE session_id = %s AND job_id = %s",
                (_json_dump(extras), session_id, job_id),
            )


def add_resume_version(
    session_id: str,
    version_name: str,
    content: str,
    job_id: Optional[str] = None,
    feedback: Optional[Dict[str, Any]] = None,
) -> int:
    with get_conn() as conn:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO resume_versions (session_id, job_id, version_name, content, feedback)
                VALUES (%s, %s, %s, %s, %s) RETURNING id
                """,
                (session_id, job_id, version_name, content, _json_dump(feedback or {})),
            )
            version_id = cursor.fetchone()[0]
            return version_id


def list_resume_versions(session_id: str) -> List[Dict[str, Any]]:
    with get_conn() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cursor:
            cursor.execute(
                "SELECT id, job_id, version_name, content, feedback, created_at FROM resume_versions WHERE session_id = %s ORDER BY created_at DESC",
                (session_id,),
            )
            rows = cursor.fetchall()
    versions = []
    for row in rows:
        row_dict = dict(row)
        row_dict['feedback'] = _json_load(row_dict['feedback'])
        versions.append(row_dict)
    return versions


def store_file_upload(
    session_id: str,
    filename: str,
    file_type: str,
    file_size: int,
    file_path: Path,
) -> None:
    with get_conn() as conn:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO file_uploads (session_id, filename, file_path, file_type, file_size)
                VALUES (%s, %s, %s, %s, %s)
                """,
                (session_id, filename, str(file_path), file_type, file_size),
            )


def list_files(session_id: str) -> List[Dict[str, Any]]:
    with get_conn() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cursor:
            cursor.execute(
                "SELECT id, filename, file_type, file_size, created_at FROM file_uploads WHERE session_id = %s ORDER BY created_at DESC",
                (session_id,),
            )
            rows = cursor.fetchall()
    return [dict(row) for row in rows]


def cleanup_expired_sessions() -> None:
    cutoff = datetime.utcnow()
    with get_conn() as conn:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT id FROM sessions WHERE expires_at <= %s", (cutoff,)
            )
            expired_ids = [row[0] for row in cursor.fetchall()]
            if expired_ids:
                # psycopg2 can accept a tuple of IDs directly
                id_tuple = tuple(expired_ids)
                
                cursor.execute(
                    "SELECT file_path FROM file_uploads WHERE session_id IN %s",
                    (id_tuple,),
                )
                file_rows = cursor.fetchall()
                
                # Deletions
                for table in ["file_uploads", "resume_versions", "job_matches", "wimd_outputs", "sessions"]:
                    cursor.execute(
                        f"DELETE FROM {table} WHERE session_id IN %s", (id_tuple,)
                    )
                
                for row in file_rows:
                    try:
                        path = Path(row[0])
                        if path.exists() and path.is_file():
                            path.unlink()
                    except OSError:
                        pass


def session_summary(session_id: str) -> Dict[str, Any]:
    data: Dict[str, Any] = {"session_id": session_id}
    with get_conn() as conn:
        with conn.cursor(cursor_factory=psycopg2.extras.DictCursor) as cursor:
            cursor.execute(
                "SELECT created_at, expires_at, user_data FROM sessions WHERE id = %s",
                (session_id,),
            )
            session_row = cursor.fetchone()
    if session_row:
        data.update(dict(session_row))
    data["latest_metrics"] = latest_metrics(session_id) or {}
    data["files"] = list_files(session_id)
    data["resumes"] = list_resume_versions(session_id)
    data["job_matches"] = fetch_job_matches(session_id)
    return data


__all__ = [
    "UPLOAD_ROOT",
    "create_session",
    "ensure_session",
    "session_exists",
    "record_wimd_output",
    "latest_metrics",
    "wimd_history",
    "store_job_matches",
    "fetch_job_matches",
    "update_job_match_status",
    "add_resume_version",
    "list_resume_versions",
    "store_file_upload",
    "list_files",
    "cleanup_expired_sessions",
    "init_db",
    "session_summary",
]
