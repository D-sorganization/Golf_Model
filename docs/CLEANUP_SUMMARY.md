# GUI Directory Cleanup Summary

**Date:** August 2, 2025
**Operation:** Moved unused functions to Archive/Unused_Functions/

## Files Remaining in Main Directory (Essential Functions)

### Core GUI Script
- `Data_GUI.m` - Main GUI application (247KB)

### Essential Supporting Functions
- `setModelParameters.m` - Sets simulation parameters
- `extractFromCombinedSignalBus.m` - Extracts data from CombinedSignalBus
- `traverseSimlogNode.m` - Traverses Simscape log nodes
- `getPolynomialParameterInfo.m` - Provides joint parameter information
- `extractConstantMatrixData.m` - Handles constant matrix data extraction

### Configuration Files
- `user_preferences.mat` - User preferences storage

### Directories
- `Archive/` - Contains unused functions and backups
- `Backup_Run_Files/` - Run-specific backups
- `Backup_Scripts/` - Script backups including safe states
- `golf_swing_dataset_20250802/` - Generated dataset
- `Test_Large_Dataset_Batching/` - Test data

## Files Moved to Archive/Unused_Functions/

### Broken/Backup Files
- `Data_GUI_BROKEN.m` - Broken version of main GUI
- `extractFromCombinedSignalBus_BROKEN.m` - Broken extraction function
- `Data_GUI_No_Batch.m` - Alternative GUI version
- `joint_editor_layout_fix.txt` - Layout fix documentation
- `CHANGES_SUMMARY.md` - Previous changes summary

### Unused Data Extraction Functions
- `processSimulationOutput.m`
- `extractSimscapeDataRecursive.m`
- `extractSignalsFromSimOut.m`
- `combineDataSources.m`
- `extractWorkspaceOutputs.m`
- `extractTimeSeriesData.m`
- `extractLogsoutDataFixed.m`
- `extractFromNestedStruct.m`
- `extractDataFromField.m`
- `extractCoefficientsFromTable.m`
- `extractCombinedSignalBusData.m`
- `extractDataWithOptions.m`
- `extractAllSignalsFromBus.m`
- `data_extraction_functions.m`

### Unused Utility Functions
- `setPolynomialCoefficients.m`
- `runSingleTrial.m`
- `restoreWorkspace.m`
- `resampleDataToFrequency.m`
- `mergeTables.m`
- `prepareSimulationInputsForBatch.m`
- `logical2str.m`
- `loadInputFile.m`
- `getShortenedJointName.m`
- `generateRandomCoefficients.m`
- `getMemoryInfo.m`
- `fallbackSimlogExtraction.m`
- `checkStopRequest.m`
- `checkHighMemoryUsage.m`
- `addModelWorkspaceData.m`
- `checkpoint_recovery.m`
- `Clear_Parallel_Cache.m`
- `verbosity_control.m`
- `recordPhase.m`
- `performance_monitor.m`
- `recordBatchTime.m`
- `logBatchResult.m`
- `logMessage.m`
- `memory_monitor.m`
- `endPhase.m`
- `getMemoryUsage.m`
- `inspect_simscape_hierarchy.m`
- `checkModelConfiguration.m`
- `check_model_configuration.m`
- `launch_gui.m`

### Verbosity Control Functions
- `shouldShowNormal.m`
- `shouldShowVerbose.m`
- `shouldShowDebug.m`

## Benefits of Cleanup

1. **Reduced Clutter:** Main directory now contains only essential files
2. **Easier Navigation:** Clear separation between active and archived code
3. **Reduced Confusion:** No duplicate or broken files in main directory
4. **Better Organization:** Unused functions preserved in archive for potential future use
5. **Cleaner Backups:** Script backup system will only copy essential files

## Current Working State

The main directory now contains only the files that are actively used by the `Data_GUI.m` script, making it much cleaner and easier to work with. All unused functions have been preserved in the archive for potential future reference or restoration if needed.

**Total Files in Main Directory:** 8 files + 5 directories
**Total Files Moved to Archive:** 47 files
