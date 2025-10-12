from models.pivot_table.self import PivotTable
from models.pivot_table.pivot_table_level import level_to_spanish
from models.pivot_table.aggregate_function_type import aggregate_function_to_spanish
from models.pivot_table.filter_function_type import filter_function_to_spanish
from models.pivot_table.data_filter.charting_mode import ChartingMode

from lib.pivot_table.plot_data import plot_data
from lib.directory_definitions import bare_preview_of_pivot_table

import os

def render_bare_preview_of_pivot_table(root_directory: str, pivot_table: PivotTable) -> str:
    filepath = bare_preview_of_pivot_table(root_directory=root_directory, slide_id=pivot_table.identifier)
    outer_filter = next((_filter for _filter in pivot_table.filters if _filter.charting_mode == ChartingMode.SUPER_CHART), None)
    if outer_filter is None:
        outer_filter = next((_filter for _filter in pivot_table.filters if _filter.charting_mode == ChartingMode.CHART), None)

    if pivot_table.bare_preview is not None and os.path.exists(pivot_table.bare_preview):
        os.remove(pivot_table.bare_preview)

    plot_data(
        data=pivot_table.data, 
        title=pivot_table.title, 
        kind="bar", 
        x_label=level_to_spanish(outer_filter.level), 
        y_label=aggregate_function_to_spanish(pivot_table.aggregate_function) + " de calificaciones de " + filter_function_to_spanish(pivot_table.filter_function),
        filepath=filepath
        )
    
    pivot_table.bare_preview = filepath
