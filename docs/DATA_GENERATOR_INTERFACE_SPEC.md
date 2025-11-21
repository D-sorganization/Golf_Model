# data_generator.m Interface Specification
**Module:** data_generator.m (To be extracted from Dataset_GUI.m)
**Purpose:** Pure simulation engine with NO GUI dependencies
**Status:** Specification - Ready for implementation

---

## Overview

The `data_generator.m` module provides a clean, reusable interface for running golf swing simulations programmatically. This enables counterfactual analysis, parameter sweeps, and batch processing without GUI interaction.

**Key Principle:** ZERO GUI DEPENDENCIES
- No `handles` structure
- No `get()`/`set()` calls on UI elements
- Pure function interfaces
- Config-driven execution

---

## Public API

### **Primary Function: runSimulation()**

```matlab
function [successful_trials, dataset_path, metadata] = runSimulation(config, options)
    % RUNSIMULATION Execute golf swing simulation(s) without GUI
    %
    % Args:
    %   config - Struct with simulation configuration (see below)
    %   options - Optional struct with execution options
    %
    % Returns:
    %   successful_trials - Number of successfully completed simulations
    %   dataset_path - Path to output dataset folder
    %   metadata - Struct with execution metadata (timing, errors, etc.)
    %
    % Example:
    %   config = createSimulationConfig();
    %   config.num_simulations = 100;
    %   [trials, path, meta] = runSimulation(config);
    %
    % See also: CREATESIMULATIONCONFIG, VALIDATESIMULATIONCONFIG
```

**Signature:**
```matlab
[successful_trials, dataset_path, metadata] = runSimulation(config, options)
```

**Input Validation:**
```matlab
arguments
    config struct {mustBeNonempty}
    options struct = struct('verbose', true)
end
```

---

## Configuration Structure

### **config (required fields)**

```matlab
config = struct(...
    % === Model Configuration ===
    'model_name', 'GolfSwing3D_Model', ...         % Simulink model name
    'model_path', '/path/to/model.slx', ...        % Full path to model file
    ...
    % === Simulation Parameters ===
    'num_simulations', 100, ...                     % Number of trials to run
    'simulation_time', 0.5, ...                     % Simulation duration (seconds)
    'sample_rate', 1000, ...                        % Data sampling rate (Hz)
    ...
    % === Execution Configuration ===
    'execution_mode', 'parallel', ...               % 'sequential' or 'parallel'
    'batch_size', 10, ...                           % Trials per batch
    'save_interval', 5, ...                         % Batches between checkpoints
    ...
    % === Data Sources ===
    'use_logsout', true, ...                        % Extract from logsout
    'use_signal_bus', true, ...                     % Extract from signal bus
    'use_simscape', true, ...                       % Extract from Simscape
    ...
    % === Output Configuration ===
    'output_folder', '/path/to/output', ...         % Base output directory
    'folder_name', 'dataset_name', ...              % Dataset folder name
    ...
    % === Coefficient Configuration ===
    'torque_scenario', 1, ...                       % 1=Variable, 2=Zero, 3=Constant
    'coeff_range', 10.0, ...                        % Range for random coefficients
    'coefficient_values', [], ...                   % Pre-generated coefficients (optional)
    ...
    % === Optional Settings ===
    'verbosity', 'Normal', ...                      % 'Silent', 'Normal', 'Verbose', 'Debug'
    'enable_animation', false, ...                  % Enable Simulink animation
    'capture_workspace', false, ...                 % Capture workspace variables
    'enable_memory_monitoring', false, ...          % Monitor memory usage
    'enable_checkpoint_resume', true, ...           % Enable resume from checkpoint
    'input_file', '' ...                            % Optional input data file
);
```

### **Validation Requirements**

