from lib.with_flask import with_flask
from lib.get_or_panic import get_or_panic
from lib.descriptive_error import DescriptiveError

from flask import request

@with_flask("/delete", methods=["POST"])
def delete_image_slide():
    report = get_or_panic(request.json, 'report', 'No se incluyó el identificador del reporte en la solicitud')
    slide = get_or_panic(request.json, 'slide', 'No se incluyó el identificador del reporte en la solicitud')
    raise DescriptiveError(http_error_code=500, message='El método aun no ha sido implementado en el backend')
