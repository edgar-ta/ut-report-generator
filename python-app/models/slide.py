from lib.file_extension import check_file_extension, has_extension
from lib.sections.failure_rate.controller import FailureRate_Controller
from lib.slide_controller import SlideController
from lib.descriptive_error import DescriptiveError
from lib.directory_definitions import assets_directory_of_slide, base_directory_of_slide, preview_image_of_slide

from spire.presentation import Presentation as SpirePresentation

from pptx import Presentation as LibrePresentation

from control_variables import AVAILABLE_SLIDE_CONTROLLERS

from models.slide_type import SlideType
from models.asset import Asset
from models.asset_type import AssetType

from functools import cached_property
from pandas import Timestamp

import uuid
import os

class Slide():
    def __init__(self, 
                 id: str, 
                 _type: SlideType, 
                 assets: list[Asset], 
                 arguments: dict[str, any], 
                 data_files: list[str], 
                 last_edit: Timestamp,
                 last_render: Timestamp | None,
                 root_directory: str,
                 ) -> None:
        self.id = id
        self._type = _type
        self.assets = assets
        self._arguments = arguments
        self._data_files = data_files
        self.last_edit = last_edit
        self.last_render = last_render

        self.root_directory = root_directory
    
    @property
    def arguments(self) -> dict[str, any]:
        '''
        Arguments are validated when using dot syntax. I. e., `slide.arguments = new_arguments`
        calls a setter function under the hood
        '''
        return self._arguments
    
    @arguments.setter
    def arguments(self, new_arguments: dict[str, any]) -> None:
        merged_arguments = { **self.arguments, **new_arguments }
        if merged_arguments != self.arguments:
            self.controller.validate_arguments(merged_arguments)
            self._arguments = merged_arguments
            self.last_edit = Timestamp.now()
    
    @property
    def data_files(self) -> list[str]:
        return self._data_files

    @data_files.setter
    def data_files(self, new_data_files: list[str]) -> None:
        files_changed = set(self.data_files) != set(new_data_files)
        if files_changed:
            self._data_files = new_data_files
            self.last_edit = Timestamp.now()
    
    def to_dict(self) -> dict[str, any]:
        return {
            "id": self.id,
            "type": self._type.value,
            "assets": [ asset.to_dict() for asset in self.assets ],
            "arguments": self.arguments,
            "data_files": self.data_files,
            "last_edit": self.last_edit.isoformat(),
            "last_render": None if self.last_render is None else self.last_render.isoformat()
        }
    
    @classmethod
    def from_json(cls, json_data: dict[str, any], root_directory: str) -> "Slide":
        return cls(
            id=json_data["id"],
            _type=SlideType(json_data["type"]),
            assets=[ Asset.from_json(asset) for asset in json_data["assets"] ],
            arguments=json_data["arguments"],
            data_files=json_data["data_files"],
            last_edit=Timestamp(json_data["last_edit"]),
            last_render=None if (last_render := json_data.get("last_render")) is None else Timestamp(last_render),
            root_directory=root_directory,
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
            last_edit=Timestamp.now(),
            last_render=None,
            root_directory=base_directory,
        )

        return slide
    
    @cached_property
    def controller(self) -> type[SlideController]:
        controller = next((controller for controller in AVAILABLE_SLIDE_CONTROLLERS if controller.slide_type() == self._type), None)
        if controller is None:
            raise DescriptiveError(500, f"Tipo de controlador desconocido. Se obtuvo {self._type.value}")
        return controller

    @cached_property
    def assets_directory(self) -> str:
        return assets_directory_of_slide(root_directory=self.root_directory, slide_id=self.id)
    
    @cached_property
    def base_directory(self) -> str:
        return base_directory_of_slide(root_directory=self.root_directory, slide_id=self.id)
    
    @property
    def preview_image(self) -> str | None:
        filename = next((
            file for file in os.listdir(self.base_directory)
            if has_extension(filename=file, extension="png")
        ), None)

        if filename is None:
            return None        
        return os.path.join(self.base_directory, filename)
    
    def build_new_assets(self) -> list[Asset]:
        if self.is_up2date:
            return self.assets
        
        assets = self.controller.build_assets(
            data_files=self.data_files, 
            arguments=self.arguments, 
            base_directory=self.assets_directory
        )
        self.assets = assets
        return assets

    def makedirs(self, exist_ok: bool = True):
        os.makedirs(self.base_directory, exist_ok=exist_ok)
        os.makedirs(self.assets_directory, exist_ok=exist_ok)

    def build_new_preview(self) -> str:
        if self.is_up2date and self.preview_image is not None:
            print("New preview was skipped")
            return self.preview_image

        presentation = LibrePresentation()
        self.controller.render_slide(
            presentation=presentation,
            arguments=self.arguments,
            assets=self.assets,
        )

        pptx_preview_path = os.path.join(self.root_directory, str(uuid.uuid4()) + ".pptx")
        presentation.save(pptx_preview_path)

        spire_presentation = SpirePresentation()
        spire_presentation.LoadFromFile(pptx_preview_path)

        preview_name = preview_image_of_slide(root_directory=self.root_directory, slide_id=self.id)
        if os.path.exists(preview_name):
            os.remove(preview_name)
        
        image = spire_presentation.Slides[0].SaveAsImage()
        image.Save(preview_name)
        image.Dispose()

        spire_presentation.Dispose()
        os.remove(pptx_preview_path)

        self.last_render = Timestamp.now()

        return preview_name

    def clear_old_assets(self) -> None:
        if self.is_up2date:
            return

        for asset in self.assets:
            if asset.type == AssetType.IMAGE and os.path.exists(asset.value):
                os.remove(asset.value)
        self.assets = []

        if self.preview_image is not None:
            os.remove(self.preview_image)

    @property
    def is_up2date(self) -> bool:
        return self.last_render is not None and self.last_render >= self.last_edit
