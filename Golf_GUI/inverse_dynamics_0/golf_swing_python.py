import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure
import matplotlib.animation as animation
from mpl_toolkits.mplot3d import Axes3D
from scipy import signal
from scipy.interpolate import UnivariateSpline
import os

class GolfSwingAnalyzer:
    def __init__(self, root):
        self.root = root
        self.root.title("Golf Swing Motion Capture Analyzer")
        self.root.geometry("1400x900")
        
        # Data storage
        self.swing_data = {}
        self.key_frames = {}
        self.current_swing = "TW_ProV1"
        self.current_frame = 0
        self.current_filter = "None"
        self.eval_offset = 0.0  # inches
        self.is_playing = False
        self.show_trajectory = True
        self.show_force_vectors = True
        
        # Club parameters
        self.club_mass = 0.2  # kg
        self.shaft_length = 1.2  # meters
        
        self.setup_gui()
        self.load_default_data()
        
    def setup_gui(self):
        """Setup the main GUI layout"""
        # Main frame
        main_frame = ttk.Frame(self.root)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Left panel for controls
        control_frame = ttk.Frame(main_frame, width=300)
        control_frame.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 5))
        control_frame.pack_propagate(False)
        
        # Right panel for 3D plot
        plot_frame = ttk.Frame(main_frame)
        plot_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)
        
        self.setup_controls(control_frame)
        self.setup_plot(plot_frame)
        
    def setup_controls(self, parent):
        """Setup control panel"""
        # Title
        title_label = ttk.Label(parent, text="Golf Swing Analyzer", 
                               font=("Arial", 16, "bold"))
        title_label.pack(pady=(0, 10))
        
        # File loading
        file_frame = ttk.LabelFrame(parent, text="Data Loading", padding=10)
        file_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Button(file_frame, text="Load Excel File", 
                  command=self.load_file).pack(fill=tk.X)
        
        # Swing selection
        swing_frame = ttk.LabelFrame(parent, text="Swing Selection", padding=10)
        swing_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.swing_var = tk.StringVar(value=self.current_swing)
        swing_options = ["TW_ProV1", "TW_wiffle", "GW_ProV11", "GW_wiffle"]
        self.swing_combo = ttk.Combobox(swing_frame, textvariable=self.swing_var,
                                       values=swing_options, state="readonly")
        self.swing_combo.pack(fill=tk.X)
        self.swing_combo.bind('<<ComboboxSelected>>', self.on_swing_change)
        
        # Playback controls
        playback_frame = ttk.LabelFrame(parent, text="Playback Controls", padding=10)
        playback_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Play/Pause button
        self.play_button = ttk.Button(playback_frame, text="Play", 
                                     command=self.toggle_playback)
        self.play_button.pack(fill=tk.X, pady=(0, 5))
        
        # Frame slider
        self.frame_var = tk.IntVar()
        self.frame_scale = ttk.Scale(playback_frame, from_=0, to=100, 
                                   orient=tk.HORIZONTAL, variable=self.frame_var,
                                   command=self.on_frame_change)
        self.frame_scale.pack(fill=tk.X, pady=(0, 5))
        
        # Frame info
        self.frame_info = ttk.Label(playback_frame, text="Frame: 0 / 0")
        self.frame_info.pack()
        
        # Speed control
        speed_frame = ttk.Frame(playback_frame)
        speed_frame.pack(fill=tk.X, pady=(5, 0))
        ttk.Label(speed_frame, text="Speed:").pack(side=tk.LEFT)
        self.speed_var = tk.DoubleVar(value=1.0)
        speed_scale = ttk.Scale(speed_frame, from_=0.1, to=3.0, 
                              orient=tk.HORIZONTAL, variable=self.speed_var)
        speed_scale.pack(side=tk.RIGHT, fill=tk.X, expand=True)
        
        # Camera controls
        camera_frame = ttk.LabelFrame(parent, text="Camera Views", padding=10)
        camera_frame.pack(fill=tk.X, pady=(0, 10))
        
        camera_buttons = [
            ("Face-On", lambda: self.set_camera_view('face_on')),
            ("Down-the-Line", lambda: self.set_camera_view('down_line')),
            ("Top-Down", lambda: self.set_camera_view('top_down')),
            ("Isometric", lambda: self.set_camera_view('isometric'))
        ]
        
        for i, (text, command) in enumerate(camera_buttons):
            row, col = i // 2, i % 2
            btn = ttk.Button(camera_frame, text=text, command=command)
            btn.grid(row=row, column=col, sticky="ew", padx=2, pady=2)
        
        camera_frame.grid_columnconfigure(0, weight=1)
        camera_frame.grid_columnconfigure(1, weight=1)
        
        # Filtering options
        filter_frame = ttk.LabelFrame(parent, text="Data Filtering", padding=10)
        filter_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.filter_var = tk.StringVar(value="None")
        filter_options = ["None", "Moving Average", "Savitzky-Golay", 
                         "Butterworth 6Hz", "Butterworth 8Hz", "Butterworth 10Hz"]
        filter_combo = ttk.Combobox(filter_frame, textvariable=self.filter_var,
                                   values=filter_options, state="readonly")
        filter_combo.pack(fill=tk.X)
        filter_combo.bind('<<ComboboxSelected>>', self.on_filter_change)
        
        # Evaluation point offset
        offset_frame = ttk.LabelFrame(parent, text="Evaluation Point", padding=10)
        offset_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Label(offset_frame, text="Offset (inches):").pack()
        self.offset_var = tk.DoubleVar()
        offset_scale = ttk.Scale(offset_frame, from_=-2, to=2, 
                               orient=tk.HORIZONTAL, variable=self.offset_var,
                               command=self.on_offset_change)
        offset_scale.pack(fill=tk.X)
        
        # Display options
        display_frame = ttk.LabelFrame(parent, text="Display Options", padding=10)
        display_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.trajectory_var = tk.BooleanVar(value=True)
        trajectory_check = ttk.Checkbutton(display_frame, text="Show Trajectory",
                                         variable=self.trajectory_var,
                                         command=self.update_display_options)
        trajectory_check.pack(anchor=tk.W)
        
        self.force_var = tk.BooleanVar(value=True)
        force_check = ttk.Checkbutton(display_frame, text="Show Force Vectors",
                                    variable=self.force_var,
                                    command=self.update_display_options)
        force_check.pack(anchor=tk.W)
        
        # Analysis info
        info_frame = ttk.LabelFrame(parent, text="Current Frame Data", padding=10)
        info_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.info_text = tk.Text(info_frame, height=8, width=30)
        info_scroll = ttk.Scrollbar(info_frame, orient=tk.VERTICAL, 
                                  command=self.info_text.yview)
        self.info_text.configure(yscrollcommand=info_scroll.set)
        self.info_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        info_scroll.pack(side=tk.RIGHT, fill=tk.Y)
        
    def setup_plot(self, parent):
        """Setup 3D matplotlib plot"""
        self.fig = Figure(figsize=(10, 8), dpi=100)
        self.ax = self.fig.add_subplot(111, projection='3d')
        
        self.canvas = FigureCanvasTkAgg(self.fig, parent)
        self.canvas.draw()
        self.canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)
        
        # Initialize empty plot elements
        self.club_line = None
        self.club_head = None
        self.trajectory_line = None
        self.force_arrow = None
        self.torque_arrow = None
        self.key_points = []
        
        self.setup_3d_scene()
        
    def setup_3d_scene(self):
        """Setup the 3D scene with ground plane and ball"""
        self.ax.clear()
        
        # Ground plane
        x_ground = np.linspace(-2, 2, 10)
        y_ground = np.linspace(-2, 2, 10)
        X_ground, Y_ground = np.meshgrid(x_ground, y_ground)
        Z_ground = np.zeros_like(X_ground) - 0.1
        self.ax.plot_surface(X_ground, Y_ground, Z_ground, alpha=0.3, color='green')
        
        # Golf ball
        u = np.linspace(0, 2 * np.pi, 20)
        v = np.linspace(0, np.pi, 20)
        ball_radius = 0.021
        x_ball = ball_radius * np.outer(np.cos(u), np.sin(v))
        y_ball = ball_radius * np.outer(np.sin(u), np.sin(v))
        z_ball = ball_radius * np.outer(np.ones(np.size(u)), np.cos(v)) + ball_radius
        self.ax.plot_surface(x_ball, y_ball, z_ball, color='white')
        
        # Set labels and limits
        self.ax.set_xlabel('X (m)')
        self.ax.set_ylabel('Y (m)')
        self.ax.set_zlabel('Z (m)')
        self.ax.set_xlim([-1.5, 1.5])
        self.ax.set_ylim([-1.5, 1.5])
        self.ax.set_zlim([-0.5, 2.0])
        
        # Set initial view
        self.ax.view_init(elev=20, azim=-60)
        
    def load_default_data(self):
        """Try to load the default Excel file"""
        default_file = "Wiffle_ProV1_club_3D_data.xlsx"
        if os.path.exists(default_file):
            self.load_excel_file(default_file)
        
    def load_file(self):
        """Load Excel file dialog"""
        filename = filedialog.askopenfilename(
            title="Select Golf Swing Data File",
            filetypes=[("Excel files", "*.xlsx"), ("All files", "*.*")]
        )
        if filename:
            self.load_excel_file(filename)
            
    def load_excel_file(self, filename):
        """Load and process Excel file"""
        try:
            # Read all sheets
            excel_file = pd.ExcelFile(filename)
            
            for sheet_name in ["TW_wiffle", "TW_ProV1", "GW_wiffle", "GW_ProV11"]:
                if sheet_name in excel_file.sheet_names:
                    # Read the sheet
                    df = pd.read_excel(filename, sheet_name=sheet_name, header=None)
                    
                    # Extract key frames from first row
                    key_frame_data = {}
                    for col in range(2, min(10, len(df.columns))):
                        if pd.notna(df.iloc[0, col]) and str(df.iloc[0, col]) in ['A', 'T', 'I', 'F']:
                            if col + 1 < len(df.columns) and pd.notna(df.iloc[0, col + 1]):
                                key_frame_data[str(df.iloc[0, col])] = int(df.iloc[0, col + 1])
                    
                    self.key_frames[sheet_name] = key_frame_data
                    
                    # Extract motion data starting from row 3 (0-indexed)
                    motion_data = []
                    for row in range(3, len(df)):
                        if pd.notna(df.iloc[row, 0]):  # Sample number exists
                            row_data = {
                                'sample': int(df.iloc[row, 0]) if pd.notna(df.iloc[row, 0]) else 0,
                                'time': float(df.iloc[row, 1]) if pd.notna(df.iloc[row, 1]) else 0,
                                'X': float(df.iloc[row, 2]) / 1000 if pd.notna(df.iloc[row, 2]) else 0,  # mm to m
                                'Y': float(df.iloc[row, 3]) / 1000 if pd.notna(df.iloc[row, 3]) else 0,
                                'Z': float(df.iloc[row, 4]) / 1000 if pd.notna(df.iloc[row, 4]) else 0,
                                'Xx': float(df.iloc[row, 5]) if pd.notna(df.iloc[row, 5]) else 0,
                                'Xy': float(df.iloc[row, 6]) if pd.notna(df.iloc[row, 6]) else 0,
                                'Xz': float(df.iloc[row, 7]) if pd.notna(df.iloc[row, 7]) else 0,
                                'Yx': float(df.iloc[row, 8]) if pd.notna(df.iloc[row, 8]) else 0,
                                'Yy': float(df.iloc[row, 9]) if pd.notna(df.iloc[row, 9]) else 0,
                                'Yz': float(df.iloc[row, 10]) if pd.notna(df.iloc[row, 10]) else 0,
                            }
                            motion_data.append(row_data)
                    
                    self.swing_data[sheet_name] = pd.DataFrame(motion_data)
            
            # Update frame slider maximum
            if self.current_swing in self.swing_data:
                max_frame = len(self.swing_data[self.current_swing]) - 1
                self.frame_scale.configure(to=max_frame)
                
            self.update_visualization()
            messagebox.showinfo("Success", f"Loaded data from {filename}")
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to load file: {str(e)}")
            
    def apply_filter(self, data, method):
        """Apply selected filter to the data"""
        if method == "None" or data.empty:
            return data
            
        filtered_data = data.copy()
        position_cols = ['X', 'Y', 'Z']
        orientation_cols = ['Xx', 'Xy', 'Xz', 'Yx', 'Yy', 'Yz']
        
        for col in position_cols + orientation_cols:
            if col in filtered_data.columns:
                if method == "Moving Average":
                    filtered_data[col] = filtered_data[col].rolling(window=5, center=True).mean()
                elif method == "Savitzky-Golay":
                    if len(filtered_data) > 9:
                        filtered_data[col] = signal.savgol_filter(filtered_data[col], 9, 3)
                elif "Butterworth" in method:
                    cutoff = int(method.split()[-1].replace("Hz", ""))
                    fs = 240  # Assumed sampling frequency
                    nyquist = fs / 2
                    normalized_cutoff = cutoff / nyquist
                    b, a = signal.butter(4, normalized_cutoff, btype='low')
                    filtered_data[col] = signal.filtfilt(b, a, filtered_data[col])
        
        # Forward fill any NaN values created by filtering
        filtered_data = filtered_data.fillna(method='ffill').fillna(method='bfill')
        return filtered_data
        
    def calculate_kinematics(self, data):
        """Calculate velocity and acceleration from position data"""
        if len(data) < 3:
            return None
            
        kinematics = []
        dt_mean = np.mean(np.diff(data['time']))
        
        for i in range(len(data)):
            # Central difference for velocity
            if i == 0:
                vel_x = (data.iloc[i+1]['X'] - data.iloc[i]['X']) / dt_mean
                vel_y = (data.iloc[i+1]['Y'] - data.iloc[i]['Y']) / dt_mean
                vel_z = (data.iloc[i+1]['Z'] - data.iloc[i]['Z']) / dt_mean
            elif i == len(data) - 1:
                vel_x = (data.iloc[i]['X'] - data.iloc[i-1]['X']) / dt_mean
                vel_y = (data.iloc[i]['Y'] - data.iloc[i-1]['Y']) / dt_mean
                vel_z = (data.iloc[i]['Z'] - data.iloc[i-1]['Z']) / dt_mean
            else:
                vel_x = (data.iloc[i+1]['X'] - data.iloc[i-1]['X']) / (2 * dt_mean)
                vel_y = (data.iloc[i+1]['Y'] - data.iloc[i-1]['Y']) / (2 * dt_mean)
                vel_z = (data.iloc[i+1]['Z'] - data.iloc[i-1]['Z']) / (2 * dt_mean)
            
            # Central difference for acceleration
            if i <= 1 or i >= len(data) - 2:
                acc_x = acc_y = acc_z = 0
            else:
                acc_x = (data.iloc[i+1]['X'] - 2*data.iloc[i]['X'] + data.iloc[i-1]['X']) / (dt_mean**2)
                acc_y = (data.iloc[i+1]['Y'] - 2*data.iloc[i]['Y'] + data.iloc[i-1]['Y']) / (dt_mean**2)
                acc_z = (data.iloc[i+1]['Z'] - 2*data.iloc[i]['Z'] + data.iloc[i-1]['Z']) / (dt_mean**2)
            
            kinematics.append({
                'velocity': np.array([vel_x, vel_y, vel_z]),
                'acceleration': np.array([acc_x, acc_y, acc_z])
            })
            
        return kinematics
        
    def calculate_dynamics(self, frame_data, kinematics, frame_idx):
        """Calculate force and torque vectors"""
        if not kinematics or frame_idx >= len(kinematics):
            return {'force': np.zeros(3), 'torque': np.zeros(3)}
            
        # Force = mass * acceleration
        acceleration = kinematics[frame_idx]['acceleration']
        force = self.club_mass * acceleration
        
        # Simplified torque calculation
        # In reality, this would require more complex rigid body dynamics
        torque = np.array([
            force[1] * 0.5,  # Approximation based on lever arm
            -force[0] * 0.5,
            force[2] * 0.2
        ])
        
        return {'force': force, 'torque': torque}
        
    def update_visualization(self):
        """Update the 3D visualization"""
        if self.current_swing not in self.swing_data:
            return
            
        data = self.swing_data[self.current_swing]
        if data.empty or self.current_frame >= len(data):
            return
            
        # Apply filtering
        filtered_data = self.apply_filter(data, self.current_filter)
        
        # Calculate kinematics
        kinematics = self.calculate_kinematics(filtered_data)
        
        # Get current frame data
        frame_data = filtered_data.iloc[self.current_frame]
        
        # Clear previous club visualization
        self.setup_3d_scene()
        
        # Mid-hands position (convert coordinates for visualization)
        mid_hands = np.array([frame_data['X'], frame_data['Z'], -frame_data['Y']])
        
        # Club coordinate system
        x_axis = np.array([frame_data['Xx'], frame_data['Xz'], -frame_data['Xy']])
        y_axis = np.array([frame_data['Yx'], frame_data['Yz'], -frame_data['Yy']])
        z_axis = np.cross(x_axis, y_axis)
        
        # Calculate club positions
        eval_offset_m = self.eval_offset * 0.0254  # inches to meters
        eval_point = mid_hands + z_axis * eval_offset_m
        club_face = mid_hands + z_axis * (-self.shaft_length)
        
        # Draw club shaft
        shaft_points = np.array([mid_hands, club_face])
        self.ax.plot(shaft_points[:, 0], shaft_points[:, 1], shaft_points[:, 2], 
                    'k-', linewidth=4, label='Shaft')
        
        # Draw club head
        head_size = 0.05
        head_vertices = np.array([
            club_face + x_axis * head_size + y_axis * head_size/2,
            club_face - x_axis * head_size + y_axis * head_size/2,
            club_face - x_axis * head_size - y_axis * head_size/2,
            club_face + x_axis * head_size - y_axis * head_size/2
        ])
        
        # Draw clubhead outline
        for i in range(4):
            start = head_vertices[i]
            end = head_vertices[(i+1)%4]
            self.ax.plot([start[0], end[0]], [start[1], end[1]], [start[2], end[2]], 
                        'gray', linewidth=3)
        
        # Draw grip
        grip_end = mid_hands + z_axis * 0.15
        grip_points = np.array([mid_hands, grip_end])
        self.ax.plot(grip_points[:, 0], grip_points[:, 1], grip_points[:, 2], 
                    'brown', linewidth=6, label='Grip')
        
        # Show trajectory if enabled
        if self.trajectory_var.get() and len(filtered_data) > 1:
            trajectory = np.array([[row['X'], row['Z'], -row['Y']] for _, row in filtered_data.iterrows()])
            self.ax.plot(trajectory[:, 0], trajectory[:, 1], trajectory[:, 2], 
                        'r--', alpha=0.6, linewidth=1, label='Trajectory')
        
        # Show force vectors if enabled
        if self.force_var.get() and kinematics:
            dynamics = self.calculate_dynamics(frame_data, kinematics, self.current_frame)
            
            force_scale = 0.01  # Scale for visualization
            force_end = eval_point + dynamics['force'] * force_scale
            self.ax.quiver(eval_point[0], eval_point[1], eval_point[2],
                          dynamics['force'][0] * force_scale, dynamics['force'][1] * force_scale, 
                          dynamics['force'][2] * force_scale,
                          color='red', arrow_length_ratio=0.1, linewidth=2, label='Force')
            
            torque_scale = 0.05
            torque_end = eval_point + dynamics['torque'] * torque_scale
            self.ax.quiver(eval_point[0], eval_point[1], eval_point[2],
                          dynamics['torque'][0] * torque_scale, dynamics['torque'][1] * torque_scale,
                          dynamics['torque'][2] * torque_scale,
                          color='blue', arrow_length_ratio=0.1, linewidth=2, label='Torque')
        
        # Mark key frames
        if self.current_swing in self.key_frames:
            key_colors = {'A': 'green', 'T': 'yellow', 'I': 'red', 'F': 'blue'}
            key_names = {'A': 'Address', 'T': 'Top', 'I': 'Impact', 'F': 'Finish'}
            
            for key, frame_num in self.key_frames[self.current_swing].items():
                if abs(self.current_frame - frame_num) < 3:
                    marker_pos = mid_hands + np.array([0, 0, 0.1])
                    self.ax.scatter(marker_pos[0], marker_pos[1], marker_pos[2],
                                  c=key_colors.get(key, 'white'), s=100, alpha=0.8,
                                  label=f'{key_names.get(key, key)}')
        
        # Update info display
        self.update_info_display(frame_data, kinematics)
        
        self.canvas.draw()
        
    def update_info_display(self, frame_data, kinematics):
        """Update the information display"""
        self.info_text.delete(1.0, tk.END)
        
        info = f"Frame: {self.current_frame + 1}\n"
        info += f"Time: {frame_data['time']:.3f} s\n\n"
        
        info += "Position (m):\n"
        info += f"  X: {frame_data['X']:.4f}\n"
        info += f"  Y: {frame_data['Y']:.4f}\n"
        info += f"  Z: {frame_data['Z']:.4f}\n\n"
        
        if kinematics and self.current_frame < len(kinematics):
            vel = kinematics[self.current_frame]['velocity']
            acc = kinematics[self.current_frame]['acceleration']
            
            info += "Velocity (m/s):\n"
            info += f"  X: {vel[0]:.3f}\n"
            info += f"  Y: {vel[1]:.3f}\n"
            info += f"  Z: {vel[2]:.3f}\n\n"
            
            info += "Acceleration (m/s²):\n"
            info += f"  X: {acc[0]:.2f}\n"
            info += f"  Y: {acc[1]:.2f}\n"
            info += f"  Z: {acc[2]:.2f}\n\n"
            
            dynamics = self.calculate_dynamics(frame_data, kinematics, self.current_frame)
            
            info += "Force (N):\n"
            info += f"  X: {dynamics['force'][0]:.2f}\n"
            info += f"  Y: {dynamics['force'][1]:.2f}\n"
            info += f"  Z: {dynamics['force'][2]:.2f}\n\n"
            
            info += "Torque (Nm):\n"
            info += f"  X: {dynamics['torque'][0]:.3f}\n"
            info += f"  Y: {dynamics['torque'][1]:.3f}\n"
            info += f"  Z: {dynamics['torque'][2]:.3f}\n"
        
        self.info_text.insert(1.0, info)
        
    def update_frame_info(self):
        """Update frame information display"""
        if self.current_swing in self.swing_data:
            max_frame = len(self.swing_data[self.current_swing]) - 1
            self.frame_info.config(text=f"Frame: {self.current_frame} / {max_frame}")
        
    # Event handlers
    def on_swing_change(self, event=None):
        """Handle swing selection change"""
        self.current_swing = self.swing_var.get()
        self.current_frame = 0
        self.frame_var.set(0)
        
        if self.current_swing in self.swing_data:
            max_frame = len(self.swing_data[self.current_swing]) - 1
            self.frame_scale.configure(to=max_frame)
            
        self.update_visualization()
        self.update_frame_info()
        
    def on_frame_change(self, value):
        """Handle frame slider change"""
        self.current_frame = int(float(value))
        self.update_visualization()
        self.update_frame_info()
        
    def on_filter_change(self, event=None):
        """Handle filter selection change"""
        self.current_filter = self.filter_var.get()
        self.update_visualization()
        
    def on_offset_change(self, value):
        """Handle evaluation point offset change"""
        self.eval_offset = float(value)
        self.update_visualization()
        
    def update_display_options(self):
        """Handle display option changes"""
        self.show_trajectory = self.trajectory_var.get()
        self.show_force_vectors = self.force_var.get()
        self.update_visualization()
        
    def set_camera_view(self, view):
        """Set predefined camera views"""
        if view == 'face_on':
            self.ax.view_init(elev=0, azim=0)
        elif view == 'down_line':
            self.ax.view_init(elev=0, azim=90)
        elif view == 'top_down':
            self.ax.view_init(elev=90, azim=0)
        elif view == 'isometric':
            self.ax.view_init(elev=20, azim=-60)
            
        self.canvas.draw()
        
    def toggle_playback(self):
        """Toggle play/pause"""
        self.is_playing = not self.is_playing
        
        if self.is_playing:
            self.play_button.config(text="Pause")
            self.animate()
        else:
            self.play_button.config(text="Play")
            
    def animate(self):
        """Animation loop for playback"""
        if not self.is_playing:
            return
            
        if self.current_swing in self.swing_data:
            max_frame = len(self.swing_data[self.current_swing]) - 1
            
            if self.current_frame >= max_frame:
                self.current_frame = 0
            else:
                self.current_frame += 1
                
            self.frame_var.set(self.current_frame)
            self.update_visualization()
            self.update_frame_info()
            
            # Schedule next frame
            delay = int(50 / self.speed_var.get())  # Base 20fps, adjusted by speed
            self.root.after(delay, self.animate)
        else:
            self.is_playing = False
            self.play_button.config(text="Play")

def main():
    root = tk.Tk()
    app = GolfSwingAnalyzer(root)
    root.mainloop()

if __name__ == "__main__":
    main()
