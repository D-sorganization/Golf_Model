#!/usr/bin/env python3
"""
Golf Swing Visualizer - Tabular GUI Application
Supports multiple data sources including motion capture and future Simulink models
"""

import os
import sys
import traceback
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import moderngl as mgl
import numpy as np
import pandas as pd
# Local imports
from golf_data_core import FrameData, FrameProcessor, RenderConfig
from golf_opengl_renderer import OpenGLRenderer
from PyQt6.QtCore import (QEasingCurve, QPoint, QPropertyAnimation, QRect,
                          QRunnable, QSize, Qt, QThread, QThreadPool, QTimer,
                          pyqtSignal, pyqtSlot)
from PyQt6.QtGui import (QAction, QActionGroup, QBrush, QColor, QFont, QIcon,
                         QKeySequence, QPainter, QPalette, QPen, QPixmap,
                         QShortcut)
# OpenGL imports
from PyQt6.QtOpenGLWidgets import QOpenGLWidget
# PyQt6 imports
from PyQt6.QtWidgets import (QApplication, QCheckBox, QComboBox,
                             QDoubleSpinBox, QFileDialog, QFrame, QGridLayout,
                             QGroupBox, QHBoxLayout, QLabel, QMainWindow,
                             QMenu, QMenuBar, QMessageBox, QProgressBar,
                             QPushButton, QSlider, QSpinBox, QSplitter,
                             QStatusBar, QTabWidget, QTextEdit, QToolBar,
                             QVBoxLayout, QWidget)
from wiffle_data_loader import MotionDataLoader

# ============================================================================
# TAB WIDGETS
# ============================================================================


