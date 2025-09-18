from models.report.self import Report
from models.report.visualization_mode import VisualizationMode
from models.slide.slide_category import SlideCategory

def get_preview_of_report(report: Report) -> str:
    if report.visualization_mode == VisualizationMode.CHARTS_ONLY:
        for slide in report.slides:
            if slide.category == SlideCategory.PIVOT_TABLE:
                return slide.bare_preview
    
    return report.slides[0].preview
