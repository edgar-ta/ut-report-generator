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
            width=subarea.width,
            height=subarea.height
        )
