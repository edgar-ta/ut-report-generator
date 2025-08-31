from lib.with_app_decorator import with_app
from lib.descriptive_error import DescriptiveError
from lib.get_entities_from_request import entities_for_editing_filter
from lib.pivot_table.recalculate import recalculate

from models.responses.edit_pivot_table_response import EditPivotTable_Response

from flask import request

import pandas

@with_app("/delete", methods=["POST"])
def delete_filter():
    report, pivot_table, _filter, _ = entities_for_editing_filter(request=request, get_option=False)

    if len(pivot_table.filters) == 1:
        raise DescriptiveError(http_error_code=400, message="Se intentó borrar el último filtro de un reporte")
    
    pivot_table.filters.remove(_filter)
    pivot_table.filters_order = [ level for level in pivot_table.filters_order if level != _filter.level ]

    new_data, new_filters = recalculate(pivot_table=pivot_table)

    pivot_table.last_edit = pandas.Timestamp.now()
    report.save()

    return EditPivotTable_Response(
        data=new_data,
        filters=new_filters
    ).to_dict(), 200
