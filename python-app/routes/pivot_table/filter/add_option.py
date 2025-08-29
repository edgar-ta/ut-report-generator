from lib.with_app_decorator import with_app
from lib.get_entities_from_request import entities_for_editing_filter
from lib.descriptive_error import DescriptiveError
from lib.pivot_table.recalculate import recalculate
from lib.pivot_table.bring_filter_up import bring_filter_up

from flask import request

import pandas

@with_app("/add", methods=["POST"])
def add_option_to_filter():
    report, pivot_table, _filter, option = entities_for_editing_filter(request=request, get_option=True)

    if not option in _filter.possible_values:
        raise DescriptiveError(http_error_code=400, message="La opción seleccionada no es válida para el filtro")
    
    _filter.selected_values.append(option)
    pivot_table.filters_order = bring_filter_up(filters=pivot_table.filters_order, edited_filter=_filter.level)

    new_data, new_filters = recalculate(pivot_table=pivot_table)

    pivot_table.last_edit = pandas.Timestamp.now()
    report.save()

    return {
        "data": new_data,
        "filters": new_filters
    }, 200
