from lib.with_app_decorator import with_app
from lib.descriptive_error import DescriptiveError
from lib.format_for_create import format_for_create
from lib.image_slide.add_image_slide_to_report import add_image_slide_to_report

from models.report import Report

from flask import request

@with_app("/start_with_slide", methods=["POST"])
def start_report_with_slide():
    report = Report.from_nothing()
    report.makedirs()

    add_image_slide_to_report(report=report, local_request=request)

    report.save()
    return format_for_create(response=report), 200
