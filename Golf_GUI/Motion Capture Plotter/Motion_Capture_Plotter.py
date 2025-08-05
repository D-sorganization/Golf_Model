import sys
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('QtAgg')  # Use QtAgg backend for PyQt6 compatibility
import matplotlib.pyplot as plt
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
from mpl_toolkits.mplot3d import Axes3D
from scipy import signal
import os
from PyQt6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                             QHBoxLayout, QLabel, QPushButton, QComboBox, 
                             QSlider, QCheckBox, QGroupBox, QTextEdit, 
                             QScrollArea, QFileDialog, QMessageBox, QFrame)
from PyQt6.QtCore import Qt, QTimer, pyqtSignal
from PyQt6.QtGui import QFont

class MotionCapturePlotter(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Motion Capture Plotter - PyQt6")
        self.setGeometry(100, 100, 1400, 900)
        
        # Data storage
        self.swing_data = {}
        self.current_swing = None
        self.current_frame = 0
        self.is_playing = False
        self.current_filter = 'none'
        
        # Club parameters
        self.shaft_length = 0.9  # meters
        self.motion_scale = 1.0  # Use actual scale since we have real coordinates
        
        # Mouse interaction state
        self._last_pos = None
        
        # Setup UI
        self.setup_ui()
        
        # Animation timer
        self.animation_timer = QTimer()
        self.animation_timer.timeout.connect(self.next_frame)
        
        # Try to auto-load the Excel file if it exists
        self.auto_load_excel_file()
        
        # Data source tracking
        self.current_data_source = "Motion Capture (Excel)"
        
    def auto_load_excel_file(self):
        """Automatically load the Excel file if it exists in the current directory"""
        excel_files = [f for f in os.listdir('.') if f.endswith(('.xlsx', '.xls'))]
        if excel_files:
            # Try to load the first Excel file found
            filename = excel_files[0]
            print(f"Auto-loading Excel file: {filename}")
            self.load_excel_file(filename)
        
    def setup_ui(self):
        """Setup the main UI"""
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        
        # Main layout
        main_layout = QHBoxLayout(central_widget)
        
        # Left control panel
        control_panel = self.create_control_panel()
        main_layout.addWidget(control_panel)
        
        # Right plot panel
        plot_panel = self.create_plot_panel()
        main_layout.addWidget(plot_panel, stretch=1)
        
    def create_control_panel(self):
        """Create the left control panel"""
        panel = QWidget()
        panel.setMaximumWidth(400)
        panel.setMinimumWidth(350)
        
        layout = QVBoxLayout(panel)
        
        # Title
        title = QLabel("Motion Capture Plotter")
        title.setFont(QFont("Arial", 16, QFont.Weight.Bold))
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(title)
        
        # File loading
        file_group = QGroupBox("Data Loading")
        file_layout = QVBoxLayout(file_group)
        
        # Data source selection
        file_layout.addWidget(QLabel("Data Source:"))
        self.data_source_combo = QComboBox()
        self.data_source_combo.addItem("Motion Capture (Excel)")
        self.data_source_combo.addItem("Simscape Multibody (CSV)")
        self.data_source_combo.currentTextChanged.connect(self.on_data_source_changed)
        file_layout.addWidget(self.data_source_combo)
        
        # File selection
        file_layout.addWidget(QLabel("Data File:"))
        self.file_combo = QComboBox()
        self.file_combo.addItem("Wiffle_ProV1_club_3D_data.xlsx")
        self.file_combo.addItem("trial_001_20250802_204903.csv")
        file_layout.addWidget(self.file_combo)
        
        load_btn = QPushButton("Load File")
        load_btn.clicked.connect(self.load_file)
        file_layout.addWidget(load_btn)
        layout.addWidget(file_group)
        
        # Swing selection
        swing_group = QGroupBox("Swing Selection")
        swing_layout = QVBoxLayout(swing_group)
        self.swing_combo = QComboBox()
        self.swing_combo.currentTextChanged.connect(self.on_swing_change)
        swing_layout.addWidget(self.swing_combo)
        layout.addWidget(swing_group)
        
        # Playback controls
        playback_group = QGroupBox("Playback Controls")
        playback_layout = QVBoxLayout(playback_group)
        
        # Play/Pause button
        self.play_btn = QPushButton("Play")
        self.play_btn.clicked.connect(self.toggle_playback)
        playback_layout.addWidget(self.play_btn)
        
        # Frame slider
        frame_layout = QHBoxLayout()
        frame_layout.addWidget(QLabel("Frame:"))
        self.frame_slider = QSlider(Qt.Orientation.Horizontal)
        self.frame_slider.valueChanged.connect(self.on_frame_change)
        frame_layout.addWidget(self.frame_slider)
        self.frame_label = QLabel("0")
        frame_layout.addWidget(self.frame_label)
        playback_layout.addLayout(frame_layout)
        
        # Speed control
        speed_layout = QHBoxLayout()
        speed_layout.addWidget(QLabel("Speed:"))
        self.speed_slider = QSlider(Qt.Orientation.Horizontal)
        self.speed_slider.setRange(1, 60)
        self.speed_slider.setValue(30)  # Default faster speed
        self.speed_slider.valueChanged.connect(self.on_speed_change)
        speed_layout.addWidget(self.speed_slider)
        self.speed_label = QLabel("30")
        speed_layout.addWidget(self.speed_label)
        playback_layout.addLayout(speed_layout)
        
        layout.addWidget(playback_group)
        
        # Visualization options
        viz_group = QGroupBox("Visualization Options")
        viz_layout = QVBoxLayout(viz_group)
        
        # Trajectory options
        self.trajectory_check = QCheckBox("Show Mid-Hands Path")
        self.trajectory_check.setChecked(True)
        self.trajectory_check.stateChanged.connect(self.update_visualization)
        viz_layout.addWidget(self.trajectory_check)
        
        self.club_path_check = QCheckBox("Show Club Head Path")
        self.club_path_check.setChecked(True)
        self.club_path_check.stateChanged.connect(self.update_visualization)
        viz_layout.addWidget(self.club_path_check)
        
        # Motion scaling
        scale_layout = QHBoxLayout()
        scale_layout.addWidget(QLabel("Motion Scale:"))
        self.scale_slider = QSlider(Qt.Orientation.Horizontal)
        self.scale_slider.setRange(1, 10)  # Reasonable range for scaling
        self.scale_slider.setValue(1)  # Default 1x scale
        self.scale_slider.valueChanged.connect(self.on_scale_change)
        scale_layout.addWidget(self.scale_slider)
        self.scale_label = QLabel("1x")
        scale_layout.addWidget(self.scale_label)
        viz_layout.addLayout(scale_layout)
        
        # Club length
        club_layout = QHBoxLayout()
        club_layout.addWidget(QLabel("Club Length:"))
        self.club_slider = QSlider(Qt.Orientation.Horizontal)
        self.club_slider.setRange(50, 150)
        self.club_slider.setValue(90)  # 0.9m default
        self.club_slider.valueChanged.connect(self.on_club_length_change)
        club_layout.addWidget(self.club_slider)
        self.club_label = QLabel("0.9m")
        club_layout.addWidget(self.club_label)
        viz_layout.addLayout(club_layout)
        
        layout.addWidget(viz_group)
        
        # Camera controls
        camera_group = QGroupBox("Camera Views")
        camera_layout = QVBoxLayout(camera_group)
        
        camera_buttons = [
            ("Face-On", lambda: self.set_camera_view('face_on')),
            ("Down-the-Line", lambda: self.set_camera_view('down_line')),
            ("Top-Down", lambda: self.set_camera_view('top_down')),
            ("Isometric", lambda: self.set_camera_view('isometric')),
            ("Reset View", lambda: self.reset_view())
        ]
        
        for text, command in camera_buttons:
            btn = QPushButton(text)
            btn.clicked.connect(command)
            camera_layout.addWidget(btn)
            
        layout.addWidget(camera_group)
        
        # Analysis info
        info_group = QGroupBox("Current Frame Data")
        info_layout = QVBoxLayout(info_group)
        self.info_text = QTextEdit()
        self.info_text.setMaximumHeight(150)
        info_layout.addWidget(self.info_text)
        layout.addWidget(info_group)
        
        # Interactive controls help
        help_group = QGroupBox("3D Plot Controls")
        help_layout = QVBoxLayout(help_group)
        help_text = """3D Plot Interaction:
• Left-click + drag: Rotate view
• Right-click + drag: Pan view  
• Mouse wheel: Zoom in/out
• Use camera buttons for preset views"""
        help_label = QLabel(help_text)
        help_label.setWordWrap(True)
        help_layout.addWidget(help_label)
        layout.addWidget(help_group)
        
        layout.addStretch()
        return panel
        
    def create_plot_panel(self):
        """Create the right plot panel"""
        panel = QWidget()
        layout = QVBoxLayout(panel)
        
        # Create matplotlib figure
        self.fig = Figure(figsize=(10, 8), dpi=100)
        self.ax = self.fig.add_subplot(111, projection='3d')
        
        # Enable interactive features and 3D navigation
        self.ax.mouse_init()
        
        # Enable matplotlib's built-in 3D navigation
        self.ax.set_navigate(True)
        
        # Create canvas
        self.canvas = FigureCanvas(self.fig)
        layout.addWidget(self.canvas)
        
        # Connect mouse events for zoom/rotation with proper event handling
        self.canvas.mpl_connect('scroll_event', self.on_scroll)
        self.canvas.mpl_connect('button_press_event', self.on_mouse_press)
        self.canvas.mpl_connect('button_release_event', self.on_mouse_release)
        self.canvas.mpl_connect('motion_notify_event', self.on_mouse_move)
        
        # Enable mouse tracking for better interaction
        self.canvas.setMouseTracking(True)
        
        # Initialize empty plot elements
        self.club_line = None
        self.club_head = None
        self.trajectory_line = None
        self.club_path_line = None
        
        # Show initial 3D scene
        self.setup_3d_scene()
        
        return panel
        
    def load_file(self):
        """Load data file based on current data source"""
        if self.current_data_source == "Motion Capture (Excel)":
            filename, _ = QFileDialog.getOpenFileName(
                self, "Load Excel File", "", "Excel Files (*.xlsx *.xls)")
            if filename:
                self.load_excel_file(filename)
        else:  # Simscape Multibody (CSV)
            filename, _ = QFileDialog.getOpenFileName(
                self, "Load CSV File", "", "CSV Files (*.csv)")
            if filename:
                self.load_simscape_csv(filename)
    
    def on_data_source_changed(self, source):
        """Handle data source change"""
        self.current_data_source = source
        print(f"Data source changed to: {source}")
        
        # Update file combo based on data source
        self.file_combo.clear()
        if source == "Motion Capture (Excel)":
            self.file_combo.addItem("Wiffle_ProV1_club_3D_data.xlsx")
            # Try to auto-load Excel file
            self.auto_load_excel_file()
        else:  # Simscape Multibody (CSV)
            self.file_combo.addItem("trial_001_20250802_204903.csv")
            # Try to auto-load CSV file
            self.auto_load_simscape_csv()
    
    def auto_load_simscape_csv(self):
        """Automatically load the Simscape CSV file if it exists"""
        csv_files = [f for f in os.listdir('.') if f.endswith('.csv')]
        if csv_files:
            filename = csv_files[0]
            print(f"Auto-loading Simscape CSV file: {filename}")
            self.load_simscape_csv(filename)
            
    def load_excel_file(self, filename):
        """Load and process Excel file"""
        try:
            print(f"Loading file: {filename}")
            # Read all sheets
            excel_file = pd.ExcelFile(filename)
            print(f"Available sheets: {excel_file.sheet_names}")
            
            for sheet_name in ["TW_wiffle", "TW_ProV1", "GW_wiffle", "GW_ProV11"]:
                if sheet_name in excel_file.sheet_names:
                    # Read the sheet
                    df = pd.read_excel(filename, sheet_name=sheet_name, header=None)
                    
                    # Extract key frames from first row
                    key_frame_data = {}
                    for col in range(2, min(10, len(df.columns))):
                        if pd.notna(df.iloc[0, col]) and str(df.iloc[0, col]) in ['A', 'T', 'I', 'F']:
                            key_frame_data[str(df.iloc[0, col])] = col
                    
                    # Process data starting from row 3 (actual data starts here)
                    if len(df) > 3:
                        # Extract position and orientation data for both mid-hands and club head
                        data = []
                        for i in range(3, len(df)):
                            row = df.iloc[i]
                            if len(row) >= 25:  # Ensure we have enough columns for both sets
                                # Helper function to safely convert to float
                                def safe_float(value, default=0.0):
                                    if pd.isna(value):
                                        return default
                                    try:
                                        return float(value)
                                    except (ValueError, TypeError):
                                        return default
                                
                                # Mid-hands data (columns 2-13) - Convert inches to meters
                                frame_data = {
                                    'time': safe_float(row[1], i-3),  # Time is in column 1
                                    # Mid-hands position (convert inches to meters) and orientation
                                    'mid_X': safe_float(row[2]) * 0.0254,  # inches to meters
                                    'mid_Y': safe_float(row[3]) * 0.0254,  # inches to meters
                                    'mid_Z': safe_float(row[4]) * 0.0254,  # inches to meters
                                    'mid_Xx': safe_float(row[5]),  # Direction cosines (unitless)
                                    'mid_Xy': safe_float(row[6]),
                                    'mid_Xz': safe_float(row[7]),
                                    'mid_Yx': safe_float(row[8]),
                                    'mid_Yy': safe_float(row[9]),
                                    'mid_Yz': safe_float(row[10]),
                                    'mid_Zx': safe_float(row[11]),
                                    'mid_Zy': safe_float(row[12]),
                                    'mid_Zz': safe_float(row[13]),
                                    # Club head position (convert inches to meters) and orientation (columns 14-25)
                                    'club_X': safe_float(row[14]) * 0.0254,  # inches to meters
                                    'club_Y': safe_float(row[15]) * 0.0254,  # inches to meters
                                    'club_Z': safe_float(row[16]) * 0.0254,  # inches to meters
                                    'club_Xx': safe_float(row[17]),  # Direction cosines (unitless)
                                    'club_Xy': safe_float(row[18]),
                                    'club_Xz': safe_float(row[19]),
                                    'club_Yx': safe_float(row[20]),
                                    'club_Yy': safe_float(row[21]),
                                    'club_Yz': safe_float(row[22]),
                                    'club_Zx': safe_float(row[23]),
                                    'club_Zy': safe_float(row[24]),
                                    'club_Zz': safe_float(row[25])
                                }
                                data.append(frame_data)
                        
                        if data:
                            self.swing_data[sheet_name] = pd.DataFrame(data)
                            print(f"Successfully loaded {len(data)} frames for {sheet_name}")
                            self.print_data_debug(sheet_name)
            
            # Update swing selection
            self.swing_combo.clear()
            self.swing_combo.addItems(list(self.swing_data.keys()))
            
            if self.swing_data:
                self.current_swing = list(self.swing_data.keys())[0]
                print(f"Selected swing: {self.current_swing}")
                self.swing_combo.setCurrentText(self.current_swing)
                self.setup_frame_slider()
                self.update_visualization()
            else:
                print("No valid swing data found in the file")
                
        except Exception as e:
            print(f"Error loading file: {str(e)}")
            QMessageBox.critical(self, "Error", f"Failed to load file: {str(e)}")
    
    def load_simscape_csv(self, filename):
        """Load and process Simscape CSV file"""
        try:
            print(f"Loading Simscape CSV file: {filename}")
            
            # Read the CSV file
            df = pd.read_csv(filename)
            print(f"Successfully loaded CSV with {len(df)} rows and {len(df.columns)} columns")
            print(f"Time range: {df['time'].min():.3f} to {df['time'].max():.3f} seconds")
            
            # Define the key joint positions for golf swing visualization
            joint_positions = {
                'club_head': ['ClubLogs_CHGlobalPosition_1', 'ClubLogs_CHGlobalPosition_2', 'ClubLogs_CHGlobalPosition_3'],
                'left_hand': ['LWLogs_LHGlobalPosition_1', 'LWLogs_LHGlobalPosition_2', 'LWLogs_LHGlobalPosition_3'],
                'right_hand': ['RWLogs_RHGlobalPosition_1', 'RWLogs_RHGlobalPosition_2', 'RWLogs_RHGlobalPosition_3'],
                'left_shoulder': ['LSLogs_GlobalPosition_1', 'LSLogs_GlobalPosition_2', 'LSLogs_GlobalPosition_3'],
                'right_shoulder': ['RSLogs_GlobalPosition_1', 'RSLogs_GlobalPosition_2', 'RSLogs_GlobalPosition_3'],
                'left_elbow': ['LELogs_LArmonLForearmFGlobal_1', 'LELogs_LArmonLForearmFGlobal_2', 'LELogs_LArmonLForearmFGlobal_3'],
                'right_elbow': ['RELogs_RArmonLForearmFGlobal_1', 'RELogs_RArmonLForearmFGlobal_2', 'RELogs_RArmonLForearmFGlobal_3'],
                'hub': ['HipLogs_HUBGlobalPosition_1', 'HipLogs_HUBGlobalPosition_2', 'HipLogs_HUBGlobalPosition_3'],
                'spine': ['SpineLogs_GlobalPosition_1', 'SpineLogs_GlobalPosition_2', 'SpineLogs_GlobalPosition_3'],
                'hip': ['HipLogs_HipGlobalPosition_dim1', 'HipLogs_HipGlobalPosition_dim2', 'HipLogs_HipGlobalPosition_dim3']
            }
            
            # Check which joint positions are available
            available_joints = {}
            for joint_name, columns in joint_positions.items():
                if all(col in df.columns for col in columns):
                    available_joints[joint_name] = columns
                    print(f"✓ {joint_name}: AVAILABLE")
                else:
                    missing_cols = [col for col in columns if col not in df.columns]
                    print(f"✗ {joint_name}: MISSING {len(missing_cols)} columns")
            
            if not available_joints:
                raise ValueError("No valid joint position data found in the CSV file")
            
            # Process the data into our standard format
            data = []
            for i, row in df.iterrows():
                frame_data = {'time': row['time']}
                
                # Add available joint positions
                for joint_name, columns in available_joints.items():
                    if all(col in df.columns for col in columns):
                        frame_data[f'{joint_name}_X'] = row[columns[0]]
                        frame_data[f'{joint_name}_Y'] = row[columns[1]]
                        frame_data[f'{joint_name}_Z'] = row[columns[2]]
                
                data.append(frame_data)
            
            # Store the data
            swing_name = "Simscape_Swing"
            self.swing_data[swing_name] = pd.DataFrame(data)
            print(f"Successfully loaded {len(data)} frames for {swing_name}")
            
            # Update swing selection
            self.swing_combo.clear()
            self.swing_combo.addItems(list(self.swing_data.keys()))
            
            if self.swing_data:
                self.current_swing = swing_name
                print(f"Selected swing: {self.current_swing}")
                self.swing_combo.setCurrentText(self.current_swing)
                self.setup_frame_slider()
                self.update_visualization()
            else:
                print("No valid swing data found in the file")
                
        except Exception as e:
            print(f"Error loading Simscape CSV file: {str(e)}")
            QMessageBox.critical(self, "Error", f"Failed to load Simscape CSV file: {str(e)}")
            
    def print_data_debug(self, sheet_name):
        """Print debug information about the loaded data"""
        if sheet_name in self.swing_data:
            data = self.swing_data[sheet_name]
            if not data.empty:
                print(f"\n=== Data Debug for {sheet_name} ===")
                print(f"Number of frames: {len(data)}")
                print(f"Time range: {data['time'].min():.3f} to {data['time'].max():.3f} seconds")
                print(f"Mid-Hands Position ranges:")
                print(f"  X: {data['mid_X'].min():.3f} to {data['mid_X'].max():.3f}")
                print(f"  Y: {data['mid_Y'].min():.3f} to {data['mid_Y'].max():.3f}")
                print(f"  Z: {data['mid_Z'].min():.3f} to {data['mid_Z'].max():.3f}")
                
                print(f"Club Head Position ranges:")
                print(f"  X: {data['club_X'].min():.3f} to {data['club_X'].max():.3f}")
                print(f"  Y: {data['club_Y'].min():.3f} to {data['club_Y'].max():.3f}")
                print(f"  Z: {data['club_Z'].min():.3f} to {data['club_Z'].max():.3f}")
                
                # Calculate total position ranges
                mid_range = np.max([data['mid_X'].max() - data['mid_X'].min(),
                                  data['mid_Y'].max() - data['mid_Y'].min(),
                                  data['mid_Z'].max() - data['mid_Z'].min()])
                club_range = np.max([data['club_X'].max() - data['club_X'].min(),
                                   data['club_Y'].max() - data['club_Y'].min(),
                                   data['club_Z'].max() - data['club_Z'].min()])
                
                print(f"Mid-Hands motion range: {mid_range:.3f}")
                print(f"Club Head motion range: {club_range:.3f}")
                
                print("Data Analysis:")
                print("  This data contains both mid-hands and club head positions")
                print("  Using actual measured positions instead of calculated ones")
                print("  Original data in inches, converted to meters for visualization")
                print("  Direction cosines (Xx, Xy, Xz, Yx, Yy, Yz, Zx, Zy, Zz) are unitless")
                print("  Motion scaling applied to make visualization clearer")
                print("=" * 40)
                
    def setup_frame_slider(self):
        """Setup the frame slider"""
        if self.current_swing in self.swing_data:
            data = self.swing_data[self.current_swing]
            max_frame = len(data) - 1
            self.frame_slider.setRange(0, max_frame)
            self.frame_slider.setValue(0)
            self.current_frame = 0
            
    def on_swing_change(self, swing_name):
        """Handle swing selection change"""
        if swing_name in self.swing_data:
            self.current_swing = swing_name
            self.setup_frame_slider()
            self.update_visualization()
            
    def on_frame_change(self, frame):
        """Handle frame slider change"""
        self.current_frame = frame
        self.frame_label.setText(str(frame))
        self.update_visualization()
        
    def on_speed_change(self, speed):
        """Handle speed slider change"""
        self.speed_label.setText(str(speed))
        if self.is_playing:
            self.animation_timer.setInterval(1000 // speed)
            
    def on_scale_change(self, scale):
        """Handle motion scale change"""
        self.motion_scale = scale
        self.scale_label.setText(f"{scale}x")
        self.update_visualization()
        
    def on_club_length_change(self, length_cm):
        """Handle club length change"""
        self.shaft_length = length_cm / 100.0  # Convert cm to meters
        self.club_label.setText(f"{self.shaft_length:.1f}m")
        self.update_visualization()
        
    def toggle_playback(self):
        """Toggle play/pause"""
        if self.is_playing:
            self.animation_timer.stop()
            self.play_btn.setText("Play")
            self.is_playing = False
        else:
            speed = self.speed_slider.value()
            self.animation_timer.start(1000 // speed)
            self.play_btn.setText("Pause")
            self.is_playing = True
            
    def next_frame(self):
        """Advance to next frame"""
        if self.current_swing in self.swing_data:
            data = self.swing_data[self.current_swing]
            if self.current_frame < len(data) - 1:
                self.current_frame += 1
                self.frame_slider.setValue(self.current_frame)
            else:
                # Loop back to start
                self.current_frame = 0
                self.frame_slider.setValue(0)
                
    def setup_3d_scene(self):
        """Setup the 3D scene with ground plane and ball"""
        self.ax.clear()
        
        # Ground plane - adjusted for golf swing coordinate system
        x_ground = np.linspace(-3, 3, 10)
        y_ground = np.linspace(-3, 3, 10)
        X_ground, Y_ground = np.meshgrid(x_ground, y_ground)
        Z_ground = np.zeros_like(X_ground) - 0.1
        self.ax.plot_surface(X_ground, Y_ground, Z_ground, alpha=0.3, color='green')
        
        # Golf ball - positioned at origin for golf swing analysis
        u = np.linspace(0, 2 * np.pi, 20)
        v = np.linspace(0, np.pi, 20)
        ball_radius = 0.021
        x_ball = ball_radius * np.outer(np.cos(u), np.sin(v))
        y_ball = ball_radius * np.outer(np.sin(u), np.sin(v))
        z_ball = ball_radius * np.outer(np.ones(np.size(u)), np.cos(v))
        self.ax.plot_surface(x_ball, y_ball, z_ball, color='white', alpha=0.8)
        
        # Set axis labels and limits
        self.ax.set_xlabel('X (Target Line)')
        self.ax.set_ylabel('Y (Ball Direction)')
        self.ax.set_zlabel('Z (Vertical)')
        self.ax.set_xlim([-2.0, 2.0])
        self.ax.set_ylim([-1.0, 3.0])
        self.ax.set_zlim([-0.5, 2.5])
        
        # Set initial view
        self.ax.view_init(elev=15, azim=-45)
        
    def update_visualization(self):
        """Update the 3D visualization with proper coordinate system"""
        if self.current_swing not in self.swing_data:
            return
            
        data = self.swing_data[self.current_swing]
        if data.empty or self.current_frame >= len(data):
            return
            
        # Get current frame data
        frame_data = data.iloc[self.current_frame]
        
        # Clear and setup scene
        self.setup_3d_scene()
        
        # Determine data source and visualize accordingly
        if self.current_data_source == "Motion Capture (Excel)":
            self.visualize_motion_capture_data(frame_data, data)
        else:  # Simscape Multibody (CSV)
            self.visualize_simscape_data(frame_data, data)
        
        # Update info text
        self.update_info_text(frame_data)
        
        # Redraw canvas
        self.canvas.draw()
    
    def visualize_motion_capture_data(self, frame_data, data):
        """Visualize motion capture data (Excel format)"""
        # Use actual mid-hands and club head positions from the data
        # For right-handed golfers: X should be flipped to show proper swing direction
        mid_hands = np.array([
            -frame_data['mid_X'] * self.motion_scale,  # Flip X for right-handed swing
            frame_data['mid_Y'] * self.motion_scale,
            frame_data['mid_Z'] * self.motion_scale
        ])
        
        club_head = np.array([
            -frame_data['club_X'] * self.motion_scale,  # Flip X for right-handed swing
            frame_data['club_Y'] * self.motion_scale,
            frame_data['club_Z'] * self.motion_scale
        ])
        
        # Draw the club shaft (line from mid-hands to club head)
        shaft_points = np.array([mid_hands, club_head])
        self.ax.plot(shaft_points[:, 0], shaft_points[:, 1], shaft_points[:, 2], 
                    'b-', linewidth=8, alpha=0.8, label='Club Shaft')
        
        # Draw club head as a sphere at the actual club head position
        u = np.linspace(0, 2 * np.pi, 8)
        v = np.linspace(0, np.pi, 8)
        head_size = 0.05  # Fixed size for club head
        x_head = head_size * np.outer(np.cos(u), np.sin(v)) + club_head[0]
        y_head = head_size * np.outer(np.sin(u), np.sin(v)) + club_head[1]
        z_head = head_size * np.outer(np.ones(np.size(u)), np.cos(v)) + club_head[2]
        self.ax.plot_surface(x_head, y_head, z_head, color='red', alpha=0.8, label='Club Head')
        
        # Draw trajectory paths
        if self.trajectory_check.isChecked() and len(data) > 1:
            # Mid-hands path (blue dashed) - flip X for right-handed swing
            trajectory = np.array([[-row['mid_X'] * self.motion_scale, 
                                  row['mid_Y'] * self.motion_scale, 
                                  row['mid_Z'] * self.motion_scale] for _, row in data.iterrows()])
            self.ax.plot(trajectory[:, 0], trajectory[:, 1], trajectory[:, 2], 
                        'b--', alpha=0.6, linewidth=2, label='Mid-Hands Path')
        
        if self.club_path_check.isChecked() and len(data) > 1:
            # Club head path (red dashed) - flip X for right-handed swing
            club_path = np.array([[-row['club_X'] * self.motion_scale, 
                                  row['club_Y'] * self.motion_scale, 
                                  row['club_Z'] * self.motion_scale] for _, row in data.iterrows()])
            self.ax.plot(club_path[:, 0], club_path[:, 1], club_path[:, 2], 
                        'r--', alpha=0.6, linewidth=2, label='Club Head Path')
    
    def visualize_simscape_data(self, frame_data, data):
        """Visualize Simscape multibody data (CSV format)"""
        # Define colors for different body segments
        colors = {
            'club': 'red',
            'hands': 'blue',
            'arms': 'green',
            'shoulders': 'orange',
            'torso': 'purple',
            'hips': 'brown'
        }
        
        # Draw golf swing skeleton
        joints = {}
        
        # Extract joint positions from frame data
        for joint_name in ['club_head', 'left_hand', 'right_hand', 'left_shoulder', 
                          'right_shoulder', 'left_elbow', 'right_elbow', 'hub', 'spine', 'hip']:
            if f'{joint_name}_X' in frame_data:
                joints[joint_name] = np.array([
                    frame_data[f'{joint_name}_X'] * self.motion_scale,
                    frame_data[f'{joint_name}_Y'] * self.motion_scale,
                    frame_data[f'{joint_name}_Z'] * self.motion_scale
                ])
        
        # Draw segments connecting joints
        segments = [
            ('left_hand', 'right_hand', colors['hands']),  # Midpoint
            ('left_hand', 'left_elbow', colors['arms']),
            ('right_hand', 'right_elbow', colors['arms']),
            ('left_elbow', 'left_shoulder', colors['arms']),
            ('right_elbow', 'right_shoulder', colors['arms']),
            ('left_shoulder', 'right_shoulder', colors['shoulders']),
            ('left_shoulder', 'hub', colors['torso']),
            ('right_shoulder', 'hub', colors['torso']),
            ('hub', 'spine', colors['torso']),
            ('spine', 'hip', colors['torso'])
        ]
        
        # Draw club if available
        if 'club_head' in joints and 'left_hand' in joints:
            # Draw club shaft from left hand to club head
            club_points = np.array([joints['left_hand'], joints['club_head']])
            self.ax.plot(club_points[:, 0], club_points[:, 1], club_points[:, 2], 
                        color=colors['club'], linewidth=6, alpha=0.8, label='Club')
            
            # Draw club head as sphere
            u = np.linspace(0, 2 * np.pi, 8)
            v = np.linspace(0, np.pi, 8)
            head_size = 0.03
            x_head = head_size * np.outer(np.cos(u), np.sin(v)) + joints['club_head'][0]
            y_head = head_size * np.outer(np.sin(u), np.sin(v)) + joints['club_head'][1]
            z_head = head_size * np.outer(np.ones(np.size(u)), np.cos(v)) + joints['club_head'][2]
            self.ax.plot_surface(x_head, y_head, z_head, color=colors['club'], alpha=0.8)
        
        # Draw body segments
        for start_joint, end_joint, color in segments:
            if start_joint in joints and end_joint in joints:
                segment_points = np.array([joints[start_joint], joints[end_joint]])
                self.ax.plot(segment_points[:, 0], segment_points[:, 1], segment_points[:, 2], 
                            color=color, linewidth=3, alpha=0.7)
        
        # Draw joint markers
        for joint_name, position in joints.items():
            self.ax.scatter(position[0], position[1], position[2], 
                          color='black', s=50, alpha=0.8)
        
        # Draw trajectory paths if enabled
        if self.trajectory_check.isChecked() and len(data) > 1:
            # Club head trajectory
            if 'club_head' in joints:
                club_trajectory = np.array([[row[f'club_head_X'] * self.motion_scale,
                                           row[f'club_head_Y'] * self.motion_scale,
                                           row[f'club_head_Z'] * self.motion_scale] 
                                          for _, row in data.iterrows() if f'club_head_X' in row])
                if len(club_trajectory) > 1:
                    self.ax.plot(club_trajectory[:, 0], club_trajectory[:, 1], club_trajectory[:, 2], 
                                'r--', alpha=0.6, linewidth=2, label='Club Head Path')
        
        if self.club_path_check.isChecked() and len(data) > 1:
            # Hands trajectory
            if 'left_hand' in joints:
                hands_trajectory = np.array([[row[f'left_hand_X'] * self.motion_scale,
                                            row[f'left_hand_Y'] * self.motion_scale,
                                            row[f'left_hand_Z'] * self.motion_scale] 
                                           for _, row in data.iterrows() if f'left_hand_X' in row])
                if len(hands_trajectory) > 1:
                    self.ax.plot(hands_trajectory[:, 0], hands_trajectory[:, 1], hands_trajectory[:, 2], 
                                'b--', alpha=0.6, linewidth=2, label='Hands Path')
        
    def update_info_text(self, frame_data):
        """Update the information text display"""
        info = f"Frame: {self.current_frame}\n"
        info += f"Time: {frame_data['time']:.3f}s\n"
        info += f"Data Source: {self.current_data_source}\n"
        info += f"Motion Scale: {self.motion_scale}x\n\n"
        
        if self.current_data_source == "Motion Capture (Excel)":
            info += f"Mid-Hands Position:\n"
            info += f"  X: {frame_data['mid_X']:.3f}\n"
            info += f"  Y: {frame_data['mid_Y']:.3f}\n"
            info += f"  Z: {frame_data['mid_Z']:.3f}\n"
            info += f"Club Head Position:\n"
            info += f"  X: {frame_data['club_X']:.3f}\n"
            info += f"  Y: {frame_data['club_Y']:.3f}\n"
            info += f"  Z: {frame_data['club_Z']:.3f}\n"
        else:  # Simscape Multibody (CSV)
            info += f"Available Joints:\n"
            joint_count = 0
            for joint_name in ['club_head', 'left_hand', 'right_hand', 'left_shoulder', 
                              'right_shoulder', 'left_elbow', 'right_elbow', 'hub', 'spine', 'hip']:
                if f'{joint_name}_X' in frame_data:
                    info += f"  {joint_name}: ✓\n"
                    joint_count += 1
                else:
                    info += f"  {joint_name}: ✗\n"
            info += f"\nTotal Joints: {joint_count}"
        
        self.info_text.setText(info)
        
    def set_camera_view(self, view):
        """Set predefined camera views"""
        if view == 'face_on':
            # Face-on view: looking at golfer from front
            self.ax.view_init(elev=0, azim=0)
        elif view == 'down_line':
            # Down-the-line view: looking from behind golfer toward target
            self.ax.view_init(elev=0, azim=180)
        elif view == 'top_down':
            # Top-down view: looking down from above
            self.ax.view_init(elev=90, azim=0)
        elif view == 'isometric':
            # Isometric view: 3D perspective
            self.ax.view_init(elev=15, azim=-45)
            
        # Force redraw
        self.canvas.draw_idle()
        self.canvas.flush_events()
        
    def reset_view(self):
        """Reset the 3D view to the default isometric view and limits"""
        # Reset view angles
        self.ax.view_init(elev=15, azim=-45)
        
        # Reset plot limits to default
        self.ax.set_xlim([-2.0, 2.0])
        self.ax.set_ylim([-1.0, 3.0])
        self.ax.set_zlim([-0.5, 2.5])
        
        # Force redraw
        self.canvas.draw_idle()
        self.canvas.flush_events()
        
    def on_scroll(self, event):
        """Handle mouse scroll for zooming"""
        if event.inaxes != self.ax:
            return
            
        print(f"Scroll event: button={event.button}, step={event.step}")
        
        # Get current view limits
        x_lim = self.ax.get_xlim()
        y_lim = self.ax.get_ylim()
        z_lim = self.ax.get_zlim()
        
        # Determine zoom factor based on scroll direction
        if event.button == 'up' or event.step > 0:
            zoom_factor = 0.9  # Zoom in
        else:
            zoom_factor = 1.1  # Zoom out
        
        # Calculate centers
        x_center = (x_lim[0] + x_lim[1]) / 2
        y_center = (y_lim[0] + y_lim[1]) / 2
        z_center = (z_lim[0] + z_lim[1]) / 2
        
        # Calculate new ranges
        x_range = (x_lim[1] - x_lim[0]) * zoom_factor
        y_range = (y_lim[1] - y_lim[0]) * zoom_factor
        z_range = (z_lim[1] - z_lim[0]) * zoom_factor
        
        # Set new limits
        self.ax.set_xlim([x_center - x_range/2, x_center + x_range/2])
        self.ax.set_ylim([y_center - y_range/2, y_center + y_range/2])
        self.ax.set_zlim([z_center - z_range/2, z_center + z_range/2])
        
        self.canvas.draw()
        print(f"Zooming: factor={zoom_factor}")
        
    def on_mouse_press(self, event):
        """Handle mouse button press for rotation/panning"""
        if event.inaxes != self.ax:
            return
        # Store initial position for rotation/panning (use screen coordinates)
        self._last_pos = (event.x, event.y)
        print(f"Mouse press: button={event.button}, pos=({event.x}, {event.y})")
        
    def on_mouse_release(self, event):
        """Handle mouse button release"""
        self._last_pos = None
        
    def on_mouse_move(self, event):
        """Handle mouse movement for rotation/panning"""
        if event.inaxes != self.ax or self._last_pos is None:
            return
            
        if hasattr(event, 'button') and event.button == 1:  # Left click - rotate
            # Get current view angles
            elev = self.ax.elev
            azim = self.ax.azim
            
            # Calculate change in position (use screen coordinates for better control)
            dx = event.x - self._last_pos[0]
            dy = event.y - self._last_pos[1]
            
            # Update view angles (scale the movement)
            self.ax.view_init(elev=elev + dy * 0.5, azim=azim + dx * 0.5)
            self.canvas.draw()
            print(f"Rotating: dx={dx}, dy={dy}, new_elev={elev + dy * 0.5}, new_azim={azim + dx * 0.5}")
            
        elif hasattr(event, 'button') and event.button == 3:  # Right click - pan
            # Get current limits
            x_lim = self.ax.get_xlim()
            y_lim = self.ax.get_ylim()
            z_lim = self.ax.get_zlim()
            
            # Calculate change in position (use screen coordinates)
            dx = event.x - self._last_pos[0]
            dy = event.y - self._last_pos[1]
            
            # Update limits (scale the movement)
            x_range = x_lim[1] - x_lim[0]
            y_range = y_lim[1] - y_lim[0]
            z_range = z_lim[1] - z_lim[0]
            
            pan_scale = 0.01  # Adjust this for panning sensitivity
            
            self.ax.set_xlim([x_lim[0] - dx * x_range * pan_scale, x_lim[1] - dx * x_range * pan_scale])
            self.ax.set_ylim([y_lim[0] + dy * y_range * pan_scale, y_lim[1] + dy * y_range * pan_scale])
            self.canvas.draw()
            print(f"Panning: dx={dx}, dy={dy}")
            
        self._last_pos = (event.x, event.y)

def main():
    app = QApplication(sys.argv)
    window = MotionCapturePlotter()
    window.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main() 