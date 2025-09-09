from lib.with_flask import with_flask
from lib.descriptive_error import DescriptiveError
from lib.get_entities_from_request import entities_for_editing_filter
from lib.pivot_table.recalculate import recalculate
from lib.pivot_table.bring_filter_up import bring_filter_up
from lib.pivot_table.plot_pivot_table import plot_from_entities

from models.response.edit_pivot_table_response import EditPivotTable_Response

from flask import request

import pandas

@with_flask("/remove", methods=["POST"])
def remove_option_from_filter():
    report, pivot_table, _filter, option = entities_for_editing_filter(request=request, get_option=True)
    
    if not option in _filter.selected_values:
        raise DescriptiveError(http_error_code=400, message=f"La opción a eliminar no está presente en el filtro.\n{option = }.\n{_filter.selected_values = }")
    
    _filter.selected_values.remove(option)
    pivot_table.filters_order = bring_filter_up(filters=pivot_table.filters_order, edited_filter=_filter.level)

    recalculate(report=report, pivot_table=pivot_table)

    pivot_table.last_edit = pandas.Timestamp.now()
    report.save()

    return EditPivotTable_Response(
        data=pivot_table.data,
        filters=pivot_table.filters,
        preview=pivot_table.preview
    ).to_dict(), 200
