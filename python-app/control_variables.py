from lib.slide_controller import SlideController
from lib.sections.failure_rate.controller import FailureRate_Controller

import zipfile
import os

AVAILABLE_SLIDE_CONTROLLERS: list[type[SlideController]] = [
    FailureRate_Controller
]

CURRENT_FILE_PATH = os.path.abspath(__file__)
CURRENT_DIRECTORY_PATH = os.path.dirname(CURRENT_FILE_PATH)

CURRENT_PROJECT_VERSION = "0.3.0"

EXPORTED_REPORTS_EXTENSION = "reporte-ut"
REPORTS_CHUNK_SIZE = 10
ZIP_COMPRESSION_LEVEL = zipfile.ZIP_DEFLATED
