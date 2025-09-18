from control_variables import PATH_OF_PPTX_TEMPLATE

from lib.with_flask import with_flask
from lib.descriptive_error import DescriptiveError
from lib.format_for_create import format_for_create
from lib.image_slide.add_image_slide_to_report import add_image_slide_to_report
from lib.directory_definitions import base_directory_of_slide
from lib.report.render_previews_of_report import render_previews_of_report

from models.report.self import Report
from models.report.visualization_mode import VisualizationMode
from models.image_slide.cover_page_slide import CoverPageSlide

from render.drawable_area import DrawableArea

from flask import request
from pptx import Presentation
from pptx.util import Cm
from pandas import Timestamp
from uuid import uuid4

import os

@with_flask("/start_with_image_slide", methods=["POST"])
def start_report_with_image_slide():
    report = Report.from_nothing(visualization_mode=VisualizationMode.AS_REPORT)
    report.makedirs()

    slide_identifier = str(uuid4())
    cover_page = CoverPageSlide(
        title="",
        identifier=slide_identifier,
        creation_date=Timestamp.now(),
        last_edit=Timestamp.now(),
        preview=None,
        professor_name="",
        period="",
        date=""
    )
    os.makedirs(base_directory_of_slide(root_directory=report.root_directory, slide_id=cover_page.identifier))
    report.slides.append(cover_page)

    render_previews_of_report(report=report)
    report.save()

    return report.to_dict(), 200
