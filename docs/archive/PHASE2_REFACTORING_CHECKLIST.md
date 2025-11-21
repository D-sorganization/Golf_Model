# Phase 2 Refactoring Checklist - data_generator.m Extraction
**Purpose:** Step-by-step guide for extracting data_generator.m from Dataset_GUI.m
**Time Estimate:** 8-12 hours for complete extraction
**Status:** Ready for implementation

---

## Pre-Extraction Checklist

### ✅ **Prerequisites (COMPLETE)**

- [x] Code quality review completed
- [x] Phase 1 cleanup complete (duplicates/archives removed)
- [x] Constants extracted (UIColors, GUILayoutConstants, PhysicsConstants)
- [x] Input validation added to critical functions
- [x] Test framework created (test_data_generator.m)
- [x] Interface specification written (DATA_GENERATOR_INTERFACE_SPEC.md)
- [x] Configuration builder created (createSimulationConfig.m)
- [x] Function dependency map created (FUNCTION_DEPENDENCY_MAP.md)
- [x] All preparation materials committed to git

### ☐ **Environment Setup**

- [ ] Create feature branch: `git checkout -b phase2/extract-data-generator`
- [ ] Verify MATLAB version compatibility (R2020b or later recommended)
- [ ] Verify all toolboxes available (Simulink, Simscape, Parallel Computing)
- [ ] Backup current Dataset_GUI.m: `cp Dataset_GUI.m Dataset_GUI.m.backup`
- [ ] Clear MATLAB workspace: `clear all; close all; clc`
- [ ] Add paths: `addpath(genpath('matlab/Scripts'))`

---

## Extraction Steps

### **STEP 1: Create data_generator.m Skeleton** ⏱️ 30 minutes

#### Tasks:
- [ ] Create new file: `matlab/Scripts/Dataset Generator/data_generator.m`
- [ ] Add file header with comprehensive documentation
- [ ] Define public API function: `runSimulation(config, options)`
- [ ] Add input validation using arguments block
- [ ] Create placeholder for internal functions
- [ ] Test file loads without errors: `edit data_generator`

#### Deliverable:
```matlab
function [successful_trials, dataset_path, metadata] = runSimulation(config, options)
% RUNSIMULATION Execute golf swing simulations without GUI
%
% See DATA_GENERATOR_INTERFACE_SPEC.md for full documentation

arguments
    config struct {mustBeNonempty}
    options struct = struct('verbose', true)
end

% TODO: Implementation
successful_trials = 0;
dataset_path = '';
metadata = struct();

fprintf('data_generator.m skeleton created\n');
end
```

#### Verification:
```matlab
% Test skeleton works
config = createSimulationConfig();
[trials, path, meta] = runSimulation(config);
% Should print message and return zeros/empty
```

**Commit:** `git commit -m "Create data_generator.m skeleton with public API"`

---

### **STEP 2: Extract compileDataset()** ⏱️ 45 minutes

#### Why First:
- Already GUI-independent
- No complex dependencies
- Easy win to build confidence

#### Tasks:
- [ ] Copy compileDataset() from Dataset_GUI.m:4316-4471
- [ ] Paste into data_generator.m as internal function
- [ ] Verify no handles references (should be clean)
- [ ] Update function header documentation
- [ ] Test independently with mock config

#### Code Changes:
```matlab
% In Dataset_GUI.m:
% - Keep function for now (backward compatibility)
% - Add comment: "% DEPRECATED: Use data_generator.compileDataset()"

% In data_generator.m:
% - Add as internal function
% - No changes needed (already clean!)
```

#### Verification:
```matlab
% Create test config
config = createSimulationConfig();
config.output_folder = 'test_output';
config.folder_name = 'test_dataset';

% Create dummy CSV files for testing
mkdir(fullfile(config.output_folder, config.folder_name));
% ... create test CSV files ...

% Test compileDataset
compileDataset(config);  % Should create master_dataset.csv
```

**Commit:** `git commit -m "Extract compileDataset() to data_generator.m"`

