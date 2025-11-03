from lib.get_or_panic import get_or_panic
from lib.directory_definitions import data_file_of_slide
from lib.group_name import group_name_from_path
from lib.data_frame.data_frame_io import export_data_frame
from lib.data_frame.validate_file import validate_file
from lib.pivot_table.get_data_of_frame import get_data_of_frame
from lib.pivot_table.get_clean_data_frame import get_clean_data_frame
from lib.pivot_table.read_excel import read_excel
from lib.pivot_table.create_default_filters import create_default_filters
from lib.pivot_table.render_bare_preview_of_pivot_table import render_bare_preview_of_pivot_table
from lib.pivot_table.recalculate import recalculate

from models.pivot_table.self import PivotTable
from models.pivot_table.aggregate_function_type import AggregateFunctionType
from models.pivot_table.filter_function_type import FilterFunctionType
from models.pivot_table.data_source import DataSource

from uuid import uuid4

import pandas as pd

import os
import flask

def get_data_frame_from_files(data_files: list[str]) -> pd.DataFrame:
    data_frames: list[pd.DataFrame] = [ read_excel(filename=data_file) for data_file in data_files ]

    data_frames = [ 
        get_clean_data_frame(data_frame=data_frame, group_name=group_name_from_path(file_path=data_file)) 
        for data_frame, data_file in zip(data_frames, data_files)
        ]

    main_frame = pd.concat(data_frames)
    main_frame.sort_index(inplace=True)
    return main_frame


def build_pivot_table(root_directory: str, local_request: flask.Request) -> PivotTable:
    '''
    Adds a pivot table to a report. The state of the pivot table is HAS_PREVIEW
    '''

    data_files = get_or_panic(local_request.json, "data_files", "Se necesitan archivos de datos para empezar una tabla dinámica")

    for data_file in data_files:
        validate_file(data_file=data_file)

    slide_identifier = str(uuid4())
    main_frame = get_data_frame_from_files(data_files=data_files)

    data_file = data_file_of_slide(root_directory=root_directory, slide_id=slide_identifier)
    os.makedirs(os.path.dirname(data_file), exist_ok=True)

    export_data_frame(data_frame=main_frame, file_path=data_file, key=slide_identifier)

    data_source = DataSource(files=data_files, merged_file=data_file)
    default_filter_function = FilterFunctionType.FAILED_STUDENTS
    default_aggregate_function = AggregateFunctionType.COUNT
    default_filters = create_default_filters(data_frame=main_frame)
    default_title = "Mi gráfico"

    pivot_table = PivotTable(
        title=default_title,
        identifier=slide_identifier,
        creation_date=pd.Timestamp.now(),
        last_edit=pd.Timestamp.now(),
        preview=None,
        bare_preview=None,
        filters=default_filters,
        filters_order=[ _filter.level for _filter in default_filters ],
        source=data_source,
        data=None,
        aggregate_function=default_aggregate_function,
        filter_function=default_filter_function,
    )

    recalculate(root_directory=root_directory, pivot_table=pivot_table, preloaded_data_frame=main_frame)
    
    return pivot_table
