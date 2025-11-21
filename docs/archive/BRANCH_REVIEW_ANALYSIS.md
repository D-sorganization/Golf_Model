# Branch Review Analysis

**Date:** October 29, 2025
**Purpose:** Determine which old branches to keep or delete

---

## Branch-by-Branch Analysis

### 1. cleanup-unused-functions 🗑️ **RECOMMEND DELETE**

**What it contains:**

- Multiple backup folders from Aug 23, 2025
- Function usage analysis documentation
- 46 removed "unused" functions saved to backup
- Dataset_GUI modifications

**Analysis:**

- Contains 5 backup folders with duplicate Dataset_GUI versions
- Documentation: FUNCTION_CLEANUP_SUMMARY.md, FUNCTION_USAGE_ANALYSIS.md
- Many backup functions in `removed_functions_backup/` folder

**Why delete:**

- Backup files are outdated (Aug 23, before many improvements)
- Function cleanup was likely experimental
- Creates 39,274 insertions with mostly duplicated backup code
- Main branch is now more advanced

**How to preserve if needed:**

```bash
# Archive the documentation before deleting
git tag archive/cleanup-unused-functions cleanup-unused-functions
git push origin archive/cleanup-unused-functions
# Then delete the branch
```

**Recommendation:** 🗑️ **DELETE** (or archive first if you want the analysis docs)

---

### 2. fix-matlab-error-flags 💡 **REVIEW - MAY BE USEFUL**

**What it contains:**

- Code Analysis GUI package (self-contained)
- `codeIssuesGUI.m` - GUI for viewing code issues
- `launchCodeAnalyzer.m` - Launcher script
- `setup.m` - Setup script
- README documentation

**Analysis:**

- Only 622 insertions, 4 deletions (small, focused)
- Creates a standalone Code Analysis GUI tool
- Could be useful for code quality review

**Files:**

```
matlab/Scripts/Code_Analysis_GUI/
├── README.md
├── codeIssuesGUI.m (346 lines)
├── launchCodeAnalyzer.m (86 lines)
└── setup.m (83 lines)
```

**Why keep:**

