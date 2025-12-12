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

def test_csv_injection_prevention(tmp_path: Path) -> None:
    """
    Test that CSV injection is prevented by sanitizing output.
    If a marker label starts with '=', it should be escaped.
    """
    # Create a reader with a malicious marker label
    malicious_label = "=SUM(1+1)"
    reader = _stub_reader_with_points_mock(marker_labels=(malicious_label,))

    export_path = tmp_path / "sanitized.csv"
    reader.export_points(export_path)

    assert export_path.exists()
    content = export_path.read_text(encoding="utf-8")

    # Check that the content contains the escaped label
    # Should be exactly '=SUM(1+1) (which appears as '=SUM(1+1) in the file content?)
    # Wait, pandas to_csv might quote it.

    print(f"\nContent of CSV:\n{content}")

    # We expect the malicious label to be preceded by a single quote
    escaped_label = f"'{malicious_label}"

    # Pandas to_csv doesn't quote unless needed. '=SUM(1+1) is a string.
    # It might just output '=SUM(1+1),...

    assert f"{escaped_label}" in content
