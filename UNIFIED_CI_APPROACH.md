# Unified CI/CD Approach - Golf_Model Repository

**Last Updated:** 2025-11-22  
**Version:** 1.0.0  
**Repository:** D-sorganization/Golf_Model  
**Tech Stack:** MATLAB (primary), Python (utilities/testing)

---

## Table of Contents

1. [Overview](#overview)
2. [Key CI/CD Principles](#key-cicd-principles)
3. [Tool Versions](#tool-versions)
4. [Workflow Templates](#workflow-templates)
5. [Python CI Workflow](#python-ci-workflow)
6. [MATLAB CI Workflow](#matlab-ci-workflow)
7. [Best Practices](#best-practices)
8. [Security Checks](#security-checks)
9. [Replicant Branch Support](#replicant-branch-support)
10. [Quality Check Scripts](#quality-check-scripts)
11. [Troubleshooting](#troubleshooting)

---

## Overview

This document defines the unified CI/CD approach for the Golf_Model repository and serves as the reference for CI/CD standards across the D-sorganization repositories.

The Golf_Model repository uses a **hybrid approach** for CI/CD:
- **Python code**: Standard Python CI with pytest, ruff, mypy, black
- **MATLAB code**: Hybrid approach with Python-based static analysis (no MATLAB license required)

### Repository Structure

```
Golf_Model/
├── .github/
│   └── workflows/
│       ├── ci.yml                    # Main CI workflow
│       └── pr-quality-check.yml      # PR quality checks
├── python/                            # Python source code
│   ├── src/
│   └── tests/
├── matlab/                            # MATLAB source code
├── matlab_utilities/                  # MATLAB quality tools
│   ├── quality/                       # MATLAB-based checks
│   └── scripts/
│       └── matlab_quality_check.py   # Python-based static analysis
├── scripts/
│   └── quality_check.py              # Python quality checks
├── docs/
│   └── MATLAB_LINTING_AND_CI_SETUP.md  # MATLAB CI details
├── .pre-commit-config.yaml           # Pre-commit hooks
├── ruff.toml                         # Ruff configuration
├── mypy.ini                          # Mypy configuration
├── pytest.ini                        # Pytest configuration
└── requirements.txt                  # Python dependencies
```

---

## Key CI/CD Principles

### 1. Pinned Versions ✅
All tool versions are explicitly specified for reproducibility:

```yaml
pip install ruff==0.5.0 mypy==1.10.0 black==24.4.2 pytest==8.3.3 pytest-cov==6.0.0
```

**Rationale:** Prevents unexpected CI failures from tool updates.

### 2. Comprehensive Detection 🔍
Automatically find source directories:

```bash
# Check multiple possible locations
if [ -f python/requirements.txt ]; then pip install -r python/requirements.txt; fi
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
```

**Rationale:** Works across different repository structures.

### 3. Proper Exit Codes ⚠️
Preserve failure codes for GitHub Actions:

```bash
# ✅ Good - Preserves exit code
ruff check . || exit 1
mypy python/ || exit 1

# ❌ Bad - Masks failures
ruff check . || true
```

**Exception:** Use `continue-on-error: true` in step definition for non-blocking checks.

### 4. Conditional Uploads 📤
Coverage only uploaded when available:

```yaml
- name: Check for coverage file
  id: coverage-check
  run: |
    if find . -name 'coverage.xml' -type f | grep -q .; then
      echo "exists=true" >> $GITHUB_OUTPUT
    else
      echo "exists=false" >> $GITHUB_OUTPUT
    fi

- name: Upload coverage
  if: steps.coverage-check.outputs.exists == 'true'
  uses: codecov/codecov-action@v4
```

**Rationale:** Don't fail CI if coverage file doesn't exist.

### 5. Security Checks 🔒
Dependency scanning and secret detection:

```yaml
- name: Run Bandit security check
  continue-on-error: true  # ✅ Non-blocking for informational purposes
  run: |
    pip install bandit==1.7.7
    bandit -r python/src --exclude '**/tests/**' -f json -o bandit-report.json
```

**Rationale:** Catch security vulnerabilities early.

### 6. Documentation Checks 📚
Markdown linting and docstring validation:

```yaml
- name: Check for docstrings
  continue-on-error: true
  run: |
    pip install pydocstyle==6.3.0
    pydocstyle python/src
```

**Rationale:** Maintain documentation quality.

### 7. Replicant Branch Support 🌳
Include replicant branches in workflow triggers:

```yaml
on:
  push:
    branches: [main, master, copilot/*]
  pull_request:
    branches: [main, master, copilot/*]
```

**Rationale:** CI runs on AI-assisted development branches.

### 8. Quality Check Scripts 📋
Support both standard locations:

```bash
if [ -f scripts/quality-check.py ]; then
  python scripts/quality-check.py
elif [ -f quality_check_script.py ]; then
  python quality_check_script.py
fi
```

**Rationale:** Flexibility across repositories.

### 9. Fail-Fast Strategy ⚡
Always include in matrix strategies:

```yaml
strategy:
  fail-fast: true
  matrix:
    python-version: ['3.10', '3.11', '3.12']
```

**Rationale:** Stop early on first failure to save CI time.

### 10. Cache Patterns 💾
Use comprehensive patterns:

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ matrix.python-version }}-${{ hashFiles('**/*requirements*.txt', '**/pyproject.toml', '**/setup.py') }}
```

**Rationale:** Invalidate cache when any dependency file changes.

---

## Tool Versions

### Python Tools

| Tool | Version | Purpose |
|------|---------|---------|
| ruff | 0.5.0 | Linting (replaces flake8, isort) |
| mypy | 1.10.0 | Type checking |
| black | 24.4.2 | Code formatting |
| pytest | 8.3.3 | Testing framework |
| pytest-cov | 6.0.0 | Coverage measurement |
| bandit | 1.7.7 | Security scanning |
| pydocstyle | 6.3.0 | Docstring validation |

### Python Versions

Test on: **3.10, 3.11, 3.12**

**Rationale:**
- 3.10: Current LTS minimum
- 3.11: Primary development version
- 3.12: Latest stable

### GitHub Actions

| Action | Version | Purpose |
|--------|---------|---------|
| actions/checkout | v4 | Repository checkout |
| actions/setup-python | v5 | Python setup |
| actions/cache | v4 | Dependency caching |
| actions/upload-artifact | v4 | Artifact upload |
| codecov/codecov-action | v4 | Coverage upload |

---

## Workflow Templates

### Standard Python CI Template

```yaml
name: CI - Build and Test

on:
  push:
    branches: [main, master, copilot/*]
    paths:
      - 'python/**'
      - 'scripts/**'
      - '.github/workflows/ci.yml'
      - 'requirements*.txt'
      - 'pyproject.toml'
  pull_request:
    branches: [main, master, copilot/*]
    paths:
      - 'python/**'
      - 'scripts/**'

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"
          cache: 'pip'
          cache-dependency-path: |
            **/*requirements*.txt
            **/pyproject.toml

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          if [ -f python/requirements.txt ]; then pip install -r python/requirements.txt; fi
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
          pip install ruff==0.5.0 mypy==1.10.0 black==24.4.2 pytest==8.3.3 pytest-cov==6.0.0

      - name: Run quality check script
        run: |
          if [ -f scripts/quality-check.py ]; then
            python scripts/quality-check.py || exit 1
          elif [ -f scripts/quality_check.py ]; then
            python scripts/quality_check.py || exit 1
          elif [ -f quality_check_script.py ]; then
            python quality_check_script.py || exit 1
          fi

      - name: Lint with ruff
        run: |
          if [ -f ruff.toml ]; then
            ruff check . || exit 1
          else
            ruff check python/ || exit 1
          fi

      - name: Type check with mypy
        run: |
          if [ -f mypy.ini ]; then
            mypy . --config-file mypy.ini || exit 1
          else
            mypy python/ --ignore-missing-imports || exit 1
          fi

      - name: Format check with black
        run: |
          if [ -d python/src ]; then
            black --check --diff python/src || exit 1
          elif [ -d python ]; then
            black --check --diff python || exit 1
          fi

      - name: Run tests with coverage
        run: |
          if [ -d python/tests ]; then
            cd python
            pytest tests/ --cov=src --cov-report=xml --cov-report=term-missing || exit 1
          fi

      - name: Check for coverage file
        id: coverage-check
        run: |
          if find . -name 'coverage.xml' -type f | grep -q .; then
            echo "exists=true" >> $GITHUB_OUTPUT
          else
            echo "exists=false" >> $GITHUB_OUTPUT
          fi

      - name: Upload coverage
        if: steps.coverage-check.outputs.exists == 'true'
        uses: codecov/codecov-action@v4
        with:
          files: '**/coverage.xml'
          token: ${{ secrets.CODECOV_TOKEN }}
          fail_ci_if_error: false
```

---

## Python CI Workflow

### Complete Example

```yaml
name: Python CI

on:
  push:
    branches: [main, master, copilot/*]
    paths:
      - 'python/**'
      - '.github/workflows/python-ci.yml'
  pull_request:
    branches: [main, master, copilot/*]
    paths:
      - 'python/**'

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: true
      matrix:
        python-version: ['3.10', '3.11', '3.12']

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'
          cache-dependency-path: |
            **/*requirements*.txt
            **/pyproject.toml

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          if [ -f python/requirements.txt ]; then pip install -r python/requirements.txt; fi
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
          pip install ruff==0.5.0 mypy==1.10.0 black==24.4.2 pytest==8.3.3 pytest-cov==6.0.0

      - name: Run quality check
        run: |
          if [ -f scripts/quality-check.py ]; then
            python scripts/quality-check.py || exit 1
          elif [ -f scripts/quality_check.py ]; then
            python scripts/quality_check.py || exit 1
          fi

      - name: Lint with ruff
        run: |
          if [ -f ruff.toml ]; then
            ruff check . || exit 1
          else
            ruff check python/ || exit 1
          fi

      - name: Type check with mypy
        run: |
          mypy python/ --ignore-missing-imports || exit 1

      - name: Format check with black
        run: |
          black --check --diff python/ || exit 1

      - name: Run tests with coverage
        run: |
          pytest python/tests/ --cov=python/src --cov-report=xml --cov-report=term || exit 1

      - name: Upload coverage
        if: matrix.python-version == '3.11'
        uses: codecov/codecov-action@v4
        with:
          file: ./coverage.xml
          token: ${{ secrets.CODECOV_TOKEN }}
          fail_ci_if_error: false
```

### Best Practices

#### Pinned Versions

```yaml
# ✅ Good - Explicit versions
pip install ruff==0.5.0 mypy==1.10.0 black==24.4.2

# ❌ Bad - Unpinned versions
pip install ruff mypy black
```

#### Source Detection

```bash
# Automatically detect Python source directory
if [ -d "python/src" ]; then
    SOURCE_DIR="python/src"
elif [ -d "python" ]; then
    SOURCE_DIR="python"
elif [ -d "src" ]; then
    SOURCE_DIR="src"
else
    echo "No Python source directory found"
    exit 1
fi

pytest "$SOURCE_DIR/tests/"
```

#### Exit Code Preservation

```bash
# ✅ Good - Preserves exit code
ruff check python/ || exit 1
mypy python/ || exit 1

# ❌ Bad - Masks failures
ruff check python/
mypy python/

# ⚠️ Acceptable for non-blocking checks
continue-on-error: true
```

#### Conditional Coverage

```yaml
- name: Upload coverage
  if: matrix.python-version == '3.11'  # Only upload once
  uses: codecov/codecov-action@v4
  with:
    fail_ci_if_error: false  # Don't fail if Codecov is down
```

---

## MATLAB CI Workflow

### Hybrid Approach

**Challenge:** MATLAB Home licenses cannot be used for CI/CD.

**Solution:** Python-based static analysis (no MATLAB license required).

### Complete Example

```yaml
name: MATLAB Quality Checks

on:
  push:
    branches: [main, master, copilot/*]
    paths:
      - 'matlab/**'
      - '.github/workflows/matlab-ci.yml'
  pull_request:
    branches: [main, master, copilot/*]
    paths:
      - 'matlab/**'

jobs:
  matlab-quality:
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Run MATLAB Quality Check (Static Analysis)
        continue-on-error: true  # Non-blocking due to MATLAB license restrictions
        run: |
          echo "=========================================="
          echo "MATLAB Code Quality Checks"
          echo "=========================================="
          python matlab_utilities/scripts/matlab_quality_check.py --output-format json > matlab_quality_results.json
          python matlab_utilities/scripts/matlab_quality_check.py --output-format text || echo "⚠️  Quality issues found - see report above (non-blocking)"

      - name: Upload MATLAB Quality Report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: matlab-quality-report
          path: matlab_quality_results.json
          retention-days: 30
```

### MATLAB Quality Checks

The Python-based static analysis checks for:

#### Required Structure
- ✅ Function docstrings
- ✅ Arguments validation blocks
- ✅ Proper error handling

#### Banned Patterns
- ❌ TODO, FIXME, HACK, XXX placeholders
- ❌ Template placeholders (`<VAR>`, `{{var}}`)

#### Code Quality
- ⚠️ Magic numbers (undefined constants)
- ⚠️ Physics constants without definition (9.81, 3.14159)
- ❌ Global variables
- ❌ Use of `eval()`, `evalin()`, `assignin()`
- ❌ `load` without output variable
- ❌ `clear`, `clc`, `close all` in functions
- ⚠️ `exist()` usage (prefer validation or try/catch)
- ❌ `addpath` in functions

### Local Development

For comprehensive MATLAB checks with full Code Analyzer:

```matlab
% In MATLAB
addpath('matlab_utilities/quality');
results = run_quality_checks('.');
```

See [MATLAB_LINTING_AND_CI_SETUP.md](docs/MATLAB_LINTING_AND_CI_SETUP.md) for details.

---

## Best Practices

### 1. Consistency Across Repositories

All repositories use similar workflow structures:
- Same tool versions across projects
- Standardized job names: lint, test, build, security
- Common patterns for caching, testing, coverage

### 2. Comprehensive Checks

Every repository should have:
- Syntax/style linting
- Type checking (if applicable)
- Unit tests with coverage
- Integration tests (if applicable)
- Security scanning (Bandit, CodeQL, Dependabot)
- Documentation linting

### 3. Fast Feedback

- Run linting before tests (fail fast)
- Use matrix builds for multiple versions
- Cache dependencies (pip cache, npm cache)
- Run jobs in parallel when possible

### 4. Security First

```yaml
- name: Security scan
  continue-on-error: true  # Non-blocking
  run: |
    pip install bandit==1.7.7
    bandit -r python/src --exclude '**/tests/**' -f json -o bandit-report.json
```

### 5. Clear Reporting

- Use step names that describe the action
- Include tool versions in output
- Upload test results as artifacts
- Generate coverage reports

---

## Security Checks

### Bandit (Python Security Scanner)

```yaml
security-check:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.11'

    - name: Run Bandit security check
      continue-on-error: true
      run: |
        pip install bandit==1.7.7
        if [ -d python/src ]; then
          bandit -r python/src --exclude '**/tests/**' -f json -o bandit-report.json
        elif [ -d python ]; then
          bandit -r python --exclude '**/tests/**' -f json -o bandit-report.json
        fi

    - name: Upload Bandit results
      uses: actions/upload-artifact@v4
      with:
        name: bandit-report
        path: bandit-report.json
        if-no-files-found: ignore
```

### CodeQL (Advanced Security)

Enable in repository settings: Settings → Security → Code security and analysis

### Dependabot

Create `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
```

---

## Replicant Branch Support

### Pattern for AI-Assisted Development

```yaml
on:
  push:
    branches:
      - main
      - master
      - copilot/*          # For GitHub Copilot branches
      - claude/*           # For Claude AI branches
  pull_request:
    branches:
      - main
      - master
      - copilot/*
      - claude/*
```

### Repository-Specific Patterns

For repositories with replicant branches:

```yaml
branches:
  - main
  - master
  - claude/RepositoryName_Replicants  # Specific replicant branch
```

**Rationale:** Ensure CI runs on AI-assisted development branches.

---

## Quality Check Scripts

### Standard Locations

The CI workflows check for quality check scripts in this order:

1. `scripts/quality-check.py` (standard name with hyphen)
2. `scripts/quality_check.py` (underscore variant)
3. `quality_check_script.py` (legacy location)

### Integration Pattern

```bash
if [ -f scripts/quality-check.py ]; then
  python scripts/quality-check.py || exit 1
elif [ -f scripts/quality_check.py ]; then
  python scripts/quality_check.py || exit 1
elif [ -f quality_check_script.py ]; then
  python quality_check_script.py || exit 1
else
  echo "⚠️ No quality check script found, skipping..."
fi
```

### Quality Check Requirements

Scripts should check for:
- TODO, FIXME, HACK, XXX placeholders
- NotImplementedError placeholders
- Template placeholders (`<your.*here>`)
- Empty pass statements
- Magic numbers (3.14159, 9.8, etc.)
- Missing docstrings

### Example Quality Check Script

```python
#!/usr/bin/env python3
"""Quality check script to verify code meets standards."""

import re
import sys
from pathlib import Path

BANNED_PATTERNS = [
    (re.compile(r"\bTODO\b"), "TODO placeholder found"),
    (re.compile(r"\bFIXME\b"), "FIXME placeholder found"),
    (re.compile(r"NotImplementedError"), "NotImplementedError placeholder"),
]

def check_file(file_path: Path) -> list[str]:
    """Check a single file for quality issues."""
    issues = []
    with open(file_path, 'r', encoding='utf-8') as f:
        for i, line in enumerate(f, 1):
            for pattern, message in BANNED_PATTERNS:
                if pattern.search(line):
                    issues.append(f"{file_path}:{i}: {message}")
    return issues

def main():
    """Run quality checks on all Python files."""
    python_files = Path('.').rglob('*.py')
    all_issues = []
    
    for file_path in python_files:
        if 'venv' in str(file_path) or '.git' in str(file_path):
            continue
        issues = check_file(file_path)
        all_issues.extend(issues)
    
    if all_issues:
        print("Quality check failed:")
        for issue in all_issues:
            print(f"  {issue}")
        sys.exit(1)
    else:
        print("✅ Quality check passed")

if __name__ == "__main__":
    main()
```

---

## Troubleshooting

### Issue: CI failing on tool version mismatch

**Solution:**
```bash
# Update all workflows to use pinned versions
pip install ruff==0.5.0 mypy==1.10.0 black==24.4.2
```

### Issue: Cache not invalidating

**Solution:**
```yaml
# Use comprehensive cache key pattern
key: ${{ runner.os }}-pip-${{ matrix.python-version }}-${{ hashFiles('**/*requirements*.txt', '**/pyproject.toml') }}
```

### Issue: Tests failing due to missing dependencies

**Solution:**
```bash
# Check both standard locations
if [ -f python/requirements.txt ]; then pip install -r python/requirements.txt; fi
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
```

### Issue: Coverage not uploading

**Solution:**
```yaml
# Check for coverage file existence
- name: Check for coverage file
  id: coverage-check
  run: |
    if find . -name 'coverage.xml' -type f | grep -q .; then
      echo "exists=true" >> $GITHUB_OUTPUT
    fi

- name: Upload coverage
  if: steps.coverage-check.outputs.exists == 'true'
  uses: codecov/codecov-action@v4
```

### Issue: Pre-commit hooks not running

**Solution:**
```bash
# Install pre-commit hooks
pip install pre-commit
pre-commit install

# Run manually
pre-commit run --all-files
```

### Issue: MATLAB quality checks failing in CI

**Expected behavior:** MATLAB checks are non-blocking in CI (no license).

**Solution:**
```yaml
# Use continue-on-error for MATLAB checks
- name: Run MATLAB Quality Check
  continue-on-error: true
  run: python matlab_utilities/scripts/matlab_quality_check.py
```

---

## Additional Resources

- [MATLAB Linting and CI Setup Guide](docs/MATLAB_LINTING_AND_CI_SETUP.md)
- [MATLAB Quality Controls](docs/MATLAB_QUALITY_CONTROLS.md)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Pre-commit Framework](https://pre-commit.com/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [Mypy Documentation](https://mypy.readthedocs.io/)

---

## Summary Table

| Component | Standard | Purpose |
|-----------|----------|---------|
| **Python Versions** | 3.10, 3.11, 3.12 | Test matrix |
| **ruff** | 0.5.0 | Linting |
| **mypy** | 1.10.0 | Type checking |
| **black** | 24.4.2 | Formatting |
| **pytest** | 8.3.3 | Testing |
| **pytest-cov** | 6.0.0 | Coverage |
| **bandit** | 1.7.7 | Security |
| **pydocstyle** | 6.3.0 | Docstrings |
| **Cache Pattern** | `**/*requirements*.txt`, `**/pyproject.toml` | Comprehensive |
| **Exit Codes** | `|| exit 1` | Preserve failures |
| **Fail-Fast** | `true` | Stop on first failure |
| **Replicant Branches** | `copilot/*`, `claude/*` | AI development |

---

**This document is the single source of truth for CI/CD standards in the Golf_Model repository.**

**For questions or improvements, please open an issue or pull request.**
