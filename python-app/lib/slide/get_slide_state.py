from lib.directory_definitions import base_directory_of_slide

from models.slide.self import Slide

from enum import Enum

import os

class SlideState(Enum):
    JUST_CREATED = 0,
    HAS_DIRECTORY_BUT_NO_PREVIEW = 1,
    HAS_PREVIEW = 2

def get_slide_state(root_directory, slide: Slide) -> SlideState:
    base_directory = base_directory_of_slide(root_directory=root_directory, slide_id=slide.identifier)    
    if not os.path.exists(base_directory) or not os.path.isdir(base_directory):
        return SlideState.JUST_CREATED
    
    if slide.preview is None or not os.path.exists(slide.preview):
        return SlideState.HAS_DIRECTORY_BUT_NO_PREVIEW

    return SlideState.HAS_PREVIEW
