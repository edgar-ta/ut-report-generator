from lib.with_flask import with_flask
from lib.report.create_report import create_report

from lib.pivot_table.build_pivot_table import build_pivot_table

from models.report.visualization_mode import VisualizationMode

from flask import request

@with_flask("/start_with_pivot_table", methods=["POST"])
def start_report_with_pivot_table():
    report, root_directory = create_report(visualization_mode=VisualizationMode.CHARTS_ONLY)

    pivot_table = build_pivot_table(root_directory=report.root_directory, local_request=request)

    report.slides.append(pivot_table)
    report.save()

    return report.to_dict(), 200
