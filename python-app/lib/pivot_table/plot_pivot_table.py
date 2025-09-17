from models.pivot_table.self import PivotTable
from models.pivot_table.pivot_table_level import PivotTableLevel, level_to_spanish
from models.pivot_table.aggregate_function_type import AggregateFunctionType, aggregate_function_to_spanish
from models.pivot_table.filter_function_type import FilterFunctionType, filter_function_to_spanish
from models.pivot_table.data_filter.charting_mode import ChartingMode
from models.report.self import Report

from lib.pivot_table.plot_data import plot_data
from lib.directory_definitions import preview_image_of_slide

import os

def plot_from_components(
        data, 
        title: str, 
        outer_chart: PivotTableLevel, 
        _filter: FilterFunctionType, 
        aggregate: AggregateFunctionType,
        filepath: str,
        former_preview: str | None = None
        ) -> None:
    plot_data(
        data=data, 
        title=title, 
        kind="bar", 
        x_label=level_to_spanish(outer_chart), 
        y_label=aggregate_function_to_spanish(aggregate) + " de calificaciones de " + filter_function_to_spanish(_filter),
        filepath=filepath
        )
    
    if former_preview is not None:
        os.remove(former_preview)

def plot_from_entities(report: Report, pivot_table: PivotTable) -> str:
    outer_filter = next((_filter for _filter in pivot_table.filters if _filter.charting_mode == ChartingMode.SUPER_CHART), None)
    if outer_filter is None:
        outer_filter = next((_filter for _filter in pivot_table.filters if _filter.charting_mode == ChartingMode.CHART), None)

    filepath = preview_image_of_slide(root_directory=report.root_directory, slide_id=pivot_table.identifier)

    plot_from_components(
        data=pivot_table.data, 
        title=pivot_table.title, 
        outer_chart=outer_filter.level, 
        _filter=pivot_table.filter_function, 
        aggregate=pivot_table.aggregate_function, 
        filepath=filepath, 
        former_preview=pivot_table.preview
        )
    
    return filepath
