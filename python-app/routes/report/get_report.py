from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.format_for_create import format_for_create

from models.report import Report

from flask import request

@with_app("/get", methods=["POST"])
def get_report():
    report = get_or_panic(request.json, 'report', 'El directorio del reporte debe estar presente')
    report = Report.from_identifier(identifier=report)

    return format_for_create(response=report), 200
