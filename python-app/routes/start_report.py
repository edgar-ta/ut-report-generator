from lib.with_app_decorator import with_app

from models.report import Report
from models.slide import Slide

from control_variables import CURRENT_DIRECTORY_PATH

from flask import request

import os

def create_reports_directory() -> str:
    reports_directory = os.path.join(CURRENT_DIRECTORY_PATH, "reports")

    if not os.path.isdir(reports_directory):
        os.mkdir(reports_directory)
    return reports_directory

@with_app("/start_report", methods=["POST"])
def start_report():
    data_files = request.json["data_files"]

    report = Report.cold_create()
    report.makedirs()

    slide = Slide.from_data_files(
        base_directory=report.base_directory, 
        files=data_files
    )
    slide.makedirs()
    slide.build_assets()
    slide.build_preview()

    report.add_slide(slide)
    report.save()

    return report.to_dict(), 200
