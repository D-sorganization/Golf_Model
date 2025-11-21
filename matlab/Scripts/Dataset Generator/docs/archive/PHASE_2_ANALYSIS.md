# Phase 2 Analysis - Function Reconciliation
**Date:** 2025-10-31  
**Branch:** `fix/gui-and-dataset-cleanup`  
**Status:** 🔍 IN PROGRESS - ANALYSIS PHASE

## Overview

Phase 2 addresses 3 functions where Dataset_GUI.m and standalone versions have **different implementations**. We need to carefully determine which version is correct/better before making changes.

## Safety Approach

### Recovery Strategy
1. **Incremental commits** - Each function change is a separate commit
2. **Backup points** - Document git commit hashes at each stage
3. **Testing checkpoints** - Test after each function reconciliation
4. **Rollback plan** - Clear instructions for reverting each change

### Current Checkpoint
- **Last Safe Point:** Commit `33fc886` (Phase 1 complete)
- **Recovery Command:** `git checkout 33fc886`

---

## Function 1: processSimulationOutput

### Location
- **Dataset_GUI.m:** Lines 4081-4224 (144 lines)
- **Standalone:** `functions/processSimulationOutput.m` (136 lines)

### Key Differences Analysis

#### Difference 1: Config Enhancement
**Standalone has:**
```matlab
config = ensureEnhancedConfig(config);
```
**Dataset_GUI does NOT have this**

**Impact:** The standalone version ensures config has all necessary enhanced settings. This could be important for maximum data extraction.

#### Difference 2: Diagnostic Call
**Standalone has:**
```matlab
diagnoseDataExtraction(simOut, config);
```
**Dataset_GUI does NOT have this**

**Impact:** Standalone provides diagnostic output about available data sources. Useful for debugging but not functionally critical.

#### Difference 3: Verbose Setting
**Standalone:**
```matlab
options.verbose = config.verbose;
```
**Dataset_GUI:**
```matlab
options.verbose = false; % Set to true for debugging
```

**Impact:** Standalone respects user's verbosity setting, Dataset_GUI hardcodes it to false.

#### Difference 4: 1956 Column Reporting
**Standalone has:**
```matlab
fprintf('✓ Trial %d: Target 1956 columns ACHIEVED (%d columns)\n', ...);
fprintf('✗ Trial %d: Target 1956 columns MISSED (%d columns, need %d more)\n', ...);
```
**Dataset_GUI does NOT have this**

**Impact:** Standalone provides specific feedback about reaching the 1956 column target. This is informational only.

#### Difference 5: Timestamp Function
**Standalone:**
```matlab
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
```
**Dataset_GUI:**
```matlab
timestamp = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
```

**Impact:** Both produce timestamps, just different methods. Dataset_GUI version is more modern (datetime vs datestr).

#### Difference 6: Simscape Handling
**Dataset_GUI has EXTRA code:**
```matlab
% ENHANCED: Extract additional Simscape data if enabled
if config.use_simscape && isfield(simOut, 'simlog') && ~isempty(simOut.simlog)
    fprintf('Extracting additional Simscape data...\n');
    simscape_data = extractSimscapeDataRecursive(simOut.simlog);
    
    if ~isempty(simscape_data) && width(simscape_data) > 1
        % Merge Simscape data with main data
        fprintf('Found %d additional Simscape columns\n', width(simscape_data) - 1);
        
        % Ensure both tables have the same number of rows
        if height(simscape_data) == height(data_table)
            % Merge tables
            data_table = [data_table, simscape_data(:, 2:end)];
            fprintf('Merged Simscape data: %d total columns\n', width(data_table));
        else
            fprintf('Warning: Row count mismatch - Simscape: %d, Main: %d\n', ...);
        end
    else
        fprintf('No additional Simscape data found\n');
    end
end
```

**Standalone does NOT have this extra Simscape extraction**

**Impact:** ⚠️ **CRITICAL DIFFERENCE** - Dataset_GUI version does ADDITIONAL Simscape data extraction that standalone doesn't do. This could be important for data completeness!

### DECISION NEEDED ⚠️
**Question:** Which version is currently being used/called?
- Need to check where `processSimulationOutput` is called from
- If called from inline code, Dataset_GUI version is used
- If called from functions, standalone version is used

**Recommendation:** HOLD - Need to determine which is actually in use and test both

---

## Function 2: addModelWorkspaceData

