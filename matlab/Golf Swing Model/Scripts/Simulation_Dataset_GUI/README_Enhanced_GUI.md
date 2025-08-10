# Enhanced Golf Swing Data Generator GUI

## Overview

The Enhanced Golf Swing Data Generator GUI is a significant upgrade to the original GUI, featuring a modern tabbed interface, advanced post-processing capabilities, and robust data management features designed for large-scale data generation and machine learning applications.

## Key Features

### 🎯 Tabbed Interface
- **Data Generation Tab**: Original GUI functionality for generating golf swing simulation data
- **Post-Processing Tab**: Advanced data processing, export, and feature extraction capabilities
- **Persistent Title Bar**: Control buttons remain accessible regardless of active tab

### ⏸️ Pause/Resume Functionality
- **Play/Pause Button**: Toggle between start, pause, and resume states
- **Checkpoint System**: Save current state and resume later from exact point
- **Robust State Management**: Handles interruptions gracefully for long-running tests

### 📊 Advanced Post-Processing
- **Multiple Export Formats**: CSV, Parquet, MAT, and JSON support
- **Configurable Batch Sizes**: Process data in user-defined chunks (10-500 trials per file)
- **Memory-Efficient Processing**: Handles large datasets without memory issues
- **Flexible File Selection**: Process all files in folder or select specific files

### 🤖 Machine Learning Integration
- **Feature Extraction**: Automatic generation of ML-ready feature lists
- **Python-Compatible Output**: JSON and CSV formats optimized for Python workflows
- **Comprehensive Feature Categories**: Kinematics, dynamics, energy, and power metrics
- **Metadata Preservation**: Maintains data provenance and processing history

## Installation and Usage

### Quick Start
```matlab
% Launch the enhanced GUI
launch_enhanced_gui

% Or launch directly
Data_GUI_Enhanced
```

### Standalone Post-Processing
```matlab
% Initialize the post-processing module
PostProcessingModule

% Process a folder of data files
processDataFolder('path/to/data/folder', ...
    'output_folder', 'path/to/output', ...
    'format', 'CSV', ...
    'batch_size', 50, ...
    'generate_features', true)
```

## GUI Layout

### Title Bar Controls
- **▶ Start/⏸ Pause**: Toggle between start, pause, and resume
- **⏹ Stop**: Stop current operation
- **💾 Checkpoint**: Save current state for later resumption
- **Save Config**: Save current configuration
- **Load Config**: Load previously saved configuration

### Data Generation Tab
The original GUI functionality is preserved in the first tab:
- Configuration panel with all original settings
- Real-time preview and coefficient visualization
- Progress monitoring and status updates

### Post-Processing Tab
Three-column layout for efficient workflow:

#### Left Column - File Selection
- **Data Folder**: Browse and select input data folder
- **Selection Mode**: Choose between "All files" or "Select specific files"
- **File List**: Display and select files to process

#### Middle Column - Processing Options
- **Export Format**: CSV, Parquet, MAT, or JSON
- **Batch Size**: Number of trials per output file (10-500)
- **Processing Options**:
  - Generate feature list for ML
  - Compress output files
  - Include metadata
- **Output Folder**: Specify destination for processed data
- **Start Processing**: Begin batch processing

#### Right Column - Progress & Results
- **Progress Bar**: Visual progress indicator
- **Status Text**: Current operation status
- **Results Summary**: Processing completion summary
- **Processing Log**: Detailed log with timestamps

## Data Processing Features

### Supported Export Formats

#### CSV Format
- Flattened data structure for easy analysis
- Compatible with pandas, numpy, and other Python libraries
- Suitable for time series analysis

#### Parquet Format
- Columnar storage for efficient querying
- Excellent compression ratios
- Ideal for large datasets and machine learning

#### MAT Format
- Native MATLAB format
- Preserves all data types and structures
- Fastest loading in MATLAB environment

#### JSON Format
- Human-readable format
- Excellent for metadata and configuration
- Web-friendly for online applications

### Feature Extraction

The system automatically extracts comprehensive features for machine learning:

#### Kinematic Features
- **Range of Motion**: Maximum-minimum joint angles
- **Peak Angular Velocity**: Maximum angular velocity for each joint
- **Total Displacement**: Net movement of body segments
- **Peak Speed**: Maximum linear velocity

#### Dynamic Features
- **Peak Force**: Maximum force magnitudes
- **Mean Force**: Average force over time
- **Peak Torque**: Maximum torque values
- **Mean Torque**: Average torque over time

#### Energy Features
- **Total Work**: Mechanical work performed
- **Peak Power**: Maximum power output
- **Joint-Specific Work**: Work performed by each joint
- **Power Profiles**: Time-varying power curves

### Batch Processing

#### Memory Management
- **Configurable Batch Sizes**: Adjust based on available memory
- **Automatic Cleanup**: Clear memory after each batch
- **Progress Tracking**: Monitor memory usage during processing