class MotionCaptureTab(QWidget):
    """Tab for motion capture data visualization"""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.parent = parent
        self.frame_processor = None
        self.current_frame = 0
        self.is_playing = False
        self.playback_timer = QTimer()
        self.playback_timer.timeout.connect(self._next_frame)

        self._setup_ui()
        self._setup_connections()

    def _setup_ui(self):
        """Setup the motion capture tab UI"""
        layout = QVBoxLayout()

        # Control panel
        control_panel = self._create_control_panel()
        layout.addWidget(control_panel)

        # 3D visualization area
        self.opengl_widget = GolfVisualizerWidget()
        layout.addWidget(self.opengl_widget)

        # Status bar
        self.status_label = QLabel("Ready - Load motion capture data to begin")
        layout.addWidget(self.status_label)

        self.setLayout(layout)

    def _create_control_panel(self):
        """Create the control panel for motion capture data"""
        panel = QGroupBox("Motion Capture Controls")
        layout = QGridLayout()

        # Data selection
        layout.addWidget(QLabel("Swing Type:"), 0, 0)
        self.swing_combo = QComboBox()
        self.swing_combo.addItems(["TW Wiffle", "TW ProV1", "GW Wiffle", "GW ProV1"])
        layout.addWidget(self.swing_combo, 0, 1)

        # Load button
        self.load_button = QPushButton("Load Data")
        self.load_button.setMaximumWidth(100)  # Make button smaller
        layout.addWidget(self.load_button, 0, 2)

        # Playback controls
        layout.addWidget(QLabel("Playback:"), 1, 0)

        self.play_button = QPushButton("Play")
        layout.addWidget(self.play_button, 1, 1)

        self.frame_slider = QSlider(Qt.Orientation.Horizontal)
        self.frame_slider.setMinimum(0)
        self.frame_slider.setMaximum(100)
        layout.addWidget(self.frame_slider, 1, 2)

        self.frame_label = QLabel("Frame: 0/0")
        layout.addWidget(self.frame_label, 1, 3)

        # Visualization options
        layout.addWidget(QLabel("Display:"), 2, 0)

        self.show_body_check = QCheckBox("Body Segments")
        self.show_body_check.setChecked(True)
        layout.addWidget(self.show_body_check, 2, 1)

        self.show_club_check = QCheckBox("Golf Club")
        self.show_club_check.setChecked(True)
        layout.addWidget(self.show_club_check, 2, 2)

        self.show_ground_check = QCheckBox("Ground")
        self.show_ground_check.setChecked(True)
        layout.addWidget(self.show_ground_check, 2, 3)

        panel.setLayout(layout)
        return panel

    def _setup_connections(self):
        """Setup signal connections"""
        self.load_button.clicked.connect(self._load_motion_capture_data)
        self.play_button.clicked.connect(self._toggle_playback)
        self.frame_slider.valueChanged.connect(self._on_frame_changed)
        self.swing_combo.currentTextChanged.connect(self._on_swing_changed)

        # Visualization checkboxes
        self.show_body_check.toggled.connect(self._update_visualization)
        self.show_club_check.toggled.connect(self._update_visualization)
        self.show_ground_check.toggled.connect(self._update_visualization)

    def _load_motion_capture_data(self):
        """Load motion capture data"""
        try:
            swing_type = self.swing_combo.currentText()
            self.status_label.setText(f"Loading {swing_type} data...")

            # Load data using the existing MotionDataLoader
            loader = MotionDataLoader()
            excel_data = loader.load_data()  # Load the Excel data first
            baseq_data, ztcfq_data, deltaq_data = loader.convert_to_gui_format(
                excel_data
            )

            # Create frame processor with config
            config = RenderConfig()
            self.frame_processor = FrameProcessor(
                (baseq_data, ztcfq_data, deltaq_data), config
            )

            # Update UI
            total_frames = len(self.frame_processor.time_vector)
            self.frame_slider.setMaximum(total_frames - 1)
            self.frame_label.setText(f"Frame: 0/{total_frames}")

            # Initialize visualization
            self.opengl_widget.load_data_from_dataframes(
                (baseq_data, ztcfq_data, deltaq_data)
            )

            self.status_label.setText(f"Loaded {swing_type} data successfully")

        except Exception as e:
            self.status_label.setText(f"Error loading data: {str(e)}")
            traceback.print_exc()

    def _on_swing_changed(self, swing_type: str):
        """Handle swing type change"""
        if self.frame_processor is not None:
            self._load_motion_capture_data()

    def _toggle_playback(self):
        """Toggle playback"""
        if not self.frame_processor:
            return

        if self.is_playing:
            self.play_button.setText("Play")
            self.playback_timer.stop()
            self.is_playing = False
        else:
            self.play_button.setText("Pause")
            self.playback_timer.start(33)  # ~30 FPS
            self.is_playing = True

    def _next_frame(self):
        """Advance to next frame"""
        if not self.frame_processor:
            return

        current_frame = self.frame_slider.value()
        total_frames = len(self.frame_processor.time_vector)

        next_frame = (current_frame + 1) % total_frames
        self.frame_slider.setValue(next_frame)

    def _on_frame_changed(self, frame_index: int):
        """Handle frame slider change"""
        if not self.frame_processor:
            return

        total_frames = len(self.frame_processor.time_vector)
        self.frame_label.setText(f"Frame: {frame_index}/{total_frames}")

        # Update visualization
        self._update_visualization()

    def _update_visualization(self):
        """Update the 3D visualization"""
        if not self.frame_processor or not self.opengl_widget.renderer:
            return

        try:
            frame_index = self.frame_slider.value()
            frame_data = self.frame_processor.get_frame_data(frame_index)

            # Update render config
            render_config = RenderConfig()
            render_config.show_body_segments = {
                "left_forearm": self.show_body_check.isChecked(),
                "left_upper_arm": self.show_body_check.isChecked(),
                "right_forearm": self.show_body_check.isChecked(),
                "right_upper_arm": self.show_body_check.isChecked(),
                "left_shoulder_neck": self.show_body_check.isChecked(),
                "right_shoulder_neck": self.show_body_check.isChecked(),
            }
            render_config.show_club = self.show_club_check.isChecked()
            render_config.show_ground = self.show_ground_check.isChecked()

            # Update visualization
            self.opengl_widget.update_frame(frame_data, render_config)

        except Exception as e:
            self.status_label.setText(f"Visualization error: {str(e)}")


