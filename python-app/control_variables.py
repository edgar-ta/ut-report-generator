from lib.slide_controller import SlideController
from lib.sections.failure_rate.controller import FailureRate_Controller

import os

AVAILABLE_SLIDE_TYPES: list[type[SlideController]] = [
    FailureRate_Controller
]

CURRENT_FILE_PATH = os.path.abspath(__file__)
CURRENT_DIRECTORY_PATH = os.path.dirname(CURRENT_FILE_PATH)
