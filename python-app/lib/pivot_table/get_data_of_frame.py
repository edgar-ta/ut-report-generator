from lib.data_frame.cross_section import cross_section
from lib.data_frame.flatten_to_series import flatten_to_series
from lib.data_filter.get_valid_values import get_valid_values

from models.pivot_table.data_filter.self import DataFilter
from models.pivot_table.data_filter.charting_mode import ChartingMode
from models.pivot_table.filter_function_type import FilterFunctionType
from models.pivot_table.aggregate_function_type import AggregateFunctionType
from models.pivot_table.pivot_table_data import PivotTableData, PivotTableRod, PivotTableRodGroup, ColorType

from typing import Callable
from matplotlib import colors as mcolors

import pandas

def get_pivot_table_rods(
        data_frame: pandas.DataFrame, 
        charting_filter: DataFilter,
        filter_function: FilterFunctionType, 
        aggregate_function: Callable[[pandas.Series], float],
        color_generator: Callable[[int, int], ColorType]
        ) -> list[PivotTableRod]:
    
    results = []
    valid_values = get_valid_values(charting_filter)
    for index, key in enumerate(valid_values):
        local_data_frame = cross_section(
            data_frame=data_frame, 
            key=key, 
            level=charting_filter.level.value
            )
        series = flatten_to_series(obj=local_data_frame)
        professor_didnt_upload = (series == 0).all()
        if professor_didnt_upload:
            color = color_generator(len(valid_values), index)
            result = PivotTableRod(
                key=key,
                value=0,
                color=color,
                index=index,
                missing=True
            )
            results.append(result)
            continue
        
        series = series[series.apply(filter_function)]
        value = aggregate_function(series)
        color = color_generator(len(valid_values), index)

        result = PivotTableRod(
            key=key,
            value=value,
            color=color,
            missing=False
        )
        results.append(result)
    return results

def get_pivot_table_rod_groups(
        data_frame: pandas.DataFrame, 
        super_charting_filter: DataFilter,
        charting_filter: DataFilter,
        filter_function: FilterFunctionType, 
        aggregate_function: Callable[[pandas.Series], float],
        color_generator: Callable[[int, int], ColorType]
        ) -> list[PivotTableRodGroup]:
    results = []
    valid_values = get_valid_values(super_charting_filter)
    for index, key in enumerate(valid_values):
        local_data_frame = cross_section(
            data_frame=data_frame, 
            key=key, 
            level=charting_filter.level.value
            )
        pivot_table_rods = get_pivot_table_rods(
            data_frame=local_data_frame,
            charting_filter=charting_filter,
            filter_function=filter_function,
            aggregate_function=aggregate_function,
            color_generator=color_generator
            )
        pivot_table_rod_group = PivotTableRodGroup(
            key=key,
            rods=pivot_table_rods,
            index=index,
            )
        results.append(pivot_table_rod_group)
    return results

def _color_generator(total_colors: int, index: int) -> ColorType:
    values = [ str(round(value * 255)) for value in mcolors.hsv_to_rgb([index / total_colors, 1.0, 1.0]) ]
    return f'{','.join(values)}'

def get_data_of_frame(
        data_frame: pandas.DataFrame, 
        filters: list[DataFilter], 
        filter_function: FilterFunctionType, 
        aggregate_function: AggregateFunctionType, 
        ) -> PivotTableData:
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

    if super_chart_filter is not None:
        return get_pivot_table_rod_groups(
            data_frame=data_frame,
            super_charting_filter=super_chart_filter,
            charting_filter=chart_filter,
            filter_function=actual_filter_function,
            aggregate_function=actual_aggregate_function,
            color_generator=_color_generator
        )
    
    return get_pivot_table_rods(
        data_frame=data_frame,
        charting_filter=chart_filter,
        filter_function=actual_filter_function,
        aggregate_function=actual_aggregate_function,
        color_generator=_color_generator
    )
