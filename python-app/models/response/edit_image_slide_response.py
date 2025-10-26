from models.image_slide.self import ImageSlide

class EditImageSlide_Response():
    def __init__(self, preview: str):
        self.preview = preview

    def to_dict(self) -> dict[str, any]:
        return {
            'preview': self.preview
        }
