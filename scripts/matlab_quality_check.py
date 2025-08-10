#!/usr/bin/env python3
"""
MATLAB Quality Check Script

This script runs comprehensive quality checks on MATLAB code following the project's
.cursorrules.md requirements. It can be run from the command line and integrates
with the project's quality control system.

Usage:
    python scripts/matlab_quality_check.py [--strict] [--output-format json|text]
"""

import sys
import json
import subprocess
import argparse
from pathlib import Path
from typing import Dict, List, Any
import logging

# Set up logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


class MATLABQualityChecker:
    """Comprehensive MATLAB code quality checker."""

    def __init__(self, project_root: Path):
        """Initialize the MATLAB quality checker.

        Args:
            project_root: Path to the project root directory
        """
        self.project_root = project_root
        self.matlab_dir = project_root / "matlab"
        self.results = {
            "timestamp": None,
            "total_files": 0,
            "issues": [],
            "passed": True,
            "summary": "",
            "checks": {},
        }

    def check_matlab_files_exist(self) -> bool:
        """Check if MATLAB files exist in the project.

        Returns:
            True if MATLAB files are found, False otherwise
        """
        if not self.matlab_dir.exists():
            logger.error(f"MATLAB directory not found: {self.matlab_dir}")
            return False

        m_files = list(self.matlab_dir.rglob("*.m"))
        self.results["total_files"] = len(m_files)

        if len(m_files) == 0:
            logger.warning("No MATLAB files found")
            return False

        logger.info(f"Found {len(m_files)} MATLAB files")
        return True

    def run_matlab_quality_checks(self) -> Dict[str, Any]:
        """Run MATLAB quality checks using the MATLAB script.

        Returns:
            Dictionary containing quality check results
        """
        try:
            # Check if we can run MATLAB from command line
            matlab_script = self.matlab_dir / "matlab_quality_config.m"
            if not matlab_script.exists():
                logger.error(f"MATLAB quality config script not found: {matlab_script}")
                return {"error": "MATLAB quality config script not found"}

            # Try to run MATLAB quality checks
            # Note: This requires MATLAB to be installed and accessible from command line
            try:
                # First, try to run the MATLAB script directly if possible
                result = self._run_matlab_script(matlab_script)
                return result
            except Exception as e:
                logger.warning(f"Could not run MATLAB script directly: {e}")
                # Fall back to static analysis
                return self._static_matlab_analysis()

        except Exception as e:
            logger.error(f"Error running MATLAB quality checks: {e}")
            return {"error": str(e)}

    def _run_matlab_script(self, script_path: Path) -> Dict[str, Any]:
        """Attempt to run MATLAB script from command line.

        Args:
            script_path: Path to the MATLAB script

        Returns:
            Dictionary containing script results
        """
        try:
            # Try different ways to run MATLAB
            commands = [
                ["matlab", "-batch", f"run('{script_path}')"],
                [
                    "matlab",
                    "-nosplash",
                    "-nodesktop",
                    "-batch",
                    f"run('{script_path}')",
                ],
                ["octave", "--no-gui", "--eval", f"run('{script_path}')"],
            ]

            for cmd in commands:
                try:
                    logger.info(f"Trying command: {' '.join(cmd)}")
                    result = subprocess.run(
                        cmd,
                        capture_output=True,
                        text=True,
                        cwd=self.matlab_dir,
                        timeout=300,  # 5 minute timeout
                    )

                    if result.returncode == 0:
                        logger.info("MATLAB quality checks completed successfully")
                        return {
                            "success": True,
                            "output": result.stdout,
                            "method": "matlab_script",
                        }
                    else:
                        logger.warning(
                            f"Command failed with return code {result.returncode}"
                        )
                        logger.debug(f"stderr: {result.stderr}")

                except (subprocess.TimeoutExpired, FileNotFoundError):
                    continue

            # If all commands fail, fall back to static analysis
            logger.info("All MATLAB commands failed, falling back to static analysis")
            return self._static_matlab_analysis()

        except Exception as e:
            logger.error(f"Error running MATLAB script: {e}")
            return {"error": str(e)}

    def _static_matlab_analysis(self) -> Dict[str, Any]:
        """Perform static analysis of MATLAB files without running MATLAB.

        Returns:
            Dictionary containing static analysis results
        """
        logger.info("Performing static MATLAB file analysis")

        issues = []
        total_files = 0

        # Analyze each MATLAB file
        for m_file in self.matlab_dir.rglob("*.m"):
            total_files += 1
            file_issues = self._analyze_matlab_file(m_file)
            issues.extend(file_issues)

        self.results["total_files"] = total_files
        self.results["issues"] = issues
        self.results["passed"] = len(issues) == 0

        return {
            "success": True,
            "method": "static_analysis",
            "total_files": total_files,
            "issues": issues,
            "passed": len(issues) == 0,
        }

    def _analyze_matlab_file(self, file_path: Path) -> List[str]:
        """Analyze a single MATLAB file for quality issues.

        Args:
            file_path: Path to the MATLAB file

        Returns:
            List of quality issues found
        """
        issues = []

        try:
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
                lines = content.split("\n")

            # Check for basic quality issues
            for i, line in enumerate(lines, 1):
                line = line.strip()

                # Skip empty lines and comments
                if not line or line.startswith("%"):
                    continue

                # Check for function definition
                if line.startswith("function"):
                    # Check if next non-empty line has docstring
                    has_docstring = False
                    for j in range(i, min(i + 5, len(lines))):
                        next_line = lines[j].strip()
                        if next_line and not next_line.startswith("%"):
                            break
                        if next_line.startswith("%") and len(next_line) > 3:
                            has_docstring = True
                            break

                    if not has_docstring:
                        issues.append(
                            f"{file_path.name} (line {i}): Missing function docstring"
                        )

                    # Check for arguments validation block
                    has_arguments = False
                    for j in range(i, min(i + 10, len(lines))):
                        if "arguments" in lines[j]:
                            has_arguments = True
                            break

                    if not has_arguments:
                        issues.append(
                            f"{file_path.name} (line {i}): Missing arguments validation block"
                        )

                # Check for banned patterns
                banned_patterns = [
                    ("TODO", "TODO placeholder found"),
                    ("FIXME", "FIXME placeholder found"),
                    ("HACK", "HACK comment found"),
                    ("XXX", "XXX comment found"),
                    ("<.*>", "Angle bracket placeholder found"),
                    ("\\{\\{.*\\}\\}", "Template placeholder found"),
                    ("3\\.14", "Use math.pi instead of 3.14"),
                    ("1\\.57", "Use math.pi/2 instead of 1.57"),
                    ("0\\.785", "Use math.pi/4 instead of 0.785"),
                ]

                for pattern, message in banned_patterns:
                    if pattern in line:
                        issues.append(f"{file_path.name} (line {i}): {message}")
                        break

                # Check for magic numbers
                import re

                magic_numbers = re.findall(r"\b\d+\.\d+\b", line)
                for num in magic_numbers:
                    if num not in [
                        "0.0",
                        "1.0",
                        "2.0",
                        "3.0",
                        "4.0",
                        "5.0",
                        "10.0",
                        "100.0",
                    ]:
                        issues.append(
                            f"{file_path.name} (line {i}): Magic number {num} should be defined as constant"
                        )

        except Exception as e:
            issues.append(f"{file_path.name}: Could not analyze file - {str(e)}")

        return issues

    def run_all_checks(self) -> Dict[str, Any]:
        """Run all MATLAB quality checks.

        Returns:
            Dictionary containing all quality check results
        """
        logger.info("Starting MATLAB quality checks")

        # Check if MATLAB files exist
        if not self.check_matlab_files_exist():
            self.results["passed"] = False
            self.results["summary"] = "No MATLAB files found"
            return self.results

        # Run MATLAB quality checks
        matlab_results = self.run_matlab_quality_checks()

        if "error" in matlab_results:
            self.results["passed"] = False
            self.results[
                "summary"
            ] = f"MATLAB quality checks failed: {matlab_results['error']}"
            self.results["checks"]["matlab"] = matlab_results
        else:
            self.results["checks"]["matlab"] = matlab_results
            if matlab_results.get("passed", False):
                self.results[
                    "summary"
                ] = f"✅ MATLAB quality checks PASSED ({self.results['total_files']} files checked)"
            else:
                self.results["passed"] = False
                self.results[
                    "summary"
                ] = f"❌ MATLAB quality checks FAILED ({self.results['total_files']} files checked)"

        return self.results


