from lib.with_app_decorator import with_app
from lib.directory_definitions import get_reports_directory
from lib.descriptive_error import DescriptiveError

from models.report import Report

from control_variables import REPORTS_CHUNK_SIZE

from flask import request
from itertools import dropwhile

import os

@with_app("/recent_reports", methods=["POST"])
def recent_reports():
    # This is the root_directory of the last report
    # that the frontend loaded
    reference_report: str | None = None
    try:
        reference_report = request.json['reference_report']
    except:
        pass

    reports_directories = [ 
        full_directory_name for directory_name in os.listdir(get_reports_directory()) 
        if os.path.isdir((full_directory_name := os.path.join(get_reports_directory(), directory_name))) 
    ]

    reports: list[Report] = []
    for directory in reports_directories:
        try:
            # @todo This might be insanely time-consuming in the future. Since I only use the
            # preview field of the first slide I don't think it is necessary for me to parse 
            # the whole report JSON file
            report = Report.from_root_directory(root_directory=directory)
            reports.append(report)
        except Exception as e:
            print(f"Couldn't generate report")
            print(e)
    reports.sort(key=lambda report: report.last_edit, reverse=True)

    if reference_report is not None:
        reports = list(dropwhile(lambda report: report.root_directory != reference_report, reports))
        if len(reports) == 0:
            raise DescriptiveError(message=f"El reporte usado de referencia no existe: {reference_report}", http_error_code=400)
        reports = reports[1:]
    
    has_more = len(reports) > REPORTS_CHUNK_SIZE
    reports = reports[:REPORTS_CHUNK_SIZE]
    last_report = reports[-1] if len(reports) > 0 else None

    return {
        "reports": [
            {
                "preview": report.slides[0].preview_image,
                "name": report.report_name,
                "root_directory": report.root_directory,
            }
            for report in reports
        ],
        "has_more": has_more,
        "last_report": last_report.root_directory if last_report is not None else None
    }, 200
