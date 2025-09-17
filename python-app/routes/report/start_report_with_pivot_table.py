from lib.format_for_create import format_for_create
from lib.with_flask import with_flask

from lib.pivot_table.add_pivot_table_to_report import add_pivot_table_to_report
from lib.report.render_previews_of_report import render_previews_of_report

from models.report.self import Report
from models.report.visualization_mode import VisualizationMode

from flask import request

@with_flask("/start_with_pivot_table", methods=["POST"])
def start_report_with_pivot_table():
    report = Report.from_nothing(visualization_mode=VisualizationMode.CHARTS_ONLY)
    report.makedirs()

    add_pivot_table_to_report(report=report, local_request=request, index=None)

    render_previews_of_report(report=report)
    report.save()
    return format_for_create(response=report), 200
