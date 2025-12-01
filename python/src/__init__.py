"""Project package init."""

from typing import Any, List

try:
    from .c3d_reader import C3DDataReader, C3DEvent, C3DMetadata, load_tour_average_reader
    _C3D_AVAILABLE = True
except ImportError:
    # ezc3d not available (e.g., Python 3.9)
    _C3D_AVAILABLE = False
    # Define stubs to prevent import errors
    # These will raise RuntimeError when used if ezc3d is not available
    C3DDataReader: Any = None
    C3DEvent: Any = None
    C3DMetadata: Any = None
    load_tour_average_reader: Any = None

__all__: List[str] = [
    "C3DDataReader",
    "C3DEvent",
    "C3DMetadata",
    "load_tour_average_reader",
]
