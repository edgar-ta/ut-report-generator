from lib.format_for_create import format_for_create
from lib.with_app_decorator import with_app

from lib.pivot_table.add_pivot_table_to_report import add_pivot_table_to_report

from models.report import Report

from flask import request

@with_app("/start_with_pivot_table", methods=["POST"])
def start_report_with_pivot_table():
    report = Report.from_nothing()
    report.makedirs()

    add_pivot_table_to_report(report=report, local_request=request, index=None)

    report.save()
    return format_for_create(response=report), 200
