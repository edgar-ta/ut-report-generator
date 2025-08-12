from models.slide import Slide
from lib.descriptive_error import DescriptiveError
from lib.directory_definitions import metadata_file_of, images_directory_of_report, base_directory_of
from control_variables import CURRENT_DIRECTORY_PATH

from pandas import Timestamp
from functools import cached_property, cache

import os
import uuid
import json

class Report:
    def __init__(self, base_directory: str, report_name: str, creation_date: Timestamp, last_edit: Timestamp,
                 rendered_file: str | None, slides: list[Slide]) -> None:
        self.base_directory = base_directory
        self.report_name = report_name
        self.creation_date = creation_date
        self.last_edit = last_edit
        self.rendered_file = rendered_file
        self.slides = slides

    def to_dict(self) -> dict:
        """
        Serializes the Report instance to a dictionary for JSON export.
        Dates are converted to ISO 8601 strings.
        """
        return {
            "report_name": self.report_name,
            "creation_date": self.creation_date.isoformat(),
            "last_edit": self.last_edit.isoformat(),
            "rendered_file": self.rendered_file,
            "slides": [slide.to_dict() for slide in self.slides],
        }
    
    @classmethod
    def get_reports_directory(cls) -> str:
        return os.path.join(CURRENT_DIRECTORY_PATH, "reports")

    @cached_property
    def images_directory(self) -> str:
        return images_directory_of_report(self.base_directory)
    
    @cached_property
    def metadata_file(self) -> str:
        return metadata_file_of(self.base_directory)

    @classmethod
    def cold_create(cls) -> "Report":
        report_id = str(uuid.uuid4())

        report = Report(
            base_directory=base_directory_of(report_id),
            report_name="Mi reporte",
            creation_date=Timestamp.now(),
            last_edit=Timestamp.now(),
            rendered_file=None,
            slides=[]
        )
        return report
    
    def makedirs(self) -> None:
        os.makedirs(self.base_directory, exist_ok=True)
        os.makedirs(self.images_directory, exist_ok=True)
        for slide in self.slides:
            slide.makedirs()
    
    @classmethod
    def from_base_directory(cls, base_directory: str) -> "Report":
        cls.get_reports_directory()
        with open(metadata_file_of(base_directory=base_directory), "r") as metadata_file:
            metadata = json.loads(metadata_file.read())

        return cls(
            base_directory=base_directory,
            report_name=metadata["report_name"],
            creation_date=Timestamp(metadata["creation_date"]),
            last_edit=Timestamp(metadata["last_edit"]),
            rendered_file=metadata.get("rendered_file"),
            slides=[Slide.from_json(json_data=slide, base_directory=base_directory) for slide in metadata.get("slides", [])]
        )


    def __getitem__(self, key: str) -> Slide:
        slide = next((slide for slide in self.slides if slide.id == key), None)
        if slide is None:
            raise DescriptiveError(400, f"La diapositiva con id {key} no existe. Tal vez sea un error de dedo")
        return slide

    def add_slide(self, slide: Slide) -> None:
        self.slides.append(slide)
    
    def save(self):
        with open(self.metadata_file, "w") as json_file:
            json.dump(self.to_dict(), json_file, indent=4)
    
    def save_edit(self):
        self.last_edit = Timestamp.now()
        self.save()
