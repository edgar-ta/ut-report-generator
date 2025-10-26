from lib.directory_definitions import temporary_compiled_file_of_report, preview_image_of_slide
from models.error.descriptive_error import DescriptiveError
from lib.report.compile_slides import compile_slides
from lib.slide.get_slide_state import get_slide_state, SlideState

from models.slide.self import Slide as ProjectSlide

from spire.presentation.common import *
from spire.presentation import *

import os

def split_in_chunks(list, n):
    return [list[i:i + n] for i in range(0, len(list), n)]

def render_preview(root_directory: str, slides: ProjectSlide | list[ProjectSlide]):
    '''
    Takes a list or a single slide whose state is HAS_DIRECTORY_BUT_NO_PREVIEW and 
    renders their preview (that is, it makes their state HAS_PREVIEW).

    It modifies the slide objects in place
    '''
    if not isinstance(slides, list):
        slides = [slides]

    if not all(
        get_slide_state(root_directory=root_directory, slide=slide) == SlideState.HAS_DIRECTORY_BUT_NO_PREVIEW 
        for slide in slides
        ):
        raise DescriptiveError(http_error_code=500, message='Se intentó renderizar la vista previa de una diapositiva que ya tenía vista previa')

    for slides_chunk in split_in_chunks(slides, 2):
        # This is going to be insanely time consuming. I should make it
        # asynchronous somehow

        temporary_path = temporary_compiled_file_of_report(root_directory=root_directory)
        compile_slides(slides=slides_chunk, filepath=temporary_path)

        spire_presentation = Presentation()
        spire_presentation.LoadFromFile(temporary_path)

        for index, slide in enumerate(slides):
            spire_slide = spire_presentation.Slides[index + 1]
            file_name = preview_image_of_slide(root_directory=root_directory, slide_id=slide.identifier)

            image = spire_slide.SaveAsImage()
            image.Save(file_name)
            image.Dispose()

            slide.preview = file_name

        spire_presentation.Dispose()
        os.remove(temporary_path)
