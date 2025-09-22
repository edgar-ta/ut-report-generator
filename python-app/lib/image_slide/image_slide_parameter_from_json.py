from models.image_slide.image_slide_parameter import ImageSlideParameter

def image_slide_parameter_from_json(json: dict[str, any]) -> ImageSlideParameter:
    return ImageSlideParameter(
        value=json['value'],
        readable_name=json['readable_name'],
        _type=json['type'],
    )