#### Error Handling
- **Graceful Failures**: Continue processing if individual files fail
- **Detailed Logging**: Record all errors and warnings
- **Recovery Options**: Resume from last successful batch

## Configuration Management

### Save/Load Configuration
- **Complete State**: Save all GUI settings and preferences
- **Cross-Session**: Load configurations from previous sessions
- **Version Control**: Track configuration changes over time

### User Preferences
- **Persistent Settings**: Remember user preferences between sessions
- **Customizable Layout**: Adjust panel sizes and positions
- **Theme Support**: Professional color schemes

## Advanced Features

### Checkpoint System
```matlab
% Save checkpoint during processing
checkpoint = struct();
checkpoint.timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
checkpoint.gui_state = handles;
checkpoint.progress = getCurrentProgress(handles);
save('checkpoint.mat', 'checkpoint');

% Resume from checkpoint
load('checkpoint.mat');
handles = checkpoint.gui_state;
resumeFromPause(handles);
```

### Custom Feature Extraction
```matlab
% Add custom features to the extraction pipeline
function feature_list = addCustomFeature(feature_list, data, feature_name)
    % Calculate custom feature
    custom_value = calculateCustomMetric(data);

    % Add to feature list
    feature_list = addFeature(feature_list, feature_name, ...
                            custom_value, 'Custom metric', 'units', 'category');
end
```

### Integration with Python
```python
# Load feature list in Python
import json
import pandas as pd

# Load feature metadata
with open('feature_list.json', 'r') as f:
    feature_metadata = json.load(f)

# Load feature data
feature_data = pd.read_csv('feature_data.csv')

# Use in machine learning pipeline
from sklearn.ensemble import RandomForestRegressor
X = feature_data.drop('target', axis=1)
y = feature_data['target']
model = RandomForestRegressor()
model.fit(X, y)
```

## Performance Optimization

### Memory Management
- **Streaming Processing**: Process data in chunks to minimize memory usage
- **Garbage Collection**: Automatic cleanup of temporary variables
- **Parallel Processing**: Utilize multiple CPU cores when available

### Speed Optimization
- **Vectorized Operations**: Use MATLAB's optimized array operations
- **Pre-allocation**: Allocate arrays before loops for better performance
- **Efficient Data Structures**: Choose optimal data types and structures

## Troubleshooting

### Common Issues

#### GUI Not Launching
```matlab
% Check MATLAB version compatibility
if verLessThan('matlab', '9.0')
    error('MATLAB R2016a or later required');
end

% Verify file paths
if ~exist('Data_GUI_Enhanced.m', 'file')
    error('Enhanced GUI file not found');
end
```

#### Memory Issues
```matlab
% Reduce batch size for large datasets
processDataFolder('data_folder', 'batch_size', 25);

% Monitor memory usage
memory_info = memory;
fprintf('Memory usage: %.2f GB\n', memory_info.MemUsedMATLAB / 1e9);
```

#### Export Format Issues
```matlab
% Check format compatibility
supported_formats = {'CSV', 'Parquet', 'MAT', 'JSON'};
if ~ismember(format, supported_formats)
    error('Unsupported format: %s', format);
end
```

### Performance Tips

1. **Batch Size Selection**: Start with 50 trials per batch and adjust based on memory
2. **Export Format**: Use MAT for fastest processing, Parquet for large datasets
3. **Feature Extraction**: Disable if not needed to improve speed
4. **Parallel Processing**: Enable for multi-core systems

## Future Enhancements

### Planned Features
- **Real-time Visualization**: Live plotting during data generation
- **Advanced Analytics**: Statistical analysis and outlier detection
- **Cloud Integration**: Direct upload to cloud storage services
- **API Interface**: REST API for programmatic access
- **Plugin System**: Extensible architecture for custom features

### Community Contributions
- **Custom Export Formats**: Add support for additional file formats
- **Feature Extractors**: Implement domain-specific feature extraction
- **Visualization Tools**: Create custom plotting and analysis tools
- **Integration Modules**: Connect with external analysis platforms

## Support and Documentation

### Getting Help
- **Error Messages**: Check the processing log for detailed error information
- **Configuration Issues**: Verify all paths and settings are correct
- **Performance Problems**: Monitor memory usage and adjust batch sizes

### Contributing
- **Code Style**: Follow MATLAB coding conventions
- **Testing**: Test new features with various data types and sizes
- **Documentation**: Update this README for new features

## Version History

### v2.0 (Enhanced GUI)
- Tabbed interface implementation
- Pause/resume functionality
- Advanced post-processing capabilities
- Multiple export format support
- Feature extraction for machine learning
- Memory-efficient batch processing

### v1.0 (Original GUI)
- Basic data generation interface
- CSV and MAT export
- Simple progress monitoring
- Configuration management

---

*For technical support or feature requests, please refer to the project documentation or contact the development team.*
