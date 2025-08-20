from typing import Optional

class CustomIndexer:
    def __init__(self, level: str, values: list[str]):
        self.level = level
        self.values: list[str] = values
    
    def __repr__(self) -> str:
        return f'CustomIndexer({self.level = }, {self.values = })'
    
    def to_dict(self) -> dict:
        """Convierte la instancia en un diccionario serializable a JSON."""
        print(__file__)
        print("@to_dict")
        print("Hello 1")

        my_dict = {
            "level": self.level,
            "values": self.values,
        }

        print(__file__)
        print("@to_dict")
        print("Hello 2")

        return my_dict
    
    @classmethod
    def from_json(cls, data: dict[str, any]) -> "CustomIndexer":
        return cls(
            level=data["level"],
            values=data["values"]
        )
