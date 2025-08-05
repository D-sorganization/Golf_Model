#!/usr/bin/env python3
"""
Golf Swing PyTorch Motion Matching System
=========================================

This system matches polynomial coefficients to motion capture data using PyTorch,
with 3D visualization of the golf swing skeleton and trajectory comparison.

Features:
- Load motion capture data from Wiffle Excel files
- Train PyTorch neural network to map hand trajectories to polynomial coefficients
- 3D skeleton visualization with joint connections
- Real-time comparison of motion capture vs simulation results
- Interactive GUI for running and visualizing results
- Integration with MATLAB simulation system

Author: Generated for Golf Swing Simulation Project
Date: 2025
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.animation as animation
from matplotlib.widgets import Slider, Button, CheckButtons
import seaborn as sns
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.metrics import mean_squared_error, r2_score
import joblib
import os
import glob
import json
from datetime import datetime
from scipy import interpolate, signal, optimize
from scipy.spatial.transform import Rotation as R
import warnings
warnings.filterwarnings('ignore')

# Set random seeds for reproducibility
np.random.seed(42)
torch.manual_seed(42)
if torch.cuda.is_available():
    torch.cuda.manual_seed(42)

# Device configuration
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")


class GolfSwingDataset(Dataset):
    """Custom PyTorch dataset for golf swing trajectory-to-coefficients mapping."""
    
    def __init__(self, trajectories, coefficients, transform=None):
        """
        Initialize dataset.
        
        Args:
            trajectories (np.ndarray): Hand trajectory features [N, feature_dim]
            coefficients (np.ndarray): Polynomial coefficients [N, coeff_dim]
            transform: Optional data transforms
        """
        self.trajectories = torch.FloatTensor(trajectories)
        self.coefficients = torch.FloatTensor(coefficients)
        self.transform = transform
        
    def __len__(self):
        return len(self.trajectories)
    
    def __getitem__(self, idx):
        trajectory = self.trajectories[idx]
        coeffs = self.coefficients[idx]
        
        if self.transform:
            trajectory = self.transform(trajectory)
            
        return trajectory, coeffs


class TrajectoryEncoder(nn.Module):
    """
    Neural network that encodes hand trajectories into polynomial coefficients.
    Uses attention mechanism to focus on important parts of the trajectory.
    """
    
    def __init__(self, trajectory_dim, coefficient_dim, hidden_dims=[512, 256, 128], 
                 dropout_rate=0.3, use_attention=True):
        """
        Initialize the trajectory encoder.
        
        Args:
            trajectory_dim (int): Input trajectory feature dimension
            coefficient_dim (int): Output coefficient dimension
            hidden_dims (list): Hidden layer dimensions
            dropout_rate (float): Dropout rate
            use_attention (bool): Whether to use attention mechanism
        """
        super(TrajectoryEncoder, self).__init__()
        
        self.trajectory_dim = trajectory_dim
        self.coefficient_dim = coefficient_dim
        self.use_attention = use_attention
        
        # Input processing layers
        self.input_norm = nn.BatchNorm1d(trajectory_dim)
        
        # Main encoder network
        layers = []
        prev_dim = trajectory_dim
        
        for i, hidden_dim in enumerate(hidden_dims):
            layers.extend([
                nn.Linear(prev_dim, hidden_dim),
                nn.BatchNorm1d(hidden_dim),
                nn.ReLU(),
                nn.Dropout(dropout_rate * (0.8 ** i))  # Decreasing dropout
            ])
            prev_dim = hidden_dim
        
        self.encoder = nn.Sequential(*layers)
        
        # Attention mechanism for trajectory features
        if use_attention:
            self.attention = nn.MultiheadAttention(
                embed_dim=prev_dim, num_heads=8, dropout=dropout_rate, batch_first=True
            )
            self.attention_norm = nn.LayerNorm(prev_dim)
        
        # Output layers for coefficient prediction
        self.coefficient_predictor = nn.Sequential(
            nn.Linear(prev_dim, prev_dim // 2),
            nn.ReLU(),
            nn.Dropout(dropout_rate / 2),
            nn.Linear(prev_dim // 2, coefficient_dim)
        )
        
        # Initialize weights
        self.apply(self._init_weights)
    
    def _init_weights(self, module):
        """Initialize network weights."""
        if isinstance(module, nn.Linear):
            nn.init.xavier_uniform_(module.weight)
            if module.bias is not None:
                nn.init.zeros_(module.bias)
        elif isinstance(module, nn.BatchNorm1d):
            nn.init.ones_(module.weight)
            nn.init.zeros_(module.bias)
    
    def forward(self, x):
        """Forward pass through the network."""
        # Input normalization
        x = self.input_norm(x)
        
        # Encode trajectory features
        encoded = self.encoder(x)
        
        # Apply attention if enabled
        if self.use_attention:
            # Reshape for attention (add sequence dimension)
            encoded_seq = encoded.unsqueeze(1)  # [batch, 1, features]
            attended, _ = self.attention(encoded_seq, encoded_seq, encoded_seq)
            encoded = self.attention_norm(attended.squeeze(1) + encoded)
        
        # Predict coefficients
        coefficients = self.coefficient_predictor(encoded)
        
        return coefficients


class MotionCaptureLoader:
    """
    Loads and processes motion capture data from Wiffle Excel files.
    """
    
    def __init__(self):
        self.mocap_data = None
        self.club_trajectory = None
        self.hand_trajectory = None
        self.time_vector = None
        
    def load_wiffle_data(self, filepath):
        """
        Load motion capture data from Wiffle Excel file.
        
        Args:
            filepath (str): Path to Wiffle Excel file
            
        Returns:
            dict: Processed motion capture data
        """
        print(f"Loading motion capture data from {filepath}")
        
        try:
            # Load Excel file - try different sheet names
            excel_file = pd.ExcelFile(filepath)
            print(f"Available sheets: {excel_file.sheet_names}")
            
            # Load the first sheet or look for specific sheet names
            sheet_name = excel_file.sheet_names[0]
            if 'Club_3D' in excel_file.sheet_names:
                sheet_name = 'Club_3D'
            elif 'Data' in excel_file.sheet_names:
                sheet_name = 'Data'
            
            self.mocap_data = pd.read_excel(filepath, sheet_name=sheet_name)
            print(f"Loaded data shape: {self.mocap_data.shape}")
            print(f"Columns: {list(self.mocap_data.columns)}")
            
            # Process the data to extract trajectories
            self._extract_trajectories()
            
            return {
                'raw_data': self.mocap_data,
                'club_trajectory': self.club_trajectory,
                'hand_trajectory': self.hand_trajectory,
                'time_vector': self.time_vector
            }
            
        except Exception as e:
            print(f"Error loading Wiffle data: {e}")
            return None
    
    def _extract_trajectories(self):
        """Extract club and hand trajectories from motion capture data."""
        # Look for time column
        time_cols = [col for col in self.mocap_data.columns if 'time' in col.lower()]
        if time_cols:
            self.time_vector = self.mocap_data[time_cols[0]].values
        else:
            # Create synthetic time vector
            self.time_vector = np.linspace(0, 1, len(self.mocap_data))
        
        # Look for club position columns
        club_pos_cols = [col for col in self.mocap_data.columns 
                        if any(keyword in col.lower() for keyword in ['club', 'head', 'grip'])]
        
        if len(club_pos_cols) >= 3:
            # Try to identify X, Y, Z coordinates
            x_cols = [col for col in club_pos_cols if 'x' in col.lower()]
            y_cols = [col for col in club_pos_cols if 'y' in col.lower()]
            z_cols = [col for col in club_pos_cols if 'z' in col.lower()]
            
            if x_cols and y_cols and z_cols:
                self.club_trajectory = np.column_stack([
                    self.mocap_data[x_cols[0]].values,
                    self.mocap_data[y_cols[0]].values,
                    self.mocap_data[z_cols[0]].values
                ])
                print(f"Extracted club trajectory: {self.club_trajectory.shape}")
        
        # Look for hand position columns
        hand_pos_cols = [col for col in self.mocap_data.columns 
                        if any(keyword in col.lower() for keyword in ['hand', 'wrist', 'grip'])]
        
        # If we can't find explicit hand columns, use club data as proxy
        if len(hand_pos_cols) < 3 and self.club_trajectory is not None:
            # Estimate hand position from club position (offset upward)
            self.hand_trajectory = self.club_trajectory.copy()
            self.hand_trajectory[:, 2] += 0.3  # Offset hands above club
            print("Using club trajectory as hand trajectory proxy")
        elif len(hand_pos_cols) >= 3:
            # Extract hand positions similar to club
            x_cols = [col for col in hand_pos_cols if 'x' in col.lower()]
            y_cols = [col for col in hand_pos_cols if 'y' in col.lower()]
            z_cols = [col for col in hand_pos_cols if 'z' in col.lower()]
            
            if x_cols and y_cols and z_cols:
                self.hand_trajectory = np.column_stack([
                    self.mocap_data[x_cols[0]].values,
                    self.mocap_data[y_cols[0]].values,
                    self.mocap_data[z_cols[0]].values
                ])
                print(f"Extracted hand trajectory: {self.hand_trajectory.shape}")


class SimulationDataProcessor:
    """
    Processes simulation trial data for training the neural network.
    """
    
    def __init__(self, data_directory='.'):
        self.data_directory = data_directory
        self.joint_names = []
        self.coefficient_names = ['A', 'B', 'C', 'D', 'E', 'F', 'G']
        self.trajectory_length = 100  # Target normalized trajectory length
        
    def load_trial_data(self):
        """Load all trial CSV files from the data directory."""
        csv_pattern = os.path.join(self.data_directory, 'trial_*.csv')
        csv_files = glob.glob(csv_pattern)
        
        if not csv_files:
            raise FileNotFoundError(f"No trial CSV files found in {self.data_directory}")
        
        print(f"Loading {len(csv_files)} trial files...")
        
        all_trials = []
        for i, csv_file in enumerate(csv_files):
            try:
                df = pd.read_csv(csv_file)
                df['trial_id'] = i
                df['filename'] = os.path.basename(csv_file)
                all_trials.append(df)
                
                if i == 0:
                    print(f"First trial shape: {df.shape}")
                    self._analyze_data_structure(df)
                    
            except Exception as e:
                print(f"Error loading {csv_file}: {e}")
                continue
        
        if not all_trials:
            raise ValueError("No valid trial data loaded")
        
        combined_data = pd.concat(all_trials, ignore_index=True)
        print(f"Combined simulation data shape: {combined_data.shape}")
        
        return combined_data
    
    def _analyze_data_structure(self, df):
        """Analyze the structure of simulation data to understand available signals."""
        print("\nSimulation Data Structure Analysis:")
        
        # Key signal patterns to look for
        key_patterns = {
            'time': ['time'],
            'hand_midpoint': ['MidpointCalcsLogs_MPGlobalPosition'],
            'left_hand': ['LHCalcsLogs_LeftHandPostion'],
            'right_hand': ['RHCalcsLogs_RightHandPostion'],
            'club_head': ['ClubLogs_CHGlobalPosition'],
            'joint_positions': ['*Logs_GlobalPosition'],
            'polynomial_coeffs': ['input_.*_[A-G]']
        }
        
        for category, patterns in key_patterns.items():
            matching_cols = []
            for pattern in patterns:
                if '*' in pattern:
                    # Handle wildcard patterns
                    pattern_regex = pattern.replace('*', '.*')
                    matching_cols.extend([col for col in df.columns if pattern_regex in col])
                else:
                    matching_cols.extend([col for col in df.columns if pattern in col])
            
            print(f"  {category}: {len(matching_cols)} columns")
            if matching_cols and len(matching_cols) <= 5:
                print(f"    Examples: {matching_cols}")
    
    def extract_training_data(self, df):
        """
        Extract hand trajectories and polynomial coefficients for training.
        
        Args:
            df (pd.DataFrame): Combined trial data
            
        Returns:
            tuple: (trajectory_features, coefficients, metadata)
        """
        print("\nExtracting training data from simulation trials...")
        
        trajectory_features = []
        coefficients = []
        valid_trials = []
        
        # Find available joints from input columns
        input_cols = [col for col in df.columns if col.startswith('input_') and 
                     any(col.endswith(f'_{coeff}') for coeff in self.coefficient_names)]
        
        joint_names = set()
        for col in input_cols:
            parts = col.split('_')
            if len(parts) >= 3:
                joint_name = '_'.join(parts[1:-1])
                joint_names.add(joint_name)
        
        self.joint_names = sorted(list(joint_names))
        print(f"Found {len(self.joint_names)} joints for training")
        
        # Process each trial
        trial_ids = df['trial_id'].unique()
        print(f"Processing {len(trial_ids)} trials...")
        
        for trial_id in trial_ids:
            try:
                trial_data = df[df['trial_id'] == trial_id]
                
                # Extract hand midpoint trajectory
                trajectory = self._extract_hand_trajectory(trial_data)
                if trajectory is None:
                    continue
                
                # Normalize and extract features
                traj_features = self._extract_trajectory_features(trajectory)
                
                # Extract polynomial coefficients
                trial_coeffs = self._extract_coefficients(trial_data)
                if trial_coeffs is None:
                    continue
                
                trajectory_features.append(traj_features)
                coefficients.append(trial_coeffs)
                valid_trials.append(trial_id)
                
            except Exception as e:
                print(f"Error processing trial {trial_id}: {e}")
                continue
        
        trajectory_features = np.array(trajectory_features)
        coefficients = np.array(coefficients)
        
        print(f"Extracted {len(valid_trials)} valid trials")
        print(f"Trajectory feature dimension: {trajectory_features.shape[1]}")
        print(f"Coefficient dimension: {coefficients.shape[1]}")
        
        metadata = {
            'joint_names': self.joint_names,
            'coefficient_names': self.coefficient_names,
            'trajectory_length': self.trajectory_length,
            'n_features': trajectory_features.shape[1],
            'n_coefficients': coefficients.shape[1],
            'valid_trials': valid_trials
        }
        
        return trajectory_features, coefficients, metadata
    
    def _extract_hand_trajectory(self, trial_data):
        """Extract hand midpoint trajectory from trial data."""
        # Try midpoint columns first
        mp_pos_cols = [col for col in trial_data.columns 
                      if 'MidpointCalcsLogs_MPGlobalPosition' in col]
        
        if len(mp_pos_cols) >= 3:
            position = trial_data[mp_pos_cols[:3]].values
            time_data = trial_data['time'].values if 'time' in trial_data.columns else np.arange(len(position))
        else:
            # Fallback: compute from left and right hand positions
            lh_cols = [col for col in trial_data.columns if 'LHCalcsLogs_LeftHandPostion' in col]
            rh_cols = [col for col in trial_data.columns if 'RHCalcsLogs_RightHandPostion' in col]
            
            if len(lh_cols) >= 3 and len(rh_cols) >= 3:
                lh_pos = trial_data[lh_cols[:3]].values
                rh_pos = trial_data[rh_cols[:3]].values
                position = (lh_pos + rh_pos) / 2.0
                time_data = trial_data['time'].values if 'time' in trial_data.columns else np.arange(len(position))
            else:
                return None
        
        # Compute velocity
        dt = np.mean(np.diff(time_data)) if len(time_data) > 1 else 0.01
        velocity = np.gradient(position, dt, axis=0)
        
        return {
            'position': position,
            'velocity': velocity,
            'time': time_data
        }
    
    def _extract_trajectory_features(self, trajectory):
        """Extract features from trajectory for neural network input."""
        position = trajectory['position']
        velocity = trajectory['velocity']
        time = trajectory['time']
        
        # Normalize trajectory to target length
        position_norm, velocity_norm = self._normalize_trajectory(position, velocity, time)
        
        features = []
        
        # Raw trajectory features (flattened)
        features.extend(position_norm.flatten())
        features.extend(velocity_norm.flatten())
        
        # Statistical features for each axis
        for axis in range(3):
            pos_axis = position_norm[:, axis]
            vel_axis = velocity_norm[:, axis]
            
            # Position statistics
            features.extend([
                np.mean(pos_axis), np.std(pos_axis),
                np.min(pos_axis), np.max(pos_axis), np.ptp(pos_axis)
            ])
            
            # Velocity statistics
            features.extend([
                np.mean(vel_axis), np.std(vel_axis),
                np.min(vel_axis), np.max(vel_axis), np.ptp(vel_axis)
            ])
        
        # Overall trajectory characteristics
        total_distance = np.sum(np.linalg.norm(np.diff(position_norm, axis=0), axis=1))
        max_speed = np.max(np.linalg.norm(velocity_norm, axis=1))
        avg_speed = np.mean(np.linalg.norm(velocity_norm, axis=1))
        
        features.extend([total_distance, max_speed, avg_speed])
        
        return np.array(features)
    
    def _normalize_trajectory(self, position, velocity, time):
        """Normalize trajectory to standard length."""
        # Interpolate to target length
        time_norm = np.linspace(time[0], time[-1], self.trajectory_length)
        
        position_norm = np.zeros((self.trajectory_length, 3))
        velocity_norm = np.zeros((self.trajectory_length, 3))
        
        for axis in range(3):
            f_pos = interpolate.interp1d(time, position[:, axis], kind='cubic', 
                                       bounds_error=False, fill_value='extrapolate')
            position_norm[:, axis] = f_pos(time_norm)
            
            f_vel = interpolate.interp1d(time, velocity[:, axis], kind='cubic',
                                       bounds_error=False, fill_value='extrapolate')
            velocity_norm[:, axis] = f_vel(time_norm)
        
        return position_norm, velocity_norm
    
    def _extract_coefficients(self, trial_data):
        """Extract polynomial coefficients from trial data."""
        coeffs = []
        
        for joint_name in self.joint_names:
            for coeff_name in self.coefficient_names:
                col_name = f"input_{joint_name}_{coeff_name}"
                if col_name in trial_data.columns:
                    coeffs.append(trial_data[col_name].iloc[0])
                else:
                    coeffs.append(0.0)
        
        return np.array(coeffs) if coeffs else None


class GolfSwingSkeleton:
    """
    3D skeleton representation for golf swing visualization.
    """
    
    def __init__(self):
        # Define joint connections based on golf swing model
        self.joint_connections = [
            # Spine and torso
            ('hip', 'spine_lower'),
            ('spine_lower', 'spine_upper'),
            ('spine_upper', 'head'),
            
            # Left arm
            ('spine_upper', 'left_shoulder'),
            ('left_shoulder', 'left_elbow'),
            ('left_elbow', 'left_wrist'),
            ('left_wrist', 'left_hand'),
            
            # Right arm
            ('spine_upper', 'right_shoulder'),
            ('right_shoulder', 'right_elbow'),
            ('right_elbow', 'right_wrist'),
            ('right_wrist', 'right_hand'),
            
            # Club
            ('left_hand', 'club_grip'),
            ('right_hand', 'club_grip'),
            ('club_grip', 'club_head')
        ]
        
        # Default joint positions (will be updated from simulation data)
        self.joint_positions = {
            'hip': np.array([0, 0, 1.0]),
            'spine_lower': np.array([0, 0, 1.2]),
            'spine_upper': np.array([0, 0, 1.4]),
            'head': np.array([0, 0, 1.6]),
            'left_shoulder': np.array([-0.2, 0, 1.4]),
            'left_elbow': np.array([-0.4, 0.3, 1.2]),
            'left_wrist': np.array([-0.3, 0.5, 1.0]),
            'left_hand': np.array([-0.2, 0.6, 0.9]),
            'right_shoulder': np.array([0.2, 0, 1.4]),
            'right_elbow': np.array([0.4, 0.3, 1.2]),
            'right_wrist': np.array([0.3, 0.5, 1.0]),
            'right_hand': np.array([0.2, 0.6, 0.9]),
            'club_grip': np.array([0, 0.6, 0.9]),
            'club_head': np.array([0, 1.0, 0.1])
        }
        
        # Colors for different body parts
        self.colors = {
            'spine': '#2E86AB',     # Blue
            'left_arm': '#A23B72',  # Purple
            'right_arm': '#F18F01', # Orange
            'club': '#C73E1D',      # Red
            'joints': '#F3F3F3'     # Light gray
        }
    
    def update_from_simulation_data(self, sim_data, time_idx=0):
        """Update joint positions from simulation data."""
        # Map simulation data columns to skeleton joints
        joint_mapping = {
            'hip': ['HipLogs_HipGlobalPosition_1', 'HipLogs_HipGlobalPosition_2', 'HipLogs_HipGlobalPosition_3'],
            'left_hand': ['LHCalcsLogs_LeftHandPostion_1', 'LHCalcsLogs_LeftHandPostion_2', 'LHCalcsLogs_LeftHandPostion_3'],
            'right_hand': ['RHCalcsLogs_RightHandPostion_1', 'RHCalcsLogs_RightHandPostion_2', 'RHCalcsLogs_RightHandPostion_3'],
            'club_head': ['ClubLogs_CHGlobalPosition_1', 'ClubLogs_CHGlobalPosition_2', 'ClubLogs_CHGlobalPosition_3']
        }
        
        for joint_name, col_names in joint_mapping.items():
            if all(col in sim_data for col in col_names):
                try:
                    if isinstance(sim_data[col_names[0]], (list, np.ndarray)):
                        if len(sim_data[col_names[0]]) > time_idx:
                            position = np.array([
                                sim_data[col_names[0]][time_idx],
                                sim_data[col_names[1]][time_idx],
                                sim_data[col_names[2]][time_idx]
                            ])
                            self.joint_positions[joint_name] = position
                except (IndexError, KeyError):
                    continue
        
        # Calculate derived positions
        if 'left_hand' in self.joint_positions and 'right_hand' in self.joint_positions:
            self.joint_positions['club_grip'] = (
                self.joint_positions['left_hand'] + self.joint_positions['right_hand']
            ) / 2.0
    
    def plot_skeleton(self, ax, alpha=1.0, linewidth=2, show_joints=True):
        """Plot the skeleton on a 3D axis."""
        # Plot joint connections
        for connection in self.joint_connections:
            joint1, joint2 = connection
            if joint1 in self.joint_positions and joint2 in self.joint_positions:
                pos1 = self.joint_positions[joint1]
                pos2 = self.joint_positions[joint2]
                
                # Determine color
                if 'club' in joint1 or 'club' in joint2:
                    color = self.colors['club']
                elif 'left' in joint1 or 'left' in joint2:
                    color = self.colors['left_arm']
                elif 'right' in joint1 or 'right' in joint2:
                    color = self.colors['right_arm']
                else:
                    color = self.colors['spine']
                
                ax.plot([pos1[0], pos2[0]], [pos1[1], pos2[1]], [pos1[2], pos2[2]], 
                       color=color, alpha=alpha, linewidth=linewidth)
        
        # Plot joints
        if show_joints:
            for joint_name, position in self.joint_positions.items():
                size = 80 if 'hand' in joint_name or 'club' in joint_name else 40
                ax.scatter(position[0], position[1], position[2], 
                         s=size, c=self.colors['joints'], alpha=alpha, edgecolors='black')


class MotionMatchingVisualizer:
    """
    Interactive 3D visualization for comparing motion capture and simulation results.
    """
    
    def __init__(self, figsize=(16, 10)):
        self.fig = plt.figure(figsize=figsize)
        self.setup_layout()
        
        # Data containers
        self.mocap_data = None
        self.sim_data = None
        self.skeleton = GolfSwingSkeleton()
        
        # Animation controls
        self.is_playing = False
        self.current_frame = 0
        self.animation = None
        
    def setup_layout(self):
        """Setup the visualization layout with multiple subplots."""
        # Main 3D view
        self.ax_3d = self.fig.add_subplot(221, projection='3d')
        self.ax_3d.set_title('3D Golf Swing Visualization', fontsize=14, fontweight='bold')
        
        # Trajectory comparison (X-Y view)
        self.ax_xy = self.fig.add_subplot(222)
        self.ax_xy.set_title('Hand Trajectory - Top View (X-Y)', fontweight='bold')
        self.ax_xy.set_xlabel('X Position (m)')
        self.ax_xy.set_ylabel('Y Position (m)')
        self.ax_xy.grid(True, alpha=0.3)
        
        # Trajectory comparison (X-Z view)
        self.ax_xz = self.fig.add_subplot(223)
        self.ax_xz.set_title('Hand Trajectory - Side View (X-Z)', fontweight='bold')
        self.ax_xz.set_xlabel('X Position (m)')
        self.ax_xz.set_ylabel('Z Position (m)')
        self.ax_xz.grid(True, alpha=0.3)
        
        # Error analysis
        self.ax_error = self.fig.add_subplot(224)
        self.ax_error.set_title('Position Error Over Time', fontweight='bold')
        self.ax_error.set_xlabel('Time (s)')
        self.ax_error.set_ylabel('Error (m)')
        self.ax_error.grid(True, alpha=0.3)
        
        # Control widgets
        self.setup_controls()
        
        plt.tight_layout()
        plt.subplots_adjust(bottom=0.15)
    
    def setup_controls(self):
        """Setup interactive controls."""
        # Time slider
        slider_ax = plt.axes([0.1, 0.08, 0.5, 0.03])
        self.time_slider = Slider(slider_ax, 'Time', 0, 1, valinit=0, 
                                 facecolor='lightblue', alpha=0.7)
        self.time_slider.on_changed(self.update_visualization)
        
        # Play/Pause button
        play_ax = plt.axes([0.65, 0.08, 0.08, 0.04])
        self.play_button = Button(play_ax, 'Play', color='lightgreen', hovercolor='green')
        self.play_button.on_clicked(self.toggle_animation)
        
        # Reset button
        reset_ax = plt.axes([0.74, 0.08, 0.08, 0.04])
        self.reset_button = Button(reset_ax, 'Reset', color='lightcoral', hovercolor='red')
        self.reset_button.on_clicked(self.reset_view)
        
        # Display options
        options_ax = plt.axes([0.83, 0.05, 0.15, 0.1])
        self.display_options = CheckButtons(
            options_ax, ['Show Skeleton', 'Show Trajectories', 'Show Error'], [True, True, True]
        )
        self.display_options.on_clicked(self.update_display_options)
    
    def load_motion_capture_data(self, mocap_data):
        """Load motion capture data for visualization."""
        self.mocap_data = mocap_data
        print(f"Loaded motion capture data with {len(mocap_data['hand_trajectory'])} time points")
        
        # Update slider range
        max_frames = len(mocap_data['hand_trajectory']) - 1
        self.time_slider.valmax = max_frames
        self.time_slider.ax.set_xlim(0, max_frames)
    
    def load_simulation_data(self, sim_data):
        """Load simulation data for visualization."""
        self.sim_data = sim_data
        print(f"Loaded simulation data")
    
    def update_visualization(self, val=None):
        """Update the visualization for current time point."""
        if self.mocap_data is None:
            return
        
        # Get current time index
        if val is None:
            time_idx = int(self.time_slider.val)
        else:
            time_idx = int(val)
        
        time_idx = max(0, min(time_idx, len(self.mocap_data['hand_trajectory']) - 1))
        
        # Clear all axes
        self.ax_3d.clear()
        self.ax_xy.clear()
        self.ax_xz.clear()
        self.ax_error.clear()
        
        # Update skeleton from simulation data if available
        if self.sim_data:
            self.skeleton.update_from_simulation_data(self.sim_data, time_idx)
        
        # Plot skeleton
        if self.display_options.get_status()[0]:  # Show Skeleton
            self.skeleton.plot_skeleton(self.ax_3d, alpha=0.8, linewidth=2)
        
        # Plot trajectories
        if self.display_options.get_status()[1]:  # Show Trajectories
            self.plot_trajectories(time_idx)
        
        # Plot error analysis
        if self.display_options.get_status()[2]:  # Show Error
            self.plot_error_analysis(time_idx)
        
        # Set 3D axis properties
        self.ax_3d.set_xlabel('X (m)')
        self.ax_3d.set_ylabel('Y (m)')
        self.ax_3d.set_zlabel('Z (m)')
        self.ax_3d.set_title(f'Golf Swing at Frame {time_idx}')
        
        # Set equal aspect ratio for 3D plot
        self.set_equal_aspect_3d()
        
        self.fig.canvas.draw()
    
    def plot_trajectories(self, current_idx):
        """Plot hand trajectories up to current time."""
        mocap_traj = self.mocap_data['hand_trajectory'][:current_idx+1]
        
        if len(mocap_traj) > 1:
            # 3D trajectory
            self.ax_3d.plot(mocap_traj[:, 0], mocap_traj[:, 1], mocap_traj[:, 2], 
                           'b-', linewidth=3, alpha=0.8, label='Motion Capture')
            self.ax_3d.scatter(mocap_traj[-1, 0], mocap_traj[-1, 1], mocap_traj[-1, 2], 
                             c='blue', s=100, marker='o')
            
            # X-Y projection
            self.ax_xy.plot(mocap_traj[:, 0], mocap_traj[:, 1], 'b-', linewidth=2, label='Motion Capture')
            self.ax_xy.scatter(mocap_traj[-1, 0], mocap_traj[-1, 1], c='blue', s=100, marker='o')
            
            # X-Z projection
            self.ax_xz.plot(mocap_traj[:, 0], mocap_traj[:, 2], 'b-', linewidth=2, label='Motion Capture')
            self.ax_xz.scatter(mocap_traj[-1, 0], mocap_traj[-1, 2], c='blue', s=100, marker='o')
        
        # Add simulation trajectory if available
        if self.sim_data and 'hand_trajectory' in self.sim_data:
            sim_traj = self.sim_data['hand_trajectory'][:current_idx+1]
            
            if len(sim_traj) > 1:
                # 3D trajectory
                self.ax_3d.plot(sim_traj[:, 0], sim_traj[:, 1], sim_traj[:, 2], 
                               'r--', linewidth=3, alpha=0.8, label='Simulation')
                self.ax_3d.scatter(sim_traj[-1, 0], sim_traj[-1, 1], sim_traj[-1, 2], 
                                 c='red', s=100, marker='s')
                
                # X-Y projection
                self.ax_xy.plot(sim_traj[:, 0], sim_traj[:, 1], 'r--', linewidth=2, label='Simulation')
                self.ax_xy.scatter(sim_traj[-1, 0], sim_traj[-1, 1], c='red', s=100, marker='s')
                
                # X-Z projection
                self.ax_xz.plot(sim_traj[:, 0], sim_traj[:, 2], 'r--', linewidth=2, label='Simulation')
                self.ax_xz.scatter(sim_traj[-1, 0], sim_traj[-1, 2], c='red', s=100, marker='s')
        
        # Add legends and labels
        self.ax_3d.legend()
        self.ax_xy.legend()
        self.ax_xy.set_xlabel('X Position (m)')
        self.ax_xy.set_ylabel('Y Position (m)')
        self.ax_xy.grid(True, alpha=0.3)
        
        self.ax_xz.legend()
        self.ax_xz.set_xlabel('X Position (m)')
        self.ax_xz.set_ylabel('Z Position (m)')
        self.ax_xz.grid(True, alpha=0.3)
    
    def plot_error_analysis(self, current_idx):
        """Plot position error between motion capture and simulation."""
        if not (self.sim_data and 'hand_trajectory' in self.sim_data):
            self.ax_error.text(0.5, 0.5, 'No simulation data available\nfor error analysis', 
                             ha='center', va='center', transform=self.ax_error.transAxes)
            return
        
        mocap_traj = self.mocap_data['hand_trajectory']
        sim_traj = self.sim_data['hand_trajectory']
        
        # Calculate error up to current time
        min_length = min(len(mocap_traj), len(sim_traj), current_idx + 1)
        
        if min_length > 1:
            error = np.linalg.norm(mocap_traj[:min_length] - sim_traj[:min_length], axis=1)
            time_vec = np.linspace(0, 1, min_length)
            
            self.ax_error.plot(time_vec, error, 'g-', linewidth=2, label='Position Error')
            if min_length > 0:
                self.ax_error.scatter(time_vec[-1], error[-1], c='green', s=100)
                
            # Add statistics
            mean_error = np.mean(error)
            max_error = np.max(error)
            self.ax_error.axhline(mean_error, color='orange', linestyle='--', alpha=0.7, 
                                label=f'Mean: {mean_error:.3f}m')
            self.ax_error.text(0.02, 0.98, f'Max Error: {max_error:.3f}m', 
                             transform=self.ax_error.transAxes, va='top')
            
            self.ax_error.legend()
        
        self.ax_error.set_xlabel('Normalized Time')
        self.ax_error.set_ylabel('Position Error (m)')
        self.ax_error.grid(True, alpha=0.3)
    
    def set_equal_aspect_3d(self):
        """Set equal aspect ratio for 3D plot."""
        # Get all position data
        all_positions = list(self.skeleton.joint_positions.values())
        
        if self.mocap_data and 'hand_trajectory' in self.mocap_data:
            all_positions.extend(self.mocap_data['hand_trajectory'])
        
        if all_positions:
            positions = np.array(all_positions)
            
            # Calculate range
            max_range = np.array([
                positions[:, 0].max() - positions[:, 0].min(),
                positions[:, 1].max() - positions[:, 1].min(),
                positions[:, 2].max() - positions[:, 2].min()
            ]).max() / 2.0
            
            # Calculate center
            mid_x = (positions[:, 0].max() + positions[:, 0].min()) * 0.5
            mid_y = (positions[:, 1].max() + positions[:, 1].min()) * 0.5
            mid_z = (positions[:, 2].max() + positions[:, 2].min()) * 0.5
            
            # Set limits
            self.ax_3d.set_xlim(mid_x - max_range, mid_x + max_range)
            self.ax_3d.set_ylim(mid_y - max_range, mid_y + max_range)
            self.ax_3d.set_zlim(mid_z - max_range, mid_z + max_range)
    
    def toggle_animation(self, event):
        """Toggle animation playback."""
        if not self.is_playing:
            self.start_animation()
        else:
            self.stop_animation()
    
    def start_animation(self):
        """Start animation playback."""
        if self.mocap_data is None:
            return
        
        self.is_playing = True
        self.play_button.label.set_text('Pause')
        
        def animate(frame):
            if not self.is_playing:
                return
            
            self.time_slider.set_val(frame)
            return []
        
        frames = len(self.mocap_data['hand_trajectory'])
        self.animation = animation.FuncAnimation(
            self.fig, animate, frames=frames, interval=50, repeat=True
        )
    
    def stop_animation(self):
        """Stop animation playback."""
        self.is_playing = False
        self.play_button.label.set_text('Play')
        
        if self.animation:
            self.animation.event_source.stop()
    
    def reset_view(self, event):
        """Reset the view to initial state."""
        self.stop_animation()
        self.time_slider.reset()
        self.update_visualization(0)
    
    def update_display_options(self, label):
        """Update display options when checkboxes are clicked."""
        self.update_visualization()
    
    def show(self):
        """Show the interactive visualization."""
        plt.show()


class MotionMatchingSystem:
    """
    Main system that coordinates motion capture loading, neural network training,
    and visualization for golf swing motion matching.
    """
    
    def __init__(self, data_directory='.', results_directory='motion_matching_results'):
        self.data_directory = data_directory
        self.results_directory = results_directory
        
        # Create results directory
        os.makedirs(results_directory, exist_ok=True)
        
        # Initialize components
        self.mocap_loader = MotionCaptureLoader()
        self.sim_processor = SimulationDataProcessor(data_directory)
        self.visualizer = MotionMatchingVisualizer()
        
        # Data containers
        self.mocap_data = None
        self.sim_data = None
        self.trained_model = None
        self.scalers = {}
        
        print(f"Motion Matching System initialized")
        print(f"Data directory: {data_directory}")
        print(f"Results directory: {results_directory}")
    
    def load_motion_capture_data(self, wiffle_file_path):
        """Load motion capture data from Wiffle Excel file."""
        print(f"\n{'='*60}")
        print("LOADING MOTION CAPTURE DATA")
        print(f"{'='*60}")
        
        self.mocap_data = self.mocap_loader.load_wiffle_data(wiffle_file_path)
        
        if self.mocap_data is None:
            raise ValueError("Failed to load motion capture data")
        
        # Load data into visualizer
        self.visualizer.load_motion_capture_data(self.mocap_data)
        
        return self.mocap_data
    
    def load_simulation_data(self):
        """Load simulation trial data for training."""
        print(f"\n{'='*60}")
        print("LOADING SIMULATION DATA")
        print(f"{'='*60}")
        
        # Load trial data
        trial_df = self.sim_processor.load_trial_data()
        
        # Extract training data
        trajectory_features, coefficients, metadata = self.sim_processor.extract_training_data(trial_df)
        
        self.sim_data = {
            'trajectory_features': trajectory_features,
            'coefficients': coefficients,
            'metadata': metadata,
            'raw_data': trial_df
        }
        
        return self.sim_data
    
    def train_neural_network(self, epochs=200, batch_size=32, learning_rate=0.001):
        """Train the neural network for motion matching."""
        print(f"\n{'='*60}")
        print("TRAINING NEURAL NETWORK")
        print(f"{'='*60}")
        
        if self.sim_data is None:
            raise ValueError("No simulation data loaded. Call load_simulation_data() first.")
        
        X = self.sim_data['trajectory_features']
        y = self.sim_data['coefficients']
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        X_train, X_val, y_train, y_val = train_test_split(
            X_train, y_train, test_size=0.2, random_state=42
        )
        
        print(f"Training samples: {len(X_train)}")
        print(f"Validation samples: {len(X_val)}")
        print(f"Test samples: {len(X_test)}")
        
        # Scale data
        scaler_input = StandardScaler()
        scaler_output = StandardScaler()
        
        X_train_scaled = scaler_input.fit_transform(X_train)
        X_val_scaled = scaler_input.transform(X_val)
        X_test_scaled = scaler_input.transform(X_test)
        
        y_train_scaled = scaler_output.fit_transform(y_train)
        y_val_scaled = scaler_output.transform(y_val)
        y_test_scaled = scaler_output.transform(y_test)
        
        # Create datasets
        train_dataset = GolfSwingDataset(X_train_scaled, y_train_scaled)
        val_dataset = GolfSwingDataset(X_val_scaled, y_val_scaled)
        test_dataset = GolfSwingDataset(X_test_scaled, y_test_scaled)
        
        # Create data loaders
        train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
        val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)
        test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False)
        
        # Initialize model
        model = TrajectoryEncoder(
            trajectory_dim=X_train_scaled.shape[1],
            coefficient_dim=y_train_scaled.shape[1],
            hidden_dims=[512, 256, 128],
            dropout_rate=0.3,
            use_attention=True
        ).to(device)
        
        # Training setup
        optimizer = optim.Adam(model.parameters(), lr=learning_rate, weight_decay=1e-5)
        scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, patience=10, factor=0.5)
        criterion = nn.MSELoss()
        
        # Training loop
        train_losses = []
        val_losses = []
        best_val_loss = float('inf')
        patience_counter = 0
        patience = 20
        
        print(f"\nTraining model with {sum(p.numel() for p in model.parameters()):,} parameters")
        
        for epoch in range(epochs):
            # Training phase
            model.train()
            train_loss = 0.0
            
            for batch_trajectories, batch_coeffs in train_loader:
                batch_trajectories = batch_trajectories.to(device)
                batch_coeffs = batch_coeffs.to(device)
                
                optimizer.zero_grad()
                predicted_coeffs = model(batch_trajectories)
                loss = criterion(predicted_coeffs, batch_coeffs)
                loss.backward()
                
                # Gradient clipping
                torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
                
                optimizer.step()
                train_loss += loss.item()
            
            train_loss /= len(train_loader)
            
            # Validation phase
            model.eval()
            val_loss = 0.0
            
            with torch.no_grad():
                for batch_trajectories, batch_coeffs in val_loader:
                    batch_trajectories = batch_trajectories.to(device)
                    batch_coeffs = batch_coeffs.to(device)
                    
                    predicted_coeffs = model(batch_trajectories)
                    loss = criterion(predicted_coeffs, batch_coeffs)
                    val_loss += loss.item()
            
            val_loss /= len(val_loader)
            
            # Learning rate scheduling
            scheduler.step(val_loss)
            
            # Record losses
            train_losses.append(train_loss)
            val_losses.append(val_loss)
            
            # Early stopping
            if val_loss < best_val_loss:
                best_val_loss = val_loss
                patience_counter = 0
                # Save best model
                torch.save(model.state_dict(), os.path.join(self.results_directory, 'best_model.pth'))
            else:
                patience_counter += 1
            
            # Print progress
            if (epoch + 1) % 10 == 0 or epoch == 0:
                current_lr = optimizer.param_groups[0]['lr']
                print(f"Epoch [{epoch+1}/{epochs}] - "
                      f"Train Loss: {train_loss:.6f}, "
                      f"Val Loss: {val_loss:.6f}, "
                      f"LR: {current_lr:.2e}")
            
            # Early stopping
            if patience_counter >= patience:
                print(f"Early stopping at epoch {epoch+1}")
                break
        
        # Load best model
        model.load_state_dict(torch.load(os.path.join(self.results_directory, 'best_model.pth')))
        
        # Evaluate on test set
        model.eval()
        test_predictions = []
        test_targets = []
        
        with torch.no_grad():
            for batch_trajectories, batch_coeffs in test_loader:
                batch_trajectories = batch_trajectories.to(device)
                predicted_coeffs = model(batch_trajectories)
                
                test_predictions.append(predicted_coeffs.cpu().numpy())
                test_targets.append(batch_coeffs.numpy())
        
        test_predictions = np.concatenate(test_predictions, axis=0)
        test_targets = np.concatenate(test_targets, axis=0)
        
        # Inverse transform predictions
        test_predictions_orig = scaler_output.inverse_transform(test_predictions)
        test_targets_orig = scaler_output.inverse_transform(test_targets)
        
        # Calculate metrics
        test_mse = mean_squared_error(test_targets_orig, test_predictions_orig)
        test_r2 = r2_score(test_targets_orig, test_predictions_orig)
        
        print(f"\nTraining completed!")
        print(f"Best validation loss: {best_val_loss:.6f}")
        print(f"Test MSE: {test_mse:.6f}")
        print(f"Test R²: {test_r2:.4f}")
        
        # Save model and scalers
        torch.save(model.state_dict(), os.path.join(self.results_directory, 'final_model.pth'))
        joblib.dump(scaler_input, os.path.join(self.results_directory, 'scaler_input.pkl'))
        joblib.dump(scaler_output, os.path.join(self.results_directory, 'scaler_output.pkl'))
        
        # Save metadata
        training_metadata = {
            'model_architecture': 'TrajectoryEncoder',
            'epochs_trained': len(train_losses),
            'best_val_loss': float(best_val_loss),
            'test_mse': float(test_mse),
            'test_r2': float(test_r2),
            'trajectory_dim': X_train_scaled.shape[1],
            'coefficient_dim': y_train_scaled.shape[1],
            'training_samples': len(X_train),
            'validation_samples': len(X_val),
            'test_samples': len(X_test),
            'joint_names': self.sim_data['metadata']['joint_names'],
            'training_completed': datetime.now().isoformat()
        }
        
        with open(os.path.join(self.results_directory, 'training_metadata.json'), 'w') as f:
            json.dump(training_metadata, f, indent=2)
        
        # Store trained model and scalers
        self.trained_model = model
        self.scalers = {
            'input': scaler_input,
            'output': scaler_output
        }
        
        # Plot training results
        self.plot_training_results(train_losses, val_losses, test_targets_orig, test_predictions_orig)
        
        return {
            'model': model,
            'train_losses': train_losses,
            'val_losses': val_losses,
            'test_mse': test_mse,
            'test_r2': test_r2,
            'metadata': training_metadata
        }
    
    def predict_coefficients_for_mocap(self):
        """Predict polynomial coefficients for the loaded motion capture data."""
        print(f"\n{'='*60}")
        print("PREDICTING COEFFICIENTS FOR MOTION CAPTURE")
        print(f"{'='*60}")
        
        if self.trained_model is None:
            raise ValueError("No trained model available. Train the model first.")
        
        if self.mocap_data is None:
            raise ValueError("No motion capture data loaded.")
        
        # Extract trajectory features from motion capture data
        hand_trajectory = self.mocap_data['hand_trajectory']
        time_vector = self.mocap_data['time_vector']
        
        # Compute velocity
        dt = np.mean(np.diff(time_vector)) if len(time_vector) > 1 else 0.01
        velocity = np.gradient(hand_trajectory, dt, axis=0)
        
        # Create trajectory dictionary
        trajectory = {
            'position': hand_trajectory,
            'velocity': velocity,
            'time': time_vector
        }
        
        # Extract features using the same method as training
        features = self.sim_processor._extract_trajectory_features(trajectory)
        
        # Scale features
        features_scaled = self.scalers['input'].transform(features.reshape(1, -1))
        
        # Predict coefficients
        self.trained_model.eval()
        with torch.no_grad():
            features_tensor = torch.FloatTensor(features_scaled).to(device)
            coeffs_scaled = self.trained_model(features_tensor)
            coeffs = self.scalers['output'].inverse_transform(coeffs_scaled.cpu().numpy())[0]
        
        # Organize coefficients by joint
        joint_names = self.sim_data['metadata']['joint_names']
        coefficient_names = ['A', 'B', 'C', 'D', 'E', 'F', 'G']
        
        predicted_coefficients = {}
        coeff_idx = 0
        
        for joint_name in joint_names:
            predicted_coefficients[joint_name] = {}
            for coeff_name in coefficient_names:
                if coeff_idx < len(coeffs):
                    predicted_coefficients[joint_name][coeff_name] = float(coeffs[coeff_idx])
                    coeff_idx += 1
        
        # Save predicted coefficients
        with open(os.path.join(self.results_directory, 'predicted_coefficients.json'), 'w') as f:
            json.dump(predicted_coefficients, f, indent=2)
        
        # Generate MATLAB coefficient file
        self.generate_matlab_coefficient_file(predicted_coefficients)
        
        print(f"Predicted coefficients for {len(joint_names)} joints")
        print(f"Coefficients saved to: {self.results_directory}")
        
        return predicted_coefficients
    
    def generate_matlab_coefficient_file(self, coefficients):
        """Generate MATLAB-compatible coefficient file."""
        matlab_file = os.path.join(self.results_directory, 'predicted_coefficients.m')
        
        with open(matlab_file, 'w') as f:
            f.write("% Auto-generated polynomial coefficients for golf swing simulation\n")
            f.write(f"% Generated by Motion Matching System: {datetime.now().isoformat()}\n")
            f.write("% Format: input_Joint_Coefficient = value;\n\n")
            
            for joint_name in coefficients:
                f.write(f"% {joint_name} coefficients\n")
                for coeff_name in ['A', 'B', 'C', 'D', 'E', 'F', 'G']:
                    if coeff_name in coefficients[joint_name]:
                        value = coefficients[joint_name][coeff_name]
                        f.write(f"input_{joint_name}_{coeff_name} = {value:.8f};\n")
                f.write("\n")
        
        print(f"MATLAB coefficient file saved: {matlab_file}")
    
    def plot_training_results(self, train_losses, val_losses, y_test, y_pred):
        """Plot training results and model performance."""
        fig, axes = plt.subplots(2, 2, figsize=(15, 10))
        
        # Training curves
        axes[0, 0].plot(train_losses, label='Training Loss', color='blue', alpha=0.7)
        axes[0, 0].plot(val_losses, label='Validation Loss', color='red', alpha=0.7)
        axes[0, 0].set_title('Training Progress', fontweight='bold')
        axes[0, 0].set_xlabel('Epoch')
        axes[0, 0].set_ylabel('Loss')
        axes[0, 0].legend()
        axes[0, 0].grid(True, alpha=0.3)
        
        # Prediction vs actual scatter plot
        axes[0, 1].scatter(y_test.flatten(), y_pred.flatten(), alpha=0.5, s=10)
        axes[0, 1].plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2)
        axes[0, 1].set_xlabel('Actual Coefficients')
        axes[0, 1].set_ylabel('Predicted Coefficients')
        axes[0, 1].set_title('Prediction Accuracy', fontweight='bold')
        axes[0, 1].grid(True, alpha=0.3)
        
        # Error distribution
        errors = np.abs(y_test - y_pred)
        axes[1, 0].hist(errors.flatten(), bins=50, alpha=0.7, color='green')
        axes[1, 0].set_xlabel('Absolute Error')
        axes[1, 0].set_ylabel('Frequency')
        axes[1, 0].set_title('Error Distribution', fontweight='bold')
        axes[1, 0].grid(True, alpha=0.3)
        
        # R² scores by coefficient
        r2_scores = []
        for i in range(min(y_test.shape[1], 50)):  # Limit to first 50 coefficients
            if np.var(y_test[:, i]) > 1e-8:
                r2 = r2_score(y_test[:, i], y_pred[:, i])
                r2_scores.append(r2)
        
        if r2_scores:
            axes[1, 1].plot(r2_scores, 'o-', markersize=4)
            axes[1, 1].set_xlabel('Coefficient Index')
            axes[1, 1].set_ylabel('R² Score')
            axes[1, 1].set_title('R² by Coefficient', fontweight='bold')
            axes[1, 1].grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(os.path.join(self.results_directory, 'training_results.png'), 
                   dpi=300, bbox_inches='tight')
        plt.show()
    
    def run_interactive_visualization(self):
        """Run the interactive 3D visualization."""
        print(f"\n{'='*60}")
        print("STARTING INTERACTIVE VISUALIZATION")
        print(f"{'='*60}")
        
        if self.mocap_data is None:
            print("No motion capture data loaded. Please load data first.")
            return
        
        # Update visualization with current frame
        self.visualizer.update_visualization(0)
        
        print("Interactive visualization ready!")
        print("Controls:")
        print("- Use the time slider to scrub through the motion")
        print("- Click 'Play' to animate the motion")
        print("- Use checkboxes to toggle display options")
        print("- Click 'Reset' to return to the beginning")
        
        # Show the visualization
        self.visualizer.show()
    
    def run_complete_workflow(self, wiffle_file_path):
        """Run the complete motion matching workflow."""
        print("="*80)
        print("GOLF SWING MOTION MATCHING SYSTEM")
        print("="*80)
        
        try:
            # Step 1: Load motion capture data
            self.load_motion_capture_data(wiffle_file_path)
            
            # Step 2: Load simulation data
            self.load_simulation_data()
            
            # Step 3: Train neural network
            training_results = self.train_neural_network()
            
            # Step 4: Predict coefficients for motion capture
            predicted_coefficients = self.predict_coefficients_for_mocap()
            
            # Step 5: Run interactive visualization
            self.run_interactive_visualization()
            
            print("\n" + "="*80)
            print("WORKFLOW COMPLETED SUCCESSFULLY!")
            print("="*80)
            print(f"Results saved in: {self.results_directory}")
            print(f"MATLAB coefficients: {self.results_directory}/predicted_coefficients.m")
            print(f"Training metadata: {self.results_directory}/training_metadata.json")
            
            return {
                'training_results': training_results,
                'predicted_coefficients': predicted_coefficients,
                'mocap_data': self.mocap_data,
                'results_directory': self.results_directory
            }
            
        except Exception as e:
            print(f"\nWorkflow failed with error: {e}")
            import traceback
            traceback.print_exc()
            return None


def main():
    """Main entry point for the motion matching system."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Golf Swing Motion Matching System')
    parser.add_argument('--wiffle-file', required=True, 
                       help='Path to Wiffle Excel file containing motion capture data')
    parser.add_argument('--data-dir', default='.', 
                       help='Directory containing trial CSV files')
    parser.add_argument('--results-dir', default='motion_matching_results', 
                       help='Output directory for results')
    parser.add_argument('--epochs', type=int, default=200, 
                       help='Training epochs')
    parser.add_argument('--batch-size', type=int, default=32, 
                       help='Batch size for training')
    parser.add_argument('--learning-rate', type=float, default=0.001, 
                       help='Learning rate for training')
    
    args = parser.parse_args()
    
    # Initialize the system
    system = MotionMatchingSystem(
        data_directory=args.data_dir,
        results_directory=args.results_dir
    )
    
    # Run the complete workflow
    results = system.run_complete_workflow(args.wiffle_file)
    
    if results:
        print(f"\nMotion matching completed successfully!")
        print(f"Check {args.results_dir} for all generated files.")
    else:
        print(f"\nMotion matching failed. Check error messages above.")


if __name__ == "__main__":
    # Example usage for demonstration
    print("Golf Swing PyTorch Motion Matching System")
    print("=" * 50)
    
    # For demonstration purposes, create example usage
    try:
        # Initialize system
        system = MotionMatchingSystem(
            data_directory='.',
            results_directory='motion_matching_results'
        )
        
        # Check if required files exist
        wiffle_file = 'Wiffle_ProV1_club_3D_data.xlsx'
        if os.path.exists(wiffle_file):
            print(f"Found Wiffle file: {wiffle_file}")
            print("Run with: python script.py --wiffle-file Wiffle_ProV1_club_3D_data.xlsx")
        else:
            print(f"Wiffle file not found: {wiffle_file}")
            print("Please provide the path to your motion capture Excel file")
        
        # Check for trial data
        trial_files = glob.glob('trial_*.csv')
        if trial_files:
            print(f"Found {len(trial_files)} trial CSV files")
        else:
            print("No trial CSV files found in current directory")
            
        print("\nTo run the complete system:")
        print("python script.py --wiffle-file your_motion_capture_file.xlsx")
        
    except Exception as e:
        print(f"Error in demonstration: {e}")
