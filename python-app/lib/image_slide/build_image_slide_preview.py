from lib.image_slide.controller_for_kind import controller_for_kind

from lib.directory_definitions import base_directory_of_slide
from lib.directory_definitions import preview_image_of_slide

from spire.presentation import Presentation as SpirePresentation

from pptx import Presentation as LibrePresentation

from models.image_slide.self import ImageSlide

import uuid
import os

def build_image_slide_preview(image_slide: ImageSlide, root_directory: str) -> str:
    '''
    Pre-conditions
    - It assumes the base directory of the slide already exists. You should create
      it with another method
    - There are no other preview images in the slide's `base_directory`. You should
      delete them with another method so they don't clutter the user's file system  

    Builds a new preview for the passed `image_slide`
    '''
    presentation = LibrePresentation()

    controller_for_kind(kind=image_slide.category).render_slide(
        presentation=presentation,
        arguments=image_slide.parameters
    )

    pptx_preview_path = os.path.join(
        base_directory_of_slide(root_directory=root_directory, slide_id=image_slide.identifier), 
        str(uuid.uuid4()) + ".pptx"
        )
    
    presentation.save(pptx_preview_path)

    spire_presentation = SpirePresentation()
    spire_presentation.LoadFromFile(pptx_preview_path)

    preview_name = preview_image_of_slide(root_directory=root_directory, slide_id=image_slide.identifier)
    if os.path.exists(preview_name):
        os.remove(preview_name)
    
    image = spire_presentation.Slides[0].SaveAsImage()
    image.Save(preview_name)
    image.Dispose()

    spire_presentation.Dispose()
    os.remove(pptx_preview_path)

    return preview_name
