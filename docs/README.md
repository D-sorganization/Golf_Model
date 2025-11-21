# Golf Model Documentation Index

**Last Updated:** November 21, 2025

This directory contains comprehensive documentation for the Golf Model repository. Documents are organized by category for easy navigation.

## 📚 Quick Start

New to the project? Start here:
1. [Main README](../README.md) - Project overview and setup
2. [MATLAB Setup Instructions](../matlab/SETUP_INSTRUCTIONS.md) - Environment configuration
3. [AI-Assisted Development Guide](AI_ASSISTED_DEVELOPMENT_GUIDE.md) - Best practices for AI coding assistants
4. [MATLAB Linting Quickstart](MATLAB_LINTING_QUICKSTART.md) - Code quality tools

## 📖 Documentation Categories

### Development Standards

**[Guardrails Guidelines](GUARDRAILS_GUIDELINES.md)**
- Universal standards for safety, linting, and CI/CD
- Pre-commit hook configuration
- Continuous integration setup
- Best practices for preventing code quality issues

**[AI-Assisted Development Guide](AI_ASSISTED_DEVELOPMENT_GUIDE.md)** ⭐ *Recommended*
- Best practices for using GitHub Copilot, Cursor, and other AI assistants
- Git workflow and commit conventions
- Security guidelines for AI-generated code
- Python and MATLAB coding standards

### MATLAB Development

**[MATLAB Linting Quickstart](MATLAB_LINTING_QUICKSTART.md)** ⭐ *Start here for MATLAB*
- Quick setup guide for MATLAB code quality tools
- Linting and static analysis configuration
- Integration with pre-commit hooks
- Common issues and solutions

**[MATLAB Linting and CI Setup](MATLAB_LINTING_AND_CI_SETUP.md)**
- Detailed MATLAB CI/CD pipeline configuration
- Advanced linting strategies
- Integration with GitHub Actions
- Custom quality controls

**[MATLAB Quality Controls](MATLAB_QUALITY_CONTROLS.md)**
- Code review checklist
- Performance optimization guidelines
- Testing strategies
- Documentation standards

### Application Guides

**[Data Generator Interface Specification](DATA_GENERATOR_INTERFACE_SPEC.md)**
- Batch simulation system architecture
- Parameter sweep configuration
- Dataset generation workflows
- API reference for Dataset Generator

**[Interactive Signal Plotter Guide](INTERACTIVE_SIGNAL_PLOTTER_GUIDE.md)**
- GUI usage instructions
- Visualization features
- Data import and export
- Customization options

**[Performance Tracking Guide](PERFORMANCE_TRACKING_GUIDE.md)**
- Performance monitoring tools
- Optimization strategies
- Benchmarking procedures
- Profiling MATLAB code

### Project History

**[CHANGELOG](CHANGELOG.md)**
- Project version history
- Notable changes and updates
- Migration guides

**[Archive Directory](archive/)**
- Historical implementation summaries
- Completed phase documentation
- Session-specific work logs
- Legacy guides (for reference only)

## 🔍 Find Documentation by Topic

