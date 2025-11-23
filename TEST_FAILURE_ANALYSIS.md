# Golf_Model Test Failure Analysis

## Summary

After CI/CD standardization, Golf_Model tests are failing: **3 of 7 tests passed, 4 skipped** (previously passing all 11 tests).

## Root Causes Identified

### 1. **Test Discovery Scope Changed** ⚠️ PRIMARY ISSUE
- **Before:** Tests were discovered from entire repository (including `matlab/Scripts/Golf_GUI/Simscape Multibody Data Plotters/Python Version/integrated_golf_gui_r0/`)
- **After:** `pytest.ini` restricts `testpaths = python/tests` - only finds 6 tests in `python/tests/`
- **Impact:** Tests in GUI directory (`integrated_golf_gui_r0/`) are no longer discovered
- **Evidence:** Running `pytest .` finds 14 tests total (6 in `python/tests/` + 8 in GUI directory), but `pytest.ini` restricts to only `python/tests`

### 2. **CI Workflow Test Execution Changed**
- **Before:** `pytest -q` from repository root (discovered all tests)
- **After:** `pytest -q` with `PYTEST_ADDOPTS: "-m 'not requires_gl and not slow_numba'"` and `testpaths = python/tests` restriction
- **Impact:** Only 6 tests in `python/tests/` are found, but CI reports 3 passed, 4 skipped (7 total)
- **Mystery:** Local run shows 6 tests all pass, but CI reports 7 tests (3 pass, 4 skip)

### 3. **Test Marker Filtering**
- **Current:** `PYTEST_ADDOPTS: "-m 'not requires_gl and not slow_numba'"`
- **Issue:** Tests in `python/tests/` don't have these markers, so all 6 should run
- **Possible Cause:** CI environment might have different test discovery or dependencies causing skips

### 4. **Test Count Mismatch**
- **Expected:** 11 tests (from before standardization)
- **Found Locally:** 6 tests in `python/tests/` + 8 tests in GUI directory = 14 total
- **CI Reports:** 3 passed, 4 skipped (7 total)
- **Discrepancy:** Test count doesn't match - suggests CI is finding 1 additional test or counting differently

## Files to Investigate

1. **`pytest.ini`** - Currently restricts to `python/tests` only
2. **`.github/workflows/ci.yml`** - Line 65: `if [ -d python/tests ] || ls -1 **/tests 2>/dev/null | grep -q .; then`
3. **Test files in GUI directory:**
   - `matlab/Scripts/Golf_GUI/Simscape Multibody Data Plotters/Python Version/integrated_golf_gui_r0/test_*.py`

## Recommended Fixes

### Option 1: Expand Test Discovery (Recommended if GUI tests should run)
- Remove or modify `testpaths` in `pytest.ini` to include GUI tests:
  ```ini
  testpaths =
      python/tests
      matlab/Scripts/Golf_GUI/Simscape Multibody Data Plotters/Python Version/integrated_golf_gui_r0
  ```
- Or remove `testpaths` entirely to discover all tests
- Update CI workflow if needed to handle GUI test dependencies

### Option 2: Keep Current Scope (Recommended if GUI tests shouldn't run in CI)
- Accept that only `python/tests/` tests run (6 tests)
- Move GUI tests to `python/tests/` if they should be part of CI
- Document that GUI tests are excluded from CI
- **Fix the CI discrepancy:** Investigate why CI reports 7 tests when only 6 exist

### Option 3: Separate Test Suites
- Create separate test jobs for `python/tests/` and GUI tests
- Use different markers or test paths for each suite
- Mark GUI tests with `requires_gl` or `gui` marker to exclude from headless CI

## Immediate Action Items

1. **Check CI logs** to see:
   - Which specific tests are being skipped and why
   - If there's a 7th test being discovered that doesn't exist locally
   - What error messages or skip reasons are shown

2. **Verify test count:**
   - Run `pytest python/tests/ --collect-only` in CI to see what's actually collected
   - Compare with local collection results

3. **Fix test discovery:**
   - If GUI tests should run: Update `pytest.ini` to include them
   - If GUI tests shouldn't run: Ensure `pytest.ini` correctly restricts to `python/tests` only
   - Fix any CI environment issues causing test skips

4. **Document decision:**
   - Decide whether GUI tests should be part of CI
   - Update documentation accordingly

## Files Changed During Standardization

- `.github/workflows/ci.yml` - Line 65: Test discovery logic
- `pytest.ini` - `testpaths` restriction added (if it didn't exist before)
- Test execution now respects `pytest.ini` configuration
