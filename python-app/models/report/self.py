from lib.get_metadata import get_metadata
from lib.descriptive_error import DescriptiveError
from lib.directory_definitions import metadata_file_of_report, slides_directory_of_report, root_directory_of_report, compiled_file_of_report, exported_file_of_report, temporary_export_directory_of_report, data_directory_of_report, get_reports_directory
from lib.image_slide.image_slide_from_json import image_slide_from_json
from lib.pivot_table.pivot_table_from_json import pivot_table_from_json

from models.image_slide.self import ImageSlide
from models.pivot_table.self import PivotTable
from models.slide.slide_category import SlideCategory
from models.report.visualization_mode import VisualizationMode

from control_variables import CURRENT_DIRECTORY_PATH, CURRENT_PROJECT_VERSION

from functools import cached_property

import pandas
import os
import uuid
import json

Slide = ImageSlide | PivotTable

class Report:
    def __init__(
            self, 
            identifier: str,
            root_directory: str, 
            report_name: str, 
            creation_date: pandas.Timestamp, 
            last_edit: pandas.Timestamp,
            slides: list[ImageSlide | PivotTable],
            visualization_mode: VisualizationMode,
            version: str
            ) -> None:
        self.identifier = identifier
        self.report_name = report_name
        self.creation_date = creation_date
        self.last_edit = last_edit
        self.slides = slides
        self.visualization_mode = visualization_mode
        self.version = version

        self.root_directory = root_directory

    def to_dict(self) -> dict:
        """
        Serializes the Report instance to a dictionary for JSON export.
        Dates are converted to ISO 8601 strings.
        """
        return {
            "identifier": self.identifier,
            "report_name": self.report_name,
            "creation_date": self.creation_date.isoformat(),
            "last_edit": self.last_edit.isoformat(),
            "slides": [slide.to_dict() for slide in self.slides],
            "visualization_mode": self.visualization_mode.value,
            "version": self.version
        }
    
    @classmethod
    def from_root_directory(cls, root_directory: str) -> "Report":
        metadata = get_metadata(root_directory=root_directory)
        
        version = metadata['version']
        if version != CURRENT_PROJECT_VERSION:
            raise DescriptiveError(message=f"El reporte no se puede abrir porque es de una versión desactualizada. La versión actual es {CURRENT_PROJECT_VERSION} y el reporte tiene {version}", http_error_code=400)

        return cls(
            identifier=metadata['identifier'],
            root_directory=root_directory,
            report_name=metadata["report_name"],
            creation_date=pandas.Timestamp(metadata["creation_date"]),
            last_edit=pandas.Timestamp(metadata["last_edit"]),
            slides=[
                    image_slide_from_json(json=slide) 
                    if SlideCategory(slide["category"]) == SlideCategory.IMAGE_SLIDE
                    else pivot_table_from_json(json=slide)
                for slide in metadata.get("slides", [])
            ],
            visualization_mode=VisualizationMode(metadata['visualization_mode']),
            version=version
        )

    @classmethod
    def from_identifier(cls, identifier: str) -> "Report":
        for filename in os.listdir(get_reports_directory()):
            directory_path = os.path.join(get_reports_directory(), filename)
            if os.path.isdir(directory_path) and filename.endswith(identifier):
                return Report.from_root_directory(root_directory=directory_path)
            
        raise DescriptiveError(http_error_code=400, message=f'La id especificada ({identifier}) no corresponde a ningún reporte')

    def add_slide(self, slide: Slide) -> None:
        self.slides.append(slide)
    
    def save(self):
        last_edits = [ slide.last_edit for slide in self.slides ]
        last_edits.append(self.last_edit)
        self.last_edit = max(last_edits)
        metadata_file = metadata_file_of_report(root_directory=self.root_directory)

        with open(metadata_file, "w") as json_file:
            json.dump(self.to_dict(), json_file, indent=4)

    def __getitem__(self, key: str) -> Slide:
        slide = next((slide for slide in self.slides if slide.identifier == key), None)
        if slide is None:
            raise DescriptiveError(400, f"La diapositiva con id {key} no existe. Tal vez sea un error de dedo")
        return slide

    @classmethod
    def get_reports_directory(cls) -> str:
        return os.path.join(CURRENT_DIRECTORY_PATH, "reports")
