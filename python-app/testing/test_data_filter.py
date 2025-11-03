from testing.utils.client import client
from testing.utils.created_slideshow import created_visualization

from lib.report.construct import from_identifier, from_root_directory, find_root_directory

from models.report.self import Report
from models.pivot_table.self import PivotTable
from models.pivot_table.pivot_table_level import PivotTableLevel
from models.pivot_table.data_filter.self import DataFilter
from models.response.edit_pivot_table_response import EditPivotTable_Response

from routes.route_map import DATA_FILTER

from typing import TypeVar

import pytest

PivotTableData = dict[str, float] | dict[str, dict[str, float]]

T = TypeVar("T", float, dict)
def _is_data_equals(first: T, second: T) -> bool:
    if isinstance(first, float):
        return first == second

    first_keys = set(first.keys())
    second_keys = set(second.keys())
    if first_keys != second_keys:
        return False
    
    for key in first_keys:
        if not _is_data_equals(first[key], second[key]):
            return False
    return True

def test_create_filter(client, created_visualization: Report):
    created_pivot_table: PivotTable = created_visualization.slides[0]

    response = client.post(DATA_FILTER.CREATE.value, json={
        'report': created_visualization.identifier,
        'pivot_table': created_pivot_table.identifier,
        'level': PivotTableLevel.YEAR.value
    })
    assert response.status_code == 200, "El servidor no pudo crear el nuevo filtro"
    created_data_filter = DataFilter.from_json(response.get_json())

    _, visualization = from_identifier(identifier=created_visualization.identifier)
    pivot_table: PivotTable = visualization[created_pivot_table.identifier]

    assert pivot_table.filters_order[-1] == created_data_filter.level, "El filtro recién creado no tiene la precedencia esperada (debería estar hasta el final)"
    assert visualization.last_edit > created_visualization.last_edit, "El servidor no actualizó correctamente la última edición de la visualización"
    assert pivot_table.preview is not None, "El servidor no creó una vista previa para la tabla dinámica correspondiente al filtro"

    if len(created_data_filter.possible_values) > 0:
        assert len(created_data_filter.selected_values) > 0, "Los filtros con opciones posibles no pueden tener cero opciones seleccionadas"

# def test_create_filter_of_invalid_level(client, created_visualization):
#     pass

def test_delete_filter(client, created_visualization: Report):
    filter_index = 0
    created_pivot_table: PivotTable = created_visualization.slides[0]
    created_data_filter = created_pivot_table.filters[filter_index]

    response = client.post(DATA_FILTER.DELETE.value, json={
        'report': created_visualization.identifier,
        'pivot_table': created_pivot_table.identifier,
        'filter': filter_index
    })
    assert response.status_code == 200, "El servidor no pudo eliminar el filtro solicitado"
    edit_pivot_table_response = EditPivotTable_Response.from_json(response.get_json())
    
    assert edit_pivot_table_response.preview is not None, "El servidor no envió una vista previa para la tabla dinámica"
    assert created_data_filter.level not in [data_filter.level for data_filter in edit_pivot_table_response.filters], "El servidor envió el filtro a eliminar en su respuesta"

    _, visualization = from_identifier(identifier=created_visualization.identifier)
    pivot_table = visualization.slides[0]
    assert created_data_filter.level not in [ data_filter.level for data_filter in pivot_table.filters ], "El servidor no eliminó el filtro solicitado del sistema de archivos"
    assert visualization.last_edit > created_visualization.last_edit, "El servidor no actualizó correctamente la hora de última edición"

# def test_delete_last_filter(client, created_visualization):
#     pass

# def test_add_option_to_filter(client, created_visualization):
#     pass

# def test_remove_option_from_filter(client, created_visualization):
#     pass

# def test_remove_last_option_from_filter(client, created_visualization):
#     pass

# def test_toggle_mode_of_filter(client, created_visualization):
#     pass