All config fields must pass:
```matlab
% Model validation
assert(exist(config.model_path, 'file') > 0, 'Model file must exist');

% Numeric validation
assert(config.num_simulations > 0 && config.num_simulations <= 10000, ...
    'num_simulations must be 1-10000');
assert(config.simulation_time > 0 && config.simulation_time <= 60, ...
    'simulation_time must be 0.001-60 seconds');
assert(config.sample_rate > 0 && config.sample_rate <= 10000, ...
    'sample_rate must be 1-10000 Hz');

% Data source validation
assert(config.use_logsout || config.use_signal_bus || config.use_simscape, ...
    'At least one data source must be enabled');

% Path validation
assert(~isempty(config.output_folder), 'output_folder cannot be empty');
```

---

## Return Values

### **successful_trials (integer)**
```matlab
% Number of simulations that completed successfully
% Range: 0 to config.num_simulations
% Example: 95 (if 95 out of 100 trials succeeded)
```

### **dataset_path (string)**
```matlab
% Full path to generated dataset directory
% Example: '/path/to/output/dataset_name_20251116_142530'
% Contains: trial_001.csv, trial_002.csv, ..., master_dataset.csv (optional)
```

### **metadata (struct)**
```matlab
metadata = struct(...
    'start_time', datetime(...), ...        % Execution start time
    'end_time', datetime(...), ...          % Execution end time
    'duration_seconds', 125.3, ...          % Total execution time
    'successful_trials', 95, ...            % Number of successful trials
    'failed_trials', 5, ...                 % Number of failed trials
    'success_rate', 0.95, ...               % Success rate (0-1)
    'execution_mode', 'parallel', ...       % Mode used
    'num_workers', 14, ...                  % Workers used (if parallel)
    'errors', {...}, ...                    % Cell array of error messages
    'checkpoint_used', false, ...           % Whether resumed from checkpoint
    'dataset_compiled', true ...            % Whether master dataset created
);
```

---

## Helper Functions (Public)

### **createSimulationConfig()**

```matlab
function config = createSimulationConfig(varargin)
    % CREATESIMULATIONCONFIG Create simulation configuration with defaults
    %
    % Args:
    %   varargin - Name-value pairs to override defaults
    %
    % Returns:
    %   config - Struct with default configuration
    %
    % Example:
    %   config = createSimulationConfig('num_simulations', 50, 'execution_mode', 'parallel');
```

### **validateSimulationConfig()**

```matlab
function validateSimulationConfig(config)
    % VALIDATESIMULATIONCONFIG Validate configuration structure
    %
    % Args:
    %   config - Configuration struct to validate
    %
    % Throws:
    %   Error if validation fails
    %
    % Example:
    %   validateSimulationConfig(config);  % Throws if invalid
```

### **getAvailableModels()**

```matlab
function models = getAvailableModels()
    % GETAVAILABLEMODELS List available Simulink models
    %
    % Returns:
    %   models - Cell array of model names
    %
    % Example:
    %   models = getAvailableModels();
    %   % Returns: {'GolfSwing3D_Model', 'GolfSwing2D_Model'}
```

---

## Internal Functions (Private)

These functions are internal to data_generator.m:

### **runParallelSimulations()**
```matlab
function successful_trials = runParallelSimulations(config)
    % Execute simulations in parallel using parpool
```

### **runSequentialSimulations()**
```matlab
function successful_trials = runSequentialSimulations(config)
    % Execute simulations sequentially
```

### **prepareSimulationInputsForBatch()**
```matlab
function simInputs = prepareSimulationInputsForBatch(config, start_trial, end_trial)
    % Prepare SimulationInput objects for batch
```

### **processSimulationResults()**
```matlab
function results = processSimulationResults(simOutputs, config)
    % Process simulation outputs and save data
```

### **compileDataset()**
```matlab
function compileDataset(config)
    % Compile individual trial files into master dataset
```

### **saveCheckpoint()**
```matlab
function saveCheckpoint(config, completed_trials, next_batch)
    % Save checkpoint for resume capability
```

