"""Tests for C3D data loading utilities."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pytest

from c3d_reader import C3DDataReader, load_tour_average_reader

EXPECTED_MARKER_COUNT = 38
EXPECTED_FRAME_COUNT = 654
EXPECTED_FRAME_RATE_HZ = 360.0
EXPECTED_POINT_UNITS = "m"
EXPECTED_ANALOG_COUNT = 0


def _tour_average_reader() -> C3DDataReader:
    repository_root = Path(__file__).resolve().parents[2]
    return load_tour_average_reader(repository_root)


def test_metadata_matches_expected_capture() -> None:
    reader = _tour_average_reader()
    metadata = reader.get_metadata()

    assert metadata.marker_count == EXPECTED_MARKER_COUNT
    assert metadata.frame_count == EXPECTED_FRAME_COUNT
    assert metadata.frame_rate == pytest.approx(EXPECTED_FRAME_RATE_HZ)
    assert metadata.units == EXPECTED_POINT_UNITS
    assert metadata.analog_count == EXPECTED_ANALOG_COUNT
    assert metadata.duration == pytest.approx(
        EXPECTED_FRAME_COUNT / EXPECTED_FRAME_RATE_HZ
    )
    assert metadata.marker_labels[1] == "WaistLeft"
    assert metadata.events == []


def test_points_dataframe_shape_and_columns() -> None:
    reader = _tour_average_reader()
    dataframe = reader.points_dataframe()

    expected_rows = EXPECTED_FRAME_COUNT * EXPECTED_MARKER_COUNT
    assert dataframe.shape[0] == expected_rows
    assert dataframe.shape[1] in (6, 7)  # With or without the optional time column
    expected_columns = {"frame", "marker", "x", "y", "z", "residual"}
    assert expected_columns.issubset(set(dataframe.columns))


def test_marker_time_series_is_ordered_and_numeric() -> None:
    reader = _tour_average_reader()
    dataframe = reader.points_dataframe()
    waist_left_frames = dataframe[dataframe["marker"] == "WaistLeft"].reset_index(
        drop=True
    )

    assert waist_left_frames["frame"].is_monotonic_increasing
    assert waist_left_frames[["x", "y", "z"]].apply(np.isfinite).all().all()
    if "time" in waist_left_frames.columns:
        assert waist_left_frames["time"].is_monotonic_increasing
        assert waist_left_frames.loc[1, "time"] - waist_left_frames.loc[
            0, "time"
        ] == pytest.approx(1 / EXPECTED_FRAME_RATE_HZ)


def test_marker_subset_and_unit_conversion() -> None:
    reader = _tour_average_reader()
    dataframe_meters = reader.points_dataframe(
        markers=["WaistLeft"], include_time=False
    )
    dataframe_mm = reader.points_dataframe(
        markers=["WaistLeft"], include_time=False, target_units="mm"
    )

    assert set(dataframe_meters["marker"].unique()) == {"WaistLeft"}
    assert set(dataframe_mm["marker"].unique()) == {"WaistLeft"}

    finite_m = dataframe_meters[["x", "y", "z"]].stack().dropna().iloc[0]
    finite_mm = dataframe_mm[["x", "y", "z"]].stack().dropna().iloc[0]
    assert finite_mm == pytest.approx(finite_m * 1000.0)


def test_residual_filtering_sets_noisy_points_to_nan() -> None:
    reader = _tour_average_reader()
    dataframe = reader.points_dataframe(residual_nan_threshold=0.5)

    assert dataframe[["x", "y", "z"]].isna().all().all()


def test_analog_dataframe_handles_missing_channels_gracefully() -> None:
    reader = _tour_average_reader()
    analog_df = reader.analog_dataframe()

    assert analog_df.empty
    assert list(analog_df.columns) == ["sample", "time", "channel", "value"]


def test_points_export_supports_multiple_formats(tmp_path: Path) -> None:
    reader = _tour_average_reader()
    export_dir = tmp_path / "exports"

    csv_path = reader.export_points(export_dir / "points.csv", markers=["WaistLeft"])
    json_path = reader.export_points(export_dir / "points.json", include_time=False)
    npz_path = reader.export_points(
        export_dir / "points_archive.npz", residual_nan_threshold=0.5
    )

    assert csv_path.exists()
    csv_frame = csv_path.stat().st_size
    assert csv_frame > 0

    assert json_path.exists()
    assert json_path.stat().st_size > 0

    assert npz_path.exists()
    with np.load(npz_path) as archive:
        assert set(archive.files) >= {"frame", "marker", "x", "y", "z", "residual"}


def test_analog_export_writes_empty_structure(tmp_path: Path) -> None:
    reader = _tour_average_reader()
    path = reader.export_analog(tmp_path / "analog.csv")

    assert path.exists()
    contents = path.read_text(encoding="utf-8").strip().splitlines()
    assert contents[0].split(",") == ["sample", "time", "channel", "value"]
