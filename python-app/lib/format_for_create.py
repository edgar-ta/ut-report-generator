from models.report import Report
from models.image_slide.self import ImageSlide
from models.pivot_table.self import PivotTable

def format_for_create(response: Report | ImageSlide | PivotTable) -> dict:
    if type(response) == Report:
        return {
            "identifier": response.identifier,
            "report_name": response.report_name,
            "creation_date": response.creation_date,
            "last_edit": response.last_edit,
            "last_open": response.last_open,
            "slides": [ format_for_create(response=slide) for slide in response.slides ]
        }
    
    if type(response) == ImageSlide:
        return response.to_dict()
    
    if type(response) == PivotTable:
        return response.to_dict()
