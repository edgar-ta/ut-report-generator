from models.image_slide.self import ImageSlide
from models.image_slide.image_slide_kind import ImageSlideKind
from models.image_slide.cover_page_slide import CoverPageSlide

from pandas import Timestamp

def image_slide_from_json(json: dict[str, any]) -> ImageSlide:
    kind = ImageSlideKind(json['kind'])
    parameters = json['parameters']

    image_slide_arguments = {
        'title': json['title'],
        'identifier': json['identifier'],
        'creation_date': Timestamp(json['creation_date']),
        'last_edit': Timestamp(json['last_edit']),
        'preview': json['preview'],
    }

    match kind:
        case ImageSlideKind.COVER_PAGE:
            return CoverPageSlide(
                professor_name=parameters['professor_name'],
                period=parameters['period'],
                date=parameters['date'],
                **image_slide_arguments
                )
