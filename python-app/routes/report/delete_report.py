from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_report

from models.response.success_response import SuccessResponse

from flask import request

import shutil

@with_flask("/delete", methods=["POST"])
def delete_report():
    root_directory, _ = entities_for_editing_report(request=request)
    shutil.rmtree(root_directory)

    return SuccessResponse(message="El reporte fue eliminado correctamente").to_dict(), 200
