from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic

from models.report import Report
from models.frontend.report_record import ReportRecord

from flask import request

@with_app("/get", methods=["POST"])
def get_report():
    report_directory = get_or_panic(request.json, 'report_directory', 'El directorio del reporte debe estar presente')
    report = Report.from_root_directory(root_directory=report_directory)
    record = ReportRecord.from_report(report=report)

    return record.to_dict(), 200