---

### **STEP 3: Extract saveScriptAndSettings()** ⏱️ 45 minutes

#### Tasks:
- [ ] Copy saveScriptAndSettings() from Dataset_GUI.m:4506-4669
- [ ] Paste into data_generator.m
- [ ] Verify minimal GUI dependencies (uses config)
- [ ] Test with mock config

#### Verification:
```matlab
config = createSimulationConfig();
config.output_folder = 'test_output';
saveScriptAndSettings(config);
% Should create settings file
```

**Commit:** `git commit -m "Extract saveScriptAndSettings() to data_generator.m"`

---

### **STEP 4: Extract validateCoefficientBounds()** ⏱️ 30 minutes

#### Tasks:
- [ ] Copy validateCoefficientBounds() from Dataset_GUI.m:4472-4505
- [ ] Replace: `get(handles.coeff_table, 'Data')` → `config.coefficient_values`
- [ ] Test with coefficient array

#### Code Changes:
```matlab
% BEFORE:
table_data = get(handles.coeff_table, 'Data');

% AFTER:
table_data = config.coefficient_values;
```

#### Verification:
```matlab
config = createSimulationConfig();
config.coefficient_values = rand(10, 20);
config.coeff_range = 10.0;
validateCoefficientBounds(config, 10.0);  % Should pass
```

**Commit:** `git commit -m "Extract validateCoefficientBounds() with GUI deps removed"`

---

### **STEP 5: Extract and Adapt validateInputs()** ⏱️ 2 hours

#### Why Complex:
- 233 lines of code
- 15+ get() calls to replace
- Complex Simscape validation logic

#### Tasks:
- [ ] Copy validateInputs() from Dataset_GUI.m:4021-4253
- [ ] Rename to `validateSimulationConfig(config)`
- [ ] Remove ALL get(handles.*) calls - use config.* instead
- [ ] Replace shouldShowDebug(handles) with verbosity check
- [ ] Update to return validated config instead of creating new struct
- [ ] Test thoroughly with various configs

#### Replacement Pattern:
```matlab
% BEFORE (15+ instances):
num_trials = str2double(get(handles.num_trials_edit, 'String'));
sim_time = str2double(get(handles.sim_time_edit, 'String'));
enable_logsout = get(handles.use_logsout, 'Value');

// AFTER:
num_trials = config.num_simulations;
sim_time = config.simulation_time;
enable_logsout = config.use_logsout;
```

#### Verification:
```matlab
% Test valid config
config = createSimulationConfig();
config_validated = validateSimulationConfig(config);
assert(isstruct(config_validated));

% Test invalid config (should throw)
bad_config = config;
bad_config.num_simulations = -1;
try
    validateSimulationConfig(bad_config);
    error('Should have thrown error');
catch ME
    assert(contains(ME.identifier, 'DataGenerator'));
end
```

**Commit:** `git commit -m "Extract validateSimulationConfig() - all GUI deps removed"`

---

### **STEP 6: Extract runSequentialSimulations()** ⏱️ 2 hours

#### Tasks:
- [ ] Copy runSequentialSimulations() from Dataset_GUI.m:3832-3982
- [ ] Change signature: Remove `handles` parameter
- [ ] Replace progress updates: `set(handles.progress_text,...)` → `fprintf()`
- [ ] Replace stop check: `checkStopRequest(handles)` → timeout logic
- [ ] Replace checkpoint resume: Use config instead of handles
- [ ] Test with small simulation

#### Code Changes:
```matlab
% BEFORE:
function successful_trials = runSequentialSimulations(handles, config)
    ...
    set(handles.progress_text, 'String', progress_msg);
    if checkStopRequest(handles)
        break;
    end
    if get(handles.enable_checkpoint_resume, 'Value')
        ...
    end
end

% AFTER:
function successful_trials = runSequentialSimulations(config)
    ...
    if ~strcmp(config.verbosity, 'Silent')
        fprintf('%s\n', progress_msg);
    end
    % Remove stop check or use timeout
    if config.enable_checkpoint_resume
        ...
    end
end
```

