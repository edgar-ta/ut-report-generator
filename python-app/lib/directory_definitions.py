from control_variables import CURRENT_DIRECTORY_PATH

from lib.kebab_case import kebab_case

from functools import cache
from uuid import uuid4

import os

@cache
def get_reports_directory() -> str:
    return os.path.join(CURRENT_DIRECTORY_PATH, "reports")

def root_directory_of_report(report_id: str, report_name: str | None = None) -> str:
    directory_name = report_id
    if report_name is not None:
        directory_name = f'{kebab_case(report_name)}-{directory_name}'
    return os.path.join(get_reports_directory(), directory_name)

@cache
def metadata_file_of_report(root_directory: str) -> str:
    return os.path.join(root_directory, "metadata.json")

@cache
def rendered_file_of_report(root_directory: str, report_name: str) -> str:
    return os.path.join(root_directory, f"{report_name}.pptx")

@cache
def temporary_rendered_file_of_report(root_directory: str) -> str:
    file_name = str(uuid4())
    return os.path.join(root_directory, f"temporary-{file_name}.pptx")

@cache
def export_file_of_report(root_directory: str, report_name: str) -> str:
    return os.path.join(root_directory, f"{report_name}.zip")

@cache
def export_directory_of_report(root_directory: str) -> str:
    return os.path.join(root_directory, "export")

@cache
def slides_directory_of_report(root_directory: str) -> str:
    return os.path.join(root_directory, "slides")

@cache
def data_directory_of_report(root_directory: str) -> str:
    return os.path.join(root_directory, "data")

@cache
def base_directory_of_slide(root_directory: str, slide_id: str) -> str:
    return os.path.join(root_directory, "slides", slide_id)

@cache
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

