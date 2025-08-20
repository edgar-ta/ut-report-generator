from lib.descriptive_error import DescriptiveError

from models.image_slide.self import ImageSlide
from models.pivot_table.self import PivotTable
from models.report import Report

from uuid import uuid4

def format_for_edit(response: Report | ImageSlide | PivotTable):
    if type(response) == Report:
        raise DescriptiveError(http_error_code=500, message=f"La rama de este método no ha sido implementada todavía. {__file__}")
    
    if type(response) == ImageSlide:
        return {
            "preview": response.preview,
        }
    
    if type(response) == PivotTable:
        raise DescriptiveError(http_error_code=500, message=f"La rama de este método no ha sido implementada todavía. {__file__}")
