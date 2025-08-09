# Golf Swing Neural Network Pipeline

This pipeline generates a comprehensive dataset of golf swing simulations with randomized inputs and trains a neural network to map from desired kinematics (joint positions, velocities, accelerations) to required joint torques. The polynomial inputs serve as a data generation tool to create diverse torque profiles.

## Overview

The pipeline consists of two main phases:

1. **Dataset Generation**: Creates 1000+ simulations with randomized polynomial inputs and starting positions
2. **Neural Network Training**: Trains a network to predict joint torques from kinematics features (positions, velocities, accelerations)

## Files Structure

```
Neural_Network_Pipeline/
├── Scripts/
│   ├── generatePolynomialInputs.m          # Generate random polynomial coefficients
│   ├── generateRandomStartingPositions.m   # Generate random starting positions
│   ├── updateModelParameters.m             # Update Simulink model parameters
│   ├── runSimulation.m                     # Run single simulation with error handling
│   ├── extractJointStatesFromSimscape.m   # Extract joint states and beam data
│   ├── generateCompleteDataset.m           # Main dataset generation script
│   ├── trainKinematicsToTorqueMap.m       # Neural network training script
│   └── simulationTimeEstimator.m           # Estimate simulation time and requirements
├── README.md                               # This file
└── runCompletePipeline.m                   # Master script to run entire pipeline
```

## Prerequisites

### Software Requirements
- MATLAB R2020b or later
- Simulink
- Simscape Multibody
- Deep Learning Toolbox
- Statistics and Machine Learning Toolbox

### Model Requirements
- `GolfSwing3D_Kinetic.slx` model must be available and functional
- Model should have polynomial input blocks for joint torques
- Model should have Simscape logging enabled

## Phase 0: System Verification

### Step 1: Verify Simscape Signals and System Setup

Before running the full pipeline, verify that all required signals are available:

```matlab
% Run comprehensive signal verification
[verification_results, test_dataset] = verifySimscapeSignals('GolfSwing3D_Kinetic', true);
```

This script will:
- ✅ Check model loading and Simscape logging
- ✅ Run a test simulation
- ✅ Verify all required signal categories:
  - Joint positions, velocities, accelerations, torques
  - Beam modal coordinates, strain energy, displacement, forces/moments
  - Clubhead, hand, and body kinematics
- ✅ Check model workspace accessibility
- ✅ Generate a test dataset from single simulation
- ✅ Clean up workspace variables
- ✅ Provide detailed reporting

**Expected Output:**
- Verification results structure
- Test dataset file: `test_dataset_verification_YYYYMMDD_HHMMSS.mat`
- Comprehensive console output with signal counts

**Critical Checks:**
- Overall Status: PASSED
- All signal categories should have signals found
- Model workspace should be accessible
- Test dataset should be generated successfully

**Quick Test:**
```matlab
% Run quick verification test
testVerification
```

## Phase 1: Dataset Generation

Edit `generateCompleteDataset.m` to set your desired parameters:

```matlab
% Dataset size
config.num_simulations = 1000;        % Number of simulations
config.simulation_duration = 0.3;       % Seconds per simulation
config.sample_rate = 1000;            % Hz

% Polynomial input ranges (Nm) - Reduced for stability
config.hip_torque_range = [-30, 30];
config.spine_torque_range = [-20, 20];
config.shoulder_torque_range = [-15, 15];
config.elbow_torque_range = [-10, 10];
config.wrist_torque_range = [-8, 8];
config.translation_force_range = [-50, 50]; % N

% Starting position ranges
config.hip_position_range = [-0.1, 0.1];      % meters
config.hip_rotation_range = [-0.2, 0.2];      % radians
config.spine_tilt_range = [-0.3, 0.3];        % radians
config.torso_rotation_range = [-0.4, 0.4];    % radians
```

### Step 2: Run Dataset Generation

```matlab
% Run the complete dataset generation
generateCompleteDataset
```

**Expected Output:**
- `golf_swing_dataset_YYYYMMDD_HHMMSS.mat` - Full resolution dataset
- `golf_swing_dataset_archive_YYYYMMDD_HHMMSS.mat` - Downsampled archive
- `dataset_report_YYYYMMDD_HHMMSS.txt` - Comprehensive report
- `intermediate_dataset_*.mat` - Intermediate saves (every 50 simulations)

**Time Estimate:**
- Single core: 0.5-1 day
- Parallel (8 cores): 1-3 hours
- Optimized parallel: 0.5-1 hour

### Step 3: Monitor Progress

