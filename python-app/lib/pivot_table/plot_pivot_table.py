from models.pivot_table.self import PivotTable
from models.pivot_table.pivot_table_level import PivotTableLevel, level_to_spanish
from models.pivot_table.aggregate_function_type import AggregateFunctionType, aggregate_function_to_spanish
from models.pivot_table.filter_function_type import FilterFunctionType, filter_function_to_spanish
from models.pivot_table.data_filter.charting_mode import ChartingMode
from models.report import Report

from lib.pivot_table.plot_data import plot_data
from lib.directory_definitions import preview_image_of_slide

import os

def render_pivot_table(report: Report, pivot_table: PivotTable) -> str:
    outer_filter = next((_filter for _filter in pivot_table.filters if _filter.charting_mode == ChartingMode.SUPER_CHART), None)
    if outer_filter is None:
        outer_filter = next((_filter for _filter in pivot_table.filters if _filter.charting_mode == ChartingMode.CHART), None)

    filepath = preview_image_of_slide(root_directory=report.root_directory, slide_id=pivot_table.identifier)
    plot_data(
        data=pivot_table.data, 
        title=pivot_table.name, 
        kind="bar", 
        x_label=level_to_spanish(outer_filter.level), 
        y_label=aggregate_function_to_spanish(pivot_table.aggregate_function) + " de calificaciones de " + filter_function_to_spanish(pivot_table.filter_function),
        filepath=filepath
        )
    
    if pivot_table.preview is not None:
        os.remove(pivot_table.preview)
    return filepath
