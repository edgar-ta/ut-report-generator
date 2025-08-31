from lib.with_flask import with_flask
from lib.get_or_panic import get_or_panic
from lib.directory_definitions import base_directory_of_slide
from lib.format_for_edit import format_for_edit

from lib.image_slide.build_image_slide_preview import build_image_slide_preview
from lib.image_slide.controller_for_kind import controller_for_kind

from models.report import Report
from models.image_slide.self import ImageSlide

from flask import request

import re
import pandas
import os

@with_flask("/edit", methods=["POST"])
def edit_image_slide():
    report = get_or_panic(request.json, 'report', 'El identificador del reporte no está presente en la solicitud')
    image_slide = get_or_panic(request.json, 'slide', 'El identificador de la diapositiva no está presente en la solicitud')
    arguments = get_or_panic(request.json, "arguments", "La lista de argumentos no está presente en la solicitud")

    report = Report.from_identifier(identifier=report)
    image_slide: ImageSlide = report[image_slide]
    controller = controller_for_kind(kind=image_slide.kind)
    
    controller.validate_arguments(arguments=arguments)
    image_slide.arguments = arguments
    image_slide.last_edit = pandas.Timestamp.now()

    base_directory = base_directory_of_slide(root_directory=report.root_directory, slide_id=image_slide.identifier)
    for filename in os.listdir(base_directory):
        if re.match(pattern=r'preview-\d{8}-\d{4}-\d{4}-\d{4}-\d{12}.png'):
            os.remove(os.path.join(base_directory, filename))

    new_preview = build_image_slide_preview(image_slide=image_slide, root_directory=report.root_directory)
    image_slide.preview = new_preview

    report.save()

    return format_for_edit(response=image_slide)