#### Verification:
```matlab
config = createSimulationConfig();
config.num_simulations = 2;
config.execution_mode = 'sequential';
config.verbosity = 'Verbose';
successful = runSequentialSimulations(config);
assert(successful >= 0 && successful <= 2);
```

**Commit:** `git commit -m "Extract runSequentialSimulations() without GUI deps"`

---

### **STEP 7: Extract runParallelSimulations()** ⏱️ 3 hours

#### Why Most Complex:
- 372 lines of code
- Parallel pool management
- Many progress update points
- Checkpoint logic
- Error handling

#### Tasks:
- [ ] Copy runParallelSimulations() from Dataset_GUI.m:3431-3802
- [ ] Change signature: Remove `handles` parameter
- [ ] Replace ALL progress updates with fprintf() or callback
- [ ] Replace stop checks with timeout or remove
- [ ] Replace checkpoint UI checks with config
- [ ] Keep parallel pool logic (already good)
- [ ] Test with small parallel simulation

#### Progress Callback Pattern:
```matlab
% BEFORE (many instances):
set(handles.progress_text, 'String', progress_msg);
drawnow;

% AFTER (Option 1: Simple fprintf):
if ~strcmp(config.verbosity, 'Silent')
    fprintf('%s\n', progress_msg);
end

% AFTER (Option 2: Optional callback):
if isfield(options, 'progress_callback')
    options.progress_callback(batch_idx, num_batches, progress_msg);
else
    fprintf('%s\n', progress_msg);
end
```

#### Verification:
```matlab
% Check parallel toolbox
if license('test', 'Distrib_Computing_Toolbox')
    config = createSimulationConfig();
    config.num_simulations = 4;
    config.execution_mode = 'parallel';
    config.batch_size = 2;
    successful = runParallelSimulations(config);
    assert(successful >= 0 && successful <= 4);
else
    fprintf('Skipping parallel test - toolbox not available\n');
end
```

**Commit:** `git commit -m "Extract runParallelSimulations() without GUI deps"`

---

### **STEP 8: Implement runSimulation() Orchestrator** ⏱️ 1 hour

#### Tasks:
- [ ] Copy logic from runGeneration() Dataset_GUI.m:3337-3429
- [ ] Remove ALL handles references
- [ ] Call validateSimulationConfig()
- [ ] Route to runParallelSimulations() or runSequentialSimulations()
- [ ] Add metadata collection (timing, success rate, etc.)
- [ ] Implement comprehensive error handling
- [ ] Test end-to-end

#### Implementation:
```matlab
function [successful_trials, dataset_path, metadata] = runSimulation(config, options)
    arguments
        config struct {mustBeNonempty}
        options struct = struct('verbose', true)
    end

    % Start timing
    start_time = datetime('now');

    try
        % Validate configuration
        config = validateSimulationConfig(config);

        % Ensure enhanced config
        config = ensureEnhancedConfig(config);

        % Generate coefficients if not provided
        if isempty(config.coefficient_values)
            config.coefficient_values = generateRandomCoefficients(...
                config.num_simulations, 20);  % Adjust num_coeffs
        end

        % Create output directory
        full_output_path = fullfile(config.output_folder, config.folder_name);
        if ~exist(full_output_path, 'dir')
            mkdir(full_output_path);
        end

        % Execute simulations
        if strcmp(config.execution_mode, 'parallel') && ...
                license('test', 'Distrib_Computing_Toolbox')
            successful_trials = runParallelSimulations(config);
        else
            successful_trials = runSequentialSimulations(config);
        end

        % Compile master dataset if enabled
        if config.enable_master_dataset && successful_trials > 0
            compileDataset(config);
        end

        % Save script and settings
        saveScriptAndSettings(config);

        % Prepare outputs
        dataset_path = full_output_path;
        end_time = datetime('now');

        metadata = struct(...
            'start_time', start_time, ...
            'end_time', end_time, ...
            'duration_seconds', seconds(end_time - start_time), ...
            'successful_trials', successful_trials, ...
            'failed_trials', config.num_simulations - successful_trials, ...
            'success_rate', successful_trials / config.num_simulations, ...
            'execution_mode', config.execution_mode, ...
            'dataset_compiled', config.enable_master_dataset ...
        );

    catch ME
        % Error handling
        error('DataGenerator:SimulationFailed', ...
            'Simulation failed: %s', ME.message);
    end
end
```

