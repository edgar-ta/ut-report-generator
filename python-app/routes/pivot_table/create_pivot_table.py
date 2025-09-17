from lib.with_flask import with_flask
from lib.get_or_panic import get_or_panic
from lib.format_for_create import format_for_create

from lib.pivot_table.add_pivot_table_to_report import add_pivot_table_to_report

from models.report.self import Report

from flask import request

@with_flask("/create", methods=["POST"])
def create_pivot_table():
    report = get_or_panic(request.json, "report", "La id del reporte no fue incluida en la petición")
    report = Report.from_identifier(identifier=report)

    pivot_table = add_pivot_table_to_report(report=report, local_request=request, index=request.json.get('index'))
    report.save()

    return format_for_create(pivot_table), 200
