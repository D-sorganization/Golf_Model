# MATLAB Linting Quick Start Guide

**TL;DR**: Automated MATLAB quality checks without needing MATLAB licenses in CI/CD.

## The Problem

- MATLAB Home licenses can't be used in CI/CD pipelines
- You need automated quality checks for pull requests
- Manual code review is time-consuming

## The Solution

**Hybrid Approach:**
- **Local**: Use MATLAB's full linter (with your Home license)
- **CI/CD**: Use Python static analysis (no MATLAB needed)

## Quick Setup (5 minutes)

### 1. Install Git Hooks

```bash
./.githooks/install-hooks.sh
```

This enables:
- **pre-commit**: Fast Python checks before each commit
- **pre-push**: Full MATLAB checks before pushing (if MATLAB available)

### 2. Done!

Now your code is automatically checked:
- ✅ Before every commit (Python static analysis)
- ✅ Before every push (MATLAB quality checks if available)
- ✅ On every pull request (CI/CD with Python)

## Running Quality Checks Manually

### With MATLAB (Comprehensive)

```matlab
addpath('matlab_utilities/quality');
results = run_quality_checks('.');
```

### Without MATLAB (Static Analysis)

```bash
python matlab_utilities/scripts/matlab_quality_check.py
```

## What Gets Checked?

- ❌ Missing docstrings and arguments blocks
- ❌ TODO, FIXME, HACK, XXX placeholders
- ❌ Magic numbers (undefined constants)
- ❌ Bad practices (eval, global variables, etc.)
- ❌ Workspace pollution (clear, clc in functions)
- ✅ Proper function structure
- ✅ Code quality and maintainability

## Bypassing Checks (Emergency Only)

```bash
git commit --no-verify   # Skip pre-commit
git push --no-verify     # Skip pre-push
```

## Common Issues

### "Too many issues found"

This is normal for existing codebases. Options:
1. Fix issues incrementally
2. Use non-strict mode (see full docs)
3. Customize exclusions in the utilities

### "MATLAB not found in pre-push"

**Expected!** The hook falls back to Python static analysis automatically.

### "Pre-commit hook not running"

```bash
# Reinstall hooks
./.githooks/install-hooks.sh
```

## Full Documentation

See: [docs/MATLAB_LINTING_AND_CI_SETUP.md](docs/MATLAB_LINTING_AND_CI_SETUP.md)

## File Structure

```
├── matlab_utilities/           # Reusable quality tools
│   ├── quality/               # MATLAB quality checkers
│   │   ├── run_quality_checks.m
│   │   └── exportCodeIssues.m
│   └── scripts/               # Python tools (no MATLAB needed)
│       └── matlab_quality_check.py
├── .githooks/                 # Git hook templates
│   ├── pre-commit            # Fast Python checks
│   ├── pre-push              # Full MATLAB checks
│   └── install-hooks.sh      # Setup script
└── .github/workflows/ci.yml   # CI/CD configuration
```

## Next Steps

1. ✅ Hooks are installed - no action needed
2. 📝 Write code as usual
3. 🔍 Pre-commit catches issues automatically
4. ✨ Review CI quality reports on pull requests
5. 🎯 Fix issues before merging

---

**Need help?** See full documentation: `docs/MATLAB_LINTING_AND_CI_SETUP.md`
