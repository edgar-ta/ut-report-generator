from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_filter
from lib.descriptive_error import DescriptiveError
from lib.pivot_table.recalculate import recalculate
from lib.pivot_table.bring_filter_up import bring_filter_up

from models.response.edit_pivot_table_response import EditPivotTable_Response
from models.pivot_table.data_filter.selection_mode import SelectionMode

from flask import request

import pandas

@with_flask("/add", methods=["POST"])
def add_option_to_filter():
    report, pivot_table, _filter, option = entities_for_editing_filter(request=request, get_option=True)

    if _filter.selection_mode != SelectionMode.MANY:
        raise DescriptiveError(http_error_code=400, message="Se intentó añadir una opción a un filtro de tipo 'ONE'")

    if not option in _filter.possible_values:
        raise DescriptiveError(http_error_code=400, message="La opción seleccionada no es válida para el filtro")
    
    if option in _filter.selected_values:
        raise DescriptiveError(http_error_code=400, message=f"La opción seleccionada ya fue añadida al filtro.\n{option = }.\n{_filter.selected_values = }")

    _filter.selected_values.append(option)
    
    pivot_table.filters_order = bring_filter_up(filters=pivot_table.filters_order, edited_filter=_filter.level)

    recalculate(pivot_table=pivot_table)

    pivot_table.last_edit = pandas.Timestamp.now()
    report.save()

    return EditPivotTable_Response(
        data=pivot_table.data,
        filters=pivot_table.filters
    ).to_dict(), 200
