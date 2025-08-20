from models.frontend.slide_record import SlideRecord
from models.report.self import Report

from dataclasses import dataclass
from pandas import Timestamp

@dataclass(frozen=True)
class ReportRecord:
    root_directory: str
    report_name: str
    creation_date: Timestamp
    slides: list[SlideRecord]
    rendered_file: str

    @classmethod
    def from_report(cls, report: Report) -> "ReportRecord":
        return cls(
            root_directory=report.root_directory,
            report_name=report.report_name,
            creation_date=report.creation_date,
            slides=[SlideRecord.from_slide(slide) for slide in report.slides],
            rendered_file=report.rendered_file
        )

    def to_dict(self) -> dict[str, any]:
        return {
            "report_directory": self.root_directory,
            "report_name": self.report_name,
            "creation_date": self.creation_date.isoformat(),
            "slides": [slide.to_dict() for slide in self.slides],
            "rendered_file": self.rendered_file
        }
