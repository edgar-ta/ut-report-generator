from lib.image_slide.image_slide_controller import ImageSlideController

import zipfile
import os

AVAILABLE_SLIDE_CONTROLLERS: list[type[ImageSlideController]] = [
]

CURRENT_FILE_PATH = os.path.abspath(__file__)
CURRENT_DIRECTORY_PATH = os.path.dirname(CURRENT_FILE_PATH)

CURRENT_PROJECT_VERSION = "0.3.0"

EXPORTED_REPORTS_EXTENSION = "reporte-ut"
REPORTS_CHUNK_SIZE = 10
ZIP_COMPRESSION_LEVEL = zipfile.ZIP_DEFLATED

VALID_CAREER_INITIALS = ["EV", "DS", "IA"]
VALID_CAREER_INSCRIPTION_MONTHS = [ "E", "M", "S" ]
VALID_CAREER_SHIFTS = [ "S", "M" ]