class SimulinkModelTab(QWidget):
    """Tab for Simulink model data visualization (future)"""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.parent = parent
        self._setup_ui()

    def _setup_ui(self):
        """Setup the Simulink model tab UI"""
        layout = QVBoxLayout()

        # Placeholder for future Simulink integration
        placeholder = QLabel(
            "Simulink Model Integration\n\nThis tab will support:\n"
            "• Loading Simulink model outputs\n"
            "• Comparing with motion capture data\n"
            "• Real-time model validation\n"
            "• Hand midpoint tracking analysis"
        )
        placeholder.setAlignment(Qt.AlignmentFlag.AlignCenter)
        placeholder.setStyleSheet(
            """
            QLabel {
                font-size: 16px;
                color: #666;
                padding: 40px;
                border: 2px dashed #ccc;
                border-radius: 10px;
                background-color: #f9f9f9;
            }
        """
        )

        layout.addWidget(placeholder)
        self.setLayout(layout)


class ComparisonTab(QWidget):
    """Tab for comparing motion capture vs Simulink model data"""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.parent = parent
        self._setup_ui()

    def _setup_ui(self):
        """Setup the comparison tab UI"""
        layout = QVBoxLayout()

        # Placeholder for comparison functionality
        placeholder = QLabel(
            "Data Comparison Analysis\n\nThis tab will support:\n"
            "• Side-by-side visualization\n"
            "• Hand midpoint tracking accuracy\n"
            "• Error analysis and metrics\n"
            "• Performance optimization feedback"
        )
        placeholder.setAlignment(Qt.AlignmentFlag.AlignCenter)
        placeholder.setStyleSheet(
            """
            QLabel {
                font-size: 16px;
                color: #666;
                padding: 40px;
                border: 2px dashed #ccc;
                border-radius: 10px;
                background-color: #f9f9f9;
            }
        """
        )

        layout.addWidget(placeholder)
        self.setLayout(layout)


# ============================================================================
# OPENGL WIDGET
# ============================================================================