#### Verification:
```matlab
% Full end-to-end test
config = createSimulationConfig();
config.num_simulations = 2;
config.execution_mode = 'sequential';
config.output_folder = 'test_output';
config.folder_name = 'e2e_test';

[successful, path, metadata] = runSimulation(config);

% Verify outputs
assert(successful >= 0 && successful <= 2);
assert(exist(path, 'dir') > 0);
assert(isstruct(metadata));
assert(metadata.successful_trials == successful);

fprintf('✅ End-to-end test passed!\n');
```

**Commit:** `git commit -m "Implement runSimulation() orchestrator - data_generator.m complete"`

---

### **STEP 9: Update Dataset_GUI.m Integration** ⏱️ 1 hour

#### Tasks:
- [ ] Keep original functions in Dataset_GUI.m for now (backward compatibility)
- [ ] Add wrapper calls to data_generator.m
- [ ] Test that GUI still works
- [ ] Document deprecation

#### Implementation:
```matlab
% In Dataset_GUI.m runGeneration():
function runGeneration(handles)
    try
        % Convert handles to config (temporary for backward compatibility)
        config = handles.config;

        % Call new data_generator module
        [successful_trials, dataset_path, metadata] = runSimulation(config);

        % Update GUI with results
        if handles.should_stop
            set(handles.status_text, 'String', 'Status: Generation stopped by user');
        else
            final_msg = sprintf('Complete: %d successful, %d failed', ...
                successful_trials, metadata.failed_trials);
            set(handles.status_text, 'String', ['Status: ' final_msg]);
        end

    catch ME
        errordlg(ME.message, 'Generation Failed');
    end
end
```

#### Verification:
```matlab
% Launch Dataset_GUI
Dataset_GUI()
% Run generation through GUI
% Verify works identically to before
```

**Commit:** `git commit -m "Integrate data_generator.m with Dataset_GUI.m"`

---

### **STEP 10: Comprehensive Testing** ⏱️ 2 hours

#### Tasks:
- [ ] Run full test suite: `runtests('test_data_generator')`
- [ ] Test sequential mode with 1, 5, 10 trials
- [ ] Test parallel mode (if toolbox available)
- [ ] Test checkpoint resume
- [ ] Test master dataset compilation
- [ ] Test error handling (invalid configs)
- [ ] Test from command line (no GUI)
- [ ] Test from Dataset_GUI (with GUI)
- [ ] Performance comparison (before/after)

#### Test Script:
```matlab
% test_full_extraction.m
fprintf('=== Running Full Extraction Test Suite ===\n\n');

% Test 1: Basic sequential
fprintf('Test 1: Basic Sequential (2 trials)...\n');
config = createSimulationConfig();
config.num_simulations = 2;
config.execution_mode = 'sequential';
[s1, p1, m1] = runSimulation(config);
assert(s1 >= 0 && s1 <= 2);
fprintf('✅ PASSED\n\n');

% Test 2: Parallel (if available)
if license('test', 'Distrib_Computing_Toolbox')
    fprintf('Test 2: Parallel (4 trials)...\n');
    config.num_simulations = 4;
    config.execution_mode = 'parallel';
    [s2, p2, m2] = runSimulation(config);
    assert(s2 >= 0 && s2 <= 4);
    fprintf('✅ PASSED\n\n');
end

% Test 3: Configuration validation
fprintf('Test 3: Configuration Validation...\n');
bad_config = createSimulationConfig();
bad_config.num_simulations = -1;
try
    runSimulation(bad_config);
    error('Should have thrown error');
catch ME
    assert(contains(ME.identifier, 'DataGenerator'));
end
fprintf('✅ PASSED\n\n');

% Test 4: Dataset_GUI integration
fprintf('Test 4: Dataset_GUI Integration...\n');
% Launch GUI, run manually, verify works
fprintf('✅ MANUAL VERIFICATION REQUIRED\n\n');

fprintf('=== All Tests Complete ===\n');
```

