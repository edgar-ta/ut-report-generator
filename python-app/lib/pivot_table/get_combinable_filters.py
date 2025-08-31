from control_variables import INVALID_FILTER_CREATES_VOID

from lib.data_filter.is_valid_filter import is_valid_filter
from lib.data_filter.get_valid_values import get_valid_values
from lib.data_frame.cross_section import cross_section

from models.pivot_table.data_filter.self import DataFilter
from models.pivot_table.data_filter.charting_mode import ChartingMode

from functools import cache, reduce
from typing import Callable, Iterable, TypeVar

import pandas


T = TypeVar("T")
def reduce_or(function: Callable[[T, T], T], iterable: Iterable[T], default_value: T):
    try:
        return reduce(function, iterable)
    except TypeError:  # ocurre cuando iterable está vacío
        return default_value


def get_combinable_filters(data_frame: pandas.DataFrame, filters: list[DataFilter]) -> list[DataFilter]:
    '''
    Tries to map the list of filters to its combinable version (with respect to the data frame).
    Valid filters in the resulting list are combinable with respect to the data frame; invalid filters 
    are uncombinable
    '''
    combinable_filters: list[DataFilter] = []
    data_frames: list[pandas.DataFrame] = [ data_frame ]

    for _filter in filters:
        possible_values_set = reduce_or(
            function=lambda first, second: first & second, 
            iterable=[ set(_data_frame.index.get_level_values(level=_filter.level.value)) for _data_frame in data_frames ],
            default_value=set()
        )
        combinable_filter = DataFilter(
            level=_filter.level,
            charting_mode=_filter.charting_mode,
            possible_values=list(possible_values_set),
            selected_values=list(set(_filter.selected_values) & possible_values_set),
            selection_mode=_filter.selection_mode,
            )
        combinable_filters.append(combinable_filter)

        if _filter == filters[-1]:
            # No need to create more data frames at the end; 
            # they won't be used in the future
            continue
        
        if is_valid_filter(_filter=combinable_filter):
            data_frames = [ 
                cross_section(data_frame=_data_frame, key=[value], level=combinable_filter.level.value) 
                for _data_frame in data_frames 
                for value in get_valid_values(_filter=combinable_filter)
                ]
        elif INVALID_FILTER_CREATES_VOID:
            data_frames = []
    
    return combinable_filters
