from models.image_slide.image_slide_kind import ImageSlideKind
from models.slide.slide_category import SlideCategory

from pandas import Timestamp
from abc import ABC, abstractmethod
from pptx.slide import Slide
from render.drawable_area import DrawableArea

class Slide(ABC):
    def __init__(self, 
            title: str,
            identifier: str, 
            creation_date: Timestamp,
            last_edit: Timestamp,
            preview: str | None,
            category: SlideCategory,
            ) -> None:
        self.title = title
        self.identifier = identifier
        self.creation_date = creation_date
        self.last_edit = last_edit
        self.preview = preview
        self.category = category

    def to_dict(self) -> dict[str, any]:
        return {
            "title": self.title,
            "identifier": self.identifier,
            "creation_date": self.creation_date.isoformat(),
            "last_edit": self.last_edit.isoformat(),
            "preview": self.preview,
            "category": self.category.value,
        }

    @abstractmethod
    def render(self, slide: Slide, drawable_area: DrawableArea):
        pass
