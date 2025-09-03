from lib.data_frame.cross_section import cross_section
from lib.unique_list import unique_list
from lib.pivot_table.get_combinable_filters import get_combinable_filters

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

    first_filter = DataFilter(
        level=PivotTableLevel.PROFESSOR,
        selected_values=[],
        possible_values=[],
        selection_mode=SelectionMode.ONE,
        charting_mode=ChartingMode.NONE,
        )

    second_filter = DataFilter(
        level=PivotTableLevel.SUBJECT,
        selected_values=[],
        possible_values=[],
        selection_mode=SelectionMode.ONE,
        charting_mode=ChartingMode.CHART
        )
    
    third_filter = DataFilter(
        level=PivotTableLevel.UNIT,
        selected_values=[],
        possible_values=[],
        selection_mode=SelectionMode.MANY,
        charting_mode=ChartingMode.NONE
        )

    return get_combinable_filters(data_frame=data_frame, filters=[first_filter, second_filter, third_filter])
