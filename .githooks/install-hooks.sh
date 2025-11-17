#!/bin/bash
# Install Git hooks for MATLAB quality checks
#
# This script installs the pre-commit and pre-push hooks that automatically
# run quality checks before committing and pushing code.
#
# Usage:
#   ./githooks/install-hooks.sh

set -e

echo ""
echo "========================================="
echo "Installing Git Hooks"
echo "========================================="
echo ""

# Get the git repository root
GIT_ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$GIT_ROOT/.githooks"
GIT_HOOKS_DIR="$GIT_ROOT/.git/hooks"

# Check if we're in a git repository
if [ ! -d "$GIT_ROOT/.git" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Method 1: Configure git to use .githooks directory (recommended)
echo "Configuring git to use .githooks directory..."
git config core.hooksPath .githooks

if [ $? -eq 0 ]; then
    echo "✅ Git configured to use .githooks directory"
    echo ""
    echo "Installed hooks:"
    echo "  - pre-commit: Quick Python static analysis"
    echo "  - pre-push: Comprehensive MATLAB quality checks"
    echo ""
else
    echo "⚠️  Could not configure git hooks path, falling back to manual copy..."
    echo ""

    # Method 2: Copy hooks manually (fallback)
    if [ -f "$HOOKS_DIR/pre-commit" ]; then
        cp "$HOOKS_DIR/pre-commit" "$GIT_HOOKS_DIR/pre-commit"
        chmod +x "$GIT_HOOKS_DIR/pre-commit"
        echo "✅ Installed pre-commit hook"
    fi

    if [ -f "$HOOKS_DIR/pre-push" ]; then
        cp "$HOOKS_DIR/pre-push" "$GIT_HOOKS_DIR/pre-push"
        chmod +x "$GIT_HOOKS_DIR/pre-push"
        echo "✅ Installed pre-push hook"
    fi
    echo ""
fi

echo "========================================="
echo "Installation Complete!"
echo "========================================="
echo ""
echo "What happens now:"
echo "  • pre-commit: Runs Python static analysis on every commit"
echo "  • pre-push: Runs comprehensive quality checks before push"
echo ""
echo "To bypass hooks (NOT recommended):"
echo "  git commit --no-verify"
echo "  git push --no-verify"
echo ""
echo "To uninstall hooks:"
echo "  git config --unset core.hooksPath"
echo ""
