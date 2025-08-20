from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic

from models.report.self import Report
from models.pivot_table.add_pivot_table_to_report import add_pivot_table_to_report

from flask import request

@with_app("/create", methods=["POST"])
def create_pivot_table():
    report = get_or_panic(request.json, "report", "La id del reporte no fue incluida en la petición")
    report = Report.from_identifier(identifier=report)
    pivot_table = add_pivot_table_to_report(report=report, local_request=request, index=request.json.get('index'))

    return pivot_table.to_dict(), 200
