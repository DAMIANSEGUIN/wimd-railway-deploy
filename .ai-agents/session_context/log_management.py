#!/usr/bin/env python3
"""
Session Log Management
Utilities for rotating, archiving, and cleaning session logs
"""

import gzip
import shutil
from datetime import datetime, timedelta
from pathlib import Path
from typing import List


class LogManager:
    """Manage session log lifecycle"""

    def __init__(self, sessions_dir: Path = Path(".ai-agents/sessions")):
        self.sessions_dir = sessions_dir
        self.archive_dir = sessions_dir / "archive"
        self.archive_dir.mkdir(parents=True, exist_ok=True)

    def list_sessions(self, archived: bool = False) -> List[str]:
        """List all session IDs"""
        if archived:
            pattern = "*.jsonl.gz"
            directory = self.archive_dir
        else:
            pattern = "*.jsonl"
            directory = self.sessions_dir

        return [f.stem.replace(".jsonl", "") for f in directory.glob(pattern)]

    def get_session_size(self, session_id: str) -> int:
        """Get size of session log in bytes"""
        log_file = self.sessions_dir / f"{session_id}.jsonl"
        if log_file.exists():
            return log_file.stat().st_size
        return 0

    def get_session_age(self, session_id: str) -> timedelta:
        """Get age of session log"""
        log_file = self.sessions_dir / f"{session_id}.jsonl"
        if log_file.exists():
            modified = datetime.fromtimestamp(log_file.stat().st_mtime)
            return datetime.now() - modified
        return timedelta(days=0)

    def archive_session(self, session_id: str, compress: bool = True) -> bool:
        """
        Archive a session log

        Args:
            session_id: Session to archive
            compress: Whether to gzip compress

        Returns:
            Success status
        """
        log_file = self.sessions_dir / f"{session_id}.jsonl"

        if not log_file.exists():
            return False

        if compress:
            archive_file = self.archive_dir / f"{session_id}.jsonl.gz"
            with open(log_file, "rb") as f_in:
                with gzip.open(archive_file, "wb") as f_out:
                    shutil.copyfileobj(f_in, f_out)
        else:
            archive_file = self.archive_dir / f"{session_id}.jsonl"
            shutil.copy2(log_file, archive_file)

        # Remove original
        log_file.unlink()

        return True

    def restore_session(self, session_id: str) -> bool:
        """Restore session from archive"""
        archive_file = self.archive_dir / f"{session_id}.jsonl.gz"

        if archive_file.exists():
            log_file = self.sessions_dir / f"{session_id}.jsonl"
            with gzip.open(archive_file, "rb") as f_in:
                with open(log_file, "wb") as f_out:
                    shutil.copyfileobj(f_in, f_out)
            return True

        # Try uncompressed
        archive_file = self.archive_dir / f"{session_id}.jsonl"
        if archive_file.exists():
            log_file = self.sessions_dir / f"{session_id}.jsonl"
            shutil.copy2(archive_file, log_file)
            return True

        return False

    def cleanup_old_sessions(self, older_than_days: int = 30, archive_first: bool = True) -> int:
        """
        Clean up sessions older than threshold

        Args:
            older_than_days: Age threshold in days
            archive_first: Archive before deleting

        Returns:
            Number of sessions cleaned up
        """
        cleaned = 0

        for session_id in self.list_sessions():
            age = self.get_session_age(session_id)

            if age.days > older_than_days:
                if archive_first:
                    self.archive_session(session_id)
                else:
                    log_file = self.sessions_dir / f"{session_id}.jsonl"
                    log_file.unlink()

                cleaned += 1

        return cleaned

    def get_storage_stats(self) -> dict:
        """Get storage statistics for session logs"""
        active_sessions = self.list_sessions(archived=False)
        archived_sessions = self.list_sessions(archived=True)

        active_size = sum(self.get_session_size(sid) for sid in active_sessions)

        archived_size = sum(
            (self.archive_dir / f"{sid}.jsonl.gz").stat().st_size
            for sid in archived_sessions
            if (self.archive_dir / f"{sid}.jsonl.gz").exists()
        )

        return {
            "active_sessions": len(active_sessions),
            "active_size_bytes": active_size,
            "active_size_mb": round(active_size / 1024 / 1024, 2),
            "archived_sessions": len(archived_sessions),
            "archived_size_bytes": archived_size,
            "archived_size_mb": round(archived_size / 1024 / 1024, 2),
            "total_size_mb": round((active_size + archived_size) / 1024 / 1024, 2),
        }


def main():
    """Test log management"""
    manager = LogManager()

    # Get stats
    stats = manager.get_storage_stats()
    print("📊 Storage Statistics:")
    print(f"  Active sessions: {stats['active_sessions']}")
    print(f"  Active size: {stats['active_size_mb']} MB")
    print(f"  Archived sessions: {stats['archived_sessions']}")
    print(f"  Archived size: {stats['archived_size_mb']} MB")
    print(f"  Total: {stats['total_size_mb']} MB")

    # Test archival
    sessions = manager.list_sessions()
    if sessions:
        test_session = sessions[0]
        print(f"\n📦 Testing archive of session: {test_session}")

        age = manager.get_session_age(test_session)
        print(f"  Age: {age.days} days, {age.seconds // 3600} hours")

        # Archive it
        success = manager.archive_session(test_session)
        print(f"  Archive: {'✅ Success' if success else '❌ Failed'}")

        # Restore it
        success = manager.restore_session(test_session)
        print(f"  Restore: {'✅ Success' if success else '❌ Failed'}")

    print("\n✅ Log management test complete")


if __name__ == "__main__":
    main()
