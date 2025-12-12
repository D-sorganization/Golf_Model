import sys
import os
import pytest
from unittest.mock import MagicMock, patch, call

# Gracefully skip if PyQt6 is not installed (e.g. in CI environments)
try:
    from PyQt6.QtWidgets import QApplication
    from PyQt6.QtCore import Qt
except ImportError:
    pytest.skip("PyQt6 not installed", allow_module_level=True)

# Ensure QApplication exists
@pytest.fixture(scope="session")
def qapp():
    app = QApplication.instance()
    if app is None:
        app = QApplication(sys.argv)
    yield app

def test_c3d_viewer_open_file_ux(qapp):
    """
    Test that opening a file triggers the expected UX behaviors
    (wait cursor, status bar update).
    """
    # Import inside test to avoid ImportError at module level if skip didn't catch it for some reason
    # (though allow_module_level=True handles it)
    from apps.c3d_viewer import C3DViewerMainWindow

    window = C3DViewerMainWindow()

    # We want to verify status bar messages.
    # QMainWindow.statusBar() returns the QStatusBar widget.
    # We can spy on the returned widget's showMessage method.
    real_status_bar = window.statusBar()
    real_status_bar.showMessage = MagicMock()

    # Mock the file dialog
    test_path = "/path/to/test.c3d"
    with patch("PyQt6.QtWidgets.QFileDialog.getOpenFileName", return_value=(test_path, "C3D files (*.c3d)")):

        # Mock ezc3d
        with patch("ezc3d.c3d") as mock_c3d:
            # Minimal mock data
            mock_data = MagicMock()
            mock_data.__getitem__.side_effect = lambda k: {
                "data": {"points": MagicMock(shape=(4, 1, 1)), "analogs": MagicMock(shape=(1,1,1))},
                "parameters": {
                    "POINT": {"LABELS": {"value": []}, "UNITS": {"value": [""]}, "RATE": {"value": [1.0]}},
                    "ANALOG": {"LABELS": {"value": []}, "RATE": {"value": [1.0]}, "UNITS": {"value": []}},
                    "TRIAL": {}
                }
            }.get(k, {})
            mock_c3d.return_value = mock_data

            with patch("PyQt6.QtWidgets.QApplication.setOverrideCursor") as mock_set_cursor:
                with patch("PyQt6.QtWidgets.QApplication.restoreOverrideCursor") as mock_restore_cursor:

                    window.open_c3d_file()

                    # Verify basic execution
                    assert mock_c3d.called

                    # Verify Cursor UX
                    mock_set_cursor.assert_called_once_with(Qt.CursorShape.WaitCursor)
                    mock_restore_cursor.assert_called_once()

                    # Verify Status Bar UX
                    # calls: "Loading test.c3d...", "Loaded test.c3d successfully."
                    assert real_status_bar.showMessage.call_count == 2

                    filename = os.path.basename(test_path)
                    expected_calls = [
                        call(f"Loading {filename}..."),
                        call(f"Loaded {filename} successfully.")
                    ]
                    real_status_bar.showMessage.assert_has_calls(expected_calls)
