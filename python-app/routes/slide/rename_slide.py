from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_report
from lib.get_or_panic import get_or_panic

from models.response.success_response import SuccessResponse

from flask import request
from pandas import Timestamp
from threading import Lock

LOCK = Lock()

@with_flask("/rename", methods=["POST"])
def rename_slide():
    with LOCK:
        report = entities_for_editing_report(request=request) 
        slide = get_or_panic(request.json, 'slide', 'El identificador de la diapositiva no está presente en la solicitud')
        title = get_or_panic(request.json, 'title', 'El nuevo título de la diapositiva no está presente en la solicitud')

        slide = report[slide]
        
        slide.title = title
        slide.last_edit = Timestamp.now()

        report.save()
        return SuccessResponse(message='Diapositiva renombrada con éxito').to_dict(), 200
