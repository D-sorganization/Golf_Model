# AI-Assisted Development Guide

**Last Updated:** November 21, 2025

This guide provides best practices for using AI coding assistants (GitHub Copilot, Cursor IDE, etc.) with this repository.

## 1. Repository Structure Standards

### Python Project Structure

```text
project_name/
├── README.md
├── requirements.txt
├── setup.py (for packages)
├── .gitignore
├── .env.example
├── src/
│   └── project_name/
│       ├── __init__.py
│       ├── main.py
│       ├── gui/
│       │   ├── __init__.py
│       │   └── main_window.py
│       └── utils/
│           ├── __init__.py
│           └── helpers.py
├── tests/
│   ├── __init__.py
│   └── test_main.py
├── docs/
├── data/ (if applicable)
└── scripts/
```

### MATLAB Project Structure

```text
matlab_project/
├── README.md
├── main.m
├── src/
│   ├── functions/
│   ├── classes/
│   └── gui/
├── data/
├── tests/
├── docs/
└── output/
```

## 2. AI Assistant Configuration

### GitHub Copilot

- Configuration via `.github/copilot-instructions.md` (already set up in this repo)
- Uses repository context automatically
- Respects `.gitignore` patterns

### Cursor IDE

Create a `.cursor-rules` file in your local workspace (not committed to repo):

```text
# Python Development Rules
- Use Python 3.11+ syntax and best practices
- Follow PEP 8 style guidelines
- Use type hints for all function parameters and return values
- Prefer dataclasses over dictionaries for structured data
- Use pathlib instead of os.path for file operations
- Always include docstrings for functions and classes

# MATLAB Rules
- Use descriptive function and variable names
- Include function documentation headers
- Validate input arguments at function start
- Verify critical helper functions are on the MATLAB path before execution
- Use vectorized operations instead of loops when possible
- Follow MATLAB naming conventions (camelCase for functions)

# Version Control Rules
- Make atomic commits with descriptive messages
- Use conventional commit format: type(scope): description
- Never commit secrets, API keys, or sensitive data
- Update requirements.txt when adding dependencies
- Write clear commit messages explaining the "why"

# Code Quality Rules
- Add error handling for external dependencies
- Write unit tests for core functionality
- Use logging instead of print statements for debugging
- Validate user inputs in GUI applications
- Handle exceptions gracefully with user-friendly messages
```

## 3. Git Workflow Rules

### Branch Strategy

