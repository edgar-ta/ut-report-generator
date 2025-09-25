from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_report
from lib.get_or_panic import get_or_panic
from lib.directory_definitions import compiled_file_of_report

from models.response.success_response import SuccessResponse

from flask import request
from pandas import Timestamp
from threading import Lock

import os

LOCK = Lock()

@with_flask("/rename", methods=["POST"])
def rename_report():
    with LOCK:
        report = entities_for_editing_report(request=request)
        name = get_or_panic(request.json, 'name', 'El nuevo nombre del reporte no está presente en la solicitud')

        current_filename = compiled_file_of_report(root_directory=report.root_directory, report_name=report.report_name)
        if os.path.exists(current_filename):
            new_filename = compiled_file_of_report(root_directory=report.root_directory, report_name=name)
            os.rename(current_filename, new_filename)
        
        report.report_name = name
        report.last_edit = Timestamp.now()
        report.save()

        return SuccessResponse(
            message="Reporte renombrado exitosamente"
        ).to_dict(), 200