The script provides:
- Real-time progress bar
- Intermediate saves every 50 simulations
- Error logging and recovery
- Performance statistics

## Phase 2: Neural Network Training

### Step 1: Configure Neural Network

Edit `trainKinematicsToTorqueMap.m` to set training parameters:

```matlab
% Neural network configuration
config.hidden_layers = [256, 128, 64];    % Hidden layer sizes
config.learning_rate = 0.001;             % Learning rate
config.batch_size = 32;                   % Batch size
config.max_epochs = 100;                  % Maximum epochs
config.dropout_rate = 0.3;                % Dropout rate

% Kinematics features to use as input
config.kinematics_features = {
    'clubhead_speed_at_impact'
    'clubhead_position_at_impact'
    'maximum_clubhead_speed'
    'swing_duration'
    % ... add more features as needed
};
```

### Step 2: Run Neural Network Training

```matlab
% Train the neural network
trainKinematicsToTorqueMap
```

**Expected Output:**
- `kinematics_to_torque_model_YYYYMMDD_HHMMSS.mat` - Trained model
- `predictTorqueFromKinematics_YYYYMMDD_HHMMSS.m` - Prediction function
- `training_results_YYYYMMDD_HHMMSS.png` - Training plots

## Phase 3: Using the Trained Model

### Step 1: Load the Model

```matlab
% Load the trained model
model_data = load('kinematics_to_torque_model_YYYYMMDD_HHMMSS.mat');
model = model_data.model;
```

### Step 2: Make Predictions

```matlab
% Define desired kinematics features
desired_kinematics = [
    45.0,    % clubhead_speed_at_impact (m/s)
    0.1,     % clubhead_position_x (m)
    0.0,     % clubhead_position_y (m)
    0.0,     % clubhead_position_z (m)
    50.0,    % maximum_clubhead_speed (m/s)
    1.0      % swing_duration (s)
];

% Predict joint torques
joint_torques = predictTorqueFromKinematics(desired_kinematics);
```

### Step 3: Apply to Simulation

```matlab
% Update model with predicted coefficients
success = updateModelParameters(polynomial_coeffs, starting_positions, 'GolfSwing3D_Kinetic');

% Run simulation
[simOut, success, error_msg] = runSimulation('GolfSwing3D_Kinetic');
```

## Detailed Instructions

### Customizing Polynomial Inputs

The `generatePolynomialInputs.m` script generates 4th-order polynomials for each joint:

```matlab
% Example: Hip torque X polynomial
% τ(t) = a₀ + a₁t + a₂t² + a₃t³ + a₄t⁴
hip_torque_x = [a₀, a₁, a₂, a₃, a₄];
```

**Available Polynomials:**
- Hip torques: X, Y, Z (3 polynomials)
- Spine torques: X, Y (2 polynomials)
- Shoulder torques: Left/Right X, Y, Z (6 polynomials)
- Elbow torques: Left/Right Z (2 polynomials)
- Wrist torques: Left/Right X, Y (4 polynomials)
- Translation forces: X, Y, Z (3 polynomials)

### Customizing Starting Positions

The `generateRandomStartingPositions.m` script randomizes:

**Variable Positions (as requested):**
- Hip position and rotation (6 DOF)
- Spine tilt (2 DOF)
- Torso rotation (1 DOF)
- Shoulder positions and rotations (12 DOF)

**Fixed Positions (arms and hands):**
- Elbow rotations (2 DOF)
- Forearm rotations (2 DOF)
- Wrist rotations (4 DOF)

### Data Extraction

The `extractJointStatesFromSimscape.m` script extracts:

**Joint States:**
- `q`: Joint positions (28 signals)
- `qd`: Joint velocities (28 signals)
- `qdd`: Joint accelerations (24 signals)
- `tau`: Joint torques (19 signals)

**Beam States (Flexible Shaft):**
- Modal coordinates (10 signals)
- Strain energy (2 signals)
- Displacement (3 signals)
- Internal forces/moments (6 signals)
- Tip position/orientation (6 signals)

### Error Handling

The pipeline includes comprehensive error handling:

1. **Simulation Failures**: Logged and skipped, pipeline continues
2. **Model Compilation Errors**: Detailed error messages
3. **Data Extraction Failures**: Graceful degradation
4. **Memory Issues**: Intermediate saves prevent data loss

### Performance Optimization

**For Faster Execution:**

1. **Reduce Model Complexity:**
   ```matlab
   config.num_beam_modes = 6;  % Instead of 10
   ```

2. **Use Parallel Processing:**
   ```matlab
   % In generateCompleteDataset.m, add:
   parpool('local', 8);  % Use 8 cores
   parfor sim_idx = 1:config.num_simulations
       % ... simulation code
   end
   ```

