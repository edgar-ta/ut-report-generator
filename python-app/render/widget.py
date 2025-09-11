from render.drawable_area import DrawableArea
from pptx.slide import Slide

from abc import abstractmethod, ABC

class Widget(ABC):
    def __init__(self):
        super().__init__()
        self.parent: "Widget" | None = None

    def bind_to_parent(self, parent: "Widget"):
        self.parent = parent

    @abstractmethod
    def render(self, slide: Slide):
        '''
        Add the element of the Widget to the slide of the presentation
        '''
        pass

    @property
    @abstractmethod
    def drawable_area(self) -> DrawableArea:
        pass
