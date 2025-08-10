import logging
import random

import numpy as np

logger = logging.getLogger(__name__)


def set_seeds(seed: int) -> None:
    """Set random seeds for reproducibility across numpy and random modules.
    
    Args:
        seed: Integer seed value for deterministic random number generation
        
    Returns:
        None
        
    Note:
        Sets seeds for both numpy.random and Python's random module to ensure
        complete reproducibility in scientific computations.
    """
    random.seed(seed)
    np.random.seed(seed)
    logger.info("Seeds set: %d", seed)
