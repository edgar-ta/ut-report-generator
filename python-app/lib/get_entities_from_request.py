from lib.get_or_panic import get_or_panic
from lib.report.construct import from_identifier

from models.error.descriptive_error import DescriptiveError
from models.report.self import Report
from models.pivot_table.self import PivotTable
from models.pivot_table.data_filter.self import DataFilter
from models.image_slide.self import ImageSlide
from models.slide.self import Slide

import flask

def entities_for_editing_report(request: flask.Request) -> tuple[str, Report]:
    report: Report = get_or_panic(request.json, 'report', 'El identificador del reporte no está presente en la solicitud')
    return from_identifier(identifier=report)

def entities_for_editing_slide(request: flask.Request) -> tuple[str, Report, Slide]:
    root_directory, report = entities_for_editing_report(request=request)

    slide = get_or_panic(request.json, 'slide', 'El identificador de la diapositiva no está presente en la solicitud')
    slide = report[slide]
    
    return (root_directory, report, slide)

def entities_for_editing_pivot_table(request: flask.Request) -> tuple[str, Report, PivotTable]:
    root_directory, report = entities_for_editing_report(request=request)

    pivot_table = get_or_panic(request.json, 'pivot_table', 'El identificador de la tabla dinámica no está presente en la solicitud')
    pivot_table = report[pivot_table]
    if not isinstance(pivot_table, PivotTable):
        raise DescriptiveError(http_error_code=400, message="La id solicitada no pertenece a una diapositiva de tipo tabla dinámica")

    return (root_directory, report, pivot_table)

def entities_for_editing_filter(request: flask.Request, get_option: bool = True) -> tuple[str, Report, PivotTable, DataFilter, str | None]:
    root_directory, report, pivot_table = entities_for_editing_pivot_table(request=request)
    _filter: DataFilter = get_or_panic(request.json, 'filter', 'El identificador del filtro no está presente en la solicitud')

    if _filter >= pivot_table.filters.__len__():
        raise DescriptiveError(http_error_code=400, message=f"El filtro indicado no existe. Se usó {_filter = }, pero {pivot_table.filters.__len__() = }")

    _filter = pivot_table.filters[_filter]

    if not get_option:
        return (report, pivot_table, _filter, None)

    option: str = get_or_panic(request.json, 'option', 'La opción a añadir no está presente en la solicitud')
    return (root_directory, report, pivot_table, _filter, option)

def entities_for_editing_image_slide(request: flask.Request) -> tuple[str, Report, ImageSlide]:
    root_directory, report = entities_for_editing_report(request=request)

    image_slide = get_or_panic(request.json, 'image_slide', 'El identificador de la diapositiva de imagen no está presente en la solicitud')
    image_slide: ImageSlide = report[image_slide]
    if not isinstance(image_slide, ImageSlide):
        raise DescriptiveError(http_error_code=400, message="La id solicitada no pertenece a una diapositiva de tipo imagen")

    return (root_directory, report, image_slide)
