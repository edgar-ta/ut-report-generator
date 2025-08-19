from lib.sections.failure_rate.source import get_clean_data_frame, read_excel, get_grades_statistics
from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.unique_list import unique_list

from models.pivot_table.custom_indexer import CustomIndexer
from models.pivot_table.get_parameters_of_frame import get_parameters_of_frame
from models.pivot_table.get_data_of_frame import get_data_of_frame

import pandas as pd

from flask import request

@with_app("/create", methods=["POST"])
def create_pivot_table():
    data_files = get_or_panic(request.json, "data_files", "Se necesitan archivos de datos para empezar una tabla dinámica")
    
    data_frames = [ read_excel(filename=filename) for filename in data_files ]
    data_frames = [ get_clean_data_frame(data_frame=data_frame) for data_frame in data_frames ]
    main_frame = pd.concat(data_frames)
    main_frame.sort_index(inplace=True)

    main_frame_names = main_frame.index.names
    first_main_frame_name = main_frame_names[0]
    first_level_value = unique_list(main_frame.index.get_level_values(level=first_main_frame_name))[0]

    params_indexers = [
        CustomIndexer(level=first_main_frame_name, values=[first_level_value]),
        *[ CustomIndexer(level=name, values=None) for name in main_frame_names[1:] ]
    ]

    params = get_parameters_of_frame(frame=main_frame, indexers=params_indexers)

    data_indexers = [ 
        (first_main_frame_name, [ first_level_value ]), 
        *[ (name, params[name]) for name in main_frame.index.names[1:] ] 
    ]

    data = get_data_of_frame(
        frame=main_frame, 
        indexers=data_indexers, 
        filter_function=lambda x: x >= 7, 
        aggregate_function=lambda values: len(values), 
        error_value=0
        )

    return {
        "params": params,
        "data": data,
    }, 200
