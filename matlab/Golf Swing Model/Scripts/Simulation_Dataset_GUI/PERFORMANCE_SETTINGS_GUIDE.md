# Performance Settings Tab - User Guide

## Overview

The Performance Settings tab in the Enhanced Golf Swing Data Generator GUI provides comprehensive control over performance optimization settings. This tab allows users to configure parallel processing, memory management, and optimization parameters to maximize simulation performance.

## What Was Fixed

### Issue Resolution
- **Fixed default parallel workers**: Changed from 6 to 14 workers to match your Local_Cluster capacity
- **Fixed cluster profile selection**: Ensured Local_Cluster is always available and selected by default
- **Fixed preference persistence**: All performance settings now properly save and load between GUI sessions
- **Eliminated warnings**: Resolved "Object must be a figure" warnings that were occurring during startup

### Key Changes Made
1. **Default Preferences**: Updated `loadUserPreferences()` to set `max_parallel_workers = 14` and `cluster_profile = 'Local_Cluster'`
2. **Enhanced Saving**: Modified `savePerformanceSettings()` to save all performance parameters including cluster profile and worker count
3. **Cluster Profile Management**: Enhanced `getAvailableClusterProfiles()` to always include Local_Cluster and prioritize it
4. **Setup Assistant**: Added "Setup Local Cluster" button to help users create the Local_Cluster profile if needed

## Performance Settings Sections

### 1. Parallel Processing
- **Enable Parallel Processing**: Toggle parallel processing on/off
- **Max Parallel Workers**: Set number of CPU cores to use (default: 14)
- **Cluster Profile**: Select parallel computing profile (default: Local_Cluster)
- **Use Local Cluster Profile**: Force use of selected local cluster profile
- **Test Cluster**: Verify cluster connection and configuration

### 2. Memory Management
- **Enable Preallocation**: Pre-allocate memory for better performance (default: enabled)
- **Buffer Size**: Memory buffer size for preallocation (default: 1000)
- **Enable Data Compression**: Compress data to save memory (default: enabled)
- **Compression Level**: Data compression level 1-9 (default: 6)
- **Enable Memory Pooling**: Use memory pooling for better efficiency (default: enabled)
- **Memory Pool Size**: Size of memory pool in MB (default: 100)

### 3. Optimization
- **Enable Model Caching**: Cache Simulink models for faster loading (default: enabled)
- **Enable Performance Monitoring**: Monitor performance metrics during execution (default: enabled)
- **Enable Memory Monitoring**: Track memory usage during execution (default: enabled)

## Action Buttons

### Setup Local Cluster
- **Purpose**: Creates the Local_Cluster profile if it doesn't exist
- **When to use**: Run this first if you get cluster-related errors
- **What it does**: 
  - Checks if Local_Cluster profile exists
  - Creates it from the default 'local' profile if missing
  - Configures it with the maximum number of available cores
  - Updates the GUI to use the new profile

### Save Performance Settings
- **Purpose**: Stores current performance settings to user preferences file
- **When to use**: After making changes you want to keep
- **What it does**: Saves all settings to `user_preferences.mat` for future sessions

### Reset to Defaults
- **Purpose**: Restores all performance settings to their default values
- **When to use**: If you encounter performance issues or want to start fresh
- **What it does**: Resets all settings to optimized defaults

### Apply Settings
- **Purpose**: Immediately applies current performance settings to the current session
- **When to use**: To test settings without saving them permanently
- **What it does**: Applies settings to current session without persisting to file

## Recommended Settings for Your System

Based on your 14-core system, the following settings are recommended:

```
Parallel Processing: Enabled
Max Parallel Workers: 14
Cluster Profile: Local_Cluster
Use Local Cluster: Enabled
Preallocation: Enabled
Buffer Size: 1000
Data Compression: Enabled
Compression Level: 6
Model Caching: Enabled
Memory Pooling: Enabled
Memory Pool Size: 100
Performance Monitoring: Enabled
Memory Monitoring: Enabled
```

## Troubleshooting

### Cluster Connection Issues
1. **Click "Setup Local Cluster"** - This will create the Local_Cluster profile if missing
2. **Check Parallel Computing Toolbox** - Ensure the toolbox is installed and licensed
3. **Verify Core Count** - The system should detect 14 available cores

### Performance Issues
1. **Reset to Defaults** - Use this if you encounter performance problems
2. **Check Memory Usage** - Monitor memory usage during large simulations
3. **Adjust Worker Count** - Reduce workers if you experience memory issues

### Settings Not Persisting
1. **Click "Save Performance Settings"** after making changes
2. **Check File Permissions** - Ensure the GUI can write to the preferences file
3. **Restart GUI** - Some settings require a restart to take full effect

## Technical Details

### Files Modified
- `Data_GUI_Enhanced.m` - Main GUI file with performance settings tab
- `initializeLocalCluster.m` - Cluster initialization function
- `setup_performance_preferences.m` - Setup script for performance preferences

### Preference Storage
- **File**: `user_preferences.mat` in the GUI directory
- **Structure**: All performance settings stored in `preferences` struct
- **Persistence**: Settings automatically load when GUI starts
- **Backup**: Original preferences preserved during updates

### Cluster Profile Management
- **Default Profile**: Local_Cluster (automatically created if missing)
- **Worker Configuration**: Automatically set to maximum available cores
- **Profile Validation**: GUI checks profile availability on startup
- **Fallback**: Falls back to 'local' profile if Local_Cluster unavailable

## Testing Your Configuration

Run the test script to verify your performance preferences:

```matlab
test_performance_preferences
```

This will check:
- ✅ Preferences file exists and loads correctly
- ✅ Max parallel workers set to 14
- ✅ Cluster profile set to Local_Cluster
- ✅ Local_Cluster profile available in MATLAB
- ✅ Sufficient cores available (14)

## Support

If you encounter issues:
1. Check the command window for error messages
2. Run the test script to diagnose problems
3. Use "Reset to Defaults" to restore working configuration
4. Ensure Parallel Computing Toolbox is available

---

**Last Updated**: August 2025  
**Version**: Enhanced GUI with Performance Tab  
**Compatibility**: MATLAB R2020b+ with Parallel Computing Toolbox