### Setting Up Your Environment
- [Main README - Quick Start](../README.md#quick-start)
- [MATLAB Setup Instructions](../matlab/SETUP_INSTRUCTIONS.md)
- [MATLAB Cache Configuration](../matlab/CACHE_SETUP.md)

### Code Quality and Testing
- [Guardrails Guidelines](GUARDRAILS_GUIDELINES.md)
- [MATLAB Quality Controls](MATLAB_QUALITY_CONTROLS.md)
- [MATLAB Linting Quickstart](MATLAB_LINTING_QUICKSTART.md)
- [Pre-commit Configuration](../.pre-commit-config.yaml)

### Using the Applications
- [Golf GUI Documentation](../matlab/Scripts/Golf_GUI/)
- [Dataset Generator Interface](DATA_GENERATOR_INTERFACE_SPEC.md)
- [Interactive Signal Plotter](INTERACTIVE_SIGNAL_PLOTTER_GUIDE.md)

### CI/CD and Automation
- [MATLAB Linting and CI Setup](MATLAB_LINTING_AND_CI_SETUP.md)
- [GitHub Actions Workflows](../.github/workflows/)
- [Pre-commit Hooks](../.pre-commit-config.yaml)

### Development Workflow
- [AI-Assisted Development Guide](AI_ASSISTED_DEVELOPMENT_GUIDE.md)
- [GitHub Copilot Instructions](../.github/copilot-instructions.md)
- [Git Workflow Best Practices](AI_ASSISTED_DEVELOPMENT_GUIDE.md#3-git-workflow-rules)

### Performance Optimization
- [Performance Tracking Guide](PERFORMANCE_TRACKING_GUIDE.md)
- [MATLAB Quality Controls - Performance](MATLAB_QUALITY_CONTROLS.md)

## 📝 Documentation Standards

All documentation in this repository follows these standards:

### Structure
- **Purpose** - What problem does this solve?
- **Quick Start** - Minimal steps to get started
- **Detailed Guide** - Comprehensive instructions
- **Examples** - Real-world use cases
- **Troubleshooting** - Common issues and solutions

### Writing Style
- ✅ Concise, specific, and value-dense
- ✅ Active voice ("Run the script" not "The script should be run")
- ✅ Practical examples with command-line snippets
- ✅ Clear headers and organization
- ❌ Avoid jargon without explanation
- ❌ Don't leave TODO items in published docs

### Code Examples
````markdown
```bash
# ✅ Good - Complete, executable command with context
# Run all tests with verbose output
pytest -v tests/

# ❌ Bad - Incomplete or vague
# Run tests
pytest
```
````

### Maintenance
- Update "Last Updated" date when modifying documents
- Remove outdated content (archive if historically valuable)
- Keep examples tested and working
- Review links periodically for broken references

## 🗂️ Contributing to Documentation

### Adding New Documentation
1. Choose appropriate category (Development, MATLAB, Application, etc.)
2. Use clear, descriptive filename (e.g., `FEATURE_USAGE_GUIDE.md`)
3. Follow the documentation structure standards above
4. Add entry to this index (README.md)
5. Include "Last Updated" date in document header

### Updating Existing Documentation
1. Update the content
2. Update "Last Updated" date
3. Test any command examples
4. Verify internal links still work
5. Run markdown linter: `npx markdownlint docs/*.md`

### Archiving Documentation
Move to `archive/` directory when:
- Document describes completed one-time work (implementation summaries)
- Content is superseded by newer documentation
- Historical value but no longer actively maintained

Do not archive:
- Active guides and references
- Standards and best practices documents
- Troubleshooting guides
- API documentation

## 🔗 External Resources

### MATLAB Documentation
- [MATLAB Simscape Multibody](https://www.mathworks.com/products/simscape-multibody.html)
- [MATLAB Code Analyzer](https://www.mathworks.com/help/matlab/code-analyzer.html)
- [MATLAB Unit Testing Framework](https://www.mathworks.com/help/matlab/matlab-unit-test-framework.html)

### Python Documentation
- [Ruff - Python Linter](https://github.com/astral-sh/ruff)
- [mypy - Static Type Checker](https://mypy-lang.org/)
- [pre-commit Framework](https://pre-commit.com/)

### Git and GitHub
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Git Best Practices](https://www.git-scm.com/book/en/v2)

## 📞 Getting Help

Can't find what you need?

1. **Search this index** using Ctrl+F / Cmd+F
2. **Check the archive** - `archive/` may have historical context
3. **Review MATLAB subdirectories** - `matlab/Scripts/*/README.md`
4. **Open an issue** on GitHub with:
   - What you're trying to accomplish
   - What documentation you've checked
   - Specific questions or blockers

---

**Note**: This documentation is actively maintained. If you find errors, outdated information, or areas that need clarification, please submit a PR or open an issue.
