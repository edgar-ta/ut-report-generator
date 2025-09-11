from render.widget import Widget

from abc import ABC

class ChildContainer(ABC):
    def __init__(self):
        super().__init__()
        self.child: Widget | None = None
    
    def bind_to_child(self, child: Widget):
        self.child = child
        child.bind_to_parent(parent=self)
