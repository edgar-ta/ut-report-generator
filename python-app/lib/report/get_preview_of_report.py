from models.report.self import Report
from models.report.visualization_mode import VisualizationMode
from models.slide.slide_category import SlideCategory

from control_variables import EMPTY_REPORT_PREVIEW, EMPTY_VISUALIZATION_PREVIEW

def get_preview_of_report(report: Report) -> str:
    visible_slides = report.slides

    if report.visualization_mode == VisualizationMode.CHARTS_ONLY:
        visible_slides = [ _slide for _slide in report.slides if _slide.category == SlideCategory.PIVOT_TABLE ]
    
    if len(visible_slides) == 0:
        match report.visualization_mode:
            case VisualizationMode.CHARTS_ONLY:
                return EMPTY_VISUALIZATION_PREVIEW()
            case VisualizationMode.AS_REPORT:
                return EMPTY_REPORT_PREVIEW()
    
    return visible_slides[0].preview
