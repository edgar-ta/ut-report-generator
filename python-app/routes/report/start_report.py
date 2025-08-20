from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.descriptive_error import DescriptiveError

from models.report.self import Report
from models.slide import Slide
from models.pivot_table.self import PivotTable
from models.pivot_table.slide_category import SlideCategory
from models.pivot_table.add_pivot_table_to_report import add_pivot_table_to_report

from flask import request

def format_response(response: Report | Slide | PivotTable) -> dict:
    print(__file__)
    print("@format_response")
    print("Hello 0")

    if type(response) == Report:
        print(f"report = {response}")
        return {
            "identifier": response.identifier,
            "report_name": response.report_name,
            "creation_date": response.creation_date,
            "last_edit": response.last_edit,
            "last_open": response.last_open,
            "slides": [ format_response(response=slide) for slide in response.slides ]
        }
    if type(response) == Slide:
        print(f"slide = {response}")
        return {
            "identifier": response.identifier,
            "name": response.name
        }
    if type(response) == PivotTable:
        print(f"pivot_table = {response}")
        return response.to_dict()

def add_image_slide_to_report():
    raise DescriptiveError(message="Esta funciión aun no ha sido implementada", http_error_code=500)


@with_app("/start_report", methods=["POST"])
def start_report():
    initial_slide = get_or_panic(request.json, 'initial_slide', 'El tipo de diapositiva inicial no está presente')
    try:
        initial_slide: SlideCategory = getattr(SlideCategory, initial_slide)
    except:
        raise DescriptiveError(http_error_code=400, message=f"El tipo de diapositiva '{initial_slide}' no es válido")

    report = Report.from_nothing()
    report.makedirs()

    match initial_slide:
        case SlideCategory.PIVOT_TABLE:
            add_pivot_table_to_report(report=report, local_request=request, index=None)
        case SlideCategory.IMAGE:
            add_image_slide_to_report(report=report, local_request=request)

    # slide = Slide.from_data_files(
    #     base_directory=report.root_directory, 
    #     files=data_files
    # )
    # slide.makedirs()

    # slide.build_new_assets()
    # slide.build_new_preview()

    # report.add_slide(slide)
    print(__file__)
    print("@start_report")
    print("Hello 1")

    report.save()
    response = format_response(response=report)

    return response, 200
