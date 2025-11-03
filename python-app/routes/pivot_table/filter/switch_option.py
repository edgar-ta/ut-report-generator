from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_filter
from lib.pivot_table.recalculate import recalculate
from lib.pivot_table.bring_filter_up import bring_filter_up
from lib.report.save_slideshow import save_slideshow

from models.error.descriptive_error import DescriptiveError
from models.response.edit_pivot_table_response import EditPivotTable_Response
from models.pivot_table.data_filter.selection_mode import SelectionMode

from routes.route_map import DATA_FILTER

from flask import request

import pandas

@with_flask(DATA_FILTER.SWITCH_OPTION.value, methods=["POST"])
def switch_option_in_filter():
    root_directory, report, pivot_table, _filter, option = entities_for_editing_filter(request=request, get_option=True)

    if not option in _filter.possible_values:
        raise DescriptiveError(http_error_code=400, message="La opción seleccionada no es válida para el filtro")
    
    if not _filter.selection_mode == SelectionMode.ONE:
        raise DescriptiveError(http_error_code=400, message="Se intentó emplear la acción 'switch' en un filtro que de selección tipo 'MANY'")
    
    if _filter.selected_values[0] == option:
        # do not even care about recalculating if it's the same value
        return EditPivotTable_Response(
            data=pivot_table.data,
            filters=pivot_table.filters,
            preview=pivot_table.preview
        ).to_dict(), 200

    _filter.selected_values = [option]
    pivot_table.filters_order = bring_filter_up(filters=pivot_table.filters_order, edited_filter=_filter.level)

    recalculate(root_directory=root_directory, pivot_table=pivot_table)

    pivot_table.last_edit = pandas.Timestamp.now()
    save_slideshow(root_directory=root_directory, slideshow=report)

    return EditPivotTable_Response(
        data=pivot_table.data,
        filters=pivot_table.filters,
        preview=pivot_table.preview
    ).to_dict(), 200
