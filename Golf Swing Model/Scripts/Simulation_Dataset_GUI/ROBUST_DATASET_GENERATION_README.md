# Robust Dataset Generation System

## Overview

This system provides crash-resistant dataset generation for large-scale golf swing simulations. It addresses the common issue of MATLAB crashes during long-running simulations by implementing:

- **Memory monitoring and management**
- **Batch processing with automatic sizing**
- **Checkpoint-based progress saving**
- **Automatic recovery from crashes**
- **Parallel pool management with limits**

## Problem Analysis

### Why MATLAB Crashes with Large Datasets

1. **Memory Exhaustion**: Simscape logging can consume massive amounts of memory
2. **Parallel Pool Overload**: Too many workers loading large models simultaneously
3. **No Intermediate Saves**: All progress lost if crash occurs
4. **No Memory Monitoring**: System runs until it crashes
5. **No Batch Processing**: Trying to run all simulations at once

### Typical Crash Scenarios

- **10,000 simulations**: Memory exhaustion after ~2,000-3,000 trials
- **Parallel processing**: Worker memory limits exceeded
- **Simscape logging**: Large output data overwhelming system
- **No recovery mechanism**: Hours of work lost

## Solution Components

### 1. Robust Dataset Generator (`robust_dataset_generator.m`)

**Features:**
- Automatic batch sizing based on available memory
- Intermediate checkpoint saves every N trials
- Memory monitoring and cleanup
- Parallel pool management with limits
- Automatic fallback to sequential processing
- Progress tracking and resume capability

**Usage:**
```matlab
% Basic usage
robust_dataset_generator(config)

% With custom parameters
robust_dataset_generator(config, ...
    'BatchSize', 100, ...           % Trials per batch
    'SaveInterval', 50, ...         % Save every N trials
    'MaxMemoryGB', 8, ...           % Max memory usage
    'MaxWorkers', 4, ...            % Max parallel workers
    'ResumeFrom', 'checkpoint.mat') % Resume from checkpoint
```

### 2. Memory Monitor (`memory_monitor.m`)

**Features:**
- Real-time memory usage monitoring
- Automatic warnings for high memory usage
- Memory cleanup utilities
- Continuous monitoring mode

**Usage:**
```matlab
% Display current memory status
memory_monitor()

% Check if memory is low
memory_monitor('check')

% Continuous monitoring (every 30 seconds)
memory_monitor('monitor', 30)

% Force memory cleanup
memory_monitor('cleanup')
```

### 3. Checkpoint Recovery (`checkpoint_recovery.m`)

**Features:**
- List and analyze available checkpoints
- Resume interrupted generation
- Clean up old checkpoint files
- Detailed checkpoint analysis

**Usage:**
```matlab
% List all available checkpoints
checkpoint_recovery()

% Resume from specific checkpoint
checkpoint_recovery('resume', 'checkpoint_20250730_123456.mat')

% Analyze checkpoint contents
checkpoint_recovery('analyze', 'checkpoint_20250730_123456.mat')

% Clean up old checkpoints
checkpoint_recovery('cleanup', './output_folder')
```

## Best Practices for Large-Scale Generation

### 1. Memory Management

**Before Starting:**
```matlab
% Check available memory
memory_monitor()

% Clean up if needed
memory_monitor('cleanup')

% Close unnecessary applications
% - Close other MATLAB instances
% - Close memory-intensive applications
% - Ensure sufficient disk space for checkpoints
```

**During Generation:**
```matlab
% Monitor memory usage
memory_monitor('monitor', 60)  % Check every minute

% If memory gets low, the system will automatically:
% - Pause for cleanup
% - Reduce batch size
% - Fall back to sequential processing
```

### 2. Batch Size Optimization

**Recommended Settings:**
- **Small datasets (< 1,000 trials)**: Batch size 50-100
- **Medium datasets (1,000-5,000 trials)**: Batch size 100-200
- **Large datasets (5,000-10,000 trials)**: Batch size 100-150
- **Very large datasets (> 10,000 trials)**: Batch size 50-100

**Automatic Optimization:**
The system automatically calculates optimal batch size based on:
- Available physical memory
- Estimated memory per simulation
- System overhead requirements

### 3. Checkpoint Strategy

**Save Intervals:**
- **Small datasets**: Save every 25-50 trials
- **Large datasets**: Save every 50-100 trials
- **Very large datasets**: Save every 100 trials

