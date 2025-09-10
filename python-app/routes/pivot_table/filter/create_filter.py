from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_pivot_table
from lib.get_or_panic import get_or_panic
from lib.descriptive_error import DescriptiveError
from lib.pivot_table.recalculate import recalculate
from lib.pivot_table.ordered_filters import find_filter
from lib.pivot_table.get_combinable_filters import get_combinable_filters
from lib.pivot_table.plot_pivot_table import plot_from_entities
from lib.pivot_table.recalculate import recalculate
from lib.data_frame.data_frame_io import import_data_frame

from models.pivot_table.pivot_table_level import PivotTableLevel
from models.pivot_table.data_filter.self import DataFilter
from models.pivot_table.data_filter.selection_mode import SelectionMode
from models.pivot_table.data_filter.charting_mode import ChartingMode

from flask import request

import pandas

@with_flask("/create", methods=["POST"])
def create_filter():
    report, pivot_table = entities_for_editing_pivot_table(request=request)

    level: PivotTableLevel = get_or_panic(request.json, 'level', 'No se incluyó el nivel del nuevo filtro en la request')
    try:
        level = PivotTableLevel(level)
    except:
        raise DescriptiveError(http_error_code=400, message=f"El valor de nivel pasado no es válido. Se usó {level = }")
    
    if level in (filters := [ _filter.level for _filter in pivot_table.filters ]):
        raise DescriptiveError(http_error_code=400, message=f"El filtro solicitado ya existe en la tabla dinámica. {filters = }")
    
    raw_filter = DataFilter(
        level=level,
        selected_values=[],
        possible_values=[],
        # This has to match the default mode in the fronted
        # to improve UI consistency
        selection_mode=SelectionMode.MANY,
        charting_mode=ChartingMode.NONE
        )
    
    pivot_table.filters.append(raw_filter)
    pivot_table.filters_order.append(level)

    data_frame = import_data_frame(file_path=pivot_table.source.merged_file, key=pivot_table.identifier)
    refined_filters = get_combinable_filters(data_frame=data_frame, filters=pivot_table.filters)
    refined_filter = find_filter(level=level, filters=refined_filters)

    pivot_table.filters = refined_filters
    recalculate(report=report, pivot_table=pivot_table)

    pivot_table.last_edit = pandas.Timestamp.now()
    report.save()
    
    return refined_filter.to_dict(), 200
