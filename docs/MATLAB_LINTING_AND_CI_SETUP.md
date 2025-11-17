# MATLAB Linting and CI/CD Setup Guide

This guide explains how to set up automated MATLAB linting and quality checks for both local development and CI/CD pipelines.

## Table of Contents

1. [Overview](#overview)
2. [The Challenge: MATLAB Licenses and CI/CD](#the-challenge-matlab-licenses-and-cicd)
3. [Solution: Hybrid Approach](#solution-hybrid-approach)
4. [Quick Start](#quick-start)
5. [Available Tools](#available-tools)
6. [Local Development Setup](#local-development-setup)
7. [CI/CD Configuration](#cicd-configuration)
8. [Using the Utilities Package](#using-the-utilities-package)
9. [Quality Checks Performed](#quality-checks-performed)
10. [Troubleshooting](#troubleshooting)

---

## Overview

This project uses a **hybrid approach** for MATLAB code quality checking:

- **Local Development**: Uses MATLAB's built-in Code Analyzer (`checkcode`/`mlint`) for comprehensive analysis
- **CI/CD Pipeline**: Uses Python-based static analysis (no MATLAB license required)
- **Pre-commit/Pre-push Hooks**: Automated quality gates to catch issues before they reach the repository

All tools are organized in the `matlab_utilities/` package, making them reusable across multiple projects.

---

## The Challenge: MATLAB Licenses and CI/CD

### MATLAB Home License Restrictions

MATLAB Home licenses **cannot be used for CI/CD** because:
- They are restricted to personal learning and hobby projects only
- Cannot be installed on CI/CD servers or cloud infrastructure
- Cannot be used for commercial, academic, or organizational purposes
- Violating these terms can result in license termination

### The Solution

We provide **two complementary tools**:

1. **MATLAB-based linting** (for local development with your Home license)
   - Full MATLAB Code Analyzer capabilities
   - Comprehensive syntax and semantic checking
   - Runs on your local machine where you have MATLAB installed

2. **Python-based static analysis** (for CI/CD without MATLAB)
   - No MATLAB license required
   - Fast execution (no MATLAB engine startup)
   - Checks for common quality issues and anti-patterns
   - Runs in GitHub Actions or any CI/CD environment

---

## Solution: Hybrid Approach

```
┌─────────────────────────────────────────────────────────────────┐
│                    Developer Workflow                            │
└─────────────────────────────────────────────────────────────────┘

   Local Development              Git Hooks              CI/CD Pipeline
   ─────────────────              ─────────              ──────────────

┌──────────────────┐         ┌──────────────┐         ┌──────────────┐
│  Write Code      │         │ pre-commit   │         │ GitHub       │
│  in MATLAB       │────────▶│ (Python)     │────────▶│ Actions      │
│                  │         │ Quick checks │         │ (Python)     │
└──────────────────┘         └──────────────┘         └──────────────┘
         │                            │                        │
         │                            │                        │
         ▼                            ▼                        ▼
┌──────────────────┐         ┌──────────────┐         ┌──────────────┐
│ Run MATLAB       │         │ git commit   │         │ Static       │
│ Quality Checks   │         │              │         │ Analysis     │
│ (Optional)       │         │              │         │              │
└──────────────────┘         └──────────────┘         └──────────────┘
         │                            │                        │
         │                            ▼                        │
         │                   ┌──────────────┐                 │
         │                   │ pre-push     │                 │
         └──────────────────▶│ (MATLAB)     │                 │
                             │ Full checks  │                 │
                             └──────────────┘                 │
                                      │                        │
                                      ▼                        ▼
                             ┌──────────────┐         ┌──────────────┐
                             │ git push     │────────▶│ Build & Test │
                             │              │         │              │
                             └──────────────┘         └──────────────┘
```

---

## Quick Start

### 1. Install Git Hooks

```bash
# Install pre-commit and pre-push hooks
./.githooks/install-hooks.sh
```

This configures:
- **pre-commit**: Fast Python static analysis before each commit
- **pre-push**: Comprehensive MATLAB quality checks before pushing (if MATLAB available)

### 2. Run Quality Checks Manually

**With MATLAB** (comprehensive):
```matlab
% In MATLAB
addpath('matlab_utilities/quality');
results = run_quality_checks('.');
```

**Without MATLAB** (static analysis):
```bash
# In terminal
python matlab_utilities/scripts/matlab_quality_check.py
```

### 3. Review Results

Quality check results show:
- File name and line number of issues
- Issue type (syntax, anti-pattern, banned pattern, etc.)
- Helpful message explaining the problem

---

## Available Tools

### 1. MATLAB-Based Tools

Located in `matlab_utilities/quality/`:

#### `run_quality_checks.m` (Main Interface)
Unified quality checking interface with comprehensive reporting.

```matlab
% Check current directory
results = run_quality_checks();

% Check specific directory with options
results = run_quality_checks('../src', ...
    'OutputFile', 'quality_report.csv', ...
    'Recursive', true, ...
    'ExcludeDirs', {'.git', 'build', 'external'}, ...
    'StrictMode', false, ...
    'Verbose', true);
```

**Outputs:**
- `.passed` - Boolean indicating pass/fail
- `.total_files` - Number of files checked
- `.total_issues` - Number of issues found
- `.issues_table` - Detailed table of all issues
- `.summary` - Summary message

#### `exportCodeIssues.m` (Core Engine)
Runs MATLAB's Code Analyzer and exports results.

```matlab
% Export to CSV
T = exportCodeIssues('.', 'Output', 'issues.csv');

% Export to JSON
T = exportCodeIssues('.', 'Output', 'issues.json');

% Export to Markdown
T = exportCodeIssues('.', 'Output', 'issues.md');
```

#### `matlab_quality_config.m` (Legacy)
Original quality configuration script.

```matlab
results = matlab_quality_config();
```

### 2. Python-Based Tools

Located in `matlab_utilities/scripts/`:

#### `matlab_quality_check.py` (Static Analyzer)
No MATLAB required - performs static analysis on MATLAB files.

```bash
# Basic usage
python matlab_utilities/scripts/matlab_quality_check.py

# JSON output
python matlab_utilities/scripts/matlab_quality_check.py --output-format json

# Strict mode
python matlab_utilities/scripts/matlab_quality_check.py --strict

# Custom project root
python matlab_utilities/scripts/matlab_quality_check.py --project-root /path/to/project
```

**Features:**
- Function docstring validation
- Arguments block checking
- Banned pattern detection (TODO, FIXME, HACK, XXX)
- Magic number detection
- MATLAB anti-pattern detection (eval, global, assignin, etc.)
- Best practices enforcement

### 3. Git Hooks

Located in `.githooks/`:

#### `pre-commit` (Fast Checks)
Runs Python static analysis before each commit.

```bash
# Automatically runs on: git commit
# Skip with: git commit --no-verify
```

#### `pre-push` (Comprehensive Checks)
Runs full MATLAB quality checks before pushing.

```bash
# Automatically runs on: git push
# Skip with: git push --no-verify
```

#### `install-hooks.sh` (Setup)
Installs hooks automatically.

```bash
./.githooks/install-hooks.sh
```

---

## Local Development Setup

### Option 1: Automated Setup (Recommended)

```bash
# Install hooks
./.githooks/install-hooks.sh

# Verify installation
git config core.hooksPath
# Should output: .githooks
```

### Option 2: Manual Setup

```bash
# Copy hooks to .git/hooks
cp .githooks/pre-commit .git/hooks/pre-commit
cp .githooks/pre-push .git/hooks/pre-push

# Make executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/pre-push
```

### Running Quality Checks Manually

**MATLAB Interface:**
```matlab
% Add utilities to path (do this once per session)
addpath('matlab_utilities/quality');

% Run checks on current directory
results = run_quality_checks('.');

% Run checks on specific directory
results = run_quality_checks('matlab/Scripts');

% Save results to file
results = run_quality_checks('.', 'OutputFile', 'quality_report.csv');

% Check if passed
if results.passed
    fprintf('All quality checks passed!\n');
else
    fprintf('Found %d issues in %d files\n', ...
        results.total_issues, results.total_files);
end
```

**Python Interface:**
```bash
# Basic check
python matlab_utilities/scripts/matlab_quality_check.py

# With detailed output
python matlab_utilities/scripts/matlab_quality_check.py --output-format text

# Save JSON report
python matlab_utilities/scripts/matlab_quality_check.py --output-format json > report.json
```

---

## CI/CD Configuration

### GitHub Actions

The CI workflow is configured in `.github/workflows/ci.yml`:

```yaml
- name: Run MATLAB Quality Check (Static Analysis)
  run: |
    python matlab_utilities/scripts/matlab_quality_check.py --output-format json > matlab_quality_results.json || true
    python matlab_utilities/scripts/matlab_quality_check.py --output-format text

- name: Upload MATLAB Quality Report
  if: always()
  uses: actions/upload-artifact@v3
  with:
    name: matlab-quality-report
    path: matlab_quality_results.json
    retention-days: 30
```

**Key features:**
- Runs Python static analysis (no MATLAB license needed)
- Generates JSON and text reports
- Uploads reports as artifacts for review
- Runs on every pull request and push to main

### Pre-commit Integration

The project uses `.pre-commit-config.yaml` for automated checks:

```yaml
- repo: local
  hooks:
    - id: matlab-quality-check
      name: MATLAB Quality Check
      entry: python matlab_utilities/scripts/matlab_quality_check.py
      language: system
      types: [text]
      pass_filenames: false
```

**Usage:**
```bash
# Install pre-commit
pip install pre-commit
pre-commit install

# Run manually
pre-commit run --all-files

# Run specific hook
pre-commit run matlab-quality-check
```

---

## Using the Utilities Package

The `matlab_utilities/` package is designed to be **reusable across projects**.

### Method 1: Copy to New Project

```bash
# Copy entire package to new project
cp -r matlab_utilities /path/to/new/project/

# Copy hooks
cp -r .githooks /path/to/new/project/

# Install in new project
cd /path/to/new/project
./.githooks/install-hooks.sh
```

### Method 2: Git Submodule (Advanced)

```bash
# In your new project
git submodule add <repo-url> matlab_utilities

# Update across all projects
git submodule update --remote --merge
```

### Method 3: Template Repository

Create a template repository with:
- `matlab_utilities/` package
- `.githooks/` directory
- `.github/workflows/ci.yml` configured
- Documentation

Then use GitHub's "Use this template" feature for new projects.

---

## Quality Checks Performed

### MATLAB Code Analyzer Checks

When running with MATLAB (`run_quality_checks.m`):

- **Syntax Errors**: Invalid MATLAB syntax
- **Undefined Variables**: Variables used before definition
- **Unused Variables**: Variables assigned but never used
- **Unreachable Code**: Code that can never execute
- **Missing Semicolons**: Statements that should suppress output
- **Performance Issues**: Inefficient code patterns
- **Code Complexity**: Functions that are too complex

### Python Static Analysis Checks

When running without MATLAB (`matlab_quality_check.py`):

#### Required Structure:
- ✅ Function docstrings
- ✅ Arguments validation blocks
- ✅ Proper error handling

#### Banned Patterns:
- ❌ TODO, FIXME, HACK, XXX placeholders
- ❌ Template placeholders (`<VAR>`, `{{var}}`)

#### Code Quality:
- ⚠️ Magic numbers (undefined constants)
- ⚠️ Physics constants without definition (9.81, 3.14159, etc.)
- ❌ Global variables
- ❌ Use of `eval()`, `evalin()`, `assignin()`
- ❌ `load` without output variable
- ❌ `clear`, `clc`, `close all` in functions
- ⚠️ `exist()` usage (prefer validation or try/catch)
- ❌ `addpath` in functions

#### Best Practices:
- Proper encapsulation
- No workspace pollution
- Explicit path management
- Named constants with units and sources

---

## Troubleshooting

### Issue: Pre-commit hooks not running

**Solution:**
```bash
# Verify hooks are installed
git config core.hooksPath
# Should output: .githooks

# Or check if hooks exist
ls -la .git/hooks/pre-commit
ls -la .git/hooks/pre-push

# Re-install if needed
./.githooks/install-hooks.sh
```

### Issue: MATLAB not found during pre-push

**Expected behavior**: The pre-push hook will fall back to Python static analysis.

**To use MATLAB quality checks:**
```bash
# Ensure MATLAB is in PATH
which matlab

# Or run manually
matlab -batch "addpath('matlab_utilities/quality'); run_quality_checks('.');"
```

### Issue: Too many false positives

**Solution 1**: Use non-strict mode (default):
```matlab
results = run_quality_checks('.', 'StrictMode', false);
```

**Solution 2**: Exclude directories:
```matlab
results = run_quality_checks('.', ...
    'ExcludeDirs', {'.git', 'legacy', 'external', 'third_party'});
```

**Solution 3**: Modify Python analyzer thresholds in `matlab_quality_check.py`

### Issue: CI/CD failing on MATLAB quality checks

**Solution**: CI uses Python static analysis (no MATLAB), so:
1. Run Python analyzer locally to reproduce: `python matlab_utilities/scripts/matlab_quality_check.py`
2. Fix reported issues
3. Commit and push again

### Issue: Want to skip hooks temporarily

**For one commit:**
```bash
git commit --no-verify
```

**For one push:**
```bash
git push --no-verify
```

**Permanently disable:**
```bash
git config --unset core.hooksPath
```

### Issue: Python script not found in CI

**Solution**: Ensure `matlab_utilities/` is committed to git:
```bash
git add matlab_utilities/
git commit -m "Add MATLAB utilities package"
git push
```

---

## Advanced Usage

### Custom Quality Rules

Extend the Python analyzer by modifying `matlab_utilities/scripts/matlab_quality_check.py`:

```python
# Add project-specific checks
def _analyze_matlab_file(self, file_path: Path) -> List[str]:
    # ... existing checks ...

    # Add custom check
    if "my_banned_function" in line_stripped:
        issues.append(f"{file_path.name} (line {i}): Don't use my_banned_function")

    return issues
```

### Integration with VS Code / Cursor

Add to `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "MATLAB Quality Check",
      "type": "shell",
      "command": "python",
      "args": [
        "matlab_utilities/scripts/matlab_quality_check.py",
        "--output-format",
        "text"
      ],
      "problemMatcher": [],
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    }
  ]
}
```

### Automated Reporting

Generate weekly quality reports:

```matlab
% weekly_quality_report.m
function weekly_quality_report()
    % Generate timestamped quality report
    timestamp = datetime('now', 'Format', 'yyyy-MM-dd');
    filename = sprintf('quality_reports/report_%s.csv', timestamp);

    results = run_quality_checks('.', ...
        'OutputFile', filename, ...
        'Verbose', true);

    % Email results (requires email configuration)
    if results.total_issues > 0
        fprintf('Found %d issues - see %s\n', results.total_issues, filename);
    end
end
```

---

## Best Practices

1. **Run MATLAB quality checks locally** before committing
2. **Let pre-commit hooks catch simple issues** early
3. **Use pre-push hooks for comprehensive checks** before sharing code
4. **Review CI quality reports** for all pull requests
5. **Fix issues incrementally** - don't accumulate technical debt
6. **Customize exclusions** for your project needs
7. **Keep utilities package updated** across projects
8. **Document project-specific quality rules**

---

## Summary

| Environment | Tool | MATLAB Required | Speed | Coverage |
|-------------|------|-----------------|-------|----------|
| **Local Dev** | MATLAB Quality Checks | ✅ Yes | 🐌 Slow | ⭐⭐⭐⭐⭐ Comprehensive |
| **Local Dev** | Python Static Analyzer | ❌ No | ⚡ Fast | ⭐⭐⭐ Good |
| **Pre-commit** | Python Static Analyzer | ❌ No | ⚡ Fast | ⭐⭐⭐ Good |
| **Pre-push** | MATLAB Quality Checks | ⚠️ Optional | 🐌 Slow | ⭐⭐⭐⭐⭐ Comprehensive |
| **CI/CD** | Python Static Analyzer | ❌ No | ⚡ Fast | ⭐⭐⭐ Good |

**Recommended Workflow:**
1. Write code in MATLAB
2. Pre-commit hook (Python) catches simple issues
3. Run MATLAB quality checks manually before pushing
4. Pre-push hook (MATLAB if available) provides comprehensive validation
5. CI/CD (Python) provides final safety net

---

## Additional Resources

- [MATLAB Code Analyzer Documentation](https://www.mathworks.com/help/matlab/matlab_prog/check-code-for-errors-and-warnings.html)
- [Project Quality Controls](./MATLAB_QUALITY_CONTROLS.md)
- [Utilities Package README](../matlab_utilities/README.md)
- [Pre-commit Framework](https://pre-commit.com/)

---

**Last Updated**: 2025-11-17
**Version**: 1.0.0
