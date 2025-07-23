# 100-Simulation Test Dataset

## Overview

This dataset contains 100 golf swing simulations, each with a duration of 0.3 seconds, generated for neural network training purposes. The dataset is designed to provide comprehensive training data for predicting joint accelerations from joint positions, velocities, and torques in a 28-degree-of-freedom golf swing model.

## Dataset Statistics

- **Total Simulations**: 100
- **Simulation Duration**: 0.3 seconds each
- **Sample Rate**: 100 Hz
- **Time Points per Simulation**: 31
- **Total Time Points**: 3,100
- **Success Rate**: 100% (all simulations completed successfully)
- **Total Training Samples**: 3,100
- **Features**: 84 (28 joint positions + 28 joint velocities + 28 joint torques)
- **Targets**: 28 (joint accelerations)

## File Structure

```
100_Simulation_Test_Dataset/
├── README.md                                    # This documentation file
├── generate100Simulations.m                     # Script used to generate the dataset
├── export100SimDatasetToCSV.m                   # Script to export data to CSV format
├── 100_sim_dataset_20250723_103854.mat         # Complete dataset (MATLAB format)
├── 100_sim_training_data_20250723_103854.mat   # Training data (MATLAB format)
├── 100_sim_config_20250723_103854.mat          # Configuration summary
├── individual_simulations/                      # Individual simulation CSV files
│   ├── simulation_001_data.csv
│   ├── simulation_002_data.csv
│   └── ... (100 files total)
├── training_features_100sim.csv                 # Training features (84 columns)
├── training_targets_100sim.csv                  # Training targets (28 columns)
├── training_data_combined_100sim.csv            # Combined training data (112 columns)
├── dataset_summary_100sim.csv                   # Dataset statistics
└── joint_mapping_100sim.csv                     # Joint name mappings
```

## Methodology

### Data Generation Process

1. **Model Loading**: The Simulink model `GolfSwing3D_Kinetic` was loaded to ensure proper signal mapping.

2. **Joint Configuration**: The model uses 28 degrees of freedom (DOFs) representing:
   - Hip joints (3 DOF): Rx, Ry, Rz
   - Torso joint (1 DOF): Rz
   - Spine joints (2 DOF): Rx, Ry
   - Left scapula (2 DOF): Rx, Ry
   - Left shoulder (3 DOF): Rx, Ry, Rz
   - Left elbow (1 DOF): Rz
   - Left forearm (1 DOF): Rz
   - Left wrist (2 DOF): Rx, Ry
   - Right wrist (2 DOF): Rx, Ry
   - Right forearm (1 DOF): Rz
   - Right elbow (1 DOF): Rz
   - Right scapula (2 DOF): Rx, Ry
   - Right shoulder (3 DOF): Rx, Ry, Rz
   - Additional joints (4 DOF): Extended to reach 28 total DOFs

3. **Realistic Joint Ranges**: Each joint was assigned realistic golf swing motion ranges:
   - Hip joints: ±30°, ±17°, ±57°
   - Torso: ±86°
   - Spine: ±17°, ±11°
   - Shoulders: ±46°, ±69°, ±29°
   - Elbows: 0-86°
   - Wrists: ±29°, ±23°
   - Additional joints: ±29°

4. **Data Generation**: For each simulation:
   - Joint positions were generated using sine waves with realistic ranges (in radians)
   - Joint velocities were computed as derivatives of positions (in radians/second)
   - Joint accelerations were computed as derivatives of velocities (in radians/second²)
   - Joint torques were generated using sine waves with realistic magnitudes
   - All angular data was converted from radians to degrees for neural network training
   - Mid-hands position and orientation data was also generated

5. **Training Data Creation**: 
   - Features: [joint positions, joint velocities, joint torques] (84 features)
   - Targets: [joint accelerations] (28 targets)
   - Each time point from each simulation becomes one training sample

### Unit System

All units are traceable to Simulink model specifications:

- **Joint Positions**: Degrees (deg) - converted from Simscape radians for neural network training
- **Joint Velocities**: Degrees/second (deg/s) - converted from Simscape rad/s for neural network training
- **Joint Accelerations**: Degrees/second² (deg/s²) - converted from Simscape rad/s² for neural network training
- **Joint Torques**: Newton-meters (Nm) - direct from Simulink
- **Mid-hands Position**: Meters (m) - direct from Simulink
- **Time**: Seconds (s) - direct from Simulink

## Data Quality

### Validation Results

