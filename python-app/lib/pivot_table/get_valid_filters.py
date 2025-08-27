from lib.data_frame.cross_section import cross_section

from models.pivot_table.data_filter.self import DataFilter
from models.pivot_table.data_filter.charting_mode import ChartingMode

import pandas

def get_valid_filters(data_frame: pandas.DataFrame, filters: list[DataFilter]) -> list[DataFilter]:
    valid_filters: list[DataFilter] = []
    for _filter in filters:
        possible_values = set(data_frame.index.get_level_values(level=_filter.level.value))
        selected_values = set(_filter.selected_values) & possible_values
        if len(selected_values) == 0 and (_filter.charting_mode != ChartingMode.NONE):
            selected_values = possible_values
        
        valid_filter = DataFilter(
            level=_filter.level,
            possible_values=list(possible_values),
            selected_values=list(selected_values),
            charting_mode=_filter.charting_mode,
            selection_mode=_filter.selection_mode,
            )
        
        valid_filters.append(valid_filter)
        data_frame = cross_section(
            data_frame=data_frame,
            key=valid_filter.selected_values, 
            level=valid_filter.level.value
            )
        
    return valid_filters
