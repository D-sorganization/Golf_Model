# MATLAB Crash Troubleshooting Guide

## Problem Description
MATLAB crashes during large simulation runs (e.g., 1000 trials) with the following error:
- **Exception Code**: `0xe0000008`
- **Module**: `libcef.dll` (Chromium Embedded Framework)
- **Process**: `matlabwindowhelper.exe`

## Root Cause Analysis
The crash is caused by memory exhaustion and GUI-related memory leaks in MATLAB's Chromium Embedded Framework component. This typically occurs when:

1. **Memory accumulation** over many simulation iterations
2. **GUI memory leaks** from MATLAB's display system
3. **Parallel processing overhead** creating memory pressure
4. **Large data extraction** without proper cleanup

## Solutions

### 1. Use Memory-Safe Simulation Script
Replace the original `runParallelSimulations.m` with the memory-safe version:

```matlab
% Use the new memory-safe script
runParallelSimulations_memorySafe
```

**Key improvements:**
- Batch processing with memory cleanup
- Limited parallel workers (max 4)
- Reduced data extraction scope
- Automatic garbage collection
- Memory monitoring

### 2. Memory Management Best Practices

#### Before Running Large Simulations:
```matlab
% Check current memory usage
memoryMonitor('check')

% Perform initial cleanup
memoryMonitor('cleanup')

% Start memory monitoring
memoryMonitor('monitor', 60)  % Check every 60 seconds
```

#### During Simulation:
- Use smaller batch sizes (25-50 trials)
- Monitor memory usage regularly
- Stop if memory usage exceeds 80%

#### After Simulation:
```matlab
% Stop monitoring
memoryMonitor('stop')

% Final cleanup
memoryMonitor('cleanup')
```

### 3. System-Level Optimizations

#### MATLAB Startup Options:
```bash
# Start MATLAB with reduced memory usage
matlab -softwareopengl -nodesktop -nosplash

# Or with specific memory limits
matlab -softwareopengl -nodesktop -nosplash -r "memory('max', 4096)"
```

#### Windows System Settings:
1. **Increase Virtual Memory**:
   - System Properties → Advanced → Performance Settings
   - Advanced → Virtual Memory → Change
   - Set to 1.5x physical RAM

2. **Disable Visual Effects**:
   - System Properties → Advanced → Performance Settings
   - Visual Effects → Adjust for best performance

3. **Close Unnecessary Applications**:
   - Close browsers, office applications
   - Disable antivirus real-time scanning during simulation

### 4. Simulation Configuration Recommendations

#### For 1000+ Trials:
```matlab
% Recommended settings
config.num_simulations = 1000;
config.batch_size = 25;        % Small batches
config.simulation_time = 0.3;  % Keep short
config.sample_rate = 100;      % Standard rate
```

#### For Very Large Simulations (5000+ trials):
```matlab
% Conservative settings
config.num_simulations = 5000;
config.batch_size = 10;        % Very small batches
config.simulation_time = 0.2;  % Shorter simulations
config.sample_rate = 50;       % Lower sample rate
```

### 5. Crash Recovery

#### Check Existing Data:
```matlab
% Check what trials were completed
crashRecovery('check', 'path/to/trial_data')

% Get detailed status
crashRecovery('status', 'path/to/trial_data')
```

#### Resume Interrupted Simulation:
```matlab
% Resume from where it left off
crashRecovery('resume', 'path/to/trial_data', 1000)
```

#### Clean Up Corrupted Files:
```matlab
% Remove incomplete files
crashRecovery('cleanup', 'path/to/trial_data')
```

### 6. Alternative Approaches

#### Sequential Processing:
If parallel processing causes issues, use sequential mode:
```matlab
% In the memory-safe script, set:
use_parallel = false;
```

#### Reduced Data Extraction:
Modify the data extraction functions to capture only essential data:
```matlab
% In extractTrialDataMemorySafe, comment out heavy extractions:
% trial_data = extractModelWorkspaceData(simOut, trial_data, target_time);
% trial_data = extractMatrixData(simOut, trial_data, target_time);
```

#### External Processing:
Save minimal data and process externally:
```matlab
% Save only essential data
save(filepath, 'trial_data', 'polynomial_coeffs', 'sim_idx');
```

### 7. Monitoring and Prevention

#### Memory Monitoring Script:
```matlab
% Continuous monitoring during simulation
memoryMonitor('monitor', 30);  % Check every 30 seconds

% Manual checks
memoryMonitor('check');

% Cleanup when needed
memoryMonitor('cleanup');
```

#### Progress Tracking:
```matlab
% Save progress periodically
progress_file = 'simulation_progress.mat';
save(progress_file, 'current_trial', 'successful_trials', 'config');
```

### 8. Emergency Procedures

#### If MATLAB Becomes Unresponsive:
1. **Wait 5-10 minutes** for automatic recovery
2. **Force close MATLAB** if necessary
3. **Restart MATLAB** with reduced memory settings
4. **Check for saved progress** using crash recovery tools

#### If System Becomes Unstable:
1. **Save current work** immediately
2. **Close MATLAB** and other applications
3. **Restart computer** if necessary
4. **Reduce batch size** for next run

### 9. Performance Optimization

#### Model Optimization:
- Reduce simulation time if possible
- Simplify model complexity
- Use lower sample rates
- Disable unnecessary logging

#### System Optimization:
- Close unnecessary applications
- Disable real-time antivirus
- Increase virtual memory
- Use SSD storage for trial data

### 10. Long-term Solutions

#### Hardware Upgrades:
- **Increase RAM** to 32GB or more
- **Use SSD** for faster I/O
- **Consider dedicated simulation machine**

#### Software Alternatives:
- **Use MATLAB Parallel Server** for distributed computing
- **Consider cloud computing** for large simulations
- **Implement external data processing** pipeline

## Quick Reference Commands

```matlab
% Memory management
memoryMonitor('check')           % Check memory
memoryMonitor('cleanup')         % Clean up memory
memoryMonitor('monitor', 60)     % Start monitoring
memoryMonitor('stop')            % Stop monitoring

% Crash recovery
crashRecovery('check', folder)   % Check existing trials
crashRecovery('status', folder)  % Detailed status
crashRecovery('cleanup', folder) % Clean corrupted files
crashRecovery('resume', folder, total_trials) % Resume simulation

% Safe simulation
runParallelSimulations_memorySafe % Use memory-safe script
```

## Contact and Support

If issues persist after trying these solutions:
1. **Check MATLAB version** and update if necessary
2. **Verify system requirements** are met
3. **Contact MathWorks support** for CEF-related issues
4. **Consider alternative approaches** for large-scale simulations

## Prevention Checklist

- [ ] Use memory-safe simulation script
- [ ] Set appropriate batch sizes (25-50 trials)
- [ ] Monitor memory usage during simulation
- [ ] Perform regular memory cleanup
- [ ] Save progress frequently
- [ ] Use crash recovery tools
- [ ] Optimize system settings
- [ ] Close unnecessary applications
- [ ] Have backup/recovery plan
