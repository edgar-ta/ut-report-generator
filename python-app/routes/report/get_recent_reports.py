from lib.with_flask import with_flask
from lib.directory_definitions import get_reports_directory

from lib.report.get_id_of_report import get_id_of_report

from models.report import Report

from control_variables import REPORTS_CHUNK_SIZE

from flask import request
from itertools import dropwhile

import os

@with_flask("/get_recent", methods=["POST"])
def get_recent_reports():
    # This is the id of the last report
    # that the frontend loaded
    reference_report: str | None = getattr(request.json, 'report', None)
    reports_directories = sorted((
        full_directory_name 
        for directory_name in os.listdir(get_reports_directory()) 
        if os.path.isdir((full_directory_name := os.path.join(get_reports_directory(), directory_name))) 
    ), key=os.path.getatime)

    if reference_report is not None:
        reports_directories = list(dropwhile(
            lambda report: get_id_of_report(report) != reference_report, 
            reports_directories
            ))[1:]

    reports: list[Report] = []
    for directory in reports_directories:
        try:
            if len(reports) >= REPORTS_CHUNK_SIZE:
                break
            # @todo This might be insanely time-consuming in the future. Since I only use the
            # preview field of the first slide I don't think it is necessary for me to parse 
            # the whole report JSON file
            report = Report.from_root_directory(root_directory=directory)
            reports.append(report)
        except Exception as e:
            print(f"Couldn't generate report")
            print(e)
    
    has_more = len(reports) > REPORTS_CHUNK_SIZE
    last_report = reports[-1] if len(reports) > 0 else None

    return {
        "reports": [
            {
                "preview": next((slide.preview for slide in report.slides if slide.preview is not None), None),
                "name": report.report_name,
                "identifier": report.identifier,
            }
            for report in reports
        ],
        "has_more": has_more,
        "last_report": last_report.root_directory if last_report is not None else None
    }, 200
