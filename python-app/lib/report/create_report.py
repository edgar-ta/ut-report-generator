from control_variables import CURRENT_PROJECT_VERSION

from models.report.self import Report
from models.report.visualization_mode import VisualizationMode

from lib.directory_definitions import root_directory_of_report, slides_directory_of_report, data_directory_of_report

import pandas
import os
import uuid

def create_report(visualization_mode: VisualizationMode, name: str =  "Mi reporte") -> tuple[Report, str]:
    report_id = str(uuid.uuid4())
    root_directory = root_directory_of_report(report_id=report_id)

    report = Report(
        identifier=report_id,
        root_directory=root_directory,
        report_name=name,
        creation_date=pandas.Timestamp.now(),
        last_edit=pandas.Timestamp.now(),
        slides=[],
        visualization_mode=visualization_mode,
        version=CURRENT_PROJECT_VERSION
    )

    os.makedirs(slides_directory_of_report(root_directory=root_directory), exist_ok=True)
    os.makedirs(data_directory_of_report(root_directory=root_directory), exist_ok=True)

    return report, root_directory
