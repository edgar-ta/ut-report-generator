from render.widget import Widget
from render.children_container import ChildrenContainer

from pptx.slide import Slide
from pptx.util import Length

from functools import reduce

class Fraction():
    def __init__(self, count: int):
        if count <= 0 or not float.is_integer(count):
            raise ValueError("La fracción tiene que ser un entero positivo")
        self.count = count

class GridLayout(Widget, ChildrenContainer):
    def __init__(
            self, 
            grid_areas: str, 
            row_heights: list[Length | Fraction], 
            column_widths: list[Length | Fraction], 
            gap: float, 
            children: list[Widget]
            ):
        super().__init__()
        self.grid_areas = grid_areas
        self.row_heights = row_heights
        self.column_widths = column_widths
        self.gap = gap

        self.bind_to_children(children=children)
    
    def resolve_lengths(self, total_length, lengths: list[Length | Fraction]) -> list[int]:
        emus: list[int] = [ unit.emu for unit in lengths if isinstance(unit, Length) ]
        fractions = [ unit.count for unit in lengths if isinstance(unit, Fraction) ]

        if fractions.__len__() <= 0:
            return emus

        number_of_fractions = reduce(lambda a, b: a + b, fractions, 0)
        occupied_length = reduce(lambda a, b: a + b, emus, 0)
        gap_length = self.gap * (lengths.__len__() - 1)
        length_per_fraction = (total_length - occupied_length - gap_length) / number_of_fractions

        resolved_lengths = []
        emus_passed = 0
        fractions_passed = 0
        for unit in lengths:
            if isinstance(unit, Length):
                resolved_lengths.append(emus[emus_passed])
                emus_passed += 1
            elif isinstance(unit, Fraction):
                resolved_lengths.append(unit.count * length_per_fraction)
                fractions_passed += 1
        return resolved_lengths

    def render(self, slide):
        column_widths: list[int] = self.resolve_lengths(total_length=self.drawable_area.width, lengths=self.column_widths)
        row_heights: list[int] = self.resolve_lengths(total_length=self.drawable_area.height, lengths=self.row_heights)

        self.drawable_area
