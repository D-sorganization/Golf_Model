# Golf Swing Dataset - Python Export

This directory contains golf swing simulation data exported from MATLAB in Python-friendly formats.

## Files

### Main Dataset
- **`simple_dataset_10_sims_20250722_211348_dataset_20250722_212615.csv`** (6.1 MB)
  - 47,220 data points from 15 simulations
  - Each row contains: time, simulation_id, polynomial coefficients, starting positions
  - Perfect for machine learning training

### Simulation Summary
- **`simple_dataset_10_sims_20250722_211348_summary_20250722_212615.csv`**
  - Summary statistics for each simulation
  - Number of timepoints, time range, success status

### Python Helper
- **`load_simple_dataset_20250722_212615.py`**
  - Ready-to-use Python script to load and analyze the data
  - Includes plotting and analysis functions

## Quick Start

### 1. Load the Data
```python
import pandas as pd

# Load main dataset
dataset = pd.read_csv('simple_dataset_10_sims_20250722_211348_dataset_20250722_212615.csv')

# Load summary
summary = pd.read_csv('simple_dataset_10_sims_20250722_211348_summary_20250722_212615.csv')

print(f"Dataset shape: {dataset.shape}")
print(f"Simulations: {dataset.simulation_id.nunique()}")
```

### 2. Use the Helper Script
```bash
python load_simple_dataset_20250722_212615.py
```

### 3. Open in Excel
- Double-click any CSV file to open in Excel
- Data is tabular and ready for analysis

## Data Structure

### Main Dataset Columns
- **`simulation_id`**: Which simulation (1-15)
- **`time`**: Time point (0.000 to 0.300 seconds)
- **`hip_torque_a0`** to **`hip_torque_a3`**: Hip torque polynomial coefficients
- **`spine_torque_a0`** to **`spine_torque_a3`**: Spine torque polynomial coefficients
- **`shoulder_torque_a0`** to **`shoulder_torque_a3`**: Shoulder torque polynomial coefficients
- **`elbow_torque_a0`** to **`elbow_torque_a3`**: Elbow torque polynomial coefficients
- **`wrist_torque_a0`** to **`wrist_torque_a3`**: Wrist torque polynomial coefficients
- **`start_hip_x`**, **`start_hip_y`**, **`start_hip_z`**: Starting hip positions
- **`start_spine_rx`**, **`start_spine_ry`**: Starting spine rotations
- **`simulation_time`**: How long each simulation took to run

### Example Usage

#### Load and Analyze
```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Load data
dataset = pd.read_csv('simple_dataset_10_sims_20250722_211348_dataset_20250722_212615.csv')

# Get data for simulation 1
sim1 = dataset[dataset.simulation_id == 1]

# Plot hip torque polynomial
time = np.linspace(0, 0.3, 100)
coeffs = [sim1.hip_torque_a0.iloc[0], sim1.hip_torque_a1.iloc[0], 
          sim1.hip_torque_a2.iloc[0], sim1.hip_torque_a3.iloc[0]]
hip_torque = np.polyval(coeffs[::-1], time)

plt.plot(time, hip_torque)
plt.xlabel('Time (s)')
plt.ylabel('Hip Torque (N⋅m)')
plt.title('Hip Torque Polynomial - Simulation 1')
plt.show()
```

#### Machine Learning Preparation
```python
# Extract features (polynomial coefficients)
feature_cols = [col for col in dataset.columns if '_a' in col]
X = dataset[feature_cols].iloc[::10, :]  # Sample every 10th point

# For now, create dummy targets (in real implementation, these would be joint torques)
y = np.random.randn(len(X), 15)  # 15 joint torques (3D x 5 joints)

print(f"Training data: X={X.shape}, y={y.shape}")
```

## Dataset Statistics

- **Total data points**: 47,220
- **Simulations**: 15
- **Time range**: 0.000 to 0.300 seconds
- **Data points per simulation**: ~3,148
- **File size**: 6.1 MB

## Future Enhancements

This export currently contains polynomial input coefficients. Future versions will include:
- Joint kinematics (positions, velocities, accelerations)
- Joint torques (the actual simulation outputs)
- Club head speed and other golf metrics
- More detailed signal data from Simscape

## Notes

- All simulations ran successfully (100% success rate)
- Data is cumulative - you can add more simulations using the MATLAB append function
- CSV format is compatible with Excel, Python pandas, R, and most data analysis tools
- The Python helper script provides ready-to-use functions for analysis and visualization 