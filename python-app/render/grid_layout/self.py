from render.fractional_unit import FractionalUnit
from render.drawable_area import DrawableArea
from render.widget.text_widget import TextWidget
from render.grid_layout.grid_layout_item import GridLayoutItem

from pptx.slide import Slide
from pptx.util import Length, Cm

from functools import reduce

import re
    
def resolve_lengths(
        total_length, 
        lengths: list[Length | FractionalUnit],
        gap: int
        ) -> list[int]:
    emus: list[int] = [ unit.emu for unit in lengths if isinstance(unit, Length) ]
    fractions = [ unit.count for unit in lengths if isinstance(unit, FractionalUnit) ]

    if fractions.__len__() <= 0:
        return emus

    number_of_fractions = reduce(lambda a, b: a + b, fractions, 0)
    occupied_length = reduce(lambda a, b: a + b, emus, 0)
    gap_length = gap * (lengths.__len__() - 1)
    length_per_fraction = (total_length - occupied_length - gap_length) / number_of_fractions

    resolved_lengths = []
    emus_passed = 0
    fractions_passed = 0
    for unit in lengths:
        if isinstance(unit, Length):
            resolved_lengths.append(emus[emus_passed])
            emus_passed += 1
        elif isinstance(unit, FractionalUnit):
            resolved_lengths.append(unit.count * length_per_fraction)
            fractions_passed += 1
    return resolved_lengths

def get_area_size(areas_matrix: list[str], start: tuple[int, int]) -> tuple[int, int]:
    i, j = start
    matrix_height, matrix_width = len(areas_matrix), len(areas_matrix[0])

    key = areas_matrix[i][j]
    width = 0

    while j < matrix_width and areas_matrix[i][j] == key:
        width += 1
        j += 1

    j -= 1
    height = 0
    while i < matrix_height and areas_matrix[i][j] == key:
        height += 1
        i += 1
    
    chunk = [ line[start[1]:start[1] + width] for line in areas_matrix[start[0]:start[0] + height] ]
    if not all(character == key for character in "".join(chunk)):
        raise ValueError(f"El área con clave {key} no es rectangular")

    return (width, height)

def measure_area(start: tuple[int, int], size: tuple[int, int], gap: int, widths: list[int], heights: list[int]) -> tuple[int, int]:
    i0, j0 = start
    width, height = size
    i1, j1 = i0 + height, j0 + width
    
    actual_width = sum(widths[j0:j1]) + (width - 1) * gap
    actual_height = sum(heights[i0:i1]) + (height - 1) * gap

    return (actual_width, actual_height)

def position_area(start: tuple[int, int], gap: int, widths: list[int], heights: list[int]) -> tuple[int, int]:
    i, j = start

    x = sum(widths[0:j]) + j * gap
    y = sum(heights[0:i]) + i * gap

    return (x, y)

def grid_layout(
        slide: Slide, 
        drawable_area: DrawableArea,
        grid_areas: str,
        gap: int,
        column_widths: list[FractionalUnit | Length],
        row_heights: list[FractionalUnit | Length],
        children: list[GridLayoutItem],
        ):
    column_widths: list[int] = resolve_lengths(total_length=drawable_area.width, lengths=column_widths, gap=gap)
    row_heights: list[int] = resolve_lengths(total_length=drawable_area.height, lengths=row_heights, gap=gap)
    
    areas_map = {}
    areas_matrix = [ re.sub(pattern=r'\s+', string=line.strip(), repl='') for line in grid_areas.splitlines() if not (line.isspace() or len(line) == 0) ]

    matrix_width = areas_matrix[0].__len__()
    matrix_height = len(areas_matrix)

    if not all(row.__len__() == matrix_width for row in areas_matrix):
        raise ValueError('Las áreas deben ser del mismo ancho en todas las filas')
    
    for i in range(matrix_height):
        for j in range(matrix_width):
            key = areas_matrix[i][j]
            if key in areas_map:
                continue
            start = (i, j)
            size = get_area_size(areas_matrix=areas_matrix, start=start)

            width, height = measure_area(start=start, size=size, gap=gap, widths=column_widths, heights=row_heights)
            x, y = position_area(start=start, gap=gap, widths=column_widths, heights=row_heights)
            
            areas_map[key] = drawable_area.position_subarea(DrawableArea(x=x, y=y, width=width, height=height))

    for item in children:
        if item.area not in areas_map:
            raise ValueError(f'El área especificada por el elemento no está presente en las áreas de la grid. Área {item.area}')
        
        item_area = areas_map[item.area]
        item.child.draw(slide=slide, drawable_area=item_area)
