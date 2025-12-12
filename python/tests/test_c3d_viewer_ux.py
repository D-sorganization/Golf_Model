
import sys
import os
from typing import Any
from unittest.mock import MagicMock, patch
import pytest
from PyQt6.QtCore import Qt
from PyQt6 import QtWidgets

# Ensure python/src is in sys.path (conftest handles this usually, but for direct run/safety)
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../src')))

from apps.c3d_viewer import C3DViewerMainWindow

def test_open_c3d_file_shows_wait_cursor(qtbot: Any) -> None:
    """Test that opening a C3D file sets the wait cursor and restores it."""

    # Create the window
    window = C3DViewerMainWindow()
    qtbot.addWidget(window)

    # Mock QFileDialog to return a file path
    with patch('PyQt6.QtWidgets.QFileDialog.getOpenFileName', return_value=('/tmp/fake.c3d', 'C3D files (*.c3d)')):

        # Mock _load_c3d to verify it's called
        # We need to mock it on the instance, but patching the class method is easier if we don't have the instance yet or want to patch before call
        # But here we have 'window'.
        with patch.object(window, '_load_c3d') as mock_load:
            # Return a dummy model so _populate_ui_with_model doesn't crash
            mock_model = MagicMock()
            mock_model.filepath = "/tmp/fake.c3d"
            mock_model.marker_names.return_value = []
            mock_model.analog_names.return_value = []
            mock_model.point_time = None
            mock_model.analog_time = None
            mock_model.metadata = {}
            mock_load.return_value = mock_model

            # Mock status bar
            mock_status_bar = MagicMock()
            with patch.object(window, 'statusBar', return_value=mock_status_bar):

                with patch('PyQt6.QtWidgets.QApplication.setOverrideCursor') as mock_set_cursor:
                    with patch('PyQt6.QtWidgets.QApplication.restoreOverrideCursor') as mock_restore_cursor:

                         # Call the method
                         window.open_c3d_file()

                         # Assertions
                         # Check if wait cursor was set
                         mock_set_cursor.assert_called_with(Qt.CursorShape.WaitCursor)

                         # Check if cursor was restored
                         mock_restore_cursor.assert_called()

                         # Check if status bar was updated
                         # We expect "Loading..." then "Loaded..." or similar
                         assert mock_status_bar.showMessage.call_count >= 1

def test_open_c3d_file_restores_cursor_on_error(qtbot: Any) -> None:
    """Test that cursor is restored even if loading fails."""

    window = C3DViewerMainWindow()
    qtbot.addWidget(window)

    with patch('PyQt6.QtWidgets.QFileDialog.getOpenFileName', return_value=('/tmp/fake.c3d', 'C3D files (*.c3d)')):
        with patch.object(window, '_load_c3d', side_effect=Exception("Load failed")):

            mock_status_bar = MagicMock()
            with patch.object(window, 'statusBar', return_value=mock_status_bar):

                with patch('PyQt6.QtWidgets.QApplication.setOverrideCursor') as mock_set_cursor:
                    with patch('PyQt6.QtWidgets.QApplication.restoreOverrideCursor') as mock_restore_cursor:
                         with patch('PyQt6.QtWidgets.QMessageBox.critical') as mock_msg:

                             window.open_c3d_file()

                             mock_set_cursor.assert_called_with(Qt.CursorShape.WaitCursor)
                             # It should be restored
                             mock_restore_cursor.assert_called()
                             # Error message shown
                             mock_msg.assert_called_once()
