from render.widget import Widget
from render.child_container import ChildContainer
from render.drawable_area import DrawableArea

class Padding(Widget, ChildContainer):
    def __init__(self, padding: float, child: Widget):
        super().__init__()
        self.padding = padding
        self.bind_to_child(child=child)

    @property
    def drawable_area(self):
        parent_area = self.parent.drawable_area
        return DrawableArea(
            x=self.padding, 
            y=self.padding, 
            width=parent_area.width - 2 * self.padding,
            height=parent_area.height - 2 * self.padding,
            )
