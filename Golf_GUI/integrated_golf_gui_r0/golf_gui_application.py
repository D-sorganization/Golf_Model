#!/usr/bin/env python3
"""
Golf Swing Visualizer - Modern PyQt6 GUI Application
Sophisticated user interface with real-time 3D visualization and comprehensive controls
"""

import sys
import os
import time
import traceback
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import numpy as np

from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QLabel, 
    QPushButton, QSlider, QGroupBox, QCheckBox, QComboBox, QDockWidget, 
    QFileDialog, QMessageBox
)
from PyQt6.QtCore import Qt, pyqtSignal, QTimer, QPoint
from PyQt6.QtGui import QAction, QMouseEvent, QWheelEvent, QKeyEvent, QSurfaceFormat
from PyQt6.QtOpenGLWidgets import QOpenGLWidget

import moderngl as mgl
from golf_data_core import MatlabDataLoader, FrameProcessor, RenderConfig, PerformanceStats
from golf_opengl_renderer import OpenGLRenderer

# ============================================================================
# MODERN OPENGL WIDGET
# ============================================================================

class GolfVisualizerWidget(QOpenGLWidget):
    """High-performance OpenGL widget for 3D golf swing visualization"""
    
    # Signals for communication with main window
    frameChanged = pyqtSignal(int)
    fpsUpdated = pyqtSignal(float)
    statusMessage = pyqtSignal(str)
    
    def __init__(self, parent=None):
        super().__init__(parent)
        
        # Core components
        self.renderer = OpenGLRenderer()
        self.frame_processor: Optional[FrameProcessor] = None
        self.render_config = RenderConfig()
        self.performance_stats = PerformanceStats()
        
        # Animation and interaction state
        self.current_frame = 0
        self.num_frames = 0
        self.is_playing = False
        self.playback_speed = 1.0
        self.loop_playback = True
        
        # Camera controls
        self.camera_distance = 3.0
        self.camera_azimuth = 45.0
        self.camera_elevation = 20.0
        self.camera_target = np.array([0, 0, 0], dtype=np.float32)
        self.camera_fov = 45.0
        
        # Mouse interaction
        self.last_mouse_pos = None
        self.mouse_buttons = Qt.MouseButton.NoButton
        self.mouse_sensitivity = 0.5
        self.zoom_sensitivity = 0.1
        
        # Animation timer
        self.animation_timer = QTimer()
        self.animation_timer.timeout.connect(self._next_frame)
        
        # Performance monitoring timer
        self.perf_timer = QTimer()
        self.perf_timer.timeout.connect(self._update_performance)
        self.perf_timer.start(100)  # Update 10 times per second
        
        # OpenGL context
        self.ctx: Optional[mgl.Context] = None
        self.initialized = False
        
        # Set OpenGL format
        format = QSurfaceFormat()
        format.setVersion(3, 3)
        format.setProfile(QSurfaceFormat.OpenGLContextProfile.CoreProfile)
        format.setDepthBufferSize(24)
        format.setStencilBufferSize(8)
        format.setSamples(4)  # 4x MSAA
        self.setFormat(format)
        
        # Enable mouse tracking and focus
        self.setMouseTracking(True)
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)
        
        print("🖥️ Golf visualizer widget created")
    
    def initializeGL(self):
        """Initialize OpenGL context and renderer"""
        try:
            # Create ModernGL context
            self.ctx = mgl.create_context()
            
            # Initialize renderer
            self.renderer.initialize(self.ctx)
            
            # Set viewport
            self.renderer.set_viewport(self.width(), self.height())
            
            self.initialized = True
            self.statusMessage.emit("OpenGL initialized successfully")
            
            print("✅ OpenGL context initialized")
            print(f"   Version: {self.ctx.info['GL_VERSION']}")
            print(f"   Vendor: {self.ctx.info['GL_VENDOR']}")
            print(f"   Renderer: {self.ctx.info['GL_RENDERER']}")
            
        except Exception as e:
            self.statusMessage.emit(f"OpenGL initialization failed: {e}")
            print(f"❌ OpenGL initialization failed: {e}")
            traceback.print_exc()
    
    def resizeGL(self, w: int, h: int):
        """Handle widget resize"""
        if self.renderer and self.initialized:
            self.renderer.set_viewport(w, h)
    
    def paintGL(self):
        """Render the current frame"""
        if not self.initialized or not self.frame_processor:
            if self.ctx:
                self.ctx.clear(0.1, 0.2, 0.3, 1.0)
            return
        
        start_time = time.time()
        
        try:
            # Get current frame data
            frame_data = self.frame_processor.get_frame_data(self.current_frame)
            # Extract calculated dynamics for current frame
            dynamics_data = {
                'force': frame_data.forces.get('calculated', np.zeros(3, dtype=np.float32)),
                'torque': frame_data.torques.get('calculated', np.zeros(3, dtype=np.float32))
            }
        
            # Calculate camera matrices
            view_matrix = self._calculate_view_matrix()
            proj_matrix = self._calculate_projection_matrix()
            view_position = self._get_camera_position()
        
            # Render the frame (with dynamics)
            self.renderer.render_frame(
                frame_data, dynamics_data, self.render_config,
                view_matrix, proj_matrix, view_position
            )
        
            # Update performance stats
            frame_time = time.time() - start_time
            self.performance_stats.update_frame_time(frame_time)
            
        except Exception as e:
            self.statusMessage.emit(f"Render error: {e}")
            print(f"❌ Render error: {e}")
            if self.ctx:
                self.ctx.clear(0.3, 0.1, 0.1, 1.0)  # Red background for errors
    
    def load_data(self, baseq_file: str, ztcfq_file: str, delta_file: str) -> bool:
        """Load golf swing data"""
        try:
            self.statusMessage.emit("Loading data...")
            
            # Load MATLAB data
            loader = MatlabDataLoader()
            datasets = loader.load_datasets(baseq_file, ztcfq_file, delta_file)
            
            # Create frame processor
            self.frame_processor = FrameProcessor(datasets, self.render_config)
            self.num_frames = self.frame_processor.num_frames
            self.current_frame = 0
            
            # Update camera to frame the data
            self._frame_data_in_view()
            
            self.statusMessage.emit(f"Loaded {self.num_frames} frames successfully")
            self.frameChanged.emit(self.current_frame)
            
            # Trigger redraw
            self.update()
            
            return True
            
        except Exception as e:
            self.statusMessage.emit(f"Failed to load data: {e}")
            print(f"❌ Data loading failed: {e}")
            return False
    
    def _frame_data_in_view(self):
        """Adjust camera to frame the loaded data"""
        if not self.frame_processor:
            return
        
        # Sample a few frames to estimate data bounds
        sample_frames = [0, self.num_frames // 4, self.num_frames // 2, 
                        3 * self.num_frames // 4, self.num_frames - 1]
        
        all_points = []
        for frame_idx in sample_frames:
            frame_data = self.frame_processor.get_frame_data(frame_idx)
            points = [frame_data.butt, frame_data.clubhead, frame_data.midpoint,
                     frame_data.left_shoulder, frame_data.right_shoulder, frame_data.hub]
            all_points.extend([p for p in points if np.isfinite(p).all()])
        
        if all_points:
            all_points = np.array(all_points)
            center = np.mean(all_points, axis=0)
            extents = np.max(all_points, axis=0) - np.min(all_points, axis=0)
            max_extent = np.max(extents)
            
            self.camera_target = center.astype(np.float32)
            self.camera_distance = max_extent * 2.0
            
            print(f"📷 Camera framed: center={center}, distance={self.camera_distance:.2f}")
    
    def _calculate_view_matrix(self) -> np.ndarray:
        """Calculate camera view matrix"""
        # Convert spherical to Cartesian coordinates
        azimuth_rad = np.radians(self.camera_azimuth)
        elevation_rad = np.radians(self.camera_elevation)
        
        x = self.camera_distance * np.cos(elevation_rad) * np.cos(azimuth_rad)
        y = self.camera_distance * np.sin(elevation_rad)
        z = self.camera_distance * np.cos(elevation_rad) * np.sin(azimuth_rad)
        
        camera_pos = self.camera_target + np.array([x, y, z], dtype=np.float32)
        
        # Create lookAt matrix
        return self._create_lookat_matrix(camera_pos, self.camera_target, np.array([0, 1, 0]))
    
    def _calculate_projection_matrix(self) -> np.ndarray:
        """Calculate perspective projection matrix"""
        aspect_ratio = self.width() / self.height() if self.height() > 0 else 1.0
        near = 0.1
        far = 100.0
        
        return self._create_perspective_matrix(np.radians(self.camera_fov), aspect_ratio, near, far)
    
    def _get_camera_position(self) -> np.ndarray:
        """Get current camera position in world coordinates"""
        azimuth_rad = np.radians(self.camera_azimuth)
        elevation_rad = np.radians(self.camera_elevation)
        
        x = self.camera_distance * np.cos(elevation_rad) * np.cos(azimuth_rad)
        y = self.camera_distance * np.sin(elevation_rad)
        z = self.camera_distance * np.cos(elevation_rad) * np.sin(azimuth_rad)
        
        return self.camera_target + np.array([x, y, z], dtype=np.float32)
    
    @staticmethod
    def _create_lookat_matrix(eye: np.ndarray, target: np.ndarray, up: np.ndarray) -> np.ndarray:
        """Create lookAt view matrix"""
        f = target - eye
        f = f / np.linalg.norm(f)
        
        s = np.cross(f, up)
        s = s / np.linalg.norm(s)
        
        u = np.cross(s, f)
        
        result = np.eye(4, dtype=np.float32)
        result[0, 0:3] = s
        result[1, 0:3] = u
        result[2, 0:3] = -f
        result[0, 3] = -np.dot(s, eye)
        result[1, 3] = -np.dot(u, eye)
        result[2, 3] = np.dot(f, eye)
        
        return result
    
    @staticmethod
    def _create_perspective_matrix(fov: float, aspect: float, near: float, far: float) -> np.ndarray:
        """Create perspective projection matrix"""
        f = 1.0 / np.tan(fov / 2.0)
        
        result = np.zeros((4, 4), dtype=np.float32)
        result[0, 0] = f / aspect
        result[1, 1] = f
        result[2, 2] = (far + near) / (near - far)
        result[2, 3] = (2 * far * near) / (near - far)
        result[3, 2] = -1.0
        
        return result
    
    # ========================================================================
    # MOUSE AND KEYBOARD INTERACTION
    # ========================================================================
    
    def mousePressEvent(self, a0: QMouseEvent):
        """Handle mouse press events"""
        self.last_mouse_pos = a0.position().toPoint()
        self.mouse_buttons = a0.buttons()
        
    def mouseMoveEvent(self, a0: QMouseEvent):
        """Handle mouse movement for camera control"""
        if self.last_mouse_pos is None:
            return
        
        current_pos = a0.position().toPoint()
        dx = current_pos.x() - self.last_mouse_pos.x()
        dy = current_pos.y() - self.last_mouse_pos.y()
        
        if self.mouse_buttons & Qt.MouseButton.LeftButton:
            # Orbit camera
            self.camera_azimuth += dx * self.mouse_sensitivity
            self.camera_elevation = np.clip(
                self.camera_elevation - dy * self.mouse_sensitivity,
                -89, 89
            )
            self.update()
            
        elif self.mouse_buttons & Qt.MouseButton.RightButton:
            # Pan camera
            pan_speed = self.camera_distance * 0.001
            
            # Calculate camera right and up vectors
            azimuth_rad = np.radians(self.camera_azimuth)
            elevation_rad = np.radians(self.camera_elevation)
            
            right = np.array([-np.sin(azimuth_rad), 0, np.cos(azimuth_rad)]) * pan_speed * dx
            up = np.array([0, 1, 0]) * pan_speed * dy
            
            self.camera_target += right + up
            self.update()
        
        self.last_mouse_pos = current_pos
    
    def wheelEvent(self, a0: QWheelEvent):
        """Handle mouse wheel for camera zoom"""
        delta = a0.angleDelta().y() / 120  # Standard wheel step
        zoom_factor = 1.0 + (delta * self.zoom_sensitivity)
        
        self.camera_distance = np.clip(
            self.camera_distance / zoom_factor,
            0.1, 20.0
        )
        self.update()
    
    def keyPressEvent(self, a0: QKeyEvent):
        """Handle keyboard shortcuts"""
        key = a0.key()
        
        if key == Qt.Key.Key_Space:
            self.toggle_playback()
        elif key == Qt.Key.Key_Left:
            self.previous_frame()
        elif key == Qt.Key.Key_Right:
            self.next_frame()
        elif key == Qt.Key.Key_Home:
            self.set_frame(0)
        elif key == Qt.Key.Key_End:
            self.set_frame(self.num_frames - 1)
        elif key == Qt.Key.Key_R:
            self.reset_camera()
        elif key == Qt.Key.Key_F:
            self._frame_data_in_view()
            self.update()
        else:
            super().keyPressEvent(a0)
    
    # ========================================================================
    # PLAYBACK CONTROLS
    # ========================================================================
    
    def play(self):
        """Start animation playback"""
        if not self.frame_processor or self.num_frames <= 1:
            return
        
        if not self.is_playing:
            self.is_playing = True
            interval = max(1, int(33 / self.playback_speed))  # Target ~30 FPS
            self.animation_timer.start(interval)
            self.statusMessage.emit("Playing animation")
    
    def pause(self):
        """Pause animation playback"""
        if self.is_playing:
            self.is_playing = False
            self.animation_timer.stop()
            self.statusMessage.emit("Animation paused")
    
    def toggle_playback(self):
        """Toggle between play and pause"""
        if self.is_playing:
            self.pause()
        else:
            self.play()
    
    def _next_frame(self):
        """Advance to next frame (internal)"""
        if self.num_frames <= 1:
            return
        
        self.current_frame += 1
        if self.current_frame >= self.num_frames:
            if self.loop_playback:
                self.current_frame = 0
            else:
                self.current_frame = self.num_frames - 1
                self.pause()
        
        self.frameChanged.emit(self.current_frame)
        self.update()
    
    def next_frame(self):
        """Advance to next frame (public)"""
        if self.num_frames <= 1:
            return
        
        self.current_frame = min(self.current_frame + 1, self.num_frames - 1)
        self.frameChanged.emit(self.current_frame)
        self.update()
    
    def previous_frame(self):
        """Go to previous frame"""
        if self.num_frames <= 1:
            return
        
        self.current_frame = max(self.current_frame - 1, 0)
        self.frameChanged.emit(self.current_frame)
        self.update()
    
    def set_frame(self, frame_idx: int):
        """Jump to specific frame"""
        if 0 <= frame_idx < self.num_frames:
            self.current_frame = frame_idx
            self.frameChanged.emit(self.current_frame)
            self.update()
    
    def set_playback_speed(self, speed: float):
        """Set playback speed multiplier"""
        self.playback_speed = np.clip(speed, 0.1, 5.0)
        
        # Update timer interval if playing
        if self.is_playing:
            interval = max(1, int(33 / self.playback_speed))
            self.animation_timer.setInterval(interval)
    
    def reset_camera(self):
        """Reset camera to default position"""
        self.camera_distance = 3.0
        self.camera_azimuth = 45.0
        self.camera_elevation = 20.0
        self.camera_target = np.array([0, 0, 0], dtype=np.float32)
        self.update()
    
    def _update_performance(self):
        """Update performance statistics"""
        if self.performance_stats.fps > 0:
            self.fpsUpdated.emit(self.performance_stats.fps)

# ============================================================================
# CONTROL PANELS
# ============================================================================

class PlaybackControlPanel(QWidget):
    """Modern playback control panel"""
    
    frameChanged = pyqtSignal(int)
    speedChanged = pyqtSignal(float)
    playToggled = pyqtSignal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.num_frames = 0
        self.is_playing = False
        self._setup_ui()
    
    def _setup_ui(self):
        """Setup the playback control UI"""
        layout = QVBoxLayout(self)
        layout.setContentsMargins(10, 10, 10, 10)
        layout.setSpacing(15)
        
        # Title
        title = QLabel("Playback Controls")
        title.setStyleSheet("font-weight: bold; font-size: 14px; color: #ffffff;")
        layout.addWidget(title)
        
        # Play/Pause button
        self.play_button = QPushButton("▶ Play")
        self.play_button.setMinimumHeight(40)
        self.play_button.setStyleSheet("""
            QPushButton {
                background-color: #0078d4;
                border: none;
                color: white;
                font-size: 14px;
                font-weight: bold;
                border-radius: 8px;
            }
            QPushButton:hover {
                background-color: #106ebe;
            }
            QPushButton:pressed {
                background-color: #005a9e;
            }
        """)
        self.play_button.clicked.connect(self._toggle_play)
        layout.addWidget(self.play_button)
        
        # Frame controls
        frame_group = QGroupBox("Frame Navigation")
        frame_layout = QVBoxLayout(frame_group)
        
        # Frame slider
        self.frame_slider = QSlider(Qt.Orientation.Horizontal)
        self.frame_slider.setMinimum(0)
        self.frame_slider.setMaximum(100)
        self.frame_slider.setValue(0)
        self.frame_slider.valueChanged.connect(self._on_frame_slider_changed)
        frame_layout.addWidget(self.frame_slider)
        
        # Frame info
        frame_info_layout = QHBoxLayout()
        self.frame_label = QLabel("Frame: 0 / 0")
        self.time_label = QLabel("Time: 0.00s")
        frame_info_layout.addWidget(self.frame_label)
        frame_info_layout.addStretch()
        frame_info_layout.addWidget(self.time_label)
        frame_layout.addLayout(frame_info_layout)
        
        # Navigation buttons
        nav_layout = QHBoxLayout()
        self.first_button = QPushButton("⏮")
        self.prev_button = QPushButton("⏪")
        self.next_button = QPushButton("⏩")
        self.last_button = QPushButton("⏭")
        
        for btn in [self.first_button, self.prev_button, self.next_button, self.last_button]:
            btn.setMinimumHeight(30)
            btn.setMaximumWidth(50)
        
        self.first_button.clicked.connect(lambda: self.frameChanged.emit(0))
        self.prev_button.clicked.connect(self._previous_frame)
        self.next_button.clicked.connect(self._next_frame)
        self.last_button.clicked.connect(lambda: self.frameChanged.emit(self.num_frames - 1))
        
        nav_layout.addWidget(self.first_button)
        nav_layout.addWidget(self.prev_button)
        nav_layout.addStretch()
        nav_layout.addWidget(self.next_button)
        nav_layout.addWidget(self.last_button)
        frame_layout.addLayout(nav_layout)
        
        layout.addWidget(frame_group)
        
        # Speed controls
        speed_group = QGroupBox("Playback Speed")
        speed_layout = QVBoxLayout(speed_group)
        
        self.speed_slider = QSlider(Qt.Orientation.Horizontal)
        self.speed_slider.setMinimum(10)   # 0.1x
        self.speed_slider.setMaximum(500)  # 5.0x
        self.speed_slider.setValue(100)    # 1.0x
        self.speed_slider.valueChanged.connect(self._on_speed_changed)
        speed_layout.addWidget(self.speed_slider)
        
        speed_info_layout = QHBoxLayout()
        speed_info_layout.addWidget(QLabel("0.1x"))
        self.speed_label = QLabel("1.0x")
        self.speed_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        speed_info_layout.addWidget(self.speed_label)
        speed_info_layout.addWidget(QLabel("5.0x"))
        speed_layout.addLayout(speed_info_layout)
        
        layout.addWidget(speed_group)
        
        layout.addStretch()
    
    def _toggle_play(self):
        """Toggle play/pause"""
        self.playToggled.emit()
    
    def _on_frame_slider_changed(self, value):
        """Handle frame slider change"""
        if self.num_frames > 0:
            frame = int(value * (self.num_frames - 1) / 100)
            self.frameChanged.emit(frame)
    
    def _on_speed_changed(self, value):
        """Handle speed slider change"""
        speed = value / 100.0  # Convert to multiplier
        self.speed_label.setText(f"{speed:.1f}x")
        self.speedChanged.emit(speed)
    
    def _previous_frame(self):
        """Go to previous frame"""
        current = int(self.frame_slider.value() * (self.num_frames - 1) / 100)
        if current > 0:
            new_frame = current - 1
            self.frameChanged.emit(new_frame)
    
    def _next_frame(self):
        """Go to next frame"""
        current = int(self.frame_slider.value() * (self.num_frames - 1) / 100)
        if current < self.num_frames - 1:
            new_frame = current + 1
            self.frameChanged.emit(new_frame)
    
    def update_num_frames(self, num_frames: int):
        """Update the number of frames"""
        self.num_frames = num_frames
        self.frame_slider.setEnabled(num_frames > 0)
        
        for btn in [self.first_button, self.prev_button, self.next_button, self.last_button]:
            btn.setEnabled(num_frames > 0)
    
    def update_current_frame(self, frame: int):
        """Update current frame display"""
        if self.num_frames > 0:
            # Update slider
            slider_value = int(100 * frame / max(1, self.num_frames - 1))
            self.frame_slider.blockSignals(True)
            self.frame_slider.setValue(slider_value)
            self.frame_slider.blockSignals(False)
            
            # Update labels
            time_seconds = frame * 0.001  # Assume 1000 Hz sampling
            self.frame_label.setText(f"Frame: {frame} / {self.num_frames}")
            self.time_label.setText(f"Time: {time_seconds:.3f}s")
    
    def update_playing_state(self, is_playing: bool):
        """Update play button state"""
        self.is_playing = is_playing
        if is_playing:
            self.play_button.setText("⏸ Pause")
        else:
            self.play_button.setText("▶ Play")

class VisualizationControlPanel(QWidget):
    """Control panel for visualization settings"""
    
    renderConfigChanged = pyqtSignal(object)
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.render_config = RenderConfig()
        self._setup_ui()
    
    def _setup_ui(self):
        """Setup the visualization control UI"""
        layout = QVBoxLayout(self)
        layout.setContentsMargins(10, 10, 10, 10)
        layout.setSpacing(15)
        
        # Title
        title = QLabel("Visualization")
        title.setStyleSheet("font-weight: bold; font-size: 14px; color: #ffffff;")
        layout.addWidget(title)
        
        # Forces group
        forces_group = QGroupBox("Forces")
        forces_layout = QVBoxLayout(forces_group)
        
        self.force_checkboxes = {}
        force_colors = {'BASEQ': '#FF6B35', 'ZTCFQ': '#4ECDC4', 'DELTAQ': '#FFE66D'}
        
        for dataset in ['BASEQ', 'ZTCFQ', 'DELTAQ']:
            cb = QCheckBox(f"{dataset} Forces")
            cb.setChecked(True)
            cb.setStyleSheet(f"QCheckBox {{ color: {force_colors[dataset]}; font-weight: bold; }}")
            cb.stateChanged.connect(lambda state, ds=dataset: self._toggle_forces(ds, state))
            forces_layout.addWidget(cb)
            self.force_checkboxes[dataset] = cb
        
        layout.addWidget(forces_group)
        
        # Torques group
        torques_group = QGroupBox("Torques")
        torques_layout = QVBoxLayout(torques_group)
        
        self.torque_checkboxes = {}
        for dataset in ['BASEQ', 'ZTCFQ', 'DELTAQ']:
            cb = QCheckBox(f"{dataset} Torques")
            cb.setChecked(True)
            cb.setStyleSheet(f"QCheckBox {{ color: {force_colors[dataset]}; font-weight: bold; }}")
            cb.stateChanged.connect(lambda state, ds=dataset: self._toggle_torques(ds, state))
            torques_layout.addWidget(cb)
            self.torque_checkboxes[dataset] = cb
        
        layout.addWidget(torques_group)
        
        # Body segments group
        body_group = QGroupBox("Body Segments")
        body_layout = QVBoxLayout(body_group)
        
        self.body_checkboxes = {}
        segments = [
            ('left_forearm', 'Left Forearm'),
            ('left_upper_arm', 'Left Upper Arm'),
            ('right_forearm', 'Right Forearm'),
            ('right_upper_arm', 'Right Upper Arm'),
            ('left_shoulder_neck', 'Left Shoulder/Neck'),
            ('right_shoulder_neck', 'Right Shoulder/Neck')
        ]
        
        for segment_key, segment_label in segments:
            cb = QCheckBox(segment_label)
            cb.setChecked(True)
            cb.stateChanged.connect(lambda state, seg=segment_key: self._toggle_body_segment(seg, state))
            body_layout.addWidget(cb)
            self.body_checkboxes[segment_key] = cb
        
        layout.addWidget(body_group)
        
        # Other elements group
        other_group = QGroupBox("Other Elements")
        other_layout = QVBoxLayout(other_group)
        
        self.club_cb = QCheckBox("Club")
        self.club_cb.setChecked(True)
        self.club_cb.stateChanged.connect(self._toggle_club)
        other_layout.addWidget(self.club_cb)
        
        self.face_normal_cb = QCheckBox("Face Normal")
        self.face_normal_cb.setChecked(True)
        self.face_normal_cb.stateChanged.connect(self._toggle_face_normal)
        other_layout.addWidget(self.face_normal_cb)
        
        self.ground_cb = QCheckBox("Ground Grid")
        self.ground_cb.setChecked(True)
        self.ground_cb.stateChanged.connect(self._toggle_ground)
        other_layout.addWidget(self.ground_cb)
        
        layout.addWidget(other_group)
        
        # Vector scale
        scale_group = QGroupBox("Vector Scale")
        scale_layout = QVBoxLayout(scale_group)
        
        self.scale_slider = QSlider(Qt.Orientation.Horizontal)
        self.scale_slider.setMinimum(10)   # 0.1x
        self.scale_slider.setMaximum(300)  # 3.0x
        self.scale_slider.setValue(100)    # 1.0x
        self.scale_slider.valueChanged.connect(self._on_scale_changed)
        scale_layout.addWidget(self.scale_slider)
        
        scale_info_layout = QHBoxLayout()
        scale_info_layout.addWidget(QLabel("0.1x"))
        self.scale_label = QLabel("1.0x")
        self.scale_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        scale_info_layout.addWidget(self.scale_label)
        scale_info_layout.addWidget(QLabel("3.0x"))
        scale_layout.addLayout(scale_info_layout)
        
        layout.addWidget(scale_group)
        
        layout.addStretch()
    
    def _toggle_forces(self, dataset: str, state: int):
        """Toggle force visibility for dataset"""
        self.render_config.show_forces[dataset] = state == Qt.CheckState.Checked.value
        self.renderConfigChanged.emit(self.render_config)
    
    def _toggle_torques(self, dataset: str, state: int):
        """Toggle torque visibility for dataset"""
        self.render_config.show_torques[dataset] = state == Qt.CheckState.Checked.value
        self.renderConfigChanged.emit(self.render_config)
    
    def _toggle_body_segment(self, segment: str, state: int):
        """Toggle body segment visibility"""
        self.render_config.show_body_segments[segment] = state == Qt.CheckState.Checked.value
        self.renderConfigChanged.emit(self.render_config)
    
    def _toggle_club(self, state: int):
        """Toggle club visibility"""
        self.render_config.show_club = state == Qt.CheckState.Checked.value
        self.renderConfigChanged.emit(self.render_config)
    
    def _toggle_face_normal(self, state: int):
        """Toggle face normal visibility"""
        self.render_config.show_face_normal = state == Qt.CheckState.Checked.value
        self.renderConfigChanged.emit(self.render_config)
    
    def _toggle_ground(self, state: int):
        """Toggle ground visibility"""
        self.render_config.show_ground = state == Qt.CheckState.Checked.value
        self.renderConfigChanged.emit(self.render_config)
    
    def _on_scale_changed(self, value: int):
        """Handle vector scale change"""
        scale = value / 100.0
        self.scale_label.setText(f"{scale:.1f}x")
        self.render_config.vector_scale = scale
        self.renderConfigChanged.emit(self.render_config)

class AnalysisControlPanel(QWidget):
    """Control panel for analysis and filtering."""

    filterChanged = pyqtSignal(str)
    showCalculatedForceChanged = pyqtSignal(bool)
    showCalculatedTorqueChanged = pyqtSignal(bool)
    vectorScaleChanged = pyqtSignal(float)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._setup_ui()

    def _setup_ui(self):
        layout = QVBoxLayout(self)
        layout.setContentsMargins(10, 10, 10, 10)
        layout.setSpacing(15)

        title = QLabel("Analysis & Filtering")
        title.setStyleSheet("font-weight: bold; font-size: 14px; color: #ffffff;")
        layout.addWidget(title)

        # Filter selection
        filter_group = QGroupBox("Data Filter")
        filter_layout = QVBoxLayout(filter_group)

        self.filter_combo = QComboBox()
        self.filter_combo.addItems(["None", "Butterworth", "Savitzky-Golay", "Moving Average"])
        self.filter_combo.currentTextChanged.connect(self.filterChanged.emit)
        filter_layout.addWidget(self.filter_combo)
        layout.addWidget(filter_group)

        # Calculated vectors
        vectors_group = QGroupBox("Calculated Vectors")
        vectors_layout = QVBoxLayout(vectors_group)

        self.show_force_cb = QCheckBox("Show Calculated Force")
        self.show_force_cb.setChecked(True)
        self.show_force_cb.stateChanged.connect(lambda state: self.showCalculatedForceChanged.emit(state == Qt.CheckState.Checked.value))
        vectors_layout.addWidget(self.show_force_cb)

        self.show_torque_cb = QCheckBox("Show Calculated Torque")
        self.show_torque_cb.setChecked(True)
        self.show_torque_cb.stateChanged.connect(lambda state: self.showCalculatedTorqueChanged.emit(state == Qt.CheckState.Checked.value))
        vectors_layout.addWidget(self.show_torque_cb)
        
        layout.addWidget(vectors_group)

        # Vector scale
        scale_group = QGroupBox("Calculated Vector Scale")
        scale_layout = QVBoxLayout(scale_group)

        self.scale_slider = QSlider(Qt.Orientation.Horizontal)
        self.scale_slider.setMinimum(10)   # 0.1x
        self.scale_slider.setMaximum(500)  # 5.0x
        self.scale_slider.setValue(100)    # 1.0x
        self.scale_slider.valueChanged.connect(self._on_scale_changed)
        scale_layout.addWidget(self.scale_slider)

        scale_info_layout = QHBoxLayout()
        scale_info_layout.addWidget(QLabel("0.1x"))
        self.scale_label = QLabel("1.0x")
        self.scale_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        scale_info_layout.addWidget(self.scale_label)
        scale_info_layout.addWidget(QLabel("5.0x"))
        scale_layout.addLayout(scale_info_layout)
        
        layout.addWidget(scale_group)

        layout.addStretch()

    def _on_scale_changed(self, value: int):
        scale = value / 100.0
        self.scale_label.setText(f"{scale:.1f}x")
        self.vectorScaleChanged.emit(scale)

class PerformancePanel(QWidget):
    """Performance monitoring panel"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._setup_ui()
    
    def _setup_ui(self):
        """Setup performance monitoring UI"""
        layout = QHBoxLayout(self)
        layout.setContentsMargins(10, 5, 10, 5)
        
        self.fps_label = QLabel("FPS: --")
        self.fps_label.setStyleSheet("color: #00ff00; font-weight: bold;")
        
        self.frame_label = QLabel("Frame: -- / --")
        self.frame_label.setStyleSheet("color: #ffffff;")
        
        self.time_label = QLabel("Time: --.--s")
        self.time_label.setStyleSheet("color: #ffffff;")
        
        self.render_time_label = QLabel("Render: --.--ms")
        self.render_time_label.setStyleSheet("color: #ffffff;")
        
        layout.addWidget(self.fps_label)
        layout.addWidget(QLabel("|"))
        layout.addWidget(self.frame_label)
        layout.addWidget(QLabel("|"))
        layout.addWidget(self.time_label)
        layout.addWidget(QLabel("|"))
        layout.addWidget(self.render_time_label)
        layout.addStretch()
    
    def update_fps(self, fps: float):
        """Update FPS display"""
        self.fps_label.setText(f"FPS: {fps:.1f}")
        
        # Color code based on performance
        if fps >= 30:
            color = "#00ff00"  # Green
        elif fps >= 15:
            color = "#ffff00"  # Yellow
        else:
            color = "#ff0000"  # Red
        
        self.fps_label.setStyleSheet(f"color: {color}; font-weight: bold;")
    
    def update_frame_info(self, current_frame: int, total_frames: int, time_seconds: float):
        """Update frame information"""
        self.frame_label.setText(f"Frame: {current_frame} / {total_frames}")
        self.time_label.setText(f"Time: {time_seconds:.3f}s")
    
    def update_render_time(self, render_time_ms: float):
        """Update render time"""
        self.render_time_label.setText(f"Render: {render_time_ms:.2f}ms")

# ============================================================================
# MAIN APPLICATION WINDOW
# ============================================================================

class GolfVisualizerMainWindow(QMainWindow):
    """Main application window with modern UI"""
    
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Modern Golf Swing Visualizer")
        self.setGeometry(100, 100, 1600, 1000)
        self.setMinimumSize(1200, 800)
        
        # Create central widget and layout
        self.gl_widget = GolfVisualizerWidget()
        self.setCentralWidget(self.gl_widget)
        
        # Create control panels
        self._create_dock_panels()
        self._create_menu_bar()
        self._create_toolbar()
        self._create_status_bar()
        
        # Connect signals
        self._connect_signals()
        
        # Apply modern styling
        self._apply_modern_style()
        
        # Status
        self.show_status_message("Ready - Load data to begin")
        
        # Initialize data core
        self._initialize_data_core()
        
        print("🚀 Golf Visualizer main window created")
    
    def _create_dock_panels(self):
        """Create dockable control panels"""
        # Playback controls (left)
        self.playback_panel = PlaybackControlPanel()
        playback_dock = QDockWidget("Playback", self)
        playback_dock.setWidget(self.playback_panel)
        playback_dock.setFeatures(QDockWidget.DockWidgetFeature.DockWidgetMovable | 
                                 QDockWidget.DockWidgetFeature.DockWidgetFloatable)
        self.addDockWidget(Qt.DockWidgetArea.LeftDockWidgetArea, playback_dock)
        
        # Visualization controls (right)
        self.viz_panel = VisualizationControlPanel()
        viz_dock = QDockWidget("Visualization", self)
        viz_dock.setWidget(self.viz_panel)
        viz_dock.setFeatures(QDockWidget.DockWidgetFeature.DockWidgetMovable | 
                            QDockWidget.DockWidgetFeature.DockWidgetFloatable)
        self.addDockWidget(Qt.DockWidgetArea.RightDockWidgetArea, viz_dock)
        
        # Analysis controls (right, tabbed with visualization)
        self.analysis_panel = AnalysisControlPanel()
        analysis_dock = QDockWidget("Analysis", self)
        analysis_dock.setWidget(self.analysis_panel)
        analysis_dock.setFeatures(QDockWidget.DockWidgetFeature.DockWidgetMovable |
                                  QDockWidget.DockWidgetFeature.DockWidgetFloatable)
        self.addDockWidget(Qt.DockWidgetArea.RightDockWidgetArea, analysis_dock)

        # Tabify the right docks
        self.tabifyDockWidget(viz_dock, analysis_dock)
        
        # Performance monitor (bottom)
        self.perf_panel = PerformancePanel()
        perf_dock = QDockWidget("Performance", self)
        perf_dock.setWidget(self.perf_panel)
        perf_dock.setFeatures(QDockWidget.DockWidgetFeature.DockWidgetMovable | 
                             QDockWidget.DockWidgetFeature.DockWidgetFloatable)
        self.addDockWidget(Qt.DockWidgetArea.BottomDockWidgetArea, perf_dock)
    
    def _create_menu_bar(self):
        """Create menu bar"""
        menubar = self.menuBar()
        
        # File menu
        file_menu = menubar.addMenu("File")
        
        load_action = QAction("Load Data...", self)
        load_action.setShortcut("Ctrl+O")
        load_action.triggered.connect(self._load_data_dialog)
        file_menu.addAction(load_action)
        
        file_menu.addSeparator()
        
        export_action = QAction("Export Screenshot...", self)
        export_action.setShortcut("Ctrl+S")
        export_action.triggered.connect(self._export_screenshot)
        file_menu.addAction(export_action)
        
        file_menu.addSeparator()
        
        exit_action = QAction("Exit", self)
        exit_action.setShortcut("Ctrl+Q")
        exit_action.triggered.connect(self.close)
        file_menu.addAction(exit_action)
        
        # View menu
        view_menu = menubar.addMenu("View")
        
        reset_camera_action = QAction("Reset Camera", self)
        reset_camera_action.setShortcut("R")
        reset_camera_action.triggered.connect(self.gl_widget.reset_camera)
        view_menu.addAction(reset_camera_action)
        
        frame_data_action = QAction("Frame Data", self)
        frame_data_action.setShortcut("F")
        frame_data_action.triggered.connect(lambda: (self.gl_widget._frame_data_in_view(), self.gl_widget.update()))
        view_menu.addAction(frame_data_action)
        
        # Help menu
        help_menu = menubar.addMenu("Help")
        
        about_action = QAction("About", self)
        about_action.triggered.connect(self._show_about)
        help_menu.addAction(about_action)
    
    def _create_toolbar(self):
        """Create toolbar with quick actions"""
        toolbar = self.addToolBar("Main")
        toolbar.setMovable(False)
        
        # Load data
        load_action = QAction("📁", self)
        load_action.setToolTip("Load Data (Ctrl+O)")
        load_action.triggered.connect(self._load_data_dialog)
        toolbar.addAction(load_action)
        
        toolbar.addSeparator()
        
        # Playback controls
        play_action = QAction("▶", self)
        play_action.setToolTip("Play/Pause (Space)")
        play_action.triggered.connect(self.gl_widget.toggle_playback)
        toolbar.addAction(play_action)
        
        prev_action = QAction("⏪", self)
        prev_action.setToolTip("Previous Frame (Left Arrow)")
        prev_action.triggered.connect(self.gl_widget.previous_frame)
        toolbar.addAction(prev_action)
        
        next_action = QAction("⏩", self)
        next_action.setToolTip("Next Frame (Right Arrow)")
        next_action.triggered.connect(self.gl_widget.next_frame)
        toolbar.addAction(next_action)
        
        toolbar.addSeparator()
        
        # Camera controls
        reset_cam_action = QAction("🎯", self)
        reset_cam_action.setToolTip("Reset Camera (R)")
        reset_cam_action.triggered.connect(self.gl_widget.reset_camera)
        toolbar.addAction(reset_cam_action)
        
        frame_data_action = QAction("🔍", self)
        frame_data_action.setToolTip("Frame Data (F)")
        frame_data_action.triggered.connect(lambda: (self.gl_widget._frame_data_in_view(), self.gl_widget.update()))
        toolbar.addAction(frame_data_action)
    
    def _create_status_bar(self):
        """Create status bar"""
        self.status_bar = self.statusBar()
        if self.status_bar:
            self.status_bar.setStyleSheet("background-color: #2b2b2b; color: #ffffff;")
        
    def show_status_message(self, message: str, timeout: int = 5000):
        """Show a status message in the status bar with optional timeout"""
        if hasattr(self, 'status_bar') and self.status_bar:
            self.status_bar.showMessage(message, timeout)
        print(f"Status: {message}")
    
    def _connect_signals(self):
        """Connect all widget signals"""
        # GL widget signals
        self.gl_widget.frameChanged.connect(self._on_frame_changed)
        self.gl_widget.fpsUpdated.connect(self.perf_panel.update_fps)
        self.gl_widget.statusMessage.connect(self.show_status_message)
        
        # Playback panel signals
        self.playback_panel.playToggled.connect(self.gl_widget.toggle_playback)
        self.playback_panel.frameChanged.connect(self.gl_widget.set_frame)
        self.playback_panel.speedChanged.connect(self.gl_widget.set_playback_speed)
        
        # Visualization panel signals
        self.viz_panel.renderConfigChanged.connect(self._on_render_config_changed)

        # Analysis panel signals
        self.analysis_panel.filterChanged.connect(self._on_filter_changed)
        self.analysis_panel.showCalculatedForceChanged.connect(self._on_show_calculated_force_changed)
        self.analysis_panel.showCalculatedTorqueChanged.connect(self._on_show_calculated_torque_changed)
        self.analysis_panel.vectorScaleChanged.connect(self._on_calculated_vector_scale_changed)

    def _on_frame_changed(self, frame_idx: int):
        """Handle frame changes from GL widget"""
        if self.gl_widget.frame_processor:
            # Get the frame data for the current frame
            frame_data = self.gl_widget.frame_processor.get_frame_data(frame_idx)
            
            # Update UI elements that depend on the current frame
            if hasattr(self, 'data_core') and self.data_core:
                self.data_core.current_frame = frame_idx
                
            # Update playback panel
            self.playback_panel.update_current_frame(frame_idx)
            
            # Update performance panel
            time_seconds = frame_idx * 0.001  # Assume 1000 Hz
            total_frames = self.gl_widget.num_frames
            render_time_ms = self.gl_widget.performance_stats.frame_time_ms
            self.perf_panel.update_frame_info(frame_idx, total_frames, time_seconds)
            self.perf_panel.update_render_time(render_time_ms)
            self.perf_panel.update_frame_info(frame_idx, total_frames, time_seconds)
            self.perf_panel.update_render_time(render_time_ms)
    
    def _on_render_config_changed(self, config: RenderConfig):
        """Handle render config changes from visualization panel"""
        if hasattr(self, 'gl_widget') and self.gl_widget:
            self.gl_widget.render_config = config
            self.gl_widget.update()
            
    def _initialize_data_core(self):
        """Initialize the data core for the application"""
        # This would normally happen when loading data
        if not hasattr(self, 'data_core'):
            from golf_data_core import FrameProcessor, RenderConfig
            import pandas as pd
            import numpy as np
            # Create empty datasets for initialization
            empty_df = pd.DataFrame()
            self.data_core = FrameProcessor((empty_df, empty_df, empty_df), RenderConfig())
    
    def _on_filter_changed(self, filter_type: str):
        """Handle filter type changes from the analysis panel"""
        if hasattr(self, 'data_core') and self.data_core:
            self.data_core.set_filter_type(filter_type)
            self.show_status_message(f"Filter changed to: {filter_type}")
            if hasattr(self, 'gl_widget') and self.gl_widget:
                self.gl_widget.update()
        else:
            self._initialize_data_core()
            if hasattr(self, 'data_core') and self.data_core:
                self.data_core.set_filter_type(filter_type)

    def _on_show_calculated_force_changed(self, visible: bool):
        """Handle force vector visibility toggle from the analysis panel"""
        if hasattr(self, 'data_core') and self.data_core:
            self.data_core.set_vector_visibility("force", visible)
            self.show_status_message(f"Force vectors {'shown' if visible else 'hidden'}")
            if hasattr(self, 'gl_widget') and self.gl_widget:
                self.gl_widget.update()

    def _on_show_calculated_torque_changed(self, visible: bool):
        """Handle torque vector visibility toggle from the analysis panel"""
        if hasattr(self, 'data_core') and self.data_core:
            self.data_core.set_vector_visibility("torque", visible)
            self.show_status_message(f"Torque vectors {'shown' if visible else 'hidden'}")
            if hasattr(self, 'gl_widget') and self.gl_widget:
                self.gl_widget.update()

    def _on_calculated_vector_scale_changed(self, scale: float):
        """Handle vector scale changes from the analysis panel"""
        if hasattr(self, 'data_core') and self.data_core:
            self.data_core.set_vector_scale("all", scale)
            self.show_status_message(f"Vector scale set to {scale:.1f}")
            if hasattr(self, 'gl_widget') and self.gl_widget:
                self.gl_widget.update()

    def _load_data_dialog(self):
        """Open a dialog to select and load data files."""
        self.show_status_message("Select the folder containing BASEQ.mat, ZTCFQ.mat, and DELTAQ.mat")
        folder = QFileDialog.getExistingDirectory(self, "Select Data Folder")
        
        if folder:
            baseq_file = Path(folder) / "BASEQ.mat"
            ztcfq_file = Path(folder) / "ZTCFQ.mat"
            delta_file = Path(folder) / "DELTAQ.mat"
            
            if all(f.exists() for f in [baseq_file, ztcfq_file, delta_file]):
                if self.gl_widget.load_data(str(baseq_file), str(ztcfq_file), str(delta_file)):
                    self.playback_panel.update_num_frames(self.gl_widget.num_frames)
                    self.playback_panel.update_current_frame(0)
                    self.show_status_message(f"Loaded {self.gl_widget.num_frames} frames successfully")
                else:
                    QMessageBox.critical(self, "Error", "Failed to load data. Check console for details.")
                    self.show_status_message("Failed to load data.")
            else:
                QMessageBox.warning(self, "Warning", "One or more required .mat files not found in the selected folder.")
                self.show_status_message("Data loading cancelled.")

    def _export_screenshot(self):
        """Export screenshot"""
        filename, _ = QFileDialog.getSaveFileName(
            self, "Save Screenshot", "golf_swing_screenshot.png",
            "PNG files (*.png);;JPEG files (*.jpg)"
        )
        
        if filename:
            pixmap = self.gl_widget.grab()
            if pixmap.save(filename):
                self.show_status_message(f"Screenshot saved: {filename}")
            else:
                QMessageBox.critical(self, "Error", "Failed to save screenshot")
    
    def _show_about(self):
        """Show about dialog"""
        QMessageBox.about(self, "About Golf Swing Visualizer",
                         """
                         <h3>Modern Golf Swing Visualizer</h3>
                         <p>High-performance 3D visualization tool for golf swing biomechanics analysis.</p>
                         <p><b>Features:</b></p>
                         <ul>
                         <li>Real-time 3D rendering with OpenGL</li>
                         <li>Multi-dataset force and torque visualization</li>
                         <li>Interactive camera controls</li>
                         <li>Modern, responsive user interface</li>
                         </ul>
                         <p><b>Controls:</b></p>
                         <ul>
                         <li>Mouse: Orbit/pan camera</li>
                         <li>Wheel: Zoom</li>
                         <li>Space: Play/pause</li>
                         <li>Arrow keys: Frame navigation</li>
                         <li>R: Reset camera</li>
                         <li>F: Frame data</li>
                         </ul>
                         """)
    
    def _apply_modern_style(self):
        """Apply modern dark theme styling"""
        style = """
        QMainWindow {
            background-color: #2b2b2b;
            color: #ffffff;
        }
        
        QDockWidget {
            color: #ffffff;
            background-color: #3c3c3c;
            border: 1px solid #5a5a5a;
        }
        
        QDockWidget::title {
            background-color: #4a4a4a;
            padding: 8px;
            border-bottom: 1px solid #5a5a5a;
            font-weight: bold;
        }
        
        QWidget {
            background-color: #3c3c3c;
            color: #ffffff;
        }
        
        QPushButton {
            background-color: #4a4a4a;
            border: 1px solid #6a6a6a;
            color: #ffffff;
            padding: 8px 16px;
            border-radius: 6px;
            font-weight: bold;
        }
        
        QPushButton:hover {
            background-color: #5a5a5a;
            border-color: #7a7a7a;
        }
        
        QPushButton:pressed {
            background-color: #3a3a3a;
            border-color: #5a5a5a;
        }
        
        QSlider::groove:horizontal {
            border: 1px solid #5a5a5a;
            height: 8px;
            background: #3a3a3a;
            border-radius: 4px;
        }
        
        QSlider::handle:horizontal {
            background: #0078d4;
            border: 1px solid #005a9e;
            width: 18px;
            margin: -5px 0;
            border-radius: 9px;
        }
        
        QSlider::handle:horizontal:hover {
            background: #106ebe;
        }
        
        QCheckBox {
            color: #ffffff;
            spacing: 8px;
            font-weight: normal;
        }
        
        QCheckBox::indicator {
            width: 16px;
            height: 16px;
            border-radius: 3px;
        }
        
        QCheckBox::indicator:unchecked {
            background-color: #3a3a3a;
            border: 2px solid #6a6a6a;
        }
        
        QCheckBox::indicator:checked {
            background-color: #0078d4;
            border: 2px solid #005a9e;
        }
        
        QGroupBox {
            color: #ffffff;
            border: 2px solid #5a5a5a;
            border-radius: 8px;
            margin-top: 12px;
            font-weight: bold;
            padding-top: 8px;
        }
        
        QGroupBox::title {
            subcontrol-origin: margin;
            subcontrol-position: top center;
            padding: 0 8px;
            background-color: #3c3c3c;
        }
        
        QLabel {
            color: #ffffff;
        }
        
        QMenuBar {
            background-color: #2b2b2b;
            color: #ffffff;
            border-bottom: 1px solid #5a5a5a;
        }
        
        QMenuBar::item {
            background-color: transparent;
            padding: 8px 12px;
        }
        
        QMenuBar::item:selected {
            background-color: #4a4a4a;
        }
        
        QMenu {
            background-color: #3c3c3c;
            color: #ffffff;
            border: 1px solid #5a5a5a;
        }
        
        QMenu::item {
            padding: 8px 20px;
        }
        
        QMenu::item:selected {
            background-color: #0078d4;
        }
        
        QToolBar {
            background-color: #3c3c3c;
            border: 1px solid #5a5a5a;
            spacing: 4px;
            padding: 4px;
        }
        
        QToolBar QToolButton {
            background-color: #4a4a4a;
            border: 1px solid #6a6a6a;
            padding: 6px;
            border-radius: 4px;
            font-size: 16px;
        }
        
        QToolBar QToolButton:hover {
            background-color: #5a5a5a;
        }
        
        QStatusBar {
            background-color: #2b2b2b;
            color: #ffffff;
            border-top: 1px solid #5a5a5a;
        }
        """
        
        self.setStyleSheet(style)

# ============================================================================
# MAIN APPLICATION
# ============================================================================

def main():
    """Main application entry point"""
    app = QApplication(sys.argv)
    app.setApplicationName("Modern Golf Swing Visualizer")
    app.setApplicationVersion("2.0")
    app.setOrganizationName("Golf Swing Analytics")
    
    # Set application icon (if available)
    # app.setWindowIcon(QIcon("icon.png"))
    
    # Create and show main window
    window = GolfVisualizerMainWindow()
    window.show()
    
    print("🚀 Golf Swing Visualizer started")
    print("   Use File -> Load Data to load MATLAB files")
    print("   Mouse controls: Left=orbit, Right=pan, Wheel=zoom")
    print("   Keyboard shortcuts: Space=play/pause, Arrows=navigate, R=reset camera")
    
    # Run the application
    sys.exit(app.exec())

if __name__ == '__main__':
    main()
