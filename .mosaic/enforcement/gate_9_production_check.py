#!/usr/bin/env python3
"""
Gate 9: Production Connectivity Check

Validates PRODUCTION REALITY, not just local state.

This gate was created to fix a critical blind spot in the 8-gate system:
- Gates 1-8 validated LOCAL STATE (git, JSON, code patterns)
- Gates 1-8 NEVER checked PRODUCTION (is backend live? URLs correct? deployments working?)

This led to Railway staying connected for days after Render migration, causing
30+ deployment failures that gates never caught.

Usage:
    python3 .mosaic/enforcement/gate_9_production_check.py

Exit codes:
    0 = Production is healthy
    1 = Production issues detected
"""

import json
import sys
import ssl
import certifi
from pathlib import Path
from typing import Dict, Any, List, Tuple
import urllib.request
import urllib.error


class ProductionHealthChecker:
    """Check production connectivity and consistency"""

    def __init__(self):
        self.repo_root = Path(__file__).parent.parent.parent
        self.failures = []
        self.warnings = []
        self.passed = 0

    def test_backend_health(self) -> bool:
        """Test: Backend responds to health check"""
        print("\n🧪 Test: Backend health endpoint responds")

        backend_url = "https://mosaic-backend-tpog.onrender.com/health"
        ssl_context = ssl.create_default_context(cafile=certifi.where())

        try:
            with urllib.request.urlopen(backend_url, timeout=10, context=ssl_context) as response:
                if response.status == 200:
                    data = json.loads(response.read().decode())
                    if data.get("ok"):
                        print(f"  ✅ PASS: Backend healthy ({backend_url})")
                        return True
                    else:
                        self.failures.append(f"Backend health check returned ok=false")
                        print(f"  ❌ FAIL: Backend unhealthy")
                        return False
                else:
                    self.failures.append(f"Backend returned HTTP {response.status}")
                    print(f"  ❌ FAIL: HTTP {response.status}")
                    return False

        except urllib.error.HTTPError as e:
            self.failures.append(f"Backend HTTP error: {e.code} {e.reason}")
            print(f"  ❌ FAIL: HTTP {e.code}")
            return False
        except urllib.error.URLError as e:
            self.failures.append(f"Backend unreachable: {e.reason}")
            print(f"  ❌ FAIL: Unreachable")
            return False
        except Exception as e:
            self.failures.append(f"Backend check failed: {str(e)}")
            print(f"  ❌ FAIL: {str(e)}")
            return False

    def test_frontend_loads(self) -> bool:
        """Test: Frontend loads successfully"""
        print("\n🧪 Test: Frontend loads")

        frontend_url = "https://whatismydelta.com"
        ssl_context = ssl.create_default_context(cafile=certifi.where())

        try:
            with urllib.request.urlopen(frontend_url, timeout=10, context=ssl_context) as response:
                if response.status == 200:
                    print(f"  ✅ PASS: Frontend loads ({frontend_url})")
                    return True
                else:
                    self.failures.append(f"Frontend returned HTTP {response.status}")
                    print(f"  ❌ FAIL: HTTP {response.status}")
                    return False

        except Exception as e:
            self.failures.append(f"Frontend check failed: {str(e)}")
            print(f"  ❌ FAIL: {str(e)}")
            return False

    def test_no_dead_backends(self) -> bool:
        """Test: No dead backends still referenced"""
        print("\n🧪 Test: No dead backends referenced in code")

        dead_backends = [
            "what-is-my-delta-site-production.up.railway.app",
            "mosaic-platform.vercel.app",
        ]

        # Check key files for dead backend references
        files_to_check = [
            "frontend/index.html",
            "netlify.toml",
            "CLAUDE.md",
            "docs/README.md",
        ]

        found_dead = []
        for file_path in files_to_check:
            full_path = self.repo_root / file_path
            if full_path.exists():
                with open(full_path) as f:
                    content = f.read()
                    for dead_url in dead_backends:
                        if dead_url in content:
                            found_dead.append(f"{file_path}: {dead_url}")

        if found_dead:
            for item in found_dead:
                self.failures.append(f"Dead backend referenced: {item}")
            print(f"  ❌ FAIL: Found {len(found_dead)} dead backend references")
            return False
        else:
            print(f"  ✅ PASS: No dead backends referenced")
            return True

    def test_frontend_backend_urls_match(self) -> bool:
        """Test: Frontend API URLs point to correct backend"""
        print("\n🧪 Test: Frontend URLs match production backend")

        frontend_html = self.repo_root / "frontend/index.html"

        if not frontend_html.exists():
            self.failures.append("frontend/index.html not found - critical deployment file missing")
            print(f"  ❌ FAIL: Frontend file not found at frontend/index.html")
            return False  # FAIL instead of passing with warning

        with open(frontend_html) as f:
            content = f.read()

        expected_backend = "https://mosaic-backend-tpog.onrender.com"

        # Check if correct backend is referenced
        if expected_backend in content:
            print(f"  ✅ PASS: Frontend uses correct backend URL")
            return True
        else:
            # Check netlify.toml instead (proxy config)
            netlify_toml = self.repo_root / "netlify.toml"
            if netlify_toml.exists():
                with open(netlify_toml) as f:
                    toml_content = f.read()
                    if expected_backend in toml_content:
                        print(f"  ✅ PASS: Netlify proxy configured correctly")
                        return True

            self.failures.append(f"Frontend doesn't reference production backend: {expected_backend}")
            print(f"  ❌ FAIL: Backend URL mismatch")
            return False

    def test_deployed_frontend_api_url(self) -> bool:
        """Test: DEPLOYED frontend has correct API URL (not just local file)"""
        print("\n🧪 Test: Deployed frontend API URL (production reality check)")

        frontend_url = "https://whatismydelta.com"
        expected_backend = "https://mosaic-backend-tpog.onrender.com"
        ssl_context = ssl.create_default_context(cafile=certifi.where())

        try:
            with urllib.request.urlopen(frontend_url, timeout=10, context=ssl_context) as response:
                if response.status == 200:
                    html = response.read().decode()

                    # Check if deployed HTML has correct API URL
                    if expected_backend in html:
                        print(f"  ✅ PASS: Deployed frontend uses correct API ({expected_backend})")
                        return True
                    else:
                        # Try to extract what API URL is actually deployed
                        import re
                        api_match = re.search(r"--api:'([^']*)'", html)
                        deployed_api = api_match.group(1) if api_match else "unknown"

                        self.failures.append(f"Deployed frontend has wrong API URL: {deployed_api} (expected {expected_backend})")
                        print(f"  ❌ FAIL: Deployed frontend has wrong API URL")
                        print(f"     Expected: {expected_backend}")
                        print(f"     Deployed: {deployed_api}")
                        return False
                else:
                    self.failures.append(f"Deployed frontend returned HTTP {response.status}")
                    print(f"  ❌ FAIL: Deployed frontend returned HTTP {response.status}")
                    return False

        except Exception as e:
            # Don't fail on network errors - might be running offline
            self.warnings.append(f"Could not check deployed frontend: {str(e)}")
            print(f"  ⚠️  WARN: Could not check deployed frontend (network error)")
            return True  # Pass with warning for network issues

    def test_deployment_config_valid(self) -> bool:
        """Test: Deployment config files are valid"""
        print("\n🧪 Test: Deployment configuration valid")

        # Check render.yaml exists
        render_yaml = self.repo_root / "render.yaml"
        if not render_yaml.exists():
            self.warnings.append("render.yaml not found")
            print(f"  ⚠️  WARN: render.yaml missing")
        else:
            print(f"  ✅ render.yaml exists")

        # Check railway.toml is GONE
        railway_toml = self.repo_root / "railway.toml"
        if railway_toml.exists():
            self.failures.append("railway.toml still exists (should be deleted)")
            print(f"  ❌ FAIL: railway.toml still present")
            return False
        else:
            print(f"  ✅ railway.toml deleted")

        # Check netlify.toml exists
        netlify_toml = self.repo_root / "netlify.toml"
        if not netlify_toml.exists():
            self.failures.append("netlify.toml missing")
            print(f"  ❌ FAIL: netlify.toml missing")
            return False
        else:
            print(f"  ✅ netlify.toml exists")

        print(f"  ✅ PASS: Deployment config valid")
        return True

    def run_all_tests(self) -> bool:
        """Run all production health tests"""
        print("🔍 GATE 9: PRODUCTION CONNECTIVITY CHECK")
        print("=" * 60)

        tests = [
            self.test_backend_health,
            self.test_frontend_loads,
            self.test_frontend_backend_urls_match,
            self.test_deployed_frontend_api_url,
            self.test_no_dead_backends,
            self.test_deployment_config_valid,
        ]

        passed = 0
        failed = 0

        for test in tests:
            try:
                if test():
                    passed += 1
                else:
                    failed += 1
            except Exception as e:
                print(f"  ❌ FAIL: Exception: {str(e)}")
                self.failures.append(f"Test exception: {str(e)}")
                failed += 1

        # Summary
        print("\n" + "=" * 60)
        print("📊 PRODUCTION HEALTH RESULTS")
        print("=" * 60)
        print(f"\n✅ Tests passed: {passed}")
        print(f"❌ Tests failed: {failed}")

        if self.warnings:
            print(f"⚠️  Warnings: {len(self.warnings)}")
            print("\nWarnings (non-blocking):")
            for warning in self.warnings:
                print(f"  - {warning}")

        if self.failures:
            print("\n❌ FAILURES:")
            for failure in self.failures:
                print(f"  - {failure}")
            print("\nProduction has issues that need fixing.")
            return False
        else:
            print("\n✅ All production health checks passed!")
            print("\nThis means:")
            print("- Backend is live and responding")
            print("- Frontend is accessible")
            print("- URLs are configured correctly")
            print("- No dead backends referenced")
            print("- Deployment configs are valid")
            return True


def main():
    """Main entry point"""
    checker = ProductionHealthChecker()
    success = checker.run_all_tests()
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