- **main/master**: Production-ready code only
- **develop**: Integration branch for features (if using)
- **feature/**: Individual features (`feature/add-login-gui`)
- **hotfix/**: Critical bug fixes (`hotfix/fix-crash-bug`)
- **chore/**: Maintenance tasks (`chore/update-deps`)

### Commit Rules

1. **Atomic commits**: One logical change per commit
2. **Descriptive messages**: Use conventional commit format

   ```text
   type(scope): description

   Examples:
   feat(gui): add user login dialog
   fix(data): resolve CSV parsing error
   docs: update installation instructions
   refactor(model): simplify parameter handling
   test(utils): add unit tests for helpers
   chore: update dependencies
   ```

3. **Commit message types**:
   - `feat`: New feature
   - `fix`: Bug fix
   - `docs`: Documentation
   - `style`: Formatting, no code change
   - `refactor`: Code restructuring
   - `test`: Adding tests
   - `chore`: Maintenance
   - `perf`: Performance improvement

### Pre-Commit Checklist

- [ ] Code runs without errors
- [ ] All tests pass (`run_matlab_tests` or `pytest`)
- [ ] No sensitive data (API keys, passwords)
- [ ] Requirements.txt updated (Python)
- [ ] Documentation updated if needed
- [ ] Pre-commit hooks pass: `pre-commit run --all-files`

## 4. AI Safety Guidelines

### Code Review Before Accepting

1. **Always review suggestions** before accepting
2. **Understand the code** - don't accept what you don't understand
3. **Check for security issues**:
   - Hardcoded credentials
   - SQL injection vulnerabilities
   - Unsafe file operations
   - Network security issues
   - Path traversal vulnerabilities

### AI Usage Best Practices

- Use AI for **boilerplate** and **common patterns**
- **Verify algorithms** and complex logic manually
- **Test generated code** thoroughly
- **Document generated functions** in your own words
- **Customize suggestions** to match project coding style
- **Don't blindly accept** large refactors without understanding

### What to Double-Check

- **File operations**: Ensure proper path validation
- **Database queries**: Check for SQL injection risks
- **User input handling**: Validate and sanitize all inputs
- **Error handling**: Verify exceptions are caught appropriately
- **Resource cleanup**: Ensure files, connections, etc. are closed
- **Type safety**: Verify type hints are correct and meaningful

## 5. Python-Specific Guidelines

### Code Style

```python
# ✅ Good - Type hints, docstring, error handling
def process_golf_data(file_path: Path, threshold: float = 0.5) -> pd.DataFrame:
    """
    Process golf swing data from CSV file.
    
    Args:
        file_path: Path to input CSV file
        threshold: Minimum confidence threshold (0-1)
        
    Returns:
        Processed DataFrame with filtered data
        
    Raises:
        FileNotFoundError: If input file doesn't exist
        ValueError: If threshold is out of range
    """
    if not file_path.exists():
        raise FileNotFoundError(f"Data file not found: {file_path}")
    
    if not 0 <= threshold <= 1:
        raise ValueError(f"Threshold must be 0-1, got {threshold}")
    
    df = pd.read_csv(file_path)
    return df[df['confidence'] >= threshold]

# ❌ Bad - No types, no docstring, poor error handling
def process(path, thresh=0.5):
    return pd.read_csv(path)[pd.read_csv(path)['confidence'] >= thresh]
```

### Dependencies

- Pin versions in `requirements.txt`
- Use virtual environments (venv or conda)
- Check for vulnerabilities: `pip-audit` (if available)

## 6. MATLAB-Specific Guidelines

### Function Documentation

```matlab
% ✅ Good - Clear documentation, input validation
function results = analyzeSwingData(data, options)
    % ANALYZESWINGDATA Process golf swing kinematic data
    %
    %   results = analyzeSwingData(data, options)
    %
    %   Inputs:
    %       data - Struct with fields: time, position, velocity
    %       options - Struct with optional parameters:
    %                 .smoothing (logical, default: true)
    %                 .plotResults (logical, default: false)
    %
    %   Outputs:
    %       results - Struct with analysis metrics
    %
    %   Example:
    %       opts.smoothing = true;
    %       results = analyzeSwingData(swingData, opts);
    
    arguments
        data struct
        options.smoothing (1,1) logical = true
        options.plotResults (1,1) logical = false
    end
    
    % Function implementation
    % ...
end

% ❌ Bad - No documentation, no validation
function r = analyze(d, o)
    r = struct();
end
```

### Path Management

- Use `addpath(genpath(...))` sparingly
- Prefer explicit path management
- Clean up paths in cleanup functions
- Verify dependencies before execution

## 7. Testing Requirements

### Python Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific test file
pytest tests/test_processing.py -v
```

### MATLAB Testing

```matlab
% Run all tests
cd matlab
run_matlab_tests

% Run specific test
runtests('tests/testSwingAnalysis.m')
```

## 8. Continuous Integration

This repository uses GitHub Actions for CI. All PRs must pass:

- Pre-commit hooks (ruff, mypy for Python)
- Test suite (pytest for Python, run_matlab_tests for MATLAB)
- Code quality checks

See `.github/workflows/` for workflow definitions.

## 9. Common Pitfalls

### Security

- ❌ Never commit `.env` files with real credentials
- ❌ Don't hardcode API keys or passwords
- ❌ Avoid `eval()` or `exec()` with user input
- ✅ Use environment variables for secrets
- ✅ Validate all user inputs
- ✅ Use parameterized queries for databases

### Performance

- ❌ Don't load entire datasets into memory unnecessarily
- ❌ Avoid nested loops on large datasets (use vectorization)
- ✅ Profile code before optimizing
- ✅ Use appropriate data structures
- ✅ Cache expensive computations

### Maintenance

- ❌ Don't leave commented-out code
- ❌ Avoid magic numbers (use named constants)
- ❌ Don't create functions with 10+ parameters
- ✅ Refactor complex functions into smaller units
- ✅ Write self-documenting code with clear names
- ✅ Add comments only when code intent isn't clear

## 10. Getting Help

- **Documentation**: Check `docs/` directory
- **Examples**: See `examples/` directory
- **MATLAB Setup**: See `matlab/SETUP_INSTRUCTIONS.md`
- **Issues**: Open a GitHub issue with:
  - Clear description of the problem
  - Steps to reproduce
  - Expected vs actual behavior
  - Environment details (MATLAB version, Python version, OS)

## 11. Daily Development Workflow

```bash
# Morning: Update and check status
git pull origin main
git status

# Create feature branch
git checkout -b feature/your-feature

# Work: Make changes, commit frequently
git add <files>
git commit -m "feat(scope): description"

# Run quality checks before pushing
pre-commit run --all-files
# Or for Python: ruff check . && mypy .
# Or for MATLAB: run_matlab_tests

# Push and create PR
git push origin feature/your-feature
# Open PR on GitHub
```

## 12. Emergency Procedures

### Accidentally Committed Sensitive Data

```bash
# Remove file from history (use with caution)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/sensitive/file" \
  --prune-empty --tag-name-filter cat -- --all

# Rotate any exposed credentials immediately
```

### Need to Undo Last Commit

```bash
# Keep changes, undo commit
git reset --soft HEAD~1

# Discard changes (be careful!)
git reset --hard HEAD~1
```

### Broke the Build

```bash
# Check what changed
git diff main...HEAD

# Run tests locally
pre-commit run --all-files
pytest  # or run_matlab_tests

# If needed, revert
git revert <commit-sha>
```

---

**Remember**: AI assistants are powerful tools, but you are responsible for the code you commit.
Always review, test, and understand AI-generated code before merging.
