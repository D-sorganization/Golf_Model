# Function Dependency Map - data_generator.m Extraction
**Purpose:** Map all functions and dependencies for safe extraction from Dataset_GUI.m
**Status:** Ready for Phase 2 implementation

---

## Functions to Extract (7 Core Functions)

### **1. runGeneration() → runSimulation()**

**Current Location:** Dataset_GUI.m:3337-3429 (93 lines)
**New Location:** data_generator.m
**New Name:** `runSimulation(config, options)`

**Dependencies:**
```
runGeneration
├── ensureEnhancedConfig()                   [KEEP - Extract]
├── extractCoefficientsFromTable(handles)    [REPLACE - Use config.coefficient_values]
├── runParallelSimulations(handles, config)  [EXTRACT - Remove handles param]
├── runSequentialSimulations(handles, config) [EXTRACT - Remove handles param]
├── compileDataset(config)                   [EXTRACT]
└── saveScriptAndSettings(config)            [EXTRACT]
```

**GUI Dependencies to Remove:**
- `handles.config` → `config` parameter
- `handles.status_text` → fprintf() or logger
- `handles.progress_text` → fprintf() or logger
- `handles.should_stop` → timeout check
- `handles.is_running` → metadata tracking
- `get(handles.enable_master_dataset, 'Value')` → `config.enable_master_dataset`
- `get(handles.execution_mode_popup, 'Value')` → `config.execution_mode`
- `guidata()` calls → removed

---

### **2. runParallelSimulations()**

**Current Location:** Dataset_GUI.m:3431-3802 (372 lines)
**New Location:** data_generator.m
**Signature:** `function successful_trials = runParallelSimulations(config)`

**Dependencies:**
```
runParallelSimulations
├── gcp('nocreate')                                   [KEEP - Parallel pool management]
├── parpool()                                         [KEEP]
├── checkStopRequest(handles)                         [REPLACE - Use timeout or remove]
├── updateProgress(handles, current, total, message)  [REPLACE - fprintf or callback]
├── prepareSimulationInputsForBatch(config, ...)      [EXTRACT]
├── parsim()                                          [KEEP - Core parallel execution]
├── processSimulationOutput(...)                      [KEEP - External function]
├── restoreWorkspace(initial_vars)                    [KEEP - External function]
└── Checkpoint functions                              [EXTRACT - Remove handles dep]
```

**GUI Dependencies to Remove:**
- `handles.enable_checkpoint_resume` → `config.enable_checkpoint_resume`
- `handles.progress_text` → fprintf() or optional progress callback
- `handles.should_stop` → timeout mechanism
- `get(handles.enable_checkpoint_resume, 'Value')` → `config.enable_checkpoint_resume`
- `set(handles.progress_text, ...)` → fprintf()
- All handles references → config or remove

**External Function Dependencies (Must Exist):**
- processSimulationOutput.m ✓ (exists in functions/)
- prepareSimulationInputsForBatch.m ✓ (exists in functions/)
- checkStopRequest.m ✓ (exists in functions/) - will adapt
- restoreWorkspace.m ✓ (exists in functions/)
- runSingleTrial.m ✓ (exists in functions/)
- 20+ helper functions listed in attached_files array

---

### **3. runSequentialSimulations()**

**Current Location:** Dataset_GUI.m:3832-3982 (151 lines)
**New Location:** data_generator.m
**Signature:** `function successful_trials = runSequentialSimulations(config)`

**Dependencies:**
```
runSequentialSimulations
├── checkStopRequest(handles)                         [REPLACE - Timeout check]
├── updateProgress(handles, current, total, message)  [REPLACE - fprintf]
├── generateRandomCoefficients(...)                   [KEEP - External function]
├── runSingleTrial(trial, config, ...)                [KEEP - External function]
├── restoreWorkspace(initial_vars)                    [KEEP - External function]
└── Checkpoint functions                              [EXTRACT - Remove handles]
```

**GUI Dependencies to Remove:**
- `get(handles.enable_checkpoint_resume, 'Value')` → `config.enable_checkpoint_resume`
- `set(handles.progress_text, ...)` → fprintf()
- `handles` references in checkStopRequest → remove or adapt

---

### **4. validateInputs()**

**Current Location:** Dataset_GUI.m:4021-4253 (233 lines)
**New Location:** data_generator.m (or createSimulationConfig.m)
**New Name:** `validateSimulationConfig(config)`

