#!/usr/bin/env python3
"""
Simple Python helper script to load golf swing dataset
Generated: 22-Jul-2025 21:26:16
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

def load_dataset(base_name="simple_dataset_10_sims_20250722_211348", timestamp="20250722_212615"):
    """Load golf swing dataset from CSV files"""
    data_dir = Path(".")
    
    # Load main dataset
    dataset_file = data_dir / f"{base_name}_dataset_{timestamp}.csv"
    dataset = pd.read_csv(dataset_file)
    
    # Load simulation summary
    summary_file = data_dir / f"{base_name}_summary_{timestamp}.csv"
    summary = pd.read_csv(summary_file)
    
    return dataset, summary

def get_simulation_data(dataset, simulation_id):
    """Get data for a specific simulation"""
    return dataset[dataset.simulation_id == simulation_id].copy()

def plot_polynomial_coefficients(dataset, simulation_id=1):
    """Plot polynomial coefficients for a simulation"""
    sim_data = get_simulation_data(dataset, simulation_id)
    
    # Get polynomial coefficients
    hip_coeffs = [
        sim_data.hip_torque_a0.iloc[0],
        sim_data.hip_torque_a1.iloc[0],
        sim_data.hip_torque_a2.iloc[0],
        sim_data.hip_torque_a3.iloc[0]
    ]
    
    # Create time array for polynomial evaluation
    time = np.linspace(0, sim_data.time.max(), 100)
    
    # Evaluate polynomial
    hip_torque = np.polyval(hip_coeffs[::-1], time)  # Reverse for polyval
    
    plt.figure(figsize=(10, 6))
    plt.plot(time, hip_torque, "b-", linewidth=2, label="Hip Torque Polynomial")
    plt.xlabel("Time (s)")
    plt.ylabel("Torque (N⋅m)")
    plt.title(f"Hip Torque Polynomial - Simulation {simulation_id}")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.show()

def analyze_dataset(dataset, summary):
    """Analyze dataset statistics"""
    print("=== Dataset Analysis ===\n")
    
    print(f"Total data points: {len(dataset):,}")
    print(f"Number of simulations: {dataset.simulation_id.nunique()}")
    print(f"Time range: {dataset.time.min():.3f} to {dataset.time.max():.3f} seconds")
    print(f"Average simulation time: {summary.simulation_time.mean():.2f} seconds")
    print(f"Successful simulations: {summary.success.sum()}/{len(summary)}")
    
    # Show polynomial coefficient ranges
    print("\n=== Polynomial Coefficient Ranges ===")
    coeff_columns = [col for col in dataset.columns if "_a" in col]
    for col in coeff_columns:
        print(f"{col}: [{dataset[col].min():.3f}, {dataset[col].max():.3f}]")
    
    # Show starting position ranges
    print("\n=== Starting Position Ranges ===")
    start_columns = [col for col in dataset.columns if "start_" in col]
    for col in start_columns:
        print(f"{col}: [{dataset[col].min():.3f}, {dataset[col].max():.3f}]")

def create_training_data(dataset):
    """Create training data for neural network"""
    # Extract polynomial coefficients as features
    feature_columns = [col for col in dataset.columns if "_a" in col]
    
    # For now, we only have polynomial inputs as features
    # In the future, this would include joint kinematics
    X = dataset[feature_columns].iloc[::10, :]  # Sample every 10th point
    
    # Create dummy target (in real implementation, this would be joint torques)
    y = np.random.randn(len(X), 15)  # 15 joint torques (3D x 5 joints)
    
    return X, y

if __name__ == "__main__":
    # Example usage
    print("Loading golf swing dataset...")
    try:
        dataset, summary = load_dataset()
        print("✓ Dataset loaded successfully!\n")
        
        # Analyze dataset
        analyze_dataset(dataset, summary)
        
        # Plot sample polynomial
        plot_polynomial_coefficients(dataset, simulation_id=1)
        
        # Create training data
        X, y = create_training_data(dataset)
        print(f"\nTraining data shape: X={X.shape}, y={y.shape}")
        
    except FileNotFoundError as e:
        print(f"✗ Error: {e}")
        print("Make sure you are in the correct directory with the exported files.")
