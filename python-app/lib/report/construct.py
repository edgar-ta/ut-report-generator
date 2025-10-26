from models.report.self import Report
from models.report.visualization_mode import VisualizationMode
from models.slide.slide_category import SlideCategory
from models.error.descriptive_error import DescriptiveError

from lib.directory_definitions import get_reports_directory, metadata_file_of_report
from lib.image_slide.image_slide_from_json import image_slide_from_json
from lib.pivot_table.pivot_table_from_json import pivot_table_from_json

from constants.control_variables import CURRENT_PROJECT_VERSION

import json
import pandas
import os
import re

def find_root_directory(identifier: str) -> str:
    for filename in os.listdir(get_reports_directory()):
        directory_path = os.path.join(get_reports_directory(), filename)
        if os.path.exists(directory_path) and os.path.isdir(directory_path) and filename.endswith(identifier):
            return directory_path
        
    raise DescriptiveError(http_error_code=400, message=f'La id especificada ({identifier}) no corresponde a ningún reporte')

def from_root_directory(root_directory: str) -> Report:
    with open(metadata_file_of_report(root_directory=root_directory), "r") as metadata_file:
        metadata = json.loads(metadata_file.read())
    
    version = metadata['version']
    if version != CURRENT_PROJECT_VERSION:
        raise DescriptiveError(message=f"El reporte no se puede abrir porque es de una versión desactualizada. La versión actual es {CURRENT_PROJECT_VERSION} y el reporte tiene {version}", http_error_code=400)

    return from_json(metadata)

def from_identifier(identifier: str) -> tuple[str, Report]:
    if re.match(pattern=r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$', string=identifier) is None:
        raise DescriptiveError(http_error_code=400, message="El identificador provisto no es una UUID válida")

    root_directory = find_root_directory(identifier=identifier)
    return root_directory, from_root_directory(root_directory=root_directory)

def from_json(json) -> Report:
    return Report(
        identifier=json['identifier'],
        report_name=json["report_name"],
        creation_date=pandas.Timestamp(json["creation_date"]),
        last_edit=pandas.Timestamp(json["last_edit"]),
        slides=[
                image_slide_from_json(json=slide) 
                if SlideCategory(slide["category"]) == SlideCategory.IMAGE_SLIDE
                else pivot_table_from_json(json=slide)
            for slide in json.get("slides", [])
        ],
        visualization_mode=VisualizationMode(json['visualization_mode']),
        version=json['version']
    )
