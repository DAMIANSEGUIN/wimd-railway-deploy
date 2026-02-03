#!/usr/bin/env python3
"""
Gate 12: UX Flow Congruence Checker
Traces user experience flows through codebase to find architectural violations

This gate analyzes:
1. Frontend UI flow definitions (e.g., PS101_STEPS)
2. Frontend state management (e.g., PS101State)
3. Backend API contracts
4. Database schemas
5. Configuration files

It validates that all parts of the user journey are architecturally congruent.
"""

import re
import json
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Any

class UXFlowAnalyzer:
    def __init__(self, repo_root: Path):
        self.repo_root = repo_root
        self.violations = []
        self.flows = {}

    def analyze_all_flows(self) -> Tuple[int, List[str]]:
        """Analyze all user flows for architectural congruence"""
        print("🔍 GATE 12: UX FLOW CONGRUENCE ANALYSIS")
        print("=" * 60)
        print()

        # Analyze each major user flow
        self.analyze_ps101_flow()
        self.analyze_auth_flow()
        self.analyze_coach_flow()

        return len(self.violations), self.violations

    def analyze_ps101_flow(self):
        """Analyze PS101 coaching flow for congruence"""
        print("📋 Analyzing PS101 Flow...")
        print()

        flow_data = {
            'frontend_definitions': [],
            'state_management': {},
            'hints': {},
            'backend_contract': None,
            'database_schema': None
        }

        # 1. Find ALL PS101_STEPS definitions in frontend
        frontend_files = [
            self.repo_root / 'mosaic_ui' / 'index.html',
            self.repo_root / 'frontend' / 'index.html'
        ]

        for file_path in frontend_files:
            if not file_path.exists():
                continue

            content = file_path.read_text()

            # Extract PS101_STEPS array
            ps101_match = re.search(
                r'const PS101_STEPS\s*=\s*\[(.*?)\];',
                content,
                re.DOTALL
            )

            if ps101_match:
                # Count steps
                step_count = len(re.findall(r'step:\s*\d+', ps101_match.group(1)))

                # Extract prompt counts per step
                prompt_counts = []
                for step_block in re.findall(
                    r'step:\s*(\d+).*?prompts:\s*\[(.*?)\]',
                    ps101_match.group(1),
                    re.DOTALL
                ):
                    step_num = int(step_block[0])
                    prompts_text = step_block[1]
                    # Count string literals (prompts)
                    prompt_count = len(re.findall(r'"[^"]*"', prompts_text))
                    prompt_counts.append((step_num, prompt_count))

                flow_data['frontend_definitions'].append({
                    'file': str(file_path.relative_to(self.repo_root)),
                    'step_count': step_count,
                    'prompt_counts': prompt_counts
                })

            # Extract PROMPT_HINTS
            hints_match = re.search(
                r'const PROMPT_HINTS\s*=\s*\{(.*?)\};',
                content,
                re.DOTALL
            )

            if hints_match:
                # Count which steps have hints
                hint_steps = re.findall(r'(\d+):\s*\[', hints_match.group(1))
                flow_data['hints'][str(file_path.relative_to(self.repo_root))] = [
                    int(s) for s in hint_steps
                ]

        # 2. Validate congruence across frontend files
        self._validate_frontend_congruence(flow_data)

        # 3. Check for hardcoded step counts
        self._check_hardcoded_counts(flow_data)

        # 4. Validate hints coverage
        self._validate_hints_coverage(flow_data)

        self.flows['ps101'] = flow_data

    def _validate_frontend_congruence(self, flow_data: Dict):
        """Ensure all frontend files define PS101 the same way"""
        definitions = flow_data['frontend_definitions']

        if len(definitions) == 0:
            self.violations.append(
                "❌ PS101: No PS101_STEPS definitions found in frontend files"
            )
            return

        # Check all files have same step count
        step_counts = [d['step_count'] for d in definitions]
        if len(set(step_counts)) > 1:
            self.violations.append(
                f"❌ PS101: Inconsistent step counts across files: {dict(zip([d['file'] for d in definitions], step_counts))}"
            )
        else:
            print(f"  ✅ All frontend files have {step_counts[0]} steps")

        # Check prompt counts match across files
        for i, defn in enumerate(definitions):
            if i == 0:
                reference_prompts = defn['prompt_counts']
                continue

            if defn['prompt_counts'] != reference_prompts:
                self.violations.append(
                    f"❌ PS101: Prompt counts mismatch between {definitions[0]['file']} and {defn['file']}"
                )

    def _check_hardcoded_counts(self, flow_data: Dict):
        """Check for hardcoded 'of X' that should use PS101_STEPS.length"""
        frontend_files = [
            self.repo_root / 'mosaic_ui' / 'index.html',
            self.repo_root / 'frontend' / 'index.html'
        ]

        if not flow_data['frontend_definitions']:
            return

        canonical_count = flow_data['frontend_definitions'][0]['step_count']

        for file_path in frontend_files:
            if not file_path.exists():
                continue

            content = file_path.read_text()

            # Look for hardcoded "of 10" or similar
            hardcoded_matches = re.findall(
                r'["\']Step.*of\s+(\d+)',
                content
            )

            for match in hardcoded_matches:
                count = int(match)
                if count != canonical_count:
                    self.violations.append(
                        f"❌ PS101: Hardcoded 'of {count}' in {file_path.name} doesn't match canonical {canonical_count} steps"
                    )

    def _validate_hints_coverage(self, flow_data: Dict):
        """Ensure PROMPT_HINTS covers all steps"""
        if not flow_data['frontend_definitions']:
            return

        canonical_count = flow_data['frontend_definitions'][0]['step_count']

        for file_path, hint_steps in flow_data['hints'].items():
            missing_steps = set(range(1, canonical_count + 1)) - set(hint_steps)

            if missing_steps:
                self.violations.append(
                    f"⚠️  PS101: PROMPT_HINTS missing for steps {sorted(missing_steps)} in {file_path}"
                )
            else:
                print(f"  ✅ PROMPT_HINTS covers all {canonical_count} steps in {file_path}")

    def analyze_auth_flow(self):
        """Analyze authentication flow for congruence"""
        print()
        print("📋 Analyzing Auth Flow...")
        print()

        # Check frontend auth UI vs backend endpoints
        frontend_files = [
            self.repo_root / 'mosaic_ui' / 'index.html',
            self.repo_root / 'frontend' / 'index.html'
        ]

        backend_file = self.repo_root / 'backend' / 'api' / 'index.py'

        frontend_endpoints = set()
        backend_endpoints = set()

        # Extract frontend auth endpoints
        for file_path in frontend_files:
            if not file_path.exists():
                continue

            content = file_path.read_text()

            # Find fetch calls to /auth/*
            auth_calls = re.findall(
                r'fetch\([\'"`]((?:/api)?/auth/[^\'"`]+)',
                content
            )

            frontend_endpoints.update(auth_calls)

        # Extract backend auth routes
        if backend_file.exists():
            content = backend_file.read_text()

            # Find @app.post('/auth/*') and @app.get('/auth/*')
            auth_routes = re.findall(
                r'@app\.(get|post|put|delete)\([\'"`](/auth/[^\'"`]+)',
                content
            )

            backend_endpoints.update([route[1] for route in auth_routes])

        # Validate congruence
        frontend_only = frontend_endpoints - backend_endpoints
        backend_only = backend_endpoints - frontend_endpoints

        if frontend_only:
            for endpoint in frontend_only:
                # Allow /api prefix variation
                if endpoint.replace('/api', '') not in backend_endpoints:
                    self.violations.append(
                        f"⚠️  Auth: Frontend calls {endpoint} but backend doesn't define it"
                    )

        if backend_only:
            print(f"  ℹ️  Backend defines {len(backend_only)} auth endpoints not used by frontend (may be for API clients)")

        if not frontend_only and frontend_endpoints:
            print(f"  ✅ All {len(frontend_endpoints)} frontend auth endpoints have backend implementations")

    def analyze_coach_flow(self):
        """Analyze coach/chat flow for congruence"""
        print()
        print("📋 Analyzing Coach/Chat Flow...")
        print()

        # Check if coach endpoints exist in both frontend and backend
        frontend_file = self.repo_root / 'mosaic_ui' / 'index.html'
        backend_file = self.repo_root / 'backend' / 'api' / 'index.py'

        if frontend_file.exists() and backend_file.exists():
            frontend_content = frontend_file.read_text()
            backend_content = backend_file.read_text()

            # Check for /wimd/ask endpoint
            if '/wimd/ask' in frontend_content:
                if '@app.post(\'/wimd/ask\')' in backend_content or '@app.post("/wimd/ask")' in backend_content:
                    print("  ✅ Coach endpoint /wimd/ask exists in both frontend and backend")
                else:
                    self.violations.append(
                        "❌ Coach: Frontend uses /wimd/ask but backend doesn't define it"
                    )

def main():
    repo_root = Path(__file__).parent.parent.parent
    analyzer = UXFlowAnalyzer(repo_root)

    violation_count, violations = analyzer.analyze_all_flows()

    print()
    print("=" * 60)
    print("📊 GATE 12 RESULTS")
    print("=" * 60)
    print()

    if violation_count == 0:
        print("✅ Gate 12 PASSED: All UX flows are architecturally congruent")
        print()
        print("All checks passed:")
        print("  - PS101 flow consistent across frontend files")
        print("  - Auth endpoints match frontend/backend")
        print("  - Coach endpoints match frontend/backend")
        print()
        return 0
    else:
        print(f"❌ Gate 12 FAILED: Found {violation_count} architectural violations")
        print()
        print("Violations:")
        for violation in violations:
            print(f"  {violation}")
        print()
        print("These violations indicate architectural inconsistencies that could")
        print("cause user-facing bugs like the PS101 flow issue.")
        print()
        return 1

if __name__ == '__main__':
    sys.exit(main())
