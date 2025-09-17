from render.drawable_area import DrawableArea
from render.sized_box import SizedBox

from pptx.slide import Slide

def column_layout(
    slide: Slide,
    drawable_area: DrawableArea,
    spacing: int,
    children: list[SizedBox]
    ):
    '''
    Draws a center-aligned column of components separated by `spacing` emu's
    '''
    pass