def main():
    """Main entry point for the MATLAB quality check script."""
    parser = argparse.ArgumentParser(description="MATLAB Code Quality Checker")
    parser.add_argument("--strict", action="store_true", help="Enable strict mode")
    parser.add_argument(
        "--output-format",
        choices=["json", "text"],
        default="text",
        help="Output format (default: text)",
    )
    parser.add_argument(
        "--project-root",
        type=str,
        default=".",
        help="Project root directory (default: current directory)",
    )

    args = parser.parse_args()

    # Get project root
    project_root = Path(args.project_root).resolve()
    if not project_root.exists():
        logger.error(f"Project root does not exist: {project_root}")
        sys.exit(1)

    # Initialize and run quality checks
    checker = MATLABQualityChecker(project_root)
    results = checker.run_all_checks()

    # Output results
    if args.output_format == "json":
        print(json.dumps(results, indent=2, default=str))
    else:
        print("\n" + "=" * 60)
        print("MATLAB QUALITY CHECK RESULTS")
        print("=" * 60)
        print(f"Timestamp: {results.get('timestamp', 'N/A')}")
        print(f"Total Files: {results.get('total_files', 0)}")
        print(f"Status: {'PASSED' if results.get('passed', False) else 'FAILED'}")
        print(f"Summary: {results.get('summary', 'N/A')}")

        if results.get("issues"):
            print(f"\nIssues Found ({len(results['issues'])}):")
            for i, issue in enumerate(results["issues"], 1):
                print(f"  {i}. {issue}")

        print("\n" + "=" * 60)

    # Exit with appropriate code
    sys.exit(0 if results.get("passed", False) else 1)


if __name__ == "__main__":
    main()
