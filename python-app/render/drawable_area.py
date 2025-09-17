class DrawableArea():
    '''
    Stores measurements in EMUs
    '''

    def __init__(self, x: float, y: float, width: float, height: float) -> None:
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    
    def position_subarea(self, subarea: "DrawableArea") -> "DrawableArea":
        # I'm going to assume the subarea can be placed inside the current area
        return DrawableArea(
            x=self.x + subarea.x,
            y=self.y + subarea.y,
            width=min(subarea.width, self.width - subarea.x),
            height=min(subarea.height, self.height - subarea.y)
        )
    
    def with_padding(self, horizontal: int, vertical: int) -> "DrawableArea":
        return DrawableArea(
            x=horizontal,
            y=vertical,
            width=self.width - 2 * horizontal,
            height=self.height - 2 * vertical
        )
    
    def __repr__(self) -> str:
        return f"DrawableArea(x={self.x}, y={self.y}, width={self.width}, height={self.height})"
