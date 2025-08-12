from lib.check_file_extension import check_file_extension
from lib.sections.failure_rate.controller import FailureRate_Controller
from lib.slide_controller import SlideController
from lib.descriptive_error import DescriptiveError
from lib.directory_definitions import images_directory_of_slide

from spire.presentation import Presentation as SpirePresentation

from pptx import Presentation as LibrePresentation

from control_variables import AVAILABLE_SLIDE_CONTROLLERS

from models.slide_type import SlideType
from models.asset import Asset
from models.asset_type import AssetType

from functools import cached_property

import uuid
import os

class Slide():
    def __init__(self, 
                 id: str, 
                 _type: SlideType, 
                 assets: list[Asset], 
                 arguments: dict[str, any], 
                 data_files: list[str], 
                 preview: str | None,
                 base_directory: str
                 ) -> None:
        self.id = id
        self._type = _type
        self.assets = assets
        self.arguments = arguments
        self.data_files = data_files
        self.preview = preview
        self.base_directory = base_directory
    
    def to_dict(self) -> dict[str, any]:
        return {
            "id": self.id,
            "type": self._type.value,
            "assets": [ asset.to_dict() for asset in self.assets ],
            "arguments": self.arguments,
            "data_files": self.data_files,
            "preview": self.preview
        }

    @classmethod
    def from_json(cls, json_data: dict[str, any], base_directory: str) -> "Slide":
        return cls(
            id=json_data["id"],
            _type=SlideType(json_data["type"]),
            assets=[ Asset.from_json(asset) for asset in json_data["assets"] ],
            arguments=json_data["arguments"],
            data_files=json_data["data_files"],
            preview=json_data.get("preview", None),
            base_directory=base_directory
        )
    
    def controller_for_files(file_path: list[str]) -> type[SlideController]:
        '''
        Gets the most approprivate controller for a file or collection of files.
        It validates that the data in the files is in a correct format.
        Not implemented yet
        '''
        return FailureRate_Controller

    @classmethod
    def from_data_files(cls, base_directory: str, files: list[str]) -> "Slide":
        '''
        Builds a slide with the default arguments of the most appropriate
        controller for the given data files.
        Assets are not build, neither is the preview.
        '''
        controller = cls.controller_for_files(files)
        slide_id = str(uuid.uuid4())

        slide = Slide(
            id=slide_id,
            _type=controller.slide_type(),
            assets=[],
            arguments=controller.default_arguments(),
            data_files=files,
            preview=None,
            base_directory=base_directory
        )

        return slide
    
    @cached_property
    def controller(self) -> type[SlideController]:
        controller = next((controller for controller in AVAILABLE_SLIDE_CONTROLLERS if controller.slide_type() == self._type), None)
        if controller is None:
            raise DescriptiveError(500, f"Tipo de controlador desconocido. Se obtuvo {self._type.value}")
        return controller

    @cached_property
    def images_directory(self) -> str:
        return images_directory_of_slide(base_directory=self.base_directory, slide_id=self.id)
    
    @cached_property
    def preview_image(self) -> str:
        return os.path.join(self.images_directory, "preview.png")

    def build_assets(self) -> list[Asset]:
        assets = self.controller.build_assets(
            data_files=self.data_files, 
            arguments=self.arguments, 
            base_directory=self.base_directory
        )
        self.assets = assets
        return assets

    def makedirs(self):
        os.makedirs(self.images_directory)

    def build_preview(self) -> str:
        presentation = LibrePresentation()
        self.controller.render_slide(
            presentation=presentation,
            arguments=self.arguments,
            assets=self.assets,
        )

        pptx_preview_path = os.path.join(self.base_directory, str(uuid.uuid4()) + ".pptx")
        presentation.save(pptx_preview_path)

        spire_presentation = SpirePresentation()
        spire_presentation.LoadFromFile(pptx_preview_path)

        if os.path.exists(self.preview_image):
            os.remove(self.preview_image)
        
        image = spire_presentation.Slides[0].SaveAsImage()
        image.Save(self.preview_image)
        image.Dispose()

        spire_presentation.Dispose()
        os.remove(pptx_preview_path)

        return self.preview_image

    def clear_old_assets(self) -> None:
        for asset in self.assets:
            if asset.type == AssetType.IMAGE and os.path.exists(asset.value):
                os.remove(asset.value)
        self.assets = []

        if self.preview is not None and os.path.exists(self.preview):
            os.remove(self.preview)
        self.preview = None
