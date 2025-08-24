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

def lenient_cross_section(data_frame: pandas.DataFrame, key: list[str], level: str) -> pandas.DataFrame:
    try:
        return cross_section(data_frame=data_frame, key=key, level=level)
    except KeyError as e:
        print(e)
        new_frame = pandas.DataFrame(index=data_frame.index)
        return new_frame

def get_data_of_frame(
        frame: pandas.DataFrame, 
        indexers: list[CustomIndexer], 
        filter_function: FilterFunctionType, 
        aggregate_function: AggregateFunctionType, 
        nesting_level=2
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
                return 0
        case [indexer, *other_indexers]:
            indexer, *other_indexers = indexers

            if len(other_indexers) >= nesting_level:
                return get_data_of_frame(
                    frame=lenient_cross_section(data_frame=frame, key=indexer.values[0], level=indexer.level.value), 
                    indexers=other_indexers, 
                    filter_function=filter_function,
                    aggregate_function=aggregate_function,
                    nesting_level=nesting_level
                    )

            return {
                value: get_data_of_frame(
                    frame=lenient_cross_section(data_frame=frame, key=value, level=indexer.level.value), 
                    indexers=other_indexers, 
                    filter_function=filter_function,
                    aggregate_function=aggregate_function,
                    nesting_level=nesting_level
                    )
                for value in indexer.values
            }
