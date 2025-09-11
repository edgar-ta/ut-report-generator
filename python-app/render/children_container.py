from render.widget import Widget

from abc import ABC

class ChildrenContainer(ABC):
    def __init__(self):
        super().__init__()
        self.children: list[Widget] = []
    
    def bind_to_children(self, children: list[Widget]):
        self.children = children
        for child in children:
            child.bind_to_parent(parent=self)
