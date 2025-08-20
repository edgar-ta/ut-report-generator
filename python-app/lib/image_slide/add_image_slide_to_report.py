from lib.get_or_panic import get_or_panic
from lib.directory_definitions import base_directory_of_slide

from lib.image_slide.controller_for_kind import controller_for_kind
from lib.image_slide.build_image_slide_preview import build_image_slide_preview

from models.report import Report
from models.image_slide.self import ImageSlide
from models.image_slide.image_slide_kind import ImageSlideKind

from uuid import uuid4

import pandas
import os

def add_image_slide_to_report(report: Report, local_request) -> ImageSlide:
    kind = ImageSlideKind(get_or_panic(local_request.json, 'kind', 'El tipo de diapositiva no fue indicado'))
    index = local_request.json.get('index')

    controller = controller_for_kind(kind=kind)
    image_slide = ImageSlide(
        name="Mi diapositiva",
        kind=kind,
        arguments=controller.default_arguments(),
        creation_date=pandas.Timestamp.now(),
        identifier=str(uuid4()),
        last_edit=pandas.Timestamp.now(),
        preview=None
    )

    os.makedirs(base_directory_of_slide(root_directory=report.root_directory, slide_id=image_slide.identifier))
    preview = build_image_slide_preview(image_slide=image_slide, root_directory=report.root_directory)
    image_slide.preview = preview

    if index is not None:
        report.slides.insert(index, image_slide)
    else:
        report.slides.append(image_slide)
    
    return image_slide
