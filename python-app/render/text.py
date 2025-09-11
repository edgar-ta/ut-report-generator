from render.widget import Widget

class Text(Widget):
    def __init__(self, text: str):
        super().__init__()
        self.text = text
