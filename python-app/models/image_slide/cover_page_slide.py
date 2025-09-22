from models.image_slide.self import ImageSlide
from models.image_slide.image_slide_kind import ImageSlideKind
from models.image_slide.image_slide_parameter import ImageSlideParameter

from render.grid_layout.self import grid_layout
from render.grid_layout.grid_layout_item import GridLayoutItem

from render.fractional_unit import FractionalUnit
from render.widget.text_widget import TextWidget
from render.font import Font
from render.color import Color

from pptx.util import Cm, Pt
from pptx.enum.text import PP_ALIGN

class CoverPageSlide(ImageSlide):
    def __init__(
            self, 
            title, 
            identifier, 
            creation_date, 
            last_edit, 
            preview, 
            professor_name: str,
            period: str,
            date: str
            ):
        super().__init__(title, identifier, creation_date, last_edit, preview, ImageSlideKind.COVER_PAGE)
        self.professor_name = professor_name
        self.period = period
        self.date = date

    @property
    def parameters_dict(self):
        return {
            'professor_name': ImageSlideParameter(self.professor_name, 'Profesor', 'str'),
            'period': ImageSlideParameter(self.period, 'Cuatrimestre', 'str'),
            'date': ImageSlideParameter(self.date, 'Fecha', 'str')
        }
    
    def render(self, slide, drawable_area):
        subtitle_color = Color(0x1C, 0x45, 0x87)
        subtitle_font = Font(size=Pt(22), bold=True,)

        grid_layout(
            slide=slide,
            drawable_area=drawable_area,
            grid_areas='''
            a
            b
            c
            d
            e
            d
            ''',
            column_widths=[FractionalUnit(1)],
            row_heights=[
                FractionalUnit(1), 
                Cm(6.5).emu, 
                Cm(1).emu, 
                Cm(1).emu, 
                Cm(1).emu, 
                FractionalUnit(1) 
            ],
            gap=Cm(0.25).emu,
            children=[
                GridLayoutItem(
                    area='b',
                    child=TextWidget(
                        text=self.title, 
                        alignment=PP_ALIGN.CENTER,
                        font=Font(
                            size=Pt(60),
                            bold=True,
                            font_family='Avenir'
                        ),
                        color=Color(0x1F, 0x38, 0x64)
                    )
                ),
                GridLayoutItem(
                    area='c',
                    child=TextWidget(
                        text=f'PROFESOR: {self.professor_name}', 
                        alignment=PP_ALIGN.CENTER,
                        font=subtitle_font,
                        color=subtitle_color
                    )
                ),
                GridLayoutItem(
                    area='d',
                    child=TextWidget(
                        text=f'CUATRIMESTRE: {self.period}', 
                        alignment=PP_ALIGN.CENTER,
                        font=subtitle_font,
                        color=subtitle_color
                    )
                ),
                GridLayoutItem(
                    area='e',
                    child=TextWidget(
                        text=f'FECHA: {self.date}', 
                        alignment=PP_ALIGN.CENTER,
                        font=subtitle_font,
                        color=subtitle_color
                    )
                ),
            ]
        )
