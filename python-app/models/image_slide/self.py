from models.image_slide.image_slide_kind import ImageSlideKind
from models.slide_category import SlideCategory

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
            "creation_date": self.creation_date,
            "last_edit": self.last_edit.isoformat(),
            "preview": self.preview,
            "category": self.category,
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

    # @property
    # def arguments(self) -> dict[str, any]:
    #     '''
    #     Arguments are validated when using dot syntax. I. e., `slide.arguments = new_arguments`
    #     calls a setter function under the hood
    #     '''
    #     return self._arguments
    
    # @arguments.setter
    # def arguments(self, new_arguments: dict[str, any]) -> None:
    #     merged_arguments = { **self.arguments, **new_arguments }
    #     if merged_arguments != self.arguments:
    #         self.controller.validate_arguments(merged_arguments)
    #         self._arguments = merged_arguments
    #         self.last_edit = Timestamp.now()
    
    # @property
    # def preview_image(self) -> str | None:
    #     filename = next((
    #         file for file in os.listdir(self.base_directory)
    #         if has_extension(filename=file, extension="png")
    #     ), None)

    #     if filename is None:
    #         return None        
    #     return os.path.join(self.base_directory, filename)

    # @property
    # def is_up2date(self) -> bool:
    #     return self.last_render is not None and self.last_render >= self.last_edit
