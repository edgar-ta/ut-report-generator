from models.asset import Asset
from models.asset_type import AssetType

def get_asset(asset_list: list[Asset], asset_name: str, asset_type: AssetType) -> str | None:
    return next((asset.value for asset in asset_list if asset.name == asset_name and asset.type == asset_type), None)

def get_string_asset(asset_list: list[Asset], asset_name: str) -> str | None:
    return get_asset(asset_list, asset_name, AssetType.TEXT)

def get_image_asset(asset_list: list[Asset], asset_name: str) -> str | None:
    return get_asset(asset_list, asset_name, AssetType.IMAGE)
