from lib.data_frame.cross_section import cross_section
from lib.data_frame.flatten_to_series import flatten_to_series
from lib.data_filter.get_valid_values import get_valid_values
from lib.descriptive_error import DescriptiveError

from models.pivot_table.data_filter.self import DataFilter
from models.pivot_table.data_filter.charting_mode import ChartingMode
from models.pivot_table.filter_function_type import FilterFunctionType
from models.pivot_table.aggregate_function_type import AggregateFunctionType

from typing import Callable

import pandas

def get_dict_of_frame(data_frame: pandas.DataFrame, filters: list[DataFilter], filter_function: Callable[[float], bool], aggregate_function: Callable[[pandas.Series], float]) -> dict:
    '''
    Gets the data asked for by the filters in the form of a dict

    The filters should all be valid and combinable with respect to the data_frame
    '''
    match filters:
        case []:
            series = flatten_to_series(obj=data_frame)
            series = series[series.apply(filter_function)]
            value = aggregate_function(series)
            return value
        case [_filter, *other_filters]:
            return {
                value: get_dict_of_frame(
                    data_frame=cross_section(data_frame=data_frame, key=value, level=_filter.level.value),
                    filters=other_filters,
                    filter_function=filter_function,
                    aggregate_function=aggregate_function
                    )
                for value in get_valid_values(_filter=_filter)
            }


def get_data_of_frame(
        data_frame: pandas.DataFrame, 
        filters: list[DataFilter], 
        filter_function: FilterFunctionType, 
        aggregate_function: AggregateFunctionType, 
        ) -> dict[str, dict[str, float]] | dict[str, float]:
    '''
    Gets the dict that represents with the data that the filters
    intend to create a chart of

    Chart and (if existent) super chart filters should be
    valid and mutually combinable with respect to the data frame
    '''
    
    super_chart_filter: DataFilter | None = None
    chart_filter: DataFilter = ...

    for _filter in filters:
        match _filter.charting_mode:
            case ChartingMode.CHART:
                chart_filter = _filter
            case ChartingMode.SUPER_CHART:
                super_chart_filter = _filter
            case ChartingMode.NONE:
                data_frame = cross_section(
                    data_frame=data_frame, 
                    key=_filter.selected_values, 
                    level=_filter.level.value
                    )

    actual_filter_function = FilterFunctionType.function_from_member(member=filter_function)
    actual_aggregate_function = AggregateFunctionType.function_from_member(member=aggregate_function)

    return get_dict_of_frame(
        data_frame=data_frame, 
        filters=list(filter(lambda value: value is not None, [super_chart_filter, chart_filter])),
        filter_function=actual_filter_function,
        aggregate_function=actual_aggregate_function
        )
