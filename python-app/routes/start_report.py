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

    print("Hello -1")
    slide = Slide.from_data_files(
        base_directory=report.root_directory, 
        files=data_files
    )
    slide.makedirs()

    print("Hello 0")
    slide.build_new_assets()
    slide.build_new_preview()

    print("Hello 1")
    report.add_slide(slide)
    report.save()

    return report.to_dict(), 200
