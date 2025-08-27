from models.image_slide.image_slide_kind import ImageSlideKind
from models.slide.slide_category import SlideCategory

from pandas import Timestamp

class ImageSlide():
    def __init__(self, 
            name: str,
            identifier: str, 
            creation_date: Timestamp,
            last_edit: Timestamp,
            preview: str,
            arguments: dict[str, any], 
            kind: ImageSlideKind, 
            ) -> None:
        self.name = name
        self.identifier = identifier
        self.creation_date = creation_date
        self.last_edit = last_edit
        self.preview = preview
        self.category = SlideCategory.IMAGE

        self.arguments = arguments
        self.kind = kind
    
    def to_dict(self) -> dict[str, any]:
        return {
            "name": self.name,
            "identifier": self.identifier,
            "creation_date": self.creation_date.isoformat(),
            "last_edit": self.last_edit.isoformat(),
            "preview": self.preview,
            "category": self.category.value,
            "arguments": self.arguments,
            "kind": self.kind.value,
        }
    
    @classmethod
    def from_json(cls, json_data: dict[str, any]) -> "ImageSlide":
        return cls(
            name=json_data["name"],
            identifier=json_data["id"],
            creation_date=Timestamp(json_data["creation_date"]),
            last_edit=Timestamp(json_data["last_edit"]),
            preview=json_data["preview"],
            arguments=json_data["arguments"],
            kind=ImageSlideKind(json_data["kind"])
        )
