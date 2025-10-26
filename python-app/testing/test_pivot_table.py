from testing.utils.client import client
from testing.utils.created_slideshow import created_visualization

from lib.report.construct import find_root_directory, from_root_directory
from lib.pivot_table.pivot_table_from_json import pivot_table_from_json

from models.report.self import Report
from models.response.edit_pivot_table_response import EditPivotTable_Response
from models.response.error_response import ErrorResponse

from routes.route_map import PIVOT_TABLE

import pytest
import os

def test_add_duplicate_file_to_pivot_table(client, created_visualization: Report):
    additional_file = r"D:\college\cuatrimestre-6\2025-06-16--estadias\ut-report-generator\.logistics-assets\2025-10-13--data-processing\ev01sm-24.xls"
    created_pivot_table = created_visualization.slides[0]
    root_directory = find_root_directory(identifier=created_visualization.identifier)

    response = client.post("pivot_table/add_file", json={
        'report': created_visualization.identifier,
        'pivot_table': created_pivot_table.identifier,
        'file': additional_file
    })
    assert response.status_code == 200, "No se pudo añadir un nuevo archivo a la tabla dinámica"

    edit_pivot_table_response = EditPivotTable_Response(**response.get_json())    
    assert os.path.exists(edit_pivot_table_response.preview), "La vista previa de la tabla dinámica no fue enviada"

    visualization = from_root_directory(root_directory=root_directory)
    pivot_table = visualization.slides[0]

    assert set([*created_pivot_table.source.files, additional_file]) == set(pivot_table.source.files), "El nuevo archivo no fue añadido a la lista de archivos de la tabla dinámica"
    assert pivot_table.source.merged_file is not None and os.path.exists(pivot_table.source.merged_file), "El archivo de datos de la tabla dinámica no existe"

def test_add_non_duplicate_file_to_pivot_table(client, created_visualization: Report):
    additional_file = "D:\\college\\cuatrimestre-6\\2025-06-16--estadias\\ut-report-generator\\.logistics-assets\\2025-10-13--data-processing\\ti02sm-23.xls"
    created_pivot_table = created_visualization.slides[0]
    root_directory = find_root_directory(identifier=created_visualization.identifier)

    response = client.post("pivot_table/add_file", json={
        'report': created_visualization.identifier,
        'pivot_table': created_pivot_table.identifier,
        'file': additional_file
    })
    assert response.status_code == 200, "El servidor tuvo un error cuando se intentó añadir un archivo duplicado a una tabla dinámica"

    edit_pivot_table_response = EditPivotTable_Response(**response.get_json())    
    assert os.path.exists(edit_pivot_table_response.preview), "La vista previa de la tabla dinámica no fue enviada"

    visualization = from_root_directory(root_directory=root_directory)
    pivot_table = visualization.slides[0]

    assert set(created_pivot_table.source.files) == set(pivot_table.source.files), "La lista de archivos de la tabla dinámica fue modificada aun cuando no se añadió un archivo nuevo"
    assert pivot_table.data == edit_pivot_table_response.data, "Los datos de la tabla dinámica fueron modificados aun cuando no se añadió un archivo nuevo"
    assert pivot_table.preview == edit_pivot_table_response.preview, "La vista previa de la tabla dinámica fue modificada aun cuando no se añadió un archivo nuevo"

def test_remove_existing_file_from_pivot_table(client, created_visualization: Report):
    pivot_table = created_visualization.slides[0]
    root_directory = find_root_directory(identifier=created_visualization.identifier)
    file_to_remove = pivot_table.source.files[0]
    remaining_files = pivot_table.source.files[1:]

    response = client.post("pivot_table/remove_file", json={
        'report': created_visualization.identifier,
        'pivot_table': pivot_table.identifier,
        'file': file_to_remove
    })
    assert response.status_code == 200, "El servidor tuvo un error al eliminar un archivo existente de la tabla dinámica"

    visualization = from_root_directory(root_directory=root_directory)
    updated_pivot_table = visualization.slides[0]
    assert set(updated_pivot_table.source.files) == set(remaining_files), "El archivo no fue eliminado correctamente de la lista de archivos de la tabla dinámica"

def test_remove_nonexistent_file_from_pivot_table(client, created_visualization: Report):
    pivot_table = created_visualization.slides[0]
    file_to_remove = "D:/ruta/inexistente.xls"

    response = client.post("pivot_table/remove_file", json={
        'report': created_visualization.identifier,
        'pivot_table': pivot_table.identifier,
        'file': file_to_remove
    })
    assert response.status_code == 400, "El servidor no devolvió error al intentar eliminar un archivo inexistente"

    error_response = ErrorResponse(**response.get_json())
    assert error_response.error == f"El archivo {file_to_remove} no está presente en la lista de archivos de la tabla dinámica", "El mensaje de error no es el esperado"

def test_remove_last_file_from_pivot_table(client, created_visualization: Report):
    auxiliary_file = "D:\\college\\cuatrimestre-6\\2025-06-16--estadias\\ut-report-generator\\.logistics-assets\\2025-10-13--data-processing\\ti02sm-23.xls"
    response = client.post("/pivot_table/create", json={
        'report': created_visualization.identifier,
        'data_files': [auxiliary_file]
    })

    assert response.status_code == 200, "No se pudo crear una tabla dinámica para testeo"
    pivot_table = pivot_table_from_json(response.get_json())

    response = client.post("pivot_table/remove_file", json={
        'report': created_visualization.identifier,
        'pivot_table': pivot_table.identifier,
        'file': auxiliary_file
    })

    assert response.status_code == 400, "El servidor no devolvió error al intentar eliminar el último archivo"
    error_response = ErrorResponse(**response.get_json())

    assert error_response.error == f"No se puede eliminar el último archivo de la tabla dinámica ({auxiliary_file})", "El mensaje de error no es el esperado"

