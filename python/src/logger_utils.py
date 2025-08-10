import logging
import random

import numpy as np

logger = logging.getLogger(__name__)


def get_logger(name: str) -> logging.Logger:
    """Get a logger instance with the specified name.
    
    Args:
        name: The name for the logger (usually __name__)
        
    Returns:
        A configured logger instance
    """
    logger_instance = logging.getLogger(name)
    
    # Only add handler if it doesn't already have one
    if not logger_instance.handlers:
        handler = logging.StreamHandler()
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        handler.setFormatter(formatter)
        logger_instance.addHandler(handler)
        logger_instance.setLevel(logging.INFO)
    
    return logger_instance


def set_seeds(seed: int) -> None:
    random.seed(seed)
    np.random.seed(seed)
    logger.info("Seeds set: %d", seed)
