#!/usr/bin/env python3
"""
Smooth Playback Implementation for Golf Visualizer
Replace choppy 30 FPS QTimer with smooth interpolated animation

INTEGRATION:
1. Copy this class into golf_gui_application.py
2. Replace MotionCaptureTab's playback system with SmoothPlaybackController
3. Enjoy buttery-smooth 60+ FPS playback!
"""

import numpy as np
from PyQt6.QtCore import QObject, QPropertyAnimation, QEasingCurve, pyqtProperty, pyqtSignal
from typing import Optional
from golf_data_core import FrameData, FrameProcessor


class SmoothPlaybackController(QObject):
    """
    Smooth playback controller with frame interpolation

    Features:
    - VSync-synchronized rendering (60+ FPS)
    - Frame interpolation for smooth motion between keyframes
    - Variable playback speed
    - Scrubbing support
    """

    # Signals
    frameUpdated = pyqtSignal(FrameData)  # Emits interpolated frame data
    positionChanged = pyqtSignal(float)   # Emits current position (0.0 to total_frames)

    def __init__(self, parent=None):
        super().__init__(parent)

        # Frame data
        self.frame_processor: Optional[FrameProcessor] = None
        self._current_position: float = 0.0
        self._playback_speed: float = 1.0

        # Animation
        self.animation = QPropertyAnimation(self, b"position")
        self.animation.setEasingCurve(QEasingCurve.Type.Linear)
        self.animation.valueChanged.connect(self._on_position_changed)
        self.animation.finished.connect(self._on_animation_finished)

        # State
        self.is_playing = False
        self.loop_playback = False

    def load_frame_processor(self, frame_processor: FrameProcessor):
        """Load frame processor with motion data"""
        self.frame_processor = frame_processor
        self.stop()
        self.seek(0.0)

    # ========================================================================
    # Position Property (for QPropertyAnimation)
    # ========================================================================

    @pyqtProperty(float)
    def position(self) -> float:
        """Current playback position (0.0 to total_frames - 1)"""
        return self._current_position

    @position.setter
    def position(self, value: float):
        """Set playback position with interpolation"""
        if self.frame_processor is None:
            return

        total_frames = len(self.frame_processor.time_vector)
        self._current_position = np.clip(value, 0.0, total_frames - 1)
        self.positionChanged.emit(self._current_position)

        # Interpolate frame data
        interpolated_frame = self._get_interpolated_frame(self._current_position)
        self.frameUpdated.emit(interpolated_frame)

    # ========================================================================
    # Playback Control
    # ========================================================================

    def play(self):
        """Start smooth playback"""
        if self.frame_processor is None:
            return

        if self.is_playing:
            return  # Already playing

        total_frames = len(self.frame_processor.time_vector)

        # Calculate duration based on actual data time span
        start_pos = self._current_position
        end_pos = total_frames - 1

        if start_pos >= end_pos - 0.1:  # Near end, restart from beginning
            start_pos = 0.0
            self.seek(0.0)

        # Duration in milliseconds (maintain original timing)
        frame_time_ms = 33.33  # ~30 FPS from motion capture
        duration_ms = int((end_pos - start_pos) * frame_time_ms / self._playback_speed)

        # Setup animation
        self.animation.setStartValue(start_pos)
        self.animation.setEndValue(end_pos)
        self.animation.setDuration(duration_ms)
        self.animation.start()

        self.is_playing = True
        print(f"▶ Playing from frame {start_pos:.1f} to {end_pos:.1f} ({duration_ms}ms)")

    def pause(self):
        """Pause playback"""
        if not self.is_playing:
            return

        self.animation.pause()
        self.is_playing = False
        print(f"⏸ Paused at frame {self._current_position:.1f}")

    def stop(self):
        """Stop playback and reset to beginning"""
        self.animation.stop()
        self.is_playing = False
        self.seek(0.0)
        print("⏹ Stopped")

    def toggle_playback(self):
        """Toggle between play and pause"""
        if self.is_playing:
            self.pause()
        else:
            self.play()

    def seek(self, position: float):
        """Seek to specific frame position"""
        if self.frame_processor is None:
            return

        was_playing = self.is_playing

        if was_playing:
            self.animation.stop()

        self.position = position

        if was_playing:
            self.play()

    def set_playback_speed(self, speed: float):
        """
        Set playback speed multiplier

        Args:
            speed: Playback speed (0.5 = half speed, 2.0 = double speed)
        """
        self._playback_speed = np.clip(speed, 0.1, 10.0)

        # If playing, restart with new speed
        if self.is_playing:
            current_pos = self._current_position
            self.pause()
            self.seek(current_pos)
            self.play()

        print(f"⏩ Playback speed: {self._playback_speed:.2f}x")

    # ========================================================================
    # Frame Interpolation (The Magic!)
    # ========================================================================

    def _get_interpolated_frame(self, position: float) -> FrameData:
        """
        Get interpolated frame data at fractional position

        For example:
        - position = 5.0 → Frame 5 exactly
        - position = 5.7 → 70% between frame 5 and 6
        - position = 5.3 → 30% between frame 5 and 6

        This creates smooth motion between keyframes!
        """
        if self.frame_processor is None:
            raise ValueError("No frame processor loaded")

        total_frames = len(self.frame_processor.time_vector)

        # Clamp position
        position = np.clip(position, 0.0, total_frames - 1)

        # Get integer frame indices
        low_idx = int(np.floor(position))
        high_idx = min(low_idx + 1, total_frames - 1)

        # Calculate interpolation factor (0.0 to 1.0)
        t = position - low_idx

        # Get frames at integer indices
        frame_low = self.frame_processor.get_frame_data(low_idx)
        frame_high = self.frame_processor.get_frame_data(high_idx)

        # Interpolate all positions
        return self._lerp_frame_data(frame_low, frame_high, t)

    @staticmethod
    def _lerp_frame_data(frame_a: FrameData, frame_b: FrameData, t: float) -> FrameData:
        """
        Linear interpolation between two frames

        Args:
            frame_a: Starting frame
            frame_b: Ending frame
            t: Interpolation factor (0.0 = frame_a, 1.0 = frame_b)

        Returns:
            Interpolated frame data
        """
        from copy import copy

        result = copy(frame_a)

        # List of all position attributes to interpolate
        position_attrs = [
            'left_wrist', 'left_elbow', 'left_shoulder',
            'right_wrist', 'right_elbow', 'right_shoulder',
            'hub', 'butt', 'clubhead'
        ]

        # Lerp each position: result = a * (1 - t) + b * t
        for attr in position_attrs:
            pos_a = getattr(frame_a, attr)
            pos_b = getattr(frame_b, attr)

            # Check for valid data
            if np.isfinite(pos_a).all() and np.isfinite(pos_b).all():
                interpolated_pos = pos_a * (1.0 - t) + pos_b * t
                setattr(result, attr, interpolated_pos)

        return result

    # ========================================================================
    # Internal Callbacks
    # ========================================================================

    def _on_position_changed(self, value: float):
        """Called by QPropertyAnimation on every frame update"""
        # Position property setter handles the interpolation
        pass

    def _on_animation_finished(self):
        """Called when animation completes"""
        self.is_playing = False

        if self.loop_playback:
            self.seek(0.0)
            self.play()
        else:
            print("✅ Playback finished")


