from models.slide import Slide
from models.slide_type import SlideType
from models.asset import Asset

from dataclasses import dataclass
from copy import deepcopy
from uuid import uuid4

@dataclass(frozen=True)
class SlideRecord:
    id: str
    key: str
    _type: SlideType
    assets: list[Asset]
    arguments: dict[str, object]
    data_files: list[str]
    preview: str

    @classmethod
    def from_slide(cls, slide: Slide) -> "SlideRecord":
        return SlideRecord(
            slide.id,
            uuid4(),
            slide._type,
            slide.assets,
            slide.arguments,
            slide.data_files,
            slide.preview_image
        )

    def to_dict(self) -> dict[str, any]:
        return {
            "id": self.id,
            "key": self.key,
            "type": self._type.value,
            "assets": [asset.to_dict() for asset in self.assets],
            "arguments": deepcopy(self.arguments),
            "data_files": list(self.data_files),
            "preview": self.preview
        }
