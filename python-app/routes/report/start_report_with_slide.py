from lib.with_app_decorator import with_app
from lib.descriptive_error import DescriptiveError
from lib.format_for_frontend import format_for_frontend
from lib.add_image_slide_to_report import add_image_slide_to_report

from models.report import Report

from flask import request

@with_app("/start_with_slide", methods=["POST"])
def start_report_with_slide():
    report = Report.from_nothing()
    report.makedirs()

    add_image_slide_to_report(report=report, local_request=request)

    # slide = Slide.from_data_files(
    #     base_directory=report.root_directory, 
    #     files=data_files
    # )
    # slide.makedirs()

    # slide.build_new_assets()
    # slide.build_new_preview()

    # report.add_slide(slide)

    report.save()
    response = format_for_frontend(response=report)

    return response, 200
