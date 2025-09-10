from models.pivot_table.data_filter.charting_mode import ChartingMode

from lib.with_flask import with_flask
from lib.get_entities_from_request import entities_for_editing_pivot_table
from lib.pivot_table.plot_pivot_table import plot_from_components
from lib.directory_definitions import preview_image_of_slide

from flask import request

import os

@with_flask("/render", methods=["POST"])
def render_pivot_table():
    report, pivot_table = entities_for_editing_pivot_table(request=request)
    outer_chart = next((_filter for _filter in pivot_table.filters if _filter.charting_mode == ChartingMode.SUPER_CHART), None)
    if outer_chart is None:
        outer_chart = next((_filter for _filter in pivot_table.filters if _filter.charting_mode == ChartingMode.CHART), None)

    filepath = preview_image_of_slide(root_directory=report.root_directory, slide_id=pivot_table.identifier)

    plot_from_components(
        data=pivot_table.data, 
        title=pivot_table.name, 
        outer_chart=outer_chart, 
        _filter=pivot_table.filter_function, 
        aggregate=pivot_table.aggregate_function, 
        filepath=filepath, 
        former_preview=pivot_table.preview
        )
    pivot_table.preview = filepath

    report.save()
    
    return {
        "preview": filepath
    }
