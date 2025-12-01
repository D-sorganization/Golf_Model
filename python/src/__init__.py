"""Project package init."""

from typing import List

try:
    from .c3d_reader import C3DDataReader, C3DEvent, C3DMetadata, load_tour_average_reader
    _C3D_AVAILABLE = True
except ImportError:
    # ezc3d not available (e.g., Python 3.9)
    _C3D_AVAILABLE = False
    # Define stubs to prevent import errors
    C3DDataReader = None  # type: ignore[assignment, misc]
    C3DEvent = None  # type: ignore[assignment, misc]
    C3DMetadata = None  # type: ignore[assignment, misc]
    load_tour_average_reader = None  # type: ignore[assignment, misc]

__all__: List[str] = [
    "C3DDataReader",
    "C3DEvent",
    "C3DMetadata",
    "load_tour_average_reader",
]