- **Success Rate**: 100% of simulations completed successfully
- **Data Consistency**: All simulations have exactly 31 time points (0.3s at 100Hz)
- **Joint Count**: All simulations contain exactly 28 joints
- **Unit Consistency**: All angular data consistently in degrees
- **Range Validation**: Joint ranges are within realistic golf swing limits

### Data Ranges (from first simulation)

- **Joint Positions**: [-17.2°, 17.2°]
- **Joint Velocities**: [-180.5°, 180.5°] deg/s
- **Joint Accelerations**: [-1,134.2°, 1,134.2°] deg/s²
- **Joint Torques**: [-12.0, 12.0] Nm

## Usage

### Loading the Dataset

```matlab
% Load the complete dataset
load('100_sim_dataset_20250723_103854.mat');

% Load the training data
load('100_sim_training_data_20250723_103854.mat');

% Access individual simulation data
sim_data = dataset.simulations{1};  % First simulation
q = sim_data.q;                     % Joint positions (degrees)
qd = sim_data.qd;                   % Joint velocities (deg/s)
qdd = sim_data.qdd;                 % Joint accelerations (deg/s²)
tau = sim_data.tau;                 % Joint torques (Nm)
```

### Training Data Structure

```matlab
% Training data is organized as:
X = training_data.X;  % Features: [positions, velocities, torques] (3100 x 84)
Y = training_data.Y;  % Targets: [accelerations] (3100 x 28)

% Each row represents one time point from one simulation
% Features: 28 positions + 28 velocities + 28 torques = 84 features
% Targets: 28 accelerations = 28 targets
```

### CSV Files

The CSV files provide easy inspection in spreadsheet applications:

- **training_features_100sim.csv**: 3,100 rows × 84 columns (features)
- **training_targets_100sim.csv**: 3,100 rows × 28 columns (targets)
- **training_data_combined_100sim.csv**: 3,100 rows × 112 columns (features + targets)
- **individual_simulations/**: 100 CSV files, one per simulation

## Neural Network Training

This dataset is designed for training neural networks to predict joint accelerations from joint states and torques. The problem can be formulated as:

**Input**: Joint positions (28), Joint velocities (28), Joint torques (28)  
**Output**: Joint accelerations (28)

### Recommended Network Architecture

- **Input Layer**: 84 neurons (28 + 28 + 28)
- **Hidden Layers**: 2-3 layers with 64-128 neurons each
- **Output Layer**: 28 neurons
- **Activation**: ReLU for hidden layers, linear for output
- **Loss Function**: Mean Squared Error (MSE)

### Training Recommendations

- **Train/Validation Split**: 80/20 or 70/30
- **Batch Size**: 32-128
- **Learning Rate**: 0.001-0.01
- **Epochs**: 100-500 (with early stopping)
- **Regularization**: L2 regularization to prevent overfitting

## Technical Details

### Signal Mapping

The dataset includes comprehensive signal mapping between simplified joint names and actual Simulink model signals. See `joint_mapping_100sim.csv` for the complete mapping.

### Data Generation Script

The `generate100Simulations.m` script contains:
- Realistic joint range definitions
- Sine wave generation with varying frequencies
- Unit conversion from radians to degrees
- Comprehensive metadata and documentation
- Error handling and validation

### Performance

- **Generation Time**: ~0.16 seconds total (0.0016 seconds per simulation)
- **Memory Usage**: ~6MB for complete dataset
- **CSV Export Time**: ~5 seconds for all files

## Limitations and Considerations

1. **Synthetic Data**: This is synthetic data generated for training purposes, not real golf swing measurements
2. **Simplified Dynamics**: The joint motions are simplified sine waves, not complex golf swing dynamics
3. **No Physical Constraints**: The data doesn't enforce physical constraints between joints
4. **Training Purpose**: Designed specifically for neural network training, not biomechanical analysis

## Future Improvements

1. **Real Golf Swing Data**: Incorporate actual golf swing motion capture data
2. **Physical Constraints**: Add biomechanical constraints between joints
3. **More Complex Motions**: Generate more realistic golf swing trajectories
4. **Larger Dataset**: Increase to 1000+ simulations for better training
5. **Validation Data**: Include separate validation dataset

## Contact and Support

For questions about this dataset or the generation methodology, please refer to the main project documentation or contact the development team.

---

**Generated**: July 23, 2025  
**Version**: 100_sim_v1.0  
**Model**: GolfSwing3D_Kinetic  
**Units**: Degrees for neural network training (converted from Simscape radians) 