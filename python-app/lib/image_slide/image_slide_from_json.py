from lib.slide.slide_from_json import slide_from_json

from models.image_slide.self import ImageSlide
from models.image_slide.image_slide_kind import ImageSlideKind
from models.image_slide.cover_page_slide import CoverPageSlide

def image_slide_from_json(json: dict[str, any]) -> ImageSlide:
    kind = ImageSlideKind(json['kind'])
    parameters = json['parameters']

    slide = slide_from_json(json=json)

    match kind:
        case ImageSlideKind.COVER_PAGE:
            return CoverPageSlide(
                professor_name=parameters['professor_name'],
                period=parameters['period'],
                date=parameters['date'],
                **slide
                )
