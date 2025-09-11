from render.child_container import ChildContainer
from render.widget import Widget
from render.drawable_area import DrawableArea

class Window(Widget, ChildContainer):
    def __init__(self, width: float, height: float, child: Widget):
        super().__init__()
        self.width = width
        self.height = height
        self.bind_to_child(child=child)
    
    @property
    def drawable_area(self):
        return DrawableArea(x=0, y=0, width=self.width, height=self.height)
