from constants.dynamic_variables import DynamicVariables

from enum import Enum
from typing import TypeVar, Callable, Generic

import os

def ASSETS_DIRECTORY() -> str:
    return os.path.join(DynamicVariables.instance.executable_directory, 'assets')

def _path_of_asset(filename: str) -> str:
    return os.path.join(ASSETS_DIRECTORY(), filename)

class LazyEnumMember[T]:
    def __init__(self, factory: Callable[[], T]):
        self._cached: T = None
        self._factory = factory

    def __str__(self):
        return self._cached
    
    @property
    def path(self):
        if self._cached is None:
            self._cached = self._factory()
        return self._cached

class Assets(Enum):
    PRESENTATION_TEMPLATE = LazyEnumMember(factory=lambda: _path_of_asset('presentation-template.pptx'))
    EMPTY_REPORT_PREVIEW = LazyEnumMember(factory=lambda: _path_of_asset('empty-report.png'))
    EMPTY_VISUALIZATION_PREVIEW = LazyEnumMember(factory=lambda: _path_of_asset('empty-visualization.jpg'))

def validate_assets():
    for asset in Assets:
        if not os.path.exists(asset.value.path) or not os.path.isfile(asset.value.path):
            raise FileNotFoundError(f'No se encontró el asset "{asset.name}" en  la ruta "{asset.value.path}"')
