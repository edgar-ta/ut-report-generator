from testing.client import client
from testing.slideshow.created_slideshow import created_report

from constants.control_variables import REPORTS_CHUNK_SIZE

from lib.report.construct import find_root_directory, from_json, from_root_directory
from lib.file_extension import has_extension
from lib.directory_definitions import exported_file_of_report, compiled_file_of_report

from models.response.recent_reports_response import RecentReportsResponse
from models.response.error_response import ErrorResponse
from models.response.file_response import FileResponse
from models.report.self import Report
from models.error.descriptive_error import DescriptiveError

import pytest
import os

def test_get_recent_slideshows(client):
    response = client.post("report/get_recent", json={})
    recent_reports_response = RecentReportsResponse(**response.get_json())

    assert response.status_code == 200, "La función para obtener las presentaciones recientes salió mal"
    assert len(recent_reports_response.reports) <= REPORTS_CHUNK_SIZE, f"El número de reportes recientes es mayor del esperado. Se recibieron {len(recent_reports_response.reports)} pero se esperaban máximo {REPORTS_CHUNK_SIZE}"

def test_get_existing_slideshow(client, created_report: Report):
    root_directory = find_root_directory(created_report.identifier)
    previous_time = os.path.getmtime(root_directory)

    response = client.post("report/get", json={'report': created_report.identifier})
    report = from_json(response.get_json())
    new_time = os.path.getmtime(root_directory)

    assert response.status_code == 200
    assert report.identifier == created_report.identifier
    assert all(slide.identifier == created_slide.identifier for slide, created_slide in zip(report.slides, created_report.slides))
    assert new_time > previous_time

def test_get_non_existing_slideshow_with_good_uuid(client):
    fake_id = '12345678-1234-4123-8123-123456789123'
    response = client.post("report/get", json={'report': fake_id})
    error_response = ErrorResponse(**response.get_json())

    assert response.status_code == 400, "El servidor no devolvió el código de estatus apropiado para un error del usuario"
    assert error_response.error == f"La id especificada ({fake_id}) no corresponde a ningún reporte", "El servidor no respondió con el mensaje de error apropiado"

def test_get_non_existing_slideshow_with_bad_uuid(client):
    fake_id = '1'
    response = client.post("report/get", json={'report': fake_id})
    error_response = ErrorResponse(**response.get_json())

    assert response.status_code == 400, "El servidor no devolvió el código de estatus apropiado para un error del usuario"
    assert error_response.error == f"El identificador provisto no es una UUID válida", "El servidor no respondió con el mensaje de error apropiado"

def test_export_report(client, created_report: Report):
    root_directory = find_root_directory(created_report.identifier)
    response = client.post("report/export", json={'report': created_report.identifier})
    file_response = FileResponse(**response.get_json())

    assert response.status_code == 200
    assert file_response.filepath == exported_file_of_report(root_directory=root_directory, report_name=created_report.report_name)
    assert os.path.exists(file_response.filepath)
    assert os.path.isfile(file_response.filepath)
    assert has_extension(file_response.filepath, 'zip')

def test_compile_slideshow(client, created_report: Report):
    root_directory = find_root_directory(created_report.identifier)
    response = client.post("report/compile", json={'report': created_report.identifier})
    file_response = FileResponse(**response.get_json())
    compiled_file = compiled_file_of_report(root_directory=root_directory, report_name=created_report.report_name)

    assert response.status_code == 200, "El servidor no pudo compilar la presentación"
    assert file_response.filepath == compiled_file, "El servidor compiló la presentación en una ruta diferente de la esperada"
    assert file_response.preview is not None, "El servidor no retornó una vista previa para la compilación de la presentación"
    assert os.path.exists(file_response.filepath), "La ruta devuelta por el servidor no existe"
    assert os.path.isfile(file_response.filepath), "La ruta devuelta por el servidor no es un archivo"
    assert has_extension(file_response.filepath, 'pptx'), "La ruta devuelta por el servidor no tiene la terminación .pptx"

def test_rename_slideshow(client, created_report: Report):
    root_directory = find_root_directory(created_report.identifier)
    new_name = "Name that's different from the default"

    response = client.post("report/rename", json={'report': created_report.identifier, 'name': new_name})
    assert response.status_code == 200, "El servidor no respondió correctamente al renombrado de una presentación"

    report = from_root_directory(root_directory=root_directory)
    assert report.report_name == new_name, "El nombre de la presentación no se cambió correctamente"

def test_rename_slideshow_after_compilation(client, created_report: Report):
    root_directory = find_root_directory(created_report.identifier)
    new_name = "Name that's different from the default"

    response = client.post("report/compile", json={'report': created_report.identifier})
    assert response.status_code == 200, "El servidor no pudo compilar la presentación antes de renombrarla"

    response = client.post("report/rename", json={'report': created_report.identifier, 'name': new_name})
    assert response.status_code == 200, "El servidor no pudo renombrar la presentación luego de compilarla"

    report = from_root_directory(root_directory=root_directory)
    compiled_file = compiled_file_of_report(root_directory=root_directory, report_name=report.report_name)
    assert report.report_name == new_name, "El nombre de la presentación no se cambió correctamente"
    assert os.path.exists(compiled_file), "El servidor no renombró la presentación una vez que fue compilada"

def test_rename_slideshow_after_exportation(client, created_report: Report):
    root_directory = find_root_directory(created_report.identifier)
    new_name = "Name that's different from the default"

    response = client.post("report/export", json={'report': created_report.identifier})
    assert response.status_code == 200, "El servidor no pudo exportar la presentación antes de renombrarla"

    response = client.post("report/rename", json={'report': created_report.identifier, 'name': new_name})
    assert response.status_code == 200, "El servidor no pudo renombrar la presentación luego de exportarla"

    report = from_root_directory(root_directory=root_directory)
    exported_file = exported_file_of_report(root_directory=root_directory, report_name=report.report_name)
    assert report.report_name == new_name, "El nombre de la presentación no se cambió correctamente"
    assert os.path.exists(exported_file), "El servidor no renombró la presentación una vez que fue exportada"

def test_delete_slideshow(client, created_report: Report):
    response = client.post("report/delete", json={'report': created_report.identifier})

    assert response.status_code == 200, "La presentación no pudo ser eliminada"
    with pytest.raises(DescriptiveError) as exception:
        find_root_directory(identifier=created_report.identifier)
    assert exception.value.message == f"La id especificada ({created_report.identifier}) no corresponde a ningún reporte", "El servidor no respondió con el mensaje apropiado"
