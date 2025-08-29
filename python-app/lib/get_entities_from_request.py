from lib.get_or_panic import get_or_panic

from models.report import Report
from models.pivot_table.self import PivotTable
from models.pivot_table.data_filter.self import DataFilter

import flask

def entities_for_editing_filter(request: flask.Request, get_option: bool = True) -> tuple[Report, PivotTable, DataFilter, str | None]:
    report: Report = get_or_panic(request.json, 'report', 'El identificador del reporte no está presente en la solicitud')
    pivot_table: PivotTable = get_or_panic(request.json, 'pivot_table', 'El identificador de la tabla dinámica no está presente en la solicitud')
    _filter: DataFilter = get_or_panic(request.json, 'filter', 'El identificador del filtro no está presente en la solicitud')

    report = Report.from_identifier(identifier=report)
    pivot_table = report[pivot_table]
    _filter = pivot_table.filters[_filter]

    if not get_option:
        return (report, pivot_table, _filter, None)

    option: str = get_or_panic(request.json, 'option', 'La opción a añadir no está presente en la solicitud')
    return (report, pivot_table, _filter, option)
