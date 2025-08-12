from models.asset_type import AssetType

class Asset:
    def __init__(self, name: str, value: str, _type: AssetType) -> None:
        self.name = name
        self.value = value
        self.type = _type

    def to_dict(self) -> dict[str, any]:
        """Convert the Asset instance to a JSON-serializable dictionary."""
        return {
            "name": self.name,
            "value": self.value,
            "type": self.type.value,
        }

    @classmethod
    def from_json(cls, data: dict[str, any]) -> "Asset":
        """Create an Asset instance from a JSON dictionary."""
        return cls(
            name=data["name"],
            value=data["value"],
            _type=AssetType(data["type"]),
        )