**Checkpoint Management:**
```matlab
% List checkpoints before starting
checkpoint_recovery()

% Resume if interrupted
checkpoint_recovery('resume', 'latest_checkpoint.mat')

% Clean up old checkpoints periodically
checkpoint_recovery('cleanup', './output_folder')
```

### 4. Parallel Processing

**Worker Limits:**
- **Memory-constrained systems**: 2-4 workers
- **Standard systems**: 4-6 workers
- **High-memory systems**: 6-8 workers

**Fallback Strategy:**
- System automatically falls back to sequential if parallel fails
- Individual batch failures don't stop the entire process
- Memory monitoring prevents worker overload

## Example Workflow for 10,000 Simulations

### Step 1: Preparation
```matlab
% Check system resources
memory_monitor()

% Clean up memory
memory_monitor('cleanup')

% Verify model configuration
checkModelConfiguration()
```

### Step 2: Start Generation
```matlab
% Configure for large dataset
config.num_simulations = 10000;

% Use robust generator with conservative settings
robust_dataset_generator(config, ...
    'BatchSize', 100, ...           % Conservative batch size
    'SaveInterval', 50, ...         % Frequent saves
    'MaxMemoryGB', 6, ...           % Conservative memory limit
    'MaxWorkers', 4)                % Conservative worker count
```

### Step 3: Monitor Progress
```matlab
% In another MATLAB session, monitor memory
memory_monitor('monitor', 60)

% Check checkpoints periodically
checkpoint_recovery()
```

### Step 4: Handle Interruptions
```matlab
% If MATLAB crashes or is interrupted:
% 1. Restart MATLAB
% 2. Navigate to output folder
% 3. List available checkpoints
checkpoint_recovery()

% 4. Resume from latest checkpoint
checkpoint_recovery('resume', 'checkpoint_YYYYMMDD_HHMMSS.mat')
```

## Troubleshooting

### Common Issues

**1. Memory Errors**
```
Error: Out of memory
```
**Solution:**
- Reduce batch size
- Reduce number of workers
- Perform memory cleanup
- Close other applications

**2. Parallel Pool Failures**
```
Error: Failed to start parallel pool
```
**Solution:**
- System automatically falls back to sequential
- Check parallel computing toolbox license
- Reduce worker count

**3. Checkpoint Corruption**
```
Error: Invalid checkpoint file
```
**Solution:**
- Use backup checkpoint file
- Check disk space
- Verify file permissions

**4. Slow Performance**
```
Warning: Processing is very slow
```
**Solution:**
- Reduce batch size
- Switch to sequential processing
- Check system resources
- Monitor for memory leaks

### Performance Optimization

**For Maximum Speed:**
```matlab
robust_dataset_generator(config, ...
    'BatchSize', 200, ...           % Larger batches
    'SaveInterval', 100, ...        % Less frequent saves
    'MaxMemoryGB', 12, ...          % Higher memory limit
    'MaxWorkers', 8)                % More workers
```

**For Maximum Stability:**
```matlab
robust_dataset_generator(config, ...
    'BatchSize', 50, ...            % Smaller batches
    'SaveInterval', 25, ...         % More frequent saves
    'MaxMemoryGB', 4, ...           % Conservative memory limit
    'MaxWorkers', 2)                % Fewer workers
```

## Integration with Existing GUI

The robust dataset generator can be integrated into the existing Data_GUI by:

1. **Adding a "Robust Mode" option** in the execution mode dropdown
2. **Adding memory monitoring controls** to the GUI
3. **Adding checkpoint management buttons**
4. **Adding progress indicators** for batch processing

This provides a seamless experience while maintaining the safety features of the robust system.

## File Structure

```
Scripts/Simulation_Dataset_GUI/
├── robust_dataset_generator.m      # Main robust generator
├── memory_monitor.m               # Memory monitoring utility
├── checkpoint_recovery.m          # Checkpoint management
├── Data_GUI.m                     # Existing GUI (to be enhanced)
└── ROBUST_DATASET_GENERATION_README.md  # This file
```

## Conclusion

This robust dataset generation system provides:

✅ **Crash Prevention**: Memory monitoring and batch processing
✅ **Progress Protection**: Checkpoint-based saves
✅ **Automatic Recovery**: Resume from any interruption
✅ **Performance Optimization**: Adaptive batch sizing
✅ **Easy Integration**: Works with existing GUI

With these tools, you can confidently generate large datasets without fear of losing progress due to crashes or interruptions. 