**Dependencies:**
```
validateInputs
├── get(handles.num_trials_edit, 'String')           [REPLACE - config.num_simulations]
├── get(handles.sim_time_edit, 'String')             [REPLACE - config.simulation_time]
├── get(handles.sample_rate_edit, 'String')          [REPLACE - config.sample_rate]
├── get(handles.torque_scenario_popup, 'Value')      [REPLACE - config.torque_scenario]
├── get(handles.coeff_range_edit, 'String')          [REPLACE - config.coeff_range]
├── get(handles.use_signal_bus, 'Value')             [REPLACE - config.use_signal_bus]
├── get(handles.use_logsout, 'Value')                [REPLACE - config.use_logsout]
├── get(handles.use_simscape, 'Value')               [REPLACE - config.use_simscape]
├── get(handles.output_folder_edit, 'String')        [REPLACE - config.output_folder]
├── get(handles.folder_name_edit, 'String')          [REPLACE - config.folder_name]
├── validateCoefficientBounds(handles, coeff_range)  [EXTRACT - Remove handles]
├── find_system() - Simscape validation              [KEEP]
├── shouldShowDebug(handles)                         [REPLACE - config.verbosity]
└── Model path validation                            [KEEP]
```

**GUI Dependencies to Remove (15+ get() calls):**
- Replace ALL `get(handles.*, ...)` with `config.*`
- Replace `handles.model_name` with `config.model_name`
- Replace `handles.model_path` with `config.model_path`
- Replace `handles.selected_input_file` with `config.input_file`
- Replace `shouldShowDebug(handles)` with `strcmp(config.verbosity, 'Debug')`

---

### **5. compileDataset()**

**Current Location:** Dataset_GUI.m:4316-4471 (156 lines)
**New Location:** data_generator.m
**Signature:** `function compileDataset(config)`

**Dependencies:**
```
compileDataset
├── dir() - File listing                              [KEEP]
├── readtable() - CSV reading                         [KEEP]
├── vertcat() - Table concatenation                   [KEEP]
├── writetable() - CSV writing                        [KEEP]
└── fprintf() - Progress messages                     [KEEP]
```

**GUI Dependencies:** NONE ✓ (Already clean!)

**Notes:** This function is already GUI-independent and can be extracted as-is.

---

### **6. validateCoefficientBounds()**

**Current Location:** Dataset_GUI.m:4472-4505 (34 lines)
**New Location:** data_generator.m
**Signature:** `function validateCoefficientBounds(config, coeff_range)`

**Dependencies:**
```
validateCoefficientBounds
├── get(handles.coeff_table, 'Data')                  [REPLACE - config.coefficient_values]
└── Numeric validation                                [KEEP]
```

**GUI Dependencies to Remove:**
- `get(handles.coeff_table, 'Data')` → `config.coefficient_values`

---

### **7. saveScriptAndSettings()**

**Current Location:** Dataset_GUI.m:4506-4669 (164 lines)
**New Location:** data_generator.m
**Signature:** `function saveScriptAndSettings(config)`

**Dependencies:**
```
saveScriptAndSettings
├── fopen() - File I/O                                [KEEP]
├── fprintf() - Writing                               [KEEP]
├── datetime() - Timestamps                           [KEEP]
└── Config serialization                              [KEEP]
```

**GUI Dependencies:** NONE ✓ (Already mostly clean, uses config)

---

## Helper Functions (Already External)

These functions already exist in `matlab/Scripts/Functions/` and don't need extraction:

✓ processSimulationOutput.m
✓ prepareSimulationInputsForBatch.m
✓ runSingleTrial.m
✓ extractSignalsFromSimOut.m
✓ extractAllSignalsFromBus.m
✓ extractLogsoutDataFixed.m
✓ extractSimscapeDataRecursive.m
✓ setModelParameters.m
✓ setPolynomialCoefficients.m
✓ generateRandomCoefficients.m
✓ restoreWorkspace.m
✓ checkStopRequest.m (needs adaptation)
✓ extractCoefficientsFromTable.m (will be replaced)
✓ shouldShowDebug.m, shouldShowVerbose.m, shouldShowNormal.m (will be replaced)

---

## GUI Dependency Patterns to Replace

