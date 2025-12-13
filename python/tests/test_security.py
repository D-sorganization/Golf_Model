"""Tests for security vulnerabilities in C3D data reader."""

import pytest
import pandas as pd
import numpy as np
from pathlib import Path
from src.c3d_reader import C3DDataReader

def _stub_reader_with_points_mock(
    marker_labels: tuple[str, ...] = ("Marker1",),
) -> C3DDataReader:
    """Create a stubbed reader with synthetic point data."""
    frame_count = 1
    point_rate = 100.0
    points = np.zeros((4, len(marker_labels), frame_count))

    reader = C3DDataReader(Path("synthetic"))
    reader._c3d_data = {
        "data": {"points": points, "analogs": np.zeros((1, 0, frame_count))},
        "parameters": {
            "POINT": {
                "LABELS": {"value": list(marker_labels)},
                "FRAMES": {"value": [frame_count]},
                "RATE": {"value": [point_rate]},
                "UNITS": {"value": ["m"]},
            },
        },
    }
    return reader

def test_csv_injection_prevention_default(tmp_path: Path) -> None:
    """
    Test that CSV injection is prevented by sanitizing output by default.
    """
    malicious_label = "=SUM(1+1)"
    reader = _stub_reader_with_points_mock(marker_labels=(malicious_label,))

    export_path = tmp_path / "sanitized.csv"
    reader.export_points(export_path)

    assert export_path.exists()
    content = export_path.read_text(encoding="utf-8")

    # Expect escaped label
    escaped_label = f"'{malicious_label}"
    assert f"{escaped_label}" in content

def test_csv_injection_allowed_when_requested(tmp_path: Path) -> None:
    """
    Test that CSV injection is allowed (raw output) when sanitize=False.
    """
    malicious_label = "=SUM(1+1)"
    reader = _stub_reader_with_points_mock(marker_labels=(malicious_label,))

    export_path = tmp_path / "raw.csv"
    reader.export_points(export_path, sanitize=False)

    assert export_path.exists()
    content = export_path.read_text(encoding="utf-8")

    # Expect raw label (no escape)
    # Note: Depending on CSV formatting, it might just be the string.
    # We ensure it does NOT start with '

    # Split by comma to find the marker column
    # format: frame,marker,x,y,z,residual,time
    # 0,=SUM(1+1),...

    assert f",{malicious_label}," in content or f"\n{malicious_label}," in content
    assert f"'{malicious_label}" not in content
