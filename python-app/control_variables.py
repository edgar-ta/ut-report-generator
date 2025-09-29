import zipfile
import os

CURRENT_FILE_PATH = os.path.abspath(__file__)
CURRENT_DIRECTORY_PATH = os.path.dirname(CURRENT_FILE_PATH)

CURRENT_PROJECT_VERSION = "0.10.0"

EXPORTED_REPORTS_EXTENSION = "reporte-ut"
REPORTS_CHUNK_SIZE = 10
ZIP_COMPRESSION_LEVEL = zipfile.ZIP_DEFLATED
INVALID_FILTER_CREATES_VOID = False

def PATH_OF_PPTX_TEMPLATE() -> str:
    variable = os.getenv('PPTX_TEMPLATE') or os.path.join(CURRENT_DIRECTORY_PATH, "presentation-template.pptx")
    if not os.path.exists(variable) and os.path.isfile(variable):
        raise Exception('La ruta de la plantilla de PowerPoint es inválida')
    return variable