class GolfVisualizerWidget(QOpenGLWidget):
    """OpenGL widget for 3D golf swing visualization"""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.renderer = None
        self.frame_processor = None
        self.current_frame_data = None
        self.current_render_config = None

        # Camera state - Fixed for proper golf views
        self.camera_distance = 3.0
        self.camera_azimuth = 0.0  # Face-on view (looking at golfer from front)
        self.camera_elevation = 15.0  # Slightly elevated for better view
        self.camera_target = np.array([0.0, 0.0, 0.0], dtype=np.float32)

        # Ground level tracking
        self.ground_level = 0.0

        # Mouse interaction
        self.last_mouse_pos = None
        self.mouse_pressed = False

        # Set focus policy for keyboard events
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)

    def initializeGL(self):
        """Initialize OpenGL context"""
        try:
            # Create moderngl context
            self.ctx = mgl.create_context()

            # Initialize renderer
            self.renderer = OpenGLRenderer()
            self.renderer.initialize(self.ctx)

            # Set viewport
            self.renderer.set_viewport(self.width(), self.height())

            print("✅ OpenGL context initialized")
            print(f"   Version: {self.ctx.info['GL_VERSION']}")
            print(f"   Vendor: {self.ctx.info['GL_VENDOR']}")
            print(f"   Renderer: {self.ctx.info['GL_RENDERER']}")

        except Exception as e:
            print(f"❌ OpenGL initialization failed: {e}")
            traceback.print_exc()

    def resizeGL(self, w: int, h: int):
        """Handle OpenGL widget resize"""
        if self.renderer:
            self.renderer.set_viewport(w, h)

    def paintGL(self):
        """Render the OpenGL scene"""
        if not self.renderer or not self.current_frame_data:
            return

        try:
            # Calculate view and projection matrices
            view_matrix = self._calculate_view_matrix()
            proj_matrix = self._calculate_projection_matrix()
            view_position = self._calculate_view_position()

            # Pass ground level to renderer
            if hasattr(self.renderer, "ground_level"):
                self.renderer.ground_level = self.ground_level

            # Render frame
            self.renderer.render_frame(
                self.current_frame_data,
                {},  # Empty dynamics data for now
                self.current_render_config or RenderConfig(),
                view_matrix,
                proj_matrix,
                view_position,
            )

        except Exception as e:
            print(f"❌ Render error: {e}")

    def _calculate_view_matrix(self) -> np.ndarray:
        """Calculate view matrix from camera parameters"""
        # Convert spherical coordinates to Cartesian
        x = (
            self.camera_distance
            * np.cos(np.radians(self.camera_elevation))
            * np.cos(np.radians(self.camera_azimuth))
        )
        y = self.camera_distance * np.sin(np.radians(self.camera_elevation))
        z = (
            self.camera_distance
            * np.cos(np.radians(self.camera_elevation))
            * np.sin(np.radians(self.camera_azimuth))
        )

        camera_pos = np.array([x, y, z], dtype=np.float32) + self.camera_target

        # Look-at matrix
        forward = self.camera_target - camera_pos
        forward_norm = np.linalg.norm(forward)
        if forward_norm > 1e-6:
            forward = forward / forward_norm
        else:
            forward = np.array(
                [0, 0, -1], dtype=np.float32
            )  # Default forward direction

        right = np.cross(forward, np.array([0, 1, 0], dtype=np.float32))
        right_norm = np.linalg.norm(right)
        if right_norm > 1e-6:
            right = right / right_norm
        else:
            right = np.array([1, 0, 0], dtype=np.float32)  # Default right direction

        up = np.cross(right, forward)

        view_matrix = np.eye(4, dtype=np.float32)
        view_matrix[:3, 0] = right
        view_matrix[:3, 1] = up
        view_matrix[:3, 2] = -forward
        view_matrix[:3, 3] = -camera_pos

        return view_matrix

    def _calculate_projection_matrix(self) -> np.ndarray:
        """Calculate projection matrix"""
        aspect = self.width() / max(self.height(), 1)
        fov = 45.0
        near = 0.1
        far = 100.0

        f = 1.0 / np.tan(np.radians(fov) / 2.0)

        proj_matrix = np.array(
            [
                [f / aspect, 0, 0, 0],
                [0, f, 0, 0],
                [0, 0, (far + near) / (near - far), (2 * far * near) / (near - far)],
                [0, 0, -1, 0],
            ],
            dtype=np.float32,
        )

        return proj_matrix

    def _calculate_view_position(self) -> np.ndarray:
        """Calculate view position"""
        x = (
            self.camera_distance
            * np.cos(np.radians(self.camera_elevation))
            * np.cos(np.radians(self.camera_azimuth))
        )
        y = self.camera_distance * np.sin(np.radians(self.camera_elevation))
        z = (
            self.camera_distance
            * np.cos(np.radians(self.camera_elevation))
            * np.sin(np.radians(self.camera_azimuth))
        )

        return np.array([x, y, z], dtype=np.float32) + self.camera_target

    def load_data_from_dataframes(
        self, dataframes: Tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]
    ):
        """Load data from pandas DataFrames"""
        try:
            baseq_df, ztcfq_df, deltaq_df = dataframes

            # Create frame processor with config
            config = RenderConfig()
            self.frame_processor = FrameProcessor(
                (baseq_df, ztcfq_df, deltaq_df), config
            )

            # Get first frame
            if len(self.frame_processor.time_vector) > 0:
                self.current_frame_data = self.frame_processor.get_frame_data(0)
                self.current_render_config = RenderConfig()

                # Frame camera to data
                self._frame_camera_to_data()

                # Trigger redraw
                self.update()

                print(f"✅ Loaded {len(self.frame_processor.time_vector)} frames")

        except Exception as e:
            print(f"❌ Data loading failed: {e}")
            traceback.print_exc()

    def update_frame(self, frame_data: FrameData, render_config: RenderConfig):
        """Update the current frame data and render config"""
        self.current_frame_data = frame_data
        self.current_render_config = render_config
        self.update()

    def _frame_camera_to_data(self):
        """Frame camera to show all data and set proper ground level"""
        if not self.current_frame_data:
            return

        # Calculate bounding box of data
        positions = [
            self.current_frame_data.left_wrist,
            self.current_frame_data.left_elbow,
            self.current_frame_data.left_shoulder,
            self.current_frame_data.right_wrist,
            self.current_frame_data.right_elbow,
            self.current_frame_data.right_shoulder,
            self.current_frame_data.hub,
            self.current_frame_data.butt,
            self.current_frame_data.clubhead,
        ]

        positions = [pos for pos in positions if np.isfinite(pos).all()]

        if not positions:
            return

        positions = np.array(positions)
        center = np.mean(positions, axis=0)
        max_distance = np.max(np.linalg.norm(positions - center, axis=1))

        # Set ground level to lowest Z point in the data
        self.ground_level = np.min(positions[:, 2])

        # Update camera target to be centered horizontally but at ground level
        self.camera_target = np.array(
            [center[0], center[1], self.ground_level], dtype=np.float32
        )
        self.camera_distance = max_distance * 2.5

        print(
            f"📷 Camera framed: center={center}, ground_level={self.ground_level:.3f}, distance={self.camera_distance:.2f}"
        )

    def set_face_on_view(self):
        """Set camera to face-on view (looking at golfer from front)"""
        self.camera_azimuth = 0.0
        self.camera_elevation = 15.0
        self.update()
        print("📷 Camera: Face-on view")

    def set_down_the_line_view(self):
        """Set camera to down-the-line view (90° from face-on)"""
        self.camera_azimuth = 90.0  # 90° from face-on, not 180°
        self.camera_elevation = 15.0
        self.update()
        print("📷 Camera: Down-the-line view")

    def set_behind_view(self):
        """Set camera to behind view (180° from face-on)"""
        self.camera_azimuth = 180.0
        self.camera_elevation = 15.0
        self.update()
        print("📷 Camera: Behind view")

    def set_above_view(self):
        """Set camera to overhead view"""
        self.camera_azimuth = 0.0
        self.camera_elevation = 80.0
        self.update()
        print("📷 Camera: Overhead view")

    def mousePressEvent(self, event):
        """Handle mouse press events"""
        self.last_mouse_pos = event.pos()
        self.mouse_pressed = True

    def mouseReleaseEvent(self, event):
        """Handle mouse release events"""
        self.mouse_pressed = False

    def mouseMoveEvent(self, event):
        """Handle mouse move events"""
        if not self.mouse_pressed or not self.last_mouse_pos:
            return

        delta = event.pos() - self.last_mouse_pos

        if event.buttons() & Qt.MouseButton.LeftButton:
            # Rotate camera
            self.camera_azimuth += delta.x() * 0.5
            self.camera_elevation += delta.y() * 0.5
            self.camera_elevation = np.clip(self.camera_elevation, -89, 89)

        elif event.buttons() & Qt.MouseButton.RightButton:
            # Pan camera
            pan_speed = self.camera_distance * 0.001
            right = np.array(
                [
                    np.cos(np.radians(self.camera_azimuth - 90)),
                    0,
                    np.sin(np.radians(self.camera_azimuth - 90)),
                ],
                dtype=np.float32,
            )
            up = np.array([0, 1, 0], dtype=np.float32)

            self.camera_target += (right * delta.x() - up * delta.y()) * pan_speed

        self.last_mouse_pos = event.pos()
        self.update()

    def wheelEvent(self, event):
        """Handle mouse wheel events"""
        zoom_factor = 1.1 if event.angleDelta().y() > 0 else 0.9
        self.camera_distance *= zoom_factor
        self.camera_distance = np.clip(self.camera_distance, 0.1, 50.0)
        self.update()

    def keyPressEvent(self, event):
        """Handle keyboard shortcuts"""
        key = event.key()

        if key == Qt.Key.Key_1:
            self.set_face_on_view()
        elif key == Qt.Key.Key_2:
            self.set_down_the_line_view()
        elif key == Qt.Key.Key_3:
            self.set_behind_view()
        elif key == Qt.Key.Key_4:
            self.set_above_view()
        elif key == Qt.Key.Key_R:
            self._frame_camera_to_data()
            self.update()
        elif key == Qt.Key.Key_Space:
            # Toggle playback if parent has this functionality
            parent = self.parent()
            if parent and hasattr(parent, "toggle_playback"):
                parent.toggle_playback()
        else:
            super().keyPressEvent(event)


