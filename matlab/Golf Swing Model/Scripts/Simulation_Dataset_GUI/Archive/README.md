# Golf Swing Data Generation GUI

## Overview
The Data Generation GUI is a MATLAB-based graphical interface for generating comprehensive golf swing datasets for machine learning applications. It provides an intuitive way to configure simulation parameters, generate trial data, and export ML-ready datasets.

## Features
- **Flexible Trial Configuration**: Set number of trials, simulation time, and sampling rate
- **Multiple Data Sources**: Extract data from Model Workspace, Logsout, Signal Bus, and Simscape results
- **Polynomial Coefficient Editor**: Configure joint torque coefficients with multiple scenarios:
  - Random generation within specified ranges
  - Constant values for all joints
  - Import from existing files
- **Real-time Preview**: View coefficient distributions before generation
- **Batch Processing**: Generate multiple trials with parallel execution support
- **ML-Ready Output**: Automatically formats data with proper labels and metadata for machine learning

## Requirements
- MATLAB R2019b or later
- Simulink
- Simscape Multibody (for 3D model simulation)
- The GolfSwing3D_Kinetic Simulink model

## Installation
1. Clone or download the repository
2. Navigate to `Golf Swing Model/Scripts/Simulation_Dataset_GUI/`
3. Ensure all required files are present (run `test_gui_functions.m` to verify)

## Usage

### Launching the GUI
```matlab
% Option 1: Direct launch
Data_Generation_GUI()

% Option 2: Using the launcher script
launch_gui
```

### Basic Workflow
1. **Configure Trial Settings**
   - Set number of trials (simulations to run)
   - Set simulation time (duration of each swing)
   - Choose sampling rate (data points per second)
   - Select execution mode (Sequential or Parallel)

2. **Select Data Sources**
   - Check which data sources to extract from:
     - Model Workspace: Model parameters and variables
     - Logsout: Logged signals
     - Signal Bus: ToWorkspace block data
     - Simscape Results: Primary simulation data

3. **Configure Modeling Mode**
   - Select polynomial order for joint torques
   - Mode 3 (Hexic polynomial) is recommended

4. **Set Torque Coefficients**
   - Choose scenario:
     - Random: Generate coefficients within specified range
     - Constant: Use same value for all coefficients
     - From File: Import existing coefficient values
   - Use the Joint Editor to customize individual joints
   - Preview coefficient distributions

5. **Configure Output**
   - Select output folder for generated data
   - Choose file format (CSV recommended for ML)
   - Enable/disable data compilation

6. **Generate Data**
   - Click "Start Generation" to begin
   - Monitor progress in the status panel
   - Use "Stop Generation" if needed

### Output Files
The GUI generates:
- Individual trial CSV files: `ml_trial_XXX_timestamp.csv`
- Master dataset: `master_dataset_timestamp.csv`
- Dataset summary: `dataset_summary_timestamp.txt`
- MAT format files for faster MATLAB loading

### Data Format
Each row contains:
- **Metadata**: trial_id, time, simulation_id, generation_timestamp
- **Input Features**: All polynomial coefficients (input_JointName_Coefficient)
- **Output Variables**: Joint positions, velocities, accelerations, forces, torques

## Advanced Features

### Coefficient Table Operations
- **Search**: Filter coefficients by name
- **Apply to All**: Copy one trial's coefficients to all trials
- **Export/Import**: Save/load coefficient configurations
- **Reset**: Regenerate coefficients based on current scenario

### Performance Options
- Access via `performance_options.m`
- Configure parallel workers
- Set memory limits
- Adjust logging verbosity

## Troubleshooting

### Common Issues

1. **"Simulink model not found"**
   - Ensure the GolfSwing3D_Kinetic model is in your MATLAB path
   - Use the model browser to locate and select the model

2. **"No data extracted from simulation"**
   - Verify at least one data source is selected
   - Check that the model runs without errors
   - Ensure signal logging is enabled in the model

3. **"Memory error during generation"**
   - Reduce number of trials per batch
   - Lower sampling rate
   - Use sequential mode instead of parallel

4. **"Invalid coefficient values"**
   - Ensure all table cells contain valid numbers
   - Check coefficient range is reasonable (typically -10 to 10)
   - Verify no NaN or Inf values

### Debug Mode
For detailed debugging:
```matlab
% Enable verbose logging
handles = guidata(gcf);
handles.debug_mode = true;
guidata(gcf, handles);
```

## File Structure
```
Simulation_Dataset_GUI/
├── Data_Generation_GUI.m          # Main GUI file
├── launch_gui.m                   # GUI launcher
├── runSingleTrial.m              # Single trial execution
├── extractCompleteTrialData.m    # Data extraction logic
├── generatePolynomialCoefficients.m # Coefficient generation
├── setPolynomialVariables.m      # Variable setting helper
├── GolfSwingDataGeneratorHelpers.m # Additional helpers
├── performance_options.m         # Performance configuration
├── test_gui_functions.m          # Function verification
└── README.md                     # This file
```

## Contributing
When modifying the GUI:
1. Test all callback functions
2. Verify data extraction with sample runs
3. Update this README if adding features
4. Run `test_gui_functions.m` to ensure integrity

## Support
For issues or questions:
1. Check TROUBLESHOOTING.md for detailed solutions
2. Review GUI_IMPROVEMENTS_SUMMARY.md for recent changes
3. Ensure all dependencies are properly installed
