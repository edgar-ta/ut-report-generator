from render.fractional_unit import FractionalUnit
from render.widget.drawable_widget import DrawableWidget

from pptx.util import Length

class SizedBox():
    def __init__(self, width: Length | FractionalUnit, height: Length | FractionalUnit, child: DrawableWidget):
        self.width = width
        self.height = height
        self.child = child
