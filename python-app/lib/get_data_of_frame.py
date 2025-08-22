from lib.cross_section import cross_section

from models.pivot_table.custom_indexer import CustomIndexer
from models.pivot_table.filter_function_type import FilterFunctionType
from models.pivot_table.aggregate_function_type import AggregateFunctionType

import pandas

def flatten_to_series(obj: pandas.DataFrame | pandas.Series) -> pandas.Series:
    if isinstance(obj, pandas.DataFrame):
        return pandas.Series(obj.values.flatten())
    elif isinstance(obj, pandas.Series):
        return obj.copy()
    else:
        raise TypeError("Expected a pandas DataFrame or Series")

def get_data_of_frame(
        frame: pandas.DataFrame, 
        indexers: list[CustomIndexer], 
        filter_function: FilterFunctionType, 
        aggregate_function: AggregateFunctionType, 
        error_value: float
        ):
    match indexers:
        case []:
            try:
                value = flatten_to_series(obj=frame)
                actual_filter_function = FilterFunctionType.function_from_member(member=filter_function)
                actual_aggregate_function = AggregateFunctionType.function_from_member(member=aggregate_function)

                value = value[value.apply(actual_filter_function)]
                value = actual_aggregate_function(value)
                
                return value
            except Exception as error:
                print(error)
                return error_value
        case [indexer, *other_indexers]:
            indexer, *other_indexers = indexers

            return {
                value: get_data_of_frame(
                    frame=cross_section(data_frame=frame, key=value, level=indexer.level), 
                    indexers=other_indexers, 
                    filter_function=filter_function,
                    aggregate_function=aggregate_function,
                    error_value=error_value
                    )
                for value in indexer.values
            }