- Self-contained tool (doesn't modify existing code)
- Could be useful for ongoing code quality work
- Small and clean

**Why delete:**

- May not be actively used
- Can recreate if needed

**Recommendation:** ⚠️ **REVIEW** - Check if you use the Code Analysis GUI

---

### 3. fix-path-and-parallel-cleanup 🗑️ **RECOMMEND DELETE**

**What it contains:**

- Multiple backup folders from Aug 23, 2025
- Dataset_GUI modifications
- Path cleanup utilities
- 20,640 insertions, 1,736 deletions

**Analysis:**

- Similar to cleanup-unused-functions (lots of backups)
- Multiple backup versions of Dataset_GUI
- Changes to parallel processing and sequential fallback
- Some changes reverted ("REVERT: Remove problematic sequential fallback")

**Why delete:**

- Mostly backup files from August
- Experimental work with reverts
- Main branch has moved forward significantly
- Backup files are outdated

**Recommendation:** 🗑️ **DELETE**

---

### 4. modular-architecture-clean (Local) 🗑️ **RECOMMEND DELETE**

**What it contains:**

- Same backup structure as cleanup-unused-functions
- Dataset_GUI refactoring work
- Enhanced error handling
- Performance monitoring

**Analysis:**

- Contains same Aug 23 backup files
- Dataset_GUI improvements that may or may not be in main
- Remote version exists (origin/modular-architecture-clean)

**Why delete:**

- Remote version exists, don't need local copy
- Backup files outdated
- Can be evaluated via remote branch

**Recommendation:** 🗑️ **DELETE LOCAL** (keep remote for now)

---

### 5. sync-local-main-20250829-202133 🗑️ **SAFE TO DELETE**

**What it contains:**

- Old sync from August 29, 2025
- Dataset_GUI error handling improvements
- Config.mat updates

**Analysis:**

- Named as a sync/backup branch
- From August 29 (2 months ago)
- Main has moved far beyond this

**Why delete:**

- Old sync branch from August
- Main is now significantly ahead
- No longer relevant

**Recommendation:** 🗑️ **DELETE**

---

### 6. matlab-code-issues-fix 🗑️ **SAFE TO DELETE**

**What it contains:**

- "Updates to fix the matlab code issues reported"
- This work was merged in PR #51

**Analysis:**

- Appears to be the branch that became PR #51
- Work is already in main

**Why delete:**

- Already merged to main
- No longer needed

**Recommendation:** 🗑️ **DELETE**

---

### 7. origin/modular-architecture-clean (Remote) ⚠️ **REVIEW**

**What it contains:**

- Dataset_GUI refactoring
- Enhanced error handling and usability
- MATLAB path cleanup

**Analysis:**

- Has 3 commits with specific improvements
- May have useful refactoring work
- Need to check if these changes are in main

**Recommendation:** ⚠️ **CHECK** if these improvements are in current main

---

### 8. origin/restore-1956-columns (Remote) ⚠️ **REVIEW**

**What it contains:**

- "Working 1956-column state - ready for PR to main"
- Column restoration work
- Multiple refinements to data extraction

**Analysis:**

- Seems to be completed work ready for PR
- May contain important column handling fixes
- 5 commits of refinement work

**Why keep:**

- May have critical column handling improvements
- Marked as "ready for PR"
- Could be valuable

**Why delete:**

- If column issue is already fixed in main
- If no longer relevant

**Recommendation:** ⚠️ **CHECK** - Compare with main to see if needed

---

### 9. origin/feature/interactive-signal-plotter ✅ **SAFE TO DELETE**

**Status:** Already merged into main (PR #52)

**Recommendation:** ✅ **DELETE**

---

### 10. origin/feature/merge-smooth-gui ✅ **SAFE TO DELETE**

**Status:** Just merged into main (PR #53)

**Recommendation:** ✅ **DELETE**

---

### 11. backup/standalone-oct29-2025 ✅ **KEEP**

**Purpose:** Safety backup of standalone version

**Recommendation:** ✅ **KEEP** (local + remote)

---

## Summary by Category

### ✅ SAFE TO DELETE (6 branches)

**Local:**

- `cleanup-unused-functions` - Old backups
- `fix-path-and-parallel-cleanup` - Old backups
- `sync-local-main-20250829-202133` - Old sync
- `matlab-code-issues-fix` - Already merged
- `modular-architecture-clean` - Duplicate of remote

**Remote:**

- `origin/feature/interactive-signal-plotter` - Merged
- `origin/feature/merge-smooth-gui` - Merged

### ⚠️ REVIEW BEFORE DELETING (3 branches)

**fix-matlab-error-flags** (local)

- Code Analysis GUI tool
- May be useful

**origin/modular-architecture-clean** (remote)

- Dataset_GUI refactoring
- Check if improvements are in main

**origin/restore-1956-columns** (remote)

- Column restoration work
- Check if still needed

### ✅ KEEP (1 branch + tag)

**backup/standalone-oct29-2025** (local + remote)

- Your safety backup

**Tag: v1.0-standalone**

- Permanent reference

---

## Recommended Cleanup Actions

### Step 1: Delete Obviously Safe Branches

**Delete local branches:**

```bash
git branch -D cleanup-unused-functions
git branch -D fix-path-and-parallel-cleanup
git branch -D sync-local-main-20250829-202133
git branch -D matlab-code-issues-fix
git branch -D modular-architecture-clean
```

**Delete remote branches:**

```bash
git push origin --delete feature/interactive-signal-plotter
git push origin --delete feature/merge-smooth-gui
```

**Result:** Removes 5 local + 2 remote = **7 branches**

---

### Step 2: Quick Review of Remaining Branches

**fix-matlab-error-flags:**
Check if Code Analysis GUI is useful:

```bash
git checkout fix-matlab-error-flags
cd matlab/Scripts/Code_Analysis_GUI
cat README.md
# Decide if you want to keep it
```

**origin/modular-architecture-clean:**
Check what's different from main:

```bash
git diff main...origin/modular-architecture-clean -- matlab/Scripts/Dataset\ Generator/Dataset_GUI.m | head -50
```

**origin/restore-1956-columns:**
Check if column work is in main:

```bash
git diff main...origin/restore-1956-columns -- matlab/Scripts/Dataset\ Generator/ | head -50
```

---

### Step 3: Final Decision

After reviewing, either:

- **Keep** if has unique valuable work
- **Archive** to tag if want to preserve history
- **Delete** if no longer needed

---

## Quick Delete Commands

### Conservative (7 branches - definitely safe)

```bash
# Local
git branch -D cleanup-unused-functions
git branch -D fix-path-and-parallel-cleanup
git branch -D sync-local-main-20250829-202133
git branch -D matlab-code-issues-fix
git branch -D modular-architecture-clean

# Remote
git push origin --delete feature/interactive-signal-plotter
git push origin --delete feature/merge-smooth-gui
```

### After Review (3 more branches)

```bash
# If not needed:
git branch -D fix-matlab-error-flags
git push origin --delete modular-architecture-clean
git push origin --delete restore-1956-columns
```

---

## Summary

**Total branches currently:** 15 (8 local + 7 remote)
**Recommend delete immediately:** 7 branches
**Recommend review first:** 3 branches
**Recommend keep:** 2 (backup + tag)

**After cleanup, you'll have:**

- `main` (working branch)
- `backup/standalone-oct29-2025` (safety backup)
- Tag: `v1.0-standalone` (permanent reference)
- Maybe: 3 reviewed branches if they have unique work

**Much cleaner!** ✨
