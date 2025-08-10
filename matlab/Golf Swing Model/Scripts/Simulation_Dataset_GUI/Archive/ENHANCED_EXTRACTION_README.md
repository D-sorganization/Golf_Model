# Enhanced Signal Extraction System

## Overview

The enhanced signal extraction system provides a comprehensive solution for extracting all signals from Simulink simulation outputs, supporting multiple data sources with graceful handling of missing data.

## Key Features

### ✅ **Multiple Data Source Support**
- **CombinedSignalBus**: Primary signal bus with all logged signals
- **Logsout**: Traditional Simulink logging output
- **Simscape Results Explorer**: Simscape-specific data when available

### ✅ **Graceful Error Handling**
- Automatically detects available data sources
- Continues extraction even if some sources are missing
- Provides clear warnings and status messages

### ✅ **Configurable Extraction Options**
- Select which data sources to extract from
- Verbose/silent output modes
- Customizable extraction parameters

### ✅ **Comprehensive Signal Support**
- **1D Signals**: Scalar values (positions, velocities, etc.)
- **3D Vector Signals**: Position, velocity, force, torque vectors
- **3×3 Matrix Signals**: Rotation matrices and inertia tensors
- **Multi-dimensional Signals**: Any combination of the above

## Files

### Core Functions

1. **`extractAllSignalsFromBus.m`** - Main extraction function
   - Handles all data sources
   - Configurable options
   - Returns unified table and metadata

2. **`extractDataWithOptions.m`** - GUI interface
   - User-friendly selection interface
   - Automatic source detection
   - Results summary

### Test Files

3. **`test_enhanced_extraction.m`** - Comprehensive test suite
   - Tests all data source combinations
   - Validates extraction results
   - Performance benchmarking

## Usage Examples

### Basic Usage (CombinedSignalBus Only)
```matlab
% Run simulation
simOut = sim('YourModel');

% Extract all signals from CombinedSignalBus
[data, info] = extractAllSignalsFromBus(simOut);
```

### Advanced Usage (Multiple Sources)
```matlab
% Run simulation
simOut = sim('YourModel');

% Configure extraction options
options = struct();
options.extract_combined_bus = true;
options.extract_logsout = true;
options.extract_simscape = false;
options.verbose = true;

% Extract from multiple sources
[data, info] = extractAllSignalsFromBus(simOut, options);
```

### GUI Interface
```matlab
% Run simulation
simOut = sim('YourModel');

% Use GUI to select options
[data, info] = extractDataWithOptions(simOut);
```

## Data Source Details

### CombinedSignalBus
- **Format**: Structured signal bus
- **Content**: All logged signals from the model
- **Availability**: Always present when logging is enabled
- **Signal Types**: 1D, 3D vectors, 3×3 matrices

### Logsout
- **Format**: Simulink.SimulationData.Dataset
- **Content**: Traditional Simulink logged signals
- **Availability**: When 'SaveOutput' is set to 'on'
- **Signal Types**: 1D, 3D vectors, 3×3 matrices

### Simscape Results Explorer
- **Format**: Simulink.sdi.Signal objects
- **Content**: Simscape-specific simulation data
- **Availability**: When Simscape logging is enabled
- **Signal Types**: 1D, 3D vectors, 3×3 matrices

## Signal Type Handling

### 1D Signals (Scalar Values)
- Angular positions, velocities, accelerations
- Club head speed, angles of attack
- Individual joint torques and forces
- Calculated power and work values

### 3D Vector Signals
- Position vectors (X, Y, Z components)
- Velocity vectors (X, Y, Z components)
- Force vectors (X, Y, Z components)
- Torque vectors (X, Y, Z components)

### 3×3 Matrix Signals
- **Rotation Matrices**: Object orientation over time
- **Inertia Tensors**: Object inertia properties over time
- **Extraction**: Each matrix element becomes a separate time series

## Output Format

### Signal Table
- **Time Column**: Simulation time vector
- **Signal Columns**: All extracted signals as individual columns
- **Naming Convention**:
  - 1D signals: `SignalName`
  - 3D vectors: `SignalName_1`, `SignalName_2`, `SignalName_3`
  - 3×3 matrices: `SignalName_1_1`, `SignalName_1_2`, ..., `SignalName_3_3`

### Signal Info Structure
```matlab
signal_info = struct(
    'total_signals', 953,           % Total number of signals
    'time_points', 352,             % Number of time points
    'signal_names', {...},          % Names of all signals
    'source_info', struct(          % Information about each source
        'combined_bus', struct('extracted', true, 'signals', 408),
        'logsout', struct('extracted', false, 'signals', 0),
        'simscape', struct('extracted', false, 'signals', 0)
    ),
    'extraction_time', datetime     % When extraction was performed
);
```

## Integration with Existing GUI

The enhanced extraction system can be easily integrated into the existing `Data_GUI.m` system:

1. **Add Extraction Options Panel**: Include checkboxes for data source selection
2. **Modify Extraction Call**: Replace existing extraction calls with `extractAllSignalsFromBus`
3. **Update Results Display**: Show extraction summary and signal counts
4. **Error Handling**: Use graceful error handling for missing sources

## Performance Considerations

### Memory Usage
- Large simulations may require significant memory
- Consider extracting only needed sources
- Use silent mode for batch processing

### Processing Time
- 3×3 matrix extraction is computationally intensive
- Verbose output adds overhead
- Consider disabling verbose mode for large datasets

## Error Handling

### Missing Data Sources
- Function continues with available sources
- Clear warnings for missing sources
- Graceful degradation of functionality

### Data Validation
- Checks for NaN and Inf values
- Validates signal dimensions
- Ensures consistent time vectors

### Table Creation
- Multiple fallback methods for table creation
- Detailed error reporting
- Robust handling of edge cases

## Testing

### Test Suite Coverage
- All data source combinations
- Missing source scenarios
- Large dataset performance
- Error condition handling

### Validation
- Signal count verification
- Data integrity checks
- Time vector consistency
- Matrix element extraction accuracy

## Future Enhancements

### Planned Features
- **Signal Filtering**: Extract only specific signal types
- **Time Range Selection**: Extract subset of time data
- **Parallel Processing**: Multi-threaded extraction for large datasets
- **Export Formats**: Direct export to CSV, Excel, or other formats

### Integration Opportunities
- **Neural Network Pipeline**: Direct integration with training data generation
- **Real-time Processing**: Live signal extraction during simulation
- **Batch Processing**: Multiple simulation extraction workflows

## Troubleshooting

### Common Issues

1. **No Signals Extracted**
   - Check if simulation logging is enabled
   - Verify data source availability
   - Review simulation output structure

2. **Memory Errors**
   - Reduce simulation time or logging frequency
   - Extract only needed sources
   - Use silent mode to reduce overhead

3. **Table Creation Failures**
   - Check for NaN/Inf values in signals
   - Verify signal dimensions are consistent
   - Review time vector length

### Debug Mode
Enable verbose output to see detailed extraction process:
```matlab
options.verbose = true;
[data, info] = extractAllSignalsFromBus(simOut, options);
```

## Support

For issues or questions:
1. Check the test suite for examples
2. Enable verbose output for debugging
3. Review error messages for specific issues
4. Verify simulation output structure

---

**Version**: 2.0
**Last Updated**: December 2024
**Compatibility**: MATLAB R2020b+, Simulink, Simscape