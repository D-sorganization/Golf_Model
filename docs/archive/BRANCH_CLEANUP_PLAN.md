# Branch Cleanup Plan

**Date:** October 29, 2025
**Current Branch:** main
**Status:** Ready for cleanup

---

## Branch Analysis

### Remote Branches

#### ✅ Safe to Delete (Already Merged)

**origin/feature/interactive-signal-plotter**

- Status: Merged via PR #52
- Action: Delete

**origin/feature/merge-smooth-gui**

- Status: Just merged via PR #53
- Action: Delete

#### ⚠️ Evaluate Before Deleting

**origin/modular-architecture-clean**

- Last commit: "Enhance Dataset_GUI with improved error handling"
- Has unique work not in main
- Recommendation: Review before deleting

**origin/restore-1956-columns**

- Purpose: Column restoration work
- Recommendation: Check if still needed

---

### Local Branches

#### ✅ Safe to Delete (Old/Superseded)

**sync-local-main-20250829-202133**

- Purpose: Old sync from August 29
- Status: Superseded by current main
- Action: Delete

**matlab-code-issues-fix**

- Last commit: "Updates to fix the matlab code issues reported"
- Status: Work appears to be in main (PR #51)
- Action: Delete

#### ⚠️ May Have Unique Work - Review First

**cleanup-unused-functions**

- Commits:
  - "Clean up temporary analysis files"
  - "Complete function cleanup: remove 46 unused functions"
  - "Add function usage analysis: identify 46 unused functions"
- **Recommendation:** Keep for now - has analysis of unused functions

**fix-matlab-error-flags**

- Commits:
  - "ENHANCE: Create self-contained Code Analysis GUI package"
- **Recommendation:** Review if Code Analysis GUI package is useful

**fix-path-and-parallel-cleanup**

- Commits:
  - "ENHANCE: Improved sequential simulation handling"
  - "REVERT: Remove problematic sequential fallback"
- **Recommendation:** Review if these fixes are needed

**modular-architecture-clean**

- Commits:
  - "Enhance Dataset_GUI with improved error handling"
  - "Refactor Dataset_GUI for enhanced usability"
  - "Add automatic MATLAB path cleanup"
- **Recommendation:** Review - may have useful refactoring work

#### ✅ Keep (Backup)

**backup/standalone-oct29-2025**

- Purpose: Backup of original standalone version
- Action: **KEEP** - This is your safety backup!

---

## Recommended Cleanup Actions

### Phase 1: Delete Obviously Merged Branches

**Remote branches to delete:**

```bash
git push origin --delete feature/interactive-signal-plotter
git push origin --delete feature/merge-smooth-gui
```

**Local branches to delete:**

```bash
git branch -D sync-local-main-20250829-202133
git branch -D matlab-code-issues-fix
```

### Phase 2: Review and Decide

**Branches to review before deleting:**

1. **cleanup-unused-functions** - Check if function analysis is valuable
2. **fix-matlab-error-flags** - Check if Code Analysis GUI is useful
3. **fix-path-and-parallel-cleanup** - Check if fixes are needed
4. **modular-architecture-clean** (both local and remote) - Check refactoring work
5. **origin/restore-1956-columns** - Check if column restoration is complete

### Phase 3: Archive Before Deleting (Optional)

If any branches have work you might want later:

```bash
# Create a tag to preserve the branch
git tag archive/branch-name branch-name
git push origin archive/branch-name

# Then delete the branch
git branch -D branch-name
```

---

## Quick Cleanup Commands

### Conservative Cleanup (Safe)

```bash
# Delete obviously merged remote branches
git push origin --delete feature/interactive-signal-plotter
git push origin --delete feature/merge-smooth-gui

# Delete old local sync branch
git branch -D sync-local-main-20250829-202133

# Delete local branch that's in main
git branch -D matlab-code-issues-fix
```

### Aggressive Cleanup (If you're sure)

```bash
# Delete all the branches from Phase 1
git push origin --delete feature/interactive-signal-plotter
git push origin --delete feature/merge-smooth-gui
git branch -D sync-local-main-20250829-202133
git branch -D matlab-code-issues-fix

# Delete branches after review (only if you're sure!)
git branch -D cleanup-unused-functions
git branch -D fix-matlab-error-flags
git branch -D fix-path-and-parallel-cleanup
git branch -D modular-architecture-clean
git push origin --delete modular-architecture-clean
git push origin --delete restore-1956-columns
```

---

## Branches to KEEP

**✅ KEEP THESE:**

- `main` - Current working branch
- `backup/standalone-oct29-2025` - Safety backup (local)
- `origin/backup/standalone-oct29-2025` - Safety backup (remote)

---

## Summary

### Recommended for Immediate Deletion

- ✅ origin/feature/interactive-signal-plotter (merged)
- ✅ origin/feature/merge-smooth-gui (merged)
- ✅ sync-local-main-20250829-202133 (old sync)
- ✅ matlab-code-issues-fix (in main)

**Total: 4 branches (2 remote, 2 local)**

### Recommend Review Before Deletion

- ⚠️ cleanup-unused-functions (has function analysis)
- ⚠️ fix-matlab-error-flags (has Code Analysis GUI)
- ⚠️ fix-path-and-parallel-cleanup (has simulation fixes)
- ⚠️ modular-architecture-clean (local + remote, has refactoring)
- ⚠️ origin/restore-1956-columns (column restoration)

**Total: 5 unique branches + 1 remote**

### Must Keep

- ✅ backup/standalone-oct29-2025 (local + remote)

---

## My Recommendation

**Start with conservative cleanup:**

1. Delete the 4 obviously merged/old branches
2. Review the other 5 branches by checking their diffs against main
3. Archive any with unique work you might want later
4. Delete branches after archiving or determining they're not needed

**Would you like me to:**

1. Execute the conservative cleanup now?
2. Help you review the other branches first?
3. Archive and delete all old branches?
