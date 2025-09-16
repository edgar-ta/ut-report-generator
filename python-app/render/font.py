from pptx.util import Pt


class Font():
    def __init__(
            self, 
            font_family: str = 'Calibri', 
            size: Pt = Pt(22), 
            bold: bool = False, 
            italic: bool = False
            ):
        self.font_family = font_family
        self.size = size
        self.bold = bold
        self.italic = italic
