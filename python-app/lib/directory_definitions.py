from control_variables import CURRENT_DIRECTORY_PATH

from functools import cache

import os

@cache
def get_reports_directory() -> str:
    return os.path.join(CURRENT_DIRECTORY_PATH, "reports")

@cache
def base_directory_of(report_id: str) -> str:
    return os.path.join(get_reports_directory(), report_id)

@cache
def metadata_file_of(base_directory: str) -> str:
    return os.path.join(base_directory, "metadata.json")

@cache
def images_directory_of_report(base_directory: str) -> str:
    return os.path.join(base_directory, "images")

@cache
def images_directory_of_slide(base_directory: str, slide_id: str) -> str:
    return os.path.join(base_directory, slide_id, "images")
