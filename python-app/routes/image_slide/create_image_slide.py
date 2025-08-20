from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.format_for_create import format_for_create

from lib.image_slide.add_image_slide_to_report import add_image_slide_to_report

from models.report import Report

from flask import request

@with_app("/create", methods=["POST"])
def create_image_slide():
    report = get_or_panic(request.json, 'report', 'El identificador del reporte no está presente en la solicitud')
    report = Report.from_identifier(identifier=report)

    image_slide = add_image_slide_to_report(report=report, local_request=request)
    report.save()

    return format_for_create(response=image_slide), 200