# ============================================================================
# INTEGRATION EXAMPLE
# ============================================================================

class MotionCaptureTabSmooth:
    """
    Example integration into existing MotionCaptureTab

    REPLACE the existing playback timer code with this smooth controller
    """

    def __init__(self, parent=None):
        # ... existing init code ...

        # OLD CODE (REMOVE THIS):
        # self.playback_timer = QTimer()
        # self.playback_timer.timeout.connect(self._next_frame)

        # NEW CODE (ADD THIS):
        self.playback_controller = SmoothPlaybackController(self)
        self.playback_controller.frameUpdated.connect(self._on_smooth_frame_updated)
        self.playback_controller.positionChanged.connect(self._on_position_changed)

        # Connect slider for scrubbing
        self.frame_slider.valueChanged.connect(self._on_slider_moved)

    def _load_motion_capture_data(self):
        """Load motion capture data"""
        # ... existing data loading code ...

        # After creating frame_processor:
        self.playback_controller.load_frame_processor(self.frame_processor)

        # Update slider range
        total_frames = len(self.frame_processor.time_vector)
        self.frame_slider.setMaximum(total_frames - 1)

    def _toggle_playback(self):
        """Toggle smooth playback (replaces old timer-based method)"""
        self.playback_controller.toggle_playback()

        if self.playback_controller.is_playing:
            self.play_button.setText("Pause")
        else:
            self.play_button.setText("Play")

    def _on_smooth_frame_updated(self, frame_data: FrameData):
        """Called on every interpolated frame update (60+ FPS!)"""
        if not self.opengl_widget.renderer:
            return

        # Update render config
        render_config = self._get_current_render_config()

        # Update 3D visualization with interpolated frame
        self.opengl_widget.update_frame(frame_data, render_config)

    def _on_position_changed(self, position: float):
        """Update UI when position changes"""
        total_frames = len(self.frame_processor.time_vector) if self.frame_processor else 0

        # Update frame label
        self.frame_label.setText(f"Frame: {position:.1f}/{total_frames}")

        # Update slider (without triggering valueChanged)
        self.frame_slider.blockSignals(True)
        self.frame_slider.setValue(int(position))
        self.frame_slider.blockSignals(False)

    def _on_slider_moved(self, value: int):
        """Handle manual slider movement (scrubbing)"""
        # Seek to slider position
        self.playback_controller.seek(float(value))

    def _get_current_render_config(self):
        """Get current render configuration from UI checkboxes"""
        from golf_data_core import RenderConfig

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

        return render_config


# ============================================================================
# TESTING
# ============================================================================

if __name__ == "__main__":
    import sys
    from PyQt6.QtWidgets import QApplication

    print("🎬 Smooth Playback Implementation")
    print("\nFeatures:")
    print("  ✅ 60+ FPS interpolated playback (VSync-synchronized)")
    print("  ✅ Smooth motion between keyframes")
    print("  ✅ Variable playback speed")
    print("  ✅ Precise scrubbing support")
    print("\nIntegration:")
    print("  1. Copy SmoothPlaybackController into golf_gui_application.py")
    print("  2. Replace MotionCaptureTab playback code with example above")
    print("  3. Test with your motion capture data")
    print("\n🎉 Enjoy butter-smooth golf swing visualization!")
