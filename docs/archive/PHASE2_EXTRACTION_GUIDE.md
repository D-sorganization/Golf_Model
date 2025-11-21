# Phase 2: data_generator.m Extraction Implementation Guide

**Date:** 2025-11-16
**Purpose:** Detailed code-level guide for extracting data_generator.m from Dataset_GUI.m
**Estimated Time:** 8-12 hours
**Risk Level:** MEDIUM (with proper testing: LOW)

---

## Table of Contents

1. [Overview](#overview)
2. [Before You Begin](#before-you-begin)
3. [Code Extraction Patterns](#code-extraction-patterns)
4. [Function-by-Function Guide](#function-by-function-guide)
5. [Testing Strategy](#testing-strategy)
6. [Rollback Procedures](#rollback-procedures)

---

## Overview

### What We're Doing

Extracting **7 core simulation functions** (~1,500 lines) from Dataset_GUI.m (4,669 lines) into a new standalone module `data_generator.m` that can run simulations **without any GUI**.

### Why This Matters

**Current State (Before):**
```matlab
% Cannot run simulation without GUI
Dataset_GUI();  % Opens window, requires manual interaction
% ❌ Cannot automate
% ❌ Cannot do parameter sweeps
% ❌ Cannot do counterfactual analysis
```

**Target State (After):**
```matlab
% Can run simulation programmatically!
config = createSimulationConfig('num_simulations', 100);
[trials, path, metadata] = runSimulation(config);
% ✅ Fully automated
% ✅ Parameter sweeps possible
% ✅ Counterfactual analysis enabled
```

### Architecture Change

```
BEFORE:
┌─────────────────────────────────────┐
│      Dataset_GUI.m (4,669 lines)    │
│  ┌────────────────────────────────┐ │
│  │ UI Code (handles everywhere)   │ │
│  │ ┌────────────────────────────┐ │ │
│  │ │ Simulation Logic (buried)  │ │ │
│  │ └────────────────────────────┘ │ │
│  └────────────────────────────────┘ │
└─────────────────────────────────────┘

AFTER:
┌──────────────────┐    ┌──────────────────────┐
│ Dataset_GUI.m    │───▶│ data_generator.m     │
│ (3,169 lines)    │    │ (1,500 lines)        │
│                  │    │                      │
│ • UI Code        │    │ • Pure simulation    │
│ • Callbacks      │    │ • No GUI deps        │
│ • Orchestration  │    │ • Config-driven      │
└──────────────────┘    └──────────────────────┘
```

---

## Before You Begin

### Pre-Extraction Checklist

- [ ] **Run baseline validation:**
  ```matlab
  baseline = validate_baseline_behavior();
  save('baseline_before_refactoring.mat', 'baseline');
  ```

- [ ] **Create backup branch:**
  ```bash
  git checkout -b phase2-extraction-backup
  git checkout claude/review-golf-analysis-code-01MPVXk5mNVJpgaHmVxaPHbW
  ```

- [ ] **Verify all tests pass:**
  ```matlab
  cd matlab/tests
  run(test_data_generator)  % Verify test framework works
  ```

- [ ] **Set MATLAB path:**
  ```matlab
  addpath(genpath('matlab/Scripts'));
  addpath('matlab/tests');
  ```

- [ ] **Have Dataset_GUI.m open in editor** for reference

---

## Code Extraction Patterns

### Pattern 1: Remove GUI Dependencies (handles → config)

**BEFORE (GUI-dependent):**
```matlab
function runGeneration(handles)
    num_trials = str2double(get(handles.num_trials_edit, 'String'));
    mode = get(handles.execution_mode_dropdown, 'Value');

    if num_trials < 1
        set(handles.status_text, 'String', 'Error: Invalid trial count');
        return;
    end

    % ... simulation code ...
end
```

**AFTER (Pure function):**
```matlab
function [successful_trials, dataset_path, metadata] = runSimulation(config, options)
    arguments
        config struct {mustBeNonempty}
        options struct = struct('verbose', true)
    end

    % Extract from config (no handles!)
    num_trials = config.num_simulations;
    mode = config.execution_mode;

    % Validate using Design by Contract
    assert(num_trials >= 1 && num_trials <= 10000, ...
        'DataGenerator:InvalidParameter', ...
        'num_simulations must be between 1 and 10000');

    % ... simulation code ...

    % Return values instead of GUI updates
    successful_trials = trials_completed;
    dataset_path = fullfile(config.output_folder, 'dataset.mat');
    metadata = struct('start_time', start_time, 'end_time', end_time);
end
```

**Key Changes:**
1. ❌ No `handles` parameter
2. ✅ Use `config` struct for all inputs
3. ✅ Add `arguments` block for validation
4. ✅ Return values instead of GUI updates
5. ✅ Use error identifiers ('DataGenerator:*')

---

### Pattern 2: Replace GUI Updates (set → fprintf/logger)

**BEFORE (GUI updates):**
```matlab
set(handles.status_text, 'String', 'Running simulation 5/100...');
set(handles.progress_bar, 'Value', 0.05);
drawnow;
```

**AFTER (Console output with verbosity control):**
```matlab
% Option 1: Simple fprintf with verbosity check
if ~strcmp(config.verbosity, 'Silent')
    fprintf('Running simulation %d/%d...\n', current_trial, total_trials);
end

% Option 2: Structured logging function
logMessage(config, 'Normal', 'Running simulation %d/%d...', current_trial, total_trials);

% Option 3: Callback for GUI integration (best for flexibility)
if isfield(config, 'progress_callback') && ~isempty(config.progress_callback)
    config.progress_callback(current_trial, total_trials, metadata);
end
```

**Recommended: Use Option 1 for Phase 2, add callbacks later if needed.**

**Implementation:**
```matlab
function logMessage(config, level, varargin)
    % Simple logging function with verbosity levels
    %
    % Args:
    %   config - Configuration with verbosity field
    %   level - 'Silent', 'Normal', 'Verbose', 'Debug'
    %   varargin - Format string and arguments (like fprintf)

    verbosity_levels = containers.Map(...
        {'Silent', 'Normal', 'Verbose', 'Debug'}, ...
        {0, 1, 2, 3});

    current_level = verbosity_levels(config.verbosity);
    message_level = verbosity_levels(level);

    if message_level <= current_level
        fprintf(varargin{:});
        fprintf('\n');
    end
end
```

---

### Pattern 3: Handle User Interaction (waitbar, stop button)

**BEFORE (Interactive):**
```matlab
if handles.should_stop
    set(handles.status_text, 'String', 'Stopped by user');
    return;
end
```

**AFTER (Timeout-based):**
```matlab
% Check timeout instead of stop button
if toc(start_time) > config.timeout_seconds
    warning('DataGenerator:Timeout', ...
        'Simulation exceeded timeout of %d seconds', config.timeout_seconds);

    metadata.stop_reason = 'timeout';
    metadata.trials_completed = current_trial - 1;
    return;
end
```

**For waitbar:**
```matlab
% BEFORE
wb = waitbar(0, 'Running simulations...');
waitbar(progress/total, wb, sprintf('Progress: %d%%', round(100*progress/total)));
close(wb);

% AFTER (Option 1: No waitbar)
logMessage(config, 'Normal', 'Progress: %d%% (%d/%d)', ...
    round(100*progress/total), progress, total);

% AFTER (Option 2: Optional callback)
if isfield(config, 'progress_callback')
    config.progress_callback(progress, total);
end
```

---

### Pattern 4: File Path Handling

**BEFORE (Relative paths, current directory assumptions):**
```matlab
output_file = 'simulation_output.mat';
save(output_file, 'data');
```

**AFTER (Absolute paths from config):**
```matlab
% Always use absolute paths
output_file = fullfile(config.output_folder, config.folder_name, 'simulation_output.mat');

% Ensure directory exists
if ~exist(fileparts(output_file), 'dir')
    mkdir(fileparts(output_file));
end

% Save with error handling
try
    save(output_file, 'data');
    logMessage(config, 'Verbose', 'Saved output to: %s', output_file);
catch ME
    error('DataGenerator:SaveFailed', ...
        'Failed to save output to %s: %s', output_file, ME.message);
end
```

---

### Pattern 5: Error Handling

**BEFORE (GUI error dialogs):**
```matlab
try
    % ... simulation ...
catch ME
    errordlg(ME.message, 'Simulation Error');
    set(handles.status_text, 'String', 'Error occurred');
end
```

**AFTER (Proper error propagation):**
```matlab
try
    % ... simulation ...
catch ME
    % Add context to error
    error('DataGenerator:SimulationFailed', ...
        'Simulation failed at trial %d/%d: %s', ...
        current_trial, total_trials, ME.message);
end
```

**With stop_on_error flag:**
```matlab
try
    % ... run single trial ...
catch ME
    if config.stop_on_error
        error('DataGenerator:TrialFailed', ...
            'Trial %d failed: %s', trial_idx, ME.message);
    else
        warning('DataGenerator:TrialFailed', ...
            'Trial %d failed (continuing): %s', trial_idx, ME.message);

        metadata.failed_trials(end+1) = trial_idx;
        continue;  % Continue to next trial
    end
end
```

---

## Function-by-Function Guide

### Function 1: runSimulation() (Main Entry Point)

**Location:** New function (extracts logic from runGeneration)
**Lines to Extract:** ~200 lines from Dataset_GUI.m:3200-3400
**Time Estimate:** 2 hours

**Skeleton:**
```matlab
function [successful_trials, dataset_path, metadata] = runSimulation(config, options)
% RUNSIMULATION Run golf swing simulation with given configuration
%
% This is the main entry point for the data generator. It orchestrates
% the entire simulation process from validation to execution to compilation.
%
% Args:
%   config - Simulation configuration struct (from createSimulationConfig)
%   options - Optional settings struct
%     .verbose - Enable verbose output (default: true)
%     .progress_callback - Function handle for progress updates (optional)
%
% Returns:
%   successful_trials - Number of successfully completed trials
%   dataset_path - Path to compiled dataset file
%   metadata - Struct with execution metadata
%
% Example:
%   config = createSimulationConfig('num_simulations', 100);
%   [trials, path, meta] = runSimulation(config);
%
% See also: CREATESIMULATIONCONFIG, RUNPARALLELSIMULATIONS, COMPILEDATASET

arguments
    config struct {mustBeNonempty}
    options struct = struct('verbose', true)
end

%% Validate Configuration

% Use existing validateSimulationConfig (in createSimulationConfig.m)
validateSimulationConfig(config);

%% Initialize Metadata

metadata = struct();
metadata.start_time = datetime('now');
metadata.matlab_version = version;
metadata.config = config;
metadata.failed_trials = [];

start_timer = tic;

%% Ensure Enhanced Configuration

% This function adds computed fields to config
% (Extract ensureEnhancedConfig from Dataset_GUI.m)
config = ensureEnhancedConfig(config);

%% Create Output Directory

output_dir = fullfile(config.output_folder, config.folder_name);
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
    logMessage(config, 'Normal', 'Created output directory: %s', output_dir);
end

config.full_output_path = output_dir;

%% Save Configuration

config_file = fullfile(output_dir, 'simulation_config.mat');
save(config_file, 'config');
logMessage(config, 'Verbose', 'Saved configuration to: %s', config_file);

%% Run Simulations

logMessage(config, 'Normal', 'Starting %d simulations in %s mode...', ...
    config.num_simulations, config.execution_mode);

if strcmp(config.execution_mode, 'parallel')
    [successful_trials, trial_metadata] = runParallelSimulations(config);
else
    [successful_trials, trial_metadata] = runSequentialSimulations(config);
end

metadata.trial_metadata = trial_metadata;
metadata.successful_trials = successful_trials;

%% Compile Dataset

if successful_trials > 0 && config.enable_master_dataset
    logMessage(config, 'Normal', 'Compiling master dataset...');
    dataset_path = compileDataset(config);
    metadata.dataset_path = dataset_path;
else
    dataset_path = '';
    logMessage(config, 'Normal', 'No dataset compiled (successful_trials=%d, enable=%d)', ...
        successful_trials, config.enable_master_dataset);
end

%% Finalize Metadata

metadata.end_time = datetime('now');
metadata.elapsed_seconds = toc(start_timer);
metadata.success_rate = successful_trials / config.num_simulations;

% Save metadata
metadata_file = fullfile(output_dir, 'execution_metadata.mat');
save(metadata_file, 'metadata');

%% Log Summary

logMessage(config, 'Normal', '\n=== SIMULATION COMPLETE ===');
logMessage(config, 'Normal', 'Successful trials: %d/%d (%.1f%%)', ...
    successful_trials, config.num_simulations, 100*metadata.success_rate);
logMessage(config, 'Normal', 'Elapsed time: %.1f seconds', metadata.elapsed_seconds);
if ~isempty(dataset_path)
    logMessage(config, 'Normal', 'Dataset: %s', dataset_path);
end
logMessage(config, 'Normal', 'Output directory: %s\n', output_dir);

end
```

**Code to Extract from Dataset_GUI.m:**

1. **Lines ~3200-3220:** Configuration validation
2. **Lines ~3230-3250:** Output directory creation
3. **Lines ~3260-3280:** Coefficient extraction (replace with config.coefficient_values)
4. **Lines ~3290-3310:** Parallel/sequential dispatcher
5. **Lines ~3350-3370:** Dataset compilation
6. **Lines ~3380-3400:** Metadata saving

**GUI Dependencies to Remove:**

```matlab
% REMOVE these lines:
set(handles.status_text, 'String', '...');
set(handles.progress_bar, 'Value', ...);
handles.should_stop = ...;
drawnow;

% REPLACE with:
logMessage(config, 'Normal', '...');
% (no progress bar updates)
% (no stop button, use timeout instead)
```

---

### Function 2: runParallelSimulations()

**Location:** Dataset_GUI.m:3431-3802 (372 lines)
**Time Estimate:** 3-4 hours (most complex function)

**Key Extraction Steps:**

1. **Copy entire function** to data_generator.m
2. **Update signature:**
   ```matlab
   % BEFORE
   function [successful_trials, metadata] = runParallelSimulations(handles, config)

   % AFTER
   function [successful_trials, metadata] = runParallelSimulations(config)
   ```

3. **Remove all handles references** (~50 instances):
   ```matlab
   % Find all instances of:
   handles.should_stop
   handles.status_text
   handles.progress_bar
   handles.progress_text

   % Replace with appropriate alternatives (see patterns above)
   ```

4. **Update parallel pool management:**
   ```matlab
   % BEFORE (assumes GUI handles pool)
   if isempty(gcp('nocreate'))
       parpool(14);  % Hardcoded!
   end

   % AFTER (config-driven)
   pool = gcp('nocreate');
   if isempty(pool)
       if isfield(config, 'num_workers') && config.num_workers > 0
           parpool(config.num_workers);
           logMessage(config, 'Normal', 'Created parallel pool with %d workers', ...
               config.num_workers);
       else
           parpool();  % Auto-detect
           logMessage(config, 'Normal', 'Created parallel pool (auto-detect workers)');
       end
   else
       logMessage(config, 'Verbose', 'Using existing parallel pool (%d workers)', ...
           pool.NumWorkers);
   end
   ```

5. **Update progress reporting:**
   ```matlab
   % BEFORE (inside parfor)
   fprintf('Worker %d: Completed trial %d\n', labindex, trial_idx);

   % AFTER (with verbosity control)
   if strcmp(config.verbosity, 'Debug')
       fprintf('[Worker %d] Trial %d/%d complete\n', ...
           labindex, trial_idx, config.num_simulations);
   end
   ```

6. **Handle checkpoints:**
   ```matlab
   % Checkpoint saving logic is OK to keep
   % Just remove GUI updates about checkpoint status

   % BEFORE
   set(handles.checkpoint_text, 'String', 'Checkpoint saved');

   % AFTER
   logMessage(config, 'Verbose', 'Checkpoint saved at trial %d', trial_idx);
   ```

**Critical Section - Parallel Trial Execution:**

```matlab
% This section is ~150 lines and needs careful extraction
% Location: Dataset_GUI.m:3550-3700

parfor trial_idx = 1:config.num_simulations
    try
        % Generate coefficient values for this trial
        if isempty(config.coefficient_values)
            % Generate random coefficients based on torque_scenario
            trial_coeffs = generateTrialCoefficients(config, trial_idx);
        else
            % Use pre-specified coefficients
            trial_coeffs = config.coefficient_values(trial_idx, :);
        end

        % Set up trial-specific configuration
        trial_config = config;
        trial_config.current_trial = trial_idx;
        trial_config.coefficients = trial_coeffs;

        % Run single trial simulation
        trial_result = runSingleTrial(trial_config);

        % Store result (with parsave for parfor compatibility)
        trial_output_file = fullfile(config.full_output_path, ...
            sprintf('trial_%04d.mat', trial_idx));
        parsave(trial_output_file, trial_result);

        % Update success count (using atomic operation)
        successful_trials_arr(trial_idx) = 1;

        % Log progress (worker-specific)
        if strcmp(config.verbosity, 'Debug')
            fprintf('[Worker %d] Trial %d complete\n', labindex, trial_idx);
        end

    catch ME
        % Handle trial failure
        if config.stop_on_error
            % Re-throw to stop all workers
            rethrow(ME);
        else
            % Log and continue
            warning('DataGenerator:TrialFailed', ...
                'Trial %d failed: %s', trial_idx, ME.message);
            successful_trials_arr(trial_idx) = 0;
        end
    end
end

% Sum successful trials
successful_trials = sum(successful_trials_arr);
```

**Helper Function Needed:**
```matlab
function parsave(filename, data)
    % PARSAVE Save data in parfor loop
    % parfor doesn't allow direct save() calls
    save(filename, 'data');
end
```

---

### Function 3: runSequentialSimulations()

**Location:** Dataset_GUI.m:3810-3950 (140 lines)
**Time Estimate:** 1-2 hours
**Complexity:** MEDIUM (simpler than parallel)

**Skeleton:**
```matlab
function [successful_trials, metadata] = runSequentialSimulations(config)
% RUNSEQUENTIALSIMULATIONS Run simulations sequentially (no parallelization)
%
% Args:
%   config - Simulation configuration
%
% Returns:
%   successful_trials - Number of successful trials
%   metadata - Execution metadata

metadata = struct();
metadata.mode = 'sequential';
metadata.start_time = datetime('now');

successful_trials = 0;
trial_results = cell(config.num_simulations, 1);

start_timer = tic;

for trial_idx = 1:config.num_simulations
    trial_start = tic;

    try
        % Log progress
        logMessage(config, 'Normal', 'Running trial %d/%d...', ...
            trial_idx, config.num_simulations);

        % Generate coefficients
        if isempty(config.coefficient_values)
            trial_coeffs = generateTrialCoefficients(config, trial_idx);
        else
            trial_coeffs = config.coefficient_values(trial_idx, :);
        end

        % Set up trial config
        trial_config = config;
        trial_config.current_trial = trial_idx;
        trial_config.coefficients = trial_coeffs;

        % Run trial
        trial_result = runSingleTrial(trial_config);

        % Save result
        trial_output_file = fullfile(config.full_output_path, ...
            sprintf('trial_%04d.mat', trial_idx));
        save(trial_output_file, 'trial_result');

        successful_trials = successful_trials + 1;
        trial_results{trial_idx} = trial_result;

        % Log time
        trial_elapsed = toc(trial_start);
        logMessage(config, 'Verbose', '  Completed in %.2f seconds', trial_elapsed);

    catch ME
        if config.stop_on_error
            error('DataGenerator:TrialFailed', ...
                'Trial %d failed: %s', trial_idx, ME.message);
        else
            warning('DataGenerator:TrialFailed', ...
                'Trial %d failed: %s', trial_idx, ME.message);
            metadata.failed_trials(end+1) = trial_idx;
        end
    end

    % Check timeout
    if toc(start_timer) > config.timeout_seconds
        warning('DataGenerator:Timeout', 'Simulation timeout exceeded');
        metadata.stop_reason = 'timeout';
        break;
    end
end

metadata.end_time = datetime('now');
metadata.successful_trials = successful_trials;
metadata.elapsed_seconds = toc(start_timer);
metadata.trial_results = trial_results;

end
```

---

### Functions 4-7: Supporting Functions

**4. validateInputs()** (Dataset_GUI.m:~3960-4160, 200 lines)
- Extract to validateSimulationConfig() (already in createSimulationConfig.m)
- Merge any additional validation logic
- Time: 1 hour

**5. compileDataset()** (Dataset_GUI.m:~4170-4300, 130 lines)
- Direct extraction (minimal GUI dependencies)
- Update file paths to use config.full_output_path
- Time: 1 hour

**6. ensureEnhancedConfig()** (Dataset_GUI.m:~4310-4400, 90 lines)
- Direct extraction
- Adds computed fields to config
- Time: 30 minutes

**7. generateTrialCoefficients()** (May need to create new)
- Extract coefficient generation logic
- Currently embedded in runParallelSimulations
- Time: 1 hour

---

## Testing Strategy

### Test After Each Function

After extracting each function, run:

```matlab
% Test configuration builder
config = createSimulationConfig();
assert(~isempty(config));

% Test validation
try
    validateSimulationConfig(config);
    disp('✅ Validation passed');
catch ME
    disp(['❌ Validation failed: ' ME.message]);
end

% Test enhanced config
config_enhanced = ensureEnhancedConfig(config);
assert(~isempty(config_enhanced));
```

### Integration Test (After All Functions Extracted)

```matlab
% Run minimal simulation
config = createSimulationConfig();
config.num_simulations = 2;
config.execution_mode = 'sequential';
config.output_folder = fullfile(pwd, 'test_output');
config.verbosity = 'Verbose';

[trials, path, metadata] = runSimulation(config);

assert(trials >= 0, 'Should return trial count');
disp('✅ Integration test passed');
```

### Comparison Test (Ensure Identical Behavior)

```matlab
% After refactoring, run baseline validation again
new_results = validate_baseline_behavior();

% Load baseline
load('baseline_before_refactoring.mat', 'baseline');

% Compare
compareResults(baseline, new_results);
```

---

## Rollback Procedures

### If Things Go Wrong

**Option 1: Revert Specific File**
```bash
git checkout HEAD -- matlab/Scripts/Dataset\ Generator/data_generator.m
```

**Option 2: Revert All Changes**
```bash
git reset --hard HEAD
```

**Option 3: Switch to Backup Branch**
```bash
git checkout phase2-extraction-backup
```

### Save Work-in-Progress

```bash
# Commit partial work
git add -A
git commit -m "WIP: Partial extraction of data_generator.m (X/7 functions done)"
git push -u origin claude/review-golf-analysis-code-01MPVXk5mNVJpgaHmVxaPHbW
```

---

## Success Criteria

✅ **data_generator.m created** with 7 core functions
✅ **No handles dependencies** in extracted code
✅ **All tests pass** (baseline validation identical)
✅ **runSimulation(config) works** without GUI
✅ **Dataset_GUI.m still functional** (calls new module)
✅ **Code committed** with clear message

---

## Estimated Timeline

| Step | Task | Time |
|------|------|------|
| 1 | Create skeleton + runSimulation() | 2 hours |
| 2 | Extract runParallelSimulations() | 3-4 hours |
| 3 | Extract runSequentialSimulations() | 1-2 hours |
| 4-7 | Extract supporting functions | 2-3 hours |
| 8 | Testing & debugging | 1-2 hours |
| 9 | Update Dataset_GUI.m integration | 1 hour |
| 10 | Final validation & commit | 30 min |
| **TOTAL** | **11-15 hours** |

---

## Next Steps After Extraction

1. Update Dataset_GUI.m to call `runSimulation(config)` instead of inline logic
2. Run full test suite and validate GUI still works
3. Write documentation for new module
4. Commit with detailed message
5. Celebrate! 🎉
6. Move to next module (batch_processor.m or coefficient_manager.m)

---

**Ready to begin? Follow PHASE2_REFACTORING_CHECKLIST.md for step-by-step instructions.**
