# Archive Folder - Test and Development Files

This folder contains all the temporary files, test scripts, and development versions that were created while debugging and fixing the Golf Swing Data Generator GUI.

## Files Archived:

### Test and Debug Files:
- `debug_test.m` - Basic MATLAB functionality tests
- `diagnose_gui_error.m` - Comprehensive GUI diagnostic script
- `check_syntax.m` - Syntax checking utility
- `test_*.m` - Various test scripts
- `*minimal*.m` - Minimal GUI test versions
- `ultra_minimal_gui.m` - Basic component testing

### Alternative GUI Versions:
- `MATLAB_ONLY_GUI.m` - Working Java-free GUI (used as base for fixed version)
- `GolfSwingDataGeneratorGUI_FIXED.m` - Intermediate fixed version
- `*WORKING*.m` - Various working prototype versions
- `backup_GolfSwingDataGeneratorGUI.m` - Backup of original broken file

### Launch Scripts:
- `launch_matlab_only.m` - Launcher for MATLAB-only version
- `safe_launch_gui.m` - Safe launcher with fallback options

### Test and Utility Files:
- `test_signal_bus_compatibility.m` - Signal bus testing
- `run_tests.m` - Test suite runner

## Why These Were Archived:

These files were created during the debugging process to:
1. **Identify the root cause** of "Caught unexpected exception of unknown type" errors
2. **Test different approaches** to fix Java component issues
3. **Create working alternatives** that avoid problematic Java components
4. **Provide diagnostic tools** for troubleshooting

## Main Directory Now Contains:

Only the essential working files:
- `GolfSwingDataGeneratorGUI.m` - **FIXED** main GUI (Java-free version)
- `launch_gui.m` - Standard launcher
- `GolfSwingDataGeneratorHelpers.m` - Helper functions
- `runSingleTrial.m` - Core simulation function
- Essential data files and documentation

## Root Cause Resolution:

The original GUI failed because it used Java components (`uitable` and `popupmenu`) that caused crashes. The fixed version uses only native MATLAB components (`listbox`, `uicontrol`) for 100% compatibility.

---
*These archived files can be safely removed from the MATLAB path as they are no longer needed for normal operation.*
