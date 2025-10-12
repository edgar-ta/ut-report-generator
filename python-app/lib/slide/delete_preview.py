from models.slide.self import Slide

import os

def delete_preview(slide: Slide):
    '''
    Takes a slide of any state and makes it a non-HAS_PREVIEW slide
    '''
    if slide.preview is None:
        return

    if os.path.exists(slide.preview):
        os.remove(slide.preview)
    
    slide.preview = None

def delete_previews(slides: list[Slide]):
    for slide in slides:
        delete_preview(slide=slide)
