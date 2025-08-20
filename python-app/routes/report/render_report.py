from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.random_message import random_message, RandomMessageType

from models.report import Report

from flask import request


@with_app("/report", methods=["POST"])
def render_report():
    root_directory = get_or_panic(request.json, "report_directory", "El directorio del reporte debe estar presente")

    report = Report.from_root_directory(root_directory=root_directory)
    report.new_render()
    report.save()

    return {
        "message": random_message(RandomMessageType.REPORT_GENERATED),
        "output_file": report.rendered_file
    }, 200
