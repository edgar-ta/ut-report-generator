from render.widget.drawable_widget import DrawableWidget

class ImageWidget(DrawableWidget):
    def __init__(self, source: str):
        super().__init__()
        self.source = source
    
    def draw(self, slide, drawable_area):
        slide.shapes.add_picture(image_file=self.source, left=drawable_area.x, top=drawable_area.y, width=drawable_area.width, height=drawable_area.height)
