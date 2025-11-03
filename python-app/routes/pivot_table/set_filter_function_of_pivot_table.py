from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_pivot_table
from lib.get_or_panic import get_or_panic
from lib.pivot_table.recalculate import recalculate
from lib.report.save_slideshow import save_slideshow

from models.pivot_table.filter_function_type import FilterFunctionType
from models.response.edit_pivot_table_response import EditPivotTable_Response

from routes.route_map import PIVOT_TABLE

from flask import request
from pandas import Timestamp

@with_flask(PIVOT_TABLE.SET_FILTER.value, methods=["POST"])
def set_filter_function_of_pivot_table():
    root_directory, report, pivot_table = entities_for_editing_pivot_table(request=request)
    filter_function = get_or_panic(request.json, 'filter_function', 'La función de filtro no está presente en la solicitud')

    filter_function = FilterFunctionType(filter_function)
    if filter_function != pivot_table.filter_function:
        pivot_table.filter_function = filter_function
        recalculate(root_directory=root_directory, pivot_table=pivot_table)
        pivot_table.last_edit = Timestamp.now()
        save_slideshow(root_directory=root_directory, slideshow=report)

    return EditPivotTable_Response(
        data=pivot_table.data,
        filters=pivot_table.filters,
        preview=pivot_table.preview
    ).to_dict(), 200
