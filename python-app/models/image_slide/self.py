from models.slide.self import Slide
from models.slide.slide_category import SlideCategory
from models.image_slide.image_slide_kind import ImageSlideKind

from render.drawable_area import DrawableArea

from abc import abstractmethod

class ImageSlide(Slide):
    def __init__(self, title, identifier, creation_date, last_edit, preview, kind: ImageSlideKind):
        super().__init__(title, identifier, creation_date, last_edit, preview, SlideCategory.IMAGE_SLIDE)
        self.kind = kind
    
    def to_dict(self):
        return {
            **super().to_dict(),
            'kind': self.kind.value,
            'parameters': self.parameters_dict
        }

    @property
    @abstractmethod
    def parameters_dict(self) -> dict[str, any]:
        pass

    @abstractmethod
    def render(self, slide: Slide, drawable_area: DrawableArea):
        pass
