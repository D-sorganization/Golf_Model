# Performance Monitoring and Verbosity Control System

## Overview

This system provides comprehensive performance monitoring and intelligent output control for the golf swing dataset generation process. It helps identify bottlenecks, optimize performance, and manage console output based on your needs.

## Features

### 🎯 **Performance Monitoring**
- **Real-time tracking** of execution phases
- **Memory usage monitoring** with trend analysis
- **Trial and batch timing** measurements
- **Bottleneck identification** and recommendations
- **Performance reports** with detailed analysis

### 🔇 **Verbosity Control**
- **4 output levels**: Silent, Normal, Verbose, Debug
- **Intelligent message filtering** based on priority
- **Performance-optimized output** for large datasets
- **Easy switching** between modes

## Performance Monitoring

### Usage

```matlab
% Start monitoring
performance_monitor('start')

% Check current status
performance_monitor()

% Stop monitoring and get report
performance_monitor('stop')

% Analyze specific data
performance_monitor('analyze', data)

% Identify bottlenecks
performance_monitor('bottlenecks')
```

### What Gets Tracked

#### **Execution Phases**
- Initialization time
- Parallel pool setup
- Dataset generation
- Final compilation
- Memory usage per phase

#### **Trial Metrics**
- Individual trial execution time
- Simulation vs. processing time
- Success/failure rates
- Error patterns

#### **Batch Metrics**
- Batch processing time
- Trials per second throughput
- Memory usage per batch
- Efficiency consistency

#### **System Metrics**
- Memory usage trends
- Checkpoint save times
- I/O performance
- Parallel efficiency

### Performance Report Example

```
=== PERFORMANCE REPORT ===
Total execution time: 1247.32 seconds (20.79 minutes)
Memory change: -2048.1 MB

--- Phase Analysis ---
  Initialization: 2.45 seconds (0.2%)
  Parallel Pool Setup: 15.23 seconds (1.2%)
  Dataset Generation: 1220.15 seconds (97.8%)
  Final Compilation: 9.49 seconds (0.8%)

Slowest phase: Dataset Generation (1220.15 seconds)

--- Trial Analysis ---
Average trial time: 0.124 seconds
Average simulation time: 0.098 seconds
Average processing time: 0.026 seconds
Trial time std dev: 0.045 seconds
Slowest trial: 847 (0.312 seconds)

--- Batch Analysis ---
Average batch time: 12.45 seconds
Average throughput: 8.03 trials/second
Batch time std dev: 2.34 seconds
Slowest batch: 15 (18.67 seconds, 5.36 trials/sec)

--- Checkpoint Analysis ---
Average checkpoint time: 0.234 seconds
Total checkpoint overhead: 23.40 seconds
Checkpoint overhead: 1.9% of total time

--- Performance Recommendations ---
  • Phase "Dataset Generation" is taking 97.8% of total time - consider optimization
  • 12 trials are significantly slower than average - investigate outliers
  • Significant memory usage detected - consider reducing batch size
```

## Verbosity Control

### Output Levels

#### **SILENT** - Performance Mode
- **Shows**: Only critical errors
- **Use for**: Maximum performance, long-running datasets
- **Example output**:
  ```
  ❌ ERROR: Trial 847 failed: Out of memory
  ```

#### **NORMAL** - Standard Mode (Default)
- **Shows**: Errors, warnings, important info, progress
- **Use for**: Regular dataset generation
- **Example output**:
  ```
  ℹ️  INFO: Starting new dataset generation
  ℹ️  INFO: Using batch size: 100 trials
  ⚠️  WARNING: Trial 847 failed
  🔄 Overall progress: 5000/10000 (50.0%)
  ℹ️  INFO: Batch 50: 95/100 successful (95.0%) in 12.3 seconds
  ```

#### **VERBOSE** - Detailed Mode
- **Shows**: Everything except debug messages
- **Use for**: Detailed progress monitoring
- **Example output**:
  ```
  ℹ️  INFO: Starting new dataset generation
  ℹ️  INFO: Using batch size: 100 trials
  ⚡ Memory usage: 2048.1 MB (change: -50.2 MB)
  🔄 Processing trial 847: 47/100 (47.0%)
  ℹ️  INFO: Trial 847 completed successfully in 0.124 seconds
  ⚡ Trial completed in 0.124 seconds
  ℹ️  INFO: Batch 50 completed: 95 successful, 5 failed (95.0% success rate) in 12.34 seconds
  ℹ️  INFO: Checkpoint saved: 2.1 MB in 0.234 seconds
  ```

#### **DEBUG** - Maximum Detail
- **Shows**: Everything including debug messages
- **Use for**: Troubleshooting and development
- **Example output**:
  ```
  🐛 DEBUG: Setting coefficient HipA = 0.123
  🐛 DEBUG: Loading model on worker 1
  🐛 DEBUG: Simulation metadata check passed
  🐛 DEBUG: Extracting 47 signals from logsout
  🐛 DEBUG: Memory cleanup completed
  ```

