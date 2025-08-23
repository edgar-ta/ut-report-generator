from control_variables import DATA_NESTING_LEVEL

from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.descriptive_error import DescriptiveError
from lib.get_parameters_of_frame import get_parameters_of_frame
from lib.get_data_of_frame import get_data_of_frame

from models.pivot_table.self import PivotTable
from models.pivot_table.custom_indexer import CustomIndexer
from models.report import Report

from flask import request

import pandas

import os

def read_data_source(file_path: str):
    return pandas.read_hdf(file_path)

@with_app("/edit", methods=["POST"])
def edit_pivot_table():
    report = get_or_panic(request.json, 'report', 'La id del reporte a editar debe estar presente')
    pivot_table = get_or_panic(request.json, 'pivot_table', "La id de la tabla a editar debe estar presente")
    arguments = get_or_panic(request.json, 'arguments', "Los argumentos de la tabla a editar deben estar presentes")

    report: Report = Report.from_identifier(identifier=report)
    pivot_table: PivotTable = report[pivot_table]
    arguments: list[CustomIndexer] = [ CustomIndexer.from_json(argument) for argument in arguments ]

    data_frame = pivot_table.source.merged_file

    if data_frame is None:
        raise DescriptiveError(http_error_code=400, message="El archivo de datos de la tabla dinámica no existe")
    
    if not os.path.exists(data_frame):
        raise DescriptiveError(http_error_code=400, message="El archivo de datos de la tabla dinámica no existe")
    
    data_frame = read_data_source(file_path=data_frame)

    parameters, valid_arguments = get_parameters_of_frame(frame=data_frame, arguments=arguments)

    data = get_data_of_frame(
        frame=data_frame, 
        indexers=valid_arguments,
        aggregate_function=pivot_table.aggregate_function,
        filter_function=pivot_table.filter_function,
        nesting_level=DATA_NESTING_LEVEL
        )

    pivot_table.arguments = valid_arguments
    pivot_table.parameters = parameters
    pivot_table.data = data
    pivot_table.last_edit = pandas.Timestamp.now()

    report.save()

    return {
        "parameters": [ parameter.to_dict() for parameter in parameters ],
        "arguments": [ argument.to_dict() for argument in valid_arguments ],
        "data": data
    }, 200