3. **Optimize Solver Settings:**
   ```matlab
   config.solver_type = 'ode23t';
   config.relative_tolerance = 1e-3;  % Less strict
   config.absolute_tolerance = 1e-5;
   ```

4. **Reduce Dataset Size for Testing:**
   ```matlab
   config.num_simulations = 100;  % Start small
   ```

## Troubleshooting

### Common Issues

1. **Model Loading Errors:**
   - Ensure `GolfSwing3D_Kinetic.slx` is in the MATLAB path
   - Check for missing dependencies

2. **Simulation Failures:**
   - Check solver settings
   - Verify polynomial coefficient ranges
   - Ensure starting positions are physically realistic

3. **Memory Issues:**
   - Reduce `config.num_simulations`
   - Increase `config.save_interval`
   - Use archive dataset for training

4. **Neural Network Training Issues:**
   - Check data normalization
   - Adjust learning rate
   - Increase/decrease network size

### Debugging Tips

1. **Test with Small Dataset:**
   ```matlab
   config.num_simulations = 10;
   ```

2. **Check Individual Components:**
   ```matlab
   % Test polynomial generation
   poly_inputs = generatePolynomialInputs(config);
   
   % Test position generation
   starting_positions = generateRandomStartingPositions(config);
   
   % Test single simulation
   [simOut, success, error_msg] = runSimulation('GolfSwing3D_Kinetic');
   ```

3. **Monitor Memory Usage:**
   ```matlab
   memory  % Check available memory
   whos    % Check workspace variables
   ```

## Output Files

### Dataset Files
- **Full Dataset**: `golf_swing_dataset_*.mat` (~4-5 GB)
- **Archive Dataset**: `golf_swing_dataset_archive_*.mat` (~0.5 GB)
- **Report**: `dataset_report_*.txt`

### Model Files
- **Trained Model**: `kinematics_to_polynomial_model_*.mat`
- **Prediction Function**: `predictPolynomialFromKinematics_*.m`
- **Training Plots**: `training_results_*.png`

### Intermediate Files
- **Checkpoints**: `intermediate_dataset_*.mat` (every 50 simulations)

## Data Structure

### Dataset Structure
```matlab
dataset = struct();
dataset.config = config;                    % Configuration
dataset.metadata = metadata;                % Metadata
dataset.simulations = {sim1, sim2, ...};    % Cell array of simulation data
dataset.parameters = {param1, param2, ...}; % Cell array of parameters
dataset.success_flags = [true, false, ...]; % Success indicators
dataset.error_messages = {'', 'error', ...}; % Error messages
dataset.simulation_times = [1.2, 0.8, ...]; % Simulation times
```

### Simulation Data Structure
```matlab
sim_data = struct();
sim_data.time = [0, 0.001, 0.002, ...];     % Time vector
sim_data.q = [pos1; pos2; ...];             % Joint positions
sim_data.qd = [vel1; vel2; ...];            % Joint velocities
sim_data.qdd = [acc1; acc2; ...];           % Joint accelerations
sim_data.tau = [torque1; torque2; ...];     % Joint torques
sim_data.beam_states = [beam1; beam2; ...]; % Beam state data
```

## Advanced Usage

### Custom Kinematics Features

Add custom kinematics features in `trainKinematicsToPolynomialMap.m`:

```matlab
config.kinematics_features = {
    'clubhead_speed_at_impact'
    'clubhead_position_at_impact'
    'maximum_clubhead_speed'
    'swing_duration'
    'custom_feature_1'
    'custom_feature_2'
};
```

Then implement extraction in `extractKinematicsFeatures()`:

```matlab
case 'custom_feature_1'
    % Your custom feature calculation
    features = [features, calculated_value];
```

### Custom Neural Network Architecture

Modify the network architecture in `trainKinematicsToPolynomialMap.m`:

```matlab
% Custom architecture
layers = [
    featureInputLayer(size(X_train, 2))
    fullyConnectedLayer(512)
    reluLayer
    dropoutLayer(0.5)
    fullyConnectedLayer(256)
    reluLayer
    dropoutLayer(0.3)
    fullyConnectedLayer(size(Y_train, 2))
    regressionLayer
];
```

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review error messages in the console
3. Examine the dataset report for statistics
4. Test with smaller datasets first

## Version History

- **v1.0**: Initial release with complete pipeline
- Includes dataset generation, neural network training, and prediction functions
- Supports flexible beam data extraction
- Comprehensive error handling and progress monitoring 