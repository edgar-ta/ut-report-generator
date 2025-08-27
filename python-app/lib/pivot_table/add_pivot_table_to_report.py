from lib.get_or_panic import get_or_panic
from lib.file_extension import get_file_extension, without_extension
from lib.descriptive_error import DescriptiveError
from lib.directory_definitions import data_file_of_slide
from lib.data_frame.data_frame_io import export_data_frame
from lib.pivot_table.get_data_of_frame import get_data_of_frame
from lib.pivot_table.get_clean_data_frame import get_clean_data_frame
from lib.pivot_table.is_valid_career_name import is_valid_career_name
from lib.pivot_table.read_excel import read_excel
from lib.pivot_table.create_default_filters import create_default_filters

from models.pivot_table.self import PivotTable
from models.pivot_table.aggregate_function_type import AggregateFunctionType
from models.pivot_table.filter_function_type import FilterFunctionType
from models.pivot_table.data_source import DataSource
from models.slide.slide_category import SlideCategory
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
        
        filename = os.path.split(data_file)[-1]
        if not is_valid_career_name(without_extension(filename=filename)):
            raise DescriptiveError(http_error_code=400, message=f"El archivo no cuenta con el nombre de un grupo válido ({filename})")
        
        if not os.path.exists(data_file):
            raise DescriptiveError(http_error_code=400, message="El archivo seleccionado no existe")

def get_data_frame_from_files(data_files: list[str]) -> pd.DataFrame:
    data_frames: list[pd.DataFrame] = [ read_excel(filename=data_file) for data_file in data_files ]

    data_frames = [ 
        get_clean_data_frame(data_frame=data_frame, group_name=without_extension(filename=os.path.split(data_file)[-1])) 
        for data_frame, data_file in zip(data_frames, data_files)
        ]

    main_frame = pd.concat(data_frames)
    main_frame.sort_index(inplace=True)
    return main_frame


def add_pivot_table_to_report(report: Report, local_request, index: int | None) -> PivotTable:
    data_files = get_or_panic(local_request.json, "data_files", "Se necesitan archivos de datos para empezar una tabla dinámica")

    validate_files(data_files=data_files)

    slide_identifier = str(uuid4())
    main_frame = get_data_frame_from_files(data_files=data_files)

    data_file = data_file_of_slide(root_directory=report.root_directory, slide_id=slide_identifier)
    os.makedirs(os.path.dirname(data_file), exist_ok=True)

    export_data_frame(data_frame=main_frame, file_path=data_file, key=slide_identifier)

    data_source = DataSource(files=data_files, merged_file=data_file)
    filter_function = FilterFunctionType.FAILED_STUDENTS
    aggregate_function = AggregateFunctionType.COUNT
    filters = create_default_filters(data_frame=main_frame)

    data = get_data_of_frame(
        data_frame=main_frame, 
        filters=filters, 
        filter_function=filter_function, 
        aggregate_function=aggregate_function, 
        )
    
    pivot_table = PivotTable(
        aggregate_function=aggregate_function,
        creation_date=pd.Timestamp.now(),
        data=data,
        filter_function=filter_function,
        identifier=slide_identifier,
        last_edit=pd.Timestamp.now(),
        name="Mi tabla dinámica",
        filters=filters,
        preview=None,
        source=data_source,
        mode=SlideCategory.PIVOT_TABLE
    )

    if index is None:
        report.slides.append(pivot_table)
    else:
        report.slides.insert(index, pivot_table)
    
    return pivot_table

