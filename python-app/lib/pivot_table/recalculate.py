from lib.pivot_table.get_combinable_filters import get_combinable_filters
from lib.pivot_table.ordered_filters import ordered_filters
from lib.pivot_table.get_data_of_frame import get_data_of_frame
from lib.pivot_table.ordered_filters import find_filter
from lib.pivot_table.plot_pivot_table import plot_from_entities
from lib.data_filter.is_valid_filter import is_valid_filter
from lib.data_frame.data_frame_io import import_data_frame
from lib.directory_definitions import bare_preview_of_pivot_table

from models.pivot_table.self import PivotTable
from models.pivot_table.data_filter.self import DataFilter
from models.pivot_table.pivot_table_level import PivotTableLevel
from models.pivot_table.data_filter.charting_mode import ChartingMode
from models.report.self import Report

import pandas
import os

def fix_charts(filters: list[DataFilter], filters_order: list[PivotTable]) -> None:
    find_new_chart = False
    super_chart = None

    for _filter in filters:
        if not is_valid_filter(_filter=_filter):
            if _filter.charting_mode == ChartingMode.CHART:
                find_new_chart = True
            if _filter.charting_mode == ChartingMode.SUPER_CHART:
                super_chart = _filter
            _filter.charting_mode = ChartingMode.NONE
    
    if find_new_chart:
        new_chart = ...
        if super_chart is not None:
            new_chart = super_chart
        elif filters_order.__len__() > 0:
            new_chart = find_filter(level=filters_order[0], filters=filters)
        else:
            new_chart = next(_filter for _filter in filters if is_valid_filter(_filter=_filter))
        new_chart.charting_mode = ChartingMode.CHART
    

def recalculate(report: Report, pivot_table: PivotTable, preloaded_data_frame: pandas.DataFrame | None = None):
    '''
    Re calculates the data of the pivot table based on its filters. It modifies the pivot table in place.
    Also, it creates a new preview
    '''
    data_frame = preloaded_data_frame
    if data_frame is None:
        data_frame = import_data_frame(file_path=pivot_table.source.merged_file, key=pivot_table.identifier)
    
    combinable_filters = get_combinable_filters(data_frame=data_frame, filters=pivot_table.filters)
    fix_charts(filters=combinable_filters, filters_order=pivot_table.filters_order)
    pivot_table.filters = combinable_filters

    _ordered_filters = ordered_filters(filters_order=pivot_table.filters_order, filters=pivot_table.filters)
    new_data = get_data_of_frame(
        data_frame=data_frame, 
        filters=_ordered_filters, 
        filter_function=pivot_table.filter_function, 
        aggregate_function=pivot_table.aggregate_function
        )
    
    if os.path.exists(pivot_table.bare_preview):
        os.remove(pivot_table.bare_preview)
    
    filepath = bare_preview_of_pivot_table(root_directory=report.root_directory, slide_id=pivot_table.identifier)
    plot_from_entities(filepath=filepath, pivot_table=pivot_table)

    pivot_table.data = new_data
    pivot_table.bare_preview = filepath
