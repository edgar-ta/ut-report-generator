from lib.with_app_decorator import with_app
from lib.get_entities_from_request import entities_for_editing_pivot_table
from lib.descriptive_error import DescriptiveError
from lib.pivot_table.recalculate import recalculate

from models.pivot_table.data_filter.charting_mode import ChartingMode

from flask import request

import os
import pandas

@with_app("/set_charts", methods=["POST"])
def set_charts_of_pivot_table():
    report, pivot_table = entities_for_editing_pivot_table(request=request)
    chart_index = request.json['chart']
    super_chart_index = request.json['super_chart']

    if chart_index is None and super_chart_index is None:
        raise DescriptiveError(http_error_code=400, message="No se pasó ningún índice para editar el gráfico o super gráfico de la tabla dinámica")

    if chart_index == super_chart_index:
        raise DescriptiveError(http_error_code=400, message="Se intentó hacer que un mismo filtro sea gráfico y súper gráfico a la vez. Solo se puede uno solo")

    if chart_index is not None:
        for index, _filter in enumerate(pivot_table.filters):
            if index == chart_index:
                _filter.charting_mode = ChartingMode.CHART
                continue
            
            if _filter.charting_mode == ChartingMode.SUPER_CHART:
                continue

            _filter.charting_mode = ChartingMode.NONE
    
    if super_chart_index is not None:
        for index, _filter in enumerate(pivot_table.filters):
            if index == super_chart_index:
                _filter.charting_mode = ChartingMode.SUPER_CHART
                continue

            if _filter.charting_mode == ChartingMode.CHART:
                continue

            _filter.charting_mode = ChartingMode.NONE

    recalculate(pivot_table=pivot_table)

    pivot_table.last_edit = pandas.Timestamp.now()
    report.save()

    return pivot_table.data, 200
