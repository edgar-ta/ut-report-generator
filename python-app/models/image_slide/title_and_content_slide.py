from models.image_slide.self import ImageSlide
from models.image_slide.image_slide_kind import ImageSlideKind
from models.image_slide.image_slide_parameter import ImageSlideParameter

from render.grid_layout.self import grid_layout
from render.grid_layout.grid_layout_item import GridLayoutItem

from render.fractional_unit import FractionalUnit
from render.widget.text_widget import TextWidget

from pptx.util import Cm, Pt

class TitleAndContentSlide(ImageSlide):
    def __init__(self, title, identifier, creation_date, last_edit, preview, content: str):
        super().__init__(title, identifier, creation_date, last_edit, preview, ImageSlideKind.TITLE_AND_CONTENT)
        self.content = content

    @property
    def parameters_dict(self):
        return {
            'content': ImageSlideParameter(value=self.content, readable_name="Texto", _type='str'),
        }
    
    def render(self, slide, drawable_area):
        grid_layout(
            slide=slide,
            drawable_area=drawable_area,
            grid_areas='''
            a
            b
            ''',
            gap=Cm(0.25).emu,
            column_widths=[FractionalUnit(1)],
            row_heights=[
                Cm(6.5).emu, 
                FractionalUnit(1) 
            ],
            children=[
                GridLayoutItem(
                    area='a',
                    child=TextWidget(
                        text=self.title,
                    )
                ),
                GridLayoutItem(
                    area='b',
                    child=TextWidget(
                        text=self.content,
                    )
                )
            ]
        )
