from models.error.descriptive_error import DescriptiveError

from models.image_slide.self import ImageSlide
from models.pivot_table.self import PivotTable
from models.report.visualization_mode import VisualizationMode

import pandas

Slide = ImageSlide | PivotTable

class Report:
    def __init__(
            self, 
            identifier: str,
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

    def __getitem__(self, key: str) -> Slide:
        slide = next((slide for slide in self.slides if slide.identifier == key), None)
        if slide is None:
            raise DescriptiveError(400, f"La diapositiva con id {key} no existe. Tal vez sea un error de dedo")
        return slide

    def __repr__(self) -> str:
        return (
            f"Report("
            f"  identifier={self.identifier!r}, "
            f"  report_name={self.report_name!r}, "
            f"  creation_date={self.creation_date!r}, "
            f"  last_edit={self.last_edit!r}, "
            f"  slides={len(self.slides)} slides, "
            f"  visualization_mode={self.visualization_mode!r}, "
            f"  version={self.version!r}"
            f")"
        )
