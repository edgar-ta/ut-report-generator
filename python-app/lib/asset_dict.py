def asset_dict(assets: list[tuple[str, str, str]]) -> list[dict[str, str]]:
    return [ 
        { 
            "name": name, 
            "value": value, 
            "type": _type 
        } 
        for (name, value, _type) in assets 
    ]
