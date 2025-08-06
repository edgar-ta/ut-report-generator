def asset_dict(assets: list[tuple[str, str]]) -> list[dict[str, str]]:
    return [ { "name": name, "path": path } for (name, path) in assets ]