### Location
- **Dataset_GUI.m:** Lines 4315-4397 (83 lines)
- **Standalone:** `functions/addModelWorkspaceData.m` (97 lines)

### Key Differences Analysis

#### Difference 1: Implementation Approach
**Dataset_GUI approach:**
```matlab
% Manual handling with if-else chains:
if isnumeric(var_value) && isscalar(var_value)
    column_name = sprintf('model_%s', var_name);
    data_table.(column_name) = repmat(var_value, num_rows, 1);
elseif isnumeric(var_value) && isvector(var_value)
    for j = 1:length(var_value)
        column_name = sprintf('model_%s_%d', var_name, j);
        data_table.(column_name) = repmat(var_value(j), num_rows, 1);
    end
elseif isnumeric(var_value) && ismatrix(var_value)
    [rows, cols] = size(var_value);
    for r = 1:rows
        for c = 1:cols
            column_name = sprintf('model_%s_%d_%d', var_name, r, c);
            data_table.(column_name) = repmat(var_value(r,c), num_rows, 1);
        end
    end
```

**Standalone approach:**
```matlab
% Uses helper functions:
if isnumeric(var_value)
    [constant_signals] = extractConstantMatrixData(var_value, var_name, []);
    if ~isempty(constant_signals)
        addSignalsToTable(data_table, constant_signals, num_rows, var_name);
    end
end
```

#### Difference 2: Matrix Handling
**Dataset_GUI:** Simple nested loops for matrices  
**Standalone:** Uses specialized `extractConstantMatrixData()` function

**Impact:** Standalone version may handle special cases like inertia matrices (9-element vectors) better.

#### Difference 3: Column Naming
**Dataset_GUI:**
- Scalars: `model_varname`
- Vectors: `model_varname_1`, `model_varname_2`, etc.
- Matrices: `model_varname_1_1`, `model_varname_1_2`, etc.

**Standalone:** Uses `extractConstantMatrixData()` which may have different naming conventions.

**Impact:** ⚠️ **COULD AFFECT OUTPUT COLUMN NAMES** - This might break downstream code expecting specific column names!

#### Difference 4: Empty Check
**Dataset_GUI:**
```matlab
if ~isempty(variables)
```

**Standalone:**
```matlab
if length(variables) > 0
```

**Impact:** Negligible - both do the same thing

### DECISION NEEDED ⚠️
**Recommendation:** HOLD - Need to test both to see if column naming differs and affects output

---

## Function 3: logical2str

### Location
- **Dataset_GUI.m:** Lines 5046-5053 (8 lines)
- **Standalone:** `functions/logical2str.m` (8 lines)

### Key Differences Analysis

**Dataset_GUI version:**
```matlab
function result = logical2str(value)
% Helper function to convert logical to string
if value
    result = 'YES';
else
    result = 'NO';
end
end
```

**Standalone version:**
```matlab
function str = logical2str(logical_val)
if logical_val
    str = 'enabled';
else
    str = 'disabled';
end
end
```

### Difference Summary
- **Different return values:** 'YES'/'NO' vs 'enabled'/'disabled'
- **Different parameter name:** `value` vs `logical_val`
- **Different output variable name:** `result` vs `str`

### Usage Analysis Needed
Need to find all call sites to determine:
1. Where is this function called?
2. What is the output used for? (Display, logging, config files?)
3. Which format makes more sense in context?

### DECISION NEEDED ⚠️
**Recommendation:** ANALYZE - Find all call sites and determine appropriate format

---

## Next Steps

### Step 1: Determine Which Versions Are Currently In Use
```matlab
% In Dataset_GUI.m, search for calls to these functions
% Are they called as local functions or external functions?
```

### Step 2: Find All Call Sites
For each function, identify:
- Where it's called from
- What parameters are passed
- What the return values are used for

### Step 3: Testing Strategy
1. Create test cases for each function
2. Run both versions with same inputs
3. Compare outputs
4. Document differences

### Step 4: Make Decisions
For each function:
- [ ] Which version is better?
- [ ] Can we create a hybrid?
- [ ] What are the risks?
- [ ] How do we test changes?

### Step 5: Implementation Plan
1. **One function at a time**
2. **One commit per function**
3. **Test after each change**
4. **Document decisions**

---

## Status: ANALYSIS IN PROGRESS

Currently investigating which versions are actually being used in the codebase...


