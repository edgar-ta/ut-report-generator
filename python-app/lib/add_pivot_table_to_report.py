from lib.sections.failure_rate.source import get_clean_data_frame, read_excel, get_grades_statistics
from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.unique_list import unique_list
from lib.file_extension import has_extension, get_file_extension
from lib.descriptive_error import DescriptiveError
from lib.is_valid_career_name import is_valid_career_name
from lib.directory_definitions import data_file_of_slide

from models.pivot_table.self import PivotTable
from models.pivot_table.aggregate_function_type import AggregateFunctionType
from models.pivot_table.filter_function_type import FilterFunctionType
from models.pivot_table.custom_indexer import CustomIndexer
from lib.get_parameters_of_frame import get_parameters_of_frame
from lib.get_data_of_frame import get_data_of_frame
from models.pivot_table.data_source import DataSource
from models.pivot_table.slide_category import SlideCategory
from models.report import Report

from flask import request
from uuid import uuid4

import pandas as pd

import os

def validate_files(data_files: list[str]) -> None:
    for data_file in data_files:
        extension = get_file_extension(filename=data_file)
        if extension is None:
            raise DescriptiveError(http_error_code=400, message="El archivo no tiene una extensión válida")
        
        if extension not in ["xls", "csv", "hdf5"]:
            raise DescriptiveError(http_error_code=400, message="El archivo es de una extensión no válida")
        # # This feature is disabled in the meantime
        # if not is_valid_career_name(data_file):
        #     raise DescriptiveError(http_error_code=400, message="El archivo no cuenta con el nombre de un grupo válido")
        if not os.path.exists(data_file):
            raise DescriptiveError(http_error_code=400, message="El archivo seleccionado no existe")

def get_data_frame_from_files(data_files: list[str]) -> pd.DataFrame:
    data_frames = []
    for data_file in data_files:
        match get_file_extension(filename=data_file):
            case "xls" | "xlsx":
                data_frames.append(pd.read_excel(data_file, header=[0, 1, 2, 3, 4]))
            case "csv":
                data_frames.append(pd.read_csv(data_file, header=[0, 1, 2, 3, 4]))

    print(__file__)
    print("@get_data_frame_from_files")
    print("Hello 0")

    data_frames = [ get_clean_data_frame(data_frame=data_frame) for data_frame in data_frames ]

    print(__file__)
    print("@get_data_frame_from_files")
    print("Hello 1")

    main_frame = pd.concat(data_frames)
    main_frame.sort_index(inplace=True)
    return main_frame

def add_pivot_table_to_report(report: Report, local_request, index: int | None) -> PivotTable:
    data_files = get_or_panic(local_request.json, "data_files", "Se necesitan archivos de datos para empezar una tabla dinámica")

    validate_files(data_files=data_files)

    slide_identifier = str(uuid4())
    main_frame = get_data_frame_from_files(data_files=data_files)

    print(__file__)
    print("@add_pivot_table_to_report")
    print("Hello 0")
    print(f'{main_frame = }')

    data_file = data_file_of_slide(root_directory=report.root_directory, slide_id=slide_identifier)
    os.makedirs(os.path.dirname(data_file), exist_ok=True)

    print("Hello 0.0")
    main_frame.to_hdf(path_or_buf=data_file, key=slide_identifier, format='table', mode='w')
    print("Hello 0.1")

    data_source = DataSource(files=data_files, merged_file=data_file)

    main_frame_names = main_frame.index.names
    first_main_frame_name = main_frame_names[0]
    first_level_value = main_frame.index.get_level_values(level=first_main_frame_name)[0]

    arguments = [
        CustomIndexer(level=first_main_frame_name, values=[first_level_value]),
        *[ CustomIndexer(level=name, values=[]) for name in main_frame_names[1:] ]
    ]

    print(__file__)
    print("@add_pivot_table_to_report")
    print("Hello 1")
    print(f'{arguments = }')

    parameters = get_parameters_of_frame(frame=main_frame, indexers=arguments)

    # Though it seems I just assigned the `arguments` variable the same value it
    # had before, that's not the case. I am changing the `values` kwarg to include
    # all of the options found in the parameters object of the corresponding name
    # this way, the second value of arguments doesn't have an empty array
    arguments = [ 
        CustomIndexer(level=first_main_frame_name, values=[ first_level_value ]), 
        *(parameters[1:])
    ]

    data = get_data_of_frame(
        frame=main_frame, 
        indexers=arguments, 
        filter_function=lambda x: x >= 7, 
        aggregate_function=lambda values: len(values), 
        error_value=0
        )
    
    pivot_table = PivotTable(
        aggregate_function=AggregateFunctionType.COUNT,
        arguments=arguments,
        creation_date=pd.Timestamp.now(),
        data=data,
        filter_function=FilterFunctionType.FAILED_STUDENTS,
        identifier=slide_identifier,
        last_edit=pd.Timestamp.now(),
        name="Mi tabla dinámica",
        parameters=parameters,
        preview=None,
        source=data_source,
        mode=SlideCategory.PIVOT_TABLE
    )

    print(__file__)
    print("@add_pivot_table_to_report")
    print("Hello 2")

    if index is None:
        report.slides.append(pivot_table)
    else:
        report.slides.insert(index, pivot_table)
    
    return pivot_table
