from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_filter
from lib.pivot_table.recalculate import recalculate
from lib.report.save_slideshow import save_slideshow

from models.error.descriptive_error import DescriptiveError
from models.response.edit_pivot_table_response import EditPivotTable_Response

from flask import request

import pandas

@with_flask("/delete", methods=["POST"])
def delete_filter():
    root_directory, report, pivot_table, _filter, _ = entities_for_editing_filter(request=request, get_option=False)

    if len(pivot_table.filters) == 1:
        raise DescriptiveError(http_error_code=400, message="Se intentó borrar el último filtro de un reporte")
    
    pivot_table.filters.remove(_filter)
    pivot_table.filters_order = [ level for level in pivot_table.filters_order if level != _filter.level ]

    recalculate(root_directory=root_directory, pivot_table=pivot_table)

    pivot_table.last_edit = pandas.Timestamp.now()
    save_slideshow(root_directory=root_directory, slideshow=report)

    return EditPivotTable_Response(
        data=pivot_table.data,
        filters=pivot_table.filters,
        preview=pivot_table.preview
    ).to_dict(), 200
