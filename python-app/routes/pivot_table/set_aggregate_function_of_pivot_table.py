from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_pivot_table
from lib.get_or_panic import get_or_panic
from lib.pivot_table.recalculate import recalculate
from lib.report.save_slideshow import save_slideshow

from models.pivot_table.aggregate_function_type import AggregateFunctionType
from models.response.edit_pivot_table_response import EditPivotTable_Response

from routes.route_map import PIVOT_TABLE

from flask import request
from pandas import Timestamp

@with_flask(PIVOT_TABLE.SET_AGGREGATE.value, methods=["POST"])
def set_aggregate_function_of_pivot_table():
    root_directory, report, pivot_table = entities_for_editing_pivot_table(request=request)
    aggregate_function = get_or_panic(request.json, 'aggregate_function', 'La función de agregación no está presente en la solicitud')

    aggregate_function = AggregateFunctionType(aggregate_function)

    if aggregate_function != pivot_table.aggregate_function:
        pivot_table.aggregate_function = aggregate_function
        recalculate(root_directory=root_directory, pivot_table=pivot_table)
        pivot_table.last_edit = Timestamp.now()
        save_slideshow(slideshow=report, root_directory=root_directory)

    return EditPivotTable_Response(
        data=pivot_table.data,
        filters=pivot_table.filters,
        preview=pivot_table.preview
    ).to_dict(), 200
