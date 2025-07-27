# Data Generation GUI Improvements Summary

## Overview
This document summarizes the improvements made to the `Data_Generation_GUI.m` for enhanced trial setup and machine learning dataset generation.

## Key Improvements

### 1. **Removed Mode 3 Hexagonal Polynomial Comment**
- Removed the redundant "Mode 3: Hexagonal Polynomial" text from the Modeling Configuration panel
- Added polynomial equation display in the Individual Joint Editor panel
- Equation shown: `τ(t) = A + Bt + Ct² + Dt³ + Et⁴ + Ft⁵ + Gt⁶`

### 2. **Fixed "Apply Row" Error**
- Fixed the "unrecognized field name coefficients_table" error
- Enhanced error handling to properly retrieve handles structure
- Added validation to check if coefficients_table exists before accessing

### 3. **Added Search Functionality**
- New search bar above the coefficients preview table
- Real-time search through coefficient column names
- Automatic scrolling to matching columns
- Clear button to reset search
- Status updates showing number of matches found

### 4. **Enhanced Data Compilation for Machine Learning**

#### CSV File Structure
Each trial now generates ML-ready CSV files with:
- **Metadata columns**: trial_id, timestamp, scenario parameters
- **Input features**: All polynomial coefficients labeled as `input_JointName_Coeff`
- **Output variables**: Simulation results from signal logging
- **Consistent labeling**: Ensures data integrity across all trials

#### Master Dataset Compilation
After all trials complete:
- Automatically compiles all individual trials into `master_dataset_[timestamp].csv`
- Creates MAT format version for faster MATLAB loading
- Generates `dataset_summary_[timestamp].txt` with statistics

#### Metadata Tracking
Each trial saves a `.mat` file containing:
- Trial configuration
- Coefficient values
- Joint mappings
- Generation timestamp

### 5. **Improved Table Updates**
- Preview table should now update when number of trials changes
- Better synchronization between UI elements

### 6. **Enhanced UI Layout**
- Adjusted button spacing to accommodate search functionality
- Cleaner visual hierarchy
- Better use of screen space

## Data Organization for ML

### Column Structure
```
[Metadata] | [Input Features] | [Output Variables]
```

### Metadata Columns
- `trial_id`: Unique identifier for each trial
- `time`: Timestamp within simulation
- `simulation_id`: Simulation instance number
- `torque_scenario`: Type of torque generation used
- `coeff_range`: Range for random coefficients
- `constant_value`: Value for constant torque scenario
- `generation_timestamp`: When data was generated

### Input Features
- Named as `input_<JointName>_<Coefficient>`
- Example: `input_BaseT_A`, `input_HipX_G`
- Consistent across all time points in a trial
- Ready for use as ML model inputs

### Output Variables
- All logged signals from the simulation
- Maintains original signal names
- Time-synchronized with input features

## Usage Tips

1. **For ML Pipeline Integration**:
   - Use the master dataset CSV for training
   - Input features are clearly labeled with `input_` prefix
   - Metadata columns help with data filtering and validation

2. **Search Functionality**:
   - Search is case-insensitive
   - Searches partial matches (e.g., "Hip" finds all hip-related columns)
   - Table automatically scrolls to first match

3. **Data Quality**:
   - Check `dataset_summary_[timestamp].txt` for overview
   - Verify all trials have consistent column structure
   - Use metadata to filter trials by scenario type

## File Outputs

### Per Trial
- `ml_trial_XXX_YYYYMMDD_HHMMSS.csv`: Enhanced trial data
- `ml_trial_XXX_metadata.mat`: Trial configuration

### After Generation
- `master_dataset_YYYYMMDD_HHMMSS.csv`: Combined dataset
- `master_dataset_YYYYMMDD_HHMMSS.mat`: MATLAB format
- `dataset_summary_YYYYMMDD_HHMMSS.txt`: Statistics and overview

## Testing
Run `test_gui_improvements.m` to verify all features are working correctly.