def test_create_pivot_table_with_nonexistent_file(client, created_visualization: Report):
    nonexistent_file = "D:/ruta/inexistente.xls"
    response = client.post("/pivot_table/create", json={
        'report': created_visualization.identifier,
        'data_files': [nonexistent_file]
    })
    assert response.status_code == 400, "El servidor no devolvió error al intentar crear una tabla dinámica con un archivo inexistente"
    error_response = ErrorResponse(**response.get_json())
    assert error_response.error == "El archivo seleccionado no existe", "El mensaje de error no indica que el archivo no existe"

def test_create_pivot_table_with_invalid_group_name_file(client, created_visualization: Report):
    invalid_file = r"D:\college\cuatrimestre-6\2025-06-16--estadias\ut-report-generator\.logistics-assets\2025-10-13--data-processing\example-data-1.xls"

    response = client.post("/pivot_table/create", json={
        'report': created_visualization.identifier,
        'data_files': [invalid_file]
    })
    assert response.status_code == 400, "El servidor no devolvió error al intentar crear una tabla dinámica con archivos de nombre inválido"
    error_response = ErrorResponse(**response.get_json())
    assert error_response.error == "El archivo no cuenta con el nombre de un grupo válido", "El mensaje de error no indica que el nombre del archivo es inválido"

def test_create_pivot_table_with_invalid_extension_file(client, created_visualization: Report):
    invalid_file = r"D:\college\cuatrimestre-6\2025-06-16--estadias\ut-report-generator\.logistics-assets\2025-10-13--data-processing\ds01sm-24.htm"

    response = client.post("/pivot_table/create", json={
        'report': created_visualization.identifier,
        'data_files': [invalid_file]
    })
    assert response.status_code == 400, "El servidor no devolvió error al intentar crear una tabla dinámica con archivos de extensión inválida"
    error_response = ErrorResponse(**response.get_json())
    assert error_response.error == "El archivo es de una extensión no válida", "El mensaje de error no indica que el nombre del archivo es inválido"

def test_create_pivot_table_with_valid_files(client, created_visualization: Report):
    valid_file_1 = r"D:\college\cuatrimestre-6\2025-06-16--estadias\ut-report-generator\.logistics-assets\2025-10-13--data-processing\ds01sm-24.xls"
    valid_file_2 = r"D:\college\cuatrimestre-6\2025-06-16--estadias\ut-report-generator\.logistics-assets\2025-10-13--data-processing\ds02sm-24.xls"

    response = client.post("/pivot_table/create", json={
        'report': created_visualization.identifier,
        'data_files': [valid_file_1, valid_file_2]
    })
    assert response.status_code == 200, "El servidor no pudo crear la tabla dinámica con archivos válidos"
    pivot_table = pivot_table_from_json(response.get_json())
    assert set(pivot_table.source.files) == {valid_file_1, valid_file_2}, "Los archivos válidos no fueron añadidos correctamente a la tabla dinámica"

def test_create_pivot_table_with_nonexistent_report(client):
    nonexistent_report_id = "reporte-inexistente-123"
    valid_file = r"D:\college\cuatrimestre-6\2025-06-16--estadias\ut-report-generator\.logistics-assets\2025-10-13--data-processing\ds01sm-24.xls"

    response = client.post("/pivot_table/create", json={
        'report': nonexistent_report_id,
        'data_files': [valid_file]
    })
    assert response.status_code == 400, "El servidor no devolvió error al intentar crear una tabla dinámica con un reporte inexistente"

def test_get_pivot_table(client, created_visualization):
    pivot_table = created_visualization.slides[0]
    response = client.post(PIVOT_TABLE.GET, json={
        'report': created_visualization.identifier,
        'pivot_table': pivot_table.identifier
    })
    assert response.status_code == 200, "No se pudo obtener la tabla dinámica"
    data = response.get_json()
    assert "source" in data, "La respuesta no contiene la fuente de datos"
    assert "filters" in data, "La respuesta no contiene los filtros"
    assert "data" in data, "La respuesta no contiene los datos de la tabla dinámica"

def test_set_charts_with_chart_only(client, created_visualization):
    pivot_table = created_visualization.slides[0]
    chart_index = 0
    response = client.post(PIVOT_TABLE.SET_CHARTS, json={
        'report': created_visualization.identifier,
        'pivot_table': pivot_table.identifier,
        'chart': chart_index,
        'super_chart': None
    })
    assert response.status_code == 200, "No se pudo establecer el gráfico"
    data = response.get_json()
    assert isinstance(data, dict), "La propiedad `data` no es un diccionario"
    for value in data.values():
        try:
            float(value)
        except:
            raise Exception("Los valores de `data` no son todos de tipo float")

def test_set_charts_with_super_chart_only(client, created_visualization):
    pivot_table = created_visualization.slides[0]
    super_chart_index = 1
    response = client.post(PIVOT_TABLE.SET_CHARTS, json={
        'report': created_visualization.identifier,
        'pivot_table': pivot_table.identifier,
        'chart': None,
        'super_chart': super_chart_index
    })
    assert response.status_code == 200, "No se pudo establecer el super gráfico"
    data = response.get_json()
    assert isinstance(data, dict), "La propiedad `data` no es un diccionario"
    assert all(isinstance(v, dict) for v in data.values()), "Los valores de `data` no son diccionarios"
    for subdict in data.values():
        for value in subdict.values():
            try:
                float(value)
            except:
                raise Exception("Los valores internos de `data` no son todos de tipo float")
