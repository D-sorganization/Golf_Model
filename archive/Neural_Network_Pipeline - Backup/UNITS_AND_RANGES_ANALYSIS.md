# Units and Ranges Analysis for Golf Swing Model

## Summary

**Simscape outputs joint angles in RADIANS**, not degrees. This is the standard for Simscape multibody joints. The test dataset generates data in radians and converts to **degrees for neural network training**.

## Key Findings

### 1. Simscape Units
- **Joint Positions**: Radians (rad) - direct from Simscape
- **Joint Velocities**: Radians/second (rad/s) - direct from Simscape  
- **Joint Accelerations**: Radians/second² (rad/s²) - direct from Simscape
- **Joint Torques**: Newton-meters (Nm) - direct from Simulink
- **Translations**: Meters (m) - direct from Simulink

### 2. Expected Ranges for Golf Swing Motions

| Joint Motion | Min (deg) | Max (deg) | Min (rad) | Max (rad) |
|--------------|-----------|-----------|-----------|-----------|
| Hip Rotation (X) | -90 | 90 | -1.57 | 1.57 |
| Hip Rotation (Y) | -45 | 45 | -0.79 | 0.79 |
| Hip Rotation (Z) | -120 | 120 | -2.09 | 2.09 |
| Torso Rotation | -180 | 180 | -3.14 | 3.14 |
| Spine Tilt (X) | -30 | 30 | -0.52 | 0.52 |
| Spine Tilt (Y) | -20 | 20 | -0.35 | 0.35 |
| Shoulder Rotation (X) | -90 | 90 | -1.57 | 1.57 |
| Shoulder Rotation (Y) | -120 | 120 | -2.09 | 2.09 |
| Shoulder Rotation (Z) | -60 | 60 | -1.05 | 1.05 |
| Elbow Flexion | 0 | 150 | 0 | 2.62 |
| Wrist Motion (X) | -60 | 60 | -1.05 | 1.05 |
| Wrist Motion (Y) | -45 | 45 | -0.79 | 0.79 |

### 3. Conversion Factors
- **Radians to Degrees**: `degrees = radians * 180/pi`
- **Degrees to Radians**: `radians = degrees * pi/180`

## Evidence from Codebase

### Existing Conversion Patterns Found
The codebase contains numerous examples of radian-to-degree conversions:

```matlab
% Examples found in existing scripts:
hipPosition = interp1(baseDataTable.Time, baseDataTable.HipPositionZ, simTime, 'linear', 'extrap') * 180/pi;
torsoPosition = interp1(baseDataTable.Time, baseDataTable.TorsoPosition, simTime, 'linear', 'extrap') * 180/pi;
```

### Model Input Files
Analysis of existing `3DModelInputs.mat` files shows position values in the range of ±π radians, confirming Simscape outputs radians.

## Corrected Test Dataset

The `testDatasetGeneration.m` script has been updated to:

1. **Generate data in radians** with realistic golf swing ranges
2. **Convert to degrees** for neural network training
3. **Document units clearly** (degrees for training, radians for generation)
4. **Provide training data in degrees** as requested

### Updated Joint Ranges in Test Data
```matlab
joint_ranges = [
    % Hip joints (3 DOF)
    0.5, 0.3, 1.0;    % Hip Rx, Ry, Rz (±~30°, ±~17°, ±~57°)
    % Torso joint (1 DOF)
    1.5;               % Torso Rz (±~86°)
    % Spine joints (2 DOF)
    0.3, 0.2;         % Spine Rx, Ry (±~17°, ±~11°)
    % ... and so on for all 28 joints
];
```

## Verification Scripts

Two scripts have been created to verify units and ranges:

1. **`verifyUnitsAndRanges.m`** - Runs a test simulation and analyzes actual model output
2. **`analyzeUnitsAndRanges.m`** - Comprehensive analysis of existing data files and code patterns

## Recommendations

### For Neural Network Training
- **Use degree values** converted from Simscape radian output
- **Training data is provided in degrees** as requested
- **Document units clearly** in dataset metadata

### For Visualization and Analysis
- **Convert to degrees** for plotting and human interpretation
- **Use `rad2deg()` function** or `* 180/pi` for conversion
- **Label axes and legends** with appropriate units

### For Model Configuration
- **Input parameters** may expect degrees (check model documentation)
- **Convert as needed** when setting model parameters
- **Be consistent** with unit usage throughout the pipeline

## Common Pitfalls

1. **Assuming degrees**: Simscape always outputs radians
2. **Inconsistent conversions**: Mixing radian and degree values
3. **Small ranges**: If joint ranges are much smaller than expected, check:
   - Simulation duration (should be ~0.3-1.0 seconds)
   - Joint torque magnitudes (should be sufficient to drive motion)
   - Model configuration and initial conditions

## Conclusion

The golf swing model outputs joint angles in **radians**, and the test dataset generates data in radians then converts to **degrees for neural network training**. For realistic golf swing motions, expect joint ranges of approximately ±30-120 degrees for most joints, with some joints (like torso rotation) potentially reaching ±180 degrees.

The corrected test dataset now generates data with realistic ranges in degrees and proper unit documentation, making it suitable for neural network training with degree-based inputs as requested. 