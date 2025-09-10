from lib.data_filter.is_valid_filter import is_valid_filter
from lib.descriptive_error import DescriptiveError
from lib.get_entities_from_request import entities_for_editing_filter
from lib.pivot_table.recalculate import recalculate
from lib.pivot_table.bring_filter_up import bring_filter_up
from lib.with_flask import with_flask

from models.pivot_table.data_filter.selection_mode import SelectionMode

from flask import request

import pandas

@with_flask("/toggle_selection_mode", methods=["POST"])
def toggle_selection_mode_of_filter():
    report, pivot_table, _filter, _ = entities_for_editing_filter(request=request, get_option=False)

    if not is_valid_filter(_filter=_filter):
        raise DescriptiveError(http_error_code=400, message="El filtro seleccionado es de tipo inválido (no tiene valores posibles)")

    do_recalculation = _filter.selection_mode == SelectionMode.MANY and _filter.selected_values.__len__() > 1

    if _filter.selection_mode == SelectionMode.MANY:
        _filter.selection_mode = SelectionMode.ONE
        _filter.selected_values = [ _filter.selected_values[0] ] if _filter.selected_values.__len__() > 0 else []
    else:
        _filter.selection_mode = SelectionMode.MANY
    
    if do_recalculation:
        pivot_table.filters_order = bring_filter_up(filters=pivot_table.filters_order, edited_filter=_filter.level)
        recalculate(report=report, pivot_table=pivot_table)

    pivot_table.last_edit = pandas.Timestamp.now()
    report.save()

    if do_recalculation:
        return {
            "recalculated": do_recalculation,
            "data": pivot_table.data,
            "filters": [ _filter.to_dict() for _filter in pivot_table.filters ]
        }, 200
    else:
        return { "recalculated": False, }, 200
