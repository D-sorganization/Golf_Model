# Enhanced Work and Power Calculations

## Overview

This feature branch adds enhanced work and power calculation capabilities to the golf swing simulation data processing system. The key improvements include:

1. **Optional Work Calculations**: Work calculations can be enabled/disabled based on the data type
2. **Total Angular Impulse Calculations**: Comprehensive angular impulse calculations including applied torques and force moments
3. **GUI Controls**: User-friendly interface for controlling calculation options
4. **Enhanced Data Processing**: Improved integration with the existing data processing pipeline

## Key Features

### 1. Optional Work Calculations

- **Default Behavior**: Work calculations are disabled by default for random input data
- **When to Enable**: Enable work calculations for meaningful time series data (e.g., machine learning results)
- **When to Disable**: Disable for random input data where work values have little meaning
- **Power Always Calculated**: Power calculations are always performed regardless of work settings

### 2. Total Angular Impulse Calculations

The system now calculates total angular impulse including:

- **Applied Torques**: Actuator torques from joints (LS, RS, LE, RE)
- **Force Moments**: Moments of forces at joints
- **Configurable Components**: Users can choose which components to include

### 3. Enhanced GUI Controls

New controls in the Post-Processing tab:

- **Calculate Work Values**: Checkbox to enable/disable work calculations
- **Include Applied Torques**: Checkbox to include applied torques in angular impulse
- **Include Force Moments**: Checkbox to include force moments in angular impulse

## File Structure

### New Files

- `Scripts/Functions/calculateWorkPowerAndAngularImpulse3D.m` - Enhanced calculation function
- `Scripts/Simulation_Dataset_GUI/test_enhanced_calculations.m` - Test script
- `Scripts/Simulation_Dataset_GUI/README_Enhanced_Work_Calculations.md` - This documentation

### Modified Files

- `Scripts/Simulation_Dataset_GUI/Data_GUI_Enhanced.m` - Added GUI controls for calculation options
- `Scripts/Simulation_Dataset_GUI/PostProcessingModule.m` - Enhanced with new calculation function

## Usage

### For Random Input Data (Default)

```matlab
% Default settings - work disabled
options = struct();
options.calculate_work = false;  % Disable work for random inputs
options.include_applied_torques = true;
options.include_force_moments = true;

% Process data
[ZTCFQ_enhanced, DELTAQ_enhanced] = calculateWorkPowerAndAngularImpulse3D(ZTCFQ, DELTAQ, options);
```

### For Machine Learning Results (Meaningful Time Series)

```matlab
% Enable work calculations for meaningful data
options = struct();
options.calculate_work = true;   % Enable work for meaningful time series
options.include_applied_torques = true;
options.include_force_moments = true;

% Process data
[ZTCFQ_enhanced, DELTAQ_enhanced] = calculateWorkPowerAndAngularImpulse3D(ZTCFQ, DELTAQ, options);
```

### GUI Usage

1. Open the Enhanced Golf Swing Data Generator
2. Navigate to the "Post-Processing" tab
3. Configure calculation options:
   - **Calculate Work Values**: Check for meaningful time series, uncheck for random inputs
   - **Include Applied Torques**: Check to include actuator torques in angular impulse
   - **Include Force Moments**: Check to include force moments in angular impulse
4. Select files and start processing

## Data Structure

The enhanced calculations work with the following data structure (based on `trial_001_20250802_204903.csv`):

### Required Columns for Power Calculations

- `CalculatedSignalsLogs_TotalHandForceGlobal_1/2/3` - Total hand forces
- `CalculatedSignalsLogs_LHonClubForceGlobal_1/2/3` - Left hand forces
- `CalculatedSignalsLogs_RHonClubForceGlobal_1/2/3` - Right hand forces
- `MidpointCalcsLogs_MPGlobalVelocity_1/2/3` - Midpoint velocities
- `LHCalcsLogs_LHGlobalVelocity_1/2/3` - Left hand velocities
- `RHCalcsLogs_RHGlobalVelocity_1/2/3` - Right hand velocities
- `LWLogs_LHGlobalAngularVelocity_1/2/3` - Left wrist angular velocities
- `RWLogs_RHGlobalAngularVelocity_1/2/3` - Right wrist angular velocities
- `CalculatedSignalsLogs_TotalHandTorqueGlobal_1/2/3` - Total hand torques

### Required Columns for Angular Impulse

- `LSLogs_ActuatorTorqueX/Y/Z` - Left shoulder actuator torques
- `RSLogs_ActuatorTorqueX/Y/Z` - Right shoulder actuator torques
- `LELogs_ActuatorTorque` - Left elbow actuator torque
- `RELogs_ActuatorTorque` - Right elbow actuator torque
- `LSLogs_TorqueLocal_1/2/3` - Left shoulder force moments
- `RSLogs_TorqueLocal_1/2/3` - Right shoulder force moments
- `LELogs_LArmonLForearmTGlobal_1/2/3` - Left elbow force moments
- `RELogs_RArmonLForearmTGlobal_1/2/3` - Right elbow force moments

## Output Columns

### Power Calculations (Always Generated)

- `LH_Linear_Power` - Left hand linear power
- `RH_Linear_Power` - Right hand linear power
- `Total_Linear_Power` - Total linear power
- `LH_Angular_Power` - Left hand angular power
- `RH_Angular_Power` - Right hand angular power
- `Total_Angular_Power` - Total angular power

### Work Calculations (Optional)

- `LH_Linear_Work` - Left hand linear work
- `RH_Linear_Work` - Right hand linear work
- `Total_Linear_Work` - Total linear work
- `LH_Angular_Work` - Left hand angular work
- `RH_Angular_Work` - Right hand angular work
- `Total_Angular_Work` - Total angular work

### Angular Impulse Calculations (Always Generated)

- `Total_Angular_Impulse_X` - Total angular impulse X component
- `Total_Angular_Impulse_Y` - Total angular impulse Y component
- `Total_Angular_Impulse_Z` - Total angular impulse Z component

## Testing

Run the test script to verify functionality:

```matlab
cd Scripts/Simulation_Dataset_GUI
test_enhanced_calculations
```

The test script will:
1. Test power calculations with work disabled
2. Test power and work calculations with work enabled
3. Test angular impulse calculations with different options
4. Test integration with the PostProcessingModule

## Branch Information

- **Branch Name**: `feature/optional-work-calculations`
- **Base Branch**: `main`
- **Status**: Ready for testing

## Notes

- The system maintains backward compatibility with existing data processing workflows
- Work calculations are disabled by default to avoid meaningless results with random input data
- Power calculations are always performed as they remain meaningful regardless of input type
- Angular impulse calculations provide comprehensive analysis of rotational dynamics
- All calculation options are stored in the output data for reference and reproducibility
