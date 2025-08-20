from control_variables import AVAILABLE_SLIDE_CONTROLLERS

from lib.descriptive_error import DescriptiveError
from lib.image_slide.image_slide_controller import ImageSlideController

from models.image_slide.image_slide_kind import ImageSlideKind

def controller_for_kind(kind: ImageSlideKind) -> type[ImageSlideController]:
    controller = next((controller for controller in AVAILABLE_SLIDE_CONTROLLERS if controller.slide_kind() == kind), None)
    if controller is None:
        raise DescriptiveError(500, f"Tipo de controlador desconocido. Se obtuvo {kind.value}")
    return controller
