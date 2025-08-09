"""Tests for logger utilities module."""

import pytest
import logging
from src.logger_utils import get_logger


def test_get_logger_returns_logger():
    """Test that get_logger returns a logging.Logger instance."""
    logger = get_logger(__name__)
    assert isinstance(logger, logging.Logger)


def test_get_logger_same_name_returns_same_instance():
    """Test that get_logger returns the same logger instance for the same name."""
    logger1 = get_logger("test_module")
    logger2 = get_logger("test_module")
    assert logger1 is logger2


def test_get_logger_different_names_return_different_instances():
    """Test that get_logger returns different logger instances for different names."""
    logger1 = get_logger("test_module_1")
    logger2 = get_logger("test_module_2")
    assert logger1 is not logger2


def test_logger_has_handler():
    """Test that the logger has at least one handler."""
    logger = get_logger("test_handler")
    assert len(logger.handlers) > 0


def test_logger_level_setting():
    """Test that logger level can be set and retrieved."""
    logger = get_logger("test_level")
    original_level = logger.level
    
    # Set to DEBUG level
    logger.setLevel(logging.DEBUG)
    assert logger.level == logging.DEBUG
    
    # Restore original level
    logger.setLevel(original_level)
