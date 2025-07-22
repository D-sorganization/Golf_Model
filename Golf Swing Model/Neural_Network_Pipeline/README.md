# Golf Swing Neural Network Pipeline

This folder contains the complete machine learning pipeline for training a neural network to control the golf swing model using inverse dynamics.

## Folder Structure

```
Neural_Network_Pipeline/
├── README.md                    # This documentation file
├── runCompletePipeline.m        # Master script to run the entire pipeline
├── Scripts/                     # Individual pipeline scripts
│   ├── extractSimKinematics.m   # Extract q, qdot, qdotdot from simulation outputs
│   ├── generateDataset.m        # Generate training dataset with random polynomial inputs
│   ├── trainInverseDynamicsModel.m  # Train neural network for inverse dynamics
│   ├── controlWithNeuralNetwork.m   # Demonstrate control with desired kinematics
│   ├── identifyLoggedSignals.m  # Analyze currently logged signals in Simulink model
│   ├── enhancedSignalAnalysis.m # Enhanced analysis with ML-specific requirements
│   ├── extractSimscapeData.m    # Extract data from Simscape Results Explorer
│   ├── generateSimInputs.m      # Generate Simulink simulation inputs from coefficients
│   └── computeLoss.m           # Compute loss between predicted and target kinematics
├── Data/                        # Generated datasets and training data
├── Models/                      # Trained neural network models
└── Results/                     # Control demonstration results and plots
```

## Pipeline Overview

The neural network pipeline consists of three main phases:

### Phase 1: Dataset Generation
- **Script**: `Scripts/generateDataset.m`
- **Purpose**: Generate large dataset of golf swing simulations with random polynomial torque inputs
- **Input**: Random polynomial coefficients for 28 joints (7 coefficients each = 196 total)
- **Output**: Training data with features [q, qd, tau, coeffs] and targets [qdd]
- **Dependencies**: Simulink model `GolfSwing3D_Kinetic.slx`

### Phase 2: Neural Network Training
- **Script**: `Scripts/trainInverseDynamicsModel.m`
- **Purpose**: Train neural network to predict joint torques from desired kinematics
- **Input**: [q, qd, qdd] (84 features for 28 joints)
- **Output**: τ (28 joint torques)
- **Architecture**: Deep neural network with configurable hidden layers

### Phase 3: Control Demonstration
- **Script**: `Scripts/controlWithNeuralNetwork.m`
- **Purpose**: Demonstrate neural network control with desired kinematics
- **Input**: Desired trajectory [q_desired, qd_desired, qdd_desired]
- **Output**: Controlled simulation following desired trajectory

## Quick Start

### Step 0: Analyze Current Signal Logging
```matlab
% Navigate to the Neural_Network_Pipeline folder
cd Neural_Network_Pipeline

% Analyze what signals are currently logged
run('Scripts/enhancedSignalAnalysis.m')

% If you have Simscape data, extract it
run('Scripts/extractSimscapeData.m')
```

### Option 1: Run Complete Pipeline
```matlab
% Run the complete pipeline
runCompletePipeline
```

### Option 2: Run Individual Steps
```matlab
% Step 1: Generate dataset
run('Scripts/generateDataset.m')

% Step 2: Train neural network
run('Scripts/trainInverseDynamicsModel.m')

% Step 3: Demonstrate control
run('Scripts/controlWithNeuralNetwork.m')
```

## Configuration

### Dataset Generation Parameters
- `nSimulations`: Number of simulations to generate (default: 1000)
- `coeffBounds`: Bounds for random polynomial coefficients (default: 50)
- `batchSize`: Number of simulations per batch (default: 10)

### Neural Network Parameters
- `hiddenLayers`: Network architecture (default: [512, 256, 128, 64])
- `maxEpochs`: Training epochs (default: 100)
- `batchSize`: Training batch size (default: 128)
- `learningRate`: Learning rate (default: 0.001)

### Control Parameters
- `simDuration`: Simulation duration (default: 1.0 seconds)
- `useFeedback`: Enable feedback control (default: true)
- `feedbackGain`: Feedback gain for position correction (default: 0.1)

## Dependencies

### Required MATLAB Toolboxes
- Deep Learning Toolbox
- Simulink
- Parallel Computing Toolbox (recommended)

### Required Files
- `Model/GolfSwing3D_Kinetic.slx` - Main Simulink model
- `Machine Learning Polynomials/generateSimInputs.m` - Utility function

## Output Files

### Generated Data
- `Data/training_data.mat` - Training dataset
- `Data/golf_swing_dataset.mat` - Full dataset with metadata
- `Data/dataset_metadata.mat` - Dataset statistics and parameters

### Trained Models
- `Models/inverse_dynamics_model.mat` - Trained neural network
- `Models/predictions.mat` - Model predictions on test data

### Results
- `Results/neural_network_control_results.mat` - Control demonstration results
- Various plots and visualizations

## Signal Logging and Data Extraction

### Analyzing Current Signal Logging
The pipeline includes tools to analyze what signals are currently being logged in your Simulink model:

1. **`enhancedSignalAnalysis.m`** - Comprehensive analysis of logged signals
   - Identifies currently logged signals
   - Checks for required signals (q, qd, qdd, tau)
   - Provides recommendations for additional logging
   - Creates configuration scripts

2. **`extractSimscapeData.m`** - Extract data from Simscape Results Explorer
   - Accesses Simscape logging data
   - Converts to logsout format for neural network pipeline
   - Categorizes available signals
   - Tests compatibility with extraction functions

### Working with Simscape Results Explorer
1. **Enable Simscape Logging**: Set `SimscapeLogType` to `'all'` in model parameters
2. **Run Simulation**: Execute your model to generate Simscape data
3. **Access Data**: Use `extractSimscapeData.m` to extract and convert data
4. **Export to Workspace**: Right-click signals in Results Explorer → Export to Workspace

## Troubleshooting

### Common Issues

1. **Simulink Model Not Found**
   - Ensure `GolfSwing3D_Kinetic.slx` is in the `Model/` folder
   - Check that the model name matches in `generateSimInputs.m`

2. **Memory Issues**
   - Reduce `nSimulations` or `batchSize`
   - Use smaller neural network architecture
   - Enable parallel processing if available

3. **Training Convergence Issues**
   - Reduce learning rate
   - Increase number of epochs
   - Check data normalization

4. **Poor Control Performance**
   - Increase feedback gain
   - Retrain with more diverse dataset
   - Check desired trajectory feasibility

### Performance Tips

1. **Use GPU**: Set `'ExecutionEnvironment', 'gpu'` in training options
2. **Parallel Processing**: Enable parallel simulation with `parsim`
3. **Data Preprocessing**: Normalize inputs and outputs for better training
4. **Regularization**: Use dropout and batch normalization to prevent overfitting

## Customization

### Adding New Joints
1. Update `nJoints` in all scripts
2. Modify `getJointNames()` in `generateSimInputs.m`
3. Update neural network input/output dimensions

### Using Motion Capture Data
1. Replace `generateDesiredGolfSwing()` in `controlWithNeuralNetwork.m`
2. Load motion capture data and interpolate to desired time steps
3. Ensure data format matches expected [q, qd, qdd] structure

### Custom Loss Functions
1. Modify `computeLoss.m` for different loss metrics
2. Add regularization terms in `trainInverseDynamicsModel.m`
3. Implement custom evaluation metrics

## Contact

For questions or issues with the neural network pipeline, refer to the main project documentation or contact the development team. 