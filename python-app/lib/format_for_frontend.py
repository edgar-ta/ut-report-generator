from models.report import Report
from models.slide.self import Slide
from models.pivot_table.self import PivotTable

def format_for_frontend(response: Report | Slide | PivotTable) -> dict:
    if type(response) == Report:
        return {
            "identifier": response.identifier,
            "report_name": response.report_name,
            "creation_date": response.creation_date,
            "last_edit": response.last_edit,
            "last_open": response.last_open,
            "slides": [ format_for_frontend(response=slide) for slide in response.slides ]
        }
    if type(response) == Slide:
        return {
            "identifier": response.identifier,
            "name": response.name
        }
    if type(response) == PivotTable:
        print(f"pivot_table = {response}")
        return response.to_dict()
