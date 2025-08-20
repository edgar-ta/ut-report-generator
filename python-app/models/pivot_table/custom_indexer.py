class CustomIndexer:
    def __init__(self, level: str, values: list[str]):
        self.level = level
        self.values: list[str] = values
    
    def __repr__(self) -> str:
        return f'CustomIndexer({self.level = }, {self.values = })'
    
    def to_dict(self) -> dict:
        """Convierte la instancia en un diccionario serializable a JSON."""
        return {
            "level": self.level,
            "values": self.values,
        }
    
    @classmethod
    def from_json(cls, data: dict[str, any]) -> "CustomIndexer":
        return cls(
            level=data["level"],
            values=data["values"]
        )
