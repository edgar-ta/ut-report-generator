from routes.report.export_report import export_report
from routes.report.get_recent_reports import get_recent_reports
from routes.report.get_report import get_report
from routes.report.import_report import import_report
from routes.report.render_report import render_report
from routes.report.start_report_with_pivot_table import start_report_with_pivot_table
from routes.report.start_report_with_image_slide import start_report_with_image_slide
from routes.report.rename_report import rename_report

from flask import Blueprint

blueprint = Blueprint("report", __name__, url_prefix="/report")

export_report(blueprint)
get_recent_reports(blueprint)
get_report(blueprint)
import_report(blueprint)
render_report(blueprint)
start_report_with_pivot_table(blueprint)
start_report_with_image_slide(blueprint)
rename_report(blueprint)
