from lib.with_flask import with_flask
from lib.directory_definitions import base_directory_of_slide
from lib.slide.render_preview import render_preview
from lib.report.create_report import create_report
from lib.report.save_slideshow import save_slideshow

from models.report.visualization_mode import VisualizationMode
from models.image_slide.cover_page_slide import CoverPageSlide

from routes.route_map import SLIDESHOW

from pandas import Timestamp
from uuid import uuid4

import os

@with_flask(SLIDESHOW.START_AS_REPORT.value, methods=["POST"])
def start_report_with_image_slide():
    root_directory, report = create_report(visualization_mode=VisualizationMode.AS_REPORT)

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
    os.makedirs(base_directory_of_slide(root_directory=root_directory, slide_id=cover_page.identifier))
    report.slides.append(cover_page)

    render_preview(root_directory=root_directory, slides=report.slides)
    save_slideshow(root_directory=root_directory, slideshow=report)

    return report.to_dict(), 200
