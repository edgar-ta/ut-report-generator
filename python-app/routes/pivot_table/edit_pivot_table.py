from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.descriptive_error import DescriptiveError
from lib.pivot_table.get_data_of_frame import get_data_of_frame
from lib.data_frame.data_frame_io import import_data_frame

from models.pivot_table.self import PivotTable
from models.pivot_table.data_filter.self import DataFilter
from models.report import Report

from flask import request

import pandas

import os

@with_app("/edit", methods=["POST"])
def edit_pivot_table():
    report = get_or_panic(request.json, 'report', 'La id del reporte a editar debe estar presente')
    pivot_table = get_or_panic(request.json, 'pivot_table', "La id de la tabla a editar debe estar presente")
    # Los filtros están ordenados por prioridad, de modo que aquellos que acaba de modificar el usuario
    # (es decir, los que más le interesa que obedezcan a su selección) están antes que los de menor prioridad
    filters = get_or_panic(request.json, 'filters', "Los argumentos de la tabla a editar deben estar presentes")

    report: Report = Report.from_identifier(identifier=report)
    pivot_table: PivotTable = report[pivot_table]
    filters: list[DataFilter] = [ DataFilter.from_json(_filter) for _filter in filters ]

    data_frame = pivot_table.source.merged_file

    if data_frame is None:
        raise DescriptiveError(http_error_code=400, message="El archivo de datos de la tabla dinámica no existe")
    
    if not os.path.exists(data_frame):
        raise DescriptiveError(http_error_code=400, message="El archivo de datos de la tabla dinámica no existe")
    
    data_frame = import_data_frame(file_path=data_frame, key=pivot_table.identifier)

    data, valid_filters = get_data_of_frame(
        frame=data_frame, 
        filters=filters,
        aggregate_function=pivot_table.aggregate_function,
        filter_function=pivot_table.filter_function,
        )

    pivot_table.filters = valid_filters
    pivot_table.data = data
    pivot_table.last_edit = pandas.Timestamp.now()

    report.save()

    return {
        "filters": [ _filter.to_dict() for _filter in valid_filters ],
        "data": data
    }, 200
