from lib.directory_definitions import temporary_compiled_file_of_report, preview_image_of_slide
from lib.descriptive_error import DescriptiveError
from lib.report.compile_slides import compile_slides

from models.slide.self import Slide as ProjectSlide

from spire.presentation import Presentation as SpirePresentation

import os

def render_preview(root_directory: str, slides: ProjectSlide | list[ProjectSlide]):
    if not isinstance(slides, list):
        slides = [slides]

    if not all(slide.preview is None for slide in slides):
        raise DescriptiveError(http_error_code=500, message='Se intentó renderizar la vista previa de una diapositiva que ya tenía vista previa')

    temporary_path = temporary_compiled_file_of_report(root_directory=root_directory)
    compile_slides(slides=slides, filepath=temporary_path)
    spire_presentation = SpirePresentation()
    spire_presentation.LoadFromFile(temporary_path)

    file_names: list[str] = []

    for index, slide in enumerate(slides):
        spire_slide = spire_presentation.Slides[index + 1]
        file_name = preview_image_of_slide(root_directory=root_directory, slide_id=slide.identifier)
        file_names.append(file_name)

        image = spire_slide.SaveAsImage()
        image.Save(file_name)
        image.Dispose()

        slide.preview = file_name

    spire_presentation.Dispose()
    os.remove(temporary_path)
