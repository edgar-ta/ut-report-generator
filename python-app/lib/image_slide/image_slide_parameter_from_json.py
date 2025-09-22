from models.image_slide.image_slide_parameter import ImageSlideParameter

def image_slide_parameter_from_json(json: dict[str, any]) -> ImageSlideParameter:
    return ImageSlideParameter(
        name=json['name'],
        value=json['value'],
        _type=json['type'],
    )