### **Pattern 1: UI Element Reading**
```matlab
% BEFORE (Dataset_GUI.m)
num_trials = str2double(get(handles.num_trials_edit, 'String'));

% AFTER (data_generator.m)
num_trials = config.num_simulations;
```

### **Pattern 2: UI Element Writing**
```matlab
% BEFORE
set(handles.status_text, 'String', 'Status: Running trials...');
set(handles.progress_text, 'String', progress_msg);
drawnow;

// AFTER
if ~strcmp(config.verbosity, 'Silent')
    fprintf('Status: Running trials...\n');
    fprintf('%s\n', progress_msg);
end
```

### **Pattern 3: Stop Request Checking**
```matlab
% BEFORE
if checkStopRequest(handles)
    fprintf('Simulation stopped by user\n');
    break;
end

% AFTER
if elapsedTime > config.timeout_seconds
    fprintf('Simulation timed out\n');
    break;
end
```

### **Pattern 4: Progress Callback**
```matlab
% BEFORE
updateProgress(handles, current, total, message);

% AFTER
if ~strcmp(config.verbosity, 'Silent')
    fprintf('[%d/%d] %s\n', current, total, message);
end
% OR provide optional progress callback in options
if isfield(options, 'progress_callback')
    options.progress_callback(current, total, message);
end
```

### **Pattern 5: Checkbox/Popup Values**
```matlab
% BEFORE
enable_master_dataset = get(handles.enable_master_dataset, 'Value');
execution_mode = get(handles.execution_mode_popup, 'Value');

% AFTER
enable_master_dataset = config.enable_master_dataset;
execution_mode = config.execution_mode;
```

---

## Extraction Order (Recommended)

**Order matters for dependencies!**

1. **validateCoefficientBounds()** - Simplest, no complex dependencies
2. **compileDataset()** - Already GUI-independent
3. **saveScriptAndSettings()** - Minimal GUI deps
4. **validateInputs() → validateSimulationConfig()** - Many deps, but self-contained
5. **runSequentialSimulations()** - Depends on 1-4
6. **runParallelSimulations()** - Depends on 1-4
7. **runGeneration() → runSimulation()** - Depends on all above

---

## Testing Strategy

### **Test Each Function After Extraction**

```matlab
% 1. Test validateCoefficientBounds
config = createSimulationConfig();
config.coefficient_values = rand(10, 20);
validateCoefficientBounds(config, 10.0);  % Should pass

% 2. Test compileDataset
config.output_folder = '/test/path';
compileDataset(config);  % Should work if files exist

% 3. Test runSequentialSimulations
config.num_simulations = 2;
successful = runSequentialSimulations(config);
assert(successful >= 0 && successful <= 2);

% 4. Test runParallelSimulations
config.num_simulations = 2;
config.execution_mode = 'parallel';
successful = runParallelSimulations(config);
assert(successful >= 0 && successful <= 2);

% 5. Test full runSimulation
[successful, path, metadata] = runSimulation(config);
assert(successful >= 0);
assert(exist(path, 'dir') > 0);
assert(isstruct(metadata));
```

---

## Risk Mitigation

### **High Risk Areas**

1. **Parallel pool management** - Complex error handling
   - Mitigation: Keep existing logic, test thoroughly

2. **Checkpoint resume** - File I/O and state management
   - Mitigation: Extract checkpoint as separate functions

3. **Progress callbacks** - Many UI update points
   - Mitigation: Replace with fprintf() or optional callback

4. **Stop request handling** - User interruption mechanism
   - Mitigation: Replace with timeout or remove for v1

### **Medium Risk Areas**

1. **Configuration validation** - Many dependencies
   - Mitigation: Already implemented in createSimulationConfig.m

2. **Error propagation** - Maintaining error messages
   - Mitigation: Use consistent error IDs

### **Low Risk Areas**

1. **compileDataset()** - Already GUI-independent
2. **saveScriptAndSettings()** - Minimal dependencies
3. **File I/O** - Standard MATLAB functions

---

## Success Metrics

After extraction:

✅ **No handles references** in data_generator.m
✅ **No get()/set()** calls on UI elements
✅ **All tests pass**
✅ **Dataset_GUI.m can call data_generator functions**
✅ **Output identical to original**
✅ **Can run from command line**: `runSimulation(config)`
✅ **Performance equivalent or better**

---

**Status:** Dependency map complete - Ready for extraction
**Next:** Use this map during step-by-step extraction process
