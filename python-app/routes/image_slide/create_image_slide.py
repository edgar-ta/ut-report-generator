from lib.with_flask import with_flask
from lib.get_or_panic import get_or_panic
from lib.get_entities_from_request import entities_for_editing_report

from models.report.self import Report
from models.image_slide.image_slide_kind import ImageSlideKind
from models.image_slide.self import ImageSlide
from models.image_slide.cover_page_slide import CoverPageSlide
from models.image_slide.title_and_content_slide import TitleAndContentSlide

from flask import request
from uuid import uuid4
from pandas import Timestamp

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

@with_flask("/create", methods=["POST"])
def create_image_slide():
    report = entities_for_editing_report(request=request)
    root_directory = report.root_directory
    kind = get_or_panic(request.json, 'kind', 'El tipo de diapositiva de imagen no fue enviado en la solicitud')
    kind = ImageSlideKind(kind)
    

    return "Not implemented yet", 500