### Usage

```matlab
% Set verbosity level
verbosity_control('silent')    % Performance mode
verbosity_control('normal')    % Standard mode
verbosity_control('verbose')   % Detailed mode
verbosity_control('debug')     % Debug mode

% Check current level
verbosity_control()

% Test all levels
verbosity_control('test')
```

## Integration with Robust Dataset Generator

### Enhanced Usage

```matlab
% Basic usage with performance monitoring
robust_dataset_generator(config, ...
    'Verbosity', 'normal', ...
    'PerformanceMonitoring', true);

% Performance-optimized for large datasets
robust_dataset_generator(config, ...
    'Verbosity', 'silent', ...
    'PerformanceMonitoring', true, ...
    'BatchSize', 100, ...
    'SaveInterval', 50);

% Debug mode for troubleshooting
robust_dataset_generator(config, ...
    'Verbosity', 'debug', ...
    'PerformanceMonitoring', true, ...
    'BatchSize', 10, ...
    'SaveInterval', 5);
```

### Performance Monitoring Integration

The robust dataset generator automatically:

1. **Starts monitoring** when `PerformanceMonitoring` is enabled
2. **Records phases** for initialization, parallel setup, generation, and compilation
3. **Tracks batch performance** including timing and throughput
4. **Monitors memory usage** and checkpoint overhead
5. **Generates comprehensive reports** at completion
6. **Identifies bottlenecks** and provides optimization recommendations

### Verbosity Integration

The system automatically:

1. **Filters all output** based on verbosity level
2. **Provides progress updates** appropriate to the level
3. **Logs performance metrics** when in verbose/debug mode
4. **Shows detailed error information** in debug mode
5. **Minimizes console clutter** in silent mode

## Best Practices

### For Large Datasets (10,000+ trials)

```matlab
% Use silent mode for maximum performance
verbosity_control('silent');

% Enable performance monitoring
performance_monitor('start');

% Run with conservative settings
robust_dataset_generator(config, ...
    'Verbosity', 'silent', ...
    'PerformanceMonitoring', true, ...
    'BatchSize', 100, ...
    'SaveInterval', 100);

% Check performance after completion
performance_monitor('bottlenecks');
```

### For Development and Testing

```matlab
% Use debug mode for maximum information
verbosity_control('debug');

% Enable detailed monitoring
performance_monitor('start');

% Run with small batches for testing
robust_dataset_generator(config, ...
    'Verbosity', 'debug', ...
    'PerformanceMonitoring', true, ...
    'BatchSize', 10, ...
    'SaveInterval', 5);
```

### For Regular Use

```matlab
% Use normal mode for balanced output
verbosity_control('normal');

% Enable performance monitoring
performance_monitor('start');

% Standard settings
robust_dataset_generator(config, ...
    'Verbosity', 'normal', ...
    'PerformanceMonitoring', true);
```

## Performance Optimization Tips

### Based on Performance Reports

1. **If simulation time is the bottleneck**:
   - Reduce model complexity
   - Optimize solver settings
   - Use faster simulation methods

2. **If processing time is the bottleneck**:
   - Optimize data extraction
   - Reduce output variables
   - Use more efficient data structures

3. **If memory usage is high**:
   - Reduce batch size
   - Increase checkpoint frequency
   - Clear variables more frequently

4. **If checkpoint overhead is high**:
   - Reduce checkpoint frequency
   - Use faster storage (SSD)
   - Compress checkpoint files

5. **If parallel efficiency is poor**:
   - Reduce number of workers
   - Optimize worker memory allocation
   - Check for resource contention

## Troubleshooting

### Common Issues

**Performance monitoring not starting**:
```matlab
% Check if monitoring is active
performance_monitor()

% Restart monitoring
performance_monitor('start')
```

**Verbosity not changing**:
```matlab
% Check current level
verbosity_control()

% Set level explicitly
verbosity_control('set', 'verbose')
```

**Too much output**:
```matlab
% Switch to silent mode
verbosity_control('silent')
```

**Not enough information**:
```matlab
% Switch to debug mode
verbosity_control('debug')
```

## File Structure

```
Scripts/Simulation_Dataset_GUI/
├── performance_monitor.m           # Performance monitoring system
├── verbosity_control.m            # Verbosity control system
├── robust_dataset_generator.m     # Enhanced with monitoring
├── memory_monitor.m               # Memory monitoring utility
├── checkpoint_recovery.m          # Checkpoint management
└── PERFORMANCE_MONITORING_README.md  # This file
```

## Conclusion

This performance monitoring and verbosity control system provides:

✅ **Comprehensive Performance Tracking**: Detailed metrics for optimization
✅ **Intelligent Output Control**: Appropriate detail level for any situation
✅ **Bottleneck Identification**: Automatic detection of performance issues
✅ **Optimization Recommendations**: Actionable advice for improvement
✅ **Easy Integration**: Seamless integration with existing workflow

With these tools, you can optimize your dataset generation process, identify performance issues, and control output verbosity based on your specific needs. 