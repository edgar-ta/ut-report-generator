from lib.with_flask import with_flask
from lib.get_or_panic import get_or_panic
from lib.get_entities_from_request import entities_for_editing_report
from lib.slide.render_preview import render_preview
from lib.directory_definitions import base_directory_of_slide
from lib.report.save_slideshow import save_slideshow

from models.report.self import Report
from models.image_slide.image_slide_kind import ImageSlideKind
from models.image_slide.self import ImageSlide
from models.image_slide.cover_page_slide import CoverPageSlide
from models.image_slide.title_and_content_slide import TitleAndContentSlide

from routes.route_map import IMAGE_SLIDE

from flask import request
from uuid import uuid4
from pandas import Timestamp

import os

def image_slide_from_kind(kind: ImageSlideKind):
    title = "Mi diapositiva"
    identifier = str(uuid4())
    creation_date = Timestamp.now()

    match kind:
        case ImageSlideKind.COVER_PAGE:
            return CoverPageSlide(
                title=title,
                identifier=identifier,
                creation_date=creation_date,
                last_edit=creation_date,
                preview=None,
                professor_name="Profesor",
                period="Cuatrimestre",
                date="Fecha"
                )
        case ImageSlideKind.TITLE_AND_CONTENT:
            return TitleAndContentSlide(
                title=title,
                identifier=identifier,
                creation_date=creation_date,
                last_edit=creation_date,
                preview=None,
                content="Texto"
            )
        case ImageSlideKind.IMAGE_LEFT:
            pass
    pass

@with_flask(IMAGE_SLIDE.CREATE.value, methods=["POST"])
def create_image_slide():
    root_directory, report = entities_for_editing_report(request=request)
    kind = get_or_panic(request.json, 'kind', 'El tipo de diapositiva de imagen no fue enviado en la solicitud')
    kind = ImageSlideKind(kind)

    slide = image_slide_from_kind(kind=kind)
    os.makedirs(base_directory_of_slide(root_directory=root_directory, slide_id=slide.identifier))
    render_preview(root_directory=root_directory, slides=slide)

    report.slides.append(slide)
    report.last_edit = Timestamp.now()
    save_slideshow(root_directory=root_directory, slideshow=report)

    return slide.to_dict(), 200
