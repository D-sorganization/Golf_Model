#!/usr/bin/env python3
"""
Enhanced Golf Swing PyTorch Motion Matching System
==================================================

This system matches polynomial coefficients to motion capture data using PyTorch optimization,
handling joint redundancy and providing comprehensive 3D visualization.

Key features:
- Loads motion capture data from Wiffle Excel files (mid-hands and club face)
- Optimization-based coefficient matching for hand midpoint trajectory
- Joint redundancy handling with specified/solved joint separation
- Real-time 3D skeleton visualization with motion comparison
- MATLAB-compatible coefficient output

Author: Enhanced for Golf Swing Simulation Project
Date: 2025
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.animation as animation
from matplotlib.widgets import Slider, Button, CheckButtons
import torch
import torch.nn as nn
import torch.optim as optim
from scipy import interpolate, optimize
from scipy.spatial.transform import Rotation as R
import os
import json
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

# Set random seeds
np.random.seed(42)
torch.manual_seed(42)

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")


class WiffleDataLoader:
    """
    Loads motion capture data from Wiffle Excel files.
    Handles the specific format with mid-hands and club face data.
    """
    
    def __init__(self):
        self.time_data = None
        self.midhand_positions = None
        self.midhand_orientations = None
        self.clubface_positions = None
        self.clubface_orientations = None
        
    def load_wiffle_excel(self, filepath, sheet_name=None):
        """
        Load Wiffle motion capture data from Excel file.
        
        Args:
            filepath (str): Path to Excel file
            sheet_name (str): Sheet name to load (default: auto-detect)
            
        Returns:
            dict: Processed motion capture data
        """
        print(f"\nLoading Wiffle data from: {filepath}")
        
        # Read Excel file
        excel_file = pd.ExcelFile(filepath)
        
        # Auto-detect sheet if not specified
        if sheet_name is None:
            # Look for sheets with ProV1 or similar
            for name in excel_file.sheet_names:
                if 'ProV1' in name or 'wiffle' in name.lower():
                    sheet_name = name
                    break
            if sheet_name is None:
                sheet_name = excel_file.sheet_names[0]
        
        print(f"Loading sheet: {sheet_name}")
        df = pd.read_excel(filepath, sheet_name=sheet_name, header=None)
        
        # Find data start row (where numeric data begins)
        data_start_row = None
        for i in range(min(20, len(df))):
            # Count numeric values in row
            numeric_count = df.iloc[i].apply(lambda x: isinstance(x, (int, float))).sum()
            if numeric_count > 10:  # Threshold for data row
                data_start_row = i
                break
        
        if data_start_row is None:
            raise ValueError("Could not find numeric data in Excel file")
        
        print(f"Data starts at row {data_start_row}")
        
        # Extract data
        data_df = df.iloc[data_start_row:].reset_index(drop=True)
        
        # Extract time (column 1)
        self.time_data = data_df.iloc[:, 1].values.astype(float)
        
        # Extract mid-hands data (columns 2-13)
        # Position: columns 2-4 (X, Y, Z)
        self.midhand_positions = data_df.iloc[:, 2:5].values.astype(float)
        
        # Orientation matrix: columns 5-13 (Xx, Xy, Xz, Yx, Yy, Yz, Zx, Zy, Zz)
        orientation_data = data_df.iloc[:, 5:14].values.astype(float)
        self.midhand_orientations = orientation_data.reshape(-1, 3, 3)
        
        # Extract club face data (columns 14-25)
        # Position: columns 14-16 (X, Y, Z)
        self.clubface_positions = data_df.iloc[:, 14:17].values.astype(float)
        
        # Orientation matrix: columns 17-25
        if data_df.shape[1] >= 26:
            club_orientation_data = data_df.iloc[:, 17:26].values.astype(float)
            self.clubface_orientations = club_orientation_data.reshape(-1, 3, 3)
        
        # Convert units from cm to meters (assuming data is in cm based on values)
        self.midhand_positions /= 100.0
        self.clubface_positions /= 100.0
        
        # Normalize time to start at 0
        self.time_data -= self.time_data[0]
        
        print(f"Loaded {len(self.time_data)} time points")
        print(f"Time range: {self.time_data[0]:.3f} to {self.time_data[-1]:.3f} seconds")
        print(f"Mid-hand position range: X[{self.midhand_positions[:, 0].min():.3f}, {self.midhand_positions[:, 0].max():.3f}]")
        
        return {
            'time': self.time_data,
            'midhand_positions': self.midhand_positions,
            'midhand_orientations': self.midhand_orientations,
            'clubface_positions': self.clubface_positions,
            'clubface_orientations': self.clubface_orientations
        }


class GolfSwingKinematics:
    """
    Forward kinematics model for the golf swing.
    Maps joint angles to global positions of all body segments.
    """
    
    def __init__(self):
        # Segment lengths (in meters)
        self.segments = {
            'hip_height': 1.0,
            'torso_length': 0.5,
            'shoulder_width': 0.4,
            'upper_arm': 0.3,
            'forearm': 0.25,
            'hand': 0.1,
            'club_length': 1.0
        }
        
        # Joint mapping to coefficient names
        self.joint_mapping = {
            'hip_translation': ['TranslationX', 'TranslationY', 'TranslationZ'],
            'hip_rotation': ['HipX', 'HipY', 'HipZ'],
            'spine': ['SpineX', 'SpineY'],
            'torso': ['Torso'],
            'left_shoulder': ['LScapX', 'LScapY', 'LSX', 'LSY', 'LSZ'],
            'right_shoulder': ['RScapX', 'RScapY', 'RSX', 'RSY', 'RSZ'],
            'left_elbow': ['LE'],
            'right_elbow': ['RE'],
            'left_forearm': ['LF'],
            'right_forearm': ['RF'],
            'left_wrist': ['LWX', 'LWY'],
            'right_wrist': ['RWX', 'RWY']
        }
        
    def compute_positions(self, joint_angles, time_idx=None):
        """
        Compute global positions of all joints given joint angles.
        
        Args:
            joint_angles (dict): Dictionary of joint angles
            time_idx (int): Time index for time-varying values
            
        Returns:
            dict: Global positions of all joints and segments
        """
        positions = {}
        orientations = {}
        
        # Get angle value at time index
        def get_angle(joint_name, idx=time_idx):
            if joint_name in joint_angles:
                val = joint_angles[joint_name]
                if isinstance(val, np.ndarray) and idx is not None:
                    return val[idx] if idx < len(val) else val[-1]
                return val
            return 0.0
        
        # Hip position (translation)
        hip_x = get_angle('TranslationX')
        hip_y = get_angle('TranslationY') 
        hip_z = get_angle('TranslationZ') + self.segments['hip_height']
        positions['hip'] = np.array([hip_x, hip_y, hip_z])
        
        # Hip orientation
        R_hip = self._euler_to_matrix(get_angle('HipX'), get_angle('HipY'), get_angle('HipZ'))
        orientations['hip'] = R_hip
        
        # Spine (lower torso)
        R_spine = self._euler_to_matrix(get_angle('SpineX'), get_angle('SpineY'), 0)
        orientations['spine'] = R_hip @ R_spine
        positions['spine'] = positions['hip'] + orientations['hip'] @ np.array([0, 0, self.segments['torso_length']/2])
        
        # Upper torso
        R_torso = self._euler_to_matrix(0, 0, get_angle('Torso'))
        orientations['torso'] = orientations['spine'] @ R_torso
        positions['torso'] = positions['spine'] + orientations['spine'] @ np.array([0, 0, self.segments['torso_length']/2])
        
        # Shoulders
        positions['left_shoulder'] = positions['torso'] + orientations['torso'] @ np.array([-self.segments['shoulder_width']/2, 0, 0])
        positions['right_shoulder'] = positions['torso'] + orientations['torso'] @ np.array([self.segments['shoulder_width']/2, 0, 0])
        
        # Left arm chain
        R_lscap = self._euler_to_matrix(get_angle('LScapX'), get_angle('LScapY'), 0)
        R_ls = self._euler_to_matrix(get_angle('LSX'), get_angle('LSY'), get_angle('LSZ'))
        orientations['left_shoulder'] = orientations['torso'] @ R_lscap @ R_ls
        
        # Left elbow
        positions['left_elbow'] = positions['left_shoulder'] + orientations['left_shoulder'] @ np.array([0, -self.segments['upper_arm'], 0])
        R_le = self._euler_to_matrix(0, 0, get_angle('LE'))
        orientations['left_elbow'] = orientations['left_shoulder'] @ R_le
        
        # Left wrist
        R_lf = self._euler_to_matrix(0, 0, get_angle('LF'))
        orientations['left_forearm'] = orientations['left_elbow'] @ R_lf
        positions['left_wrist'] = positions['left_elbow'] + orientations['left_forearm'] @ np.array([0, -self.segments['forearm'], 0])
        
        # Left hand
        R_lw = self._euler_to_matrix(get_angle('LWX'), get_angle('LWY'), 0)
        orientations['left_hand'] = orientations['left_forearm'] @ R_lw
        positions['left_hand'] = positions['left_wrist'] + orientations['left_hand'] @ np.array([0, -self.segments['hand'], 0])
        
        # Right arm chain (similar to left)
        R_rscap = self._euler_to_matrix(get_angle('RScapX'), get_angle('RScapY'), 0)
        R_rs = self._euler_to_matrix(get_angle('RSX'), get_angle('RSY'), get_angle('RSZ'))
        orientations['right_shoulder'] = orientations['torso'] @ R_rscap @ R_rs
        
        positions['right_elbow'] = positions['right_shoulder'] + orientations['right_shoulder'] @ np.array([0, -self.segments['upper_arm'], 0])
        R_re = self._euler_to_matrix(0, 0, get_angle('RE'))
        orientations['right_elbow'] = orientations['right_shoulder'] @ R_re
        
        R_rf = self._euler_to_matrix(0, 0, get_angle('RF'))
        orientations['right_forearm'] = orientations['right_elbow'] @ R_rf
        positions['right_wrist'] = positions['right_elbow'] + orientations['right_forearm'] @ np.array([0, -self.segments['forearm'], 0])
        
        R_rw = self._euler_to_matrix(get_angle('RWX'), get_angle('RWY'), 0)
        orientations['right_hand'] = orientations['right_forearm'] @ R_rw
        positions['right_hand'] = positions['right_wrist'] + orientations['right_hand'] @ np.array([0, -self.segments['hand'], 0])
        
        # Club (midpoint between hands)
        positions['club_grip'] = (positions['left_hand'] + positions['right_hand']) / 2.0
        
        # Club head (simplified - pointing down from grip)
        club_direction = np.array([0, -0.7, -0.7])  # Angled down and forward
        club_direction = club_direction / np.linalg.norm(club_direction)
        positions['club_head'] = positions['club_grip'] + self.segments['club_length'] * club_direction
        
        # Hand midpoint (for matching)
        positions['hand_midpoint'] = (positions['left_hand'] + positions['right_hand']) / 2.0
        
        return positions, orientations
    
    def _euler_to_matrix(self, rx, ry, rz):
        """Convert Euler angles to rotation matrix."""
        # Convert degrees to radians if needed
        if abs(rx) > 2*np.pi or abs(ry) > 2*np.pi or abs(rz) > 2*np.pi:
            rx, ry, rz = np.deg2rad([rx, ry, rz])
        
        return R.from_euler('xyz', [rx, ry, rz]).as_matrix()


class PolynomialCoefficientOptimizer:
    """
    Optimizes polynomial coefficients to match target hand trajectory.
    Handles joint redundancy by specifying some joints and solving for others.
    """
    
    def __init__(self, kinematics_model, specified_joints, time_duration=1.0):
        """
        Initialize optimizer.
        
        Args:
            kinematics_model: Forward kinematics model
            specified_joints: List of joint names to optimize directly
            time_duration: Duration of motion in seconds
        """
        self.kinematics = kinematics_model
        self.specified_joints = specified_joints
        self.time_duration = time_duration
        self.n_coeffs = 7  # A through G
        
        # All available joints
        self.all_joints = ['HipX', 'HipY', 'HipZ', 'SpineX', 'SpineY', 'Torso',
                          'LScapX', 'LScapY', 'LSX', 'LSY', 'LSZ', 'LE', 'LF', 'LWX', 'LWY',
                          'RScapX', 'RScapY', 'RSX', 'RSY', 'RSZ', 'RE', 'RF', 'RWX', 'RWY',
                          'TranslationX', 'TranslationY', 'TranslationZ']
        
    def optimize(self, target_trajectory, initial_coeffs=None, n_iterations=500, lr=0.01):
        """
        Optimize polynomial coefficients to match target trajectory.
        
        Args:
            target_trajectory (np.array): Target hand midpoint positions [n_time, 3]
            initial_coeffs (dict): Initial coefficient values
            n_iterations (int): Number of optimization iterations
            lr (float): Learning rate
            
        Returns:
            dict: Optimized polynomial coefficients
        """
        n_time = len(target_trajectory)
        time_vec = np.linspace(0, self.time_duration, n_time)
        
        # Initialize coefficients as torch parameters
        coeffs_params = {}
        for joint in self.specified_joints:
            if initial_coeffs and joint in initial_coeffs:
                init_vals = np.array([initial_coeffs[joint].get(c, 0) for c in 'ABCDEFG'])
                coeffs_params[joint] = torch.nn.Parameter(torch.tensor(init_vals, dtype=torch.float32))
            else:
                coeffs_params[joint] = torch.nn.Parameter(torch.randn(self.n_coeffs) * 0.1)
        
        # Create parameter list for optimizer
        parameters = list(coeffs_params.values())
        optimizer = torch.optim.Adam(parameters, lr=lr)
        
        target_tensor = torch.tensor(target_trajectory, dtype=torch.float32)
        
        losses = []
        print("\nOptimizing polynomial coefficients...")
        
        for iteration in range(n_iterations):
            optimizer.zero_grad()
            
            # Compute joint angles from polynomials
            joint_angles = {}
            for joint, params in coeffs_params.items():
                # Evaluate polynomial at all time points
                angles = torch.zeros(n_time)
                for i, coeff in enumerate(params):
                    angles += coeff * torch.tensor(time_vec ** i, dtype=torch.float32)
                joint_angles[joint] = angles.detach().numpy()
            
            # Add zero values for unspecified joints
            for joint in self.all_joints:
                if joint not in joint_angles:
                    joint_angles[joint] = np.zeros(n_time)
            
            # Compute hand positions through forward kinematics
            hand_positions = []
            for t in range(n_time):
                positions, _ = self.kinematics.compute_positions(joint_angles, time_idx=t)
                hand_positions.append(positions['hand_midpoint'])
            
            hand_positions = torch.tensor(np.array(hand_positions), dtype=torch.float32)
            
            # Position matching loss
            position_loss = torch.mean((hand_positions - target_tensor) ** 2)
            
            # Smoothness regularization (minimize acceleration)
            smooth_loss = 0
            for joint, params in coeffs_params.items():
                # Second derivative coefficients
                accel_coeffs = torch.zeros_like(params)
                for i in range(2, self.n_coeffs):
                    accel_coeffs[i-2] = params[i] * i * (i-1)
                smooth_loss += torch.sum(accel_coeffs ** 2)
            
            # Total loss
            total_loss = position_loss + 0.001 * smooth_loss
            
            # Backward pass
            total_loss.backward()
            optimizer.step()
            
            losses.append(total_loss.item())
            
            if iteration % 50 == 0:
                print(f"  Iteration {iteration}: Loss = {total_loss.item():.6f}, Position Error = {position_loss.item():.6f}")
        
        # Extract final coefficients
        final_coeffs = {}
        coeff_names = ['A', 'B', 'C', 'D', 'E', 'F', 'G']
        
        for joint, params in coeffs_params.items():
            final_coeffs[joint] = {}
            for i, name in enumerate(coeff_names):
                final_coeffs[joint][name] = float(params[i].detach().numpy())
        
        # Add zero coefficients for unspecified joints
        for joint in self.all_joints:
            if joint not in final_coeffs:
                final_coeffs[joint] = {name: 0.0 for name in coeff_names}
        
        return final_coeffs, losses


class GolfSwingVisualizer:
    """
    Enhanced 3D visualization system for golf swing analysis.
    """
    
    def __init__(self, figsize=(20, 12)):
        self.fig = plt.figure(figsize=figsize)
        self.setup_layout()
        
        # Data containers
        self.mocap_data = None
        self.sim_positions = None
        self.coefficients = None
        self.kinematics_model = GolfSwingKinematics()
        
        # Animation state
        self.is_playing = False
        self.current_frame = 0
        self.animation = None
        
    def setup_layout(self):
        """Setup the visualization layout."""
        gs = self.fig.add_gridspec(3, 3, height_ratios=[2, 1, 1])
        
        # Main 3D view
        self.ax_3d = self.fig.add_subplot(gs[0:2, 0:2], projection='3d')
        self.ax_3d.set_title('3D Golf Swing Visualization', fontsize=14, fontweight='bold')
        
        # Trajectory comparison
        self.ax_traj = self.fig.add_subplot(gs[0, 2])
        self.ax_traj.set_title('Hand Trajectory Comparison', fontweight='bold')
        self.ax_traj.grid(True, alpha=0.3)
        
        # Club path
        self.ax_club = self.fig.add_subplot(gs[1, 2])
        self.ax_club.set_title('Club Head Path', fontweight='bold')
        self.ax_club.grid(True, alpha=0.3)
        
        # Error plot
        self.ax_error = self.fig.add_subplot(gs[2, :])
        self.ax_error.set_title('Position Matching Error', fontweight='bold')
        self.ax_error.grid(True, alpha=0.3)
        
        # Controls
        self.setup_controls()
        
        plt.tight_layout()
        
    def setup_controls(self):
        """Setup interactive controls."""
        # Time slider
        slider_ax = plt.axes([0.1, 0.02, 0.5, 0.03])
        self.time_slider = Slider(slider_ax, 'Time', 0, 100, valinit=0, valstep=1)
        self.time_slider.on_changed(self.update_frame)
        
        # Buttons
        play_ax = plt.axes([0.65, 0.02, 0.08, 0.04])
        self.play_button = Button(play_ax, '▶ Play', color='lightgreen')
        self.play_button.on_clicked(self.toggle_animation)
        
        reset_ax = plt.axes([0.74, 0.02, 0.08, 0.04])
        self.reset_button = Button(reset_ax, '↺ Reset', color='lightcoral')
        self.reset_button.on_clicked(self.reset_animation)
        
        # Display options
        options_ax = plt.axes([0.84, 0.01, 0.15, 0.05])
        self.options = CheckButtons(options_ax, ['Skeleton', 'Trajectories'], [True, True])
        self.options.on_clicked(self.update_frame)
        
    def load_motion_capture(self, mocap_data):
        """Load motion capture data."""
        self.mocap_data = mocap_data
        n_frames = len(mocap_data['time'])
        self.time_slider.valmax = n_frames - 1
        self.time_slider.ax.set_xlim(0, n_frames - 1)
        print(f"Loaded motion capture with {n_frames} frames")
        
    def load_coefficients(self, coefficients):
        """Load polynomial coefficients and compute resulting motion."""
        self.coefficients = coefficients
        
        # Compute motion from coefficients
        time_vec = self.mocap_data['time']
        n_frames = len(time_vec)
        
        # Evaluate polynomials
        joint_angles = {}
        for joint, coeffs_dict in coefficients.items():
            angles = np.zeros(n_frames)
            for i, coeff_name in enumerate(['A', 'B', 'C', 'D', 'E', 'F', 'G']):
                if coeff_name in coeffs_dict:
                    angles += coeffs_dict[coeff_name] * (time_vec ** i)
            joint_angles[joint] = angles
        
        # Compute positions for each frame
        self.sim_positions = []
        for t in range(n_frames):
            positions, _ = self.kinematics_model.compute_positions(joint_angles, time_idx=t)
            self.sim_positions.append(positions)
        
        print(f"Computed {n_frames} frames from polynomial coefficients")
        
    def update_frame(self, val=None):
        """Update visualization for current frame."""
        if not self.mocap_data:
            return
            
        frame = int(self.time_slider.val)
        
        # Clear axes
        self.ax_3d.clear()
        self.ax_traj.clear()
        self.ax_club.clear()
        
        # Get mocap data for current frame
        mocap_hand_pos = self.mocap_data['midhand_positions'][frame]
        mocap_club_pos = self.mocap_data['clubface_positions'][frame]
        
        # Plot skeleton if available
        if self.options.get_status()[0] and self.sim_positions:
            self.plot_skeleton(self.sim_positions[frame])
        
        # Plot trajectories
        if self.options.get_status()[1]:
            self.plot_trajectories(frame)
        
        # Update error plot
        self.update_error_plot()
        
        # Set 3D view properties
        self.ax_3d.set_xlabel('X (m)')
        self.ax_3d.set_ylabel('Y (m)') 
        self.ax_3d.set_zlabel('Z (m)')
        self.ax_3d.set_title(f'Frame {frame} / {len(self.mocap_data["time"])-1}')
        
        # Set equal aspect ratio
        self.set_equal_aspect()
        
        self.fig.canvas.draw_idle()
        
    def plot_skeleton(self, positions):
        """Plot the golf swing skeleton."""
        # Define connections
        connections = [
            # Torso
            (['hip', 'spine'], 'blue', 3),
            (['spine', 'torso'], 'blue', 3),
            
            # Left arm
            (['torso', 'left_shoulder'], 'darkblue', 2),
            (['left_shoulder', 'left_elbow'], 'red', 2),
            (['left_elbow', 'left_wrist'], 'red', 2),
            (['left_wrist', 'left_hand'], 'red', 2),
            
            # Right arm
            (['torso', 'right_shoulder'], 'darkblue', 2),
            (['right_shoulder', 'right_elbow'], 'green', 2),
            (['right_elbow', 'right_wrist'], 'green', 2),
            (['right_wrist', 'right_hand'], 'green', 2),
            
            # Club
            (['left_hand', 'club_grip'], 'black', 1),
            (['right_hand', 'club_grip'], 'black', 1),
            (['club_grip', 'club_head'], 'orange', 3),
        ]
        
        # Plot connections
        for joints, color, width in connections:
            if all(j in positions for j in joints):
                points = np.array([positions[j] for j in joints])
                self.ax_3d.plot(points[:, 0], points[:, 1], points[:, 2],
                              color=color, linewidth=width, alpha=0.8)
        
        # Plot joint points
        for joint, pos in positions.items():
            size = 100 if 'hand' in joint or 'club' in joint else 60
            color = 'orange' if 'club' in joint else 'lightgray'
            self.ax_3d.scatter(pos[0], pos[1], pos[2], s=size, c=color,
                             edgecolors='black', linewidth=1)
            
    def plot_trajectories(self, current_frame):
        """Plot motion trajectories."""
        # Motion capture trajectories
        mocap_hands = self.mocap_data['midhand_positions'][:current_frame+1]
        mocap_club = self.mocap_data['clubface_positions'][:current_frame+1]
        
        # 3D trajectories
        if len(mocap_hands) > 1:
            self.ax_3d.plot(mocap_hands[:, 0], mocap_hands[:, 1], mocap_hands[:, 2],
                          'b-', linewidth=2, alpha=0.6, label='Mocap Hands')
            self.ax_3d.scatter(mocap_hands[-1, 0], mocap_hands[-1, 1], mocap_hands[-1, 2],
                             c='blue', s=100, marker='o')
                             
        if len(mocap_club) > 1:
            self.ax_3d.plot(mocap_club[:, 0], mocap_club[:, 1], mocap_club[:, 2],
                          'g-', linewidth=2, alpha=0.6, label='Mocap Club')
                          
        # Simulated trajectories
        if self.sim_positions:
            sim_hands = np.array([p['hand_midpoint'] for p in self.sim_positions[:current_frame+1]])
            sim_club = np.array([p['club_head'] for p in self.sim_positions[:current_frame+1]])
            
            if len(sim_hands) > 1:
                self.ax_3d.plot(sim_hands[:, 0], sim_hands[:, 1], sim_hands[:, 2],
                              'r--', linewidth=2, alpha=0.6, label='Sim Hands')
                self.ax_3d.scatter(sim_hands[-1, 0], sim_hands[-1, 1], sim_hands[-1, 2],
                                 c='red', s=100, marker='s')
                                 
            if len(sim_club) > 1:
                self.ax_3d.plot(sim_club[:, 0], sim_club[:, 1], sim_club[:, 2],
                              'orange', linewidth=2, alpha=0.6, label='Sim Club')
                              
        self.ax_3d.legend(loc='upper right')
        
        # 2D trajectory projections
        self.plot_2d_trajectories(current_frame)
        
    def plot_2d_trajectories(self, current_frame):
        """Plot 2D trajectory projections."""
        # Hand trajectory comparison (X-Y view)
        mocap_hands = self.mocap_data['midhand_positions'][:current_frame+1]
        
        if len(mocap_hands) > 1:
            self.ax_traj.plot(mocap_hands[:, 0], mocap_hands[:, 1], 'b-', 
                            linewidth=2, label='Motion Capture')
            self.ax_traj.scatter(mocap_hands[-1, 0], mocap_hands[-1, 1], 
                               c='blue', s=100)
                               
        if self.sim_positions and current_frame > 0:
            sim_hands = np.array([p['hand_midpoint'] for p in self.sim_positions[:current_frame+1]])
            self.ax_traj.plot(sim_hands[:, 0], sim_hands[:, 1], 'r--', 
                            linewidth=2, label='Simulation')
            self.ax_traj.scatter(sim_hands[-1, 0], sim_hands[-1, 1], 
                               c='red', s=100)
                               
        self.ax_traj.set_xlabel('X (m)')
        self.ax_traj.set_ylabel('Y (m)')
        self.ax_traj.legend()
        self.ax_traj.set_aspect('equal')
        
        # Club path (X-Z view)
        mocap_club = self.mocap_data['clubface_positions'][:current_frame+1]
        
        if len(mocap_club) > 1:
            self.ax_club.plot(mocap_club[:, 0], mocap_club[:, 2], 'g-', 
                            linewidth=2, label='Mocap Club')
                            
        if self.sim_positions and current_frame > 0:
            sim_club = np.array([p['club_head'] for p in self.sim_positions[:current_frame+1]])
            self.ax_club.plot(sim_club[:, 0], sim_club[:, 2], 'orange', 
                            linewidth=2, label='Sim Club')
                            
        self.ax_club.set_xlabel('X (m)')
        self.ax_club.set_ylabel('Z (m)')
        self.ax_club.legend()
        
    def update_error_plot(self):
        """Update error analysis plot."""
        if not self.sim_positions:
            return
            
        self.ax_error.clear()
        
        # Calculate errors
        mocap_hands = self.mocap_data['midhand_positions']
        sim_hands = np.array([p['hand_midpoint'] for p in self.sim_positions])
        
        min_len = min(len(mocap_hands), len(sim_hands))
        errors = np.linalg.norm(mocap_hands[:min_len] - sim_hands[:min_len], axis=1)
        time_vec = self.mocap_data['time'][:min_len]
        
        # Plot error
        self.ax_error.plot(time_vec, errors * 100, 'g-', linewidth=2)  # Convert to cm
        self.ax_error.fill_between(time_vec, 0, errors * 100, alpha=0.3, color='green')
        
        # Statistics
        mean_error = np.mean(errors) * 100
        max_error = np.max(errors) * 100
        
        self.ax_error.axhline(mean_error, color='orange', linestyle='--', 
                            label=f'Mean: {mean_error:.1f} cm')
        self.ax_error.text(0.02, 0.98, f'Max Error: {max_error:.1f} cm',
                         transform=self.ax_error.transAxes, va='top',
                         bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
                         
        self.ax_error.set_xlabel('Time (s)')
        self.ax_error.set_ylabel('Position Error (cm)')
        self.ax_error.legend()
        self.ax_error.grid(True, alpha=0.3)
        
    def set_equal_aspect(self):
        """Set equal aspect ratio for 3D plot."""
        if not self.mocap_data:
            return
            
        # Get all points
        all_points = []
        all_points.extend(self.mocap_data['midhand_positions'])
        all_points.extend(self.mocap_data['clubface_positions'])
        
        if self.sim_positions:
            for pos_dict in self.sim_positions:
                all_points.extend(pos_dict.values())
                
        all_points = np.array(all_points)
        
        # Calculate bounds
        max_range = np.array([
            all_points[:, 0].max() - all_points[:, 0].min(),
            all_points[:, 1].max() - all_points[:, 1].min(),
            all_points[:, 2].max() - all_points[:, 2].min()
        ]).max() / 2.0
        
        mid_x = (all_points[:, 0].max() + all_points[:, 0].min()) * 0.5
        mid_y = (all_points[:, 1].max() + all_points[:, 1].min()) * 0.5
        mid_z = (all_points[:, 2].max() + all_points[:, 2].min()) * 0.5
        
        self.ax_3d.set_xlim(mid_x - max_range, mid_x + max_range)
        self.ax_3d.set_ylim(mid_y - max_range, mid_y + max_range)
        self.ax_3d.set_zlim(mid_z - max_range, mid_z + max_range)
        
    def toggle_animation(self, event):
        """Toggle animation playback."""
        if not self.is_playing:
            self.is_playing = True
            self.play_button.label.set_text('⏸ Pause')
            
            def animate(frame):
                if self.is_playing:
                    self.time_slider.set_val(frame % self.time_slider.valmax)
                return []
                
            self.animation = animation.FuncAnimation(
                self.fig, animate, frames=int(self.time_slider.valmax),
                interval=50, repeat=True
            )
        else:
            self.is_playing = False
            self.play_button.label.set_text('▶ Play')
            if self.animation:
                self.animation.event_source.stop()
                
    def reset_animation(self, event):
        """Reset animation to beginning."""
        self.is_playing = False
        self.play_button.label.set_text('▶ Play')
        if self.animation:
            self.animation.event_source.stop()
        self.time_slider.reset()
        self.update_frame(0)
        
    def show(self):
        """Display the visualization."""
        plt.show()


class GolfSwingMotionMatching:
    """
    Main system for golf swing motion matching.
    """
    
    def __init__(self, output_dir='motion_matching_results'):
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)
        
        # Components
        self.wiffle_loader = WiffleDataLoader()
        self.kinematics = GolfSwingKinematics()
        self.visualizer = GolfSwingVisualizer()
        
        # Data
        self.mocap_data = None
        self.trial_data = None
        self.optimized_coeffs = None
        
        # Joint configuration
        self.specified_joints = ['HipX', 'HipY', 'HipZ', 'SpineX', 'SpineY', 'Torso',
                               'TranslationX', 'TranslationY', 'TranslationZ']
        
    def load_wiffle_data(self, filepath, sheet_name=None):
        """Load motion capture data from Wiffle Excel file."""
        self.mocap_data = self.wiffle_loader.load_wiffle_excel(filepath, sheet_name)
        self.visualizer.load_motion_capture(self.mocap_data)
        return self.mocap_data
        
    def load_trial_data(self, trial_csv):
        """Load trial data with initial coefficients."""
        print(f"\nLoading trial data from: {trial_csv}")
        self.trial_data = pd.read_csv(trial_csv)
        
        # Extract coefficients
        coeffs = {}
        coeff_names = ['A', 'B', 'C', 'D', 'E', 'F', 'G']
        
        for col in self.trial_data.columns:
            if col.startswith('input_') and col[-1] in coeff_names:
                parts = col.split('_')
                if len(parts) >= 3:
                    joint = '_'.join(parts[1:-1])
                    coeff = parts[-1]
                    
                    if joint not in coeffs:
                        coeffs[joint] = {}
                    coeffs[joint][coeff] = float(self.trial_data[col].iloc[0])
                    
        print(f"Extracted coefficients for {len(coeffs)} joints")
        return coeffs
        
    def optimize_coefficients(self, initial_coeffs=None):
        """Optimize polynomial coefficients to match motion capture."""
        if self.mocap_data is None:
            raise ValueError("No motion capture data loaded")
            
        # Target trajectory is the hand midpoint from motion capture
        target_trajectory = self.mocap_data['midhand_positions']
        
        # Create optimizer
        optimizer = PolynomialCoefficientOptimizer(
            self.kinematics, 
            self.specified_joints,
            time_duration=self.mocap_data['time'][-1]
        )
        
        # Optimize
        self.optimized_coeffs, losses = optimizer.optimize(
            target_trajectory,
            initial_coeffs=initial_coeffs,
            n_iterations=300,
            lr=0.01
        )
        
        # Plot optimization progress
        plt.figure(figsize=(10, 6))
        plt.plot(losses)
        plt.xlabel('Iteration')
        plt.ylabel('Loss')
        plt.title('Motion Matching Optimization Progress')
        plt.grid(True, alpha=0.3)
        plt.savefig(os.path.join(self.output_dir, 'optimization_loss.png'))
        plt.close()
        
        # Load into visualizer
        self.visualizer.load_coefficients(self.optimized_coeffs)
        
        return self.optimized_coeffs
        
    def save_results(self):
        """Save optimized coefficients and analysis results."""
        if self.optimized_coeffs is None:
            raise ValueError("No optimized coefficients to save")
            
        # Save as JSON
        results = {
            'coefficients': self.optimized_coeffs,
            'specified_joints': self.specified_joints,
            'timestamp': datetime.now().isoformat()
        }
        
        with open(os.path.join(self.output_dir, 'optimized_coefficients.json'), 'w') as f:
            json.dump(results, f, indent=2)
            
        # Save as MATLAB file
        self.save_matlab_coefficients()
        
        print(f"\nResults saved to {self.output_dir}")
        
    def save_matlab_coefficients(self):
        """Generate MATLAB-compatible coefficient file."""
        matlab_file = os.path.join(self.output_dir, 'golf_swing_coefficients.m')
        
        with open(matlab_file, 'w') as f:
            f.write("% Golf Swing Polynomial Coefficients\n")
            f.write(f"% Generated: {datetime.now().isoformat()}\n")
            f.write("% Optimized to match Wiffle motion capture data\n\n")
            
            for joint, coeffs in self.optimized_coeffs.items():
                f.write(f"\n% {joint}\n")
                for coeff_name, value in coeffs.items():
                    f.write(f"input_{joint}_{coeff_name} = {value:.8f};\n")
                    
        print(f"MATLAB coefficients saved: {matlab_file}")
        
    def run_analysis(self, wiffle_file, trial_file=None, sheet_name=None):
        """Run complete motion matching analysis."""
        print("="*80)
        print("GOLF SWING MOTION MATCHING SYSTEM")
        print("="*80)
        
        # Load motion capture
        self.load_wiffle_data(wiffle_file, sheet_name)
        
        # Load initial coefficients if available
        initial_coeffs = None
        if trial_file and os.path.exists(trial_file):
            initial_coeffs = self.load_trial_data(trial_file)
            
        # Optimize coefficients
        self.optimize_coefficients(initial_coeffs)
        
        # Save results
        self.save_results()
        
        # Show visualization
        print("\nStarting interactive visualization...")
        self.visualizer.show()
        
        print("\nAnalysis complete!")
        return self.optimized_coeffs


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Golf Swing Motion Matching System')
    parser.add_argument('--wiffle', required=True, help='Path to Wiffle Excel file')
    parser.add_argument('--trial', help='Path to trial CSV file (optional)')
    parser.add_argument('--sheet', help='Excel sheet name (optional)')
    parser.add_argument('--output', default='motion_matching_results', help='Output directory')
    
    args = parser.parse_args()
    
    # Run analysis
    system = GolfSwingMotionMatching(output_dir=args.output)
    system.run_analysis(args.wiffle, args.trial, args.sheet)


if __name__ == "__main__":
    # Example usage
    print("Golf Swing Motion Matching System")
    print("="*50)
    print("\nExample usage:")
    print("python golf_swing_motion_matching.py --wiffle Wiffle_ProV1_club_3D_data.xlsx --trial trial_011_20250802_205003.csv")
    print("\nThis system will:")
    print("1. Load motion capture data from Wiffle Excel file")
    print("2. Extract hand midpoint trajectory")
    print("3. Optimize polynomial coefficients using PyTorch")
    print("4. Visualize the results with 3D skeleton animation")
    print("5. Save MATLAB-compatible coefficient files")
