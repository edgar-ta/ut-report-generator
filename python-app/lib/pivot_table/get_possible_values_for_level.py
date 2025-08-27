from lib.data_frame.cross_section import lenient_cross_section

from models.pivot_table.data_filter.self import DataFilter
from models.pivot_table.pivot_table_level import PivotTableLevel

from functools import reduce

import pandas

def get_possible_values_for_level(data_frame: pandas.DataFrame, filters: list[DataFilter], level: PivotTableLevel) -> set[str]:
    match filters:
        case [ ]:
            return set(data_frame.index.get_level_values(level=level.name))
        case [ _filter, *other_filters ]:
            return reduce(
                lambda first, second: first & second,
                (get_possible_values_for_level(
                    data_frame=lenient_cross_section(data_frame=data_frame, key=value, level=level.name),
                    filters=other_filters,
                    level=level
                    )
                for value in _filter.selected_values
                ))
