from render.widget.drawable_widget import DrawableWidget

class GridLayoutItem():
    def __init__(self, area: str, child: DrawableWidget):
        self.area = area
        self.child = child
