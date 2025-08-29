from lib.pivot_table.get_valid_filters import get_valid_filters
from lib.pivot_table.ordered_filters import ordered_filters
from lib.pivot_table.get_data_of_frame import get_data_of_frame
from lib.data_frame.data_frame_io import import_data_frame

from models.pivot_table.self import PivotTable
from models.pivot_table.data_filter.self import DataFilter

import pandas

def recalculate(pivot_table: PivotTable, preloaded_data_frame: pandas.DataFrame | None) -> tuple[dict[str, dict[str, float]] | dict[str, float], list[DataFilter]]:
    data_frame = preloaded_data_frame
    if data_frame is None:
        data_frame = import_data_frame(file_path=pivot_table.source.merged_file, key=pivot_table.identifier)
    
    new_filters = get_valid_filters(data_frame=data_frame, filters=pivot_table.filters)
    pivot_table.filters = new_filters

    _ordered_filters = ordered_filters(filters_order=pivot_table.filters_order, filters=pivot_table.filters)
    new_data = get_data_of_frame(
        data_frame=data_frame, 
        filters=_ordered_filters, 
        filter_function=pivot_table.filter_function, 
        aggregate_function=pivot_table.aggregate_function
        )
    pivot_table.data = new_data

    return (new_data, new_filters)
