from models.pivot_table.cross_section import cross_section

import pandas

def get_data_of_frame(frame: pandas.DataFrame, indexers: list, filter_function, aggregate_function, error_value: float):
    match indexers:
        case []:
            try:
                value = frame.iloc[0, :]
                value = value[value.apply(filter_function)]
                value = aggregate_function(value)
                
                return value
            except:
                return error_value
        case [indexer, *other_indexers]:
            indexer, *other_indexers = indexers
            level, values = indexer

            return {
                value: get_data_of_frame(
                    frame=cross_section(data_frame=frame, key=value, level=level), 
                    indexers=other_indexers, 
                    filter_function=filter_function,
                    aggregate_function=aggregate_function,
                    error_value=error_value
                    )
                for value in values
            }