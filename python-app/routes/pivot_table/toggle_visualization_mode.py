from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.directory_definitions import preview_image_of_slide, base_directory_of_slide

from models.report import Report
from models.slide.slide_category import SlideCategory

from flask import request
from uuid import uuid4

import os
import pandas

@with_app("/change_visualization_mode", methods=["POST"])
def change_visualization_mode():
    report_id = get_or_panic(request.json, 'report', 'El identificador del reporte no estaba presente en la solicitud')
    pivot_table_id = get_or_panic(request.json, 'pivot_table', 'El identificador del reporte no estaba presente en la solicitud')
    mode_value = get_or_panic(request.json, 'mode', 'El nuevo modo de visualización no estaba presente en la solicitud')

    report = Report.from_identifier(identifier=report_id)
    pivot_table = report[pivot_table_id]
    mode = SlideCategory(mode_value)

    if mode == pivot_table.mode:
        return { "success": True }, 200
    
    match pivot_table.mode:
        case SlideCategory.IMAGE_SLIDE:
            pass
        case SlideCategory.PIVOT_TABLE:
            # We're changing from pivot_table to image_slide
            preview_exists = os.path.exists(pivot_table.preview)
            if preview_exists and pandas.Timestamp(os.path.getmtime(pivot_table.preview), "s") > pivot_table.last_edit:
                # If there is a preview and it was created after the last edit,
                # then do nothing, pretty much
                pivot_table.mode = mode
            else:
                if preview_exists:
                    os.remove(pivot_table.preview)

                new_preview = preview_image_of_slide(root_directory=report.root_directory, slide_id=pivot_table.identifier)

                base_directory = base_directory_of_slide(root_directory=report.root_directory, slide_id=pivot_table.identifier)
                chart_path = os.path.join(base_directory, f"chart-{str(uuid4())}.png")

                data = {
                    "a": { "b": 5 }
                }
                data.values()
            
