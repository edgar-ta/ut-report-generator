from lib.descriptive_error import DescriptiveError

from models.slide.self import Slide

import os

def delete_preview(slide: Slide):
    if slide.preview is None:
        return
    
    if os.path.exists(slide.preview) and not os.path.isfile(slide.preview):
        raise DescriptiveError(http_error_code=500, message='La vista previa del reporte apunta hacia un archivo inválido')

    if os.path.exists(slide.preview):
        os.remove(slide.preview)
    
    slide.preview = None

def delete_previews(slides: list[Slide]):
    for slide in slides:
        delete_preview(slide=slide)
