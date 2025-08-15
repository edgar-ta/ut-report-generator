from models.slide import Slide
from lib.descriptive_error import DescriptiveError
from lib.directory_definitions import metadata_file_of_report, slides_directory_of_report, root_directory_of_report, rendered_file_of_report, export_file_of_report, export_directory_of_report, data_directory_of_report
from control_variables import CURRENT_DIRECTORY_PATH, CURRENT_PROJECT_VERSION

from pandas import Timestamp
from pptx import Presentation
from functools import cached_property, cache

import os
import uuid
import json

class Report:
    def __init__(
            self, 
            root_directory: str, 
            report_name: str, 
            creation_date: Timestamp, 
            last_edit: Timestamp,
            last_render: Timestamp | None,
            slides: list[Slide],
            version: str
            ) -> None:
        self.root_directory = root_directory
        self.report_name = report_name
        self.creation_date = creation_date
        self.last_edit = last_edit
        self.last_render = last_render
        self.slides = slides
        self.version = version

    def to_dict(self) -> dict:
        """
        Serializes the Report instance to a dictionary for JSON export.
        Dates are converted to ISO 8601 strings.
        """
        return {
            "report_name": self.report_name,
            "creation_date": self.creation_date.isoformat(),
            "last_edit": self.last_edit.isoformat(),
            "last_render": None if self.last_render is None else self.last_render.isoformat(),
            "slides": [slide.to_dict() for slide in self.slides],
            "version": self.version
        }
    
    @classmethod
    def get_reports_directory(cls) -> str:
        return os.path.join(CURRENT_DIRECTORY_PATH, "reports")

    @cached_property
    def slides_directory(self) -> str:
        return slides_directory_of_report(self.root_directory)
    
    @cached_property
    def metadata_file(self) -> str:
        return metadata_file_of_report(self.root_directory)
    
    @property
    def rendered_file(self) -> str:
        return rendered_file_of_report(root_directory=self.root_directory, report_name=self.report_name)
    
    @property
    def export_file(self) -> str:
        return export_file_of_report(root_directory=self.root_directory, report_name=self.report_name)
    
    @cached_property
    def export_directory(self) -> str:
        return export_directory_of_report(root_directory=self.root_directory)
    
    @cached_property
    def data_directory(self) -> str:
        return data_directory_of_report(root_directory=self.root_directory)
    
    @classmethod
    def cold_create(cls) -> "Report":
        report_id = str(uuid.uuid4())

        report = Report(
            root_directory=root_directory_of_report(report_id),
            report_name="Mi reporte",
            creation_date=Timestamp.now(),
            last_edit=Timestamp.now(),
            last_render=None,
            slides=[],
            version=CURRENT_PROJECT_VERSION
        )
        return report
    
    def makedirs(self, exist_ok: bool = True) -> None:
        '''
        Creates the directories that the reports needs in order
        to work (i. e., the root, the slides and data directory)
        '''
        os.makedirs(self.root_directory, exist_ok=exist_ok)
        os.makedirs(self.slides_directory, exist_ok=exist_ok)
        os.makedirs(self.data_directory, exist_ok=exist_ok)

        for slide in self.slides:
            slide.makedirs(exist_ok=exist_ok)
    
    @classmethod
    def from_root_directory(cls, root_directory: str) -> "Report":
        with open(metadata_file_of_report(root_directory=root_directory), "r") as metadata_file:
            metadata = json.loads(metadata_file.read())

        return cls(
            root_directory=root_directory,
            report_name=metadata["report_name"],
            creation_date=Timestamp(metadata["creation_date"]),
            last_edit=Timestamp(metadata["last_edit"]),
            last_render=None if (last_render := metadata.get("last_render")) is None else Timestamp(last_render),
            slides=[Slide.from_json(json_data=slide, root_directory=root_directory) for slide in metadata.get("slides", [])],
            version=metadata["version"]
        )


    def __getitem__(self, key: str) -> Slide:
        slide = next((slide for slide in self.slides if slide.id == key), None)
        if slide is None:
            raise DescriptiveError(400, f"La diapositiva con id {key} no existe. Tal vez sea un error de dedo")
        return slide
    
    def new_render(self) -> None:
        is_render_updated = self.last_render is not None and self.last_render >= self.last_edit

        if is_render_updated and os.path.exists(self.rendered_file):
            return
        
        presentation = Presentation()
        for slide in self.slides:
            slide.build_new_assets()
            slide.controller.render_slide(
                presentation=presentation, 
                arguments=slide.arguments, 
                assets=slide.assets
            )
        
        if os.path.exists(self.rendered_file):
            os.remove(self.rendered_file)
        
        presentation.save(self.rendered_file)
        self.last_render = Timestamp.now()

    def add_slide(self, slide: Slide) -> None:
        self.slides.append(slide)
    
    def save(self):
        last_edits = [ slide.last_edit for slide in self.slides ]
        last_edits.append(self.last_edit)
        self.last_edit = max(last_edits)

        with open(self.metadata_file, "w") as json_file:
            json.dump(self.to_dict(), json_file, indent=4)