# ============================================================================
# MAIN WINDOW
# ============================================================================


class GolfVisualizerMainWindow(QMainWindow):
    """Main window for the Golf Swing Visualizer with tabular interface"""

    def __init__(self):
        super().__init__()
        self.setWindowTitle("Golf Swing Visualizer - Multi-Data Analysis Platform")
        self.setGeometry(100, 100, 1200, 800)  # More reasonable window size

        # Apply modern white theme
        self._apply_modern_style()

        # Setup UI
        self._setup_ui()
        self._setup_menu()
        self._setup_status_bar()

        print("🚀 Golf Visualizer main window created")

    def _setup_ui(self):
        """Setup the main UI with tabular structure"""
        # Create central widget with tab widget
        self.central_widget = QWidget()
        self.setCentralWidget(self.central_widget)

        # Main layout
        main_layout = QVBoxLayout(self.central_widget)

        # Create tab widget
        self.tab_widget = QTabWidget()
        self.tab_widget.setTabPosition(QTabWidget.TabPosition.North)

        # Add tabs
        self.motion_capture_tab = MotionCaptureTab(self)
        self.simulink_tab = SimulinkModelTab(self)
        self.comparison_tab = ComparisonTab(self)

        self.tab_widget.addTab(self.motion_capture_tab, "Motion Capture Data")
        self.tab_widget.addTab(self.simulink_tab, "Simulink Model")
        self.tab_widget.addTab(self.comparison_tab, "Data Comparison")

        main_layout.addWidget(self.tab_widget)

        # Add global controls
        global_controls = self._create_global_controls()
        main_layout.addWidget(global_controls)

    def _create_global_controls(self):
        """Create global control panel"""
        panel = QGroupBox("Global Controls")
        layout = QGridLayout()

        # Camera view buttons
        layout.addWidget(QLabel("Camera Views:"), 0, 0)

        self.face_on_btn = QPushButton("Face-On (1)")
        self.face_on_btn.setMaximumWidth(100)
        self.face_on_btn.clicked.connect(self._set_face_on_view)
        layout.addWidget(self.face_on_btn, 0, 1)

        self.down_line_btn = QPushButton("Down-Line (2)")
        self.down_line_btn.setMaximumWidth(100)
        self.down_line_btn.clicked.connect(self._set_down_line_view)
        layout.addWidget(self.down_line_btn, 0, 2)

        self.behind_btn = QPushButton("Behind (3)")
        self.behind_btn.setMaximumWidth(100)
        self.behind_btn.clicked.connect(self._set_behind_view)
        layout.addWidget(self.behind_btn, 1, 1)

        self.above_btn = QPushButton("Above (4)")
        self.above_btn.setMaximumWidth(100)
        self.above_btn.clicked.connect(self._set_above_view)
        layout.addWidget(self.above_btn, 1, 2)

        # Reset camera button
        self.reset_camera_btn = QPushButton("Reset Camera (R)")
        self.reset_camera_btn.setMaximumWidth(120)
        self.reset_camera_btn.clicked.connect(self._reset_camera)
        layout.addWidget(self.reset_camera_btn, 2, 1, 1, 2)

        # Visualization toggles
        layout.addWidget(QLabel("Visualization:"), 3, 0)

        self.show_face_normal_cb = QCheckBox("Face Normal")
        self.show_face_normal_cb.setChecked(True)
        self.show_face_normal_cb.stateChanged.connect(self._toggle_face_normal)
        layout.addWidget(self.show_face_normal_cb, 3, 1)

        self.show_ball_cb = QCheckBox("Ball")
        self.show_ball_cb.setChecked(True)
        self.show_ball_cb.stateChanged.connect(self._toggle_ball)
        layout.addWidget(self.show_ball_cb, 3, 2)

        panel.setLayout(layout)
        return panel

    def _setup_menu(self):
        """Setup the menu bar"""
        menubar = self.menuBar()

        # File menu
        file_menu = menubar.addMenu("File")

        load_action = QAction("Load Motion Capture Data", self)
        load_action.setShortcut(QKeySequence.StandardKey.Open)
        load_action.triggered.connect(self._load_motion_capture_data)
        file_menu.addAction(load_action)

        file_menu.addSeparator()

        exit_action = QAction("Exit", self)
        exit_action.setShortcut(QKeySequence.StandardKey.Quit)
        exit_action.triggered.connect(self.close)
        file_menu.addAction(exit_action)

        # View menu
        view_menu = menubar.addMenu("View")

        reset_camera_action = QAction("Reset Camera", self)
        reset_camera_action.setShortcut("R")
        reset_camera_action.triggered.connect(self._reset_camera)
        view_menu.addAction(reset_camera_action)

        # Help menu
        help_menu = menubar.addMenu("Help")

        about_action = QAction("About", self)
        about_action.triggered.connect(self._show_about)
        help_menu.addAction(about_action)

    def _setup_status_bar(self):
        """Setup the status bar"""
        self.status_bar = QStatusBar()
        self.setStatusBar(self.status_bar)
        self.status_bar.showMessage("Ready - Select a tab to begin analysis")

    def _apply_modern_style(self):
        """Apply modern white theme"""
        self.setStyleSheet(
            """
            QMainWindow {
                background-color: #ffffff;
                color: #333333;
            }
            
            QTabWidget::pane {
                border: 1px solid #cccccc;
                background-color: #ffffff;
            }
            
            QTabBar::tab {
                background-color: #f0f0f0;
                color: #333333;
                padding: 8px 16px;
                margin-right: 2px;
                border: 1px solid #cccccc;
                border-bottom: none;
                border-top-left-radius: 4px;
                border-top-right-radius: 4px;
            }
            
            QTabBar::tab:selected {
                background-color: #ffffff;
                border-bottom: 1px solid #ffffff;
            }
            
            QTabBar::tab:hover {
                background-color: #e8e8e8;
            }
            
            QGroupBox {
                font-weight: bold;
                border: 1px solid #cccccc;
                border-radius: 4px;
                margin-top: 8px;
                padding-top: 8px;
                background-color: #fafafa;
            }
            
            QGroupBox::title {
                subcontrol-origin: margin;
                left: 8px;
                padding: 0 4px 0 4px;
                color: #333333;
            }
            
            QPushButton {
                background-color: #0078d4;
                color: white;
                border: none;
                padding: 6px 12px;
                border-radius: 4px;
                font-weight: bold;
            }
            
            QPushButton:hover {
                background-color: #106ebe;
            }
            
            QPushButton:pressed {
                background-color: #005a9e;
            }
            
            QPushButton:disabled {
                background-color: #cccccc;
                color: #666666;
            }
            
            QSlider::groove:horizontal {
                border: 1px solid #cccccc;
                height: 6px;
                background-color: #f0f0f0;
                border-radius: 3px;
            }
            
            QSlider::handle:horizontal {
                background-color: #0078d4;
                border: 1px solid #0078d4;
                width: 16px;
                margin: -5px 0;
                border-radius: 8px;
            }
            
            QSlider::handle:horizontal:hover {
                background-color: #106ebe;
            }
            
            QCheckBox {
                color: #333333;
            }
            
            QCheckBox::indicator {
                width: 16px;
                height: 16px;
                border: 1px solid #cccccc;
                border-radius: 2px;
                background-color: #ffffff;
            }
            
            QCheckBox::indicator:checked {
                background-color: #0078d4;
                border-color: #0078d4;
            }
            
            QComboBox {
                border: 1px solid #cccccc;
                border-radius: 4px;
                padding: 4px 8px;
                background-color: #ffffff;
                color: #333333;
            }
            
            QComboBox::drop-down {
                border: none;
                width: 20px;
            }
            
            QComboBox::down-arrow {
                image: none;
                border-left: 5px solid transparent;
                border-right: 5px solid transparent;
                border-top: 5px solid #333333;
            }
            
            QLabel {
                color: #333333;
            }
            
            QStatusBar {
                background-color: #f0f0f0;
                color: #333333;
                border-top: 1px solid #cccccc;
            }
        """
        )

    def _load_motion_capture_data(self):
        """Load motion capture data"""
        # This will be handled by the motion capture tab
        self.tab_widget.setCurrentIndex(0)
        self.motion_capture_tab._load_motion_capture_data()

    def _reset_camera(self):
        """Reset camera to default position"""
        if hasattr(self, "gl_widget") and self.gl_widget:
            self.gl_widget._frame_camera_to_data()
            self.gl_widget.update()

    def _set_face_on_view(self):
        """Set face-on camera view"""
        if hasattr(self, "gl_widget") and self.gl_widget:
            self.gl_widget.set_face_on_view()

    def _set_down_line_view(self):
        """Set down-the-line camera view"""
        if hasattr(self, "gl_widget") and self.gl_widget:
            self.gl_widget.set_down_the_line_view()

    def _set_behind_view(self):
        """Set behind camera view"""
        if hasattr(self, "gl_widget") and self.gl_widget:
            self.gl_widget.set_behind_view()

    def _set_above_view(self):
        """Set overhead camera view"""
        if hasattr(self, "gl_widget") and self.gl_widget:
            self.gl_widget.set_above_view()

    def _toggle_face_normal(self, state):
        """Toggle face normal visibility"""
        if (
            hasattr(self, "gl_widget")
            and self.gl_widget
            and self.gl_widget.current_render_config
        ):
            self.gl_widget.current_render_config.show_face_normal = bool(state)
            self.gl_widget.update()

    def _toggle_ball(self, state):
        """Toggle ball visibility"""
        if (
            hasattr(self, "gl_widget")
            and self.gl_widget
            and self.gl_widget.current_render_config
        ):
            self.gl_widget.current_render_config.show_ball = bool(state)
            self.gl_widget.update()

    def _show_about(self):
        """Show about dialog"""
        QMessageBox.about(
            self,
            "About Golf Swing Visualizer",
            "Golf Swing Visualizer - Multi-Data Analysis Platform\n\n"
            "Version: 2.0\n"
            "Features:\n"
            "• Motion capture data visualization\n"
            "• Future Simulink model integration\n"
            "• Hand midpoint tracking analysis\n"
            "• Real-time 3D rendering\n\n"
            "Built with PyQt6 and ModernGL",
        )


# ============================================================================
# MAIN FUNCTION
# ============================================================================


def main():
    """Main application entry point"""
    app = QApplication(sys.argv)

    # Set application properties
    app.setApplicationName("Golf Swing Visualizer")
    app.setApplicationVersion("2.0")
    app.setOrganizationName("Golf Analysis Lab")

    # Create and show main window
    window = GolfVisualizerMainWindow()
    window.show()

    print("🚀 Golf Swing Visualizer started")
    print("   Tabular interface ready for multi-data analysis")
    print("   Motion capture data visualization active")
    print("   Simulink model integration prepared for future use")

    # Start event loop
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
