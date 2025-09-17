from lib.image_slide.image_slide_controller import ImageSlideController

import zipfile
import os

AVAILABLE_SLIDE_CONTROLLERS: list[type[ImageSlideController]] = [
]

CURRENT_FILE_PATH = os.path.abspath(__file__)
CURRENT_DIRECTORY_PATH = os.path.dirname(CURRENT_FILE_PATH)

CURRENT_PROJECT_VERSION = "0.8.0"

EXPORTED_REPORTS_EXTENSION = "reporte-ut"
REPORTS_CHUNK_SIZE = 10
ZIP_COMPRESSION_LEVEL = zipfile.ZIP_DEFLATED
INVALID_FILTER_CREATES_VOID = False

def PATH_OF_PPTX_TEMPLATE() -> str:
    variable = os.getenv('PPTX_TEMPLATE')
    if variable is None:
        raise Exception('La ruta de la plantilla de PowerPoint no se encuentra')
    return variable
