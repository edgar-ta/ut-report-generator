from lib.sections.failure_rate.source import get_clean_data_frame, read_excel, get_grades_statistics
from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.unique_list import unique_list

from functools import cache

import math
import pandas as pd

from flask import request


class CustomIndexer():
    def __init__(self, level: str, values: list[str]):
        self.level = level
        self.values: list[str] | None = values
    
    def __repr__(self) -> str:
        return f'CustomIndexer({self.level = }, {self.values = })'

def cross_section(data_frame: pd.DataFrame, key: list[str] | None, level: str) -> pd.DataFrame:
    if key is None:
        return data_frame
    match key:
        case [key]:
            return data_frame.xs(key=key, level=level)
        case _:
            equivalent_index = data_frame.index.names.index(level)
            return data_frame.loc[
                tuple(
                    key
                    if i == equivalent_index
                    else slice(None)
                    for i in range(len(data_frame.index.names))
                ),
                :
            ]

def get_params_of_frame(frame: pd.DataFrame, indexers: list[CustomIndexer]):
    result = {}
    for indexer in indexers:
        result[indexer.level] = unique_list(frame.index.get_level_values(level=indexer.level))

        if indexer == indexers[-1]: break
        frame = cross_section(data_frame=frame, key=indexer.values, level=indexer.level)
    return result


def _get_data_of_frame(frame: pd.DataFrame, indexers: list, filter_function, aggregate_function, error_value: float):
    match indexers:
        case []:
            try:
                value = frame.iloc[0, :]
                print(f'{value = }')
                value = value[value.apply(filter_function)]

                print(f'Value after filtering')
                print(f'{value = }')

                value = aggregate_function(value)
                
                return value
            except:
                return error_value
        case [indexer, *other_indexers]:
            indexer, *other_indexers = indexers
            level, values = indexer

            return {
                value: _get_data_of_frame(
                    frame=cross_section(data_frame=frame, key=value, level=level), 
                    indexers=other_indexers, 
                    filter_function=filter_function,
                    aggregate_function=aggregate_function,
                    error_value=error_value
                    )
                for value in values
            }

@with_app("/start_pivot_table", methods=["POST"])
def start_pivot_table():
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

    params = get_params_of_frame(frame=main_frame, indexers=params_indexers)

    data_indexers = [ 
        (first_main_frame_name, [ first_level_value ]), 
        *[ (name, params[name]) for name in main_frame.index.names[1:] ] 
    ]

    print(f'{data_indexers = }')

    data = _get_data_of_frame(
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
