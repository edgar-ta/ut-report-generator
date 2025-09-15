from render.widget.drawable_widget import DrawableWidget
from pptx.util import Emu

class TextWidget(DrawableWidget):
    def __init__(self, text: str):
        super().__init__()

        self.text = text

    def draw(self, slide, drawable_area):
        print(repr(drawable_area))
        textbox = slide.shapes.add_textbox(
            left=drawable_area.x, 
            top=drawable_area.y, 
            width=Emu(drawable_area.width), 
            height=Emu(drawable_area.height)
            )
        textbox.text = self.text
