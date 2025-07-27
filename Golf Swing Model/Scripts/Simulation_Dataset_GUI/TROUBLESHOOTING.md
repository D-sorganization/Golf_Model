# GUI Launch Error Troubleshooting Guide

## Error: "Caught unexpected exception of unknown type"

This error typically occurs when MATLAB encounters an unhandled exception in the GUI code. Here's a systematic approach to diagnose and fix the issue.

## Quick Solutions to Try First

1. **Run from the correct directory:**
   ```matlab
   cd('/workspace/Golf Swing Model/Scripts/Simulation_Dataset_GUI')
   launch_gui
   ```

2. **Try the safe launcher:**
   ```matlab
   safe_launch_gui
   ```

3. **Run with software OpenGL (if graphics issues):**
   ```bash
   matlab -softwareopengl
   ```

## Diagnostic Tools Available

### 1. Comprehensive Diagnostic Script
Run this to check your MATLAB environment:
```matlab
diagnose_gui_error
```

This will check:
- MATLAB version and environment
- Required toolboxes
- GUI component functionality
- Java/display availability
- Missing dependencies

### 2. Debug Version of GUI
Run this to see exactly where the error occurs:
```matlab
GolfSwingDataGeneratorGUI_debug
```

This provides detailed output at each step of GUI initialization.

### 3. Minimal GUI Test
Test basic GUI functionality:
```matlab
minimal_gui_test
```

If this works but the main GUI doesn't, the issue is with specific GUI components.

## Common Causes and Solutions

### 1. Display/Graphics Issues
**Symptoms:** Error occurs immediately when creating figure or UI components
**Solutions:**
- Run MATLAB with: `matlab -softwareopengl`
- Update graphics drivers
- Check if running in a remote/SSH session without X11 forwarding

### 2. Path Issues
**Symptoms:** Functions not found, path-related errors
**Solutions:**
```matlab
% Add GUI directory to path
addpath('/workspace/Golf Swing Model/Scripts/Simulation_Dataset_GUI')
% Save path for future sessions
savepath
```

### 3. Missing Toolboxes
**Symptoms:** Specific functionality not available
**Check installed toolboxes:**
```matlab
ver
```
Required: MATLAB, Simulink (optional for full functionality)

### 4. Corrupted MATLAB Preferences
**Symptoms:** Persistent errors even with simple GUIs
**Solutions:**
```matlab
% Reset MATLAB preferences (backup first!)
prefdir  % Shows preference directory
% Then delete or rename the preferences directory
```

### 5. Java/JVM Issues
**Symptoms:** Java-related errors, display issues
**Solutions:**
- Check Java version: `version -java`
- Try running without Java desktop: `matlab -nojvm` (limited functionality)

## Step-by-Step Troubleshooting Process

1. **Run the diagnostic script:**
   ```matlab
   diagnose_gui_error
   ```
   Review output for any failures or warnings.

2. **Try the debug GUI:**
   ```matlab
   GolfSwingDataGeneratorGUI_debug
   ```
   Note exactly where it fails.

3. **Test minimal functionality:**
   ```matlab
   debug_test  % Tests basic MATLAB functionality
   minimal_gui_test  % Tests minimal GUI
   ```

4. **Try the safe launcher:**
   ```matlab
   safe_launch_gui
   ```
   This tries multiple launch methods with fallbacks.

5. **Check for conflicting files:**
   ```matlab
   which -all GolfSwingDataGeneratorGUI
   ```
   Ensure only one version exists.

## If All Else Fails

1. **Create a fresh MATLAB session:**
   ```matlab
   clear all
   close all
   clc
   restoredefaultpath
   ```

2. **Manually add only the required path:**
   ```matlab
   addpath('/workspace/Golf Swing Model/Scripts/Simulation_Dataset_GUI')
   ```

3. **Try launching with all warnings enabled:**
   ```matlab
   warning on all
   launch_gui
   ```

4. **Check MATLAB log files:**
   - Look in the MATLAB command window for any additional error messages
   - Check system logs if MATLAB crashes

## Reporting the Issue

If you need to report this issue, please provide:
1. Output from `diagnose_gui_error`
2. MATLAB version: `version`
3. Operating system details
4. Exact error message and stack trace
5. Whether minimal_gui_test works

## Alternative: Command-Line Usage

If the GUI cannot be fixed immediately, you can still use the core functionality via command line. See `GolfSwingDataGeneratorHelpers.m` for available functions.