### **loadCheckpoint()**
```matlab
function [completed_trials, next_batch] = loadCheckpoint(config)
    % Load checkpoint if exists
```

---

## Usage Examples

### **Example 1: Basic Sequential Simulation**

```matlab
% Create configuration
config = createSimulationConfig();
config.num_simulations = 10;
config.execution_mode = 'sequential';
config.output_folder = '/path/to/output';

% Run simulation
[successful, path, metadata] = runSimulation(config);

% Check results
fprintf('Completed %d of %d trials (%.1f%%)\n', ...
    successful, config.num_simulations, metadata.success_rate * 100);
fprintf('Dataset saved to: %s\n', path);
```

### **Example 2: Parallel Simulation with Custom Settings**

```matlab
% Create configuration with custom settings
config = createSimulationConfig(...
    'num_simulations', 100, ...
    'execution_mode', 'parallel', ...
    'batch_size', 20, ...
    'verbosity', 'Verbose' ...
);
config.output_folder = '/path/to/output';

% Run parallel simulation
[successful, path, metadata] = runSimulation(config);

% Report results
fprintf('Duration: %.1f seconds\n', metadata.duration_seconds);
fprintf('Workers used: %d\n', metadata.num_workers);
```

### **Example 3: Parameter Sweep (Counterfactual Analysis)**

```matlab
% Define parameter values to sweep
driver_masses = linspace(0.28, 0.34, 10);  % 10 different masses
results = cell(length(driver_masses), 1);

% Base configuration
config = createSimulationConfig();
config.num_simulations = 50;
config.execution_mode = 'parallel';

% Sweep parameter
for i = 1:length(driver_masses)
    % Modify configuration
    config.driver_mass = driver_masses(i);
    config.folder_name = sprintf('mass_%.3f', driver_masses(i));
    config.output_folder = '/path/to/sweep_results';

    % Run simulation
    [successful, path, metadata] = runSimulation(config);

    % Store results
    results{i} = struct(...
        'mass', driver_masses(i), ...
        'successful_trials', successful, ...
        'dataset_path', path, ...
        'metadata', metadata ...
    );

    fprintf('Mass %.3f: %d successful trials\n', driver_masses(i), successful);
end

% Analyze results
analyzeParameterSweep(results);
```

### **Example 4: Counterfactual Comparison**

```matlab
% Baseline scenario
config_baseline = createSimulationConfig();
config_baseline.num_simulations = 100;
config_baseline.swing_speed = 100;  % mph
config_baseline.folder_name = 'baseline';
[trials_base, path_base, meta_base] = runSimulation(config_baseline);

% Counterfactual: +10% swing speed
config_cf = config_baseline;
config_cf.swing_speed = 110;  % +10%
config_cf.folder_name = 'counterfactual_plus10pct';
[trials_cf, path_cf, meta_cf] = runSimulation(config_cf);

% Load and compare results
data_base = readtable(fullfile(path_base, 'master_dataset.csv'));
data_cf = readtable(fullfile(path_cf, 'master_dataset.csv'));

% Analyze counterfactual effect
effect = analyzeCounterfactual(data_base, data_cf);
fprintf('Effect of +10%% swing speed:\n');
fprintf('  ΔDistance: %.1f yards\n', effect.distance_diff);
fprintf('  ΔClub Speed: %.1f mph\n', effect.chs_diff);
```

---

## Dependencies

### **External Functions Required**

These functions must be available in the MATLAB path:

```matlab
% Data processing
extractSignalsFromSimOut.m
processSimulationOutput.m
extractAllSignalsFromBus.m
extractLogsoutDataFixed.m
extractSimscapeDataRecursive.m

% Model configuration
setModelParameters.m
setPolynomialCoefficients.m

% Utilities
generateRandomCoefficients.m
restoreWorkspace.m
checkStopRequest.m  % Will be replaced with timeout check
mergeTabl.m
resampleDataToFrequency.m

% Coefficient management
extractCoefficientsFromTable.m  % Will be replaced with direct array
getShortenedJointName.m
getPolynomialParameterInfo.m
```

