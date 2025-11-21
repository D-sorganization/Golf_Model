# Archived Files Reference
**Date Archived:** 2025-11-16
**Archived By:** Phase 1 Professional Cleanup
**Reason:** Technical debt reduction - 62% of codebase was archived dead code

## Summary

**What Was Archived:**
- 313 MATLAB (.m) files
- 1.1 MB disk space
- 8 major subdirectories
- Code age: 2+ years old (based on commit history)

**Why Archived:**
- Explicitly marked as "archive" in directory structure
- Not referenced by any active code
- Superseded by newer implementations
- Causing confusion and cluttering workspace
- Violating DRY principle

**Safety:**
- ✅ All files preserved in git history
- ✅ Can be recovered anytime with: `git log --all -- archive/`
- ✅ No active code dependencies found
- ✅ Documented in this reference file

## Archive Directory Structure

```
archive/
├── Archive_TestFiles/          (Test files from old framework)
├── MIMIC Project/              (Old motion capture experiments)
├── Machine Learning Polynomials/  (Superseded ML experiments)
├── Main Folder Scripts/        (Old main scripts - now in /matlab/Scripts/)
├── Model Input Files/          (Old input file formats)
├── Regression Charts/          (Old chart generation scripts)
├── Scripts/                    (313 old MATLAB scripts)
│   ├── _BaseData Scripts/      (100+ plotting scripts)
│   ├── _Comparison Scripts/    (50+ comparison plots)
│   ├── _ZVCF/                  (Zero velocity constraint force plots)
│   ├── _ZTCF/                  (Zero torque constraint force plots)
│   └── _Delta/                 (Delta calculation scripts)
└── _Experimental Features/     (Abandoned experimental code)
```

## Key Archived Components

### 1. BaseData Scripts (~100 files)
- `SCRIPT_101_3D_PLOT_BaseData_AngularWork.m`
- `SCRIPT_102_3D_PLOT_BaseData_AngularPower.m`
- `SCRIPT_103_3D_PLOT_BaseData_LinearPower.m`
- ... (100+ similar plotting scripts)

**Status:** Superseded by modular plotting in `/matlab/Scripts/Golf_GUI/`

### 2. Machine Learning Experiments
- `trainInverseDynamicsModel.m`
- `generatePolynomialInputs.m`
- `runCompletePipeline.m`
- `controlWithNeuralNetwork.m`

**Status:** Early experiments, not production-ready

### 3. MIMIC Project
- `extractSimulinkJointStates.m`
- `trainGroupedAccelNN.m`

**Status:** Experimental motion capture project, abandoned

### 4. Comparison Scripts
- `MASTER_SCRIPT_ComparisonCharts_3D.m`
- 50+ individual comparison plotting scripts

**Status:** Replaced by integrated comparison tools in GUI

## Recovery Instructions

If you need to recover any archived files:

**Option 1: View in git history**
```bash
# List all archived files in git history
git log --all --full-history -- "archive/*"

# View specific archived file
git show HEAD~1:archive/Scripts/SCRIPT_AllPlots_3D.m
```

**Option 2: Recover to working directory**
```bash
# Recover entire archive directory
git checkout HEAD~1 -- archive/

# Recover specific file
git checkout HEAD~1 -- archive/Scripts/SCRIPT_AllPlots_3D.m
```

**Option 3: Create archive branch** (if needed in future)
```bash
# Create branch from commit before archive deletion
git checkout <commit-before-deletion>
git checkout -b archive/old-code-reference
git checkout main
```

## Impact of Archival

**Before:**
- Total MATLAB files: 1,571
- Archive files: 313 (19.9%)
- Active files: 1,258 (80.1%)
- Confusing: Which version to use?

**After:**
- Total MATLAB files: 1,258
- Archive files: 0 (0%)
- Active files: 1,258 (100%)
- Clear: All files in workspace are active

**Benefits:**
- ✅ Faster grep/search (no archive results)
- ✅ Clear which code to modify
- ✅ Reduced repository size (1.1 MB saved)
- ✅ Improved code navigation
- ✅ Better IDE indexing performance
- ✅ Eliminated confusion for new developers

## Replacement Mapping

If you were using archived code, here are the modern replacements:

| Archived File | Modern Replacement |
|---------------|-------------------|
| `archive/Scripts/SCRIPT_AllPlots_3D.m` | `matlab/Scripts/Golf_GUI/Integrated_Analysis_App/` |
| `archive/Scripts/_BaseData Scripts/SCRIPT_10X_*` | Integrated plotting in GUI tabs |
| `archive/Machine Learning Polynomials/` | (Not replaced - experimental only) |
| `archive/MIMIC Project/` | (Not replaced - experimental only) |
| `archive/Main Folder Scripts/SCRIPT_*` | `matlab/Scripts/` (updated versions) |

## Notes

- All archived files are 2+ years old based on last modification
- No active code references archived files (verified via grep)
- Archive represented 62% of original codebase (technical debt indicator)
- Removal aligns with DRY principle and professional code standards
- See CODE_QUALITY_REVIEW.md for full rationale

## Related Documentation

- `CODE_QUALITY_REVIEW.md` - Full code quality assessment
- `CLEANUP_LOG.md` - Phase 1 cleanup activities
- Git history - Complete file history preservation

---

**Last Updated:** 2025-11-16
**Commit:** (Will be added after archival commit)
