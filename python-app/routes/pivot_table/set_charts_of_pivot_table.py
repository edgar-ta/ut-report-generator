from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_pivot_table
from lib.pivot_table.recalculate import recalculate
from lib.report.save_slideshow import save_slideshow

from models.pivot_table.data_filter.charting_mode import ChartingMode
from models.error.descriptive_error import DescriptiveError

from flask import request

import os
import pandas

@with_flask("/set_charts", methods=["POST"])
def set_charts_of_pivot_table():
    report, pivot_table = entities_for_editing_pivot_table(request=request)
    root_directory = report.root_directory
    chart_index = request.json['chart']
    super_chart_index = request.json['super_chart']

    if chart_index is None and super_chart_index is None:
        raise DescriptiveError(http_error_code=400, message="No se pasó ningún índice para editar el gráfico o super gráfico de la tabla dinámica")

    if chart_index == super_chart_index:
        raise DescriptiveError(http_error_code=400, message="Se intentó hacer que un mismo filtro sea gráfico y súper gráfico a la vez. Solo se puede uno solo")
    
    if chart_index is not None and chart_index < 0:
        raise DescriptiveError(http_error_code=400, message=f"Se intentó eliminar el gráfico de tipo `CHART` pasando {chart_index = }")

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

    recalculate(root_directory=root_directory, pivot_table=pivot_table)

    pivot_table.last_edit = pandas.Timestamp.now()
    save_slideshow(slideshow=report, root_directory=root_directory)

    return pivot_table.data, 200
