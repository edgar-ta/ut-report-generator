from testing.utils.client import client
from testing.utils.created_slideshow import created_report

from lib.report.construct import from_identifier, find_root_directory, from_root_directory
from lib.directory_definitions import base_directory_of_slide

from models.report.self import Report
from models.response.file_response import FileResponse
from models.response.error_response import ErrorResponse
from models.error.descriptive_error import DescriptiveError

from routes.route_map import SLIDE

from uuid import uuid4

import pytest
import os

def test_rename_slide(client, created_report: Report):
    created_slide = created_report.slides[0]
    new_title = str(uuid4())

    response = client.post(SLIDE.RENAME.value, json={
        'report': created_report.identifier,
        'slide': created_slide.identifier,
        'title': new_title
    })
    assert response.status_code == 200, "No se pudo renombrar la diapositiva"
    file_response = FileResponse(**response.get_json())
    assert file_response.filepath is not None, "No se envió una vista previa válida en la respuesta del servidor"
    
    _, report = from_identifier(identifier=created_report.identifier)
    slide = report.slides[0]
    assert slide.title == new_title, "La solicitud no cambió el título de la diapositiva"

def test_rename_slide_when_missing_title_passed(client, created_report: Report):
    created_slide = created_report.slides[0]

    response = client.post(SLIDE.RENAME.value, json={
        'report': created_report.identifier,
        'slide': created_slide.identifier,
    })
    assert response.status_code == 400, "El servidor no envió un error aun cuando no se envió el parámetro 'title' en la petición, el cual es obligatorio"
    error_response = ErrorResponse(**response.get_json())
    assert error_response.error == "El nuevo título de la diapositiva no está presente en la solicitud", "El servidor no respondió con el mensaje de error esperado"

def test_delete_slide(client, created_report: Report):
    root_directory = find_root_directory(identifier=created_report.identifier)
    created_slide = created_report.slides[0]
    response = client.post(SLIDE.DELETE.value, json={
        'report': created_report.identifier,
        'slide': created_slide.identifier,
    })

    assert response.status_code == 200, "El servidor no pudo eliminar la diapositiva correctamente"
    base_directory = base_directory_of_slide(root_directory=root_directory, slide_id=created_slide.identifier)

    assert not os.path.exists(base_directory), "El servidor no eliminó a la diapositiva del sistema de archivos"
    report = from_root_directory(root_directory=root_directory)
    with pytest.raises(DescriptiveError):
        slide = report[created_slide.identifier]
    
    assert report.last_edit > created_report.last_edit, "No se actualizó la fecha de última edición del reporte"
