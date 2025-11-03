from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_filter
from lib.pivot_table.recalculate import recalculate
from lib.report.save_slideshow import save_slideshow

from models.error.descriptive_error import DescriptiveError
from models.response.edit_pivot_table_response import EditPivotTable_Response
from models.pivot_table.data_filter.charting_mode import ChartingMode

from routes.route_map import DATA_FILTER

from flask import request

import pandas

@with_flask(DATA_FILTER.DELETE.value, methods=["POST"])
def delete_filter():
    root_directory, report, pivot_table, data_filter, _ = entities_for_editing_filter(request=request, get_option=False)

    if len(pivot_table.filters) == 1:
        raise DescriptiveError(http_error_code=400, message="Se intentó borrar el último filtro de un reporte")
    
    pivot_table.filters.remove(data_filter)
    pivot_table.filters_order = [ level for level in pivot_table.filters_order if level != data_filter.level ]
    if data_filter.charting_mode == ChartingMode.CHART:
        new_chart = next((_data_filter for _data_filter in pivot_table.filters if _data_filter.charting_mode == ChartingMode.NONE), None)
        if new_chart is None:
            new_chart = pivot_table.filters[0]
        new_chart.charting_mode = ChartingMode.CHART

    recalculate(root_directory=root_directory, pivot_table=pivot_table)

    pivot_table.last_edit = pandas.Timestamp.now()
    save_slideshow(root_directory=root_directory, slideshow=report)

    return EditPivotTable_Response(
        data=pivot_table.data,
        filters=pivot_table.filters,
        preview=pivot_table.preview
    ).to_dict(), 200
