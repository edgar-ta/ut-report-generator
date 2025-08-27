from lib.data_frame.cross_section import cross_section
from lib.unique_list import unique_list

from models.pivot_table.data_filter.self import DataFilter
from models.pivot_table.data_filter.selection_mode import SelectionMode
from models.pivot_table.data_filter.charting_mode import ChartingMode
from models.pivot_table.pivot_table_level import PivotTableLevel

import pandas as pd

# @todo I could definitely engineer something prettier than this
def create_default_filters(data_frame: pd.DataFrame) -> list[DataFilter]:
    '''
    Creates a list of valid default filters for the frame. It uses
    professor, subject and unit
    '''
    first_filter_possible_values = unique_list(data_frame.index.get_level_values(level=PivotTableLevel.PROFESSOR.value))
    first_filter = DataFilter(
        level=PivotTableLevel.PROFESSOR,
        selected_values=[first_filter_possible_values[0]],
        possible_values=first_filter_possible_values,
        selection_mode=SelectionMode.ONE,
        charting_mode=ChartingMode.NONE,
        )
    data_frame = cross_section(data_frame=data_frame, key=first_filter_possible_values[0], level=PivotTableLevel.PROFESSOR.value)

    second_filter_possible_values = unique_list(data_frame.index.get_level_values(level=PivotTableLevel.SUBJECT.value))
    second_filter = DataFilter(
        level=PivotTableLevel.SUBJECT,
        selected_values=[second_filter_possible_values[0]],
        possible_values=second_filter_possible_values,
        selection_mode=SelectionMode.ONE,
        charting_mode=ChartingMode.CHART
        )
    data_frame = cross_section(data_frame=data_frame, key=second_filter_possible_values[0], level=PivotTableLevel.SUBJECT.value)
    
    third_filter_possible_values = unique_list(data_frame.index.get_level_values(level=PivotTableLevel.UNIT.value))
    third_filter = DataFilter(
        level=PivotTableLevel.UNIT,
        selected_values=[],
        possible_values=third_filter_possible_values,
        selection_mode=SelectionMode.MANY,
        charting_mode=ChartingMode.NONE
        )
    
    return [ first_filter, second_filter, third_filter ]
