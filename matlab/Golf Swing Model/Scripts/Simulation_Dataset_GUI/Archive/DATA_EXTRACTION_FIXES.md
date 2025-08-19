# Data Extraction Fixes for Data_GUI.m

## Overview
This document explains the fixes applied to resolve data capture issues in the Data_GUI.m script. The main problems were:

1. **"To Workspace" Block Naming Mismatch**: The script expected specific variable names that might not match your Simulink model
2. **Misleading "Workspace" Checkbox**: The checkbox was checked but had no actual implementation
3. **Incomplete Data Extraction Logic**: The script wasn't properly extracting data from all sources

## Fixes Applied

### 1. Fixed "Workspace" Checkbox Implementation

**Problem**: The `use_model_workspace` checkbox was checked by default but had no actual code to extract data from "To Workspace" blocks.

**Solution**: Added a new `extractWorkspaceData()` function that:
- Searches for all fields in the simulation output's `out` structure
- Looks for time data using common field names (`time`, `tout`, `Time`, `TIME`)
- Extracts all numeric data fields that match the time length
- Handles struct fields (signal buses) recursively
- Handles timeseries objects

**Code Location**: Lines ~2420-2550 in Data_GUI.m

### 2. Improved Signal Bus Extraction

**Problem**: The script only looked for exact variable names like `HipLogs`, `SpineLogs`, etc.

**Solution**: Enhanced `extractSignalBusStructs()` to:
- Check for exact matches first
- Look for alternative naming patterns (e.g., `Hip_Logs`, `HipLog`)
- Automatically detect any field ending with `Logs` or `Log`
- Provide detailed debugging output

**Code Location**: Lines ~2550-2650 in Data_GUI.m

### 3. Fixed Model Parameter Configuration

**Problem**: The script wasn't properly configuring the model for data logging.

**Solution**: Updated `setModelParameters()` to:
- Set `SaveFormat` to `Structure` (better for To Workspace blocks)
- Ensure `ReturnWorkspaceOutputs` is `on`
- Provide better debugging output

**Code Location**: Lines ~2350-2380 in Data_GUI.m

## New Diagnostic Tools

### 1. Model Configuration Checker

**File**: `check_model_configuration.m`

**Purpose**: Diagnoses issues with your Simulink model configuration

**Usage**:
```matlab
check_model_configuration()
```

**What it checks**:
- Finds all "To Workspace" blocks in your model
- Compares variable names against expected names
- Checks model configuration parameters
- Runs a test simulation to verify data capture

### 2. Data Extraction Tester

**File**: `test_data_extraction.m`

**Purpose**: Tests the improved data extraction functions

**Usage**:
```matlab
test_data_extraction()
```

**What it tests**:
- Runs a short test simulation
- Tests all data extraction methods
- Reports success/failure for each method
- Shows what data was captured

## How to Use the Fixes

### Step 1: Run the Diagnostic
```matlab
cd('Scripts/Simulation_Dataset_GUI')
check_model_configuration()
```

This will tell you:
- What "To Workspace" blocks exist in your model
- What their variable names are
- Whether they match expected names
- If the model is configured correctly

### Step 2: Fix Variable Names (if needed)
If the diagnostic shows naming mismatches, you have two options:

**Option A: Rename To Workspace blocks in Simulink**
1. Open your `GolfSwing3D_Kinetic.slx` model
2. Find each "To Workspace" block
3. Double-click to open parameters
4. Change "Variable name" to match expected names:
   - `HipLogs`, `SpineLogs`, `TorsoLogs`
   - `LSLogs`, `RSLogs`, `LELogs`, `RELogs`
   - `LWLogs`, `RWLogs`, `LScapLogs`, `RScapLogs`
   - `LFLogs`, `RFLogs`

**Option B: Use the flexible extraction (recommended)**
The improved script now handles many naming variations automatically, so you may not need to rename anything.

### Step 3: Test the Fixes
```matlab
test_data_extraction()
```

This will verify that data extraction is working correctly.

### Step 4: Use the GUI
```matlab
Data_GUI()
```

**Important**: Make sure to check the appropriate data sources:
- ✅ **Workspace**: For "To Workspace" blocks (now properly implemented)
- ✅ **Signal Bus**: For signal bus structures (improved flexibility)
- ✅ **Logsout**: For Simulink logging data
- ✅ **Simscape**: For Simscape logging data

## Expected Variable Names

The script now looks for these variable names in your "To Workspace" blocks:

**Primary Names**:
- `HipLogs`, `SpineLogs`, `TorsoLogs`
- `LSLogs`, `RSLogs`, `LELogs`, `RELogs`
- `LWLogs`, `RWLogs`, `LScapLogs`, `RScapLogs`
- `LFLogs`, `RFLogs`

**Alternative Names** (automatically detected):
- `Hip_Logs`, `Spine_Logs`, `Torso_Logs`
- `LS_Logs`, `RS_Logs`, `LE_Logs`, `RE_Logs`
- `LW_Logs`, `RW_Logs`, `LScap_Logs`, `RScap_Logs`
- `LF_Logs`, `RF_Logs`
- `HipLog`, `SpineLog`, `TorsoLog`
- `LSLog`, `RSLog`, `LELog`, `RELog`
- `LWLog`, `RWLog`, `LScapLog`, `RScapLog`
- `LFLog`, `RFLog`

**Any field ending with `Logs` or `Log`** will also be automatically detected.

## Debugging Output

The improved script provides extensive debugging output. When you run it, you'll see messages like:

```
Debug: Found 'out' field in simOut
Debug: Extracting workspace data...
Debug: Available fields in out: HipLogs, SpineLogs, time
Debug: Found exact match HipLogs
Debug: Found exact match SpineLogs
Debug: Created workspace table with 15 columns
```

This helps you understand exactly what data is being found and extracted.

## Troubleshooting

### No Data Extracted
1. Run `check_model_configuration()` to identify issues
2. Ensure "To Workspace" blocks exist in your model
3. Check that variable names match expected patterns
4. Verify model configuration parameters

### Partial Data Extracted
1. Check which data sources are enabled in the GUI
2. Look at debug output to see what's being found
3. Consider enabling additional data sources

### Simulation Errors
1. Check that your model can run independently
2. Verify input files are valid
3. Check coefficient values are reasonable

## Summary

The main fixes ensure that:
1. ✅ The "Workspace" checkbox now actually extracts data from "To Workspace" blocks
2. ✅ Variable naming is more flexible and handles common variations
3. ✅ Model configuration is properly set for data logging
4. ✅ Extensive debugging output helps identify issues
5. ✅ Diagnostic tools help verify everything is working

These changes should resolve the data capture issues you were experiencing.
