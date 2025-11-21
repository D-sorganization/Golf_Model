# Dataset_GUI.m Refactoring Plan - Phase 2
**Date:** 2025-11-16
**Current State:** 4,669 lines, 81 functions, monolithic architecture
**Target State:** 6 modular files (~800 lines each), clean separation of concerns

---

## Current Structure Analysis

### Function Categories (81 total functions):

**1. GUI Layout Creation (~15 functions, ~1000 lines)**
- `createMainLayout()` - Main window setup
- `createGenerationTabContent()` - Dataset generation tab
- `createPostProcessingTabContent()` - Post-processing tab
- `createCalculationOptionsContent()` - Calculation options panel
- `createExportSettingsContent()` - Export settings panel
- `createProgressResultsContent()` - Progress display
- `createLeftColumnContent()`, `createRightColumnContent()` - Layout helpers
- Preview and UI update functions

**2. Data Generation & Simulation (~12 functions, ~1200 lines)**
- `runGeneration()` - Main generation orchestrator
- `runParallelSimulations()` - 14-core parallel execution
- `runSequentialSimulations()` - Sequential fallback
- `validateInputs()` - Input validation
- `compileDataset()` - Dataset compilation
- `validateCoefficientBounds()` - Coefficient validation
- `saveScriptAndSettings()` - Script backup

**3. Batch Processing (~8 functions, ~600 lines)**
- `startBackgroundProcessing()` - Background worker
- `processFiles()` - File processing loop
- `processBatch()` - Batch processing
- `processTrialData()` - Individual trial processing
- `exportBatch()` - Batch export

**4. Export Functionality (~8 functions, ~400 lines)**
- `exportToCSV()`, `exportToParquet()`, `exportToMAT()`, `exportToJSON()`
- Export format handlers
- File writing utilities

**5. Visualization & Preview (~10 functions, ~500 lines)**
- `updatePreviewTable()` - Preview table updates
- `updateCoefficientsPreview()` - Coefficient preview
- `createPreviewTableData()` - Preview data generation
- Table and plot update functions

**6. Coefficient Management (~15 functions, ~600 lines)**
- `updateJointCoefficients()` - Joint coefficient updates
- `validateCoefficientInput()` - Coefficient validation
- `applyJointToTable()` - Apply to table
- `loadJointFromTable()` - Load from table
- `resetCoefficientsToGenerated()` - Reset coefficients
- `coefficientCellEditCallback()` - Edit callbacks
- `applyRowToAll()` - Batch apply
- `exportCoefficientsToCSV()`, `importCoefficientsFromCSV()` - CSV I/O
- `saveScenario()`, `loadScenario()` - Scenario management
- `searchCoefficients()`, `clearSearch()` - Search functionality

**7. User Interface Controls (~13 functions, ~400 lines)**
- `switchToGenerationTab()`, `switchToPostProcessingTab()` - Tab switching
- `togglePlayPause()` - Playback control
- `saveCheckpoint()`, `resetCheckpointButton()` - Checkpoint management
- `browseDataFolder()`, `browseOutputFolderPostProcessing()` - File browsers
- `selectionModeChanged()`, `updateFileList()` - File selection
- `selectSpecificFiles()` - File picker
- `updateProgress()` - Progress updates

**8. Configuration & Preferences (~6 functions, ~300 lines)**
- `loadUserPreferences()` - Load preferences
- `saveUserPreferences()` - Save preferences
- `selectSimulinkModel()` - Model selection
- `clearAllCheckpoints()` - Clear checkpoints
- `backupScripts()` - Script backup

---

## Refactoring Strategy

### Phase 2A: Extract Core Modules (Priority Order)

#### **Module 1: data_generator.m** (~1,200 lines)
**Why First:** Most critical for counterfactual analysis - need reusable simulation engine

**Functions to Extract:**
```matlab
runSimulation(config)                    % NEW: Pure simulation function (extracted from runGeneration)
runParallelSimulations(config)
runSequentialSimulations(config)
validateInputs(config)
compileDataset(config)
validateCoefficientBounds(config, coeff_range)
saveScriptAndSettings(config)
```

**Interface:**
```matlab
% Public API
function [successful_trials, dataset] = runSimulation(config)
    % No GUI dependencies!
    % Can be called 1000s of times for parameter sweeps
end
```

#### **Module 2: batch_processor.m** (~600 lines)
**Why Second:** Enables batch counterfactual processing

**Functions to Extract:**
```matlab
processBatchSimulations(files, config)   % Renamed from startBackgroundProcessing
processFiles(processing_data)
processBatch(batch_files, processing_data)
processTrialData(data, processing_data)
exportBatch(batch_data, batch_idx, processing_data)
```

**Interface:**
```matlab
% Public API
function [results, metadata] = processBatchSimulations(files, config)
    % Batch processing without GUI
end
```

#### **Module 3: export_manager.m** (~400 lines)
**Why Third:** Clean separation of export logic

**Functions to Extract:**
```matlab
exportDataset(dataset, format, output_path)  % NEW: Unified export
exportToCSV(data, output_file)
exportToParquet(data, output_file)
exportToMAT(data, output_file)
exportToJSON(data, output_file)
```

**Interface:**
```matlab
% Public API
function exportDataset(dataset, format, output_path, options)
    % Handles all export formats
end
```

#### **Module 4: coefficient_manager.m** (~600 lines)
**Why Fourth:** Complex coefficient logic deserves own module

