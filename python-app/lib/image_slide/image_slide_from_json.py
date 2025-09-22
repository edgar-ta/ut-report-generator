from lib.slide.slide_from_json import slide_from_json
from lib.image_slide.image_slide_parameter_from_json import image_slide_parameter_from_json

from models.image_slide.self import ImageSlide
from models.image_slide.image_slide_kind import ImageSlideKind
from models.image_slide.cover_page_slide import CoverPageSlide

def image_slide_from_json(json: dict[str, any]) -> ImageSlide:
    kind = ImageSlideKind(json['kind'])
    parameters = {
        key: image_slide_parameter_from_json(json=value) for (key, value) in json['parameters'].items()
    }

    slide = slide_from_json(json=json)

    match kind:
        case ImageSlideKind.COVER_PAGE:
            value = CoverPageSlide(
                professor_name=parameters['professor_name'].value,
                period=parameters['period'].value,
                date=parameters['date'].value,
                **slide
                )
            return value
