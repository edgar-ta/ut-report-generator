from lib.with_app_decorator import with_app
from lib.get_entities_from_request import entities_for_editing_filter
from lib.pivot_table.recalculate import recalculate
from lib.pivot_table.bring_filter_up import bring_filter_up

from models.pivot_table.data_filter.selection_mode import SelectionMode

from flask import request

import pandas

@with_app("/toggle_selection_mode", methods=["POST"])
def toggle_selection_mode_of_filter():
    report, pivot_table, _filter, _ = entities_for_editing_filter(request=request, get_option=False)

    do_recalculation = False

    if _filter.selection_mode == SelectionMode.MANY:
        do_recalculation = len(_filter.selected_values) > 1
        _filter.selection_mode = SelectionMode.ONE
        _filter.selected_values = [ _filter.selected_values[0] ]
    else:
        _filter.selection_mode = SelectionMode.MANY
    
    if do_recalculation:
        pivot_table.filters_order = bring_filter_up(filters=pivot_table.filters_order, edited_filter=_filter.level)
        recalculate(pivot_table=pivot_table)

    pivot_table.last_edit = pandas.Timestamp.now()
    report.save()

    return {
        "data": pivot_table.data,
        "filters": pivot_table.filters
    }, 200