### **Toolbox Requirements**

```matlab
% Required
Simulink
Simscape (if use_simscape = true)
Parallel Computing Toolbox (if execution_mode = 'parallel')

% Optional
Simscape Multibody (for 3D golf swing model)
Signal Processing Toolbox
Statistics and Machine Learning Toolbox
```

---

## Error Handling

### **Standard Error IDs**

```matlab
'DataGenerator:ModelNotFound'          % Model file doesn't exist
'DataGenerator:InvalidConfig'          % Configuration validation failed
'DataGenerator:SimulationFailed'       % Simulation execution failed
'DataGenerator:ParallelPoolFailed'     % Parallel pool creation failed
'DataGenerator:InsufficientMemory'     % Out of memory
'DataGenerator:InvalidOutput'          % Output validation failed
```

### **Error Handling Pattern**

```matlab
try
    [successful, path, metadata] = runSimulation(config);
catch ME
    switch ME.identifier
        case 'DataGenerator:ModelNotFound'
            error('Check model path: %s', config.model_path);
        case 'DataGenerator:InvalidConfig'
            error('Fix configuration: %s', ME.message);
        otherwise
            rethrow(ME);
    end
end
```

---

## Performance Considerations

### **Memory Management**

```matlab
% Batch processing prevents memory overflow
config.batch_size = 10;  % Process 10 trials at a time

% Memory cleanup after each batch
% Automatic workspace restoration
% Java garbage collection invoked
```

### **Parallel Execution**

```matlab
% Optimal worker count
num_workers = min(14, feature('numcores'));

% Fallback to sequential if parallel fails
% Automatic pool health checking
% Graceful degradation
```

### **Checkpointing**

```matlab
% Resume from checkpoint
config.enable_checkpoint_resume = true;
config.save_interval = 5;  % Save every 5 batches

% Checkpoint file location
% output_folder/parallel_checkpoint.mat (or sequential_checkpoint.mat)
```

---

## Testing Strategy

### **Unit Tests**

```matlab
% Test individual functions
test_validateSimulationConfig()
test_createSimulationConfig()
test_prepareSimulationInputsForBatch()
```

### **Integration Tests**

```matlab
% Test full workflow
test_runSimulation_sequential()
test_runSimulation_parallel()
test_runSimulation_with_checkpoint()
```

### **Regression Tests**

```matlab
% Ensure refactoring preserves functionality
test_backward_compatibility_with_Dataset_GUI()
test_output_matches_original_Dataset_GUI()
```

---

## Migration Path

### **Phase 2A: Wrapper Approach**

```matlab
% Create wrapper that calls existing Dataset_GUI functions
% Minimal changes, proves concept
function [successful, path, metadata] = runSimulation(config)
    % Convert config to handles structure
    handles = configToHandles(config);

    % Call existing functions
    successful = runParallelSimulations(handles, config);

    % Extract metadata
    path = config.output_folder;
    metadata = struct();
end
```

### **Phase 2B: Full Extraction**

```matlab
% Extract functions from Dataset_GUI.m
% Remove all GUI dependencies
% Implement pure function interfaces
% Comprehensive testing
```

---

## Success Criteria

✅ **runSimulation()** executes without any GUI dependencies
✅ Can call from command line or scripts
✅ All tests pass
✅ Dataset_GUI.m can use data_generator.m
✅ Output format identical to original
✅ Performance equivalent or better
✅ Error handling comprehensive

---

**Next Steps:**
1. Implement createSimulationConfig() helper
2. Create data_generator.m skeleton
3. Extract runParallelSimulations() with GUI deps removed
4. Extract runSequentialSimulations() with GUI deps removed
5. Extract helper functions
6. Implement comprehensive error handling
7. Run test suite
8. Integrate with Dataset_GUI.m

**Status:** Ready for implementation
