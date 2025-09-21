from lib.with_flask import with_flask
from lib.get_or_panic import get_or_panic

from models.report.self import Report

from flask import request
from pandas import Timestamp

import os

@with_flask("/get", methods=["POST"])
def get_report():
    report = get_or_panic(request.json, 'report', 'El directorio del reporte debe estar presente')
    report = Report.from_identifier(identifier=report)

    now = Timestamp.now().to_pydatetime().timestamp()
    os.utime(report.root_directory, (now, now))

    return report.to_dict(), 200
