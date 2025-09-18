import pandas as pd

from lib.pivot_table.plot_data import plot_data

from models.pivot_table.pivot_table_level import PivotTableLevel, level_to_spanish
from models.pivot_table.aggregate_function_type import AggregateFunctionType, aggregate_function_to_spanish
from models.pivot_table.filter_function_type import FilterFunctionType, filter_function_to_spanish
from models.pivot_table.aggregate_function_type import AggregateFunctionType
from models.pivot_table.filter_function_type import FilterFunctionType
from models.pivot_table.pivot_table_level import PivotTableLevel
from models.pivot_table.data_source import DataSource
from models.pivot_table.data_filter.self import DataFilter
from models.pivot_table.data_filter.charting_mode import ChartingMode
from models.slide.slide_category import SlideCategory
from models.slide.self import Slide

from render.grid_layout.self import grid_layout
from render.grid_layout.grid_layout_item import GridLayoutItem

from render.fractional_unit import FractionalUnit
from render.widget.text_widget import TextWidget
from render.widget.image_widget import ImageWidget
from render.font import Font
from render.color import Color

from pptx.util import Cm, Pt
from pptx.enum.text import PP_ALIGN

class PivotTable(Slide):
    def __init__(
            self, 
            title: str, 
            identifier: str, 
            creation_date: pd.Timestamp, 
            last_edit: pd.Timestamp,
            preview: str,
            bare_preview: str,
            filters: list[DataFilter],
            filters_order: list[PivotTableLevel],
            source: DataSource,
            data: dict[str, dict[str, float]] | dict[str, float],
            aggregate_function: AggregateFunctionType,
            filter_function: FilterFunctionType,
            ) -> None:
        super().__init__(
            title=title, 
            identifier=identifier, 
            creation_date=creation_date, 
            last_edit=last_edit, 
            preview=preview, 
            category=SlideCategory.PIVOT_TABLE
            )

        self.bare_preview = bare_preview
        self.filters: list[DataFilter] = filters
        self.filters_order = filters_order
        self.source = source
        self.data = data
        self.aggregate_function = aggregate_function
        self.filter_function = filter_function

    def to_dict(self) -> dict:
        return {
            **super().to_dict(),
            "bare_preview": self.bare_preview,
            "filters": [f.to_dict() for f in self.filters],
            "filters_order": [ level.value for level in self.filters_order ],
            "source": self.source.to_dict(),
            "data": self.data,
            "aggregate_function": self.aggregate_function.value,
            "filter_function": self.filter_function.value,
        }
    
    def render_bare_preview(self, filepath: str):
        outer_filter: DataFilter = next((_filter for _filter in self.filters if _filter.charting_mode == ChartingMode.SUPER_CHART), None)
        if outer_filter is None:
            outer_filter = next((_filter for _filter in self.filters if _filter.charting_mode == ChartingMode.CHART), None)

        plot_data(
            data=self.data, 
            title=self.title, 
            kind="bar", 
            x_label=level_to_spanish(outer_filter.level), 
            y_label=
                aggregate_function_to_spanish(self.aggregate_function) + 
                " de calificaciones de " + 
                filter_function_to_spanish(outer_filter),
            filepath=filepath
            )
        
        self.bare_preview = filepath
    
    def render(self, slide, drawable_area):
        grid_layout(
            slide=slide,
            drawable_area=drawable_area,
            grid_areas='''
            a
            b
            ''',
            column_widths=[FractionalUnit(1)],
            row_heights=[
                Cm(3.5).emu, 
                FractionalUnit(1) 
            ],
            gap=Cm(0.25).emu,
            children=[
                GridLayoutItem(
                    area='a',
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
                    area='b',
                    child=ImageWidget(source=self.bare_preview)
                ),
            ]
        )
