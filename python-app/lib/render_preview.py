from lib.slide_controller import SlideController

from spire.presentation import Presentation as SpirePresentation

from pptx import Presentation as LibrePresentation
import uuid
import os

def render_preview(controller: type[SlideController], current_report: str, arguments: dict[str, str], assets: list[dict[str, str]]) -> str:
    presentation = LibrePresentation()
    controller.render_slide(presentation, arguments, assets)
    pptx_preview_path = os.path.join(current_report, str(uuid.uuid4()) + ".pptx")
    presentation.save(pptx_preview_path)

    spire_presentation = SpirePresentation()
    spire_presentation.LoadFromFile(pptx_preview_path)

    png_preview_path = os.path.join(current_report, "images", str(uuid.uuid4()) + ".png")
    image = spire_presentation.Slides[0].SaveAsImage()
    image.Save(png_preview_path)
    image.Dispose()

    spire_presentation.Dispose()
    os.remove(pptx_preview_path)

    return png_preview_path