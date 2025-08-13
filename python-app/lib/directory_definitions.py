from control_variables import CURRENT_DIRECTORY_PATH

from functools import cache

import os

@cache
def get_reports_directory() -> str:
    return os.path.join(CURRENT_DIRECTORY_PATH, "reports")

@cache
def root_directory_of_report(report_id: str) -> str:
    return os.path.join(get_reports_directory(), report_id)

@cache
def metadata_file_of_report(root_directory: str) -> str:
    return os.path.join(root_directory, "metadata.json")

@cache
def rendered_file_of_report(root_directory: str, report_name: str) -> str:
    return os.path.join(root_directory, f"{report_name}.pptx")

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
    return os.path.join(root_directory, "slides", slide_id, "assets")

@cache
def preview_image_of_slide(root_directory: str, slide_id: str) -> str:
    return os.path.join(root_directory, "slides", slide_id, "preview.png")
