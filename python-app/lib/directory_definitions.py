from control_variables import CURRENT_DIRECTORY_PATH

from lib.kebab_case import kebab_case
from lib.remove_invalid_characters import remove_invalid_characters

from uuid import uuid4

import os

def get_reports_directory() -> str:
    return os.path.join(CURRENT_DIRECTORY_PATH, "reports")

def root_directory_of_report(report_id: str, report_name: str | None = None) -> str:
    directory_name = report_id
    if report_name is not None:
        directory_name = f'{kebab_case(report_name)}-{report_id}'
    return os.path.join(get_reports_directory(), directory_name)

def metadata_file_of_report(root_directory: str) -> str:
    return os.path.join(root_directory, "metadata.json")

def compiled_file_of_report(root_directory: str, report_name: str) -> str:
    return os.path.join(root_directory, f"{remove_invalid_characters(report_name)}.pptx")

def temporary_compiled_file_of_report(root_directory: str) -> str:
    file_name = str(uuid4())
    return os.path.join(root_directory, f"temporary-{file_name}.pptx")

def export_file_of_report(root_directory: str, report_name: str) -> str:
    return os.path.join(root_directory, f"{report_name}.zip")

def export_directory_of_report(root_directory: str) -> str:
    return os.path.join(root_directory, "export")

def slides_directory_of_report(root_directory: str) -> str:
    return os.path.join(root_directory, "slides")

def data_directory_of_report(root_directory: str) -> str:
    return os.path.join(root_directory, "data")

def base_directory_of_slide(root_directory: str, slide_id: str) -> str:
    return os.path.join(root_directory, "slides", slide_id)

def assets_directory_of_slide(root_directory: str, slide_id: str) -> str:
    return os.path.join(
        base_directory_of_slide(root_directory=root_directory, slide_id=slide_id), 
        "assets"
        )

def preview_image_of_slide(root_directory: str, slide_id: str) -> str:
    '''
    Generates a new name for the preview image of a slide.
    The file with said name is not guaranteed to actually exist
    '''
    return os.path.join(
        base_directory_of_slide(root_directory=root_directory, slide_id=slide_id), 
        f"preview-{str(uuid4())}.png"
        )

def bare_preview_of_pivot_table(root_directory:str, slide_id: str) -> str:
    return os.path.join(
        base_directory_of_slide(root_directory=root_directory, slide_id=slide_id), 
        f"bare-preview-{str(uuid4())}.png"
        )

def data_file_of_slide(root_directory: str, slide_id: str) -> str:
    return os.path.join(
        base_directory_of_slide(root_directory=root_directory, slide_id=slide_id), 
        "data.hdf5"
        )

