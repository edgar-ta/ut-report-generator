from models.asset import Asset
from models.asset_type import AssetType

def asset_dict(assets: list[tuple[str, str, str]]) -> list[Asset]:
    return [ 
        Asset(
            name=name,
            value=value,
            _type=AssetType(_type)
        ) 
        for (name, value, _type) in assets 
    ]
