from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_report
from lib.get_or_panic import get_or_panic
from lib.directory_definitions import root_directory_of_report

from models.response.success_response import SuccessResponse

from flask import request
from pandas import Timestamp

import os
import threading

LOCK = threading.Lock()

@with_flask("/rename", methods=["POST"])
def rename_report():
    with LOCK:
        report = entities_for_editing_report(request=request)
        name = get_or_panic(request.json, 'name', 'El nuevo nombre del reporte no está presente en la solicitud')

        new_name = root_directory_of_report(report_id=report.identifier, report_name=name)
        os.rename(report.root_directory, new_name)

        report.report_name = name
        report.last_edit = Timestamp.now()
        report.save()

        return SuccessResponse(
            message="Reporte renombrado exitosamente"
        ).to_dict(), 200
