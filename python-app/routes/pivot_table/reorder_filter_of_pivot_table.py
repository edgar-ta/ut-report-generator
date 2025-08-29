from lib.with_app_decorator import with_app
from lib.get_entities_from_request import entities_for_editing_pivot_table
from lib.get_or_panic import get_or_panic

from flask import request

import pandas

@with_app("/reorder_filter", methods=["POST"])
def reorder_filter_of_pivot_table():
    report, pivot_table = entities_for_editing_pivot_table(request=request)
    old_index = get_or_panic(request.json, 'old_index', 'No se incluyó el antiguo índice del filtro a reordenar')
    new_index = get_or_panic(request.json, 'new_index', 'No se incluyó el nuevo índice del filtro a reordenar')

    if new_index > old_index:
        new_index -= 1
    
    _filter = pivot_table.filters[old_index]
    del pivot_table.filters[old_index]
    pivot_table.filters.insert(new_index, _filter)

    pivot_table.last_edit = pandas.Timestamp.now()
    report.save()

    return {
        "message": "Se reordenó el filtro correctamente"
    }, 200

