from testing.utils.client import client
from testing.utils.created_slideshow import created_report

from lib.report.construct import from_identifier

from models.report.self import Report
from models.image_slide.self import ImageSlide
from models.response.edit_image_slide_response import EditImageSlide_Response
from models.response.error_response import ErrorResponse

from routes.route_map import IMAGE_SLIDE

from random import choice
from uuid import uuid4

def test_edit_image_slide(client, created_report: Report):
    created_image_slide: ImageSlide = created_report.slides[0]
    parameter_name = choice(list(created_image_slide.parameters_dict.keys()))
    parameter_value = str(uuid4())

    response = client.post(IMAGE_SLIDE.EDIT, json={
        'report': created_report.identifier, 
        'image_slide': created_image_slide.identifier,
        'parameter_name': parameter_name,
        'parameter_value': parameter_value
    })

    assert response.status_code == 200, "No se pudo editar la diapositiva de imagen"
    edit_image_slide_response = EditImageSlide_Response(**response.get_json())
    assert edit_image_slide_response.preview is not None, "No se envió la vista previa actualizada de la imagen"

    _, report = from_identifier(identifier=created_report.identifier)
    image_slide = report.slides[0]
    assert image_slide.parameters_dict[parameter_name].value == parameter_value, "No se editó la diapositiva correctamente"
    assert image_slide.preview is not None, "No se guardó la nueva vista previa de la diapositiva"
    assert image_slide.preview != created_image_slide.preview, "La vista previa de la diapositiva sigue siendo la misma que antes de editarla"
    assert image_slide.last_edit > created_image_slide.last_edit, "No se actualizó el tiempo de última edición de la diapositiva"

def test_edit_image_slide_returns_error_when_missing_arguments_passed(client, created_report):
    created_image_slide: ImageSlide = created_report.slides[0]
    parameter_name = choice(list(created_image_slide.parameters_dict.keys()))

    response = client.post(IMAGE_SLIDE.EDIT, json={
        'report': created_report.identifier, 
        'image_slide': created_image_slide.identifier,
    })

    assert response.status_code == 400, "El servidor no lanzó un error aun faltando parámetros obligatorios en la solicitud"

    response = client.post(IMAGE_SLIDE.EDIT, json={
        'report': created_report.identifier, 
        'image_slide': created_image_slide.identifier,
        'parameter_name': parameter_name
    })

    assert response.status_code == 400, "El servidor no lanzó un error aun faltando parámetros obligatorios en la solicitud"    

def test_edit_image_slide_returns_error_when_invalid_parameter_passed(client, created_report):
    created_image_slide: ImageSlide = created_report.slides[0]
    parameter_name = str(uuid4())
    parameter_value = str(uuid4())

    response = client.post(IMAGE_SLIDE.EDIT, json={
        'report': created_report.identifier, 
        'image_slide': created_image_slide.identifier,
        'parameter_name': parameter_name,
        'parameter_value': parameter_value
    })

    assert response.status_code == 400, "El servidor no lanzó un error aun cuando se intentó editar un parámetro no existente en la diapositiva"
    error_response = ErrorResponse(**response.get_json())
    assert error_response.error == "El nombre del parámetro no es válido para la diapostiva a editar", "El servidor no respondió con un mensaje de error apropiado"
