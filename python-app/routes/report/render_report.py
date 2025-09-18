from lib.with_flask import with_flask
from lib.get_or_panic import get_or_panic
from lib.random_message import random_message, RandomMessageType

from models.report.self import Report

from flask import request


@with_flask("/report", methods=["POST"])
def render_report():
    report = get_or_panic(request.json, "report", "El directorio del reporte debe estar presente")
    report = Report.from_identifier(identifier=report)

    report.new_render()
    report.save()

    return {
        "message": random_message(RandomMessageType.REPORT_GENERATED),
        "output_file": report.rendered_file
    }, 200
