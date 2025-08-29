from lib.with_app_decorator import with_app
from lib.get_or_panic import get_or_panic
from lib.directory_definitions import preview_image_of_slide, base_directory_of_slide
from lib.get_entities_from_request import entities_for_editing_pivot_table

from models.report import Report
from models.slide.slide_category import SlideCategory

from flask import request
from uuid import uuid4

import os
import pandas

@with_app("/toggle_visualization_mode", methods=["POST"])
def toggle_visualization_mode_of_pivot_table():
    report, pivot_table = entities_for_editing_pivot_table(request=request)
    
    match pivot_table.mode:
        case SlideCategory.IMAGE_SLIDE:
            # should render the image slide
            pass
        case SlideCategory.PIVOT_TABLE:
            # should render the pivot table
            pass
