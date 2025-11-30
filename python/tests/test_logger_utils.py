"""Tests for logger utilities module."""

import logging
import random

import numpy as np

# Import handled by conftest.py
from logger_utils import get_logger, set_seeds


def test_get_logger_returns_logger() -> None:
    """Test that get_logger returns a logging.Logger instance."""
    logger = get_logger(__name__)
    assert isinstance(logger, logging.Logger)


def test_get_logger_same_name_returns_same_instance() -> None:
    """Test that get_logger returns the same logger instance for the same name."""
    logger1 = get_logger("test_module")
    logger2 = get_logger("test_module")
    assert logger1 is logger2


def test_get_logger_different_names_return_different_instances() -> None:
    """Test that get_logger returns different logger instances for different names."""
    logger1 = get_logger("test_module_1")
    logger2 = get_logger("test_module_2")
    assert logger1 is not logger2


def test_logger_has_handler() -> None:
    """Test that the logger has at least one handler."""
    logger = get_logger("test_handler")
    assert len(logger.handlers) > 0


def test_logger_level_setting() -> None:
    """Test that logger level can be set and retrieved."""
    logger = get_logger("test_level")
    original_level = logger.level

    # Set to DEBUG level
    logger.setLevel(logging.DEBUG)
    assert logger.level == logging.DEBUG

    # Restore original level
    logger.setLevel(original_level)


def test_set_seeds_synchronizes_numpy_and_random() -> None:
    """Setting seeds should produce reproducible sequences across libraries."""

    set_seeds(1234)
    first_sequence = (random.random(), np.random.rand(), np.random.randint(0, 10))

    set_seeds(1234)
    second_sequence = (random.random(), np.random.rand(), np.random.randint(0, 10))

    assert first_sequence == second_sequence