**Functions to Extract:**
```matlab
updateJointCoefficients(coefficients, joint_name)
validateCoefficientInput(coefficient_value)
applyJointToTable(table_data, joint_data)
loadJointFromTable(table_data, joint_name)
resetCoefficientsToGenerated(original_coefficients)
applyRowToAll(row_data, table_data)
exportCoefficientsToCSV(coefficients, output_file)
importCoefficientsFromCSV(input_file)
saveScenario(scenario_name, coefficients)
loadScenario(scenario_name)
searchCoefficients(search_term, coefficients)
```

**Interface:**
```matlab
% Public API
classdef CoefficientManager
    methods
        function obj = CoefficientManager(config)
        end
        function applyToSimulation(obj)
        end
    end
end
```

#### **Module 5: gui_layout_generator.m** (~1,000 lines)
**Why Fifth:** UI creation separate from logic

**Functions to Extract:**
```matlab
createMainLayout(fig, colors, layout)
createGenerationTabContent(parent, colors, layout)
createPostProcessingTabContent(parent, colors, layout)
createCalculationOptionsContent(parent, colors, layout)
createExportSettingsContent(parent, colors, layout)
createProgressResultsContent(parent, colors, layout)
createLeftColumnContent(parent, colors, layout)
createRightColumnContent(parent, colors, layout)
createPreviewTableData()
```

**Interface:**
```matlab
% Public API
function handles = createMainLayout(fig, colors, layout, callbacks)
    % Returns handles structure with all UI elements
end
```

#### **Module 6: dataset_gui_controller.m** (~800 lines)
**Why Last:** Orchestrates all other modules

**Remaining Functions:**
```matlab
Dataset_GUI()                            % Main entry point
% UI callbacks that call other modules:
switchToGenerationTab()
switchToPostProcessingTab()
togglePlayPause()
saveCheckpoint(), resetCheckpointButton()
browseDataFolder(), browseOutputFolderPostProcessing()
selectionModeChanged(), updateFileList(), selectSpecificFiles()
startPostProcessing()
updatePreviewTable(), updateCoefficientsPreview()
updateProgress()
loadUserPreferences(), saveUserPreferences()
selectSimulinkModel()
clearAllCheckpoints()
backupScripts()
% And orchestration logic
```

---

## Implementation Plan

### Step 1: Create Module Skeletons (2 hours)
```bash
# Create new module files
touch matlab/Scripts/Dataset\ Generator/data_generator.m
touch matlab/Scripts/Dataset\ Generator/batch_processor.m
touch matlab/Scripts/Dataset\ Generator/export_manager.m
touch matlab/Scripts/Dataset\ Generator/coefficient_manager.m
touch matlab/Scripts/Dataset\ Generator/gui_layout_generator.m
```

### Step 2: Extract data_generator.m (8 hours)
**Critical for counterfactuals!**
1. Copy simulation functions to new file
2. Remove GUI dependencies (handles → config)
3. Add comprehensive validation
4. Test with existing Dataset_GUI.m calling new module
5. Commit: "Extract data_generator.m module"

### Step 3: Extract batch_processor.m (4 hours)
1. Copy batch processing functions
2. Update to call data_generator.m
3. Remove GUI dependencies
4. Test batch processing
5. Commit: "Extract batch_processor.m module"

### Step 4: Extract export_manager.m (3 hours)
1. Copy export functions
2. Create unified exportDataset() interface
3. Test all export formats
4. Commit: "Extract export_manager.m module"

### Step 5: Extract coefficient_manager.m (6 hours)
1. Copy coefficient functions
2. Consider converting to class
3. Test coefficient operations
4. Commit: "Extract coefficient_manager.m module"

### Step 6: Extract gui_layout_generator.m (6 hours)
1. Copy UI creation functions
2. Add callback parameters
3. Update to use modules for logic
4. Commit: "Extract gui_layout_generator.m module"

### Step 7: Refactor dataset_gui_controller.m (8 hours)
1. Update Dataset_GUI() to import modules
2. Replace inline logic with module calls
3. Keep only orchestration code
4. Final testing
5. Commit: "Complete Dataset_GUI refactoring to modular architecture"

### Step 8: Integration Testing (3 hours)
1. Test full workflow end-to-end
2. Test each module independently
3. Fix any issues
4. Document new architecture

**Total Estimated Time:** 40 hours

---

## Success Criteria

✅ Each module is <1000 lines
✅ Each module has single responsibility
✅ data_generator.m has NO GUI dependencies
✅ Can call `runSimulation(config)` without GUI
✅ All 81 functions preserved
✅ Dataset_GUI.m still works identically
✅ New architecture documented

---

## Benefits for Counterfactual Analysis

**After This Refactoring:**

```matlab
% BEFORE: Must run entire GUI
Dataset_GUI()  % Opens window, manual interaction

% AFTER: Can run simulation programmatically!
config = struct();
config.num_trials = 100;
config.parallel = true;
config.model_name = 'GolfSwing3D_Model';

% Run baseline
[trials_baseline, data_baseline] = runSimulation(config);

% Run counterfactual (vary driver mass)
config.driver_mass = 0.34;  % +10% heavier
[trials_cf, data_cf] = runSimulation(config);

% Compare
counterfactual_diff = analyzeCounterfactual(data_baseline, data_cf);
```

**This is the KEY enabler for advanced features!**

---

## Risk Mitigation

**Risks:**
1. Breaking existing functionality
2. Missing function dependencies
3. Circular dependencies between modules

**Mitigations:**
1. ✅ Test after each extraction
2. ✅ Commit frequently (every module)
3. ✅ Keep original Dataset_GUI.m until all modules working
4. ✅ Can revert to any commit if issues arise
5. ✅ Comprehensive validation in each module

---

## Next Action

**Ready to begin:** Extract data_generator.m module
**Estimated Time:** 8 hours
**Impact:** HIGH - Unlocks counterfactual analysis

Proceed? Y/N
