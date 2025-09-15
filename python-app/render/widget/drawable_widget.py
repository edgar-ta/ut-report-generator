from render.drawable_area import DrawableArea

from pptx.slide import Slide

from abc import ABC, abstractmethod

class DrawableWidget(ABC):
    @abstractmethod
    def draw(self, slide: Slide, drawable_area: DrawableArea):
        pass
