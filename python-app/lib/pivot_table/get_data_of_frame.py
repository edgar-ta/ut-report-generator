from lib.data_frame.cross_section import cross_section
from lib.data_frame.flatten_to_series import flatten_to_series
from lib.descriptive_error import DescriptiveError

from models.pivot_table.data_filter.self import DataFilter
from models.pivot_table.data_filter.charting_mode import ChartingMode
from models.pivot_table.filter_function_type import FilterFunctionType
from models.pivot_table.aggregate_function_type import AggregateFunctionType

import pandas

def get_data_of_frame(
        frame: pandas.DataFrame, 
        filters: list[DataFilter], 
        filter_function: FilterFunctionType, 
        aggregate_function: AggregateFunctionType, 
        ) -> tuple[dict[str, dict[str, float]] | dict[str, float], list[DataFilter]]:
    
    super_chart_filter: DataFilter | None = None
    chart_filter: DataFilter = ...
    valid_filters: list[DataFilter] = []

    if next((_filter for _filter in filters if _filter.charting_mode == ChartingMode.CHART), None) is None:
        raise DescriptiveError(http_error_code=400, message="El modo de graficación de los filtros es no válido. No hay un filtro de tipo `chart`")

    for _filter in filters:
        possible_values = set(frame.index.get_level_values(level=_filter.level))
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
        
        match _filter.charting_mode:
            case ChartingMode.SUPER_CHART:
                super_chart_filter = valid_filter
            case ChartingMode.CHART:
                chart_filter = valid_filter
        
        valid_filters.append(valid_filter)
        frame = cross_section(
            data_frame=frame, 
            key=valid_filter.selected_values, 
            level=valid_filter.level
            )
    
    actual_filter_function = FilterFunctionType.function_from_member(member=filter_function)
    actual_aggregate_function = AggregateFunctionType.function_from_member(member=aggregate_function)

    def get_filter_data(data_frame: pandas.DataFrame, filters: list[DataFilter]):
        match filters:
            case []:
                series = flatten_to_series(obj=data_frame)
                series = series[series.apply(actual_filter_function)]
                value = actual_aggregate_function(value)
                return value
            case [_filter, *other_filters]:
                return {
                    value: get_filter_data(
                        data_frame=cross_section(data_frame=data_frame, key=value, level=_filter.level),
                        filters=other_filters
                        )
                    for value in _filter.possible_values
                }

    if super_chart_filter is not None:
        return get_filter_data(data_frame=frame, filters=[ super_chart_filter, chart_filter ]), valid_filters
    
    return get_filter_data(data_frame=frame, filters=[chart_filter]), valid_filters
