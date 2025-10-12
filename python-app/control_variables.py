import zipfile
import os

CURRENT_FILE_PATH = os.path.abspath(__file__)
CURRENT_DIRECTORY_PATH = os.path.dirname(CURRENT_FILE_PATH)

CURRENT_PROJECT_VERSION = "0.10.0"

EXPORTED_REPORTS_EXTENSION = "reporte-ut"
REPORTS_CHUNK_SIZE = 10
ZIP_COMPRESSION_LEVEL = zipfile.ZIP_DEFLATED
INVALID_FILTER_CREATES_VOID = False

def get_asset_fullpath(relative_path: str, error_message = 'La ruta del archivo es inválido') -> str:
    path = os.path.join(CURRENT_DIRECTORY_PATH, 'assets', relative_path)
    if not os.path.exists(path) and os.path.isfile(path):
        raise Exception(error_message)
    return path

def PATH_OF_PPTX_TEMPLATE() -> str:
    return get_asset_fullpath("presentation-template.pptx", error_message="La plantilla de PowerPoint no está presente")

def EMPTY_REPORT_PREVIEW() -> str:
    return get_asset_fullpath("empty-report.png", error_message="La vista previa de los reportes vacíos no está presente")

def EMPTY_VISUALIZATION_PREVIEW() -> str:
    return get_asset_fullpath("empty-visualization.jpg", error_message="La vista previa de las visualizaciones vacías no está presente")
