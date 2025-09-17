from lib.with_flask import with_flask
from lib.get_or_panic import get_or_panic
from lib.format_for_create import format_for_create

from models.report import Report

from flask import request

@with_flask("/get", methods=["POST"])
def get_report():
    report = get_or_panic(request.json, 'report', 'El directorio del reporte debe estar presente')
    report = Report.from_identifier(identifier=report)

    return report.to_dict(), 200
