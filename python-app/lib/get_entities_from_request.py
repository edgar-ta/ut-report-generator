from lib.get_or_panic import get_or_panic
from lib.descriptive_error import DescriptiveError

from models.report.self import Report
from models.pivot_table.self import PivotTable
from models.pivot_table.data_filter.self import DataFilter
from models.image_slide.self import ImageSlide

import flask

def entities_for_editing_report(request: flask.Request) -> Report:
    report: Report = get_or_panic(request.json, 'report', 'El identificador del reporte no está presente en la solicitud')
    report = Report.from_identifier(identifier=report)
    return report

def entities_for_editing_pivot_table(request: flask.Request) -> tuple[Report, PivotTable]:
    report: Report = get_or_panic(request.json, 'report', 'El identificador del reporte no está presente en la solicitud')
    pivot_table: PivotTable = get_or_panic(request.json, 'pivot_table', 'El identificador de la tabla dinámica no está presente en la solicitud')

    report = Report.from_identifier(identifier=report)
    pivot_table = report[pivot_table]

    return (report, pivot_table)

def entities_for_editing_filter(request: flask.Request, get_option: bool = True) -> tuple[Report, PivotTable, DataFilter, str | None]:
    report, pivot_table = entities_for_editing_pivot_table(request=request)
    _filter: DataFilter = get_or_panic(request.json, 'filter', 'El identificador del filtro no está presente en la solicitud')

    if _filter >= pivot_table.filters.__len__():
        raise DescriptiveError(http_error_code=400, message=f"El filtro indicado no existe. Se usó {_filter = }, pero {pivot_table.filters.__len__() = }")

    _filter = pivot_table.filters[_filter]

    if not get_option:
        return (report, pivot_table, _filter, None)

    option: str = get_or_panic(request.json, 'option', 'La opción a añadir no está presente en la solicitud')
    return (report, pivot_table, _filter, option)

def entities_for_editing_image_slide(request: flask.Request) -> tuple[Report, ImageSlide]:
    report: Report = get_or_panic(request.json, 'report', 'El identificador del reporte no está presente en la solicitud')
    image_slide: ImageSlide = get_or_panic(request.json, 'image_slide', 'El identificador de la diapositiva de imagen no está presente en la solicitud')

    report = Report.from_identifier(identifier=report)
    image_slide = report[image_slide]

    return (report, image_slide)