**Commit:** `git commit -m "Add comprehensive test suite for data_generator.m"`

---

### **STEP 11: Documentation and Cleanup** ⏱️ 1 hour

#### Tasks:
- [ ] Update DATA_GENERATOR_INTERFACE_SPEC.md with actual implementation
- [ ] Add usage examples to documentation
- [ ] Create migration guide for users
- [ ] Update README.md with new capabilities
- [ ] Mark old functions as deprecated in Dataset_GUI.m
- [ ] Clean up temporary test files

#### Documentation Files to Update:
- [ ] DATA_GENERATOR_INTERFACE_SPEC.md - Mark as "IMPLEMENTED"
- [ ] README.md - Add counterfactual analysis examples
- [ ] PHASE2_COMPLETION_SUMMARY.md - Create completion report

**Commit:** `git commit -m "Complete Phase 2 documentation and cleanup"`

---

## Final Checklist

### **Code Quality**
- [ ] No handles references in data_generator.m
- [ ] No get()/set() calls on UI elements
- [ ] All functions have comprehensive documentation
- [ ] Input validation on all public functions
- [ ] Consistent error handling with DataGenerator:* IDs
- [ ] Code follows MATLAB style guide

### **Testing**
- [ ] All unit tests pass
- [ ] Integration tests pass
- [ ] Dataset_GUI still works
- [ ] Command-line execution works
- [ ] Parallel mode tested (if available)
- [ ] Sequential mode tested
- [ ] Error handling tested

### **Documentation**
- [ ] Interface specification complete
- [ ] Usage examples provided
- [ ] Migration guide created
- [ ] README updated
- [ ] All commits have clear messages

### **Git**
- [ ] All changes committed
- [ ] Commit messages are descriptive
- [ ] No temporary files committed
- [ ] Branch ready for merge

---

## Merge to Main

### **Pre-Merge Checklist**
- [ ] All tests passing
- [ ] Code reviewed (self-review minimum)
- [ ] Documentation complete
- [ ] No breaking changes to Dataset_GUI.m
- [ ] Performance acceptable

### **Merge Commands**
```bash
# Ensure all work committed
git status

# Update from main
git checkout main
git pull origin main

# Merge feature branch
git merge phase2/extract-data-generator

# Push to remote
git push origin main

# Tag release
git tag -a v2.0-data-generator -m "Phase 2: Extract data_generator.m module"
git push origin v2.0-data-generator
```

---

## Rollback Plan

If extraction fails or causes issues:

```bash
# Option 1: Revert specific commit
git revert <commit-hash>

# Option 2: Reset to before extraction
git reset --hard <commit-before-extraction>

# Option 3: Use backup file
cp Dataset_GUI.m.backup Dataset_GUI.m

# All original code preserved in git history
git log --all -- "matlab/Scripts/Dataset Generator/Dataset_GUI.m"
```

---

## Success Criteria

✅ **Functional:**
- runSimulation(config) works from command line
- Dataset_GUI.m still works as before
- All tests pass

✅ **Quality:**
- Zero GUI dependencies in data_generator.m
- Comprehensive error handling
- Professional documentation

✅ **Capability:**
- Can run parameter sweeps programmatically
- Can run counterfactual analysis
- Foundation for Phase 3 features

---

**Estimated Total Time:** 8-12 hours
**Recommended Approach:** Complete one step per session, commit frequently
**Status:** Ready for execution

**Next:** Begin with STEP 1 when dedicated time available
