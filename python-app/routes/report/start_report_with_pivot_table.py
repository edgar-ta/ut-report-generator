from lib.format_for_create import format_for_create
from lib.with_flask import with_flask

from lib.pivot_table.add_pivot_table_to_report import add_pivot_table_to_report
from lib.slide.render_preview import render_preview

from models.report.self import Report
from models.report.visualization_mode import VisualizationMode

from flask import request

@with_flask("/start_with_pivot_table", methods=["POST"])
def start_report_with_pivot_table():
    report = Report.from_nothing(visualization_mode=VisualizationMode.CHARTS_ONLY)
    report.makedirs()

    add_pivot_table_to_report(report=report, local_request=request, index=None)

    render_preview(root_directory=report.root_directory, slides=report.slides)
    report.save()
    return report.to_dict(), 200
